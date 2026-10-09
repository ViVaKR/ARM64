//-----------------------------------------------------
// Bundle — Entry Point (src/Main.S)
// Target OS: macOS  (프로그램 시작 심볼: '_main')
// armcli init 으로 생성됨
//-----------------------------------------------------

// 🆕 [대제독의 권고] 무기고 인프라를 인클루드하여 FUNC_START_FULL 등을 즉시 사격해 보시게나!
.include "src/includes/hun.macros.inc"

.global _main
.align 2

_main:
    // --- Prologue ---
    stp     x29, x30, [sp, #-16]!  // Frame pointer, Link register 저장
    mov     x29, sp                // Frame pointer 설정

    // --- Main Logic ---
    // .NET(Native AOT, DotnetLibs) 기본 데모 호출 — armcli init --dotnet 으로 자동 활성화됨
        bl      _dotnet_hello

        
    // 예) Rust 라이브러리 함수 호출:
    //   bl      _rust_hello
    //
    // 예) 두 수의 합 구하기 (x0=3, x1=4 전달 후 x0으로 결과 수신):
    //   mov     x0, #3
    //   mov     x1, #4
    //   bl      _add_two_numbers
    
// 예) .NET(DotnetLibs)으로 두 수의 합 구하기 + 결과 출력까지 위임하기:
//   mov     x0, #5
//   mov     x1, #4
//   bl      _add_two_numbers_dotnet
//   mov     x19, x0                    // 결과 백업
//   mov     x0, x19
//   bl      _print_number_dotnet   // [.NET] 결과 값 → 9
    mov     x0, #0                 // Return value (0)

    // --- Epilogue ---
    ldp     x29, x30, [sp], #16    // Frame pointer, Link register 복원
    ret                            // Return