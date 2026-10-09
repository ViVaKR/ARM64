use std::ffi::CStr;
use std::os::raw::c_char;

/// 기본 인사 함수 — 프로젝트 스캐폴딩이 잘 연결됐는지 확인용
#[no_mangle]
pub extern "C" fn rust_hello() {
    println!("Hello from Rust (rust_core)!");
}

/// 어셈블리/다른 언어에서 넘어온 널 종단 C 문자열을 println! 으로 출력한다.
/// 안전하지 않은 포인터 역참조이므로 msg 가 유효한 C 문자열이어야 한다.
#[no_mangle]
pub extern "C" fn rust_println(msg: *const c_char) {
    if msg.is_null() {
        println!();
        return;
    }
    let c_str = unsafe { CStr::from_ptr(msg) };
    match c_str.to_str() {
        Ok(s) => println!("{s}"),
        Err(_) => println!("<invalid utf-8>"),
    }
}