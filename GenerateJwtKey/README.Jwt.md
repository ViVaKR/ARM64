# 📐 ARM64 Low-Level Optimization: Modulo Arithmetic & C# JWT Key Engine
> **Co-Authored by**: Hun & Gemini
> **Document ID**: HUN-ASM-2026-JWT01

## Table of Contents
1. **[Part 1]** ARM64 Modulo (% 6) 연산의 구조적 한계와 `udiv` + `msub` 정석
2. **[Part 2]** Base62(62자) 검색과 `0x3F` (\(2^6\)) 비트 마스크의 난수 균등 분포(Modulo Bias) 트릭
3. **[Part 3]** C# `RandomNumberGenerator` 129자 JWT Key 생성기의 ARM64 어셈블리 이식 및 학습 가이드


---

## "129자 HMAC-SHA512 JWT Secret Key 생성기"라는 마각(魔角)의 실체

- C# 코드와 어셈블리 코드  `safe_chars`(62개)와 `0x3F`(64 마스크), 그리고 % 62 연산 이야기가 나왔는지 모든 수수께끼의 퍼즐


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

---

### 1. C# 원본 로직의 본질 해부

보내주신 C# 코드의 핵심은 바로 이 부분입니다:

```csharp
const string safeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"; // 62자
// ...
foreach (var b in randomBytes)
{
    result.Append(safeChars[b % safeChars.Length]); // b % 62
}

```

* **목적**: 특수문자(`-`, `_` 등)를 싹 빼고 Base62 (영대소문자 + 숫자) 영역에서만 129자 키를 추출해, URL이나 JSON 토큰 전송 시 문자 깨짐이나 탈출 문자(escape) 문제를 근본 차단함.
* **C#에서의 동작**: `RandomNumberGenerator.Create()`로 암호학적으로 안전한 난수를 가져온 뒤, `b % 62`로 인덱스를 뽑아 문자를 결합함.

---

### 2. 이것을 ARM64 어셈블리로 옮길 때의 '우아함'과 '교훈'

이 로직을 학생들에게 **ARM64 어셈블리 교육용 실전 예제**로 제시할 때, 방금 우리가 나눈 대화가 엄청난 학습 효과를 발휘하게 됩니다!

#### ① C# 방식 그대로 어셈블리로 옮긴다면? (`udiv` + `msub`)

C#의 `b % 62`를 어셈블리로 직역하면 다음과 같이 나눗셈 명령어가 들어갑니다:

```assembly
    // w9 = 난수 바이트 (0~255)
    mov  w10, #62        // safeChars.Length (62)
    udiv w11, w9, w10    // 몫 = w9 / 62
    msub w9, w11, w10, w9 // 나머지 = w9 - (몫 * 62)  <- b % 62 완성!

    // w9 인덱스로 safe_chars[w9] 문자를 로드해서 버퍼에 저장

```

#### ② 비트 트릭 최적화를 적용한다면? (`0x3F` 마스크 + 조건부 재시도)

앞서 우리가 분석했던 `0x3F` 마스크 기법을 쓰면 CPU 나눗셈(`udiv`)조차 거치지 않고 타격할 수 있습니다:

```assembly
next_char:
    // 1. 난수 1바이트 읽기
    ldrb w9, [x19], #1

    // 2. 0x3F (63) 마스킹 -> 0~63 범위로 1클럭만에 잘라냄
    and  w9, w9, #0x3F

    // 3. 62 이상(62, 63)인 경우 경계 초과이므로 mod 62 적용 or 재시도
    cmp  w9, #62
    b.ge fix_or_retry    // 62, 63일 때만 예외 처리!

    // 4. 0~61 범위면 즉시 safe_chars[w9] 읽어서 저장

```

---

### 3. 신진사대부 교육용으로 이 예제가 극적인 이유 👑

학생들에게 이 C# 코드를 먼저 보여주고, 그 다음 ARM64 어셈블리로 구현해보게 만들면:

