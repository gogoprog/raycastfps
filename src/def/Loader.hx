package def;

class Loader<T> {
    public function new() {
    }

    public function load(url, ondatacallback:T->Void) {
        var req = new haxe.Http(url);
        req.onData = function(datatxt) {
            var data:T = haxe.Json.parse(datatxt);
            ondatacallback(data);
        };
        req.request(false);
    }
}
