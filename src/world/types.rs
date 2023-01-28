use mlua::prelude::{LuaFunction, LuaNumber, LuaResult, LuaTable, LuaValue};
use mlua::{Lua, Result, ToLua, UserData, UserDataFields, UserDataMethods};

pub struct Controls<'lua> {
    pub gun: bool,
    pub engine: LuaTable<'lua>,
}

pub struct ModuleInputs<'lua> {
    pub dt: f64,
    pub body: LuaTable<'lua>,
    pub getPart: LuaFunction<'lua>,
    pub controls: Controls<'lua>,
    pub teamHostility: LuaTable<'lua>,
}

pub type Location = (f64, f64, f64);
pub type WorldEvent = (String, Location, f64);

pub trait Module {
    fn update(&mut self, inputs: ModuleInputs, location: Location) -> Option<WorldEvent>;
}
