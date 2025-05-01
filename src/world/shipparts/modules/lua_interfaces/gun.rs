use crate::timer::Timer;
use crate::world::shipparts::modules::gun::{process, Gun};
use mlua::prelude::{LuaTable, LuaValue};
use mlua::{IntoLua, Lua, Result};

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
            Gun {
                charged: true,
                recharge_timer: Timer {
                    limit: 0.5,
                    time: 0.5,
                },
            }
            .into_lua(lua)
        })?,
    )?;
    exports.set_metatable(Some(metatable));

    Ok(exports)
}
