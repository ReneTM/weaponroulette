//****************************************************************************************
//																						//
//								weaponroulette_director.nut								//
//																						//
//****************************************************************************************




MutationOptions <-
{
	// General
	cm_NoSurvivorBots	= 1
	
	// Special Infected
	MaxSpecials			= 6

	// Convert items
	weaponsToConvert =
	{
	}

	function ConvertWeaponSpawn(classname){
		if (classname in weaponsToConvert){
			return weaponsToConvert[classname]
		}
		return 0
	}	
	
	// Controll which weapons are allowed to be spawned
	weaponsToPreserve =
	{
		weapon_pain_pills		= 0
		weapon_adrenaline		= 0
		weapon_first_aid_kit	= 0
	}

	function AllowWeaponSpawn(classname){

		if (classname in weaponsToPreserve){
			return true
		}
		return false
	}
	
	// Avoid fallen survivors carrying items
	function AllowFallenSurvivorItem(item){
		return false
	}
	
	// Get default items for survivors
	DefaultItems =
	[
		"weapon_pistol_magnum"
	]

	function GetDefaultItem( idx ){
		if ( idx < DefaultItems.len() ){
			return DefaultItems[idx]
		}
		return 0
	}
}