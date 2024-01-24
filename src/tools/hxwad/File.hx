package hxwad;

typedef Vertex = {
    var x:Int;
    var y:Int;
}

class Level {
    public var vertices:Array<Vertex>;

    public function new() {
        vertices = [];
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
