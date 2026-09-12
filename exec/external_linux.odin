package exec

import "core:sys/posix"
import "core:strings"

import "../parser"
import "../utils"
import "../signals"

exec_external :: proc(
    command_path: string,
    argv: []string,
    envp: []string,
    command_fds: []Command_FD,
    redirects: []parser.Redirect,
) -> (_pid: posix.pid_t, _errs: []Error) {

    fds, errs := setup_redirects(redirects)
    defer delete(fds)
    if len(errs) > 0 {
        return -1, errs
    } 
    pid := posix.fork()
    switch pid {
        case BAD_PID:
            err := posix.errno()
            errors: [dynamic]Error
            append(&errors, err)
            return -1, utils.snapshot_dynamic_array(Error, errors)
        case 0:
            setup_process_io(command_fds)
            dup_redirects(redirects, fds)
            signals.default_sigint()

            path := strings.clone_to_cstring(command_path)
            c_argv := utils.strings_to_cstrings(argv)
            c_envp := utils.strings_to_cstrings(envp)
            posix.execve(path, c_argv, c_envp)
            
            posix.exit(1) // shouldn't happen, just a safe guard
    }
    return pid, errs
}

setup_process_io :: proc(command_fds: []Command_FD) {
    for command_fd in command_fds {
        if command_fd.old_fd != SKIP_FILENO {
            posix.dup2(command_fd.old_fd, command_fd.new_fd)
            posix.close(command_fd.old_fd)
        }
    }
}

setup_redirects :: proc(redirects: []parser.Redirect) -> (_fds: []posix.FD, _errors: []Error) {
    errors: [dynamic]Error
    fds: [dynamic]posix.FD
    defer delete(errors)
    defer delete(fds)

    for redirect in redirects {
        fd, err := handle_redirect(redirect)
        if err != nil {
            append(&errors, err)
        } else {
            append(&fds, fd)
        }
    }
    return utils.snapshot_dynamic_array(posix.FD, fds), utils.snapshot_dynamic_array(Error, errors)
}

dup_redirects :: proc(redirects: []parser.Redirect, fds: []posix.FD) {
    for fd, index in fds {
        redirect := redirects[index]
        TARGET_FILENO: posix.FD
        #partial switch redirect.kind {
            case .Redirect_In:
                TARGET_FILENO = posix.STDIN_FILENO
            case .Redirect_Out, .Redirect_Append:
                TARGET_FILENO = posix.STDOUT_FILENO
        }
        posix.dup2(fd, TARGET_FILENO)
    }
}


handle_redirect :: proc(redirect: parser.Redirect) -> (_fd: posix.FD, _err: Error) {
    c_target := strings.clone_to_cstring(redirect.target)
    fd: posix.FD = SKIP_FILENO

    #partial switch redirect.kind {
        case .Redirect_In:
            fd = posix.open(c_target, {.RDWR})
        case .Redirect_Out, .Redirect_Append:
            access_options: posix.O_Flags = {.CREAT, .WRONLY}
            if redirect.kind == .Redirect_Out {
                access_options |= { .TRUNC }
            } else if redirect.kind == .Redirect_Append {
                access_options |= { .APPEND }
            }
            fd = posix.open(c_target, access_options, {.IRUSR, .IWUSR, .IRGRP, .IROTH})
        }
    err: Error
    if fd == SKIP_FILENO {
        err = Redirect_Error{target = redirect.target, errno = posix.errno()}
    } 
    return fd, err
}
