use mlua::prelude::{LuaFunction, LuaNumber, LuaResult, LuaTable, LuaValue};
use mlua::{Lua, Result, ToLua, UserData, UserDataFields, UserDataMethods};
use crate::world::types::{Location, Module, ModuleInputs, WorldEvent};
use crate::timer::{Timer};

struct MissileLauncher {
    charged: bool,
    rechargeTimer: Timer,
}

impl MissileLauncher {
    fn process(&self, orders: Vec<String>) -> bool {
        // TODO: functionalize
        let shoot: bool;
        for order in orders {
            if order == "shoot" {
                shoot = true;
            }
        }

        shoot
    }
}

impl Module for MissileLauncher {
    fn update(&mut self, inputs: ModuleInputs, location: Location) -> Option<WorldEvent> {
        if !self.charged {
            if self.rechargeTimer.ready(inputs.dt) {
                self.charged = true;
            }
            None
        } else {
            if inputs.controls.gun {
                // Check if there is a part one block in front of the gun.
                if !inputs.getPart(location, (0, 1)) {
                    self.charged = false;
                    ("missile", (0, 1, 1), 1)
                }
            }
        }
    }
}

impl UserData for MissileLauncher {
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
    exports.set_metatable(Some(metatable));

    metatable.set(
        "__call",
        lua.create_function(|lua| {
            MissileLauncher {
                charged: true,
                rechargeTimer: Timer {limit: 1, time: 1},
            }
            .to_lua(lua)
        })?,
    )?;

    Ok(exports)
}
