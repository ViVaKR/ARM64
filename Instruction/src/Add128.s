//
//  Add128.s
//  Instruction
//
//  Created by 김범준 on 9/18/26.
//

.globl _add_128
.p2align 2

// Apple Silicon (macOS) 호출 규약:
// - 첫 번째 128비트 인자: 하위 64비트 = X0, 상위 64비트 = X1
// - 두 번째 128비트 인자: 하위 64비트 = X2, 상위 64비트 = X3
// - 반환값: 하위 64비트 = X0, 상위 64비트 = X1
_add_128:

    // 1. 하위 64비트끼리 더하고 Carry 플래그 업데이트
    adds x4, x0, x2

    // 2. 상위 64비트 끼리 Carry 플래그 포함하여 연산
    adc x5, x1, x3

    // 3. 호출한 곳으로 리턴
    // 결과는 x0, x1 에 남음
    ret


