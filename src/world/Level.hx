package world;

typedef WallData = {
    var a:Int;
    var b:Int;
    var bottomTextureName:String;
    var textureName:String;
    var height:Float;
    var textureScale:math.Point;
}

typedef RoomData = {
    var walls:Array<Int>;
    var floorTextureName:String;
    var bottom:Float;
    var top:Float;
    @:optional var door:Bool;
}

typedef LevelData = {
    var vertices:Array<math.Point>;
    var walls:Array<WallData>;
    var rooms:Array<RoomData>;
    var skyTextureName:String;
    var startPosition:math.Point;
}

class Level {
    public var data:LevelData;

    public var sectors:Array<Sector> = [];
    public var skyTexture:display.Framebuffer;

    public function new() {
    }

    public function load() {
        /*
            var sector = new Sector();
            sector.floorTextureName = "floor";
            addWall(sector, 0, 0, 6, 0, "wall");
            addWall(sector, 6, 0, 6, 6, "wall");
            addWall(sector, 6, 6, 0, 6, "wall");
            addWall(sector, 0, 6, 0, 0, null, "wall");
            sectors.push(sector);
            var sector = new Sector();
            sector.floorTextureName = "floor";
            addWall(sector, 0, 0, 0, 6, null, "wall");
            addWall(sector, 0, 6, -1, 6, "wall");
            addWall(sector, -1, 6, -1, 0, null, "wall");
            addWall(sector, -1, 0, 0, 0, "wall");
            sector.bottom = 10;
            sectors.push(sector);
            var sector = new Sector();
            sector.floorTextureName = "floor";
            addWall(sector, -1, 0, -1, 6, null, "wall");
            addWall(sector, -1, 6, -2, 6, "wall");
            addWall(sector, -2, 6, -2, 0, "null", "wall");
            addWall(sector, -2, 0, -1, 0, "wall");
            sector.bottom = 20;
            sectors.push(sector);
            var sector = new Sector();
            sector.floorTextureName = "floor";
            addWall(sector, -2, 0, -2, 6, null, "wall");
            addWall(sector, -2, 6, -3, 6, "wall");
            addWall(sector, -3, 6, -3, 0, "wall");
            addWall(sector, -3, 0, -2, 0, "wall");
            sector.bottom = 30;
            sectors.push(sector);

            */
        /*
            addWall(0, 0, 9, 4);
            addWall(9, 4, 6, 4);
            addWall(6, 9, 6, 4);
            addWall(6, 9, 4, 9, "floor");
            var w = addWall(5.5, 6, 5.5, 6.5, "door");
            w.height = 0.5;
            createDoor(w);
            var w = addWall(5.5, 6.5, 5.5, 7.0, "door");
            w.height = 0.5;
            w.offset = 10;
            createDoor(w);
            addWall(4, 4, 4, 9);
            addWall(4, 4, -12, 4);
            addWall(-12, 3, -12, 4);
            addWall(-12, 3, 0, 3);
            addWall(0, 0, 0, 3);
            addWall(1, 1, 8, 1);
            addWall(8, 2, 8, 1);
            addWall(8, 2, 1, 2);
            addWall(1, 1, 1, 2);
            */
        data = {
            skyTextureName: "sky",
            vertices: [
                [0, 0],
                [1024, 0],
                [1024, 1024],
                [0, 1024],
                [-1024, 1024],
                [-1024, 0]
            ],
            walls: [
            {
                a: 0,
                b: 1,
                bottomTextureName: "door",
                textureName: "wall",
                height: 1,
                textureScale: [1, 1]
            },
            {
                a: 1,
                b: 2,
                bottomTextureName: "door",
                textureName: "wall",
                height: 1,
                textureScale: [1, 1]
            },
            {
                a: 2,
                b: 3,
                bottomTextureName: "door",
                textureName: "wall",
                height: 1,
                textureScale: [1, 1]
            },
            {
                a: 3,
                b: 0,
                bottomTextureName: "door",
                textureName: null,
                height: 1,
                textureScale: [1, 1]
            },
            {
                a: 3,
                b: 4,
                bottomTextureName: "door",
                textureName: "wall",
                height: 1,
                textureScale: [1, 1]
            },
            {
                a: 4,
                b: 5,
                bottomTextureName: "door",
                textureName: "wall",
                height: 1,
                textureScale: [1, 1]
            },
            {
                a: 5,
                b: 0,
                bottomTextureName: "door",
                textureName: "wall",
                height: 1,
                textureScale: [1, 1]
            }

            ],
            rooms: [
            {
                walls: [0, 1, 2, 3],
                floorTextureName: "floor",
                bottom: 0,
                top: 3
            },
            {
                walls: [3, 4, 5, 6],
                floorTextureName: "floor2",
                bottom: 47,
                top: 46,
                door: true
            }
            ],
            startPosition: [128, 128]
        };
        generateSectors();
    }

    function addWall(sector:Sector, a:Float, b:Float, c:Float, d:Float, texName:String = null, bottomTexName:String = null) {
        var wall = new Wall([a* 200, b * 200], [c * 200, d * 200], texName, bottomTexName);
        wall.height = 1 + Std.random(3);
        sector.walls.push(wall);
        return wall;
    }

    public function update() {
        if(skyTexture == null) {
            skyTexture = Main.context.textureManager.get(data.skyTextureName);
        }

        for(sector in sectors) {
            if(sector.floorTexture == null && sector.floorTextureName != null) {
                sector.floorTexture = Main.context.textureManager.get(sector.floorTextureName);
            }

            for(wall in sector.walls) {
                if(wall.texture == null && wall.textureName != null) {
                    wall.texture = Main.context.textureManager.get(wall.textureName);
                }

                if(wall.bottomTexture == null && wall.bottomTextureName != null) {
                    wall.bottomTexture = Main.context.textureManager.get(wall.bottomTextureName);
                }
            }
        }
    }

    function createDoor(sector:Sector) {
        var e = new ecs.Entity();
        e.add(new math.Transform());
        e.add(new core.Door(sector));
        e.get(math.Transform).position = sector.center;
        Main.context.engine.addEntity(e);
    }

    public function generateSectors() {
        Main.log("Generating sectors...");
        sectors = [];
        var v = data.vertices;

        for(room in data.rooms) {
            var sector = new Sector();

            for(w in room.walls) {
                var wdata = data.walls[w];
                var wall = new Wall(v[wdata.a], v[wdata.b], wdata.textureName, wdata.bottomTextureName);
                wall.height = wdata.height;
                wall.textureScale = wdata.textureScale;
                sector.walls.push(wall);
            }

            sector.floorTextureName = room.floorTextureName;
            sector.bottom = room.bottom;
            sector.top = room.top;
            sector.computeCenter();
            sector.reorderWalls();
            sectors.push(sector);
            {
                if(room.door) {
                    createDoor(sector);
                }
            }
            Main.log("Sector added.");
        }
    }
}
