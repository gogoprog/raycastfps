package def;

@:generic
class Loader<T: {name:String}> {
    private var prefix:String;
    private var prefixOnly:String;
    private var type:String;

    public function new(prefix) {
        var className = Type.getClassName(Type.getClass(this));
        type = className.split('_')[2].toLowerCase();
        this.prefixOnly = prefix;
        this.prefix = prefix + type + 's';
    }

    public function load(name, ondatacallback:T->Void) {
        var req = new haxe.Http('${prefix}/${name}.json');
        req.onData = function(datatxt) {
            var data:T = haxe.Json.parse(datatxt);
            ondatacallback(data);
        };
        req.request(false);
    }

    public function load2(name, ondatacallback:T->Void) {
        var req = new haxe.Http('${prefixOnly}/${name}.json');
        req.onData = function(datatxt) {
            var data:T = haxe.Json.parse(datatxt);
            ondatacallback(data);
        };
        req.request(false);
    }

    public function fill(result:Map<String, T>, callback) {
        var group = type + 's';
        var req = new haxe.Http('${prefixOnly}/${group}.json');
        req.onData = function(datatxt) {
            var data:Array<T> = haxe.Json.parse(datatxt);

            for(entry in data) {
                result[entry.name] = entry;
            }

            callback();
        };
        req.request(false);
    }

    public function fill2(result:Map<String, T>, filePaths:Array<String>, callback) {
        var group = type + 's';
        var count = filePaths.length;
        function localcallback() {
            count--;

            if(count == 0) {
                callback();
            }
        }

        for(filename in filePaths) {
            var req = new haxe.Http('${prefixOnly}/${group}/${filename}');
            var name = filename.substring(0, filename.length - 5);
            req.onData = function(datatxt) {
                var data:T = haxe.Json.parse(datatxt);

                result[name] = data;

                localcallback();
            };
            req.request(false);
        }
    }
}
