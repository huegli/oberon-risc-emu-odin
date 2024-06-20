package risc

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"
import "vendor:sdl2"

CPU_HZ :: 25000000
FPS :: 60

BLACK :: 0x657b83
WHITE :: 0xfdf6e3

MAX_WIDTH :: 2048
MAX_HEIGHT :: 2048

Action :: enum {
	ACTION_OBERON_INPUT,
	ACTION_QUIT,
	ACTION_RESET,
	ACTION_TOGGLE_FULLSCREEN,
	ACTION_FAKE_MOUSE1,
	ACTION_FAKE_MOUSE2,
	ACTION_FAKE_MOUSE3,
}

KeyMapping :: struct {
	state:  u8,
	sym:    sdl2.Keycode,
	mod:    sdl2.Keymod,
	action: Action,
}

key_map := []KeyMapping {
	{sdl2.PRESSED, sdl2.Keycode.F4, sdl2.KMOD_ALT, .ACTION_QUIT},
	{sdl2.PRESSED, sdl2.Keycode.F12, sdl2.KMOD_NONE, .ACTION_RESET},
	{sdl2.PRESSED, sdl2.Keycode.DELETE, sdl2.KMOD_CTRL | sdl2.KMOD_SHIFT, .ACTION_RESET},
	{sdl2.PRESSED, sdl2.Keycode.F11, sdl2.KMOD_NONE, .ACTION_TOGGLE_FULLSCREEN},
	{sdl2.PRESSED, sdl2.Keycode.RETURN, sdl2.KMOD_ALT, .ACTION_TOGGLE_FULLSCREEN},
	{sdl2.PRESSED, sdl2.Keycode.F, sdl2.KMOD_GUI | sdl2.KMOD_SHIFT, .ACTION_TOGGLE_FULLSCREEN},
	{sdl2.PRESSED, sdl2.Keycode.LALT, sdl2.KMOD_LALT, .ACTION_FAKE_MOUSE2},
	{sdl2.RELEASED, sdl2.Keycode.LALT, sdl2.KMOD_NONE, .ACTION_FAKE_MOUSE2},
}

usage :: proc() {
	fmt.printf("Usage: %s [OPTIONS] DISK-IMAGE\n", os.args[0])
	fmt.printf("\n")
	fmt.printf("Options:\n")
	fmt.printf("--fullscreen             Start in fullscreen mode\n")
	fmt.printf("--zoom=<factor>          Set zoom factor\n")
	fmt.printf("--leds                   Show LEDs\n")
	fmt.printf("--mem=<size>             Set memory size (in MB)\n")
	fmt.printf("--size=<width>x<height>  Set screen size\n")
	fmt.printf("--boot-from-serial       Boot from serial port\n")
	fmt.printf("--serial-in=<filename>   Read serial input from file\n")
	fmt.printf("--serial-out=<filename>  Write serial output to file\n")
	os.exit(1)
}

