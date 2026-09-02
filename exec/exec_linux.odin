package exec

import "core:strings"
import "base:runtime"
import "core:os"
import "core:sys/posix"

import "../signals"

DIRECTORY_PATH_SEP :: ":"

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


find_command_path :: proc(command_name: string, directories: []string) -> (path: string, error: os.Error) {
    for directory in directories {
        command_path, err := os.join_path({directory, command_name}, context.allocator)
        if err != nil {
            return "", err
        }
        if os.exists(command_path) {
            return command_path, nil
        }
    }
    return "", os.General_Error.Invalid_Command
}

get_all_directories_from_env :: proc(env_key: string = "PATH") -> []string {
    normalized_key := strings.to_upper(env_key)
    path := os.get_env(normalized_key, context.allocator)
    return strings.split(path, DIRECTORY_PATH_SEP)
}