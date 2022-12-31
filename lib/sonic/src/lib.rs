use mlua::{Lua, Result, Table};
use mlua::prelude::{LuaResult, LuaString};

fn hello(lua: &Lua, _: ()) -> LuaResult<LuaString> {
    return lua.create_string("hello");
}

#[mlua::lua_module]
fn sonic(lua: &Lua) -> Result<Table> {
    let exports = lua.create_table()?;
    exports.set("name", "Sonic")?;
    exports.set("age", 31)?;
    exports.set("hello", lua.create_function(hello)?)?;
    Ok(exports)
}
