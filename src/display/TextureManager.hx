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
        {
            /*
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
                */
        }
        load("mariah");
        load("mariah2");
        load("doomguy");
        load("floor");
        load("wall");
        load("building");
        load("sky");
        loadSheet("grell");
        loadSheet("impact");
        loadSheet("explosion");

        for(i in 0...14) {
            load('shotgun/${i}');
        }
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

            trace('Loaded texture ${name}');
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
                    trace('Loaded texture ${name}-${index}');
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
