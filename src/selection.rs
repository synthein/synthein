use std::collections::HashMap;

use mlua::prelude::{LuaError, LuaFunction, LuaResult, LuaTable, LuaValue};
use mlua::{FromLua, IntoLua, Lua, UserData, UserDataFields, UserDataMethods};

use crate::building::Building;
use crate::world::shipparts::part::Location;

// TODO: Replace f64 indexes with integers
pub struct Selection {
    world: LuaTable,
    team: f64,
    building: Option<Building>,
    pub structure: Option<LuaTable>,
    structure_part: Option<LuaTable>,
    building_on_structure_listeners: Vec<LuaFunction>,
    done_building_on_structure_listeners: Vec<LuaFunction>,
}

struct Point {
    x: f64,
    y: f64,
}

pub fn new(world: LuaTable, team: f64) -> Selection {
    Selection {
        world: world,
        team: team,
        building: None,
        structure: None,
        structure_part: None,
        building_on_structure_listeners: Vec::new(),
        done_building_on_structure_listeners: Vec::new(),
    }
}

impl Selection {
    pub fn cursor_pressed(
        &mut self,
        cursor: Point,
        control: HashMap<String, String>,
    ) -> LuaResult<()> {
        let clicked_structure: Option<LuaTable> = self
            .world
            .get::<LuaFunction>("getObject")?
            .call::<Option<LuaTable>>((self.world.clone(), cursor.x, cursor.y))?
            .filter(|clicked_object_user_data| {
                clicked_object_user_data
                    .get::<String>("type")
                    .is_ok_and(|object_type| object_type == "structure")
            });
        let clicked_part: Option<LuaTable> = clicked_structure
            .clone()
            .map(|clicked_structure| clicked_structure.get::<LuaFunction>("findPart"))
            .transpose()?
            .map(|find_part| find_part.call((clicked_structure.clone(), cursor.x, cursor.y)))
            .transpose()?;

        match (clicked_structure, clicked_part) {
            (Some(clicked_structure), Some(clicked_part)) => {
                let clicked_structure_team = clicked_structure.get::<f64>("team")?;
                match &mut self.building {
                    Some(ref mut building) => {
                        match control.get("ship").map(|control| control.as_str()) {
                            Some("build") => {
                                if clicked_structure_team == 0.0
                                    || clicked_structure_team == self.team
                                {
                                    match building.set_structure(&clicked_structure, &clicked_part)
                                    {
                                        Ok(()) => {
                                            self.structure = Some(clicked_structure);
                                            self.structure_part = Some(clicked_part);
                                        }
                                        Err(err) => {
                                            // TODO: Replace eprintln to proper log message
                                            eprintln!("Debug: {}", err);
                                            self.building = None;
                                        }
                                    }
                                }
                            }
                            Some("destroy") => {
                                self.structure = None;
                                self.structure_part = None;
                                self.building = None;
                            }
                            _ => {}
                        }
                    }
                    None => match control.get("ship").map(|control| control.as_str()) {
                        Some("build") => {}
                        Some("destroy") => {
                            let core_part =
                                clicked_structure.get::<Option<LuaTable>>("corePart")?;
                            if core_part.is_none()
                                || (core_part.is_some_and(|core_part| core_part != clicked_part)
                                    && clicked_structure_team == self.team)
                            {
                                clicked_structure
                                    .get::<LuaFunction>("disconnectPart")?
                                    .call::<()>((
                                        clicked_structure,
                                        clicked_part.get::<LuaValue>("location"),
                                    ));
                            };
                        }
                        _ => {}
                    },
                }
            }
            _ => match control.get("ship").map(|control| control.as_str()) {
                Some("build") => {}
                Some("destroy") => {
                    self.structure = None;
                    self.structure_part = None;
                    self.building = None;
                }
                _ => {}
            },
        };

        Ok(())
    }

    pub fn cursor_released(
        &mut self,
        cursor: Point,
        controls: HashMap<String, String>,
    ) -> LuaResult<()> {
        Ok(())
    }
}

impl UserData for Selection {
    fn add_fields<F: UserDataFields<Self>>(fields: &mut F) {
        fields.add_field_method_get("structure", |_, this| Ok(this.structure.clone()));
    }

    fn add_methods<M: UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut(
            "cursorpressed",
            |_, this, (cursor, controls): (Point, HashMap<String, String>)| {
                this.cursor_pressed(cursor, controls)
            },
        );

        methods.add_method_mut(
            "cursorreleased",
            |_, this, (cursor, controls): (Point, HashMap<String, String>)| {
                this.cursor_released(cursor, controls)
            },
        );

        methods.add_method_mut("whenBuildingOnStructure", |_, this, func: LuaFunction| {
            Ok(this.building_on_structure_listeners.push(func))
        });

        methods.add_method_mut(
            "whenDoneBuildingOnStructure",
            |_, this, func: LuaFunction| Ok(this.done_building_on_structure_listeners.push(func)),
        );

        methods.add_method("draw", |_, _, ()| Ok(()));
    }
}

impl FromLua for Point {
    fn from_lua(value: LuaValue, _: &Lua) -> LuaResult<Self> {
        match value {
            LuaValue::Table(table) => Ok(Point {
                x: table.get("x")?,
                y: table.get("y")?,
            }),
            _ => Err(LuaError::FromLuaConversionError {
                from: value.type_name(),
                to: "Point".to_string(),
                message: Some("expected table".to_string()),
            }),
        }
    }
}

pub fn lua_module(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;

    exports.set(
        "create",
        lua.create_function(|lua: &Lua, (world, team): (LuaTable, f64)| {
            new(world, team).into_lua(lua)
        })?,
    )?;

    Ok(exports)
}
