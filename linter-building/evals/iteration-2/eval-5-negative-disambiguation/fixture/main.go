package main

import "errors"

func run() error {
	return errors.New("")
}

func main() {
	if err := run(); err != nil {
		panic(err)
	}
}
