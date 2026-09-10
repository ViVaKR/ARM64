# Macro

## 기본구조

- .macro 로 시작하여 .endm 으로 끝남
- 매크로 내부에서 인자를 사용할 때는 앞에 역슬래시(\)를 붙여 참조 함

```h
.macro 매크로이름 인자1, 인자2=기본값

   /* 매크로 본문 */
   mov \인자1, \인자1
endm

---

```asm

/* 
   [설명] 특정 레지스터의 비트를 제어하는 매크로
   - dest: 무조건 지정해야 함 (:req)
   - src: 안 적으면 dest 레지스터 자체를 가리킴 (=dest)
   - bit: 안 적으면 기본값 0번 비트 제어 (=0)
*/

.macro BIT_CONTROL dest:req, src=\dest, bit=0
    and \dest, \src, #(1 << \bit)
.endm

// --- 활용법 ---
BIT_CONTROL x0          // 결과: and x0, x0, #(1 << 0)
BIT_CONTROL x0, x1, 4   // 결과: and x0, x1, #(1 << 4)

```
