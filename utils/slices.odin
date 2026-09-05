package utils

import "core:slice"

snapshot_dynamic_array :: proc($T: typeid, dyn_array: [dynamic]T) -> []T {
    return slice.clone(dyn_array[:])
}

