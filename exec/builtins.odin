package exec

import "core:sys/posix"
import "core:os"

import "../models"
import "../parser"
import "../utils"

FDS_TO_SAVE :: []posix.FD{
    posix.STDIN_FILENO,
    posix.STDOUT_FILENO,
    // posix.STDERR_FILENO
}


exec_builtin :: proc(
    builtin_proc: models.builtin_proc,
    args: []string,
    current_state: ^models.Shell_state,
    command_fds: []Command_FD,
    redirects: []parser.Redirect
) -> []Error {
    

    saved_fds := save_command_fds()
    defer delete(saved_fds)
    fds, errs := setup_redirects(redirects)
    defer delete(fds)
    if len(errs) > 0 {
        return errs
    } 
    dup_redirects(redirects, fds)

    exec_errs: [dynamic]Error
    setup_process_io(command_fds)
    dup_redirects(redirects, fds)

    err := builtin_proc(current_state, args)
    if err != nil {
        append(&exec_errs, err)
    }
    
    // restore saved fildes
    setup_process_io(saved_fds)

    return utils.snapshot_dynamic_array(Error, exec_errs)
}

save_command_fds :: proc() -> []Command_FD {

    saved_fds := make([]Command_FD, len(FDS_TO_SAVE))
    for fd_to_save, i in FDS_TO_SAVE{
        saved_fds[i].old_fd = posix.dup(fd_to_save)
        saved_fds[i].new_fd = fd_to_save
    }

    return saved_fds
}