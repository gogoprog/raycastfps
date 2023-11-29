package sound;

class Sound {

    public var audio:js.html.Audio;
    public var source:js.html.audio.MediaElementAudioSourceNode;
    public var panner:js.html.audio.PannerNode;

    public function new(audioContext:js.html.audio.AudioContext, src) {
        audio = new js.html.Audio(src);
        source = audioContext.createMediaElementSource(audio);
        panner = audioContext.createPanner();
        source.connect(panner);
        panner.connect(audioContext.destination);
    }

    public function play() {
        audio.currentTime = 0;
        audio.play();
    }
}

class SoundInstances {
    static var rootPath = Macro.getDataRootPath("sounds");

    var instances:Array<Sound> = [];
    var index = 0;

    public function new(audioContext, filename) {
        var src = '${rootPath}/${filename}';

        for(i in 0...6) {
            var instance = new Sound(audioContext, src);
            instances.push(instance);
        }
    }

    public function play() {
        var instance = instances[index];
        instance.play();
        index++;
        index %= instances.length;
    }
}

class AudioManager {
    static var filePaths = Macro.getDataFilePaths("sounds");

    var sounds:Map<String, SoundInstances> = new Map();

    var audioContext:js.html.audio.AudioContext;

    public function new() {
    }

    public function initialize() {
        audioContext = new js.html.audio.AudioContext();

        for(file in filePaths) {
            var name = file.substring(0, file.length - 4);
            sounds[name] = new SoundInstances(audioContext, file);
            App.log('Loaded sound ${name}');
        }
    }

    public function play(name) {
        audioContext.resume();
        sounds[name].play();
    }
}
