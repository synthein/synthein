use crate::timer::Timer;
use crate::world::types::{Location, Module, ModuleInputs, WorldEvent};
use mlua::prelude::{LuaFunction, LuaTable};
use mlua::{Lua, RegistryKey, Result, ToLua, UserData, UserDataFields, UserDataMethods};

struct Heal {
    timer: Timer,
    hull: RegistryKey,
}

impl Module for Heal {
    fn update(&mut self, lua: &Lua, inputs: ModuleInputs, _: Location) -> Option<WorldEvent> {
        if self.timer.ready(inputs.dt) {
            let hull: LuaTable = lua.registry_value(&self.hull).unwrap();
            let user_data: LuaTable = hull.get("userData").unwrap();
            let repair: LuaFunction = user_data.get("repair").unwrap();
            repair.call::<i32, ()>(1).unwrap();
        }

        None
    }
}

impl UserData for Heal {
    fn add_fields<'lua, F: UserDataFields<'lua, Heal>>(fields: &mut F) {
        fields.add_field_method_get("timer", |_, this| Ok(this.timer));
        fields.add_field_method_set("timer", |_, this, timer| {
            this.timer = timer;
            Ok(())
        });
    }

    fn add_methods<'lua, M: UserDataMethods<'lua, Heal>>(methods: &mut M) {
        methods.add_method_mut("update", |lua, this, (inputs, location)| {
            Ok(Heal::update(this, lua, inputs, location))
        });
    }
}

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
            .to_lua(lua)
        })?,
    )?;
    exports.set_metatable(Some(metatable));

    Ok(exports)
}
