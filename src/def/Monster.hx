package def;

typedef Animations = {
    var idle:String;
    var death:String;
}

typedef Effects = {
    var death:String;
}

typedef Sounds = {
    var death:String;
    var grunts:Array<String>;
    var gruntrate:Float;
}

typedef Monster = {
    var name:String;
    var life:Int;
    var scale:Float;
    var animations:Animations;
    var effects:Effects;
    var sounds:Sounds;
}
