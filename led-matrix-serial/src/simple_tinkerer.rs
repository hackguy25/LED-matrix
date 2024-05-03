use crate::{color::Color, led_matrix::LedMatrix};
use libftd2xx::{Ft232h, FtStatus};

/// Helper struct for tinkering with an LED panel.
///
/// Provides a set of methods and a text interface to directly control
/// the values of pins on the underlying interface.
pub struct SimpleTinkerer {
    matrix: LedMatrix,
}

impl SimpleTinkerer {
    pub fn new(interface: Ft232h) -> Result<Self, FtStatus> {
        let matrix = LedMatrix::new(interface, 0)?;
        Ok(SimpleTinkerer { matrix })
    }

    pub fn set_color(&mut self, color: Color) -> Result<(), FtStatus> {
        let state = (self.matrix.state() & 0b1111_1000) | color as u8;
        self.matrix.send_value(state)?;
        Ok(())
    }

    pub fn set_clock(&mut self, value: bool) -> Result<(), FtStatus> {
        let state = (self.matrix.state() & 0b0111_1111) | ((value as u8) << 7);
        self.matrix.send_value(state)?;
        Ok(())
    }

    pub fn set_latch(&mut self, value: bool) -> Result<(), FtStatus> {
        let state = (self.matrix.state() & 0b1011_1111) | ((value as u8) << 6);
        self.matrix.send_value(state)?;
        Ok(())
    }

    pub fn set_oe(&mut self, value: bool) -> Result<(), FtStatus> {
        let state = (self.matrix.state() & 0b1101_1111) | ((value as u8) << 5);
        self.matrix.send_value(state)?;
        Ok(())
    }

    pub fn set_vdd(&mut self, value: bool) -> Result<(), FtStatus> {
        let state = (self.matrix.state() & 0b1110_1111) | ((value as u8) << 4);
        self.matrix.send_value(state)?;
        Ok(())
    }

    pub fn set_select(&mut self, value: bool) -> Result<(), FtStatus> {
        let state = (self.matrix.state() & 0b1111_0111) | ((value as u8) << 3);
        self.matrix.send_value(state)?;
        Ok(())
    }

    pub fn execute_command(&mut self, command: &str) -> Result<bool, FtStatus> {
        let command = command.trim().split(' ').collect::<Vec<_>>();
        let Some((&command, params)) = command.split_first() else {
            println!("Provide a command (color, clock, latch, oe, vdd, select, exit)!");
            return Ok(false);
        };
        match command {
            "color" => match params.split_first() {
                None => println!("Provide a color (k, b, g, c, r, m, y, w)!"),
                Some((&c, _)) => match c {
                    "k" => self.set_color(Color::Black)?,
                    "b" => self.set_color(Color::Blue)?,
                    "g" => self.set_color(Color::Green)?,
                    "c" => self.set_color(Color::Cyan)?,
                    "r" => self.set_color(Color::Red)?,
                    "m" => self.set_color(Color::Magenta)?,
                    "y" => self.set_color(Color::Yellow)?,
                    "w" => self.set_color(Color::White)?,
                    s => println!("Invalid color ({s})!"),
                },
            },
            "clock" => match params.split_first() {
                None => println!("Provide a state (on, off)!"),
                Some((&state, _)) => match state {
                    "on" => self.set_clock(true)?,
                    "off" => self.set_clock(false)?,
                    s => println!("Invalid state ({s})!"),
                },
            },
            "latch" => match params.split_first() {
                None => println!("Provide a state (on, off)!"),
                Some((&state, _)) => match state {
                    "on" => self.set_latch(true)?,
                    "off" => self.set_latch(false)?,
                    s => println!("Invalid state ({s})!"),
                },
            },
            "oe" => match params.split_first() {
                None => println!("Provide a state (on, off)!"),
                Some((&state, _)) => match state {
                    "on" => self.set_oe(true)?,
                    "off" => self.set_oe(false)?,
                    s => println!("Invalid state ({s})!"),
                },
            },
            "vdd" => match params.split_first() {
                None => println!("Provide a state (on, off)!"),
                Some((&state, _)) => match state {
                    "on" => self.set_vdd(true)?,
                    "off" => self.set_vdd(false)?,
                    s => println!("Invalid state ({s})!"),
                },
            },
            "select" => match params.split_first() {
                None => println!("Provide a state (on, off)!"),
                Some((&state, _)) => match state {
                    "on" => self.set_select(true)?,
                    "off" => self.set_select(false)?,
                    s => println!("Invalid state ({s})!"),
                },
            },
            "exit" => return Ok(true),
            s => println!("Invalid command ({s})!"),
        }
        Ok(false)
    }
}
