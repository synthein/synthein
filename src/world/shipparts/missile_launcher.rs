use crate::timer::Timer;
use crate::world::types::{Location, Module, ModuleInputs, WorldEvent};
use mlua::prelude::{LuaTable, LuaValue};
use mlua::{Lua, Nil, Result, ToLua, UserData, UserDataMethods};

struct MissileLauncher {
    charged: bool,
    recharge_timer: Timer,
}

impl MissileLauncher {
    fn process(&self, orders: Vec<String>) -> bool {
        orders.iter().any(|order| order == "shoot")
    }
}

impl Module for MissileLauncher {
    fn update(&mut self, inputs: ModuleInputs, location: Location) -> Option<WorldEvent> {
        if !self.charged {
            if self.recharge_timer.ready(inputs.dt) {
                self.charged = true;
            }
            None
        } else {
            if inputs.controls.gun {
                // Check if there is a part one block in front of the gun.
                let part = match inputs.get_part.call::<_, LuaValue>((location, [0, 1])) {
                    Ok(part) => part,
                    Err(error) => panic!("failed to look up part: {:?}", error),
                };
                if part == Nil {
                    self.charged = false;
                    Some(WorldEvent {
                        event_type: "missile".to_string(),
                        location: [0.0, 1.0, 1.0],
                        data: 1.0,
                    })
                } else {
                    None
                }
            } else {
                None
            }
        }
    }
}

impl UserData for MissileLauncher {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("ready", |_, this, orders: Vec<String>| {
            Ok(MissileLauncher::process(this, orders))
        });
        methods.add_method_mut(
            "update",
            |_, this, (inputs, location): (ModuleInputs, Location)| {
                Ok(MissileLauncher::update(this, inputs, location))
            },
        );
    }
}

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

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
