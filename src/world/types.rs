use mlua::prelude::{LuaError, LuaFunction, LuaTable, LuaValue};
use mlua::{FromLua, Lua, Result, ToLua};

pub struct Controls<'lua> {
    pub gun: bool,
    pub engine: LuaTable<'lua>,
}

impl<'lua> FromLua<'lua> for Controls<'lua> {
    fn from_lua(value: LuaValue<'lua>, _: &'lua Lua) -> Result<Self> {
        match value {
            LuaValue::Table(table) => Ok(Controls {
                gun: table.get("gun")?,
                engine: table.get("engine")?,
            }),
            _ => Err(LuaError::FromLuaConversionError {
                from: value.type_name(),
                to: "Controls",
                message: Some("expected table".to_string()),
            }),
        }
    }
}

pub struct ModuleInputs<'lua> {
    pub dt: f64,
    pub body: LuaTable<'lua>,
    pub get_part: LuaFunction<'lua>,
    pub controls: Controls<'lua>,
    pub team_hostility: LuaTable<'lua>,
}

impl<'lua> FromLua<'lua> for ModuleInputs<'lua> {
    fn from_lua(value: LuaValue<'lua>, _: &'lua Lua) -> Result<Self> {
        match value {
            LuaValue::Table(table) => Ok(ModuleInputs {
                dt: table.get("dt")?,
                body: table.get("body")?,
                get_part: table.get("getPart")?,
                controls: table.get("controls")?,
                team_hostility: table.get("teamHostility")?,
            }),
            _ => Err(LuaError::FromLuaConversionError {
                from: value.type_name(),
                to: "ModuleInputs",
                message: Some("expected table".to_string()),
            }),
        }
    }
}

pub type Location = [f64; 3];

pub struct WorldEvent {
    pub event_type: String,
    pub location: Location,
    pub data: f64,
}

impl<'lua> ToLua<'lua> for WorldEvent {
    fn to_lua(self, lua: &'lua Lua) -> Result<LuaValue<'lua>> {
        let t = lua.create_table()?;
        t.push(self.event_type)?;
        t.push(self.location)?;
        t.push(self.data)?;
        Ok(LuaValue::Table(t))
    }
}

pub trait Module {
    fn update(&mut self, inputs: ModuleInputs, location: Location) -> Option<WorldEvent>;
}
