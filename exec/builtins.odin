package exec

import "core:os"
import "../models"

exec_builtin :: proc(builtin_proc: models.builtin_proc, args: []string, current_state: ^models.Shell_state) -> os.Error {
    return builtin_proc(current_state, args)
}