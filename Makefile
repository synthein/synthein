synthein_version = devel
love_version = 11.1

env = SYNTHEIN_VERSION=$(synthein_version) LOVE_VERSION=$(love_version)

# Building commands
love: build/synthein-$(synthein_version).love

build/synthein-$(synthein_version).love: $(shell find ./src/ -type f)
	$(env) scripts/package-love.sh

appimage: love
	$(env) scripts/package-linux-appimage.sh

macos: love
	$(env) scripts/package-macos.sh

snap: love
	$(env) scripts/package-linux-snap.sh

windows: love
	$(env) scripts/package-windows.sh

# Maintenance commands
check:
	find src -name '*.lua' -exec luac -p {} +

clean:
	-rm -rf build/
	-cd package/snapcraft; snapcraft clean || true

dep:
	scripts/dependency-graph.lua --dot src/main.lua | dot -T png | display

luacheck:
	find src -name '*.lua' -not -path 'src/vendor/*' -exec luacheck {} +

test:
	love src --test

.PHONY: appimage check clean dep love luacheck macos snap test windows
