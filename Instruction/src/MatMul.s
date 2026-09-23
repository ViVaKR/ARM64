//
//  MatMul.s
//  Instruction
//
//  Created by 김범준 on 9/18/26.
//

.globl _MatMul
.p2align 2

// MAT A = [ a0 a1 ]      MAT B = [ b0 b1 ]
//         [ a2 a3 ]              [ b2 b3 ]
//
// Result C = A * B
//   C0 = a0*b0 + a1*b2   (A 1행 · B 1열)
//   C1 = a0*b1 + a1*b3   (A 1행 · B 2열)
//   C2 = a2*b0 + a3*b2   (A 2행 · B 1열)
//   C3 = a2*b1 + a3*b3   (A 2행 · B 2열)
//
// 즉 "행 벡터 · 열 벡터" = 원소끼리 곱한 뒤 다 더하기(dot product) 가 전부임.
// AI의 거대한 행렬곱도 이 dot product를 무수히 반복하는 것뿐.

_MatMul:
    // 예시 값: A = [1 2; 3 4], B = [5 6; 7 8]
    mov w0, #1
    mov w1, #2
    mov w2, #3
    mov w3, #4
    ins v0.s[0], w0        // v0 = [a0, a1] = A의 1행
    ins v0.s[1], w1
    ins v1.s[0], w2        // v1 = [a2, a3] = A의 2행
    ins v1.s[1], w3

    mov w4, #5
    mov w5, #6
    mov w6, #7
    mov w7, #8
    ins v2.s[0], w4        // v2 = [b0, b2] = B의 1열 (열이니까 세로로 뽑아옴)
    ins v2.s[1], w6
    ins v3.s[0], w5        // v3 = [b1, b3] = B의 2열
    ins v3.s[1], w7

    // ---- C0 = A1행 · B1열 = a0*b0 + a1*b2 ----
    mul  v4.2s, v0.2s, v2.2s   // v4 = [a0*b0, a1*b2]  ← 원소별 곱셈
    addp v4.2s, v4.2s, v4.2s   // v4.s[0] = a0*b0 + a1*b2 ← 짝끼리 더해서(pairwise) 합침
    // 이제 v4.s[0] 에 C0 결과가 들어있음

    // ---- C1 = A1행 · B2열 = a0*b1 + a1*b3 ----
    mul  v5.2s, v0.2s, v3.2s
    addp v5.2s, v5.2s, v5.2s   // v5.s[0] = C1

    // ---- C2 = A2행 · B1열 = a2*b0 + a3*b2 ----
    mul  v6.2s, v1.2s, v2.2s
    addp v6.2s, v6.2s, v6.2s   // v6.s[0] = C2

    // ---- C3 = A2행 · B2열 = a2*b1 + a3*b3 ----
    mul  v7.2s, v1.2s, v3.2s
    addp v7.2s, v7.2s, v7.2s   // v7.s[0] = C3

    ret

    // 결과 확인:
    // (lldb) register read -f uint32_t[] v4 v5 v6 v7
    // C0=19 (1*5+2*7), C1=22 (1*6+2*8), C2=43 (3*5+4*7), C3=50 (3*6+4*8)
    // → C = [19 22; 43 50]  (표준 2x2 행렬곱 결과와 일치)
