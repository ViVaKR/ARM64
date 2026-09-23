//
//  Dup.s
//  Instruction
//
//  Created by 김범준 on 9/19/26.
//

.globl _Dup
.p2align 2

_Dup:

    mov w0, #77 // w0 = 77

    dup v0.4s, w0
    // v0 = [77, 77, 77, 77]
    // (lldb) register read -f uint32_t[] v4 v5 v6 v7


    dup v1.8H, v0.h[4]
    // 32 비트 v0[2] 는 16비트 기준으로 보면 v0.h[4] 위치
    // v1 = [77, 77, 77, 77, 77, 77, 77, 77]

    ret

