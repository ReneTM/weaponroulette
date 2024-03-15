//****************************************************************************************
//																						//
//									WeaponRoulette.nut									//
//																						//
//****************************************************************************************


::world <- Entities.FindByClassname(null, "worldspawn")
world.ValidateScriptScope()

if(!IsSoundPrecached("player/laser_on.wav")){
	PrecacheSound("player/laser_on.wav")
}

IncludeScript("weaponroulette/wr_director")
IncludeScript("weaponroulette/wr_events")



function createThinkTimer(){
	local timer = null
	while (timer = Entities.FindByName(null, "thinkTimer")){
		timer.Kill()
	}
	timer = SpawnEntityFromTable("logic_timer", { targetname = "thinkTimer", RefireTime = 0.01 })
	timer.ValidateScriptScope()
	timer.GetScriptScope()["scope"] <- this

	timer.GetScriptScope()["func"] <- function (){
		scope.Think()
	}
	timer.ConnectOutput("OnTimer", "func")
	EntFire("!self", "Enable", null, 0, timer)
}


local sharpMeleeData =
[
	{ model = "models/v_models/v_knife_t.mdl", itemName = "knife", alias = "knife" }
	{ model = "models/weapons/melee/v_crowbar.mdl", itemName = "crowbar", alias = "crowbar" }
	{ model = "models/weapons/melee/v_fireaxe.mdl", itemName = "fireaxe", alias = "fireaxe" }
	{ model = "models/weapons/melee/v_katana.mdl", itemName = "katana", alias = "katana" }
	{ model = "models/weapons/melee/v_machete.mdl", itemName = "machete", alias = "machete" }
	{ model = "models/weapons/melee/v_pitchfork.mdl", itemName = "pitchfork", alias = "pitchfork" }
]

local bluntMeleeData =
[
	{ model = "models/weapons/melee/v_riotshield.mdl", itemName = "riotshield" , alias = "riotshield"}
	{ model = "models/weapons/melee/v_shovel.mdl", itemName = "shovel", alias = "shovel"}
	{ model = "models/weapons/melee/v_bat.mdl", itemName = "baseball_bat", alias = "bat"}
	{ model = "models/weapons/melee/v_cricket_bat.mdl", itemName = "cricket_bat", alias = "cricket"}
	{ model = "models/weapons/melee/v_golfclub.mdl", itemName = "golfclub", alias = "golfclub"}
	{ model = "models/weapons/melee/v_tonfa.mdl", itemName = "tonfa", alias = "tonfa"}
	{ model = "models/weapons/melee/v_electric_guitar.mdl", itemName = "electric_guitar", alias = "guitar"}
	{ model = "models/weapons/melee/v_frying_pan.mdl", itemName = "frying_pan", alias = "pan"}
]




function GetAvailableSharpMelees(){
	local sharps = []
	foreach(dataSet in sharpMeleeData){
		if(IsModelPrecached(dataSet.model)){
			sharps.append(dataSet.itemName)
		}
	}
	return sharps
}

function GetAvailableBluntMelees(){
	local blunts = []
	foreach(dataSet in bluntMeleeData){
		if(IsModelPrecached(dataSet.model)){
			blunts.append(dataSet.itemName)
		}
	}
	return blunts
}




// Will give the player a random sharp/blunt weapon depending which melee is available for the current map
// ----------------------------------------------------------------------------------------------------------------------------

function getAvailableMelee(attribute){
	local sharps = GetAvailableSharpMelees()
	local blunts = GetAvailableBluntMelees()
	local melee = null
	if(sharps.len() != 0 && blunts.len() != 0){
		if(attribute == "Sharp"){
		melee = sharps[RandomInt(0, sharps.len() -1)]
		}
		else{
			melee = blunts[RandomInt(0, blunts.len() -1)]
		}
		return melee
	}else{
		return "bat"
	}
}

function GetRandomItem(){
	return GetRandomItemFromArray(arsenal)
}

function GiveWeaponDelayed(){
	
	local newWeaponFound = false
	local randomWeapon = ""
	
	while(!newWeaponFound){
		randomWeapon = scope.GetRandomItem()
		if(randomWeapon != weapon_prev_name){
			newWeaponFound = true
		}
	}
	
	if(player.IsValid()){
		player.GiveItem(randomWeapon)
		EmitAmbientSoundOn("player/laser_on.wav", 1, 100, 180, player)
	}
}




function GetRandomItemFromArray(arr){
	if(arr.len() > 0){
		return arr[ RandomInt(0, arr.len() - 1) ]
	}else{
		return null
	}
}




arsenal <- 
[
	"weapon_pumpshotgun", "weapon_shotgun_chrome", "weapon_shotgun_spas", "weapon_autoshotgun",
	
	"weapon_pistol", "weapon_pistol_magnum",

	"weapon_rifle_ak47", "weapon_rifle_sg552", "weapon_rifle_m60", "weapon_rifle_desert", "weapon_rifle",

	"weapon_smg", "weapon_smg_silenced", "weapon_smg_mp5",

	"weapon_sniper_awp", "weapon_sniper_military", "weapon_sniper_scout", "weapon_hunting_rifle",
	
	"weapon_grenade_launcher", "chainsaw"
]

foreach(weapon in GetAvailableSharpMelees()){
	arsenal.append(weapon)
}

foreach(weapon in GetAvailableBluntMelees()){
	arsenal.append(weapon)
}



function GetMeleeName(ent){
	if(ent.GetClassname() != "weapon_melee"){
		return null
	}else{
		return NetProps.GetPropString(ent, "m_strMapSetScriptName")
	}
}

function IsDualWielding(ent){
	return NetProps.GetPropInt(ent, "m_isDualWielding")
}

function SetDualWielding(ent){
	NetProps.SetPropInt(ent, "m_isDualWielding", 1)
}



function ScheduleTask(func, time, args = {}){ // can only check every 33 milliseconds so be careful
	tasks.append(Task(func, args, Time() + time))
}




class Task {
	functionKey = null
	args = null
	endTime = null
	
	/*
		We place the function in a table with the arguments so that the function can access the arguments
	*/
	
	constructor(func, arguments, time){
		functionKey = UniqueString("TaskFunction")
		args = arguments
		args[functionKey] <- func
		endTime = time
	}
	
	function CallFunction(){
		args[functionKey]()
	}
	
	function ReachedTime(){
		return Time() >= endTime
	}
}



::StripInventory <- function(ent){
	local inv = {}
	GetInvTable(ent, inv)
	
	foreach(slot, ent in inv){
		if(ent.IsValid()){
			ent.Kill()
		}
	}
}




tasks <- []

function Think(){
	for(local i=0; i<tasks.len(); i++){
		if(tasks[i].ReachedTime()){
			try{
				tasks[i].CallFunction()
			} catch(e){
				printl(e)
			}
			tasks.remove(i)
			i -= 1
		}
	}
}




createThinkTimer()



