use mlua::prelude::{LuaNumber, LuaTable};
use mlua::{Lua, Result, ToLua, UserData, UserDataFields, UserDataMethods};

mod timer;
mod world;

use world::shipparts::missileLauncher;

#[mlua::lua_module]
fn synthein(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    exports.set("timer", timer::lua_module());
    exports.set("missileLauncher", missileLauncher::lua_module());

    Ok(exports)
}
