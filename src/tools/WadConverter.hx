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

    static function toPoint(v):math.Point {
        return [v.x, v.y];
    }

    static function toVertexIndex(id:Int, count:Int):Int {
        if((id >> 15) == 1) {
            id = (id & 0x7fff);
            return count + id;
        }

        return id;
    }

    static function exportLevel(wad:hxwad.File, index:Int, output:String) {
        var wadlevel = wad.levels[index];
        var vertices = new Array<math.Point>();
        var walls = new Array<def.Wall>();
        var rooms = new Array<def.Room>();
        trace(wadlevel.vertices.length);

        for(v in wadlevel.vertices) {
            vertices.push([v.x, -v.y]);
        }

        for(v in wadlevel.glVertices) {
            vertices.push([v.x, -v.y]);
        }

        /*
                for(s in wadlevel.sectors) {
                    rooms.push({
                        walls:[],
                        floorTextureName:"level/floor",
                        bottom:s.floorHeight / 4,
                        top:s.ceilingHeight / 4
                    });
                }

                for(l in wadlevel.linedefs) {
                    walls.push({
                        a: l.beginVertex,
                        b: l.endVertex,
                        textureName: null,
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

                            if(sidedef.middleTexture.length > 2) {
                                walls[last_wall_index].textureName = "level/wall";
                                // trace('"${sidedef.middleTexture}"');
                            }
                        }
                    }
                    apply(l.rightSidedef);
                    apply(l.leftSidedef);
                }
                */
        var t = 0;

        for(s in wadlevel.glSubsectors) {
            rooms.push({
                walls:[],
                floorTextureName:"level/floor",
                bottom:0,
                top:32
            });
            var room = rooms[rooms.length - 1];

            for(i in 0...s.segmentCount) {
                var segment = wadlevel.glSegments[s.firstSegment + i];
                var a = toVertexIndex(segment.beginVertex, wadlevel.vertices.length);
                var b = toVertexIndex(segment.endVertex, wadlevel.vertices.length);
                var sidedef = null;

                if(segment.linedef != 0xffff) {

                trace(segment.linedef);
                    var linedef = wadlevel.linedefs[segment.linedef];

                    if(segment.side == 0) {
                        sidedef = wadlevel.sidedefs[linedef.rightSidedef];
                    } else {
                        sidedef = wadlevel.sidedefs[linedef.leftSidedef];
                    }

                    var sector = wadlevel.sectors[sidedef.sector];

                    room.bottom = sector.floorHeight;
                    room.top = sector.ceilingHeight;
                }

                var texture = null;

                if(sidedef != null && sidedef.middleTexture != "-") {
                    texture = "level/wall";
                }

                walls.push({
                    a: a,
                    b: b,
                    textureName: texture,
                    bottomTextureName: 'level/wall',
                    textureScale: [1, 1]
                });

                room.walls.push(walls.length - 1);
            }
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
