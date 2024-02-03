package;

import def.Level;

class WadConverter {

    static function showUsage() {
        Sys.println("Usage: wad-converter [WADFILE] [LEVEL] [OUTPUT_PATH]");
    }

    static function main() {
        var args = Sys.args();
        var arg_file = args[0];
        var arg_level = args[1];
        var arg_output = args[2];

        if(arg_file == null || (arg_level != "all" && arg_output == null)) {
            showUsage();
            return;
        }

        var content = sys.io.File.getBytes(arg_file);
        var reader = new hxwad.Reader(content);
        var wad = reader.process();

        if(arg_level == "all") {
            for(i in 0...wad.levels.length) {
                exportLevel(wad, i, null);
            }
        } else {
            var level_index = Std.parseInt(arg_level);
            exportLevel(wad, level_index, arg_output);
        }
    }

    static function exportLevel(wad:hxwad.File, index:Int, output:String) {
        var wadlevel = wad.levels[index];
        var vertices = new Array<math.Point>();
        var walls = new Array<def.Wall>();
        var rooms = new Array<def.Room>();

        for(v in wadlevel.vertices) {
            vertices.push([v.x, v.y]);
        }

        for(s in wadlevel.sectors) {
            rooms.push({
                walls:[],
                floorTextureName:"level/floor",
                bottom:s.floorHeight,
                top:s.ceilingHeight
            });
        }

        for(l in wadlevel.linedefs) {
            walls.push({
                a: l.begin,
                b: l.end,
                textureName: 'level/wall',
                bottomTextureName: 'level/wall',
                textureScale: [1, 1]
            });
            var last_wall_index = walls.length - 1;
            function apply(sidedef_index) {
                if(sidedef_index != -1) {
                    var sidedef = wadlevel.sidedefs[sidedef_index];
                    var n = sidedef.sector;

                    if(rooms[n] == null) {
                        rooms[n] = {walls:[], floorTextureName:"level/floor", bottom:0, top:64};
                    }

                    rooms[n].walls.push(last_wall_index);
                }
            }
            apply(l.rightSidedef);
            apply(l.leftSidedef);
        }

        var level:def.Level = {
            vertices: vertices,
            walls: walls,
            rooms: rooms,
            objects: [],
            skyTextureName: "",
        };
        var json = haxe.Json.stringify(level);
        var name = 'level${index}';
        sys.io.File.saveContent(output != null ? output : '${name}.json', json);
        Sys.println('Extracted ${name} : ${level.vertices.length} vertices, ${level.walls.length} walls, ${level.rooms.length} rooms');
    }
}
