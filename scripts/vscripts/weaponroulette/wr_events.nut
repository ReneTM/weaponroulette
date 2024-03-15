//****************************************************************************************
//																						//
//									weaponroulette.nut									//
//																						//
//****************************************************************************************



local playerPoints = {}

function OnGameEvent_player_death(params){
	local victim = null
	if("userid" in params){
		victim = GetPlayerFromUserID(params.userid)
	}else{
		victim = EntIndexToHScript(params.entityid)
	}
	
	local attacker = null
	if("attacker" in params){
		attacker = GetPlayerFromUserID(params.attacker)
	}else{
		attacker = EntIndexToHScript(params.attackerentid)
	}
	
	if(attacker == null || !attacker.IsPlayer()){
		return
	}
		
	local userid = attacker.GetPlayerUserId()
	if(!IsPlayerABot(attacker)){
		if(!attacker.IsIncapacitated()){
			if(attacker in playerPoints){
				if(playerPoints[attacker].points > 10){

					local weapon_prev_name = ""
							local curr_weapon = attacker.GetActiveWeapon()
							if(curr_weapon.GetClassname() == "weapon_melee"){
								weapon_prev_name = GetMeleeName(curr_weapon)
							}else{
								weapon_prev_name = curr_weapon.GetClassname()
							}
					
					StripInventory(attacker)

					ScheduleTask(GiveWeaponDelayed, 0.33, { player = attacker, weapon_prev_name = weapon_prev_name, scope = this } )
					
					playerPoints[attacker].points = 0
				}else{
					playerPoints[attacker].points += 1
				}
			}else{
				playerPoints[attacker] <- { points = 1 }
			}
		}
	}
}


__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)