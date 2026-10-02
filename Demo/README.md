# Demo

`armcli init` 으로 생성된 프로젝트. Zig(`build.zig`)가 오케스트레이터 역할을 하며,
어셈블리 진입점(`src/Main.S`)에서 각 언어 라이브러리의 함수를 `bl` 로 호출하는 구조.

## 구성

- **Rust** — `app/RustLibs/rust_core` (staticlib, `add_two_numbers`, `rust_hello`)
- **Go** — `app/GoLibs` (c-archive, `add_two_numbers_go`, `go_hello`)
- **.NET (Native AOT)** — `app/DotnetLibs` (`add_two_numbers_dotnet`, `print_number_dotnet`, `dotnet_hello`)

## 디렉토리

```
Demo/
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
- **PowerShell 7** — ./hun-build.ps1 실행에 필요

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