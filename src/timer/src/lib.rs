use mlua::{Lua, Result};
use mlua::prelude::{LuaResult, LuaNumber, LuaTable};

struct Timer {
    limit: f64,
    time: f64,
}

impl Timer {
    fn ready(&mut self, dt: f64) -> bool {
        self.time -= dt;

        if self.time <= 0.0 {
            self.time += self.limit;
            true
        } else {
            false
        }
    }

    fn from_lua(t: &LuaTable) -> Result<Timer> {
        Ok(Timer {
            limit: t.get("limit")?,
            time: t.get("time")?,
        })
    }

    fn to_lua<'lua>(&self, lua: &'lua Lua) -> Result<LuaTable<'lua>> {
        let t = lua.create_table()?;
        self.copy_to_table(&t)?;
        Ok(t)
    }

    fn copy_to_table(&self, t: &LuaTable) -> Result<()> {
        t.set("limit", self.limit)?;
        t.set("time", self.time)?;

        Ok(())
    }
}

#[mlua::lua_module]
fn timer(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("ready", lua.create_function(ready)?)?;

    let metatable = lua.create_table()?;
    metatable.set("__call", lua.create_function(create)?)?;
    exports.set_metatable(Some(metatable));

    Ok(exports)
}

fn create<'a>(lua: &'a Lua, (_, limit): (LuaTable<'a>, LuaNumber)) -> LuaResult<LuaTable<'a>> {
    let t = Timer {
        limit: limit,
        time: limit,
    }.to_lua(lua)?;

    t.set("ready", lua.create_function(ready)?)?;

    Ok(t)
}

fn ready(_: &Lua, (t, dt): (LuaTable, LuaNumber)) -> LuaResult<bool> {
    let mut timer = Timer::from_lua(&t)?;
    let result = timer.ready(dt);

    timer.copy_to_table(&t)?;

    Ok(result)
}
