package lookup

import "core:os"
import "core:strings"

import "../builtins"

LOCAL_COMMAND_PREFIX :: "./"

find_builtin :: proc(name: string) -> (builtin_cmd: builtins.builtin_cmd, found: bool) {
    builtin_proc, builtin_found := builtins.BUILTINS[name]
    return builtin_proc, builtin_found
}

find_command_path_from_env :: proc(command_name: string, env_key: string = "PATH", split_on: string = ":") -> (_abs_path: string, _err: os.Error) {
    dirs: []string
    if strings.starts_with(command_name, LOCAL_COMMAND_PREFIX) {
        cwd, err := os.get_working_directory(context.allocator)
        if err != nil {
            return "", err
        }
        dirs = {cwd}
    } else {
        dirs = get_all_directories_from_env(env_key, split_on)
    }
    path, err := find_command_path(command_name, dirs)
    return path, err
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

get_all_directories_from_env :: proc(env_key: string = "PATH", split_on: string = ":") -> []string {
    normalized_key := strings.to_upper(env_key)
    path := os.get_env(normalized_key, context.allocator)
    return strings.split(path, split_on)
}
