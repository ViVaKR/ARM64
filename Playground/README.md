# 디버깅


```bash

nm bin/entry
objdump -d bin/entry
otool -tV bin/entry
otool -L bin/entry

```

## nm (Name List, 심볼 테이블 조회 무기) - 주소와 이름만 보기

- **T / t (Text)**: `_main`이나 `.L_args_loop_start` 처럼 메모리의 **코드 구역(실행 명령어 영역)**에 존재하는 웅장한 지휘관 라벨이라는 뜻.

- **s (Data / Section)**: `msg`나 `fmt_str`처럼 초기화된 **순수 데이터(문자열 리터럴 등)** 구역에 안전하게 적재되어 있다는 뜻.

- **U (Undefined)**: _printf 앞에 붙은 U가 보이는가 친구? 이건 "내 코드 안에 printf라는 이름은 등록해 놨는데, 실제 몸통은 내가 안 들고 있고 맥OS 시스템 라이브러리(libSystem)에서 빌려 쓸 녀석이다!" 라는 **외부 링크** 첩보를 뜻함.
