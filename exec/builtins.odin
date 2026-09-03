#+feature dynamic-literals
package exec

import "core:os"
import "../builtins"

BUILTINS := map[string]builtins.builtin_cmd{
    "cd" = builtins.cd,
    "pwd" = builtins.pwd,
    "exit" = builtins.exit,
    "alias" = builtins.alias,
}

find_and_exec_builtin :: proc(name: string, args: []string, current_state: ^builtins.Shell_state) -> (found: bool, err: os.Error) {
    err = nil
    builtin_cmd, builtin_found := find_builtin(name)
    if builtin_found {
        err = exec_builtin(builtin_cmd, args, current_state)
    }
    return builtin_found, err
}

find_builtin :: proc(name: string) -> (builtin_cmd: builtins.builtin_cmd, found: bool) {
    builtin, builtin_found := BUILTINS[name]
    return builtin, builtin_found
}

exec_builtin :: proc(builtin_cmd: builtins.builtin_cmd, args: []string, current_state: ^builtins.Shell_state) -> os.Error {
    return builtin_cmd(current_state, args)
}