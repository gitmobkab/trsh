package builtins

import "core:fmt"
import "core:os"

pwd :: proc(current_state: ^Shell_state, _: []string) -> os.Error {
    fmt.println(current_state.cwd)
    return nil
}