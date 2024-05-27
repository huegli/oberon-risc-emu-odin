package risc

import "core:fmt"

fp_add :: proc(x: u32, y: u32, u: bool, v: bool) -> u32 {
	return 0
}

fp_mul :: proc(x: u32, y: u32) -> u32 {
	return 0
}

fp_div :: proc(x: u32, y: u32) -> u32 {
	return 0
}

idiv :: proc(x: u32, y: u32, signed_div: bool) -> (u32, u32) {
	sign := (i32(x) < 0) && signed_div
	x0 := sign ? -i32(x) : i32(x)

	RQ := u64(x0)
	for S in 0 ..< 32 {
		w0 := u32(RQ >> 31)
		w1 := u32(w0 - y)
		if i32(w1) < 0 {
			RQ = (u64(w0) << 32) | ((RQ & 0x000000007FFFFFFF) << 1)
		} else {
			RQ = (u64(w1) << 32) | ((RQ & 0x000000007FFFFFFF) << 1) | 1
		}
	}
	rem := u32(RQ >> 32)
	quot := u32(RQ & 0xFFFFFFFF)
	if sign {
		quot = -quot
		if rem != 0 {
			quot -= 1
			rem = y - rem
		}
	}
	return quot, rem
}
