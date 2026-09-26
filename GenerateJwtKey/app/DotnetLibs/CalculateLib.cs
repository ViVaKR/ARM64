using System.Runtime.InteropServices;

namespace DotnetLibs;

public static class CalculateLib
{
    /// <summary>
    /// 두 정수를 더한 합계를 반환한다. (ARM64 호출 규약: x0=a, x1=b, 반환값=x0)
    /// </summary>
    [UnmanagedCallersOnly(EntryPoint = "add_two_numbers_dotnet")]
    public static long AddTwoNumbers(long a, long b) => a + b;

    /// <summary>
    /// 정수 하나를 받아 .NET Console로 출력한다. (ARM64 호출 규약: x0=n, 반환값 없음)
    /// UnmanagedCallersOnly 경계를 넘는 메서드는 예외를 밖으로 던지면 안 되므로 반드시 try/catch로 감싼다.
    /// </summary>
    [UnmanagedCallersOnly(EntryPoint = "print_number_dotnet", CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
    public static void PrintNumber(long n)
    {
        try
        {
            Console.WriteLine($"[.NET] 결과 값 → {n}");
            Console.Out.Flush(); // 다른 런타임(Rust/어셈블리)의 출력과 순서가 엇갈리지 않도록 즉시 플러시
        }
        catch
        {
            // UnmanagedCallersOnly 경계 밖으로 예외가 새어나가면 크래시로 이어지므로 절대 던지지 않는다.
        }
    }
}
