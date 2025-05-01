use mlua::prelude::LuaTable;
use mlua::{Lua, Result};

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    exports.set(
        "clamp",
        lua.create_function(|_lua: &Lua, (input, min, max): (f64, f64, f64)| {
            Ok(input.clamp(min, max))
        })?,
    )?;

    Ok(exports)
}
