package;

import def.Level;

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
            var walls = new Array<def.Wall>();

            for(v in wadlevel.vertices) {
                vertices.push([v.x, v.y]);
            }

            for(l in wadlevel.linedefs) {
                walls.push({
                    a: l.begin,
                    b: l.end,
                    textureName: 'wall',
                    bottomTextureName: 'wall',
                    textureScale: [1, 1]
                });
            }

            var level:def.Level = {
                vertices: vertices,
                walls: walls,
                rooms: [],
                objects: [],
                skyTextureName: "",
            };
            var json = haxe.Json.stringify(level);
            var name = 'level$i';
            sys.io.File.saveContent('${name}.json', json);
            Sys.println('Extracted ${name} : ${level.vertices.length} vertices, ${level.walls.length} walls');
        }
    }
}
