use mlua::prelude::LuaTable;
use mlua::{Lua, Result};

use crate::world::types::Location;

pub fn sign(x: f64) -> f64 {
    if x < 0.0 {
        -1.0
    } else if x > 0.0 {
        1.0
    } else {
        0.0
    }
}

pub fn magnitude(x: f64, y: f64) -> f64 {
    f64::sqrt(x * x + y * y)
}

pub fn angle(x: f64, y: f64) -> f64 {
    f64::atan2(y, x)
}

pub fn components(r: f64, angle: f64) -> (f64, f64) {
    let x: f64 = r * f64::cos(angle);
    let y: f64 = r * f64::sin(angle);

    (x, y)
}

pub fn rotate(x: f64, y: f64, angle: f64) -> (f64, f64) {
    let r: f64 = magnitude(x, y);
    let t: f64 = self::angle(x, y);
    components(r, t + angle)
}

pub fn add(a: Location, b: Location) -> Location {
    let mut l = Location {
        x: 0.0,
        y: 0.0,
        angle: 0.0,
        x_velocity: 0.0,
        y_velocity: 0.0,
        angle_velocity: 0.0,
    };
    (l.x, l.y) = rotate(b.x, b.y, b.angle);
    l.angle = b.angle;

    (l.x_velocity, l.y_velocity) = rotate(b.x_velocity, b.y_velocity, b.angle_velocity);
    l.angle_velocity = b.angle_velocity;

    l.x += a.x;
    l.y += a.y;
    l.angle += a.angle;
    l.x_velocity += a.x_velocity;
    l.y_velocity += a.y_velocity;
    l.angle_velocity += a.angle_velocity;

    l
}

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    exports.set(
        "sign",
        lua.create_function(|_lua: &Lua, x: f64| Ok(sign(x)))?,
    )?;
    exports.set(
        "magnitude",
        lua.create_function(|_lua: &Lua, (x, y): (f64, f64)| Ok(magnitude(x, y)))?,
    )?;
    exports.set(
        "angle",
        lua.create_function(|_lua: &Lua, (x, y): (f64, f64)| Ok(angle(x, y)))?,
    )?;
    exports.set(
        "components",
        lua.create_function(|_lua: &Lua, (r, angle): (f64, f64)| Ok(components(r, angle)))?,
    )?;
    exports.set(
        "rotate",
        lua.create_function(|_lua: &Lua, (x, y, angle): (f64, f64, f64)| Ok(rotate(x, y, angle)))?,
    )?;
    exports.set(
        "add",
        lua.create_function(|_lua: &Lua, (a, b): (Location, Location)| Ok(add(a, b)))?,
    )?;

    Ok(exports)
}
