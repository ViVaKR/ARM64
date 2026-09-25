#!/usr/bin/env -S dotnet --
// =========================================================================
// 👑 [Hun-ASM] .NET Native AOT File-based 턱시도 오케스트레이터 (hun-build.cs)
// =========================================================================

#:property TargetFramework=net10.0
#:property PublishAot=true
#:property OptimizationPreference=Speed

using System.Diagnostics;

// hun-build.cs.template 상단(7번 라인 부근)에 추가
[assembly: System.Diagnostics.CodeAnalysis.SuppressMessage("Design", "CA1050:Declare types in namespaces", Justification = "Hun-ASM 단일 파일 기반 스크립트 턱시도 환경")]

Console.WriteLine("👑 [Hun-ASM] .NET Native AOT 턱시도 사격 통제 기어 가동! 👑");

// 🎯 [대제독의 특명: 신사다운 수색 관제] 1. 컴파일 레이어에서 철저히 제외할 블랙리스트 폴더 무기고 수립
var excludeFolders = new List<string> {
    "bin", "build", "obj", "artifacts", "assets", "node_modules", ".git", ".vscode"
};

// 1. 현재 작업 폴더 하위의 모든 .s 및 .S 어셈블리 소스 파일을 맹렬하게 제귀 수색!
var currentDir = Directory.GetCurrentDirectory();
var asmFiles = Directory.GetFiles(currentDir, "*.s", SearchOption.AllDirectories)
    .Concat(Directory.GetFiles(currentDir, "*.S", SearchOption.AllDirectories))
    // 🎯 [최첨단 턱시도 필터] 파일 경로의 각 폴더 세그먼트 중 블랙리스트에 걸리는 녀석이 단 하나도 없는지 전수 검사!
    .Where(f => !excludeFolders.ByAnySegmentMatch(f))
    .Select(f => Path.GetRelativePath(currentDir, f))
    .Distinct(StringComparer.OrdinalIgnoreCase) // 맥OS 대소문자 중복 파일 방어
    .ToList();

if (asmFiles.Count == 0)
{
    Console.WriteLine("🛑 어이 친구, 이 벌판엔 사격할 어셈블리 파일(.s)이 한 개도 없구만! 하하하.");
    return;
}

Console.WriteLine($"📍 발견된 명사수 파일 수: {asmFiles.Count}개");
foreach (var file in asmFiles)
{
    Console.WriteLine($"-> [편입] {file}");
}

// 2. _main 또는 main 진입점이 위치한 사령관 소스 파일명 동적 수색!
string targetBaseName = "hun-bin";
foreach (var file in asmFiles)
{
    try
    {
        string content = File.ReadAllText(file);
        if (content.Contains("_main:") || content.Contains("main:"))
        {
            targetBaseName = Path.GetFileNameWithoutExtension(file).ToLower();
            break;
        }
    }
    catch { }
}

// 3. 격리된 출력 디렉터리(bin/) 생성 및 주소 바인딩
string binDir = Path.Combine(currentDir, "bin");
if (!Directory.Exists(binDir))
{
    Directory.CreateDirectory(binDir);
}
string outputFile = Path.Combine("bin", targetBaseName);

// 4. 맥OS 시스템의 실제 SDK 주소를 실시간 동적 첩보 수색!
string sdkPath = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk";
try
{
    var psiSdk = new ProcessStartInfo("xcrun", "--show-sdk-path")
    {
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        UseShellExecute = false,
        CreateNoWindow = true
    };
    using var procSdk = Process.Start(psiSdk);
    string output = procSdk?.StandardOutput.ReadToEnd() ?? "";
    procSdk?.WaitForExit();
    if (procSdk?.ExitCode == 0 && !string.IsNullOrWhiteSpace(output))
    {
        sdkPath = output.Trim();
    }
}
catch { }

