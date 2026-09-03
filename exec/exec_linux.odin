package exec

import "core:strings"
import "core:os"
import "core:sys/posix"

import "../signals"


run_command :: proc(command_path: string, args: []string = {}) {
    cmd_path_c := strings.clone_to_cstring(command_path)
    args_c := make([^]cstring, len(args) + 1)
    
    command_name := os.base(command_path)
    args_c[0] = strings.clone_to_cstring(command_name)

    status: i32
    for arg, i in args {
        args_c[i + 1] = strings.clone_to_cstring(arg)
    }
    child_pid := posix.fork()
    if child_pid == 0 {
        signals.default_sigint()
        posix.execv(cmd_path_c, args_c)
    } else {
        posix.waitpid(child_pid, &status, {.UNTRACED})
    }
}

