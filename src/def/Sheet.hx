package def;

typedef Frame = {
    var x:Int;
    var y:Int;
    var w:Int;
    var h:Int;
}

typedef FrameEntry = {
    var frame:Frame;
}

typedef Sheet = {
    var name:String;
    var frames:Array<FrameEntry>;
}
