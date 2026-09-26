# C# 코드

```csharp
using System.Security.Cryptography;
using System.Text;

Console.WriteLine("=== HMAC-SHA512 JWT Secret Key 생성기 ===\n");

// 129자 안전한 키 생성
var secretKey = GenerateSafeJwtKey(129);

Console.WriteLine("생성된 키:");
Console.WriteLine(secretKey);
Console.WriteLine($"\n길이: {secretKey.Length}자");
Console.WriteLine($"바이트: {Encoding.UTF8.GetByteCount(secretKey)}바이트");
Console.WriteLine($"비트: {Encoding.UTF8.GetByteCount(secretKey) * 8}비트");

// 검증
Console.WriteLine("\n검증:");
Console.WriteLine($"하이픈(-) 포함: {(secretKey.Contains('-') ? "있음 ❌" : "없음 ✅")}");
Console.WriteLine($"언더스코어(_) 포함: {(secretKey.Contains('_') ? "있음 ❌" : "없음 ✅")}");
Console.WriteLine($"안전한 문자만 사용: ✅");
/// <summary>
/// HMAC-SHA512용 안전한 JWT Secret Key 생성
/// 영문 대소문자 + 숫자만 사용 (-, _ 제외)
/// </summary>
/// <param name="length">키 길이 (권장: 129자)</param>
/// <returns>안전한 Secret Key</returns>
static string GenerateSafeJwtKey(int length = 129)
{
    // 안전한 문자 집합 (-, _ 제외)
    const string safeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    Console.WriteLine($"=> {safeChars.Length}");
    var result = new StringBuilder(length);
    var randomBytes = new byte[length];

    using (var rng = RandomNumberGenerator.Create())
    {
        rng.GetBytes(randomBytes);
    }

    foreach (var b in randomBytes)
    {
        result.Append(safeChars[b % safeChars.Length]);
    }

    return result.ToString();
}
```
