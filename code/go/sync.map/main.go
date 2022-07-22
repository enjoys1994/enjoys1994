package main

import "sync"

func main() {
	a := sync.Map{}
	i := 1
	for i < 5 {
		a.Store(i, "a")
		i++
	}
	for i < 10 {
		a.Load(2)
		i++
	}

}
