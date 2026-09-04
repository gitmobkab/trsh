package main

import "core:os"
import "core:fmt"

import "builtins"
import "signals"
import "lexer"
import "reader"
import "exec"

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
        defer delete(tokens)
        
        err = execute(tokens[:], &shell_state)
        if err != nil {
            fmt.println("trsh:", err)
            continue
        }

    }
}

execute :: proc(tokens: []lexer.Token, current_state: ^builtins.Shell_state) -> os.Error {
    if len(tokens) == 0 {
        return nil
    }
    cmd := tokens[0].content
    args := get_parsed_args(tokens[:])

    if found, err := exec.find_and_exec_builtin(cmd, args[:], current_state); found {
        return err
    }


    dirs := exec.get_all_directories_from_env()
    defer delete(args)
    if command_path, err := exec.find_command_path(cmd, dirs); err != nil {
        return err
    } else {
        exec.run_command(command_path, args[:])
    }

    return nil
}


get_parsed_args :: proc(tokens: []lexer.Token) -> [dynamic]string {
    if len(tokens) < 2 {
        return {}
    }

    args: [dynamic]string 

    for i := 1; i < len(tokens); i += 1 {
        current_token := tokens[i]
        if current_token.kind != .Word {
            continue
        }
        append(&args, current_token.content)
    }
    return args
}