package exec

import "core:os"
import "core:strings"

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
