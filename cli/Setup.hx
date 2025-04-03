package;

import sys.io.File;
import sys.FileSystem;
using StringTools;

class Setup {
    static final LIB_START:String = "<!--LT_LIB-->";
    static final LIB_END:String = "<!--LT_LIB_END-->";

    static final RESET:String = "\x1b[0m";
    static final GREEN:String = "\x1b[32m";
    static final RED:String = "\x1b[31m";
    static final YELLOW:String = "\x1b[33m";
    static final CYAN:String = "\x1b[36m";
    static final BOLD:String = "\x1b[1m";

    public static function main():Void {
        Sys.println('${BOLD}${CYAN}==== LineTapper Setup ====${RESET}');

        if (!FileSystem.exists("Project.xml")) {
            Sys.println('${BOLD}${RED}Error: Project.xml not found.${RESET}');
            return;
        }

        var project:String = File.getContent("Project.xml");
        var startIndex:Int = project.indexOf(LIB_START);
        var endIndex:Int = project.indexOf(LIB_END);

        if (startIndex == -1 || endIndex == -1) {
            Sys.println('${BOLD}${RED}Error: Library markers not found in Project.xml.${RESET}');
            return;
        }

        var libsSection:String = project.substring(startIndex + LIB_START.length, endIndex).trim();

        if (libsSection == "") {
            Sys.println('${BOLD}${YELLOW}No libraries found in Project.xml.${RESET}');
            return;
        }

        Sys.println('${BOLD}${CYAN}Updating haxelib...${RESET}');
        run("haxelib", ["update"], ()-> {
            installLibraries(libsSection);
        }, onFailed);
    }

    static function installLibraries(libsSection:String):Void {
        var libRegex:EReg = new EReg('<haxelib\\s+([^>]+)\\s*/>', 'g');
        var pos:Int = 0;

        while (libRegex.matchSub(libsSection, pos)) {
            var attributes:String = libRegex.matched(1);
            pos = libRegex.matchedPos().pos + libRegex.matchedPos().len;

            var nameRegex:EReg = new EReg('name\\s*=\\s*"([^"]+)"', '');
            var versionRegex:EReg = new EReg('version\\s*=\\s*"([^"]+)"', '');

            var libName:String = "";
            var libVersion:String = "";

            if (nameRegex.match(attributes))
                libName = nameRegex.matched(1);
            if (versionRegex.match(attributes))
                libVersion = versionRegex.matched(1);

            if (libName != "") {
                var args:Array<String> = libVersion != "" ? ["install", libName, libVersion] : ["install", libName];
                Sys.println('${BOLD}${YELLOW}Installing: ${libName}${libVersion != "" ? " (version " + libVersion + ")" : ""}${RESET}');
                run("haxelib", args, function() {
                    Sys.println('${GREEN}[✓] Installed: ${libName}${RESET}');
                }, onFailed);
            }
        }
    }

    static function run(cmd:String, args:Array<String>, onSuccess:Void->Void, onFail:String->Void):Void {
        Sys.println('${CYAN}> ${cmd} ${args.join(" ")}${RESET}');
        var result = Sys.command(cmd, args);
        if (result == 0) 
            onSuccess();
        else
            onFail(cmd);
    }

    static function onFailed(cmd:String):Void {
        Sys.println('${RED}[✗] Error occurred while running: ${cmd}${RESET}');
    }
}
