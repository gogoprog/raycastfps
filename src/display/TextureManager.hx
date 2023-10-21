package display;

class TextureManager {
    var textures:Map<String, Framebuffer> = new Map();
    var textureCanvas:js.html.CanvasElement = cast js.Browser.document.createElement("canvas");
    var textureContext:js.html.CanvasRenderingContext2D;
    var loadCount = 0;

    public function new() {
    }

    public function initialize() {
        textureContext = textureCanvas.getContext("2d");
        load("console");
        load("doomguy");
        load("floor");
        load("floor2");
        load("wall");
        load("sky");
        load("door");
        loadSheet("grell");
        loadSheet("impact");

        for(i in 0...14) {
            load('shotgun/${i}');
        }

        load("font");
        load("font2");
    }

    function add(name:String, texture:Framebuffer) {
        textures[name] = texture;
    }

    function load(name) {
        loadCount++;
        var img = new js.html.Image();
        img.src = '../data/textures/${name}.png';
        img.onload = function() {
            textureCanvas.width = img.width;
            textureCanvas.height = img.height;
            textureContext.drawImage(img, 0, 0, img.width, img.height);
            var buffer = Framebuffer.create(textureContext, img.width, img.height);

            add(name, buffer);

            Main.log('Loaded texture ${name}');
            loadCount--;
        }
    }

    function loadSheet(name) {
        loadCount++;
        var img = new js.html.Image();
        img.src = '../data/textures/${name}.png';
        img.onload = function() {
            var loader = new def.Loader<def.Sheet>(Main.context.dataRoot);
            loader.load(name, function(data) {
                var index = 0;

                for(frameEntry in data.frames) {
                    var frame = frameEntry.frame;
                    textureCanvas.width = frame.w;
                    textureCanvas.height = frame.h;
                    textureContext.drawImage(img, frame.x, frame.y, frame.w, frame.h, 0, 0, frame.w, frame.h);
                    var buffer = Framebuffer.create(textureContext, frame.w, frame.h);

                    add('${name}-${index}', buffer);

                    index++;
                    Main.log('Loaded texture ${name}-${index}');
                }

                loadCount--;
            });
        };
    }

    public function get(name:String) {
        return textures[name];
    }
    public function isLoading() {
        return loadCount > 0;
    }
}
