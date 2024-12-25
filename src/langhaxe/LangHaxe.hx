package langhaxe;

typedef LangHaxe = {
	var name:String;
	var ?asset_suffix:String;
	var ?lang_ver:Float;
	var ?phrases:PhrasesJson;
}

typedef PhrasesJson = {
	// the game name.
	var ?linetapper:String;
    // transitions
	var ?mainmenu:String;
	var ?gameplay:String;
	var ?song_select:String;
	var ?level_editor:String;
	var ?credits:String;
	// level editor menu
	var ?beats_per_minute:String;
	// song select menu
	var ?start_typing_your_songs_name:String;
    // settings menu
	var ?settings_Messages:Array<String>;
	var ?search_Settings:String;
	var ?settings:String;
	var ?settings_Graphics:String;
	var ?settings_Antialiasing:String;
	var ?settings_Gameplay:String;
	var ?settings_Tile_Offset:String;
	var ?settings_Audio:String;
	var ?settings_Master_Volume:String;
	var ?settings_Music_Volume:String;
	var ?settings_SFX_Volume:String;
}

class PhraseManager
{

    public static function getPhrase(phrase:String)
    {

        switch(phrase.toLowerCase())
        {
            default:
                trace('Unknown phrase: $phrase');
        }
        
    }
    
}