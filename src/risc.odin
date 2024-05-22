package risc

import "core:fmt"
import "core:os"

RISC_FRAMEBUFFER_WIDTH :: 1024
RISC_FRAMEBUFFER_HEIGHT :: 768

Damage :: struct {
	x1: u32,
	y1: u32,
	x2: u32,
	y2: u32,
}

DefaultMemSize :: 0x00100000
DefaultDisplayStart :: 0x0000E7F00

ROMStart :: 0xFFFFF800
ROMWords :: 512
IOStart :: 0xFFFFFFC0

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
	fb_width:      u32,
	fb_height:     u32,
	damage:        Damage,
	RAM:           [dynamic]u32,
	ROM:           [ROMWords]u32,
}

risc_new :: proc() -> ^RISC {
	risc := new(RISC)
	risc.mem_size = DefaultMemSize
	risc.display_start = DefaultDisplayStart
	risc.fb_width = RISC_FRAMEBUFFER_WIDTH / 32
	risc.fb_height = RISC_FRAMEBUFFER_HEIGHT
	risc.damage = Damage {
		x1 = 0,
		y1 = 0,
		x2 = risc.fb_width - 1,
		y2 = risc.fb_height - 1,
	}
	risc.RAM = make([dynamic]u32, risc.mem_size)
	risc.ROM = bootloader
	risc_reset(risc)
	return risc
}

risc_configure_memory :: proc(
	risc: ^RISC,
	megabytes_ram: u32,
	screen_width: u32,
	screen_height: u32,
) {
	megabytes_ram := megabytes_ram
	if (megabytes_ram < 1) {
		megabytes_ram = 1
	}
	if (megabytes_ram > 32) {
		megabytes_ram = 32
	}
	risc.display_start = megabytes_ram << 20
	risc.mem_size = risc.display_start + (screen_width * screen_height) / 8
	risc.fb_width = screen_width / 32
	risc.fb_height = screen_height
	risc.damage = Damage {
		x1 = 0,
		y1 = 0,
		x2 = risc.fb_width - 1,
		y2 = risc.fb_height - 1,
	}
	delete(risc.RAM)
	risc.RAM = make([dynamic]u32, risc.mem_size)

	// Patch the new constants in the bootloader.
	mem_lim := risc.display_start - 16
	risc.ROM[372] = 0x61000000 + (mem_lim >> 16)
	risc.ROM[373] = 0x41160000 + (mem_lim & 0x0000FFFF)
	stack_org := risc.display_start / 2
	risc.ROM[376] = 0x61000000 + (stack_org >> 16)

	// Inform the display driver of the framebuffer layout.
	// This isn't a very pretty mechanism, but this way our disk images
	// should still boot on the standard FPGA system.
	risc.RAM[DefaultDisplayStart / 4] = 0x53697A67
	risc.RAM[DefaultDisplayStart / 4 + 1] = screen_width
	risc.RAM[DefaultDisplayStart / 4 + 2] = screen_height
	risc.RAM[DefaultDisplayStart / 4 + 3] = risc.display_start

	risc_reset(risc)
}

risc_reset :: proc(risc: ^RISC) {
	risc.PC = ROMStart / 4
}

risc_run :: proc(risc: ^RISC, cycles: u32) {
	risc.progress = 20
	for i: u32 = 0; (i < cycles) && (risc.progress > 0); i += 1 {
		risc_single_step(risc)
	}
}

risc_single_step :: proc(risc: ^RISC) {
	ir: u32
	if risc.PC < risc.mem_size / 4 {
		ir = risc.RAM[risc.PC]
	} else if (risc.PC >= ROMStart / 4) && (risc.PC < ROMStart / 4 + ROMWords) {
		ir = risc.ROM[risc.PC - ROMStart / 4]
	} else {
		fmt.fprintf(os.stderr, "Branched into the void: %08X, resetting...\n", risc.PC)
		risc_reset(risc)
		return
	}
}

risc_get_framebuffer_damage :: proc(risc: ^RISC) -> Damage {
	return Damage{x1 = 0, y1 = 0, x2 = risc.fb_width - 1, y2 = risc.fb_height - 1}
}

risc_get_framebuffer :: proc(risc: ^RISC, offset: u32) -> u32 {
	return risc.RAM[(risc.display_start / 4) + offset]
}
