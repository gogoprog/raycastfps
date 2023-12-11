package core;

import sound.AudioManager;

@:allow(core.AudioSourceSystem)
class AudioSource {
    public var soundName:String;
    public var loop:Bool = false;

    public function new() {
    }

    public function force(name) {
        soundName = name;
        internalSoundName = null;
    }

    private var internalSoundName:String;
    private var sound:Sound;
}
