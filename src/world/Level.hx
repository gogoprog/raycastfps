package world;

typedef WallData = {
    var a:Int;
    var b:Int;
    var bottomTextureName:String;
    var textureName:String;
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
        data = {
            skyTextureName: "sky",
            vertices: [
                [0, 0],
                [1024, 0],
                [1024, 1024],
                [0, 1024],
                [-102, 1024],
                [-102, 0],
                [-1024, 1024],
                [-1024, 0]
            ],
            walls: [
            {
                a: 0,
                b: 1,
                bottomTextureName: "door",
                textureName: "wall",
                textureScale: [1, 1]
            },
            {
                a: 1,
                b: 2,
                bottomTextureName: "door",
                textureName: "wall",
                textureScale: [1, 1]
            },
            {
                a: 2,
                b: 3,
                bottomTextureName: "door",
                textureName: "wall",
                textureScale: [1, 1]
            },
            {
                a: 3,
                b: 0,
                bottomTextureName: "door",
                textureName: null,
                textureScale: [1, 1]
            },
            {
                a: 3,
                b: 4,
                bottomTextureName: "door",
                textureName: "wall",
                textureScale: [1, 1]
            },
            {
                a: 4,
                b: 5,
                bottomTextureName: "door",
                textureName: null,
                textureScale: [1, 1]
            },
            {
                a: 5,
                b: 0,
                bottomTextureName: "door",
                textureName: "wall",
                textureScale: [1, 1]
            },
            {
                a: 4,
                b: 6,
                bottomTextureName: "door",
                textureName: "wall",
                textureScale: [1, 1]
            },
            {
                a: 6,
                b: 7,
                bottomTextureName: "door",
                textureName: "wall",
                textureScale: [1, 1]
            },
            {
                a: 7,
                b: 5,
                bottomTextureName: "door",
                textureName: "wall",
                textureScale: [1, 1]
            }

            ],
            rooms: [
            {
                walls: [0, 1, 2, 3],
                floorTextureName: "floor",
                bottom: 0,
                top: 64
            },
            {
                walls: [3, 4, 5, 6],
                floorTextureName: "door",
                bottom: 10,
                top: 64,
                door: true
            },
            {
                walls: [7, 8, 9, 4],
                floorTextureName: "floor2",
                bottom: 0,
                top: 64
            }
            ],
            startPosition: [-512, 128]
        };
        generateSectors();
    }

    function addWall(sector:Sector, a:Float, b:Float, c:Float, d:Float, texName:String = null, bottomTexName:String = null) {
        var wall = new Wall([a* 200, b * 200], [c * 200, d * 200], texName, bottomTexName);
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
