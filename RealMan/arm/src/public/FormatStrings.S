.include "SectionHeader.h"

CSTRING_SECTION

.global _helloworld
.global _input_two_numbers
.global _fmt_scanf_2
.global _fmt_printf

_helloworld: .asciz "Hello, World!\n"

_input_two_numbers: .asciz "두 정수를 입력하세요: "
_fmt_scanf_2: .asciz "%lld %lld"

_fmt_printf: .asciz "=> Sum: %lld\n=> Max: %lld\n=> Count: %lld\n"
