package utils

import "core:strings"

ENV_SEP :: "="

env_store_to_environ :: proc(env_store: map[string]string) -> []string {
    environ := make([]string, len(env_store))
    i := 0
    for key, val in env_store {
        environ[i] = strings.join({key, val}, ENV_SEP)
        i += 1
    }
    return environ
}

populate_env :: proc(env_store: ^map[string]string, environ: []string) {
    for env_pair in environ {
        parts := strings.split(env_pair, ENV_SEP)
        name := parts[0]
        value := parts[1]
        env_store[name] = value
    }

}