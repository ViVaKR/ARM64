#!/usr/bin/env -S dotnet --
// =========================================================================
// 👑 [Hun-ASM] .NET Native AOT File-based 턱시도 오케스트레이터 (hun-build.cs)
// =========================================================================
#:property TargetFramework=net10.0
#:property PublishAot=true
#:property OptimizationPreference=Speed

using System.Diagnostics;

[assembly: System.Diagnostics.CodeAnalysis.SuppressMessage("Design", "CA1050:Declare types in namespaces", Justification = "Hun-ASM 단일 파일 기반 스크립트 턱시도 환경")]

Console.WriteLine("👑 [Hun-ASM] .NET Native AOT 턱시도 사격 통제 기어 가동! 👑");

var excludeFolders = new List<string> {
"bin", "build", "obj", "artifacts", "assets", "node_modules", ".git", ".vscode"
};

var currentDir = Directory.GetCurrentDirectory();
var asmFiles = Directory.GetFiles(currentDir, "*.s", SearchOption.AllDirectories)
    .Concat(Directory.GetFiles(currentDir, "*.S", SearchOption.AllDirectories))
    .Select(f => Path.GetRelativePath(currentDir, f))
    .Where(f => !excludeFolders.ByAnySegmentMatch(f))
    .Distinct(StringComparer.OrdinalIgnoreCase) // 맥OS 대소문자 중복 파일 방어 장갑
    .ToList();

if (asmFiles.Count == 0)
{
    Console.WriteLine("🛑 어이 친구, 이 벌판엔 사격할 어셈블리 파일(.s)이 한 개도 없구만! 하하하.");
    return;
}

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

string binDir = Path.Combine(currentDir, "bin");
if (!Directory.Exists(binDir)) Directory.CreateDirectory(binDir);
string outputFile = Path.Combine("bin", targetBaseName);

// 🆕 0단계-A: Rust(rust_core) 무장 준비 (있으면 자동으로 함께 사격!)
string? rustLib = null;
string rustManifest = Path.Combine(currentDir, "app", "RustLibs", "rust_core", "Cargo.toml");
if (File.Exists(rustManifest))
{
    Console.WriteLine("\n👑 0단계-A: Rust(rust_core) 무장 준비...");
    var psiCargo = new ProcessStartInfo(
        "cargo",
        $"build --release --manifest-path \"{rustManifest}\"")
    { UseShellExecute = false };
    using var procCargo = Process.Start(psiCargo);
    procCargo?.WaitForExit();

    string srcRustLib = Path.Combine(currentDir, "app", "RustLibs", "rust_core", "target", "release", "librust_core.a");
    if (File.Exists(srcRustLib))
    {
        rustLib = srcRustLib;
        Console.WriteLine($"    ✅ Rust 무장 완료: {rustLib}");
    }
    else
    {
        Console.WriteLine("    ⚠️ librust_core.a 를 못 찾았네. cargo build 로그를 확인해줘.");
    }
}

// 🆕 0단계-B: Go(GoLibs) 무장 준비 (있으면 자동으로 함께 사격!)
string? goLib = null;
string goMod = Path.Combine(currentDir, "app", "GoLibs", "go.mod");
if (File.Exists(goMod))
{
    Console.WriteLine("\n👑 0단계-B: Go(GoLibs) 무장 준비...");
    string goLibsDir = Path.Combine(currentDir, "app", "GoLibs");
    string goOutDir = Path.Combine(goLibsDir, "out");
    if (!Directory.Exists(goOutDir)) Directory.CreateDirectory(goOutDir);

    var psiGo = new ProcessStartInfo("go", "build -buildmode=c-archive -o out/libgolibs.a .")
    {
        UseShellExecute = false,
        WorkingDirectory = goLibsDir
    };
    using var procGo = Process.Start(psiGo);
    procGo?.WaitForExit();

    string srcGoLib = Path.Combine(goOutDir, "libgolibs.a");
    if (File.Exists(srcGoLib))
    {
        goLib = srcGoLib;
        Console.WriteLine($"    ✅ Go 무장 완료: {goLib}");
    }
    else
    {
        Console.WriteLine("    ⚠️ libgolibs.a 를 못 찾았네. go build 로그를 확인해줘.");
    }
}

