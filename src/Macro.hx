package;

import haxe.macro.Context;
import haxe.macro.Expr;

class Macro {

    public static macro function getDataFilePath(folder:String, file:String, applyRelative:Bool = true) {
        var dataPath = haxe.macro.Context.definedValue("dataPath") + "/";
        var dataRelativePath = haxe.macro.Context.definedValue("dataRelativePath") + "/";
        return macro $v {(applyRelative ? dataRelativePath : dataPath) + folder + "/" + file};
    }

    public static macro function getDataRootPath(folder:String) {
        var dataRelativePath = haxe.macro.Context.definedValue("dataRelativePath") + "/";
        return macro $v {dataRelativePath + folder};
    }

    public static macro function getDataFilePaths(folder:String) {
        var dataPath = haxe.macro.Context.definedValue("dataPath") + "/";

        if(!sys.FileSystem.exists(dataPath + folder)) {
            return macro $a {[]};
        }

        var result = [];
        var process;
        process = function(dir, subdir) {
            var files = sys.FileSystem.readDirectory(dir + '/' + subdir);

            for(file in files) {
                if(sys.FileSystem.isDirectory(dir + '/'  + subdir + '/' + file)) {
                    process(dir, subdir + '/' + file);
                } else {
                    var path = subdir + '/' + file;
                    path = path.substring(1);
                    result.push(path);
                }
            }
        }
        process(dataPath + folder, '');
        var exprs = [for(file in result) macro $v {file}];
        return macro $a {exprs};
    }
}
