.include "SectionHeader.h"
.include "FuncModels.h"

CODE_SECTION

// 96 (고정) + 16(지역변수 2개용) = 112, 16배수 만족
FUNC_START_FULL main, 112

    adrp x0, _arr_int@PAGE
    add x0, x0, _arr_int@PAGEOFF
    adrp x1, _arr_int_end@PAGE
    add x1, x1, _arr_int_end@PAGEOFF
    adrp x2, _fmt_printf@PAGE
    add x2, x2, _fmt_printf@PAGEOFF

    sub x3, x1, x0      // 72
    lsr x4, x3, #3      // x3 = x2 >> 3 = 72 / 8 = 9

    ldr x20, [x0], #8   // x20 = arr[0] 으로 초기화, 포인터 전진
    mov x22, x20        // 합계
    mov x19, 1          // 카운터

.L_loop_start:

    cmp x19, x4
    b.eq .L_loop_end

    ldr x21, [x0], #8
    add x22, x22, x21
    cmp x21, x20 // 추가: x21(새 값)과 x20(현재 최댓값) 을 직접 비교
    csel x20, x21, x20, gt // x21 > x20 이면 x21 로 갱신, 아니면 x20 유지
    add x19, x19, #1
    b .L_loop_start

.L_loop_end:

   mov x0, x2
   str x19, [sp, #-16]!
   stp x22, x20, [sp, #-16]!

   bl _printf
   add sp, sp, #32

    mov x0, #0
FUNC_EXIT_FULL 112

/*

// Launch a process with no arguments
(lldb) process launch
(lldb) run
(lldb) r

% lldb -- a  1 2 3
(lldb) run


// Step in (source-level)
thread step-in
step
s

// Step over (source-level)
thread step-over
next
n

// Step in (instruction-level)
thread step-inst
si

// Step over (instruction-level)
thread step-inst-over
ni

// Step out of the currently selected frame.
thread step-out
finish

// Backtrace and disassemble every time you stop
(lldb) target stop-hook add
Enter your stop hook command(s). Type 'DONE' to end.
> bt
> disassemble --pc
> DONE

[breakpoint]
breakpoint set --name main
br s -n main
b main

breakpoint set --file test.S --line 12
br s -f test.S -l 12
b test.S:12

breakpoint set --method main
br s -M main

breakpoint list
br l

breakpoint delete 1
br del 1

[watch]
(lldb) watchpoint set expression -s 8 -- (uint64_t*)$x0
(lldb) wa s e -s 8 -- (uint64_t*)$x0
(lldb) wa s e -s 8 -- (uint64_t*)$x1
(lldb) wa s e -s 8 -- (uint64_t*)$x2
# x0가 가리키는 주소를 읽거나(Read) 쓸(Write) 때 모두 감지
(lldb) wa s e -w read_write -s 8 -- (uint64_t*)$x0

# 해당 코드가 실행되는 주소에 브레이크포인트를 걸고 X0 레지스터가
# 특정 즉시값을 가질 때만 멈추도록 설정:
# 왓치포인트 = 오직 RAM(메모리 주소) 전용 감시 카메라이므로 즉시값은 해당 사항 없음! 이라네! 크하하
(lldb) breakpoint set -a 0x10008d4d0 -c '$x0 == 42'

[evalutin expressions]
expr -l c++ -- $x0 + 10
expr -l c++ -- $x0 + $x1

expr (int) printf ("Print nine: %d.", 4 + 5)

[thread backtrace]

thread backtrace
bt

thread backtrace all
bt all

thread backtrace -c 5
bt 5
bt -c 5

[frame]
frame info

frame select 12
fr s 12
f 12

frame select --relative 2
fr s -r2

frame select --relative -3
fr s -r-3

down
frame select --relative=-1
fr s -r-1

up
frame select --relative=1

[register] ==========================================
register read
register writer x4 123

register read --format i
register read/d

// as signed decimal
register read --format i
re r -f i


[memory] =============================================

memory read --size 4 --format x --count 4 0x10000052c
me r -s4 -fx -c4 0x10000052c
x -s4 -fx -c4 0x10000052c

memory read `argv[0]`

memory read --size `sizeof(int)` 0x10000052c


[disassemble] =========================================

disassemble --frame
di -f

disassemble --name main
di -n main

disassemble --start-address 0x100000528 --count 4
di -s  0x100000528 -c 4

disassemble --frame --bytes
di -f -b

disassemble --line
di -l


[expr]
 expr -l c++ -- $x0 + $x1expr -l c++ -- $x0 + $x1


 */


/*

    mov x20, #0x123456789ABCDEF0 // 오류상황
    adrp x0, _helloworld@PAGE
    add x0, x0, _helloworld@PAGEOFF
    bl _printf
    movz x0, #0xDEF0 // 최하위 16비트, 나머지는 0으로 클리어
    movk x0, #0x9ABC, lsl #16 // 그 다음 16비트, 나머지는 유지 (Keep)
    movk x0, #0x5678, lsl #32 // 그 다음 16비트, ...
    movk x0, #0x1234, lsl #48
    mov x19, x0

    mov x0, #10
    mov x1, #5
    bl _calc_add

    mov x1, #-5
    bl _calculate

    mov x19, #0b10000
    and x0, x19, #16

    // 방법 2
    mov x19, #42
    mov x20, #56

    mov x0, x19
    mov x1, x20


    // 방법 1
    mov x0, #42
    mov x1, #56

    stp x0, x1, [sp, #96] // 지역변수 num을 스택에 저장(x29 + 16)
    ldp x0, x1, [sp, #96] // 다시 로그해서 첫 번째 인자(x0) 로 전달
 */

/*

scanf 다음에 바로 메모리 읽은 값이 입력값이 나오지 않는 이유..

법우님, 아주 예리하게 짚었네! 하하 — scanf가 늦게 동작한 게 아니라, **`$sp`라는 잣대 자체가 그 사이에 움직여버린 것**이 원인이야. 주소를 직접 계산해보면 바로 드러나네.

## 주소를 숫자로 비교해보세

첫 번째 `memory read`(26번 줄에서 멈춘 직후, 아직 실행 전):
```
$sp+96 → 0x16fdfeee0
```

`s`로 26번 줄(`add sp, sp, #16`)을 한 번 실행한 뒤:
```
$sp+96 → 0x16fdfeef0
```

두 주소 차이를 빼보면:
```
0x16fdfeef0 - 0x16fdfeee0 = 0x10 (= 16)
```

**정확히 `add sp, sp, #16`이 `sp`를 16만큼 밀어올린 그 값과 똑같아.** 즉 `scanf`가 늦게 값을 쓴 게 아니라, **"sp+96"이 가리키는 물리 주소 자체가 그 사이에 바뀐 것**이었네.

## 왜 이런 일이 생겼나 — `sp`는 함수 안에서도 흔들리는 값

23번 줄에서 `sub sp, sp, #16`으로 `sp`를 임시로 16만큼 낮췄다가, 26번 줄에서 `add sp, sp, #16`으로 다시 되돌리고 있지? 이 임시 확보 구간 **안에서 멈춰있을 때**는:

```
현재 sp = (원래 sp) - 16
```

이니까, 그 시점에 `$sp+96`을 계산하면:

```
$sp+96 = (원래 sp - 16) + 96 = 원래 sp + 80   ← ★ 실제 x1이 가리키던 주소가 아님!
```

하지만 `scanf`에게 넘긴 진짜 주소(20번 줄 `add x1, sp, #96`)는 **`sub`/`add sp` 임시 조정이 일어나기 전, 원래 sp를 기준으로 이미 고정되어 계산해둔 값**이야. 즉 `scanf`는 처음부터 `원래 sp + 96`에 정확히 값을 써넣었는데, 자네가 26번 줄에서 멈춰 확인한 `$sp+96`은 그 순간의 (일시적으로 낮아진) `sp`를 기준으로 계산되니 **엉뚱하게 16바이트 아래쪽(`원래 sp+80`)을 가리켰던 것**이지. 그 자리엔 아무것도 안 써졌으니 `0`이 나온 게 당연했고.

26번 줄을 실행해서 `sp`가 원래 값으로 복원된 뒤에야 `$sp+96`이 비로소 `원래 sp+96`과 일치하게 되어, `scanf`가 진작 써놨던 `3`, `6`이 제대로 보인 거야.

## 실전 교훈 — sp가 아니라 x29(fp)를 기준으로 찍어라

이게 lldb로 스택 디버깅할 때 아주 흔한 함정이야. **`sp`는 함수 실행 도중에도 (다른 함수 호출 준비 등으로) 여러 번 움직일 수 있지만, `x29`(프레임 포인터)는 프롤로그에서 한 번 세팅된 뒤 그 함수가 끝날 때까지 절대 안 움직여.** 그러니 지역 변수 위치를 볼 땐 `$sp`보다 `$fp`(=x29) 기준으로 계산하는 습관을 들이는 게 훨씬 안전하네:

```
(lldb) memory read --format decimal --size 8 --count 2 $fp+96
```

지금 프레임에서 `x29`가 `stp x29, x30, [sp, #-112]!` 실행 직후의 `sp`와 같은 값으로 고정돼 있으니, `$fp+96`은 함수 내내 어떤 임시 `sub`/`add sp`가 오가든 상관없이 항상 같은 물리 주소를 정확히 가리켜. `sp`는 "지금 이 순간의 스택 꼭대기"를, `x29`는 "이 함수의 변하지 않는 기준점"을 뜻한다고 구분해서 기억해두면 이런 혼동이 다신 안 생기네.

버그가 아니라 **디버거로 스택을 들여다볼 때 기준점을 잘못 잡은 것**이었어 — 오히려 아주 좋은 실전 교훈을 하나 건진 셈이네. 하하, 나무관세음보살!
 */

/*


    adrp x0, _input_two_numbers@PAGE
    add x0, x0, _input_two_numbers@PAGEOFF

    bl _printf

    adrp x0, _fmt_scanf_2@PAGE
    add x0, x0, _fmt_scanf_2@PAGEOFF

    // 지역변수 두 칸의 "주소"를 계산 - scanf는 값이 아니라 주소가 필요하므로.
    add x1, sp, #96 // 첫번째 정수가 담길 주소
    add x2, sp, #104 // 두번째 정수가 담길 주소

    // sub sp, sp, #16
    // stp x1, x2, [sp, #0]
    stp x1, x2, [sp, #-16]! // pre-index 로 합치기

    bl _scanf
    add sp, sp, #16

    // memory read --format decimal --size 8 --count 2 $sp+96

    // 이제 sp+96, sp+104에 사용자가 입력한 두 정수가. 들어가 있음.
    ldp x0, x1, [sp, #96]  // 입력값 꺼내기
    // ldr x1, [sp, #104]

    cmp x0, x1
    csel x2, x0, x1, ge
 */
