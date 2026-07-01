use std::error::Error;

use mlua::prelude::{LuaFunction, LuaResult, LuaTable};
use mlua::{AnyUserData, ExternalError, ObjectLike};

use crate::world::shipparts::part::Location;

#[derive(Copy, Clone)]
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
    pub fn set_annexee(&mut self, structure: LuaTable, part: LuaTable) -> LuaResult<()> {
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

    pub fn set_structure(
        &mut self,
        structure: &LuaTable,
        part: &LuaTable,
    ) -> Result<(), Box<dyn Error>> {
        if self.annexee == Some(structure.clone()) {
            return Err("host structure and annexee are the same structure".into());
        }

        self.structure_vector = Some(part.clone().get::<Location>("location")?);
        self.structure = Some(structure.clone());
        self.structure_part = Some(part.clone());
        self.mode = BuildingState::GettingStructureSide;

        Ok(())
    }

    pub fn set_side(&mut self, part_side: f64) -> LuaResult<()> {
        match self.mode {
            BuildingState::GettingAnnexeeSide => {
                self.annexee_base_vector.as_mut().ok_or("annexee_base_vector was None; it should have been set to some value already".into_lua_err())?.orientation = part_side.floor() as i64;
                self.mode = BuildingState::GettingStructure;
                Ok(())
            }
            BuildingState::GettingStructureSide => {
                self.structure_vector
                    .as_mut()
                    .ok_or(
                        "structure_vector was None; it should have been set to some value already"
                            .into_lua_err(),
                    )?
                    .orientation = part_side.floor() as i64;

                if self.annexee.is_some()
                    && self.annexee_base_vector.is_some()
                    && self.structure.is_some()
                    && self.structure_vector.is_some()
                {
                    self.structure
                        .clone()
                        .ok_or(
                            "structure was None; it should have been set to some value already"
                                .into_lua_err(),
                        )?
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
