.include "hun.macros.inc"

// 1. 레지스터에 직관적인 이름을 매핑!
#define argc x19
#define argv x20
#define counter x24
#define item x22

.equ args, x26

CSTRING_SECTION

fmt_str: .asciz "%lld. 인수 : [%s]\n"
msg:     .asciz "종료중...\n"


CODE_SECTION

FUNC_START_FULL main, 160

  // 인수 처리
  // x0, argc, 인수갯수
  // x1, *argv[], 인수가 담긴 배열 포인터

	// [argc, 인수의 개수 : x19]
	mov x19, x0

	// 인수가 없으면 조기 리턴
	cmp  x19, #1
	b.le .L_terminate

	// [인수의 배열주소 : x20]
	mov x20, x1  // 배열의 주소

	// [카운터: x21]
	mov x21, #0

	adrp x23, fmt_str@PAGE
	add  x23, x23, fmt_str@PAGEOFF

	mov x24, #0  // 인수 갯수

.L_args_loop_start:

	add  x24, x24, #1
	cmp  x21, x19      // i == count
	b.eq .L_terminate  // if i == count, 반복문 종료

	ldr x22, [x20], #8  // x22 = 배열의 주소, post index, => +8 바이트 (다음 배열 인덱스)

	mov x0, x23
	sub sp, sp, #16
	stp x24, x22, [sp, #0]
	bl  _printf
	add sp, sp, #16
	add x21, x21, #1        // i++
	b   .L_args_loop_start

.L_terminate:

	mov x0, #0

FUNC_EXIT_FULL 160

// process launch
// process launch -- 1 2 3 4 5 6 7
// run 1 2 3 4 5
// r

// expr -l objc -- $x1

// settings set target.language objc
// settings set target.language c++

// --> 16진수 8바이트 (Hex) 로 보기
// -s 8 : 한 항목의 크기가 8바이트(64비트)
// -c 4 : 그걸 4개 (4묶음) 읽어라
// -f x : 출력 형태는 16진수

// memory read -s 8 -c 4 -f x $sp
// x/4gx $sp

// -> 4바이트 32비트 로 보기
// memory read -s 4 -c 8 -f x $sp

// == types == //
// "default"
// 'B' or "boolean"
// 'b' or "binary"
// 'y' or "bytes"
// 'Y' or "bytes with ASCII"
// 'c' or "character"
// 'C' or "printable character"
// 'F' or "complex float"
// 's' or "c-string"
// 'd' or "decimal"
// 'E' or "enumeration"
// 'x' or "hex"
// 'X' or "uppercase hex"
// 'f' or "float"
// 'o' or "octal"
// 'O' or "OSType"
// 'U' or "unicode16"
// "unicode32"
// 'u' or "unsigned decimal"
// 'p' or "pointer"
// "char[]"
// "int8_t[]", 1바이트 정수 배열, B0 ~ B31, Byte
// "uint8_t[]"
// "int16_t[]", 1바이트 정수 배열, H0 ~ H31, Halfword
// "uint16_t[]",
// "int32_t[]", 4바니트 정수 배열, W0 ~ W31, Word
// "uint32_t[]",
// "int64_t[]", 8바이트 정수 배열, X0 ~ x31, Doubleword, size_t
// "uint64_t[]", unsigned integer 64-bit type

// "float16[]", 4Bytes, S0 ~ S31, 단 정밀도 실수
// "float32[]"
// "double[]", 8Bytes, D0 ~ D31, 배 정밀도 실수
// "float64[]"

// "uint128_t[]", 16바이트, Q0 ~ Q31 / V0, 128비트 벡터/SIMD

// 'I' or "complex integer"
// 'a' or "character array"
// 'A' or "address"
// "hex float"
// 'i' or "instruction"
// 'v' or "void"
// 'u' or "unicode8"

// ASLR(주소 공간 난독화) : 메모리 보호 기법,프로그램이 메모리 어디에 로드 될지 모르는 환경

// adrp (Address Page): 현재 PC(Program Counter) 기준 +- 4GB 범위 내에서 4KB 페이지 시작 주소를 구함.
// add : 그 페이지 안에서 해당 문자열이 윟치한 정확한 오프셋(위치)을 더함.
// L1캐시 미스 위험: 코드가 실행되는 영역(Text) 과 데이터 영역(Data) 이 떨어져 있어서 CPU 캐시 동선이 꼬일 수 있음.

// ============================================ //
// thread list

// thread backtrace
// thread backtrace all
// thread select 2

// thread continue

// thread step-inst -> stepi or si
// thread step-over-inst -> nexti or ni

// thread until 100

// thread step-in -> step or s
// thread step-over -> next or n
// thread step-out -> finish or f


// =========================== //
// 이 변수가 "다른 자식 함수(bl) 을 다녀온 후에도 살아 있어야 하는가?"
// YES -> Callee-saved (x29 ~ x28) 사용, 임시 작업대 (Scratch)
// NO -> Caller-saved (x9 ~ x15) 사용, 메인 금고(Persistent)

// x16, x17 : IP0, IP1 (Intra-Procedure), 특수목적, 컴파일러/링커가 주소 브릿지(PLT 람폴린)
// x0 ~ x7 : 외부와 통하는 출입문(인자 & 리턴값)
// x8 : Indirect Result/ Syscall : 구조체 반환 주소 전달, 시스콜 번호 지정
