package;

class TextureManager {
    var textures:Map<String, Framebuffer> = new Map();
    var textureCanvas:js.html.CanvasElement = cast js.Browser.document.createElement("canvas");
    var textureContext:js.html.CanvasRenderingContext2D;

    public function new() {
    }

    public function initialize() {
        textureContext = textureCanvas.getContext("2d");
        {
            textureCanvas.width = textureCanvas.height = 64;
            textureContext.fillRect(0, 0, 64, 64);
            textureContext.fillStyle = '#a22';
            textureContext.fillRect(2, 2, 62, 30);
            textureContext.fillRect(0, 34, 30, 29);
            textureContext.fillRect(32, 50, 32, 13);
            var textureBuffer = Framebuffer.create(textureContext, 64, 64);

            add("wall", textureBuffer);

            textureCanvas.width = textureCanvas.height = 64;
            textureContext.fillStyle = '#555';
            textureContext.fillRect(0, 0, 64, 64);
            textureContext.fillStyle = '#888';
            textureContext.fillRect(2, 2, 62, 30);
            textureContext.fillRect(0, 34, 30, 29);
            textureContext.fillRect(32, 50, 32, 13);
            textureContext.fillStyle = 'red';
            textureContext.fillText("FLOOR", 0, 12);
            var textureBuffer = Framebuffer.create(textureContext, 64, 64);

            add("floor", textureBuffer);
        }
        load("doomguy");
    }

    function add(name:String, texture:Framebuffer) {
        textures[name] = texture;
    }

    function load(name) {
        var tempBuffer = Framebuffer.create(textureContext, 64, 64); // temp

        add(name, tempBuffer);

        var img = new js.html.Image();
        img.src = '../data/${name}.png';
        img.onload = function() {
            textureCanvas.width = img.width;
            textureCanvas.height = img.height;
            textureContext.drawImage(img, 0, 0, img.width, img.height);
            var buffer = Framebuffer.create(textureContext, img.width, img.height);

            add(name, buffer);
        }
    }

    public function get(name:String) {
        return textures[name];
    }
}
