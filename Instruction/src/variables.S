.section __TEXT, __text, regular, pure_instructions
.p2align 2

.globl _variables

_variables:

    stp x29, x30, [sp, #-160]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    // [let number: u64 = 8;]
    // str 명령어로 메모리에 직접 즉시값을 못씀
    mov x9, #8 // 즉시값 8을 임시 레지스터에 로드
    str x9, [sp, #96] // 스택의 [sp, #96] 위치에 8바이트 (u64) 로 저장 -> "number" 변수 생성

    // 변수 읽기
    ldr x9, [sp, #96]

    // 정수 타입을 스택에 저장할 때 rust 타입별 명령어
    mov w9, #5
    mov w10, #6

    // u8/i8, 1바이트
    // strb w9, [sp, #112]

    // u16/i16, 2바이트
    // strh w10, [sp, #128]

    // u32/i32, 4바이트
    // str (w 레지스터)  str w9, [sp, #96]

    // u64/i64, 8바이트
    // str (x 레지스터) str x9, [sp, #96]

    // 레지스터만 쓰는 버전
    // 만약 number 를 다른 함수에 넘기거나 주소를 취하지 않고 그냥 계산에만 쓴다면
    // rustc --release 는 스택에 아예 안쓰고 처리 함.
    mov x19, #8 // number 를 그냥 callee-saved 레지스터에 담아둠 (스택 접근 없음0

    // List<T> Vec<i32> 처럼 크기가 동적이고 함수 밖으로 살아 남아야 하는 데이터 는 반드시
    // 힙(heap) 에 할당해야 함. 이것이 어셈블리에서는 malloc 을 직접 호출하는 코드가 됨

    mov x0, #0

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #160

    ret
