package risc

import "core:c"

foreign import risc_clib "../librisc.a"

// This is the standard size of the framebuffer, can be overridden.
RISC_FRAMEBUFFER_WIDTH :: 1024
RISC_FRAMEBUFFER_HEIGHT :: 768

///////////////////////////////////////////////////////////////
// risc-io.h
///////////////////////////////////////////////////////////////

RISC_Serial :: struct {
	read_status: proc(_: ^RISC_Serial) -> u32,
	read_data:   proc(_: ^RISC_Serial) -> u32,
	write_data:  proc(_: ^RISC_Serial, _: u32),
}

RISC_SPI :: struct {
	read_data:  proc(_: ^RISC_SPI) -> u32,
	write_data: proc(_: ^RISC_SPI, _: u32),
}

RISC_Clipboard :: struct {
	write_control: proc(_: ^RISC_Clipboard, _: u32),
	read_control:  proc(_: ^RISC_Clipboard) -> u32,
	write_data:    proc(_: ^RISC_Clipboard, _: u32),
	read_data:     proc(_: ^RISC_Clipboard) -> u32,
}

RISC_LED :: struct {
	write: proc(_: ^RISC_LED, _: u32),
}

///////////////////////////////////////////////////////////////
// risc.h
///////////////////////////////////////////////////////////////
pRISC :: rawptr

Damage :: struct {
	x1: c.int,
	x2: c.int,
	y1: c.int,
	y2: c.int,
}

@(default_calling_convention = "c")
foreign risc_clib {

	// struct RISC *risc_new(void);
	risc_new :: proc() -> pRISC ---
	// void risc_configure_memory(struct RISC *risc, int megabytes_ram, int screen_width, int screen_height);
	risc_configure_memory :: proc(risc: pRISC, megabytes_ram: c.int, screen_width: c.int, screen_height: c.int) ---
	// void risc_set_leds(struct RISC *risc, const struct RISC_LED *leds);
	risc_set_leds :: proc(risc: pRISC, leds: ^RISC_LED) ---
	// void risc_set_serial(struct RISC *risc, const struct RISC_Serial *serial);
	risc_set_serial :: proc(risc: pRISC, serial: ^RISC_Serial) ---
	// void risc_set_spi(struct RISC *risc, int index, const struct RISC_SPI *spi);
	risc_set_spi :: proc(risc: pRISC, index: c.int, spi: ^RISC_SPI) ---
	// void risc_set_clipboard(struct RISC *risc, const struct RISC_Clipboard *clipboard);
	risc_set_clipboard :: proc(risc: pRISC, clipboard: ^RISC_Clipboard) ---
	// void risc_set_switches(struct RISC *risc, int switches);
	risc_set_switches :: proc(risc: pRISC, switches: c.int) ---

	// void risc_reset(struct RISC *risc);
	risc_reset :: proc(risc: pRISC) ---
	// void risc_run(struct RISC *risc, int cycles);
	risc_run :: proc(risc: pRISC, cycles: c.int) ---
	// void risc_set_time(struct RISC *risc, uint32_t tick);
	risc_set_time :: proc(risc: pRISC, tick: c.int) ---
	// void risc_mouse_moved(struct RISC *risc, int mouse_x, int mouse_y);
	risc_mouse_moved :: proc(risc: pRISC, mouse_x: c.int, mouse_y: c.int) ---
	// void risc_mouse_button(struct RISC *risc, int button, bool down);
	risc_mouse_button :: proc(risc: pRISC, button: c.int, down: c.int) ---
	// void risc_keyboard_input(struct RISC *risc, uint8_t *scancodes, uint32_t len);
	risc_keyboard_input :: proc(risc: pRISC, scancodes: ^c.char, len: c.int) ---

	// uint32_t *risc_get_framebuffer_ptr(struct RISC *risc);
	risc_get_framebuffer_ptr :: proc(risc: pRISC) -> [^]u32 ---
	// struct Damage risc_get_framebuffer_damage(struct RISC *risc);
	risc_get_framebuffer_damage :: proc(risc: pRISC) -> Damage ---

}

///////////////////////////////////////////////////////////////
// disk.h
///////////////////////////////////////////////////////////////

@(default_calling_convention = "c")
foreign risc_clib {

	// struct RISC_SPI *disk_new(const char *filename);
	disk_new :: proc(filename: cstring) -> ^RISC_SPI ---

}

///////////////////////////////////////////////////////////////
// raw_serial.h
///////////////////////////////////////////////////////////////

@(default_calling_convention = "c")
foreign risc_clib {

	// struct RISC_Serial *raw_serial_new(const char *filename_in, const char *filename_out);
	raw_serial_new :: proc(filename_in: cstring, filename_out: cstring) -> ^RISC_Serial ---

}
