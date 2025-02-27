use std::fs;
use std::io::Write;
use std::path::Path;

use mlua::prelude::LuaTable;
use mlua::{Lua, Result, ToLua, UserData, UserDataFields, UserDataMethods};

pub struct DrawTimeLogger {
    pub times: Vec<f64>,
    pub capacity: usize,
    pub log_file: Option<fs::File>,
    pub frame_num: u8,
}

pub fn new(capacity: usize, logdir: String, logfile: String) -> Result<DrawTimeLogger> {
    let logpath = Path::new(logdir.as_str()).join(logfile);
    let log_file = match fs::OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open(logpath.clone())
    {
        Ok(log_file) => Some(log_file),
        Err(error) => {
            // TODO: Replace this eprintln with a log function
            // that respects the current log level.
            eprintln!("ERROR Failed to open file {}: {}", logpath.display(), error);
            None
        }
    };

    Ok(DrawTimeLogger {
        times: Vec::new(),
        capacity,
        log_file,
        frame_num: 0,
    })
}

const INTERVAL: u8 = 30;

impl DrawTimeLogger {
    pub fn insert(&mut self, duration: f64) {
        if self.times.len() == self.capacity {
            self.times.pop();
        }

        self.times.insert(0, duration);
    }

    pub fn log(&mut self) {
        self.frame_num += 1;

        if self.frame_num % INTERVAL == 0 {
            if let Some(log_file) = &mut self.log_file {
                if let Err(error) = log_file.write_all(
                    self.times
                        .iter()
                        .fold(String::new(), |mut s: String, time| {
                            s.push_str(&time.to_string());
                            s.push('\n');
                            s
                        })
                        .as_bytes(),
                ) {
                    // TODO: Replace this eprintln as well.
                    eprintln!("ERROR Failed to write draw times: {}", error);
                }
            }
        }
    }

    pub fn average(&self) -> f64 {
        self.times.iter().sum::<f64>() / self.times.len() as f64
    }
}

impl UserData for DrawTimeLogger {
    fn add_fields<'lua, F: UserDataFields<'lua, Self>>(fields: &mut F) {
        fields.add_field_method_get("times", |_, this| Ok(this.times.clone()));
    }

    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method_mut("insert", |_, this, duration: f64| {
            this.insert(duration);
            Ok(())
        });

        methods.add_method_mut("log", |_, this, ()| {
            this.log();
            Ok(())
        });

        methods.add_method_mut("average", |_, this, ()| Ok(this.average()));
    }
}

pub fn lua_module(lua: &Lua) -> Result<LuaTable> {
    let exports = lua.create_table()?;

    exports.set(
        "new",
        lua.create_function(
            |lua: &Lua, (capacity, logdir, logfile): (usize, String, String)| {
                new(capacity, logdir, logfile)?.to_lua(lua)
            },
        )?,
    )?;

    Ok(exports)
}
