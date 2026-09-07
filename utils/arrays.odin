package utils

import "core:strings"

contains :: proc(value: $T, candidates: ..T) -> bool {
    for candidate in candidates {
        if value == candidate {
            return true
        }
    }
    return false
}

strings_to_cstrings :: proc(args: []string) -> [^]cstring {
    argv := make([^]cstring, len(args) + 1) 
    for arg, i in args {
        argv[i] = strings.clone_to_cstring(arg) 
    }
    argv[len(args)] = nil // 
    return argv
}