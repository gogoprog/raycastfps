package def;

@:generic
class Loader<T:{name:String}> {
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
}
