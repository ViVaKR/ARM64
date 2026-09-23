.equ INITAL_CAP, 10

.section __TEXT, __text, regular, pure_instructions
.p2align 2

.globl _make_list

// x19 = base ptr
// x20 = count
// x21 = capacity
// 구조체 처럼 { ptr, count, capacity } 를 힙에 따로 두거나.
// x19/x20/x21 레지스터로 세션 동안 들고 다니는 방식
_make_list:

    // x0 = value to add
    stp x29, x30, [sp, #-48]!
    mov x29, sp

    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    // List<int> data = new List<int>(용량 10);
    // malloc(10 * 4바이트) = 40바이트 힙 할당
    // 용량 도달시 realloc 으로 늘리기 신공 발휘
    // 1. 초기 capacity 만큼 배열 할당
    // 2. Add() 시 Count == Capacity 면 보통 2배로 확장 (realloc 상당)
    // 이 방식 덕분에 amortized O(1) Add 가 보장됨
    // 매번 늘리면 O(n) 이 되어버림
    mov x0, #40
    bl _malloc // x0 = 힙에 할당된 메모리 주소 (실패시 0)
    cbz x0, .L_alloc_fail // malloc 실패시 조기 처리
    mov x19, x0 // x19 = 배열의 시작 주소 (base pointer, 보존)
    mov x20, #0 // x20 = 루프 카우터 i (0부터 시작)

.L_loop_start:
    cmp x20, #10
    b.ge .L_loop_end  // i >= 10 이면 루프 종료

    // [data.Add(i);] -> arr[i] = i
    str w20, [x19, x20, lsl #2] // i를 4백(lsl #2) 해서 바이트 오프셋 계산
    add x20, x20, #1 // i++
    b .L_loop_start


.L_loop_end:

    // [return data;]
    mov x0, x19 // 리턴값 = 배열의 시작 주소 (x0)
    mov x1, #10 // 리턴값 = 원소 개수 (x1, C# 의 .Count에 해당)
    b .L_terminate

.L_alloc_fail:

    mov x0, #0
    mov x1, #0
    b .L_terminate

.L_terminate:
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #48
    ret


