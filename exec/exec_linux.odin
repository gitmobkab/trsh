package exec

import "core:sys/posix"
import "core:os"

import "../parser"
import "../builtins"
import "../lookup"
import "../utils"

SKIP_FILENO :: -1

exec_pipepilines :: proc(pipelines: []parser.Pipeline, shell_state: ^builtins.Shell_state) -> []Error {
    errs: [dynamic]Error
    defer delete(errs)
    for pipeline in pipelines {
        pipeline_errs := exec_pipeline(pipeline, shell_state)
        if len(pipeline_errs) > 0 {
            append(&errs, ..pipeline_errs)
        }
    }
    return utils.snapshot_dynamic_array(Error, errs)
}

exec_pipeline :: proc(pipeline: parser.Pipeline, shell_state: ^builtins.Shell_state) -> []Error {
    return exec_commands(pipeline.commands, shell_state)
}


exec_commands :: proc(commands: []parser.Parsed_Command, shell_state: ^builtins.Shell_state) -> []Error {
    pipes, pipe_errors := init_pipes(len(commands) - 1)
    if len(pipe_errors) > 0 {
        return pipe_errors
    }
    errs: [dynamic]Error
    defer delete(errs)

    pids := make([]posix.pid_t, len(commands))
    defer delete(pids)
    for command, i in commands {
        command_io := Command_IO{SKIP_FILENO, SKIP_FILENO}        

        if i > 0 {
            command_io.stdin_source = pipes[i - 1].reader
        }
        if i < len(commands) - 1 {
            command_io.stdout_target = pipes[i].writer
        }

        pid, exec_errs := exec_command(command, shell_state, command_io)
        if len(exec_errs) > 0 || pid == -1{
            append(&errs, ..exec_errs)
        } else {
            pids[i] = pid
        }
    }
    // don't intend on using it right now
    global_stat_loc: i32
    for pid in pids {
        posix.waitpid(pid, &global_stat_loc, {.UNTRACED})
    }

    for pipe in pipes {
        close_pipe(pipe)
    }

    return utils.snapshot_dynamic_array(Error, errs)
}

exec_command :: proc(
    command: parser.Parsed_Command,
    shell_state: ^builtins.Shell_state,
    io: Command_IO,
) -> (_pid: posix.pid_t, _errs: []Error) {

    found_command, search_err := lookup.search_command(command.argv[0])
    errs: [dynamic]Error
    defer delete(errs)
    if search_err != nil {
        append(&errs, search_err)
        return -1, utils.snapshot_dynamic_array(Error, errs)
    }

    cmd_pid: posix.pid_t = -1
    switch found_command.kind{
        case .Builtin:
            err := exec_builtin(found_command.builtin_proc, command.argv, shell_state)
            if err != nil {
                append(&errs, err)
            }
        case .External:
            environ := utils.env_store_to_environ(shell_state.public_env)
            pid, exec_errs := exec_external(found_command.path, command.argv, environ, io, command.redirects)
            if len(exec_errs) > 0 || pid == -1 {
                append(&errs, ..exec_errs)
            } else {
                cmd_pid = pid
            }
    }
    return cmd_pid, utils.snapshot_dynamic_array(Error, errs)
}