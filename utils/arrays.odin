package utils

contains :: proc(value: $T, candidates: ..T) -> bool {
    for candidate in candidates {
        if value == candidate {
            return true
        }
    }
    return false
} 