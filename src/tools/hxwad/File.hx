package hxwad;

typedef Vertex = {
    var x:Int;
    var y:Int;
}

typedef Linedef = {
    var begin:Int;
    var end:Int;
    var flags:Int;
    var type:Int;
    var tag:Int;
    var rightSidedef:Int;
    var leftSidedef:Int;
}

typedef Sidedef = {
    var x:Int;
    var y:Int;
    var upperTexture:String;
    var lowerTexture:String;
    var middleTexture:String;
    var sector:Int;
}

typedef Sector = {
    var floorHeight:Int;
    var ceilingHeight:Int;
    var floorTexture:String;
    var ceilingTexture:String;
    var lightLevel:Int;
    var special:Int;
    var tag:Int;
}

class Level {
    public var vertices:Array<Vertex> = [];
    public var linedefs:Array<Linedef> = [];
    public var sidedefs:Array<Sidedef> = [];
    public var sectors:Array<Sector> = [];

    public function new() {
    }
}

@:allow(hxwad.Reader)
class File {
    public var levels:Array<Level> = [];

    public function new() {
    }

    private function getLevel(index:Int):Level {

        var level = levels[index];

        if(level == null) {
            level = new Level();
            levels[index] = level;
        }

        return level;
    }
}
