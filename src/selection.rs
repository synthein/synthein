use mlua::prelude::{LuaFunction, LuaTable, LuaValue};
use mlua::{
    AnyUserData, ExternalError, IntoLua, Lua, ObjectLike, Result, UserData, UserDataFields,
    UserDataMethods,
};

use crate::world::shipparts::part::Location;
use crate::world::types::Controls;

// TODO: Replace f64 indexes with integers
pub struct Selection {
    pub world: AnyUserData,
    pub team: f64,
    building: Option<Building>,
    pub structure: Option<LuaTable>,
    pub structure_part_index: Option<f64>,
    building_on_structure_listeners: Vec<LuaFunction>,
    done_building_on_structure_listeners: Vec<LuaFunction>,
}

struct Point {
    x: f64,
    y: f64,
}

pub fn new(world: AnyUserData, team: f64) -> Selection {
    Selection {
        world: world,
        team: team,
        building: None,
        structure: None,
        structure_part_index: None,
        building_on_structure_listeners: Vec::new(),
        done_building_on_structure_listeners: Vec::new(),
    }
}

impl Selection {
    pub fn cursor_pressed(&mut self, cursor: Point, controls: Controls) -> Result<()> {
        let clicked_structure: Option<LuaTable> = self.world
            .get::<LuaFunction>("getObject")?.call::<Option<LuaTable>>((cursor.x, cursor.y))?
            .filter(|clicked_object_user_data| clicked_object_user_data.get("type").is_ok_and(|type| type == "structure");
        let clicked_part: Option<LuaTable> = clicked_structure.map(|clicked_structure| clicked_structure.get::<LuaFunction>("findPart")?.call((cursor.x, cursor.y)));

        if clicked_structure.is_some() && clicked_part.is_some() {
            let clicked_structure_team = clicked_structure.get()
            if self.building.is_some() {
                if 
            }
        } else {
            if controls.ship = 
        }
    }

    pub fn cursor_released(&mut self, cursor: Point, controls: Controls) -> Result<bool> {
    }
}

impl UserData for Selection {
    fn add_fields<F: UserDataFields<Self>>(fields: &mut F) {
        // fields.add_field_method_get("structure", |_, this| Ok(this.structure.clone()));
        // fields.add_field_method_get("mode", |_, this| Ok(this.mode));
    }

    fn add_methods<M: UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut(
            "cursorPressed",
            |_, this, (structure, part): (LuaTable, LuaTable)| {
                this.cursor_pressed(structure, part.clone())
            },
        );

        methods.add_method_mut(
            "cursorReleased",
            |_, this, (structure, part): (LuaTable, LuaTable)| {
                this.cursor_released(structure, part.clone())
            },
        );
    }
}

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    exports.set(
        "create",
        lua.create_function(|lua: &Lua, ()| new().into_lua(lua))?,
    )?;

    Ok(exports)
}
