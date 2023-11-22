package def;

typedef Animations = {
    var idle:String;
    var death:String;
}

typedef Monster = {
    var name:String;
    var life:Int;
    var animations:Animations;
    var effect:String;
}
