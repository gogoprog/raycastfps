package audio;

class Manager {
    var sounds:Map<String, js.html.Audio> = new Map();

    public function new() {
    }

    public function initialize() {
        load("shotgun-fire");
        load("shotgun-reload");
    }

    public function load(name) {
        var src = '../data/sounds/${name}.wav';
        sounds[name] = new js.html.Audio(src);
    }

    public function play(name) {
        sounds[name].currentTime = 0;
        sounds[name].play();
    }
}
