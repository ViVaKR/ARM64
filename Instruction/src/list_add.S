// equal 또는 equate, ~ 와 같다, ~ 를 같게 만들다.
// 내가 지정한 이 기호(symbol)의 값을 뒤에 나오는 숫자와 동일하게 취급해줘
.equ INITIAL_CAP, 10

.cpu apple-m4

.section __TEXT, __text, regular, pure_instructions

.p2align 2


.globl _list_add

// x19 = base ptr, x20 = count, x21 = capacity
// 구조체처럼 {ptr, count, capacity} 를 힙에 따로 두거나
// x19/x20/x21 레지스터로 세션 동안 들고 다니는 방식

// x19 = malloc ptr
// x20 = count
// x21 = capacity
_list_add:

    // x0 = value to add
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    cmp x20, x21 // count == capacity ?
    b.ne .L_no_grow

    // capacity 부족 -> realloc 으로 2배 확장
    lsl x1, x21, #1 // new_capacity = capacity * 2
    cbz x1, .L_set_init_cap // capacity 가 0이었으면 초기값으로
    b .L_do_realloc

.L_set_init_cap:
    mov x1, #INITIAL_CAP


.L_do_realloc:
    mov x21, x1 // capacity 갱신

.L_no_grow:
    // arr[count] = value
    str w0, [x19, x20, lsl #2]
    add x20, x20, #1 // count++
    ldp x29, x30, [sp], #16
    ret

.L_realloc_fail:
    mov x0, #-1
    ldp x29, x30, [sp], #16
    ret

