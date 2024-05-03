use libftd2xx::{BitMode, Ft232h, FtStatus, FtdiCommon};

/// LED matrix connected to an FT232H serial interface.
///
/// Connections:
/// - ADBUS0: color B
/// - ADBUS1: color G
/// - ADBUS2: color R
/// - ADBUS3: select E
/// - ADBUS4: VDD
/// - ADBUS5: OE
/// - ADBUS6: Latch
/// - ADBUS7: Clock
pub struct LedMatrix {
    interface: Ft232h,
    state: u8,
}
impl LedMatrix {
    pub fn new(mut interface: Ft232h, state: u8) -> Result<Self, FtStatus> {
        interface.set_bit_mode(0xff, BitMode::SyncBitbang)?;
        interface.reset()?;
        interface.set_baud_rate(210_000)?; // Actual speed is about 5 times higher, stable up to 2M?

        let buf = [state];
        interface.write(&buf)?;
        interface.purge_rx()?;

        Ok(LedMatrix { interface, state })
    }

    pub fn state(&self) -> u8 {
        self.state
    }

    pub fn push_pixel(&mut self, value: u8) -> Result<(), FtStatus> {
        let mut value = value & 7;
        value |= self.state & !7;

        // First set value, then clock it in.
        let buf = [value, value | 0x80, value];
        self.interface.write(&buf)?;
        self.state = value;

        Ok(())
    }

    pub fn latch(&mut self) -> Result<(), FtStatus> {
        let buf = [
            self.state | 0x20,
            self.state | 0x40,
            self.state | 0x20,
            self.state,
        ];
        self.interface.write(&buf)?;

        // Do some cleanup.
        self.interface.purge_rx()?;

        Ok(())
    }

    pub fn flip_line(&mut self) -> Result<(), FtStatus> {
        self.state ^= 0x08;
        self.interface.write(&[self.state])?;
        self.interface.purge_rx()?;

        Ok(())
    }

    pub fn send_value(&mut self, value: u8) -> Result<(), FtStatus> {
        self.interface.write(&[value])?;
        self.interface.purge_rx()?;
        self.state = value;
        Ok(())
    }
}
