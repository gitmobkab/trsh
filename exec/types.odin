package exec

import "core:os"
import "core:sys/posix"

Process_Pipe :: struct {
    reader: posix.FD,
    writer: posix.FD
}

Command_FD :: struct {
    old_fd: posix.FD,
    new_fd: posix.FD,
}

default_command_fds :: proc() -> []Command_FD {
    fds := []Command_FD{
        {SKIP_FILENO, posix.STDIN_FILENO},
        {SKIP_FILENO, posix.STDOUT_FILENO}
    }
    return fds
}

Error :: union  {
    os.Error,
    posix.Errno,
    Redirect_Error,
}

Redirect_Error :: struct {
    target: string,
    errno: posix.Errno
}