main :: proc() {
	risc := risc_new()
	risc_set_serial(risc, &pclink)
	risc_set_clipboard(risc, &sdl_clipboard)

	leds := RISC_LED {
		write = show_leds,
	}

	fullscreen: bool = false
	zoom: f64 = 0.0
	risc_rect: sdl2.Rect = sdl2.Rect {
		w = RISC_FRAMEBUFFER_WIDTH,
		h = RISC_FRAMEBUFFER_HEIGHT,
	}
	size_option := false
	mem_option: i32 = 0
	serial_in: cstring = ""
	serial_out: cstring = ""
	boot_from_serial := false

	arguments := os.args[1:]
	arg_cnt := len(arguments)
	if arg_cnt == 0 {
		usage()
	}

	filename: cstring
	if !strings.has_prefix(arguments[arg_cnt - 1], "-") {
		filename = strings.clone_to_cstring(arguments[arg_cnt - 1])
		arg_cnt -= 1
	}

	for arg in arguments[:arg_cnt] {
		if arg == "-f" || arg == "--fullscreen" {
			fullscreen = true
		} else if arg == "-L" || arg == "--leds" {
			risc_set_leds(risc, &leds)
		} else if strings.has_prefix(arg, "-z") || strings.has_prefix(arg, "--zoom") {
			res, _ := strings.split(arg, "=")
			zoom, _ = strconv.parse_f64(res[1])
		} else if strings.has_prefix(arg, "-s") || strings.has_prefix(arg, "--size") {
			size_option = true
			size, _ := strings.split(arg, "=")
			d, _ := strings.split(size[1], "x")
			w, _ := strconv.parse_int(d[0])
			h, _ := strconv.parse_int(d[1])
			risc_rect.w = clamp(i32(w), 32, MAX_WIDTH) & 0xffe0
			risc_rect.h = clamp(i32(h), 32, MAX_HEIGHT)
		} else if strings.has_prefix(arg, "-m") || strings.has_prefix(arg, "--mem") {
			mv, _ := strings.split(arg, "=")
			m, _ := strconv.parse_int(mv[1])
			mem_option = i32(m)
		} else if strings.has_prefix(arg, "-I") || strings.has_prefix(arg, "--serial-in") {
			s, _ := strings.split(arg, "=")
			serial_in = strings.clone_to_cstring(s[1])
		} else if strings.has_prefix(arg, "-O") || strings.has_prefix(arg, "--serial-out") {
			s, _ := strings.split(arg, "=")
			serial_out = strings.clone_to_cstring(s[1])
		} else if arg == "-S" || arg == "--boot-from-serial" {
			boot_from_serial = true
			risc_set_switches(risc, 1)
		}
	}

	if (mem_option > 0 || size_option) {
		risc_configure_memory(risc, mem_option, risc_rect.w, risc_rect.h)
	}

	if len(filename) > 0 {
		risc_set_spi(risc, 1, disk_new(filename))
	} else if boot_from_serial {
		// Allow diskless boot
		risc_set_spi(risc, 1, disk_new(nil))
	} else {
		usage()
	}

	if serial_in != "" || serial_out != "" {
		if serial_in == "" {
			serial_in = "/dev/null"
		}
		if serial_out == "" {
			serial_out = "/dev/null"
		}
		risc_set_serial(risc, raw_serial_new(serial_in, serial_out))
	}

	if sdl2.Init(sdl2.INIT_VIDEO) != 0 {
		fmt.printf("Unable to initialize SDL: %s", sdl2.GetError())
		os.exit(1)
	}
	defer sdl2.Quit()
	sdl2.EnableScreenSaver()
	sdl2.ShowCursor(sdl2.DISABLE)
	sdl2.SetHint(sdl2.HINT_RENDER_SCALE_QUALITY, "best")

	window_flags := sdl2.WINDOW_HIDDEN
	display: i32 = 0
	if fullscreen {
		window_flags |= sdl2.WINDOW_FULLSCREEN_DESKTOP
		display = best_display(&risc_rect)
	}
	if zoom == 0 {
		bounds: sdl2.Rect
		if sdl2.GetDisplayBounds(display, &bounds) == 0 &&
		   bounds.h >= risc_rect.h * 2 &&
		   bounds.w >= risc_rect.w * 2 {
			zoom = 2
		} else {
			zoom = 1
		}
	}

	window: ^sdl2.Window = sdl2.CreateWindow(
		"Project Oberon",
		sdl2.WINDOWPOS_UNDEFINED_DISPLAY(display),
		sdl2.WINDOWPOS_UNDEFINED_DISPLAY(display),
		i32(f64(risc_rect.w) * zoom),
		i32(f64(risc_rect.h) * zoom),
		window_flags,
	)

	if (window == nil) {
		fmt.printf("Could not create window: %s", sdl2.GetError())
		os.exit(1)
	}
	defer sdl2.DestroyWindow(window)

	renderer: ^sdl2.Renderer = sdl2.CreateRenderer(window, -1, {.SOFTWARE, .PRESENTVSYNC})
	if (renderer == nil) {
		fmt.printf("Could not create renderer: %s", sdl2.GetError())
		os.exit(1)
	}
	defer sdl2.DestroyRenderer(renderer)

	texture: ^sdl2.Texture = sdl2.CreateTexture(
		renderer,
		u32(sdl2.PixelFormatEnum.ARGB8888),
		sdl2.TextureAccess.STREAMING,
		risc_rect.w,
		risc_rect.h,
	)
	if (texture == nil) {
		fmt.printf("Could not create texture: %s", sdl2.GetError())
		os.exit(1)
	}
	defer sdl2.DestroyTexture(texture)

	display_rect: sdl2.Rect
	display_scale := scale_display(window, &risc_rect, &display_rect)
	update_texture(risc, texture, &risc_rect)
	sdl2.ShowWindow(window)
	sdl2.RenderClear(renderer)
	sdl2.RenderCopy(renderer, texture, &risc_rect, &display_rect)
	sdl2.RenderPresent(renderer)

	done := false
	mouse_was_offscreen := false
	for !done {
		frame_start := i32(sdl2.GetTicks())

		event: sdl2.Event
		evloop: for sdl2.PollEvent(&event) {

			#partial switch (event.type) {
			case .QUIT:
				done = true

			case .WINDOWEVENT:
				if event.window.event == .RESIZED {
					display_scale = scale_display(window, &risc_rect, &display_rect)
				}

			case .MOUSEMOTION:
				scaled_x := i32(math.round(f64(event.motion.x - display_rect.x) / display_scale))
				scaled_y := i32(math.round(f64(event.motion.y - display_rect.y) / display_scale))
				x := clamp(scaled_x, 0, risc_rect.w - 1)
				y := clamp(scaled_y, 0, risc_rect.h - 1)
				mouse_is_offscreen := x != scaled_x || y != scaled_y
				if mouse_is_offscreen != mouse_was_offscreen {
					sdl2.ShowCursor(mouse_is_offscreen ? sdl2.ENABLE : sdl2.DISABLE)
					mouse_was_offscreen = mouse_is_offscreen
				}
				risc_mouse_moved(risc, x, risc_rect.h - y - 1)

			case .MOUSEBUTTONDOWN, .MOUSEBUTTONUP:
				down := event.button.state == sdl2.PRESSED
				risc_mouse_button(
					risc,
					i32(event.button.button),
					down ? sdl2.ENABLE : sdl2.DISABLE,
				)

			case .KEYDOWN, .KEYUP:
				down := event.key.state == sdl2.PRESSED
				#partial switch (map_keyboard_event(&event.key)) {
				case .ACTION_RESET:
					risc_reset(risc)

				case .ACTION_TOGGLE_FULLSCREEN:
					fullscreen = !fullscreen
					if fullscreen {
						sdl2.SetWindowFullscreen(window, sdl2.WINDOW_FULLSCREEN_DESKTOP)
					} else {
						sdl2.SetWindowFullscreen(window, sdl2.WINDOW_SHOWN)
					}

				case .ACTION_QUIT:
					quit := sdl2.Event {
						type = .QUIT,
					}
					sdl2.PushEvent(&quit)

				case .ACTION_FAKE_MOUSE1:
					risc_mouse_button(risc, 1, down ? sdl2.ENABLE : sdl2.DISABLE)

				case .ACTION_FAKE_MOUSE2:
					risc_mouse_button(risc, 2, down ? sdl2.ENABLE : sdl2.DISABLE)

				case .ACTION_FAKE_MOUSE3:
					risc_mouse_button(risc, 3, down ? sdl2.ENABLE : sdl2.DISABLE)

				case .ACTION_OBERON_INPUT:
					ps2_bytes := ps2_encode(event.key.keysym.scancode, down)
					risc_keyboard_input(risc, raw_data(ps2_bytes), i32(len(ps2_bytes)))
				}
			}
		}

		risc_set_time(risc, frame_start)
		risc_run(risc, CPU_HZ / FPS)

		update_texture(risc, texture, &risc_rect)
		sdl2.RenderClear(renderer)
		sdl2.RenderCopy(renderer, texture, &risc_rect, &display_rect)
		sdl2.RenderPresent(renderer)

		frame_end := sdl2.GetTicks()
		delay: i32 = frame_start + 1000 / FPS - i32(frame_end)
		if (delay > 0) {
			sdl2.Delay(u32(delay))
		}
	}
}

