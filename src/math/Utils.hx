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
}
