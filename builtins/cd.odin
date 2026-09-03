package builtins

import "core:os"
import "core:fmt"

cd :: proc(current_state: ^Shell_state, args: []string) -> os.Error {
    if len(args) < 1 {
        fmt.println("Missing operand <path>")
        return nil
    }
    target, err := os.get_absolute_path(args[0], context.allocator)
    if err != nil {
        return err
    }
    if err := os.chdir(target); err != nil {
        return err
    }
    current_state.cwd = target
    return nil
}