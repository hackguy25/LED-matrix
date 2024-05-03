use libftd2xx::{Ft232h, Ftdi, FtdiCommon};
use std::{error::Error, io, sync::mpsc, time::Duration};
use timer::Timer;

mod color;
mod led_matrix;
mod line_setter;
mod simple_tinkerer;

use crate::{
    line_setter::{LineSetter, Message},
    simple_tinkerer::SimpleTinkerer,
};

fn main() -> Result<(), Box<dyn Error>> {
    let ftdi = Ftdi::new()?;
    let mut ftdi = Ft232h::try_from(ftdi)?;
    // ftdi.eeprom_erase()?;
    let info = FtdiCommon::device_info(&mut ftdi)?;
    println!("Device information: {:?}", info);

    let stdin = io::stdin();
    match 1 {
        0 => {
            let mut tinkerer = SimpleTinkerer::new(ftdi)?;
            println!("Type command (color, clock, latch, oe, vdd, exit).");
            loop {
                let mut command = String::new();
                let _ = stdin.read_line(&mut command)?;
                if tinkerer.execute_command(&command)? {
                    return Ok(());
                }
            }
        }
        1 => {
            let (sender, setter_receiver) = mpsc::channel();
            let (line_setter, receiver) = LineSetter::new(ftdi, setter_receiver)?;
            let _ = line_setter.spawn();
            let timer = Timer::new();
            let sender2 = sender.clone();
            let _guard = timer.schedule_repeating(time::Duration::milliseconds(1), move || {
                if let Err(e) = sender2.send(Message::FlipLine) {
                    println!("Error sending: {}", e);
                }
            });
            println!("Type command (line, exit)");
            loop {
                let mut command = String::new();
                let _ = stdin.read_line(&mut command)?;
                let _ = sender.send(Message::Command(command));
                match receiver.recv_timeout(Duration::from_millis(500)) {
                    Ok(false) => (),
                    Ok(true) => return Ok(()),
                    Err(e) => return Err(e.into()),
                }
            }
        }
        _ => Err("Unknown handler".into()),
    }
}
