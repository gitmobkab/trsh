package exec

import "core:sys/posix"
import "core:os"

import "../models"
import "../parser"
import "../utils"

exec_builtin :: proc(
    builtin_proc: models.builtin_proc,
    args: []string,
    current_state: ^models.Shell_state,
    io: Command_IO,
    redirects: []parser.Redirect
) -> []Error {
    
    save_stdin := posix.dup(posix.STDIN_FILENO)
    save_stdout := posix.dup(posix.STDOUT_FILENO)
    
    fds, errs := setup_redirects(redirects)
    defer delete(fds)
    if len(errs) > 0 {
        return errs
    } 
    dup_redirects(redirects, fds)

    exec_errs: [dynamic]Error
    setup_process_io(io)
    dup_redirects(redirects, fds)

    err := builtin_proc(current_state, args)
    if err != nil {
        append(&exec_errs, err)
    }
    
    posix.dup2(save_stdin, posix.STDIN_FILENO)
    posix.dup2(save_stdout, posix.STDOUT_FILENO)
    posix.close(save_stdin)
    posix.close(save_stdout)

    return utils.snapshot_dynamic_array(Error, exec_errs)
}