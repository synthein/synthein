use crate::timer::Timer;
use crate::world::shipparts::modules::heal::Heal;
use mlua::prelude::LuaTable;
use mlua::{IntoLua, Lua, Result};

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    let metatable = lua.create_table()?;
    metatable.set(
        "__call",
        lua.create_function(|lua, (_, hull): (LuaTable, LuaTable)| {
            Heal {
                timer: Timer {
                    limit: 10.0,
                    time: 10.0,
                },
                hull: lua.create_registry_value(hull)?,
            }
            .into_lua(lua)
        })?,
    )?;
    exports.set_metatable(Some(metatable));

    Ok(exports)
}
