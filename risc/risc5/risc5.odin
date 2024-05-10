package risc5

RISC_FRAMEBUFFER_WIDTH :: 1024
RISC_FRAMEBUFFER_HEIGHT :: 768

Damage :: struct {
	x1: i32,
	y1: i32,
	x2: i32,
	y2: i32,
}

RISC :: struct {
	PC:            u32,
	R:             [16]u32,
	H:             u32,
	Z, N, C, V:    bool,
	mem_size:      u32,
	display_start: u32,
	progress:      u32,
	current_tick:  u32,
	mouse:         u32,
	key_buf:       [16]u8,
	key_cnt:       u32,
	switches:      u32,

	// RISC_LED
	// RISC_Serial
	spi_selected:  u32,
	// RISC_SPI
	// RISC_Clipboard
	fb_width:      int,
	fb_height:     int,
	damage:        Damage,

	// RAM
	// ROM
}

create :: proc() -> RISC {
	return RISC{PC = 0}
}

get_framebuffer_damage :: proc(risc: ^RISC) -> Damage {
	return Damage{x1 = 0, y1 = 0, x2 = RISC_FRAMEBUFFER_WIDTH / 32, y2 = RISC_FRAMEBUFFER_HEIGHT}
}

get_framebuffer :: proc(risc: ^RISC, offset: i32) -> u32 {
	return 0xFFFFFFFF
}
