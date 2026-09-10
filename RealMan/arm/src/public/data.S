.include "SectionHeader.h"

DATA_SECTION

.global _arr_int, _arr_int_end

_arr_int:
    // 8 byte * 10 = 80 byte
    .quad 3, 10, 1, 7, 9, 5, 2, 6, 4, 8

_arr_int_end:


// 낡은 주석이 코드보다 위험하다.
//  매직넘버를 주석에 박아 두면 코드 보다 위험하다.는 교훈
// 사람이 읽을땐 주석을 먼저 믿음.
