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

Error :: union  {
    os.Error,
    posix.Errno,
    Redirect_Error,
}

Redirect_Error :: struct {
    target: string,
    errno: posix.Errno
}

