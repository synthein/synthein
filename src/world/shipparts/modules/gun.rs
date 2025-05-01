use crate::timer::Timer;
use crate::world::types::{Location, Module, ModuleInputs, WorldEvent};
use mlua::{Lua, UserData, UserDataMethods};

pub fn process(orders: Vec<String>) -> bool {
    orders.iter().any(|order| order == "shoot")
}

pub struct Gun {
    pub charged: bool,
    pub recharge_timer: Timer,
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
            let part_exists = match inputs.get_part.call::<bool>((location, [0, 1])) {
                Ok(part) => part,
                Err(error) => panic!("failed to look up part: {:?}", error),
            };
            if part_exists {
                None
            } else {
                self.charged = false;
                Some(WorldEvent {
                    event_type: "shot".to_string(),
                    location: Location {
                        x: 0.0,
                        y: 0.0,
                        angle: 1.0,
                        x_velocity: 0.0,
                        y_velocity: 0.0,
                        angle_velocity: 0.0,
                    },
                    data: 1.0,
                })
            }
        } else {
            None
        }
    }
}

impl UserData for Gun {
    fn add_methods<M: UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut(
            "update",
            |lua, this, (inputs, location): (ModuleInputs, Location)| {
                Ok(Gun::update(this, lua, inputs, location))
            },
        );
    }
}
