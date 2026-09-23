.section __TEXT, __text, regular, pure_instructions

.global _EorDemo
.p2align 2

// Exclusive OR: 베타적 논리합(XOR)을 수행하는 명령어
// 두 비티가 서로 다를 때만 1을 반환, 같으면 0을 반환
// 1. 특정비트 반전(Toggle): 특정비트를 1과 XOR 연산하면 그 비트의 값만 반전됨
//       -> 0은 1, 1은 0
// 2. 레지스터를 0으로 초기화 (Zeroing): 자기 자신과 XOR 연산을 하면 모든 비트가 0이됨
//       -> ERO x0, x0, x0
// 3. 암호화 및 체크섬: 대칭형 암호화 알고리즘이나 CRC, 데이터 무결성 검사에서 사용됨.
_EorDemo:

    mov x0, #45
    eor x0, x0, x0 // 0으로 초기화

    mov x1, #0b1111
    mov x2, #0b0101
    eor x1, x1, x2

    ret
