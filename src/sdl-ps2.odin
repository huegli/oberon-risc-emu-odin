package risc

import "vendor:sdl2"

MAX_PS2_CODE_LEN :: 8

k_type :: enum {
	K_UNKNOWN = 0,
	K_NORMAL,
	K_EXTENDED,
	K_NUMLOCK_HACK,
	K_SHIFT_HACK,
}

k_info :: struct {
	code: u8,
	type: k_type,
}

// QWERTY keymap
// keymap: [sdl2.NUM_SCANCODES]k_info = {
// 	sdl2.SCANCODE_A              = {0x1c, .K_NORMAL},
// 	sdl2.SCANCODE_B              = {0x32, .K_NORMAL},
// 	sdl2.SCANCODE_C              = {0x21, .K_NORMAL},
// 	sdl2.SCANCODE_D              = {0x23, .K_NORMAL},
// 	sdl2.SCANCODE_E              = {0x24, .K_NORMAL},
// 	sdl2.SCANCODE_F              = {0x2b, .K_NORMAL},
// 	sdl2.SCANCODE_G              = {0x34, .K_NORMAL},
// 	sdl2.SCANCODE_H              = {0x33, .K_NORMAL},
// 	sdl2.SCANCODE_I              = {0x43, .K_NORMAL},
// 	sdl2.SCANCODE_J              = {0x3b, .K_NORMAL},
// 	sdl2.SCANCODE_K              = {0x42, .K_NORMAL},
// 	sdl2.SCANCODE_L              = {0x4b, .K_NORMAL},
// 	sdl2.SCANCODE_M              = {0x3a, .K_NORMAL},
// 	sdl2.SCANCODE_N              = {0x31, .K_NORMAL},
// 	sdl2.SCANCODE_O              = {0x44, .K_NORMAL},
// 	sdl2.SCANCODE_P              = {0x4d, .K_NORMAL},
// 	sdl2.SCANCODE_Q              = {0x15, .K_NORMAL},
// 	sdl2.SCANCODE_R              = {0x2d, .K_NORMAL},
// 	sdl2.SCANCODE_S              = {0x1b, .K_NORMAL},
// 	sdl2.SCANCODE_T              = {0x2c, .K_NORMAL},
// 	sdl2.SCANCODE_U              = {0x3c, .K_NORMAL},
// 	sdl2.SCANCODE_V              = {0x2a, .K_NORMAL},
// 	sdl2.SCANCODE_W              = {0x1d, .K_NORMAL},
// 	sdl2.SCANCODE_X              = {0x22, .K_NORMAL},
// 	sdl2.SCANCODE_Y              = {0x35, .K_NORMAL},
// 	sdl2.SCANCODE_Z              = {0x1a, .K_NORMAL},
// 	sdl2.SCANCODE_1              = {0x16, .K_NORMAL},
// 	sdl2.SCANCODE_2              = {0x1e, .K_NORMAL},
// 	sdl2.SCANCODE_3              = {0x26, .K_NORMAL},
// 	sdl2.SCANCODE_4              = {0x25, .K_NORMAL},
// 	sdl2.SCANCODE_5              = {0x2e, .K_NORMAL},
// 	sdl2.SCANCODE_6              = {0x36, .K_NORMAL},
// 	sdl2.SCANCODE_7              = {0x3d, .K_NORMAL},
// 	sdl2.SCANCODE_8              = {0x3e, .K_NORMAL},
// 	sdl2.SCANCODE_9              = {0x46, .K_NORMAL},
// 	sdl2.SCANCODE_0              = {0x45, .K_NORMAL},
// 	sdl2.SCANCODE_RETURN         = {0x5a, .K_NORMAL},
// 	sdl2.SCANCODE_ESCAPE         = {0x76, .K_NORMAL},
// 	sdl2.SCANCODE_BACKSPACE      = {0x66, .K_NORMAL},
// 	sdl2.SCANCODE_TAB            = {0x0d, .K_NORMAL},
// 	sdl2.SCANCODE_SPACE          = {0x29, .K_NORMAL},
// 	sdl2.SCANCODE_MINUS          = {0x4e, .K_NORMAL},
// 	sdl2.SCANCODE_EQUALS         = {0x55, .K_NORMAL},
// 	sdl2.SCANCODE_LEFTBRACKET    = {0x54, .K_NORMAL},
// 	sdl2.SCANCODE_RIGHTBRACKET   = {0x5b, .K_NORMAL},
// 	sdl2.SCANCODE_BACKSLASH      = {0x5d, .K_NORMAL},
// 	sdl2.SCANCODE_NONUSHASH      = {0x5d, .K_NORMAL},
// 	sdl2.SCANCODE_SEMICOLON      = {0x4c, .K_NORMAL},
// 	sdl2.SCANCODE_APOSTROPHE     = {0x52, .K_NORMAL},
// 	sdl2.SCANCODE_GRAVE          = {0x0e, .K_NORMAL},
// 	sdl2.SCANCODE_COMMA          = {0x41, .K_NORMAL},
// 	sdl2.SCANCODE_PERIOD         = {0x49, .K_NORMAL},
// 	sdl2.SCANCODE_SLASH          = {0x4a, .K_NORMAL},
// 	sdl2.SCANCODE_F1             = {0x05, .K_NORMAL},
// 	sdl2.SCANCODE_F2             = {0x06, .K_NORMAL},
// 	sdl2.SCANCODE_F3             = {0x04, .K_NORMAL},
// 	sdl2.SCANCODE_F4             = {0x0c, .K_NORMAL},
// 	sdl2.SCANCODE_F5             = {0x03, .K_NORMAL},
// 	sdl2.SCANCODE_F6             = {0x0b, .K_NORMAL},
// 	sdl2.SCANCODE_F7             = {0x83, .K_NORMAL},
// 	sdl2.SCANCODE_F8             = {0x0a, .K_NORMAL},
// 	sdl2.SCANCODE_F9             = {0x01, .K_NORMAL},
// 	sdl2.SCANCODE_F10            = {0x09, .K_NORMAL},
// 	sdl2.SCANCODE_F11            = {0x78, .K_NORMAL},
// 	sdl2.SCANCODE_F12            = {0x07, .K_NORMAL},
// 	sdl2.SCANCODE_INSERT         = {0x70, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_HOME           = {0x6c, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_PAGEUP         = {0x7d, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_DELETE         = {0x71, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_END            = {0x69, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_PAGEDOWN       = {0x7a, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_RIGHT          = {0x74, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_LEFT           = {0x6b, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_DOWN           = {0x72, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_UP             = {0x75, .K_NUMLOCK_HACK},
// 	sdl2.SCANCODE_KP_DIVIDE      = {0x4a, .K_SHIFT_HACK},
// 	sdl2.SCANCODE_KP_MULTIPLY    = {0x7c, .K_NORMAL},
// 	sdl2.SCANCODE_KP_MINUS       = {0x7b, .K_NORMAL},
// 	sdl2.SCANCODE_KP_PLUS        = {0x79, .K_NORMAL},
// 	sdl2.SCANCODE_KP_ENTER       = {0x5a, .K_EXTENDED},
// 	sdl2.SCANCODE_KP_1           = {0x69, .K_NORMAL},
// 	sdl2.SCANCODE_KP_2           = {0x72, .K_NORMAL},
// 	sdl2.SCANCODE_KP_3           = {0x7a, .K_NORMAL},
// 	sdl2.SCANCODE_KP_4           = {0x6b, .K_NORMAL},
// 	sdl2.SCANCODE_KP_5           = {0x73, .K_NORMAL},
// 	sdl2.SCANCODE_KP_6           = {0x74, .K_NORMAL},
// 	sdl2.SCANCODE_KP_7           = {0x6c, .K_NORMAL},
// 	sdl2.SCANCODE_KP_8           = {0x75, .K_NORMAL},
// 	sdl2.SCANCODE_KP_9           = {0x7d, .K_NORMAL},
// 	sdl2.SCANCODE_KP_0           = {0x70, .K_NORMAL},
// 	sdl2.SCANCODE_KP_PERIOD      = {0x71, .K_NORMAL},
// 	sdl2.SCANCODE_NONUSBACKSLASH = {0x61, .K_NORMAL},
// 	sdl2.SCANCODE_APPLICATION    = {0x2f, .K_EXTENDED},
// 	sdl2.SCANCODE_LCTRL          = {0x14, .K_NORMAL},
// 	sdl2.SCANCODE_LSHIFT         = {0x12, .K_NORMAL},
// 	sdl2.SCANCODE_LALT           = {0x11, .K_NORMAL},
// 	sdl2.SCANCODE_LGUI           = {0x1f, .K_EXTENDED},
// 	sdl2.SCANCODE_RCTRL          = {0x14, .K_EXTENDED},
// 	sdl2.SCANCODE_RSHIFT         = {0x59, .K_NORMAL},
// 	sdl2.SCANCODE_RALT           = {0x11, .K_EXTENDED},
// 	sdl2.SCANCODE_RGUI           = {0x27, .K_EXTENDED},
// }