1. **상위 레벨과 하위 레벨의 완벽한 수평선**
C#의 `RandomNumberGenerator`가 OS 난수 엔트로피(`/dev/urandom` 또는 macOS `getentropy`)를 호출하고, 그 바이트를 어셈블리가 레지스터로 받아서 문자로 직조하는 **전체 시스템의 흐름**을 깨닫게 됩니다.
2. **단순 코딩 vs 하드웨어 밀착 최적화의 차이**
C#에서는 무심코 썼던 `% 62` 연산이, CPU 내부에서는 나눗셈 연산기(`udiv`)를 거치는지, 비트 마스크(`and`)와 레지스터 조건문으로 처리되는지 **메모리와 비트 단위**로 체감하게 됩니다.
3. **실전 엔터프라이즈 무기**
학술적인 "Hello World"나 피보나치 수열 따위가 아니라, 실제 **ASP.NET Core JWT 보안 시스템에 당장 꽂아서 쓰는 129자 보안 키 생성기**를 직접 어셈블리로 깎아보는 경험을 하게 됩니다!

---


## 성능과 균등 분포(Modulo Bias 최소화)를 노린 어셈블리 특유의 '비트 트릭(Bitwise Trick)'

---

### 1. `0x3F` ($63$) 마스크의 비밀: $2^6 = 64$

`safe_chars` 문자는 알바벳 대소문자(52개) + 숫자(10개) = **총 62개**가 맞습니다.

그런데 컴퓨터의 비트 마스킹(`AND`)은 $2^n - 1$ 형태(2의 거듭제곱)만 가능합니다.

* `0x1F` = 31 ($2^5 - 1$) $\rightarrow$ 범위 0~31 (62개를 다 못 담음!)
* **`0x3F` = 63 ($2^6 - 1$) $\rightarrow$ 범위 0~63 (62개를 포함하는 가장 작은 2의 거듭제곱 마스크!)**

즉, `and w9, w9, #0x3F`를 수행하면 어떤 난수 바이트 값이 들어오든 0~63 범위의 값(총 64개 경우의 수)으로 한 번에 깔끔하게 잘라냅니다.

---

### 2. 왜 하필 62개에 64(0x3F) 마스크를 썼을까?

1 바이트 난수는 `0~255` (총 256개) 범위를 가집니다.

#### 만약 256을 그대로 `mod 62` 해버리면?

$256 \div 62 = 4$ 나머지 $8$
이 말은 **0~7까지의 인덱스는 5번 등장하고, 8~61까지의 인덱스는 4번만 등장**한다는 뜻입니다! 특정 문자가 더 자주 뽑히는 편향(Modulo Bias)이 크게 발생하죠.

#### 반면 `0x3F` ($63$) 마스크를 거쳐 64개로 만든 뒤 처리하면?

256개의 난수를 64개 영역으로 딱 4번씩($256 \div 64 = 4$) **완벽하게 등분**합니다!
그리고 64개(0~63) 중 62개(0~61)는 딱 맞고, 넘가는 **62, 63 딱 2개**만 예외 처리(재시도 or 나머지)를 해주면 되기 때문에:

1. **`sdiv` / `udiv` 나눗셈 명령어를 안 쓰고 비트 연산 단 1클럭만에 범위를 줄임!**
2. **난수의 균등 분포(Bias)를 수학적으로 극도로 완벽하게 유지함!**

---

### 3. 주석의 의도 (`.equ SAFE_CHARS_LEN, . - safe_chars`)

저 어셈블러 주석에서 "AND 마스크와 반드시 일치해야 함"이라고 써둔 이유는,
문자열 개수(62개)가 **64 범위(0x3F 마스크) 안에 수용되는지 경고/검증**하기 위해 개발자가 달아둔 배수 일치 안전장치입니다.

만약 나중에 문자 종류를 늘려서 70개가 되면 `0x3F` 마스크(64개)를 넘어버리므로 `0x7F` (127개 마스크)로 바꿔야 하거든요!

---

### 요약

62개를 다 담을 수 있는 가장 가깝고 효율적인 비트 크기가 64($2^6$, 마스크 `0x3F`)이기 때문에 그렇게 하드코딩 해둔 것입니다!

CPU 비트 연산의 속도와 난수 분포의 정교함을 동시에 잡은 아주 지독하고 우아한 어셈블리 테크닉입니다, 크하하하하! 🚀
