.section __TEXT, __text, regular, pure_instructions

.global _EonDemo
.p2align 2

// Bitwise Exclusive OR NOT
// 두 레지스터의 값을 XOR(배타적 논리합) 연산후 그 결과를 반전(NOT) 하여 저장
// 두 비트가 서로 같으면 1, 다르면 0을 반환, XNOR(Exclusive NOR) 연산 수행
_EonDemo:

    mov x1, #15
    mov x2, #3
    eon x0, x1, x2

    ret

// (lldb) register read -f b x1 x2 x0
//      x1 = 0b0000000000000000000000000000000000000000000000000000000000001111
//      x2 = 0b0000000000000000000000000000000000000000000000000000000000000011
//      x0 = 0b1111111111111111111111111111111111111111111111111111111111110011
