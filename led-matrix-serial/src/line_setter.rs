use std::{
    sync::mpsc::{self, Receiver, Sender},
    thread,
};

use crate::led_matrix::LedMatrix;
use libftd2xx::{Ft232h, FtStatus};

pub struct LineSetter {
    matrix: LedMatrix,
    receiver: Receiver<Message>,
    sender: Sender<bool>,
}

pub enum Message {
    Command(String),
    FlipLine,
}

impl LineSetter {
    pub fn new(
        interface: Ft232h,
        receiver: Receiver<Message>,
    ) -> Result<(Self, Receiver<bool>), FtStatus> {
        let mut matrix = LedMatrix::new(interface, 0)?;
        // Enable VDD.
        let _ = matrix.send_value(0x10);
        let (sender, ret_receiver) = mpsc::channel();
        Ok((
            LineSetter {
                matrix,
                receiver,
                sender,
            },
            ret_receiver,
        ))
    }

    #[allow(dead_code)]
    pub fn write_line(&mut self, r: u64, g: u64, b: u64) -> Result<(), FtStatus> {
        for i in 0..64 {
            let value = (r >> i & 1) << 2 | (g >> i & 1) << 1 | (b >> i & 1);
            self.matrix.push_pixel(value as u8)?;
        }
        self.matrix.latch()?;

        Ok(())
    }

    pub fn execute_command(&mut self, command: &str) -> Result<bool, FtStatus> {
        let command = command.trim().split(' ').collect::<Vec<_>>();
        let Some((&command, params)) = command.split_first() else {
            println!("Provide a command (line, exit)!");
            return Ok(false);
        };
        match command {
            "line" => match params.split_first() {
                None => {
                    println!("Provide a line of colors (k, b, g, c, r, m, y, w)!");
                    println!("Example: 'line kbgcrmywkbgcrmywkbgcrmywkbgcrmyw'");
                }
                Some((&line, _)) => {
                    let mut chars = line.chars();
                    for _ in 0..64 {
                        match chars.next() {
                            None => self.matrix.push_pixel(0)?, // Line exhausted, pad with black.
                            Some('k') => self.matrix.push_pixel(0)?,
                            Some('b') => self.matrix.push_pixel(1)?,
                            Some('g') => self.matrix.push_pixel(2)?,
                            Some('c') => self.matrix.push_pixel(3)?,
                            Some('r') => self.matrix.push_pixel(4)?,
                            Some('m') => self.matrix.push_pixel(5)?,
                            Some('y') => self.matrix.push_pixel(6)?,
                            Some('w') => self.matrix.push_pixel(7)?,
                            Some(c) => {
                                println!("Invalid char: {c}");
                                return Ok(false);
                            }
                        }
                    }
                    self.matrix.latch()?;
                }
            },
            "exit" => return Ok(true),
            s => println!("Invalid command ({s})!"),
        }
        Ok(false)
    }

    pub fn receive_messages(&mut self) -> Result<(), FtStatus> {
        loop {
            match self.receiver.recv() {
                Ok(Message::Command(s)) => {
                    let response = self.execute_command(&s)?;
                    let _ = self.sender.send(response);
                }
                Ok(Message::FlipLine) => self.matrix.flip_line()?,
                Err(e) => {
                    println!("Channel errored: {e}");
                    return Ok(());
                }
            }
        }
    }

    pub fn spawn(mut self) -> thread::JoinHandle<Result<(), FtStatus>> {
        thread::spawn(move || self.receive_messages())
    }
}
