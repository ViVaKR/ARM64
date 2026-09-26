const std = @import("std");

// GenerateJwtKey — Zig 오케스트레이터
// 어셈블리(src/Main.S)를 뼈대로 삼고, 필요한 언어별 라이브러리를 빌드해 링크한다.
// (armcli init 으로 생성됨 — zig 0.16 기준, 다른 버전에서는 API가 다를 수 있으니 확인해줘)

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "GenerateJwtKey",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    // --- 어셈블리 진입점 (src/Main.S) ---
    exe.root_module.addCSourceFile(.{
        .file = b.path("src/Main.S"),
        .flags = &.{},
    });
    exe.root_module.link_libc = true;

    // --- Rust 라이브러리 (app/RustLibs/rust_core) ---
    const rust_build = b.addSystemCommand(&.{
        "cargo",
        "build",
        "--release",
        "--manifest-path",
        "app/RustLibs/rust_core/Cargo.toml",
    });
    exe.step.dependOn(&rust_build.step);
    exe.root_module.addObjectFile(b.path("app/RustLibs/rust_core/target/release/librust_core.a"));
    // --- Go 라이브러리 (app/GoLibs) — c-archive 정적 라이브러리로 빌드 ---
    // NOTE: go build 는 cwd 기준으로 go.mod 를 찾으므로, app/GoLibs 안에서 실행해야 한다.
    const go_out_dir = "app/GoLibs/out";
    const go_build = b.addSystemCommand(&.{
        "go",
        "build",
        "-buildmode=c-archive",
        "-o",
        "out/libgolibs.a",
        ".",
        });
    go_build.setCwd(b.path("app/GoLibs"));
    exe.step.dependOn(&go_build.step);
    exe.root_module.addObjectFile(b.path(go_out_dir ++ "/libgolibs.a"));
    // --- .NET Native AOT 라이브러리 (app/DotnetLibs) ---
    // NOTE: 대상 RID(osx-arm64/linux-arm64)에 맞춰 게시 경로가 달라진다.
    //       파일명(DotnetLibs.dylib)이 실제 publish 결과와 다르면 여기만 고쳐주면 된다.
    const dotnet_build = b.addSystemCommand(&.{
        "dotnet",
        "publish",
        "app/DotnetLibs/DotnetLibs.csproj",
        "-c",
        "Release",
        "-r",
        "osx-arm64",
    });

    const dotnet_publish_dir = "app/DotnetLibs/bin/Release/net10.0/osx-arm64/publish";
    const dotnet_lib_path = b.path(dotnet_publish_dir ++ "/DotnetLibs.dylib");

    const dotnet_fix_install_name = b.addSystemCommand(&.{
        "install_name_tool", "-id", "@rpath/DotnetLibs.dylib", "DotnetLibs.dylib",
    });
    dotnet_fix_install_name.setCwd(b.path(dotnet_publish_dir));
    dotnet_fix_install_name.step.dependOn(&dotnet_build.step);
    exe.step.dependOn(&dotnet_fix_install_name.step);
    exe.root_module.addObjectFile(dotnet_lib_path);
    // 실행 파일과 같은 폴더(zig-out/bin)에서 라이브러리를 찾도록 rpath 토큰 등록
    exe.root_module.addRPathSpecial("@executable_path");

    // 설치 시 dylib/so 를 실행 파일과 같은 폴더로 복사 (위 rpath는 실행 파일 기준 상대경로라 필수)
    const install_dotnet_lib = b.addInstallFileWithDir(dotnet_lib_path, .bin, "DotnetLibs.dylib");
    install_dotnet_lib.step.dependOn(&dotnet_fix_install_name.step);
    b.getInstallStep().dependOn(&install_dotnet_lib.step);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "GenerateJwtKey 실행");
    run_step.dependOn(&run_cmd.step);
}