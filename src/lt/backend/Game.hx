package lt.backend;

class Game {
    /**
     * Current LineTapper version.
     */
    public static final VERSION:String = "0.1.0";
    /**
     * Current LineTapper API Level, used for scripts.
     * Higher numbers means newer version.
     * Lower numbers means older version.
     */
    public static final API_LEVEL:Int = 1;
    /**
     * Information about current LineTapper build.
     */
    public static final VERSION_LABEL:String = 'LT v${VERSION} API-${API_LEVEL}';
    /**
     * Languages that LineTapper supports.
     */
    public static final SUPPORTED_LANGUAGES:Array<String> = [
        'english', 'indonesia'
    ];

}