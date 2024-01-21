package hxwad;

class Reader {
    var input:haxe.io.BytesInput;

    public function new(bytes:haxe.io.Bytes) {
        input = new haxe.io.BytesInput(bytes);
    }

    public function process() {
        var file = new File();
        file.type = input.readString(4);
        file.entries = input.readInt32();
        file.offset = input.readInt32();
        input.position = file.offset;

        for(i in 0...file.entries) {
            readEntry();
        }

        return file;
    }

    private function readEntry() {
        var data = input.readInt32();
        var size = input.readInt32();
        var name = input.readString(8);
        trace(name);
    }
}
