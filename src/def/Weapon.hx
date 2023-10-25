package def;

typedef Weapon = {
    var name:String;
    var rate:Float;
    var type:String;
    var fireCount:Int;
    var animations:{
        idle:String,
        fire:String
    };
}
