use mlua::prelude::{LuaError, LuaValue};
use mlua::{FromLua, IntoLua, Lua, Result};

#[derive(Clone)]
pub struct Location {
    pub x: i64,
    pub y: i64,
    pub orientation: i64, // TODO: Replace this with a custom type once more things are written in Rust.
}

impl FromLua for Location {
    fn from_lua(value: LuaValue, _: &Lua) -> Result<Self> {
        match value {
            LuaValue::Table(table) => Ok(Location {
                x: table.get(1)?,
                y: table.get(2)?,
                orientation: table.get(3)?,
            }),
            _ => Err(LuaError::FromLuaConversionError {
                from: value.type_name(),
                to: "part::Location".to_string(),
                message: Some("expected table".to_string()),
            }),
        }
    }
}

impl IntoLua for Location {
    fn into_lua(self, lua: &Lua) -> Result<LuaValue> {
        let t = lua.create_table()?;
        t.push(self.x)?;
        t.push(self.y)?;
        t.push(self.orientation)?;
        Ok(LuaValue::Table(t))
    }
}
