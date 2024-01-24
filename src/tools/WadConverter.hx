package;

class WadConverter {

    static function showUsage() {
        Sys.println("Usage: wad-converter [WADFILE]");
    }

    static function main() {
        var args = Sys.args();
        var file = args[0];

        if(file == null) {
            showUsage();
            return;
        }

        var content = sys.io.File.getBytes(file);
        var reader = new hxwad.Reader(content);
        var wad = reader.process();

        for(i in 0...wad.levels.length) {
            var wadlevel = wad.levels[i];
            var vertices = new Array<math.Point>();

            for(v in wadlevel.vertices) {
                vertices.push([v.x, v.y]);
            }

            var level:def.Level = {
                vertices:vertices,
                walls:[],
                rooms:[],
                objects:[],
                skyTextureName: "",
            };
            var json = haxe.Json.stringify(level);
            sys.io.File.saveContent('level$i.json', json);
        }
    }
}
