//
//  Ins.s
//  Instruction
//
//  Created by 김범준 on 9/18/26.
//

.globl _Ins

.p2align 2

_Ins:
    mov w0, #10
    mov w1, #20
    mov w2, #30
    mov w3, #40

    ins v0.s[0], w0 // v0 0번째 칸에 10을 삽입 -> [10, 0, 0, 0]
    ins v0.s[1], w1 // [10, 20, 0, 0]
    ins v0.s[2], w2 // [10, 20, 30, 0]
    ins v0.s[3], w3 // [10, 20, 30, 40]

    // (lldb) register read v0
    // v0 = {0x0a 0x00 0x00 0x00 0x14 0x00 0x00 0x00 0x1e 0x00 0x00 0x00 0x28 0x00 0x00 0x00}

    // (lldb) register read -f uint32_t[] v0
    // v0 = {0x0000000a 0x00000014 0x0000001e 0x00000028}

    ret
