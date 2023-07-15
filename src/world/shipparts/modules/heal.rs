use crate::timer::Timer;
use crate::world::types::{Location, Module, ModuleInputs, WorldEvent};
use mlua::prelude::{LuaFunction, LuaTable};
use mlua::{Lua, RegistryKey, UserData, UserDataFields, UserDataMethods};

pub struct Heal {
    pub timer: Timer,
    pub hull: RegistryKey,
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
