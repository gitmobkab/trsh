package builtins

import "core:strings"
import "core:os"

// forget my previous comment...
builtin_cmd :: #type proc(current_state: ^Shell_state, args: []string) -> os.Error

Shell_state :: struct {
    cwd: string,
    
    public_env: map[string]string,

    // do not confuse with the public env passed to programs (not used until we support variables lookup)
    private_env: map[string]string,
    aliases: map[string]string,
    should_exit: bool,
    exit_code: u8,
}

init_shell_state :: proc() -> (Shell_state, os.Error) {
    state := Shell_state{ should_exit = false }
    if working_dir, err := os.get_working_directory(context.allocator); err != nil {
        return {}, err
    } else {
        state.cwd = working_dir
    }
    
    if environ, err := os.environ(context.allocator); err != nil{
        return {}, err
    } else {
        populate_env(&state.public_env, environ)
    }

    return state, nil
}

populate_env :: proc(env_store: ^map[string]string, environ: []string) {
    for env_pair in environ {
        parts := strings.split(env_pair, "=")
        name := parts[0]
        value := parts[1]
        env_store[name] = value
    }

}