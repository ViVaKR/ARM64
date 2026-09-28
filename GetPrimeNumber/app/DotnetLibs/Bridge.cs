using System.Runtime.InteropServices;

namespace DotnetLibs;

public static class Bridge
{
    [UnmanagedCallersOnly(EntryPoint = "get_prime_numbers")]
    public static void GetPrimeNumbers()
    {
        Console.WriteLine("소수 구하기 / Get Prime Numbers");
    }

    [UnmanagedCallersOnly(EntryPoint = "input_number")]
    public static long InputNumber()
    {

        Console.Write("소수를 구할 숫자 하나를 입력 하세요: ");
        var tf = long.TryParse(Console.ReadLine(), out long input);

        if (tf)
        {
            return input;
        }
        return 2;
    }
}
