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
	var ?main_menu:String;
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
	// intro
	var loading:String;
	// greet
	var greet_title:String;
	var greet_body:String;
}

class PhraseManager
{
	public static var PHRASES_REQUIRING_FALLBACK:Array<String> = [];

	public static var languageList:LangHaxe = null;
	public static function init() {
		// Avoid loading the language file everytime getPhrase is called.
		try {
			languageList = Language.readLang(LanguageManager.LANGUAGE);
		} catch(e) {
			trace("Failed loading language: " + LanguageManager.LANGUAGE + " // " + e.message);
			languageList = Language.readLang("english"); // Use english.
			return;
		}
		trace("Language \""+LanguageManager.LANGUAGE+"\" loaded.");
	}

    public static function getPhrase(phrase:Dynamic, ?fb:Dynamic = null):Dynamic
    {
        var json:PhrasesJson = languageList.phrases;
        var fallback:Dynamic = (fb != null ? fb : phrase);

        try {
			var field:String = Std.string(phrase).toLowerCase().replace(' ', '_');
			if (Reflect.hasField(json, field)) {
				return Reflect.getProperty(json, field);
			} else {
				trace("Could not find phrase: " + field);
				return fb;
			}
		} catch(e) {
            if (!PHRASES_REQUIRING_FALLBACK.contains(phrase)){
				trace('[PHRASE MANAGER] Phrase "$phrase" required fallback');
				PHRASES_REQUIRING_FALLBACK.push(phrase);
			}
            return fallback;
        }

        return fallback;
        
    }
    
}
