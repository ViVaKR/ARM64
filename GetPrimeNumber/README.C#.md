# 소수 구하기

## 소스코드

```csharp
    /// <summary>
    /// 소수 구하기
    /// 1보다 큰 자연수 중 1과 자기 자진만을 약수로 가지는 수
    /// </summary>
    /// <param name="number">최대 수</param>
    public static void GetPrimeNumber(this int number)
    {
        WriteLine($"2 ~ {number} 소수 (에라토스테네스의 체)");
        var isPrime = new bool[number + 1];
        isPrime[0] = false;
        isPrime[1] = false;
        Array.Fill(isPrime, true);
        // 어떤수 i 가 소수가 아니라면, i = a x b 형태로 곱해짐
        // 이때 a와 b 둘 중 하나는 반드시√i 이하
        // (ex: 36의 약수 쌍 -> 1 * 36, 2 * 8, 3 * 12, 4 * 9, 6 * 6)
        for (int i = 2; i * i <= number; i++)
        {
            if (isPrime[i])
            {
                // i 의 배수들을 싹 다 소수에서 적출
                for (int j = i * i; j <= i; j += i)
                {
                    isPrime[j] = false;
                }
            }
        }
        for (var i = 2; i <= number; i++)
            if (isPrime[i]) Console.WriteLine($"소수: {i}");
    }
```
