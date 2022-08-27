package world;

class Level {
    public var walls:Array<Wall> = [];
    public var floorTexture:display.Framebuffer;

    public function new() {
    }

    public function load() {
        // T
        addWall(0, 0, 9, 4);
        addWall(9, 4, 6, 4);
        addWall(6, 9, 6, 4);
        addWall(6, 9, 4, 9, "floor");
        addWall(4, 4, 4, 9);
        addWall(4, 4, -12, 4);
        addWall(-12, 3, -12, 4);
        addWall(-12, 3, 0, 3);
        addWall(0, 0, 0, 3);
        /* // Pillar */
        addWall(1, 1, 8, 1);
        addWall(8, 2, 8, 1);
        addWall(8, 2, 1, 2);
        addWall(1, 1, 1, 2);
        floorTexture = Main.context.textureManager.get("floor");
    }

    function addWall(a:Float, b:Float, c:Float, d:Float, texName:String = "wall") {
        var wall = new Wall([a* 200, b * 200], [c * 200, d * 200], Main.context.textureManager.get(texName));
        walls.push(wall);
    }
}
