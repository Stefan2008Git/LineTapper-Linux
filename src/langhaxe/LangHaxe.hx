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
	var ?leaving_gameplay:String;
	var ?song_select:String;
	var ?level_editor:String;
	var ?credits:String;
	// level editor menu
	var ?beats_per_minute:String;
	// song select menu
	var ?start_typing_your_songs_name:String;
    // settings menu
	var ?settings_messages:Array<String>;
	var ?search_settings:String;
	var ?settings:String;
	var ?settings_graphics:String;
	var ?settings_antialiasing:String;
	var ?settings_gameplay:String;
	var ?settings_tile_offset:String;
	var ?settings_audio:String;
	var ?settings_master_volume:String;
	var ?settings_music_volume:String;
	var ?settings_sfx_volume:String;
    // pause menu
	var ?paused:String;
	// main menu
	var ?play:String;
	var ?edit:String;
}

class PhraseManager
{

    public static function getPhrase(phrase:Dynamic, ?fb:Dynamic = null):Dynamic
    {
        var json:PhrasesJson = Language.readLang(LanguageManager.LANGUAGE).phrases;
        var fallback:Dynamic = (fb != null ? fb : phrase);

        try {switch(phrase.toLowerCase().replace(' ', '_'))
		{
			case 'beats_per_minute': return json.beats_per_minute;
			case 'credits': return json.credits;
			case 'edit': return json.edit;
			case 'gameplay': return json.gameplay;
			case 'level_editor': return json.level_editor;
			case 'linetapper': return json.linetapper;
			case 'mainmenu': return json.mainmenu;
			case 'paused': return json.paused;
			case 'play': return json.play;
			case 'search_settings': return json.search_settings;
			case 'settings': return json.settings;
			case 'settings_antialiasing': return json.settings_antialiasing;
			case 'settings_audio': return json.settings_audio;
			case 'settings_gameplay': return json.settings_gameplay;
			case 'settings_graphics': return json.settings_graphics;
			case 'settings_master_volume': return json.settings_master_volume;
			case 'settings_messages': return json.settings_messages;
			case 'settings_music_volume': return json.settings_music_volume;
			case 'settings_sfx_volume': return json.settings_sfx_volume;
			case 'settings_tile_offset': return json.settings_tile_offset;
			case 'song_select': return json.song_select;
			case 'start_typing_your_songs_name': return json.start_typing_your_songs_name;

            default:
                trace('[PHRASE MANAGER] Unknown phrase: "$phrase"');
        }}catch(e) {
            trace('[PHRASE MANAGER] Phrase "$phrase" required fallback');
            return fallback;
        }

        return fallback;
        
    }
    
}