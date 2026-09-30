#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "👑 [Hun-ASM] PowerShell 턱시도 사격 통제 기어 가동! 👑" -ForegroundColor Cyan

$currentDir = Get-Location
$exclude = @("bin", "build", "obj", "artifacts", "assets", "node_modules", ".git", ".vscode")

# 1. 어셈블리 파일 탐색 (디렉터리 필터링)
$asmFiles = Get-ChildItem -Path . -Include *.s, *.S -Recurse | Where-Object {
  $rel = Resolve-Path -Relative $_.FullName
  -not ($exclude | Where-Object { $rel -split '[/\\]' -contains $_ })
}

if (-not $asmFiles) {
  Write-Warning "🛑 어이 친구, 이 벌판엔 사격할 어셈블리 파일(.s)이 한 개도 없구만! 하하하."
  exit 1
}

# 2. 메인 진입점 파일 감지
$targetBaseName = "hun-bin"
foreach ($file in $asmFiles) {
  if (Select-String -Path $file.FullName -Pattern "^\s*_?main\s*:" -Quiet) {
    $targetBaseName = $file.BaseName.ToLower()
    break
  }
}

$binDir = Join-Path $currentDir "bin"
if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }
$outputFile = Join-Path "bin" $targetBaseName

# 3. 다국적 연합군 빌드 (Rust / Go / .NET AOT)
$extraLibs = @()

# Rust
$rustManifest = "app/RustLibs/rust_core/Cargo.toml"
if (Test-Path $rustManifest) {
  Write-Host "👑 0단계-A: Rust 무장..." -ForegroundColor Yellow
  cargo build --release --manifest-path $rustManifest
  $extraLibs += "app/RustLibs/rust_core/target/release/librust_core.a"
}

# Go
if (Test-Path "app/GoLibs/go.mod") {
  Write-Host "👑 0단계-B: Go 무장..." -ForegroundColor Yellow
  Push-Location "app/GoLibs"
  go build -buildmode=c-archive -o out/libgolibs.a .
  Pop-Location
  $extraLibs += "app/GoLibs/out/libgolibs.a"
}

# .NET AOT Dylib
$dotnetProj = "app/DotnetLibs/DotnetLibs.csproj"
if (Test-Path $dotnetProj) {
  Write-Host "👑 0단계-C: .NET AOT 무장..." -ForegroundColor Yellow
  dotnet publish $dotnetProj -c Release -r osx-arm64
  $srcDylib = "app/DotnetLibs/bin/Release/net10.0/osx-arm64/publish/DotnetLibs.dylib"
  $targetDylib = "$binDir/DotnetLibs.dylib"
  Copy-Item $srcDylib $targetDylib -Force
  install_name_tool -id @rpath/DotnetLibs.dylib $targetDylib
  $extraLibs += "$targetDylib"
  # 변경 (배열로 쪼개기):
  # $rpathFlag = "-rpath @executable_path"
  $rpathFlag = @("-rpath", "@executable_path")
}

# 4. macOS SDK 경로 확보
$sdkPath = (xcrun --show-sdk-path).Trim()

# 5. as 개별 사격 및 ld 통합 링킹
$objFiles = @()
foreach ($src in $asmFiles) {
  $obj = Join-Path $binDir ($src.BaseName + ".o")
  $objFiles += $obj
  as -arch arm64 -g -o $obj $src.FullName
}

Write-Host "⚔️ ld 통합 링킹 개시..." -ForegroundColor Green
ld -arch arm64 -syslibroot $sdkPath -lSystem -o $outputFile $objFiles $extraLibs $rpathFlag

# 정리 및 즉시 실행 타격
$objFiles | Remove-Item -Force
Write-Host "✨ 사격 성공! 타격 감행 -> $outputFile" -ForegroundColor Cyan
& "./$outputFile"
