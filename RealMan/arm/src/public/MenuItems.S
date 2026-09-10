.include "SectionHeader.h"

// 메뉴 문자열
CSTRING_SECTION
.global _str_calculate

_str_calculate: .asciz "calculate"

// 메뉴 테이블
CONST_DATA_SECTION
.global _menu_items, _menu_items_end

_menu_items:
    .quad _calculate, _str_calculate
_menu_items_end:
