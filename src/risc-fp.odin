package risc

import "core:fmt"

fp_add :: proc(x: u32, y: u32, u: bool, v: bool) -> u32 {
	xs := (x & 0x80000000) != 0
	xe: u32
	x0: i32
	if !u {
		xe = (x >> 23) & 0xFF
		xm := u32((x & 0x007FFFFF) << 1) | 0x01000000
		x0 = i32(xs ? -xm : xm)
	} else {
		xe = 150
		x0 = i32(x & 0x00FFFFFF) << 8 >> 7
	}

	ys := (y & 0x80000000) != 0
	ye := (y >> 23) & 0xFF
	ym := u32((y & 0x007FFFFF) << 1)
	y0 := i32(ys ? -ym : ym)

	e0: u32
	x3, y3: i32
	if ye > xe {
		shift := u32(ye - xe)
		e0 = ye
		x3 = shift > 31 ? x0 >> 31 : x0 >> shift
		y3 = y0
	} else {
		shift := u32(xe - ye)
		e0 = xe
		x3 = x0
		y3 = shift > 31 ? y0 >> 31 : y0 >> shift

	}

	sum := u32(
		((i32(xs) << 26) | (i32(xs) << 25) | (x3 & 0x01FFFFFF)) +
		((i32(ys) << 26) | (i32(ys) << 25) | (y3 & 0x01FFFFFF)),
	)

	s := u32((((sum & (1 << 26) != 0) ? -sum : sum) + 1) & 0x07FFFFF)

	e1 := u32(e0 + 1)
	t3 := u32(s >> 1)
	if (s & 0x03FFFF3) != 0 {
		for (t3 & (1 << 24)) == 0 {
			t3 <<= 1
			e1 -= 1
		}
	} else {
		t3 <<= 24
		e1 -= 24
	}

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
