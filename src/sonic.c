#include <lua5.1/lua.h>
#include <lua5.1/lauxlib.h>

static int hello(lua_State *L) {
	lua_pushstring(L, "hello");
	return 1;
}

static const luaL_Reg l [] = {
	{"hello", hello},
	{NULL, NULL},
};

const char name [] = "Sonic";
const int age = 31;

int luaopen_sonic(lua_State *L) {
	lua_newtable(L);
	lua_pushstring(L, "name");
	lua_pushstring(L, name);
	lua_settable(L, -3);
	lua_pushstring(L, "age");
	lua_pushnumber(L, age);
	lua_settable(L, -3);

	luaL_register(L, NULL, l);

	return 1;
}
