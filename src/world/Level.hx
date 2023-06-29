package world;

class Level {
    public var sectors:Array<Sector> = [];
    public var skyTextureName:String;
    public var skyTexture:display.Framebuffer;

    public function new() {
    }

    public function load() {
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
        skyTextureName = "sky";
    }

    function addWall(sector:Sector, a:Float, b:Float, c:Float, d:Float, texName:String = null, bottomTexName:String = null) {
        var wall = new Wall([a* 200, b * 200], [c * 200, d * 200], texName, bottomTexName);
        wall.height = 1 + Std.random(3);
        sector.walls.push(wall);
        return wall;
    }

    public function update() {
        if(skyTexture == null) {
            skyTexture = Main.context.textureManager.get(skyTextureName);
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

    function createDoor(wall:Wall) {
        var e = new ecs.Entity();
        e.add(new math.Transform());
        e.add(new core.Door());
        e.get(math.Transform).position = wall.center;
        e.get(core.Door).wall = wall;
        Main.context.engine.addEntity(e);
    }
}
