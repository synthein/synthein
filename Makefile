synthein_version = devel
love_version = 0.10.2

env = SYNTHEIN_VERSION=$(synthein_version) LOVE_VERSION=$(love_version)

# Building commands
love: build/synthein-$(synthein_version).love

build/synthein-$(synthein_version).love: src
	$(env) scripts/package-love.sh

appimage: love
	$(env) scripts/package-linux-appimage.sh

mac: love
	$(env) scripts/package-mac.sh

snap: love
	$(env) scripts/package-linux-snap.sh

windows: love
	$(env) scripts/package-windows.sh

# Maintenance commands
check:
	find src -name '*.lua' -exec luac -p {} +

clean:
	rm -rf build/

dep:
	scripts/dependency-graph.lua --dot src/main.lua | dot -T png | display

luacheck:
	find src -name '*.lua' -exec luacheck --std=luajit+love {} +

test:
	love src --test

.PHONY: appimage check clean dep love luacheck mac snap test windows
