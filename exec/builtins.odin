package exec

import "core:os"
import "../builtins"

exec_builtin :: proc(builtin_cmd: builtins.builtin_cmd, args: []string, current_state: ^builtins.Shell_state) -> os.Error {
    return builtin_cmd(current_state, args)
}