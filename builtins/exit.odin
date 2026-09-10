package builtins

import "core:os"

import "../models"
import "../registry"

exit :: proc(current_state: ^models.Shell_state, _: []string) -> os.Error {
    current_state.should_exit = true
    return nil
}

@(init)
register_exit :: proc "contextless"() {
    registry.registry["exit"] = exit
}