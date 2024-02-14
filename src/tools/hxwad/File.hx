package hxwad;

typedef Vertex = {
    var x:Float;
    var y:Float;
}

typedef Linedef = {
    var beginVertex:Int;
    var endVertex:Int;
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

typedef Segment = {
    var beginVertex:Int;
    var endVertex:Int;
    var angle:Int;
    var linedef:Int;
    var direction:Int;
    var offset:Int;
}

typedef Subsector = {
    var segmentCount:Int;
    var firstSegment:Int;
}

typedef GlSegment = {
    var beginVertex:Int;
    var endVertex:Int;
    var linedef:Int;
    var side:Int;
    var partner:Int;
}

class Level {
    public var vertices:Array<Vertex> = [];
    public var linedefs:Array<Linedef> = [];
    public var sidedefs:Array<Sidedef> = [];
    public var sectors:Array<Sector> = [];
    public var segments:Array<Segment> = [];
    public var subsectors:Array<Subsector> = [];
    public var glVertices:Array<Vertex> = [];
    public var glSegments:Array<GlSegment> = [];
    public var glSubsectors:Array<Subsector> = [];

    public function new() {
    }

    public function getVertex(id:Int) {
        if((id >> 15) == 1) {
            id = id & 0x7fff;
            return glVertices[id];
        }

        return vertices[id];
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
