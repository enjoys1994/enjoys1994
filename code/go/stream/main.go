package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	// input a int num
	var a int
	fmt.Scan(&a)
	fmt.Println(a)
	// input slice int string
	// init a reader
	reader := bufio.NewReader(os.Stdin)
	//
	res, _ := reader.ReadSlice('\n')
	fmt.Println(res)
	fmt.Println(string(res))
	// how to input int slice
	res2, _ := reader.ReadString('\n')
	fmt.Println(res2)
	fmt.Printf("%T", res2)

}
