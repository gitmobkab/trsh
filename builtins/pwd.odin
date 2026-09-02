package builtins

import "core:fmt"
import "core:os"

pwd :: proc(args: []string) {
    working_dir, err := os.get_working_directory(context.allocator)
    if err != nil {
        fmt.println("pwd", err)
        return
    }
    fmt.println(working_dir)
}