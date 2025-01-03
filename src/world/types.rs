use mlua::prelude::{LuaError, LuaFunction, LuaTable, LuaValue};
use mlua::{AnyUserData, FromLua, Lua, Result, ToLua};

pub struct Controls<'lua> {
    pub gun: bool,
    pub missile_launcher: bool,
    pub engine: LuaTable<'lua>,
}

impl<'lua> FromLua<'lua> for Controls<'lua> {
    fn from_lua(value: LuaValue<'lua>, _: &'lua Lua) -> Result<Self> {
        match value {
            LuaValue::Table(table) => Ok(Controls {
                gun: table.get("gun")?,
                missile_launcher: table.get("missileLauncher")?,
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
    pub body: AnyUserData<'lua>, // TODO: implement a type that implements the UserData trait
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

pub struct Location(pub f64, pub f64, pub f64, pub f64, pub f64, pub f64);

impl<'lua> FromLua<'lua> for Location {
    fn from_lua(value: LuaValue<'lua>, _: &'lua Lua) -> Result<Self> {
        match value {
            LuaValue::Table(table) => {
                let vec = table.sequence_values().collect::<Result<Vec<_>>>()?;
                match vec.len() {
                    3 => Ok(Location(vec[0], vec[1], vec[2], 0.0, 0.0, 0.0)),
                    6 => Ok(Location(vec[0], vec[1], vec[2], vec[3], vec[4], vec[5])),
                    _ => Err(LuaError::FromLuaConversionError {
                        from: "table",
                        to: "Location",
                        message: Some(format!(
                            "expected table of length 3 or 6, got {}",
                            vec.len()
                        )),
                    }),
                }
            }
            _ => Err(LuaError::FromLuaConversionError {
                from: value.type_name(),
                to: "Location",
                message: Some("expected table".to_string()),
            }),
        }
    }
}

impl<'lua> ToLua<'lua> for Location {
    fn to_lua(self, lua: &'lua Lua) -> Result<LuaValue<'lua>> {
        let t = lua.create_table()?;
        t.push(self.0)?;
        t.push(self.1)?;
        t.push(self.2)?;
        t.push(self.3)?;
        t.push(self.4)?;
        t.push(self.5)?;
        Ok(LuaValue::Table(t))
    }
}

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
    fn update(&mut self, lua: &Lua, inputs: ModuleInputs, location: Location)
        -> Option<WorldEvent>;
}