// =========================================================================
// 🎯 [대제독의 천하통일 집도] 5. Clang을 폐위하고 순수 as + ld 쾌속 격발 개시!
// =========================================================================
var buildStart = Stopwatch.StartNew();
List<string> objFiles = [];

Console.WriteLine("\n⚔️ 1단계: as(어셈블러) 정밀 개별 사격 개시...");
foreach (var srcFile in asmFiles)
{
    // 각 .s 파일에 대응하는 임시 .o 오브젝트 파일 경로 조립
    string objFile = Path.Combine(binDir, Path.GetFileNameWithoutExtension(srcFile) + ".o");
    objFiles.Add(objFile);

    // 🎯 [완벽 복구] as 형님에게 -g 옵션을 하사하여 순수 DWARF 디버그 심볼을 인코딩 내부에 완벽 주입!
    string asArgs = $"-arch arm64 -g -o \"{objFile}\" \"{srcFile}\"";

    var psiAs = new ProcessStartInfo("as", asArgs)
    {
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        UseShellExecute = false
    };

    using var procAs = Process.Start(psiAs);
    procAs?.WaitForExit();

    if (procAs?.ExitCode != 0)
    {
        Console.WriteLine($"❌ as 사격 실패! [{srcFile}] 문법 에러를 확인하게나:\n" + procAs?.StandardError.ReadToEnd());
        return;
    }
    Console.WriteLine($"  -> [오브젝트 탄생] {objFile}");
}

Console.WriteLine("\n⚔️ 2단계: ld(링커) 통합 통령 링킹 개시...");
// 맥OS 시스템 라이브러리(libSystem.B.dylib) 연동 패스 스위치 장착
string objectsClause = string.Join(" ", objFiles.Select(o => $"\"{o}\""));
string ldArgs = $"-arch arm64 -syslibroot \"{sdkPath}\" -lSystem -o \"{outputFile}\" {objectsClause}";

var psiLd = new ProcessStartInfo("ld", ldArgs)
{
    RedirectStandardOutput = true,
    RedirectStandardError = true,
    UseShellExecute = false
};

using var procLd = Process.Start(psiLd);
procLd?.WaitForExit();
buildStart.Stop();

if (procLd?.ExitCode != 0)
{
    Console.WriteLine("❌ ld 링킹 실패! 링크 에러를 확인하게나:\n" + procLd?.StandardError.ReadToEnd());
    return;
}

// 6. 🩹 후방 청소 작전: 링킹이 완벽하게 끝났으니 임시 .o 파일들은 은밀하게 소멸시킵니다.
foreach (var obj in objFiles)
{
    try { File.Delete(obj); } catch { }
}

Console.WriteLine($"✨ 사격 성공! 완벽한 디버그 기계어 바이너리 탄생함. ({buildStart.ElapsedMilliseconds}ms) -> ./{outputFile}");

// 7. 링킹 성공 즉시 다이렉트 쾌속 타격!
Console.WriteLine("\n⚡ 즉시 실행 타격 감행!\n------------------------------------------------");
var psiRun = new ProcessStartInfo(Path.Combine(".", outputFile)) { UseShellExecute = false };
using var procRun = Process.Start(psiRun);
procRun?.WaitForExit();
Console.WriteLine("------------------------------------------------\n🏁 작전 종료 완료!");


// =========================================================================
// 🛠️ 헬퍼 확장 메서드 구조체 (C# 파일 기반 앱의 최하단에 얹어두면 작동하네!)
// =========================================================================
public static class FolderFilterExtensions
{
    public static bool ByAnySegmentMatch(this List<string> excludes, string relativePath)
    {
        // 파일 경로를 폴더 단위로 정밀하게 쪼개서 (예: "src/assets/main.s" -> ["src", "assets", "main.s"])
        var segments = relativePath.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        // 쪼개진 이름 중에 제외 폴더 목록에 들어있는 녀석이 하나라도 있는지 영리하게 판별하네!
        return segments.Any(seg => excludes.Contains(seg, StringComparer.OrdinalIgnoreCase));
    }
}
