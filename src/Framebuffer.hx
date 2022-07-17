package;

class Framebuffer {
    private var imageData:js.html.ImageData;

    private function new() {
    }

    public var data(get, never):js.lib.Uint8ClampedArray;
    inline function get_data() return imageData.data;

    public function getImageData():js.html.ImageData {
        return imageData;
    }

    static public function createEmpty(context:js.html.CanvasRenderingContext2D, width:Int, height:Int) {
        var result = new Framebuffer();
        result.imageData = context.createImageData(width, height);
        return result;
    }

    static public function create(context, width, height) {
        var result = new Framebuffer();
        result.imageData = context.getImageData(0, 0, width, height);
        return result;
    }
}
