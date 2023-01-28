use mlua::prelude::{LuaNumber, LuaTable};
use mlua::{Lua, Result, ToLua, UserData, UserDataFields, UserDataMethods};

pub struct Timer {
    limit: f64,
    time: f64,
}

impl Timer {
    pub fn ready(&mut self, dt: f64) -> bool {
        self.time -= dt;

        if self.time <= 0.0 {
            self.time += self.limit;
            true
        } else {
            false
        }
    }
}

impl UserData for Timer {
    fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
        fields.add_field_method_get("limit", |_, this| Ok(this.limit));
        fields.add_field_method_get("time", |_, this| Ok(this.time));
    }

    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method_mut("ready", |_, this, dt: f64| Ok(Timer::ready(this, dt)));
    }
}

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    let metatable = lua.create_table()?;
    metatable.set(
        "__call",
        lua.create_function(|lua: &Lua, (_, limit): (LuaTable, LuaNumber)| {
            Timer { limit, time: limit }.to_lua(lua)
        })?,
    )?;
    exports.set_metatable(Some(metatable));

    Ok(exports)
}
