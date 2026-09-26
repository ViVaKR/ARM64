# GenerateJwtKey

`armcli init` 으로 생성된 프로젝트. Zig(`build.zig`)가 오케스트레이터 역할을 하며,
어셈블리 진입점(`src/Main.S`)에서 각 언어 라이브러리의 함수를 `bl` 로 호출하는 구조.

## 구성

- **Rust** — `app/RustLibs/rust_core` (staticlib, `add_two_numbers`, `rust_hello`)
- **Go** — `app/GoLibs` (c-archive, `add_two_numbers_go`, `go_hello`)
- **.NET (Native AOT)** — `app/DotnetLibs` (`add_two_numbers_dotnet`, `print_number_dotnet`, `dotnet_hello`)

## 디렉토리

```
GenerateJwtKey/
├── build.zig          # 오케스트레이터 — 언어별 라이브러리 빌드 후 exe 링크
├── app/
│   ├── RustLibs/rust_core/
│   ├── GoLibs/
│   └── DotnetLibs/
└── src/
    ├── Main.S          # 진입점 (_main / main)
    ├── constants/
    ├── data/
    ├── includes/
    └── libs/
```

## 필요한 도구

- **Zig** — `zig build run` 에 필요 (선택한 언어의 툴체인만 있으면 됨, .NET SDK 불필요)
- **Rust (cargo)** — Rust 라이브러리 빌드에 필요
- **Go** — Go 라이브러리 빌드에 필요
- **.NET SDK 10** — .NET 라이브러리 빌드에 필요 (`zig build run` 사용 시)

## 빌드 & 실행

**권장 — Zig 오케스트레이터** (선택한 언어의 툴체인만 있으면 됨, .NET SDK 없어도 무방):
```bash
zig build run
```

**대안 — .NET 오케스트레이터** (`hun-build.cs`, 빠른 로컬 macOS 전용 즉석 실행기):
```bash
dotnet ./hun-build.cs
```
⚠️ `hun-build.cs`는 이 프로젝트가 `--dotnet` 옵션 없이 생성됐어도 **.NET SDK 10이 항상 필요**해 (스크립트 자체가 .NET file-based app이기 때문). .NET SDK가 없다면 `zig build run`을 사용해줘.

## 다음 단계

1. `src/Main.S` 의 주석 처리된 `bl` 호출 예시를 풀어서 실제로 라이브러리 함수를 호출해보기
2. `build.zig` 에서 사용하지 않는 언어 블록은 지우거나 필요에 맞게 조정하기
3. `constants/`, `data/`, `includes/`, `libs/` 폴더에 프로젝트 성격에 맞는 내용 채우기

---

좋은 마무리 챕터 컨셉이네, 크하하 — "동물원"이면 스코프도 딱 적당하고. 명령어부터 정리해줄게, 두 플랫폼 다.

## 1) macOS (Mach-O) — libSystem 심볼 목록

```bash
# C 표준 라이브러리 계열 (문자열, 메모리, stdio, 랜덤 등)
xcrun dyld_info -exports /usr/lib/system/libsystem_c.dylib

# 커널 시스템콜 계열 (open, read, mmap, kqueue 등)
xcrun dyld_info -exports /usr/lib/system/libsystem_kernel.dylib

# GCD (스레드풀 — dispatch_async 등)
xcrun dyld_info -exports /usr/lib/system/libdispatch.dylib

# 프레임워크(UI 등)도 캐시 안에서 그대로 조회 가능
xcrun dyld_info -exports /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
```

**주소 빼고 함수명만 깔끔하게 뽑기:**
```bash
xcrun dyld_info -exports /usr/lib/system/libsystem_c.dylib | awk '{print $2}' | sort
```

**특정 키워드로 검색 (예: 그래픽/윈도우 관련):**
```bash
xcrun dyld_info -exports /usr/lib/system/libsystem_c.dylib | grep -i window
```

## 2) Linux aarch64 ELF — glibc 심볼 목록

리눅스에선 macOS의 "우산" 개념이 없고 그냥 `.so` 파일이 디스크에 실체로 있어서 오히려 더 간단해.

```bash
# libc 실제 경로 먼저 확인 (배포판마다 다름)
ldconfig -p | grep libc.so

# 동적 심볼 테이블에서 정의된(구현된) 함수만 뽑기
nm -D --defined-only /lib/aarch64-linux-gnu/libc.so.6

# objdump로 봐도 동일 (nm이 안 될 때 대안)
objdump -T /lib/aarch64-linux-gnu/libc.so.6

# readelf 버전
readelf -Ws --dyn-syms /lib/aarch64-linux-gnu/libc.so.6
```

**함수명만 깔끔하게:**
```bash
nm -D --defined-only /lib/aarch64-linux-gnu/libc.so.6 | awk '{print $3}' | sort
```

**참고**: glibc 2.34부터 `libpthread`, `libdl`, `libutil`, `librt`가 전부 `libc.so.6` 하나로 흡수됐어. 그래서 리눅스에서는 스레드/dlopen 함수까지 이 한 파일에서 다 나올 거야.

## Apple Silicon이라 좋은 점 하나

너 M4 맥이니까, 리눅스 aarch64 환경을 **에뮬레이션 없이 네이티브 속도로** 바로 띄울 수 있어:

```bash
docker run --rm -it --platform linux/arm64 ubuntu:24.04 bash
```

컨테이너 안에서 `apt install binutils`하면 위 리눅스 명령어들을 바로 실전처럼 돌려볼 수 있어. Rosetta 에뮬레이션 없이 진짜 arm64 바이너리라 작성한 `.S` 코드도 그대로 크로스 검증 가능해.

## 마지막 챕터 설계 관련 팁 하나만 얹을게

"동물원/디즈니랜드"를 UI까지 어셈블리로 하려면, **macOS AppKit(Objective-C 메시징)과 Linux(X11/Wayland)는 구조가 완전히 달라서 같은 코드로 못 감당해**. 만약 "가볍게" 컨셉을 유지하면서 **양쪽 플랫폼에서 똑같은 로직으로** 돌리고 싶으면, **`ncurses`**(터미널 기반 그래픽)를 추천해 — C ABI 함수 몇 개(`initscr`, `mvaddch`, `refresh`, `getch`)만 알면 되고, macOS/Linux 둘 다 거의 동일한 API로 존재해서 Objective-C 메시징 같은 복잡한 계층 없이 바로 `bl` 호출로 끝나. 텍스트 기반 동물원 맵 정도면 딱 좋은 난이도일 것 같은데, 한번 검토해봐.
