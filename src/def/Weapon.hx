package def;

typedef Weapon = {
    var name:String;
    var rate:Float;
    var type:String;
    var fireCount:Int;
    var fireGap:Float;
    var animations:{
        idle:String,
        fire:String,
        projectile:String
    };
    var sounds:{
        fire:String
    };
    var effects:{
        impact:String
    };
    var projectile: {
        speed:Float,
        lifetime:Float,
        scale:Float
    };
}
