package models

import "core:os"

builtin_proc :: #type proc(current_state: ^Shell_state, args: []string) -> os.Error