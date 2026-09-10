// =================================================
//  제목: 섹션 선언 및 함수 제어 매크로 모음 (hun.macros.inc)
//  목적: 장문의 지시문을 압축하고 ARM64 최적화 규칙을 강제함
// =================================================

.ifndef HUN_SECTION_MACROS_INC
.set    HUN_SECTION_MACROS_INC, 1

 ========================================================
// [진입] FuncMax : 전원 참전형 거대 스택 확보 (최대 16KB)
// ========================================================
.macro FuncMax name, stack_size

    .if    \stack_size < 96
        .error "FuncMax: 모든 독서실을 쓰려면 stack_size는 최소 96 이상이어야 합니다!"
    .endif

    .if    (\stack_size % 16) != 0
        .error "FuncMax: stack_size는 16의 배수여야 합니다! (ARM64 SP 정렬 규칙)"
    .endif

    .if    \stack_size > 16384
        .error "FuncMax: macOS 안전 한계치(16KB)를 초과했습니다! 스택 프로빙이 필요합니다."
    .endif

.global _\name
.align 2

_\name:
    // 1단계: 스택 포인터 웅장하게 깎아 내리기
    sub     sp, sp, #\stack_size

    // 2단계: 확보된 공간 꼭대기에 총무(x29)와 다음갈곳(x30) 배정
    stp     x29, x30, [sp, #(\stack_size - 16)]
    add     x29, sp, #(\stack_size - 16)

    // 3단계: x19~x28 독서실 레지스터 10개 풀 백업
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]
    stp     x25, x26, [sp, #64]
    stp     x27, x28, [sp, #80]
.endmacro


// ========================================================
// [퇴장] FuncMaxExit : 백업 레지스터 복구 및 스택 완전 청소
// ========================================================
.macro FuncMaxExit stack_size
    // 1단계: 독서실 레지스터 역순 완벽 복구
    ldp     x19, x20, [sp, #16]
    ldp     x21, x22, [sp, #32]
    ldp     x23, x24, [sp, #48]
    ldp     x25, x26, [sp, #64]
    ldp     x27, x28, [sp, #80]

    // 2단계: 총무와 다음갈곳 복위
    ldp     x29, x30, [sp, #(\stack_size - 16)]

    // 3단계: 스택 공간 원래대로 메워주고 퇴장
    add     sp, sp, #\stack_size
    ret
.endmacro


// ========================================================
// 전원 참전형 함수 프롤로그 (레지스터 x19~x28 전원 백업)
// 독서실 10개(80바이트) + 기본 프레임(16바이트) = 96바이트 이상
// 변수 2개 - 96 + 16 = 112
// 112, 128, 144, ....
// ========================================================
.macro FUNC_START_FULL name, stack_size

    // [검증 1] 최소 크기 검사 (기본 독서실 분량)
    .if    \stack_size < 96
        .error "FUNC_START_FULL: 모든 독서실을 쓰려면 stack_size는 최소 96 이상이어야 합니다!"
    .endif

    // [검증 2] ARM64 SP 16바이트 정렬 규칙 검사
    .if    (\stack_size % 16) != 0
        .error "FUNC_START_FULL: stack_size는 16의 배수여야 합니다. ARM64 SP 정렬 규칙"
    .endif

    // [검증 3] macOS 가드 페이지 한계치 경고 (16KB)
    .if \stack_size > 16384
        .error "FUNC_START_FULL: "
    .endif

.global _\name
.align 2

_\name:
    // 1. 기본 독서실 총무(x29)와 다음갈곳(x30) 방 배정 및 스택 거대 확보
    stp x29, x30, [sp, #-\stack_size]!
    mov x29, sp

    // 2. x19부터 x28까지 총 10개의 독서실 레지스터를 16바이트 간격으로 풀 백업!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
.endmacro

// =====================================================
// [풀 스펙] 전원 참전형 함수 에필로그 (독서실 청소 및 복원)
// 들어올 때 어지럽힌 독서실 자리를 나갈 때 완벽하게 대청소하고 퇴장하네.
// =====================================================
.macro FUNC_EXIT_FULL stack_size
    // 1. 들어올 때와 정확히 대칭되는 위치에서 안전하게 복원 (청소 작업)
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]

    // 2. 독서실 총무와 다음갈곳을 복구하며 확보했던 거대 스택 통째로 닫기
    ldp x29, x30, [sp], #\stack_size
    ret
.endmacro

// 프롤로그: 표준 프레임 설정 및 x19, x20 안전 백업 필수 보장
.macro FUNC_START name, stack_size
    .if    \stack_size < 32
        .error "FUNC_START: stack_size는 최소 32 이상이어야 합니다 (x19/x20 저장 공간 필요)"
    .endif

    .if    (\stack_size % 16) != 0
        .error "FUNC_START: stack_size는 16의 배수여야 합니다. ARM64 SP 정렬 규칙"
    .endif

.global _\name
.align 2
    _\name:
    stp x29, x30, [sp, #-\stack_size]!
    mov x29, sp
    stp x19, x20, [sp, #16]
.endmacro

// 에필로그 (중량형): x19, x20을 쓰고 스택을 유동적으로 닫을 때
.macro FUNC_EXIT stack_size
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #\stack_size
    ret
.endmacro

// [초경량형] x19, x20 백업 없이 오직 프레임 포인터(x29, x30)만 생성
.macro FUNC_START_LIGHT name, stack_size
    .if    \stack_size < 16
        .error "FUNC_START_LIGHT: stack_size는 최소 16 이상이어야 합니다!"
    .endif
    .if    (\stack_size % 16) != 0
        .error "FUNC_START_LIGHT: stack_size는 16의 배수여야 합니다. ARM64 SP 정렬 규칙"
    .endif
.global _\name
.align 2
    _\name:
    stp x29, x30, [sp, #-\stack_size]!
    mov x29, sp
.endmacro

// 에필로그 (초경량형): 내부에서 x19, x20을 안 쓰고 오직 프레임 포인터만 복원할 때
.macro FUNC_EXIT_LIGHT stack_size
    ldp x29, x30, [sp], #\stack_size
    ret
.endmacro

.endif

