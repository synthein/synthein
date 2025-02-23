use mlua::prelude::LuaTable;
use mlua::{Lua, Result};

mod draw_time_logger;
mod mathext;
mod timer;
mod vector;
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

    exports.set("mathext", mathext::lua_module(lua)?)?;
    exports.set("shipparts", shipparts)?;
    exports.set("timer", timer::lua_module(lua)?)?;
    exports.set("vector", vector::lua_module(lua)?)?;
    exports.set("draw_time_logger", draw_time_logger::lua_module(lua)?)?;

    Ok(exports)
}
