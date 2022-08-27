package display;

class Framebuffer {
    private var imageData:js.html.ImageData;
    public var data32:js.lib.Uint32Array;

    public var width:Int;
    public var height:Int;

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
        result.width = width;
        result.height = height;
        result.data32 = new js.lib.Uint32Array(result.imageData.data.buffer);
        return result;
    }

    static public function create(context:js.html.CanvasRenderingContext2D, width:Int, height:Int) {
        var result = new Framebuffer();
        result.imageData = context.getImageData(0, 0, width, height);
        result.width = width;
        result.height = height;
        result.data32 = new js.lib.Uint32Array(result.imageData.data.buffer);
        return result;
    }
}
