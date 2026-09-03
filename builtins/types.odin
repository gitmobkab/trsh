package builtins

import "core:os"

// args doesn't contain the name of the builtin command or i'll fuck you.
builtin_cmd :: #type proc(current_state: ^Shell_state, args: []string) -> os.Error

Shell_state :: struct {
    cwd: string,
    // do not confuse with the public env passed to programs 
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
    

    return state, nil
}