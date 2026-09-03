package builtins

import "core:os"

exit :: proc(current_state: ^Shell_state, _: []string) -> os.Error {
    current_state.should_exit = true
    return nil
}