best_display :: proc(rect: ^sdl2.Rect) -> i32 {
	best: i32 = 0
	display_cnt := sdl2.GetNumVideoDisplays()
	for i: i32 = 0; i < display_cnt; i += 1 {
		bounds: sdl2.Rect
		if sdl2.GetDisplayUsableBounds(i, &bounds) == 0 &&
		   bounds.h == rect.h &&
		   bounds.w == rect.w {
			best = i
			if bounds.w == rect.w {
				break
			}
		}
	}
	return best
}

clamp :: proc(x, min, max: i32) -> i32 {
	if x < min {
		return min
	} else if x > max {
		return max
	} else {
		return x
	}
}

map_keyboard_event :: proc(event: ^sdl2.KeyboardEvent) -> Action {
	for i := 0; i < len(key_map); i += 1 {
		if (event.state == key_map[i].state) &&
		   (event.keysym.sym == key_map[i].sym) &&
		   (event.keysym.mod == key_map[i].mod) {
			return key_map[i].action
		}
	}
	return .ACTION_OBERON_INPUT
}

show_leds :: proc(leds: ^RISC_LED, value: u32) {
	fmt.printf("LED: ")
	for i := 7; i >= 0; i -= 1 {
		if value & (1 << u32(i)) == 1 {
			fmt.printf("%d", i)
		} else {
			fmt.printf("-")
		}
	}
	fmt.printf("\n")
}

