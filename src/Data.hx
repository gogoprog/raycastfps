package;

class Data {
    private static var filePaths:Array<String>;
    private static var dataPath:String = "./data";

    public static function initialize(callback) {
        if(untyped js.Browser.document.urfpsData) {
            dataPath = untyped js.Browser.document.urfpsData;
        }

        App.log('Using dataPath = "${dataPath}"');
        var req = new haxe.Http('${dataPath}/manifest.txt');
        req.onData = function(datatxt) {
            filePaths = datatxt.split("\n");
            callback();
        };
        req.request(false);
    }

    public static function getFilePaths(folder:String) {
        var result = [];
        var folder2 = folder + '/';

        for(file in filePaths) {
            if(file.substr(0, folder.length + 1) == folder2) {
                var tmp = file.substr(folder2.length);
                result.push(tmp);
            }
        }

        return result;
    }

    public static function getRootPath(folder:String) {
        return dataPath + "/" + folder;
    }
}
