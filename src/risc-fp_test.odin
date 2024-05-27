package risc

import "core:testing"

@(test)
test_idiv :: proc(t: ^testing.T) {
	q, r := idiv(10, 2, false)
	testing.expect_value(t, q, 5)
	testing.expect_value(t, r, 0)
	q, r = idiv(10, 3, false)
	testing.expect_value(t, q, 3)
	testing.expect_value(t, r, 1)
	q, r = idiv(10, 4, false)
	testing.expect_value(t, q, 2)
	testing.expect_value(t, r, 2)
	q, r = idiv(10, 0, false)
	// 10 / 0 is undefined, so we don't care about the result
	testing.expect_value(t, r, 10)
}

twos_cmpl :: proc(a: u32) -> u32 {
	return u32(u64(~a) + 1)
}

@(test)
test_idiv_signed :: proc(t: ^testing.T) {
	q, r := idiv(twos_cmpl(10), 2, true)
	testing.expect_value(t, q, twos_cmpl(5))
	testing.expect_value(t, r, 0)
	q, r = idiv(twos_cmpl(10), 3, true)
	testing.expect_value(t, q, twos_cmpl(4))
	testing.expect_value(t, r, 2)
	q, r = idiv(twos_cmpl(10), 4, true)
	testing.expect_value(t, q, twos_cmpl(3))
	testing.expect_value(t, r, 2)
	q, r = idiv(10, twos_cmpl(1), true)
	testing.expect_value(t, q, twos_cmpl(3))
	testing.expect_value(t, r, 7)
	q, r = idiv(10, twos_cmpl(2), true)
	testing.expect_value(t, q, twos_cmpl(8))
	testing.expect_value(t, r, twos_cmpl(6))
	q, r = idiv(10, twos_cmpl(3), true)
	testing.expect_value(t, q, twos_cmpl(6))
	testing.expect_value(t, r, twos_cmpl(8))
	q, r = idiv(twos_cmpl(10), twos_cmpl(1), true)
	testing.expect_value(t, q, 2)
	testing.expect_value(t, r, twos_cmpl(8))
	q, r = idiv(twos_cmpl(10), twos_cmpl(2), true)
	testing.expect_value(t, q, 7)
	testing.expect_value(t, r, 4)
}
