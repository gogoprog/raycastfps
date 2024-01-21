package;

class WadConverter {

    static function showUsage() {
        Sys.println("Usage: wad-converter [WADFILE]");
    }

    static function main() {
        var args = Sys.args();
        var file = args[0];

        if(file == null) {
            showUsage();
            return;
        }

        var content = sys.io.File.getBytes(file);
        var reader = new hxwad.Reader(content);
        var wad = reader.process();
    }
}
