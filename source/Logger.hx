package;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class Logger {
    public static var dateColorCode:String;
    public static var classColorCode:String;
    public static var methodColorCode:String;
    public static var lineNumberColorCode:String;
    public static var levelColorCode:String;
    public static var logFilePath:String;

    public static function init() {
        logFilePath = "logs/" + Sys.time() + ".txt";
        createLogsFolder();
    }

    private static function createLogsFolder() {
        #if sys
        var logsFolderPath = "logs/";
        if (!FileSystem.exists(logsFolderPath)) {
            FileSystem.createDirectory(logsFolderPath);
        }
        #end
    }    

    public static function log(message:Dynamic, ?pos:haxe.PosInfos) {
        var className = pos.className;
        var methodName = pos.methodName;
        var lineNumber = pos.lineNumber;
        var timestamp = Date.now().toString();

        var level:String;
        var levelFormat:String;

        if (message.indexOf("Error") != -1) {
            level = "ERROR";
            levelFormat = "\x1b[31m\x1b[1m";
        } else if (message.indexOf("Warn") != -1) {
            level = "WARN";
            levelFormat = "\x1b[33m\x1b[1m";
        } else {
            level = "LOG";
            levelFormat = "\x1b[32m\x1b[1m";
        }

        dateColorCode = "\x1b[36m\x1b[1m";
        classColorCode = "\x1b[35m\x1b[1m";
        methodColorCode = "\x1b[34m\x1b[1m";
        lineNumberColorCode = "\x1b[30m\x1b[1m";

        var resetCode = "\x1b[0m";

        var a = '$dateColorCode$timestamp$resetCode [$levelFormat$level$resetCode] [$classColorCode$className$resetCode.$methodColorCode$methodName$resetCode:$lineNumberColorCode$lineNumber$resetCode] - $message';
        var b = '$timestamp [$level] [$className.$methodName:$lineNumber] - $message';

        Sys.println(a);
        saveLogToFile(b);
    }

    private static function saveLogToFile(logMessage:Dynamic) {
        if (logFilePath == null) {
            return;
        }

        #if sys
        var file = File.append(logFilePath);
        if (file != null) {
            file.writeString(logMessage + "\n");
            file.close();
        } else {
            log("Error: Unable to open log file for appending.");
        }
        #end
    }
}
