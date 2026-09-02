package builtins

import "core:os"

exit :: proc(_: []string) {
    os.exit(0)
}