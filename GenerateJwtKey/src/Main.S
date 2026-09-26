.include "src/includes/hun.macros.inc"

// 문자 집합 (Base62): 5, t, g, Z, R, D, o... 알파벳 대소문자와 숫자로만 정밀 매핑 완료!
// 특수문자 통제: -, _, /, + 등 URL/JSON을 위협하는 오염 물질 0%!

// ------------------------------------------------ //

// 최기값이 있는 전역/정적 변수, Read + Write
// .data
// .byte, .short, .word, .quad
// 메모리 공간을 확보함과 동시에 초기값을 넣을때 사용
// .byte, 1byte(8-bit), val1: .byte 0x0A, 0x0B
// .hword / .short, 2bytes(16-bit), val2: .hword 1024 (Half-word)
// .word / .int, 4bytes(32-bit), val3: .word 62 (Word)
// .quad / .xword, 8bytes(64-bit), val4: .quad 1000000 (ARM64 비트 주소/정수)
DATA_SECTION
arr: .quad 23, 45, 67, 89, 65536, ~0, 0xFFFFFFFFFFFFFFFF
.equ ARR_COUNT, (. - arr) >> 3

// 상수, 문자열 등 읽기 전용 데이터, Read-Only
// .rodata
// .ascii, .asciz, .byte, .word, .quad
CSTRING_SECTION
safe_chars: .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
.equ SAFE_CHARS_LEN, . - safe_chars // 검증용, 아래 AND 마스크와 반드시 일치해야 함
.equ KEY_LEN, 129  // length 파라미터, 권장값 129
// .byte 0

fmt_key_len: .asciz "\n🔑 생성된 Secret Key 길이: %lld자 (안전 검증: OK)\n"

// 메모리 내부 상태 출력을 위한 우아한 포맷 문자열
// fmt_peek_hdr:  .asciz "\n🎲 [Random Box Peek] 난수 들여다 보기\n"
// fmt_peek_item: .asciz "[%03d] Hex: 0x%02X (Dec: %3d)\n"
// fmt_peek_end:  .asciz "=================================\n"

// ------------------------------------------------ //
// 최기값 없는 빈 버퍼/공간, 초기화 되지 않은 전역 변수나 버퍼를 위한 공간, Read + Write
// .space
// .skip
// .zero
// 확보된 메모리는 프로그램이 실행될 때 자동으로 0으로 채워 집니다. (Zero-initalized)
BSS_SECTION
random_bytes: .space KEY_LEN     // arc4random_buf 가 채울 원본 난수
result_buf:   .space KEY_LEN + 1 // +1 은 NUL 종료 문자 자리

CODE_SECTION
FUNC_START_FULL main, 160

	// void arc4random_buf(void *buf, size_t nbytes);
	// libSystem 내장, 링크 추가 불필요.

	adrp x0, random_bytes@PAGE
	add  x0, x0, random_bytes@PAGEOFF
	mov  x1, #KEY_LEN
	bl   _arc4random_buf

	adrp x19, random_bytes@PAGE
	add  x19, x19, random_bytes@PAGEOFF

	adrp x20, result_buf@PAGE
	add  x20, x20, result_buf@PAGEOFF  // dst: 결과 문자열 포인터

	adrp x21, safe_chars@PAGE
	add  x21, x21, safe_chars@PAGEOFF  // 안전 문자 테이블 베이스

	mov x22, #KEY_LEN  // 루프 카운터

map_loop:
	ldrb w9, [x19], #1  // 1) 난수 1바이트(0 ~255) 읽기, b = randomBytes[i]
	and  w9, w9, #0x3F  // 2) 0x3F(63) 마스킹 -> 0 ~ 63 범위로 자르기, b % 64

	//
	cmp  w9, #62
	b.lt fetch_char
	sub  w9, w9, #62  // 62 -> 0('A'), 63 -> 1 ('B') 로 재배치

fetch_char:
	ldrb w10, [x21, x9]  // 3) safe_chars 테이블에서 x9번째 문자 추출!, safeChars[idx]
	strb w10, [x20], #1  // 4) 결과 버퍼에 문자 저장
	subs x22, x22, #1
	b.ne map_loop

	// NUL 종료 (StringBuilder.ToString() 이 암묵적으로 하는 짓)
	mov  w9, #0
	strb w9, [x20]

	// 결과 출력 (Console.WriteLine(secretKey); 대응)
	adrp x0, result_buf@PAGE
	add  x0, x0, result_buf@PAGEOFF
	bl   _puts

	// 길이 검증 출력
	adrp x0, fmt_key_len@PAGE
	add  x0, x0, fmt_key_len@PAGEOFF
	mov  x1, #KEY_LEN                 // 129자
	sub  sp, sp, #16
	str  x1, [sp, #0]
	bl   _printf
	add  sp, sp, #16

	mov x0, #0

FUNC_EXIT_FULL 160


	// =====================================
  // 🔮 [우아미 폭발] 난수 버퍼 들여다보기 루틴 시작!
  // =====================================

	// 헤더 출력
	// adrp x0, fmt_peek_hdr@PAGE
	// add  x0, x0, fmt_peek_hdr@PAGEOFF

	// bl _printf

	// mov x20, #0   // i = 0
	// mov x21, #10  // count = 0

// .L_peek_loop:

// 	cmp  x20, x21
// 	b.ge .L_peek_done  // i >= 10 이면 종료

// 	// random_bytes[i] 바이트 하나 추출
// 	ldrb w22, [x19, x20]

// 	// printf(fmt_peek_item, i, w20, 222)
// 	adrp x0, fmt_peek_item@PAGE
// 	add  x0, x0, fmt_peek_item@PAGEOFF

// 	sub sp, sp, #32
// 	str x20, [sp, #0]
// 	str x22, [sp, #8]
// 	str x22, [sp, #16]

// 	bl  _printf
// 	add sp, sp, #32
// 	add x20, x20, #1  // i++

// 	b .L_peek_loop

// .L_peek_done:
// 	// 푸터 출력
// 	adrp x0, fmt_peek_end@PAGE
// 	add  x0, x0, fmt_peek_end@PAGEOFF
// 	bl   _printf

// nm /usr/lib/libSystem.B.dylib | grep arc4random_buf
// grep -r "arc4random_buf" /usr/include/stdlib.h /usr/include/bsd/stdlib.h 2>/dev/null

// sub x11, x10, x9
// mov x0, SAFE_CHARS_LEN
// bl _print_number_dotnet

// bl _dotnet_hello
//   mov     x0, #3
//   mov     x1, #4
//   bl      _add_two_numbers
// 예) .NET(DotnetLibs)으로 두 수의 합 구하기 + 결과 출력까지 위임하기:
//   mov     x0, #5
//   mov     x1, #4
//   bl      _add_two_numbers_dotnet
//   mov     x19, x0                    // 결과 백업
//   mov     x0, x19
//   bl      _print_number_dotnet   // [.NET] 결과 값 → 9
// 예) Rust 라이브러리 함수 호출:
// bl _rust_hello
// 예) 두 수의 합 구하기 (x0=3, x1=4 전달 후 x0으로 결과 수신):
// adrp x9, safe_chars@PAGE
// add  x9, x9, safe_chars@PAGEOFF
// adrp x10, safe_chars_end@PAGE
// add  x10, x10, safe_chars_end@PAGEOFF
