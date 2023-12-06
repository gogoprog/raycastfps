package def;

typedef ItemAnimations = {
    var idle:String;
    var death:String;
}

typedef Item = {
    var name:String;
    var scale:Float;
    var animations:ItemAnimations;
}
