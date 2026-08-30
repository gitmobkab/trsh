package main

import "core:io"
import "core:strings"
import "core:os"
import "core:fmt"

import "parser"
import "utils"


main :: proc() {
    for {
        fmt.print("TRSH > ")
        line, err := read_line()
        if err != nil {
            fmt.println("\ntrsh:", err)
            break
        }
        tokens := parser.parse(line)
        defer delete(tokens)
        fmt.println(tokens[:])
    }
}

// ok so they're a bug inside of that code and i need to figure it out
read_line :: proc () -> (string, os.Error) {
    buf: [1024]byte

    line_builder := strings.builder_make()
    defer strings.builder_destroy(&line_builder)
    for {
        count, err := os.read(os.stdin, buf[:])
        if err != nil {
            return "", err
        }
        if count == 0 {
            return "", io.Error.EOF
        }
        strings.write_bytes(&line_builder, buf[:count])
        
        if buf[count - 1] == '\n' {
            break
        }
    }
    raw_line := utils.builder_to_string(&line_builder)
    line := strings.trim_space(raw_line)
    return line, nil
}