scale_display :: proc(
	window: ^sdl2.Window,
	risc_rect: ^sdl2.Rect,
	display_rect: ^sdl2.Rect,
) -> f64 {

	win_w, win_h: i32
	sdl2.GetWindowSize(window, &win_w, &win_h)

	oberon_aspect: f64 = f64(risc_rect.w) / f64(risc_rect.h)
	window_aspect: f64 = f64(win_w) / f64(win_h)

	scale: f64 = 0
	if oberon_aspect > window_aspect {
		scale = f64(win_w) / f64(risc_rect.w)
	} else {
		scale = f64(win_h) / f64(risc_rect.h)
	}

	w: i32 = i32(math.ceil_f64(f64(risc_rect.w) * scale))
	h: i32 = i32(math.ceil_f64(f64(risc_rect.h) * scale))
	display_rect^ = {
		x = (win_w - w) / 2,
		y = (win_h - h) / 2,
		w = w,
		h = h,
	}

	return scale
}

pixel_buf: [MAX_WIDTH * MAX_HEIGHT]u32

update_texture :: proc(risc: pRISC, texture: ^sdl2.Texture, risc_rect: ^sdl2.Rect) {

	damage: Damage = risc_get_framebuffer_damage(risc)
	if damage.y1 <= damage.y2 {
		inpixels := risc_get_framebuffer_ptr(risc)
		out_idx := 0

		for line: i32 = damage.y2; line >= damage.y1; line -= 1 {
			line_start: i32 = line * risc_rect.w / 32
			for col: i32 = damage.x1; col <= damage.x2; col += 1 {
				pixels := inpixels[line_start + col]
				for b := 0; b < 32; b += 1 {
					pixel_buf[out_idx] = WHITE if (pixels & 1 == 1) else BLACK
					pixels >>= 1
					out_idx += 1
				}
			}
		}
	}

	rect: sdl2.Rect = {
		x = i32(damage.x1) * 32,
		y = i32(risc_rect.h) - i32(damage.y2) - 1,
		w = (i32(damage.x2) - i32(damage.x1) + 1) * 32,
		h = (i32(damage.y2) - i32(damage.y1) + 1),
	}
	sdl2.UpdateTexture(texture, &rect, raw_data(&pixel_buf), rect.w * 4)
}
