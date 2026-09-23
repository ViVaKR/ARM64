# ARM64

### 확장자 대문자 .S vs 소문자 .s

- 소문자 .s일 때: C 스타일 #include "macros.inc"를 쓰면 문법 에러가 납니다. 오직 GAS 스타일인 .include "macros.inc"만 먹힙니다.
- 대문자 .S일 때: Clang이 알아서 C 전처리기를 먼저 돌려주므로, 우리가 아는 익숙한 #include "macros.inc"가 완벽하게 작동합니다. (가급적 대문자 .S를 추천합니다!)

### XCode 세팅

1. Xcode 프로젝트 창 맨 위 좌측의 프로젝트 이름을 클릭합니다.
2. 가운데 화면에서 TARGETS의 내 프로그램(예: arm)을 선택합니다.
3. 상단 탭에서 [Build Settings]로 들어갑니다.
4. 우측 상단 검색창에 Header Search Paths를 검색합니다. (어셈블리 인클루드 경로도 여기서 처리합니다.)
5. Header Search Paths 항목을 더블클릭하고 + 버튼을 눌러 내 include 폴더 경로를 등록합니다.

💡 팁: 하드코딩 경로 대신 $(SRCROOT)/include 라고 적어주면 프로젝트 폴더 내부의 include 폴더를 자동으로 가리킵니다.

```text
arm (최상위 루트 폴더 - 프로젝트 .xcodeproj 파일이 있는 곳)
└── realmanmastery (실제 내 소스코드가 노는 메인 공간)
    ├── RealManMastery.S (메인 엔트리 어셈블리 파일)
    └── src
        ├── libs (외부 라이브러리나 묵직한 어셈블리 소스 모음)
        └── includes (우리가 만든 만능 매크로.inc 모음)
```


### zig 오케스트레이터 (build.zig)


```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    // 1. 타겟 및 최적화 설정 (M4 Apple Silicon 기본 타겟팅)
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 2. 실행 파일(프로그램) 정의
    const exe = b.addExecutable(.{
        .name = "realmanmastery_app",
        .target = target,
        .optimize = optimize,
    });

    // 3. 메인 엔트리 어셈블리 파일 등록 (.S 대문자 필수!)
    exe.addCSourceFile(.{
        .file = b.path("realmanmastery/RealManMastery.S"),
        .flags = &.{ "-Wall", "-Wextra" }, // Clang 컴파일러 옵션
    });

    // 4. ⭐ [핵심] 우리가 만든 includes와 libs 폴더 경로를 주입!
    exe.addIncludePath(b.path("realmanmastery/src/includes"));
    exe.addIncludePath(b.path("realmanmastery/src/libs"));

    // 5. C 표준 라이브러리 연동 (printf 같은 거 쓸 때 필요)
    exe.linkLibC();

    // 6. 빌드 결과물 방출 설정
    b.installArtifact(exe);
}

```


```bash
# 1. 빌드하기 (컴파일 수행)
zig build

# 2. 빌드와 동시에 실행까지 한 번에 하기 (C#의 F5 느낌!)
zig build run
``` 
