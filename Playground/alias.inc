// 1. 별칭 정의용 매크로 만들기
.macro SET_ALIAS alias_name, reg_name
    \alias_name .req \reg_name
.endm

// 2. 매크로 호출 (라인 시작이 표준 매크로 이름이라 에러 표기가 안 뜸!)
	SET_ALIAS ptr, x19
	SET_ALIAS counter, x20
	SET_ALIAS idx, w21
	SET_ALIAS sum, x22

// 3. 해제용 매크로도 세트로 만들어두면 깔끔합니다
.macro UNSET_ALIAS alias_name
    .unreq \alias_name
.endm
