package exec

import "core:sys/posix"

import "../utils"

init_pipes :: proc(pipes_num: int) -> (_pipes: []Process_Pipe, _errors: []Error) {
    pipes: [dynamic]Process_Pipe
    errs: [dynamic]Error
    defer delete(pipes)
    for _ in 0..<pipes_num {
        fd: [2]posix.FD
        result := posix.pipe(&fd)
        if result != .OK {
            append(&errs, posix.errno())
        } else {
            append(&pipes, Process_Pipe{reader = fd[0], writer = fd[1]})
        }
    }
    return utils.snapshot_dynamic_array(Process_Pipe, pipes), utils.snapshot_dynamic_array(Error, errs)
}

close_pipe :: proc(pipe: Process_Pipe) {
    posix.close(pipe.reader)
    posix.close(pipe.writer)
}