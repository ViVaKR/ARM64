.section __TEXT, __text, regular, pure_instructions
.p2align 2
.globl _BitwiseDemo

_BitwiseDemo:

    // eor (XOR 연산, Exclusive OR): 비트 토글, 값비교, 암호화
    mov x0, #0xF
    eor x0, x0, #1 // 0 <-> 1 반전

    // and: 특정 비트만 남기기 (마스킹)


    // bic: AND NOT, 특정 비트만 끄기(클리어)
    mov x1, #0b11111111
    mov x2, #0b00001111
    bic x0, x1, x2
    // (lldb) register read -f b x0 x1 x2
    //  x0 = 0b11110000
    //  x1 = 0b11111111
    //  x2 = 0b00001111

    // orr: 특정 비트 켜기 (플래그 설정)
    orr x0, x0, #0x8

    // orn: x2의 반전값과 OR

    // eon(Bitwise Exclusive OR NOT)
    // 두 레지스터의 값을 XOR(배타적 논리합) 연산한 후 그 결과를 반전(NOT)하여 저장
    // 두 비트가 서로 같으면 1, 다르면 0을 반환하는 XNOR(Excluisve NOR) 연산을 수행
    mov x1, 0b00001111
    mov x2, 0b00000011
    eon x0, x1, x2

    // mvn: 비트반전(NOT), 전체 비트 뒤집기

    // tst: 특정 비트가 켜져있는지 체크

    // ands: 결과도 쓰면서 조건분기 준비

    // lsl: 왼쪽 논리 시프트, 2의 거듭제곱 곱셈

    // lsr: 오른쪽 논리 시프트, 부호 없는 나눗셈

    // asr: 오른쪽 산술 시프트, 부호 있는 나눗셈 (부호유지)

    // ror: 오른쪽 회전, 해시함수(암호화 라운드)
    ret
