package utils

import "core:strings"

builder_to_string :: proc(b: ^strings.Builder) -> string{
    return strings.clone(strings.to_string(b^))
}