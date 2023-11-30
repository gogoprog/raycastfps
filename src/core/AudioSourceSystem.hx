package core;

import math.Transform;

class AudioSourceSystem extends ecs.System {

    public function new() {
        super();
        addComponentClass(AudioSource);
        addComponentClass(Transform);
    }

    override public function updateSingle(dt:Float, e:ecs.Entity) {
        var listenerTransform = context.cameraTransform;
        var transform = e.get(Transform);
        var audioSource = e.get(AudioSource);

        if(audioSource.soundName != audioSource.internalSoundName) {
            audioSource.sound = context.audioManager.play(audioSource.soundName);
            audioSource.internalSoundName = audioSource.soundName;
        }

        if(audioSource.sound != null) {
            var sound = audioSource.sound;
            var audio = audioSource.sound.audio;
            var delta = transform.position - listenerTransform.position;
            delta = math.Point.getRotated(delta, -listenerTransform.angle - Math.PI/2);
            var factor = 0.01;
            sound.panner.positionX.value = delta.x * factor;
            sound.panner.positionZ.value = delta.y * factor;

            if(audio.currentTime >= audio.duration) {
                audioSource.internalSoundName = null;
                audioSource.soundName = null;
                audioSource.sound = null;
            }
        }
    }
}
