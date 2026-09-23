.arch armv9.2-a

.global _main

.section __TEXT, __cstring, cstring_literals

.p2align 2

.section __TEXT, __text, regular, pure_instructions

.p2align 2

_main:

    stp x29, x30, [sp, #-128]!
    mov x29, sp

    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]


    mov x9, #5
    mov x10, #7

    stp x9, x10, [sp, #104]

    // 1. 인수 처리
    bl _args

    bl _make_list
    bl _variables
    bl _get_sum

    mov x0, #0
    
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]

    ldp x29, x30, [sp], #128

    ret
