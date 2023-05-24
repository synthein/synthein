use crate::timer::Timer;
use crate::world::types::{Location, Module, ModuleInputs, WorldEvent};
use mlua::prelude::{LuaTable, LuaValue};
use mlua::{Lua, Result, ToLua, UserData, UserDataMethods};

fn process(orders: Vec<String>) -> bool {
    orders.iter().any(|order| order == "shoot")
}

struct Gun {
    charged: bool,
    recharge_timer: Timer,
}

impl Module for Gun {
    fn update(&mut self, _: &Lua, inputs: ModuleInputs, location: Location) -> Option<WorldEvent> {
        if !self.charged {
            if self.recharge_timer.ready(inputs.dt) {
                self.charged = true;
            }
            None
        } else if inputs.controls.gun {
            // Check if there is a part one block in front of the gun.
            let part_exists = match inputs.get_part.call::<_, bool>((location, [0, 1])) {
                Ok(part) => part,
                Err(error) => panic!("failed to look up part: {:?}", error),
            };
            if part_exists {
                None
            } else {
                self.charged = false;
                Some(WorldEvent {
                    event_type: "shot".to_string(),
                    location: [0.0, 0.0, 1.0],
                    data: 1.0,
                })
            }
        } else {
            None
        }
    }
}

impl UserData for Gun {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method_mut(
            "update",
            |lua, this, (inputs, location): (ModuleInputs, Location)| {
                Ok(Gun::update(this, lua, inputs, location))
            },
        );
    }
}

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
            .to_lua(lua)
        })?,
    )?;
    exports.set_metatable(Some(metatable));

    Ok(exports)
}
