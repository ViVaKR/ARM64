.include "src/includes/hun.macros.inc"

CSTRING_SECTION
msg_input_number: .asciz "입력된 번호: %lld\n"

CODE_SECTION

// int main(int argc, char** argv)
// x0 = argc, x1 = argv
FUNC_START_FULL main, 160

    // x19: 배열 base
    // x20: n
    // x21: 커서
    // x22: 총 개수 (n + 1)
    // x23: 16바이트 청크 수

	// cmp  w0, #2
	// b.lt Lusage  // "< 2"
	movi v0.16b, #1
	add  x19, x0
	bl   _get_prime_numbers
	bl   _input_number
	mov  x19, x0             // 소수를 구할 대상 번호, 사용자 입력

	adrp x0, msg_input_number@PAGE
	add  x0, x0, msg_input_number@PAGEOFF

	sub sp, sp, #16
	str x19, [sp, #0]
	bl  _printf
	add sp, sp, #16

	mov x20, #2  // i = 2
	mov x21, #2  // j = 2
	mov x22, #0  // result, 0 = false, 1 = true

	mov x23, x19  // number


.L_i_loop:

	cmp  x20, x19
	b.lt .L_end






.L_end:
	mov x0, #0
FUNC_EXIT_FULL 160
