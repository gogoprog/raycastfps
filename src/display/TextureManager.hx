package display;

class TextureManager {
    static var rootPath = Macro.getDataRootPath("textures");
    static var filePaths = Macro.getDataFilePaths("textures");
    static var sheetRootPath = Macro.getDataRootPath("sheets");
    static var sheetFilePaths = Macro.getDataFilePaths("sheets");
    var context:Context;
    var textures:Map<String, Framebuffer> = new Map();
    var textureCanvas:js.html.CanvasElement = cast js.Browser.document.createElement("canvas");
    var textureContext:js.html.CanvasRenderingContext2D;
    var loadCount = 0;

    public function new(context) {
        this.context = context;
    }

    public function initialize() {
        textureContext = textureCanvas.getContext("2d");

        for(file in filePaths) {
            load(file);
        }

        for(file in sheetFilePaths) {
            loadSheet(file);
        }
    }

    function add(name:String, texture:Framebuffer) {
        textures[name] = texture;
    }

    function load(filename) {
        loadCount++;
        var img = new js.html.Image();
        img.src = '${rootPath}/${filename}';
        img.onload = function() {
            textureCanvas.width = img.width;
            textureCanvas.height = img.height;
            textureContext.drawImage(img, 0, 0, img.width, img.height);
            var buffer = Framebuffer.create(textureContext, img.width, img.height);

            var name = filename.substring(0, filename.length - 4);

            add(name, buffer);

            App.log('Loaded texture ${name}');
            loadCount--;
        }
    }

    function loadSheet(filename:String) {
        var ext = filename.substring(filename.length - 4);

        if(ext != "json") { return; }

        var name = filename.substring(0, filename.length - 5);
        loadCount++;
        var img = new js.html.Image();
        img.src = '${sheetRootPath}/${name}.png';
        img.onload = function() {
            var loader = new def.Loader<def.Sheet>(Context.dataRoot);
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
                    App.log('Loaded texture sheet ${name}-${index}');
                }

                loadCount--;
            });
        };
    }

    public function get(name:String) {
        return textures[name];
    }

    public function getTextureNames() {
        return textures.keys();
    }

    public function isLoading() {
        return loadCount > 0;
    }
}
