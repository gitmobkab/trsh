#+feature dynamic-literals
package exec

import "../builtins"

BUILTINS := map[string]builtins.builtin_cmd{
    "cd" = builtins.cd,
    "pwd" = builtins.pwd,
    "exit" = builtins.exit,
}

find_and_exec_builtin :: proc(name: string, args: []string) -> (found: bool) {
    builtin_cmd, builtin_found := find_builtin(name)
    if builtin_found {
        exec_builtin(builtin_cmd, args)
    }
    return builtin_found
}

find_builtin :: proc(name: string) -> (builtin_cmd: builtins.builtin_cmd, found: bool) {
    builtin, builtin_found := BUILTINS[name]
    if !builtin_found {
        return nil, false
    }
    return builtin, true
}

exec_builtin :: proc(builtin_cmd: builtins.builtin_cmd, args: []string) {
    builtin_cmd(args)
}