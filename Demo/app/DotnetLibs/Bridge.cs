using System.Runtime.InteropServices;

namespace DotnetLibs;

public static class Bridge
{
    [UnmanagedCallersOnly(EntryPoint = "dotnet_hello")]
    public static void Hello()
    {
        Console.WriteLine("Hello from .NET (DotnetLibs)!");
    }
}