.section __TEXT, __cstring, cstring_literals
.p2align 2

fmt_str: .asciz "입력된 인수: [%s]\n"
fmt_count_str: .asciz "총 인수 개수: %d\n"

.section __TEXT, __text, regular, pure_instructions
.p2align 2

// ------------------------------ //
.global _args

_args:
    stp x29, x30, [sp, #-128]!
    mov x29, sp

    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    // [인수를 받는 우아한 방법]
    // x0 (argc, 함수명 포함 8개)
    // x1 (*argv[], 8개의 포인터가 담긴 배열의 시작점) 이 들어옴

    adrp x24, fmt_str@PAGE
    add x24, x24, fmt_str@PAGEOFF

    // [인수 보존]
    // 인수 배열의 개수 8개 보존 (Product -> Scheme -> Edit Scheme -> Run)
    mov x19, x0

    // [인수 1개 이하면 조기 리턴]
    cmp x19, #1
    b.le .L_args_end

    mov x20, x1 // 중요: printf 에 오염되지 않도록 argv 배열주소를 백업
    mov x28, #0 // 카운터 변수 (i = 0)

.L_args_loop_start:
    cmp x28, x19
    b.eq .L_args_end
    ldr x21, [x20], #8 // x21 = 출력할 문자열의 메모리 주소

    mov x0, x24
    sub sp, sp, #16
    str x21, [sp, #0]
    bl _printf
    add sp, sp, #16

    add x28, x28, #1
    b .L_args_loop_start

.L_args_end:

    // [총 인수 개수 출력]
    adrp x0, fmt_count_str@PAGE
    add x0, x0, fmt_count_str@PAGEOFF

    sub sp, sp, #16
    str x19, [sp, #0] // argc를 가변인자 슬롯에 저장
    bl _printf
    add sp, sp, #16
    
    mov x0, #0
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #128
    ret
