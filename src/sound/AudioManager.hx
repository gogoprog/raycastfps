package sound;

class Sound {
    static var rootPath = Macro.getDataRootPath("sounds");

    var instances:Array<js.html.Audio> = [];
    var index = 0;

    public function new(filename) {
        var src = '${rootPath}/${filename}';

        for(i in 0...4) {
            var instance = new js.html.Audio(src);
            instances.push(instance);
        }
    }

    public function play() {
        var instance = instances[index];
        instance.currentTime = 0;
        instance.play();
        index++;
        index %= instances.length;
    }
}

class AudioManager {
    static var filePaths = Macro.getDataFilePaths("sounds");

    var sounds:Map<String, Sound> = new Map();

    public function new() {
    }

    public function initialize() {
        for(file in filePaths) {
            var name = file.substring(0, file.length - 4);
            sounds[name] = new Sound(file);
        }
    }

    public function play(name) {
        sounds[name].play();
    }
}
