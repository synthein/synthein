use mlua::prelude::LuaTable;
use mlua::{Lua, Result};

mod timer;
mod world;

use world::shipparts::missile_launcher;

#[mlua::lua_module]
fn synthein(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    exports.set("timer", timer::lua_module(lua)?)?;
    exports.set("missileLauncher", missile_launcher::lua_module(lua)?)?;

    Ok(exports)
}