// 🆕 0단계-C: .NET Native AOT(DotnetLibs) 사전 정찰 및 무장 준비 (있으면 자동으로 함께 사격!)
string? dotnetDylib = null;
string dotnetProj = Path.Combine(currentDir, "app", "DotnetLibs", "DotnetLibs.csproj");
if (File.Exists(dotnetProj))
{
    Console.WriteLine("\n👑 0단계-C: .NET Native AOT(DotnetLibs) 사전 정찰 및 무장 준비...");
    var psiDotnet = new ProcessStartInfo("dotnet", $"publish \"{dotnetProj}\" -c Release -r osx-arm64")
    {
        UseShellExecute = false
    };
    using var procDotnet = Process.Start(psiDotnet);
    procDotnet?.WaitForExit();

    string publishDir = Path.Combine(currentDir, "app", "DotnetLibs", "bin", "Release", "net10.0", "osx-arm64", "publish");
    string srcDylib = Path.Combine(publishDir, "DotnetLibs.dylib");

    if (File.Exists(srcDylib))
    {
        dotnetDylib = Path.Combine(binDir, "DotnetLibs.dylib");
        File.Copy(srcDylib, dotnetDylib, true);

        // 실행 파일과 같은 폴더(bin/)에서 찾도록 install name을 @rpath 기준으로 재설정
        var psiInstallName = new ProcessStartInfo(
            "install_name_tool",
            $"-id @rpath/DotnetLibs.dylib \"{dotnetDylib}\"")
        { UseShellExecute = false };
        using var procInstallName = Process.Start(psiInstallName);
        procInstallName?.WaitForExit();

        Console.WriteLine($"    ✅ .NET 무장 완료: {dotnetDylib}");
    }
    else
    {
        Console.WriteLine("    ⚠️ DotnetLibs.dylib를 못 찾았네. .csproj에 <NativeLib>Shared</NativeLib> 설정이 있는지 확인해줘!");
    }
}

string sdkPath = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk";
try
{
    var psiSdk = new ProcessStartInfo("xcrun", "--show-sdk-path") { RedirectStandardOutput = true, UseShellExecute = false, CreateNoWindow = true };
    using var procSdk = Process.Start(psiSdk);
    string output = procSdk?.StandardOutput.ReadToEnd() ?? "";
    procSdk?.WaitForExit();
    if (procSdk?.ExitCode == 0 && !string.IsNullOrWhiteSpace(output)) sdkPath = output.Trim();
}
catch { }

var buildStart = Stopwatch.StartNew();
List<string> objFiles = new List<string>();

Console.WriteLine("\n⚔️ 1단계: as(어셈블러) 정밀 개별 사격 개시...");
foreach (var srcFile in asmFiles)
{
    string objFile = Path.Combine(binDir, Path.GetFileNameWithoutExtension(srcFile) + ".o");
    objFiles.Add(objFile);
    string asArgs = $"-arch arm64 -g -o \"{objFile}\" \"{srcFile}\"";
    var psiAs = new ProcessStartInfo("as", asArgs) { UseShellExecute = false };
    using var procAs = Process.Start(psiAs);
    procAs?.WaitForExit();
}

Console.WriteLine("\n⚔️ 2단계: ld(링커) 통합 통령 링킹 개시...");
string objectsClause = string.Join(" ", objFiles.Select(o => $"\"{o}\""));
string ldArgs = $"-arch arm64 -syslibroot \"{sdkPath}\" -lSystem -o \"{outputFile}\" {objectsClause}";
if (rustLib != null)
{
    // Rust 정적 라이브러리(.a) — 별도 rpath 필요 없이 그냥 오브젝트처럼 편입
    ldArgs += $" \"{rustLib}\"";
}
if (goLib != null)
{
    // Go 정적 라이브러리(.a, c-archive) — 이것도 마찬가지로 그냥 편입
    ldArgs += $" \"{goLib}\"";
}
if (dotnetDylib != null)
{
    // .NET 무기(dylib)를 링크 목록에 편입 + 실행 파일과 같은 폴더에서 찾도록 rpath 등록
    ldArgs += $" \"{dotnetDylib}\" -rpath @executable_path";
}
var psiLd = new ProcessStartInfo("ld", ldArgs) { UseShellExecute = false };
using var procLd = Process.Start(psiLd);
procLd?.WaitForExit();
buildStart.Stop();

foreach (var obj in objFiles) { try { File.Delete(obj); } catch { } }
Console.WriteLine($"✨ 사격 성공! 완벽한 디버그 기계어 바이너리 탄생함. ({buildStart.ElapsedMilliseconds}ms) -> ./{outputFile}");

Console.WriteLine("\n⚡ 즉시 실행 타격 감행!\n------------------------------------------------");
var psiRun = new ProcessStartInfo(Path.Combine(".", outputFile)) { UseShellExecute = false };
using var procRun = Process.Start(psiRun);
procRun?.WaitForExit();
Console.WriteLine("------------------------------------------------\n🏁 작전 종료 완료!");

public static class FolderFilterExtensions
{
    public static bool ByAnySegmentMatch(this List<string> excludes, string relativePath)
    {
        var segments = relativePath.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        return segments.Any(seg => excludes.Contains(seg, StringComparer.OrdinalIgnoreCase));
    }
}
