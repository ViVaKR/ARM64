.globl _MrsMsr

.section __TEXT, __text, regular, pure_instructions

.p2align 2

// msr (Move to System Register)
// mrs (Move from System Register)
// 특수목적 레지스터(System Register) 는 mov 로 접근할 수 없음.

// 일반 레지스터 계급 : x0 ~ x30
// 시스템 레지스터 계급 : nzcv, cpsr, sp_e10

// nzcv: 상태 플래그 레지스터

// fpcr / fpsr: 부동 소수점 제어 및 상태 레지스터
//   -> 소수점 연산(Float, Double)을 할 때 반올림을 어떻게 할지,
//   -> 혹은 0으로 나누기 에러가 났는지 상태를 확인하고 제어하는 보관함.

// tpidr_e10: 유저 스레드 ID 레지스터
//   -> 멀티스페드를 돌릴 때 "지금 실행 중인 스레드의 고유주소"를 저장해 두는 비밀 주머니.

// sctlr_el1 (System Control Register) : 가상메모리 (MMU)를 켜고 끄는 스위치
// sp_el1: 커널 저용 스택 포인터
// ttbr0_el1 (Translation Table Base Register): 페이지 테이블 (메모리 지도)주소를 박아 넣는 곳

// register read cpsr

_MrsMsr:

    movz x0, #0x4, lsl #16


    // 1. NZCV 레지스터 값을 x0로 읽어 로기 (MRS)
    mrs x0, nzcv

    // 2. 비트 연산을 통해 Z(Zero) 플래스를 강제로 세팅하기
    // NZCV 상위 4비트 [31:28]을 사용함
    // N=31, Z=30, C=29, V=28
    orr x0, x0, #(1 << 30)

    // 3. 수정한 값을 다시 NZCV 레지스터에 넣기 (MSR)
    msr NZCV, x0

    mov x0, #0
    ret

// expr -l c++ -f x -- 0x00000000ULL | (1ULL << 31) | (1ULL << 30)

// (1ULL << 31)
// 1000 0000 0000 0000 0000 0000 0000 0000 (이진수)
// 16진수 변환 : 이진수 4개씩 묶어서 16진수로 변경 1000 => 8
// 0x80000000

// (1ULL << 30)
// 0100 0000 0000 0000 0000 0000 0000 0000 (이진수)
// 0x40000000
// ================================================
// 1100 0000 0000 0000 0000 0000 0000 0000 (이진수)
// 0xc0000000
