package risc

import "core:c"
import "core:c/libc"
import "vendor:sdl2"

State :: enum {
	IDLE,
	GET,
	PUT,
}

state := State.IDLE
data: [dynamic]u8
data_ptr: u32
data_len: u32

reset :: proc() {
	state = State.IDLE
	clear(&data)
	data_ptr = 0
	data_len = 0
}

clipboard_control_read :: proc(clip: ^RISC_Clipboard) -> u32 {
	r: u32 = 0
	reset()
	data_cstr := sdl2.GetClipboardText()
	if (data_cstr != nil) {
		data_len_cstr := libc.strlen(data_cstr)
		if (data_len_cstr > uint(c.UINT32_MAX)) {
			reset()
		} else if (data_len_cstr > 0) {
			state = State.GET
			data_len = u32(data_len_cstr)
			for ch in string(data_cstr) {
				if (ch != '\n') {
					r += 1
					append(&data, u8(ch))
				}
			}
		}
	}
	return r
}

clipboard_control_write :: proc(clip: ^RISC_Clipboard, len: u32) {
	reset()
	if (len < c.UINT32_MAX) {
		data_len = len
		state = State.PUT
	}
}

clipboard_data_read :: proc(clip: ^RISC_Clipboard) -> u32 {
	result: u32 = 0
	if (state == State.GET) {
		assert(data != nil && data_ptr < data_len)
		result = u32(data[data_ptr])
		data_ptr += 1
		if result == '\r' && data[data_ptr] == '\n' {
			data_ptr += 1
		} else if (result == '\n') {
			result = '\r'
		}
		if (data_ptr == data_len) {
			reset()
		}
	}
	return result
}

clipboard_data_write :: proc(clip: ^RISC_Clipboard, c: u32) {
	if (state == State.PUT) {
		assert(data != nil && data_ptr < data_len)
		c := c
		if c == '\r' {
			c = '\n'
		}
		append(&data, u8(c))
		data_ptr += 1
		if (data_ptr == data_len) {
			append(&data, 0)
			data_cstr := cstring(raw_data(data))
			sdl2.SetClipboardText(data_cstr)
			reset()
		}

	}
}

sdl_clipboard := RISC_Clipboard {
	read_control  = clipboard_control_read,
	write_control = clipboard_control_write,
	read_data     = clipboard_data_read,
	write_data    = clipboard_data_write,
}
