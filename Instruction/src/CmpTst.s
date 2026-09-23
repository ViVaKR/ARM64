
.section __TEXT,__text,regular, pure_instructions

.global _CmpTst
.p2align 2

_CmpTst:

    
    // cmp (Compare) : 뺄셈(A-B), 두 값의 크기 비교 (같음, 큼, 작음), 조건문 x==y, x>y
    // tst (Test) : 비트 AND (A & B), 특정비트의 켜짐/꺼짐 확인, 비트마스트 홀수/짝수 플래그 검사

    // x0 = 15, x1 = 10 이라고 가정
    mov x0, #18
    mov x1, #15

    cmp x0, x1 // x0 - x1 연산수행 (15 - 10 = 5)
               // 결과는 버리고 플래그만 설정 (Z=0, C=1, N=0 등)
    b.eq .L_equal
    b .L_not_equal

.L_equal:
    mov x0, #0
    b .L_terminate
.L_not_equal:
    mov x0, #1
.L_terminate:

    ret


// 조건 프래그 (NZCV) 개요
// N : 결과가 음수일때 1, 최상위 비트(MSB) 가 1
// Z : 연산결과가 0 이면 1, 두값이 같을 때 1
// C : 뺄셈 연산 시 빌림(Borrow)이 발생하지 않으면 1, 발생하면 0,
//     A - B => A + NOT(B) + 1, A >= B 이면 C=1이됨.
// V : 부호 있는 연산에서 오버플로우/언더플로우가 발생하면 1
