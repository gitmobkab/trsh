package builtins

import "core:fmt"
import "core:os"

import "../models"
import "../registry"

pwd :: proc(current_state: ^models.Shell_state, _: []string) -> os.Error {
    fmt.println(current_state.cwd)
    return nil
}

@(init)
register_pwd :: proc "contextless" () {
    registry.registry["pwd"] = pwd
}