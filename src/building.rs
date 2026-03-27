use mlua::prelude::{LuaFunction, LuaTable, LuaValue};
use mlua::{
    AnyUserData, ExternalError, IntoLua, Lua, ObjectLike, Result, UserData, UserDataFields,
    UserDataMethods,
};

use crate::world::shipparts::part::Location;

#[derive(Copy, Clone)]
pub enum BuildingState {
    GettingAnnexee,
    GettingAnnexeeSide,
    GettingStructure,
    GettingStructureSide,
    Done,
}

impl IntoLua for BuildingState {
    fn into_lua(self, lua: &Lua) -> Result<LuaValue> {
        match self {
            Self::GettingAnnexee => 1,
            Self::GettingAnnexeeSide => 2,
            Self::GettingStructure => 3,
            Self::GettingStructureSide => 4,
            Self::Done => 5,
        }
        .into_lua(lua)
    }
}

pub struct Building {
    pub structure: Option<LuaTable>,
    structure_part: Option<LuaTable>,
    pub structure_part_index: Option<f64>,
    structure_vector: Option<Location>,
    pub annexee: Option<LuaTable>,
    annexee_part: Option<LuaTable>,
    pub annexee_part_index: Option<f64>,
    annexee_base_vector: Option<Location>,
    pub body: Option<AnyUserData>,
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
    pub fn set_annexee(&mut self, structure: LuaTable, part: LuaTable) -> Result<()> {
        self.annexee_base_vector = Some(part.clone().get::<Location>("location")?);

        let fixture = part
            .clone()
            .get::<LuaTable>("modules")?
            .get::<LuaTable>("hull")?
            .get::<AnyUserData>("fixture")?;

        self.body = fixture.get::<LuaFunction>("getBody")?.call(fixture)?;

        self.annexee = Some(structure);
        self.annexee_part = Some(part);

        self.mode = BuildingState::GettingAnnexeeSide;

        Ok(())
    }

    pub fn set_structure(&mut self, structure: LuaTable, part: LuaTable) -> Result<bool> {
        if self.annexee == Some(structure.clone()) {
            return Ok(true);
        }

        self.structure_vector = Some(part.clone().get::<Location>("location")?);
        self.structure = Some(structure);
        self.structure_part = Some(part);
        self.mode = BuildingState::GettingStructureSide;

        Ok(false)
    }

    pub fn set_side(&mut self, part_side: f64) -> Result<()> {
        match self.mode {
            BuildingState::GettingAnnexeeSide => {
                self.annexee_base_vector.as_mut().unwrap().orientation = part_side.floor() as i64;
                self.mode = BuildingState::GettingStructure;
                Ok(())
            }
            BuildingState::GettingStructureSide => {
                self.structure_vector.as_mut().unwrap().orientation = part_side.floor() as i64;

                if self.annexee.is_some()
                    && self.annexee_base_vector.is_some()
                    && self.structure.is_some()
                    && self.structure_vector.is_some()
                {
                    self.structure
                        .clone()
                        .ok_or("???".into_lua_err())?
                        .get::<LuaFunction>("annex")?
                        .call((
                            self.structure.clone(),
                            self.annexee.clone(),
                            self.annexee_base_vector.clone(),
                            self.structure_vector.clone(),
                        ))?
                }

                self.mode = BuildingState::Done;
                Ok(())
            }
            _ => Err(
                "It is not valid to set a side when we're not looking for a side".into_lua_err(),
            ),
        }
    }
}

impl UserData for Building {
    fn add_fields<F: UserDataFields<Self>>(fields: &mut F) {
        fields.add_field_method_get("structure", |_, this| Ok(this.structure.clone()));
        fields.add_field_method_get("mode", |_, this| Ok(this.mode));
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

        methods.add_method_mut("setSide", |_, this, side: f64| this.set_side(side));
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
