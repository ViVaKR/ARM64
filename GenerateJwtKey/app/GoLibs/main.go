package main

// #include <stdlib.h>
import "C"
import "fmt"

//export go_hello
func go_hello() {
	fmt.Println("Hello from Go (GoLibs)!")
}

//export add_two_numbers_go
func add_two_numbers_go(a, b int64) int64 {
	return a + b
}

// c-archive 빌드 모드는 main 패키지 + main 함수를 요구하지만
// 실제로는 호출되지 않는다 (라이브러리로만 사용됨).
func main() {}