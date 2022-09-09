package math;

class Utils {

    public static function fixAngle(angle:Float) {
        while(angle > Math.PI) {
            angle -= 2 * Math.PI;
        }

        while(angle < -Math.PI) {
            angle += 2 * Math.PI;
        }

        return angle;
    }

    static public function segmentToSegmentIntersection(from1:Point, to1:Point, from2:Point, to2:Point) {
        var dX = to1.x - from1.x;
        var dY = to1.y - from1.y;
        var determinant = dX * (to2.y - from2.y) - (to2.x - from2.x) * dY;
        /* if(determinant == 0) { return null; } */
        var lambda = ((to2.y - from2.y) * (to2.x - from1.x) + (from2.x - to2.x) * (to2.y - from1.y)) / determinant;
        var gamma = ((from1.y - to1.y) * (to2.x - from1.x) + dX * (to2.y - from1.y)) / determinant;

        if(lambda<0 || !(0 <= gamma && gamma <= 1)) { return null; }

        return [lambda, gamma];
    }

    static public function getSegmentPointDistance(v:Point, w:Point, p:Point) {
        var l2 = (w - v).getSquareLength();
        var t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
        t = Math.max(0, Math.min(1, t));
        var tmp:Point = [v.x + t * (w.x - v.x), v.y + t*(w.y-v.y)];
        return (p - tmp).getLength();
    }
}
