compile:
	haxe build.hxml
	tools/generate-manifest.sh data

.PHONY: build retail
