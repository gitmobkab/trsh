package exec

import "core:os"
import "core:sys/posix"

Process_Pipe :: struct {
    reader: posix.FD,
    writer: posix.FD
}

Command_IO :: struct {
    stdin_source: posix.FD,
    stdout_target: posix.FD,
}

default_command_io :: proc() -> Command_IO {
    default_io := Command_IO{SKIP_FILENO, SKIP_FILENO}
    return default_io
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

