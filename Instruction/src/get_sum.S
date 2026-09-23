.section _TEXT, __cstring, cstring_literals
.p2align 3
result: .asciz "1...100 = %lld\n"

.section __TEXT, __text, regular, pure_instructions
.p2align 2

.globl _get_sum

_get_sum:

    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]

    mov x19, #1
    mov x20, #0

.L_loop:

    cmp x19, #101
    b.eq .L_terminate
    add x20, x20, x19
    add x19, x19, #1
    b .L_loop

.L_terminate:

    adrp x0, result@PAGE
    add x0, x0, result@PAGEOFF

    sub sp, sp, #16
    str x20, [sp, #0]
    bl _printf
    add sp, sp, #16

    mov x0, #0
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32

    ret
