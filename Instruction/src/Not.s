
.section __TEXT, __text, regular, pure_instructions

.global _NotDemo
.p2align 2

// ARM64 아키텍처(AArch64)에는
// 독립된 NOT 이라는 비트 반전 명령어 명칭이 존재하지 않습니다.
// 대신 MVN (Move Not) 명령어나 ORN (OR Not),
// 또는 EOR (Exclusive OR) 명령어를 사용하여 비트 NOT 연산을 수행합니다.

_NotDemo:
    // 2의 보수 구하기
    mov x0, #9
    mov x1, #5
    mvn x1, x1       // move not, 비트반전(1의 보수)
    add x1, x1, #1   // + 1 더하기, 결과: x1 = -5 (0xFFFFFFFFFFFFFFFB)

    add x2, x0, x1
    ret
