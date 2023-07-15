use mlua::prelude::LuaTable;
use mlua::{Lua, Result};

mod timer;
mod world;

use world::shipparts::modules::lua_interfaces::*;

#[mlua::lua_module]
fn syntheinrust(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    let shipparts = lua.create_table()?;

    let modules = lua.create_table()?;
    modules.set("gun", gun::lua_module(lua)?)?;
    modules.set("heal", heal::lua_module(lua)?)?;
    modules.set("missileLauncher", missile_launcher::lua_module(lua)?)?;
    shipparts.set("modules", modules)?;
    exports.set("shipparts", shipparts)?;

    exports.set("timer", timer::lua_module(lua)?)?;

    Ok(exports)
}
