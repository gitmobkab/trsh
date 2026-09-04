package main

import "base:runtime"
import "core:sys/posix"
import "core:io"
import "core:strings"
import "core:os"
import "core:fmt"

import "builtins"
import "signals"
import "lexer"
import "utils"
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
        line, err := read_line()
        if err != nil {
            if posix.get_errno() == .EINTR {
                continue
            }
            break
        }
        tokens := lexer.parse(line)
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