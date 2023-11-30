package core;

import sound.AudioManager;

@:allow(core.AudioSourceSystem)
class AudioSource {
    public var soundName:String;

    public function new() {
    }

    private var internalSoundName:String;
    private var sound:Sound;
}
