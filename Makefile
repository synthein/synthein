synthein_version = devel
love_version = 11.3

env = SYNTHEIN_VERSION=$(synthein_version) LOVE_VERSION=$(love_version)

# Building commands
love: c build/synthein-$(synthein_version).love

build/synthein-$(synthein_version).love: $(shell find ./src/ -type f)
	$(env) scripts/package-love.sh

appimage: love
	$(env) scripts/package-linux-appimage.sh

macos: love
	$(env) scripts/package-macos.sh

windows: love
	$(env) scripts/package-windows.sh

c: src/sonic.so
src/sonic.so: src/sonic.c
	cc src/sonic.c -pedantic -fPIC -shared $(shell pkg-config --libs lua5.1) -o src/sonic.so

# Maintenance commands
run: c
	love src

check:
	find src -name '*.lua' -not -path 'src/vendor/*' | xargs wc -l | sort -rg
	find src -name '*.lua' -exec luac -p {} + && echo "No problems found"

clean:
	rm -rf build/
	rm -f src/*.so

dep:
	scripts/dependency-graph.lua --dot src/main.lua | dot -T png | display

luacheck:
	find src -name '*.lua' -not -path 'src/vendor/*' -exec luacheck --no-unused-args {} +

test:
	love src --test

.PHONY: appimage c check clean dep love luacheck macos test windows