keymap: [sdl2.NUM_SCANCODES]k_info = {
	sdl2.SCANCODE_A              = {0x1c, .K_NORMAL}, // A
	sdl2.SCANCODE_B              = {0x22, .K_NORMAL}, // X
	sdl2.SCANCODE_C              = {0x3b, .K_NORMAL}, // J
	sdl2.SCANCODE_D              = {0x24, .K_NORMAL}, // E
	sdl2.SCANCODE_E              = {0x49, .K_NORMAL}, // .
	sdl2.SCANCODE_F              = {0x3c, .K_NORMAL}, // U
	sdl2.SCANCODE_G              = {0x43, .K_NORMAL}, // I
	sdl2.SCANCODE_H              = {0x23, .K_NORMAL}, // D
	sdl2.SCANCODE_I              = {0x21, .K_NORMAL}, // C
	sdl2.SCANCODE_J              = {0x33, .K_NORMAL}, // H
	sdl2.SCANCODE_K              = {0x2c, .K_NORMAL}, // T
	sdl2.SCANCODE_L              = {0x31, .K_NORMAL}, // N
	sdl2.SCANCODE_M              = {0x3a, .K_NORMAL}, // M
	sdl2.SCANCODE_N              = {0x32, .K_NORMAL}, // B
	sdl2.SCANCODE_O              = {0x2d, .K_NORMAL}, // R
	sdl2.SCANCODE_P              = {0x4b, .K_NORMAL}, // L
	sdl2.SCANCODE_Q              = {0x52, .K_NORMAL}, // '
	sdl2.SCANCODE_R              = {0x4d, .K_NORMAL}, // P
	sdl2.SCANCODE_S              = {0x44, .K_NORMAL}, // O
	sdl2.SCANCODE_T              = {0x35, .K_NORMAL}, // Y
	sdl2.SCANCODE_U              = {0x34, .K_NORMAL}, // G
	sdl2.SCANCODE_V              = {0x42, .K_NORMAL}, // K
	sdl2.SCANCODE_W              = {0x4c, .K_NORMAL}, // ;
	sdl2.SCANCODE_X              = {0x15, .K_NORMAL}, // Q
	sdl2.SCANCODE_Y              = {0x2B, .K_NORMAL}, // F
	sdl2.SCANCODE_Z              = {0x4c, .K_NORMAL}, // ;
	sdl2.SCANCODE_1              = {0x16, .K_NORMAL},
	sdl2.SCANCODE_2              = {0x1e, .K_NORMAL},
	sdl2.SCANCODE_3              = {0x26, .K_NORMAL},
	sdl2.SCANCODE_4              = {0x25, .K_NORMAL},
	sdl2.SCANCODE_5              = {0x2e, .K_NORMAL},
	sdl2.SCANCODE_6              = {0x36, .K_NORMAL},
	sdl2.SCANCODE_7              = {0x3d, .K_NORMAL},
	sdl2.SCANCODE_8              = {0x3e, .K_NORMAL},
	sdl2.SCANCODE_9              = {0x46, .K_NORMAL},
	sdl2.SCANCODE_0              = {0x45, .K_NORMAL},
	sdl2.SCANCODE_RETURN         = {0x5a, .K_NORMAL},
	sdl2.SCANCODE_ESCAPE         = {0x76, .K_NORMAL},
	sdl2.SCANCODE_BACKSPACE      = {0x66, .K_NORMAL},
	sdl2.SCANCODE_TAB            = {0x0d, .K_NORMAL},
	sdl2.SCANCODE_SPACE          = {0x29, .K_NORMAL},
	sdl2.SCANCODE_MINUS          = {0x54, .K_NORMAL}, // [
	sdl2.SCANCODE_EQUALS         = {0x5b, .K_NORMAL}, // ]
	sdl2.SCANCODE_LEFTBRACKET    = {0x4a, .K_NORMAL}, // /
	sdl2.SCANCODE_RIGHTBRACKET   = {0x55, .K_NORMAL}, // =
	sdl2.SCANCODE_BACKSLASH      = {0x5d, .K_NORMAL}, // \
	sdl2.SCANCODE_NONUSHASH      = {0x5d, .K_NORMAL}, // \
	sdl2.SCANCODE_SEMICOLON      = {0x1b, .K_NORMAL}, // S
	sdl2.SCANCODE_APOSTROPHE     = {0x4e, .K_NORMAL}, // -
	sdl2.SCANCODE_GRAVE          = {0x0e, .K_NORMAL},
	sdl2.SCANCODE_COMMA          = {0x1d, .K_NORMAL}, // W
	sdl2.SCANCODE_PERIOD         = {0x2a, .K_NORMAL}, // V
	sdl2.SCANCODE_SLASH          = {0x1a, .K_NORMAL}, // Z
	sdl2.SCANCODE_F1             = {0x05, .K_NORMAL},
	sdl2.SCANCODE_F2             = {0x06, .K_NORMAL},
	sdl2.SCANCODE_F3             = {0x04, .K_NORMAL},
	sdl2.SCANCODE_F4             = {0x0c, .K_NORMAL},
	sdl2.SCANCODE_F5             = {0x03, .K_NORMAL},
	sdl2.SCANCODE_F6             = {0x0b, .K_NORMAL},
	sdl2.SCANCODE_F7             = {0x83, .K_NORMAL},
	sdl2.SCANCODE_F8             = {0x0a, .K_NORMAL},
	sdl2.SCANCODE_F9             = {0x01, .K_NORMAL},
	sdl2.SCANCODE_F10            = {0x09, .K_NORMAL},
	sdl2.SCANCODE_F11            = {0x78, .K_NORMAL},
	sdl2.SCANCODE_F12            = {0x07, .K_NORMAL},
	sdl2.SCANCODE_INSERT         = {0x70, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_HOME           = {0x6c, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_PAGEUP         = {0x7d, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_DELETE         = {0x71, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_END            = {0x69, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_PAGEDOWN       = {0x7a, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_RIGHT          = {0x74, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_LEFT           = {0x6b, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_DOWN           = {0x72, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_UP             = {0x75, .K_NUMLOCK_HACK},
	sdl2.SCANCODE_KP_DIVIDE      = {0x4a, .K_SHIFT_HACK},
	sdl2.SCANCODE_KP_MULTIPLY    = {0x7c, .K_NORMAL},
	sdl2.SCANCODE_KP_MINUS       = {0x7b, .K_NORMAL},
	sdl2.SCANCODE_KP_PLUS        = {0x79, .K_NORMAL},
	sdl2.SCANCODE_KP_ENTER       = {0x5a, .K_EXTENDED},
	sdl2.SCANCODE_KP_1           = {0x69, .K_NORMAL},
	sdl2.SCANCODE_KP_2           = {0x72, .K_NORMAL},
	sdl2.SCANCODE_KP_3           = {0x7a, .K_NORMAL},
	sdl2.SCANCODE_KP_4           = {0x6b, .K_NORMAL},
	sdl2.SCANCODE_KP_5           = {0x73, .K_NORMAL},
	sdl2.SCANCODE_KP_6           = {0x74, .K_NORMAL},
	sdl2.SCANCODE_KP_7           = {0x6c, .K_NORMAL},
	sdl2.SCANCODE_KP_8           = {0x75, .K_NORMAL},
	sdl2.SCANCODE_KP_9           = {0x7d, .K_NORMAL},
	sdl2.SCANCODE_KP_0           = {0x70, .K_NORMAL},
	sdl2.SCANCODE_KP_PERIOD      = {0x71, .K_NORMAL},
	sdl2.SCANCODE_NONUSBACKSLASH = {0x61, .K_NORMAL},
	sdl2.SCANCODE_APPLICATION    = {0x2f, .K_EXTENDED},
	sdl2.SCANCODE_LCTRL          = {0x14, .K_NORMAL},
	sdl2.SCANCODE_LSHIFT         = {0x12, .K_NORMAL},
	sdl2.SCANCODE_LALT           = {0x11, .K_NORMAL},
	sdl2.SCANCODE_LGUI           = {0x1f, .K_EXTENDED},
	sdl2.SCANCODE_RCTRL          = {0x14, .K_EXTENDED},
	sdl2.SCANCODE_RSHIFT         = {0x59, .K_NORMAL},
	sdl2.SCANCODE_RALT           = {0x11, .K_EXTENDED},
	sdl2.SCANCODE_RGUI           = {0x27, .K_EXTENDED},
}

ps2_encode :: proc(sdl_scancode: sdl2.Scancode, make: bool) -> [dynamic]u8 {
	out: [dynamic]u8

	info := keymap[sdl_scancode]
	#partial switch (info.type) {
	case .K_UNKNOWN:
		break
	case .K_NORMAL:
		if (!make) {
			append(&out, u8(0xf0))
		}
		append(&out, info.code)
	case .K_EXTENDED:
		append(&out, u8(0xe0))
		if (!make) {
			append(&out, u8(0xe0))

		}
		append(&out, info.code)
	case .K_NUMLOCK_HACK:
		// This assumes Num Lock is always active
		if (make) {
			// fake shift press
			append(&out, u8(0xe0))
			append(&out, u8(0x12))
			append(&out, u8(0xe0))
			append(&out, info.code)
		} else {
			append(&out, u8(0xe0))
			append(&out, u8(0xf0))
			append(&out, info.code)
			// fake shift release
			append(&out, u8(0xe0))
			append(&out, u8(0xf0))
			append(&out, u8(0x12))
		}
	case .K_SHIFT_HACK:
		{
			mod := sdl2.GetModState()
			if (make) {
				// fake shift release
				if (.LSHIFT in mod) {
					append(&out, u8(0xe0))
					append(&out, u8(0xf0))
					append(&out, u8(0x12))
				}
				if (.RSHIFT in mod) {
					append(&out, u8(0xe0))
					append(&out, u8(0xf0))
					append(&out, u8(0x59))
				}
				append(&out, u8(0xe0))
				append(&out, info.code)
			} else {
				append(&out, u8(0xe0))
				append(&out, u8(0xf0))
				append(&out, info.code)
				// fake shift press
				if (.LSHIFT in mod) {
					append(&out, u8(0xe0))
					append(&out, u8(0x12))
				}
				if (.RSHIFT in mod) {
					append(&out, u8(0xe0))
					append(&out, u8(0x59))
				}
			}
		}

	}
	return out
}
