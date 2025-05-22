use mlua::prelude::{LuaTable, LuaFunction};
use mlua::{Lua, Result, IntoLua, UserData, UserDataFields, UserDataMethods};

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
    pub fn set_annexee(&mut self, structure: LuaTable, part: LuaTable) -> Result<()> {
        self.annexee_base_vector = part.clone().get("location")?;
        self.body = part.clone().get::<LuaTable>("modules")?
            .get::<LuaTable>("hull")?
            .get::<LuaTable>("fixture")?
            .get::<LuaFunction>("getBody")?.call(())?;

        self.annexee = Some(structure);
        self.annexee_part = Some(part);

        self.mode = BuildingState::GettingAnnexeeSide;

        Ok(())
    }

    pub fn set_structure(&mut self) {}

    pub fn set_side(&mut self) {}
}

impl UserData for Building {
    fn add_fields<F: UserDataFields<Self>>(fields: &mut F) {
        fields.add_field_method_get("structure", |_, this| Ok(this.structure.clone()));
    }

    fn add_methods<M: UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut("setAnnexee", |_, this, (structure, part): (LuaTable, LuaTable)| {
            this.set_annexee(structure, part.clone())
        });

        methods.add_method_mut("setStructure", |_, this, ()| {
            this.set_structure();
            Ok(())
        });

        methods.add_method_mut("setSide", |_, this, ()| {
            this.set_side();
            Ok(())
        });
    }
}

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    exports.set(
        "create",
        lua.create_function(
            |lua: &Lua, (capacity, logdir, logfile): (usize, String, String)| new().into_lua(lua),
        )?,
    )?;

    Ok(exports)
}
