package;

class Level {
    public var walls:Array<Dynamic> = [];
    public var floorTexture:String = "floor";

    public function new() {
        // T
        addWall(0, 0, 9, 4);
        addWall(9, 4, 6, 4);
        addWall(6, 9, 6, 4);
        addWall(6, 9, 4, 9);
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
    }

    function addWall(a:Float, b:Float, c:Float, d:Float) {
        var n = walls.length;
        var len = Math.sqrt((c-a)*(c-a)+(d-b)*(d-b));
        walls[n] = [[a* 100, b * 100], [c * 100, d * 100], len * 100];
    }
}
