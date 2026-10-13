package risc

import "core:fmt"

pclink: RISC_Serial = {
	read_status = PCLink_RStat,
	read_data   = PCLink_RData,
	write_data  = PCLink_TData,
}

Mode :: enum {
	IDLE = 0,
	ACK  = 0x10,
	REC  = 0x21,
	SND  = 0x22,
}

mode: Mode
txcount, rxcount: int
szFilename: string
buf: [dynamic]u8

buffer := make([dynamic]u8)

PCLink_load :: proc() {
	szFilename = "Oberon.Mod\x00"
	clear(&buffer)
	mode = .SND
	txcount = 0
}

PCLink_save :: proc() {
	szFilename = "NewFile.Mod\x00"
	append(&buffer, 'B')
	append(&buffer, 'L')
	append(&buffer, 'A')
	append(&buffer, '\r')
	append(&buffer, 0)
	mode = .REC
	rxcount = 0
}

PCLink_RStat :: proc(serial: ^RISC_Serial) -> u32 {
	return mode != .IDLE ? 3 : 2
}

PCLink_RData :: proc(serial: ^RISC_Serial) -> u32 {
	ch: u32
	if mode != .IDLE {
		if rxcount == 0 {
			ch = u32(mode)
		} else if rxcount < len(szFilename) + 1 {
			ch = u32(szFilename[rxcount - 1])
		} else if mode == .SND {
			ch = u32(Mode.ACK)
			if len(buffer) == 0 {
				mode = .IDLE
			}
		} else {
			pos := (rxcount - len(szFilename) - 1) % 256
			if pos == 0 || len(buffer) == 0 {
				if len(buffer) > 255 {
					ch = 255
				} else {
					ch = u32(len(buffer))
					if len(buffer) == 0 {
						mode = .IDLE
					}
				}
			} else {
				ch = u32(buffer[0])
				ordered_remove(&buffer, 0)
			}
		}
	}
	// fmt.printf("Sending: %c\n", ch)
	rxcount += 1
	return ch
}

PCLink_TData :: proc(serial: ^RISC_Serial, value: u32) {
	if mode != .IDLE {
		if txcount == 0 {
			if value != u32(Mode.ACK) {
				mode = .IDLE
			}
		} else if mode == .SND {
			append(&buffer, u8(value))
			if value == '\r' {
				fmt.printf("\n")
			} else {
				fmt.printf("%c", value)
			}
		}
	}
	txcount += 1
}
