package main

import "core:fmt"
import "core:os"
import "vendor:sdl2"

RISC_FRAMEBUFFER_WIDTH :: 1024
RISC_FRAMEBUFFER_HEIGHT :: 768

main :: proc() {

	fullscreen: bool = false
	zoom: f64 = 0

	risc_rect: sdl2.Rect = sdl2.Rect {
		w = RISC_FRAMEBUFFER_WIDTH,
		h = RISC_FRAMEBUFFER_HEIGHT,
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
	display := 0

	if fullscreen {
		window_flags |= sdl2.WINDOW_FULLSCREEN
		display = 0 // best_display(&risc_rect)
	}
	if zoom == 0 {
		bounds: sdl2.Rect
		if sdl2.GetDisplayUsableBounds(i32(display), &bounds) == 0 &&
		   bounds.h >= risc_rect.h * 2 &&
		   bounds.h >= risc_rect.h * 2 {
			zoom = 2
		} else {
			zoom = 1
		}
	}

	window: ^sdl2.Window = sdl2.CreateWindow(
		"Project Oberon",
		sdl2.WINDOWPOS_UNDEFINED,
		sdl2.WINDOWPOS_UNDEFINED,
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
		640,
		480,
	)
	defer sdl2.DestroyTexture(texture)

	display_rect := risc_rect

	sdl2.ShowWindow(window)
	sdl2.RenderClear(renderer)
	sdl2.RenderCopy(renderer, texture, &risc_rect, &display_rect)
	sdl2.RenderPresent(renderer)

	done: bool = false
	for !done {

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

		sdl2.RenderClear(renderer)
		sdl2.RenderCopy(renderer, texture, &risc_rect, &display_rect)
		sdl2.RenderPresent(renderer)

		sdl2.Delay(1000 / 60)
	}


}
