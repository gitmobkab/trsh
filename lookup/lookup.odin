package lookup

import "core:os"


search_command :: proc(command_name: string) -> (_command: Found_Command, _err: os.Error) {
    if builtin_fn, found := find_builtin(command_name); found {
        return Found_Command{kind = .Builtin, builtin_proc = builtin_fn}, nil
    }
    abs_path, err := find_command_path_from_env(command_name)
    if err != nil {
        return {}, err
    } 
    return Found_Command{kind = .External, path = abs_path}, nil
}