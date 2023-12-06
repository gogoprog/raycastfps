package world;

class Level {
    public var data:def.Level;
    public var context:Context;

    public var sectors:Array<Sector> = [];
    public var skyTexture:display.Framebuffer;

    public function new(context) {
        this.context = context;
        data = {
            skyTextureName: "",
            vertices:[],
            walls:[],
            rooms:[],
            objects:[]
        }
    }

    public function old() {
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
                bottom: 0,
                top: 64,
                door: true
            },
            {
                walls: [7, 8, 9, 5],
                floorTextureName: "floor2",
                bottom: 0,
                top: 64
            }
            ],
            objects:[
            {
                type: "start",
                name: "player",
                position:[-512, 128]

            },
            {
                type: "monster",
                name: "grell",
                position:[100, 500]

            }

            ]
        };
    }

    public function load(data:def.Level) {
        this.data = data;
    }

    function addWall(sector:Sector, a:Float, b:Float, c:Float, d:Float, texName:String = null, bottomTexName:String = null) {
        var wall = new Wall([a* 200, b * 200], [c * 200, d * 200], texName, bottomTexName);
        sector.walls.push(wall);
        return wall;
    }

    public function update() {
        if(skyTexture == null) {
            skyTexture = context.textureManager.get(data.skyTextureName);
        }

        for(sector in sectors) {
            if(sector.floorTexture == null && sector.floorTextureName != null) {
                sector.floorTexture = context.textureManager.get(sector.floorTextureName);
            }

            for(wall in sector.walls) {
                if(wall.texture == null && wall.textureName != null) {
                    wall.texture = context.textureManager.get(wall.textureName);
                }

                if(wall.bottomTexture == null && wall.bottomTextureName != null) {
                    wall.bottomTexture = context.textureManager.get(wall.bottomTextureName);
                }
            }
        }
    }

    function createDoor(sector:Sector) {
        var e = new ecs.Entity();

        e.add(new math.Transform());

        var door = new core.Door(sector);

        e.add(door);

        e.get(math.Transform).position = sector.center;
        door.open = false;
        sector.bottom =sector.initialTop;
        context.engine.addEntity(e);
    }

    public function placeObjects(skip_start = false) {
        var engine = context.engine;
        var es = engine.getMatchingEntities(core.Object);

        for(e in es) {
            if(!skip_start || e.get(core.Player) == null) {
                engine.removeEntity(e);
            }
        }

        for(obj in data.objects) {
            switch(obj.type) {
                case "monster":
                    var e = Factory.createMonster(obj.name, obj.position);
                    engine.addEntity(e);

                case "item":
                    var e = Factory.createItem(obj.name, obj.position);
                    engine.addEntity(e);

                case "start":
                    if(!skip_start) {
                        var e = Factory.createPlayer(obj.position);
                        engine.addEntity(e);
                        context.playerEntity = e;
                    }
            }
        }
    }

    public function generateSectors() {
        App.log("Generating sectors...");
        var engine = context.engine;
        var es = engine.getMatchingEntities(core.Door);

        for(e in es) {
            engine.removeEntity(e);
        }

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
            App.log("Sector added.");
        }
    }

    public function restart() {
        generateSectors();
        placeObjects();
    }

    public function findSector(test_position:math.Point):Sector {
        for(s in sectors) {
            if(s.contains(test_position)) {
                return s;
            }
        }

        return null;
    }
}
