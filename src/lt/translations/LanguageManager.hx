package lt.translations;

class LanguageManager {
    public static var LANGUAGE(get, never):String;   
    static function get_LANGUAGE():String {
        return Preferences.data.language;
    }
}