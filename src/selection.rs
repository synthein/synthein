use mlua::prelude::{LuaFunction, LuaTable, LuaValue};
use mlua::{
    AnyUserData, ExternalError, IntoLua, Lua, ObjectLike, Result, UserData, UserDataFields,
    UserDataMethods,
};

use crate::world::shipparts::part::Location;

// TODO: Replace f64 indexes with integers
pub struct Selection {
    pub world: AnyUserData,
    pub team: f64,
    build: Option<Building>,
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
        build: None,
        structure: None,
        structure_part_index: None,
        building_on_structure_listeners: Vec::new(),
        done_building_on_structure_listeners: Vec::new(),
    }
}

impl Selection {
    pub fn cursor_pressed(&mut self, cursor: Point, controls: Controls) -> Result<()> {
        let structure: Option<LuaTable> = self.world.get::<LuaFunction>("getObject")?.call(cursor.x, cursor.y);
        let mut part: Option<LuaTable> = None;

        if structure.is_some_and(|structure| structure.get("type") == "structure") {
            
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
