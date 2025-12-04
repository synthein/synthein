use mlua::prelude::{LuaError, LuaFunction, LuaTable};
use mlua::{AnyUserData, IntoLua, Lua, ObjectLike, UserData, UserDataFields, UserDataMethods, ExternalError};
use std::error::Error;

pub enum BuildingState {
    GettingAnnexee,
    GettingAnnexeeSide,
    GettingStructure,
    GettingStructureSide,
    Done,
}

pub struct Building {
    pub structure: Option<LuaTable>,
    structure_part: Option<LuaTable>,
    pub structure_part_index: Option<f64>,
    structure_vector: Option<LuaTable>,
    pub annexee: Option<LuaTable>,
    annexee_part: Option<LuaTable>,
    pub annexee_part_index: Option<f64>,
    annexee_base_vector: Option<LuaTable>,
    pub body: Option<LuaTable>,
    pub mode: BuildingState,
}

pub fn new() -> Building {
    Building {
        structure: None,
        structure_part: None,
        structure_part_index: None,
        structure_vector: None,
        annexee: None,
        annexee_part: None,
        annexee_part_index: None,
        annexee_base_vector: None,
        body: None,
        mode: BuildingState::GettingAnnexee,
    }
}

impl Building {
    pub fn set_annexee(&mut self, structure: LuaTable, part: LuaTable) -> Result<(), LuaError> {
        self.annexee_base_vector = part.clone().get("location")?;
        self.body = part
            .clone()
            .get::<LuaTable>("modules")?
            .get::<LuaTable>("hull")?
            .get::<LuaTable>("fixture")?
            .get::<LuaFunction>("getBody")?
            .call(())?;

        self.annexee = Some(structure);
        self.annexee_part = Some(part);

        self.mode = BuildingState::GettingAnnexeeSide;

        Ok(())
    }

    pub fn set_structure(&mut self, structure: LuaTable, part: LuaTable) -> Result<bool, LuaError> {
        if self.annexee == Some(structure.clone()) {
            return Ok(true);
        }

        self.structure_vector = part.clone().get("location")?;
        self.structure = Some(structure);
        self.structure_part = Some(part);
        self.mode = BuildingState::GettingStructureSide;

        Ok(false)
    }

    pub fn set_side(&mut self, part_side: f64) -> Result<(), LuaError> {
        match self.mode {
            BuildingState::GettingAnnexeeSide => {
                self.annexee_base_vector
                    .ok_or(Err("???".into_lua_err()))?
                    .set("3", part_side)?;
                self.mode = BuildingState::GettingStructure;
                Ok(())
            }
            BuildingState::GettingStructureSide => {
                self.structure_vector
                    .ok_or(Err("???".into_lua_err()))?
                    .set("3", part_side)?;

                if self.annexee.is_some()
                    && self.annexee_base_vector.is_some()
                    && self.structure.is_some()
                    && self.structure_vector.is_some()
                {
                    self.structure
                        .ok_or(Err("???".into_lua_err()))?
                        .get::<LuaFunction>("annex")?
                        .call((
                            self.annexee,
                            self.annexee_base_vector,
                            self.structure_vector,
                        ))?
                }

                self.mode = BuildingState::Done;
                Ok(())
            }
            _ => Err("It is not valid to set a side when we're not looking for a side".into_lua_err()),
        }
    }
}

impl UserData for Building {
    fn add_fields<F: UserDataFields<Self>>(fields: &mut F) {
        fields.add_field_method_get("structure", |_, this| Ok(this.structure.clone()));
    }

    fn add_methods<M: UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut(
            "setAnnexee",
            |_, this, (structure, part): (LuaTable, LuaTable)| {
                this.set_annexee(structure, part.clone())
            },
        );

        methods.add_method_mut(
            "setStructure",
            |_, this, (structure, part): (LuaTable, LuaTable)| {
                this.set_structure(structure, part.clone())
            },
        );

        methods.add_method_mut("setSide", |_, this, (side): (f64)| {
            this.set_side(side)
        });
    }
}

pub fn lua_module(lua: &Lua) -> Result<LuaTable, LuaError> {
    let exports = lua.create_table()?;

    exports.set(
        "create",
        lua.create_function(|lua: &Lua, ()| new().into_lua(lua))?,
    )?;

    Ok(exports)
}
