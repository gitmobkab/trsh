package main

import "core:os"
import "core:fmt"

import "builtins"
import "signals"
import "reader"
import "parser"
import "lexer"

PROMPT :: "TRSH > "

main :: proc() {

    signals.ignore_sigint()
    shell_state, err := builtins.init_shell_state()
    if err != nil {
        fmt.println(err)
        return
    }

    for !shell_state.should_exit {
        fmt.print(PROMPT)
        line, err := reader.read_line()
        if err != nil {
            break
        }
        tokens := lexer.tokenize(line)
        pipelines, parse_error := parser.parse(tokens[:])
        fmt.println(pipelines[:])
        if parse_error != {} {
            fmt.println("parse error:", parse_error)
        }
    }
}