.ifndef CommonHeader_h
.set CommonHeader_h, 1

// Clang/GAS 어셈블리 매크로

/*
 [기본 문법]
 - \인자명 - 인자 참조, \. 을 붙이면 뒤에 오는 텍스트와 빈칸 없이 강제 결합
 - 인자명:req - 무조건(Required) 입력 해야 함
 - 인자명=기본값 - 인자를 안 주면 자동으로 설정되는 기본 값
 - 인자명:vararg - 컴파일러가 크기를 알 수 없는 가변 인자를 묶어서 한 번에 받음
 - .exitm - 매크로 즉시 탈출, .if 조건문과 연동하여 컴파일 타임 최적화
 - .irp - 단어 리스트 반복, 여러 레지스터를 타겟으로 동일 명령을 복사할 때 사용
 */

// 비트 연산 매크로

/*
   [설명] 특정 레지스터의 비트를 제어하는 매크로
   - dest: 무조건 지정해야 함 (:req)
   - src: 안 적으면 dest 레지스터 자체를 가리킴 (=dest)
   - bit: 안 적으면 기본값 0번 비트 제어 (=0)
*/
// --- 활용법 ---
// BIT_CONTROL x0         // 결과 : and x0, x0, #(1 << 0)
// BIT_CONTROL x0, x1, 4  // 결과 : and x0, x1, $(1 << 4)
.macro BIT_CONTROL dest:req, src=\dest, bit=0
    and \dest, \src, #(1 << \bit)
.endm

/* [설명] 다량의 레지스터를 한 번에 푸시(Push)하는 매크로 */
.macro PUSH_REGS list:vararg
    stp \list, [sp, #-16]!   // 기교: 인자로 들어온 레지스터 쌍을 스택에 박아 넣음
.endm

// --- 활용법 ---
// PUSH_REGS x19, x20           // 결과: stp x19, x20, [sp, #-16]!


.macro LOAD_ADDR reg, symbol
    adrp \reg, \symbol@PAGE
    add  \reg, \reg, \symbol@PAGEOFF
.endm


// Apple M4 벡터(NEON) 레지스터 조립 매크로
// 백터 연산은 레지스터 뒤에
// .4s(32비트 4개)
// .2d(64비트 2개) 같은 크기 접미사를 붙여야 하머
/*
 백터 덧셈 명령어 조립 매크로
 - type 에 4s나 2d를 넣으면 명령어와 레지스터 뒤에 착 붙음
*/
// --- 활용법 ---
// VECTOR_ADD 4s, v0, v1, v2
// 결과: add.4s v0.4s, v1.4s, v2.4s (32비트 4개 동시 덧셈!)
.macro VECTOR_ADD type, v1, v2, v3
    add\.\type \v1\.\type, \v2\.\type, \v3\.\type
.endm

// (.irp) 범용 레지스터 일괄 초기화
// 함수 시작할 때 최기화를 위해 레지스터를 모두 0으로 셋팅할 때
// --- 사용법 ---
// CLEAR_SCRATCH_REGS
// [컴파일러가 실제로 뱉는 코드]
// mov x0, #0
// mov x1, #0
// ...
// mov x7, #0
.macro CLEAR_SCRATCH_REGS
    // 주어진 레지스터 목록을 돌아가며 \r 자리에 넣고 반복 생성
    .irp r, x0, x1, x2, x3, x4, x5, x6, x7
        mov \r, #0
    .endp
.endm

// (.irpc) 순차적 텍스트 라벨 생성
// 글자 한 자씩 뜯어서 라벨이나 데이터 테이블을 연속으로 조립할 때
// --- 사용법 ---
// CREATE_LABELS
// [ 컴파일러가 실제로 뱉는 코드]
// .L_step_1: nop
// .L_step_2: nop
// .L_step_3: nop
.macro CREATE_LABELS
    // 1, 2, 3 글자를 하나씩 뜯엇 \num에 대입
    .irpc num, 123
        .L_step_\num:
            nop

    .endr // .irpc 의 짝, 종료 지시자
.endm

.endif
