//
//  Orr.s
//  Instruction
//
//  Created by 김범준 on 9/19/26.
//
.globl _Orr
.p2align 2

_Orr:

    mov x0, 0b10101111
    orr x1, xzr, x0

    mov x0, #0


    ret
