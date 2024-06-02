package risc

import "core:fmt"
import "core:math"
import "core:os"
import "core:strings"
import "vendor:sdl2"

CPU_HZ :: 25000000
FPS :: 60

BLACK :: 0x657b83
WHITE :: 0xfdf6e3

MAX_WIDTH :: 2048
MAX_HEIGHT :: 2048

main :: proc() {

	risc := risc_new()

	fullscreen: bool = false
	zoom: f64 = 0
	risc_rect: sdl2.Rect = sdl2.Rect {
		w = RISC_FRAMEBUFFER_WIDTH,
		h = RISC_FRAMEBUFFER_HEIGHT,
	}

	filename := strings.clone_to_cstring("original/DiskImage/Oberon-2020-08-18.dsk")
	risc_set_spi(risc, 1, disk_new(filename))
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

	done: bool = false
	for !done {
		frame_start := i32(sdl2.GetTicks())

		event: sdl2.Event
		evloop: for sdl2.PollEvent(&event) {

			#partial switch (event.type) {
			case .QUIT:
				done = true
				break evloop
			case .KEYDOWN:
				if (event.key.keysym.sym == .ESCAPE) {
					done = true
					break evloop
				}

			}
		}

		risc_set_time(risc, frame_start)
		risc_run(risc, CPU_HZ / FPS)

		update_texture(risc, texture, &risc_rect)
		sdl2.RenderClear(renderer)
		sdl2.RenderCopy(renderer, texture, &risc_rect, &display_rect)
		sdl2.RenderPresent(renderer)

		sdl2.Delay(1000 / 60)
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
