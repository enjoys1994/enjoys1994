package main

import (
	"bytes"
	"fmt"
	"golang.org/x/text/encoding/simplifiedchinese"
	"golang.org/x/text/transform"
	"io"
)

func GbkToUtf8(s []byte) ([]byte, error) {
	reader := transform.NewReader(bytes.NewReader(s), simplifiedchinese.GBK.NewDecoder())
	d, e := io.ReadAll(reader)
	if e != nil {
		return nil, e
	}
	return d, nil
}

func Utf8ToGbk(s []byte) ([]byte, error) {
	reader := transform.NewReader(bytes.NewReader(s), simplifiedchinese.GBK.NewEncoder())
	d, e := io.ReadAll(reader)
	if e != nil {
		return nil, e
	}
	return d, nil
}

func main() {
	s := "GBK 与 UTF-8 编码转换测试"
	gbk, err := Utf8ToGbk([]byte(s))
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(string(gbk))
	}
	utf8, err := GbkToUtf8(gbk)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(string(utf8))
	}
}
