mod console;
pub use console::*;

/// 두 정수를 더한 합계를 반환한다.
/// ARM64 호출 규약: x0 = a, x1 = b 로 전달받고, 결과를 x0 으로 반환한다.
#[no_mangle]
pub extern "C" fn add_two_numbers(a: i64, b: i64) -> i64 {
    a + b
}