package builtins

import "core:os"
import "core:fmt"

cd :: proc(args: []string) {
    if len(args) < 1 {
        fmt.println("Missing operand <path>")
        return
    }
    target := args[0]
    if !os.exists(target) {
        fmt.println("file or directory not found:", target)
        return
    }
    if !os.is_dir(target) {
        fmt.println("not a directory:", target)
        return
    }
    if err := os.chdir(target); err != nil {
        fmt.println(err)
    }
}