use crate::timer::Timer;
use crate::world::shipparts::modules::missile_launcher::{process, MissileLauncher};
use mlua::prelude::{LuaTable, LuaValue};
use mlua::{Lua, Result, ToLua};

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;
    exports.set(
        "process",
        lua.create_function(|_, orders: Vec<String>| Ok(process(orders)))?,
    )?;

    let metatable = lua.create_table()?;
    metatable.set(
        "__call",
        lua.create_function(|lua, _: LuaValue| {
            MissileLauncher {
                charged: true,
                recharge_timer: Timer {
                    limit: 1.0,
                    time: 1.0,
                },
            }
            .to_lua(lua)
        })?,
    )?;
    exports.set_metatable(Some(metatable));

    Ok(exports)
}
