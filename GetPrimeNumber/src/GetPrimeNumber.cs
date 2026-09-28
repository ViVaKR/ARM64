#!/usr/bin/env dotnet
// GetPrimeNumber.cs
// 실행 예)
//   dotnet run GetPrimeNumber.cs -- 100
//   dotnet GetPrimeNumber.cs 100              (숏핸드 문법)
//   chmod +x GetPrimeNumber.cs && ./GetPrimeNumber.cs 100

if (args.Length == 0 || !int.TryParse(args[0], out int number) || number < 2)
{
  Console.WriteLine("사용법: dotnet run GetPrimeNumber.cs -- <2 이상 정수>");
  return;
}

number.GetPrimeNumberFast();

static class PrimeExtensions
{
  public static void GetPrimeNumberFast(this int number)
  {
    Console.WriteLine($"2 ~ {number} 소수 (에라토스테네스의 체)");

    // bool 배열 생성 (기본값 false)
    bool[] isPrime = new bool[number + 1];
    Array.Fill(isPrime, true); // 일단 전체를 소수로 가정

    isPrime[0] = false;
    isPrime[1] = false;

    for (int i = 2; i * i <= number; i++)
    {
      if (isPrime[i])
      {
        // i의 배수들을 싹 다 소수에서 적출!
        for (int j = i * i; j <= number; j += i)
        {
          isPrime[j] = false;
        }
      }
    }

    // 소수만 출력
    for (int i = 2; i <= number; i++)
    {
      if (isPrime[i]) Console.WriteLine($"소수 : {i}");
    }
  }
}


/*

## 에라토스 테네스 채

```csharp
for (int i = 2; i * i <= number; i++)      // 바깥 루프: "지우는 도구" 역할을 할 후보 i
{
    if (isPrime[i])                         // i 자신이 아직 안 지워진 소수일 때만 작동
    {
        for (int j = i * i; j <= number; j += i)  // 안쪽 루프: i의 배수를 지운다
        {
            isPrime[j] = false;
        }
    }
}
```

**바깥 루프 `for (i = 2; i*i <= number; i++)` — "지우개" 역할을 할 숫자를 하나씩 꺼냄**

`i`는 "이제부터 이 숫자의 배수를 전부 지울 거야"라는 지우개 역할을 합니다. `number = 30`이면 `i*i <= 30`을 만족하는 `i`는 2, 3, 4, 5까지만 돌고 (6*6=36 > 30 이므로 거기서 멈춤) — 이게 바로 지난번에 설명드린 √n 얘기입니다.

**`if (isPrime[i])` — 이미 지워진 숫자는 지우개로 안 씀**

`i = 4`일 때가 좋은 예입니다. 4는 `i = 2` 차례에서 이미 `isPrime[4] = false`로 지워진 상태입니다(그림에서 파란색). 그러니까 `i = 4`가 왔을 때 `if (isPrime[4])`는 거짓이 되어서, 안쪽 루프를 아예 건너뜁니다. 왜 이게 맞는 동작이냐면 — 4의 배수(8, 12, 16, 20, 24, 28...)는 전부 2의 배수이기도 해서, 이미 `i=2` 차례에 다 지워졌기 때문에 또 지울 필요가 없는 거죠. 이 한 줄이 없으면 같은 숫자를 여러 번 헛돌면서 지우는 중복 작업이 생깁니다.

**안쪽 루프 `for (j = i*i; j <= number; j += i)` — 진짜로 지우는 부분**

- `j = i*i`부터 시작하는 이유: `2i, 3i, ..., (i-1)i`처럼 더 작은 숫자들의 배수는 `i` 차례가 오기 전에 이미 다 지워져 있습니다. 그러니 아직 아무도 안 건드린 `i*i`부터 시작하면 됩니다.
- `j += i`: `i`를 계속 더해가면서 그 배수들만 콕콕 집어서 `false`로 만듭니다.

**`number = 30`으로 실제로 따라가 보면**

| i | isPrime[i]? | 지우는 범위 (j = i*i, i*2, i*3...) | 실제로 지워진 것 |
|---|---|---|---|
| 2 | true | 4, 6, 8, 10, ..., 30 | 4,6,8,10,12,14,16,18,20,22,24,26,28,30 |
| 3 | true | 9, 12, 15, ..., 30 | 9,15,21,27 (12,18,24,30은 이미 지워짐) |
| 4 | **false** | — | 건너뜀 (이미 2가 다 처리함) |
| 5 | true | 25, 30 | 25 (30은 이미 지워짐) |

`i = 6`이 되기 전에 `i*i = 36 > 30`이라 루프가 끝나고, 그 결과 지워지지 않고 살아남은 숫자들 — 2, 3, 5, 7, 11, 13, 17, 19, 23, 29(그림에서 초록색)가 바로 소수입니다.

**한 문장으로 요약하면**: 바깥 루프는 "누구를 지우개로 쓸지" 고르고, `if (isPrime[i])`는 "이미 무뎌진 지우개는 다시 안 씀"이라는 최적화이며, 안쪽 루프는 "그 지우개로 아직 안 지운 배수들만 콕콕 지우는" 작업입니다. 이 세 줄이 합쳐져서 2부터 n까지의 합성수를 딱 한 번씩만(중복 없이) 효율적으로 걸러내는 게 에라토스테네스의 체의 핵심이라네.

 */
