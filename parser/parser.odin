package parser

import "../lexer"
import "../utils"

parse :: proc(tokens: []lexer.Token) -> (_pipelines: []Pipeline, _err: Error) {

    pipelines: [dynamic]Pipeline
    current_redirects: [dynamic]Redirect
    current_commands: [dynamic]Parsed_Command
    current_argv: [dynamic]string
    
    defer delete(pipelines)
    defer delete(current_redirects)
    defer delete(current_commands)
    defer delete(current_argv)

    cursor := 0
    for cursor < len(tokens) {
        current_token := tokens[cursor]

        switch {
        case current_token.kind == .Word :
            append(&current_argv, current_token.content)
        case utils.contains(current_token.kind, ..lexer.REDIRECT_TOKEN_KINDS):
            new_cursor, err := handle_redirect_token(tokens, cursor, &current_redirects)
            if err != nil {
                return flush_pipelines(pipelines), err
            }
            cursor = new_cursor
            continue
        case current_token.kind == .Pipe:
            if len(current_argv) == 0 && len(current_redirects) == 0 {
                return flush_pipelines(pipelines), Parse_Error{cursor, .Bad_Pipe_Usage}
            }
            add_new_command(&current_commands, &current_argv, &current_redirects)
        case utils.contains(current_token.kind, ..lexer.PIPELINE_SEPARATORS):
            run_in_background := (current_token.kind == .Background)
            success := flush_trailing_pipeline(&pipelines, &current_commands, &current_redirects, &current_argv, run_in_background)
            if run_in_background && !success {
                return flush_pipelines(pipelines), Parse_Error{cursor, .Missing_Background_Pipeline}
            }
        }
        cursor += 1
    }
    flush_trailing_pipeline(&pipelines, &current_commands, &current_redirects, &current_argv, false)
    return flush_pipelines(pipelines), nil
}

flush_trailing_pipeline :: proc(
    pipelines: ^[dynamic]Pipeline, 
    commands: ^[dynamic]Parsed_Command,
    redirects: ^[dynamic]Redirect,
    argv: ^[dynamic]string,
    run_in_background: bool,
) -> (_success: bool) {
    if len(argv) != 0 || len(redirects) != 0 {
        add_new_command(commands, argv, redirects)
    }
    if len(commands) == 0 && run_in_background {
        return false
    }
    add_new_pipeline(pipelines, commands, run_in_background)
    return true
}

handle_redirect_token :: proc(tokens: []lexer.Token, cursor: int, redirects: ^[dynamic]Redirect) -> (_new_cursor: int, _err: Error) {
    current_token := tokens[cursor]
    next_cursor := cursor + 1
    if next_cursor >= len(tokens) {
        return cursor, Parse_Error{cursor, .Missing_Redirect_Target}
    } else if redirect_target := tokens[next_cursor]; redirect_target.kind != .Word {
        return cursor, Parse_Error{cursor, .Invalid_Redirect_Target}
    }
    redirect_target := tokens[next_cursor].content
    append(redirects, Redirect{current_token.kind, redirect_target})
    return cursor + 2, nil
}

add_new_command :: proc(current_commands: ^[dynamic]Parsed_Command, argv: ^[dynamic]string, redirects: ^[dynamic]Redirect) {
    append(
        current_commands,
        Parsed_Command{argv = flush_dynamic_string(argv^), redirects = flush_redirects(redirects^)}
    )
    clear(argv)
    clear(redirects)
}

add_new_pipeline :: proc(current_pipelines: ^[dynamic]Pipeline, commands: ^[dynamic]Parsed_Command, run_in_background: bool = false) {
    append(
        current_pipelines,
        Pipeline{commands = flush_commands(commands^), background = run_in_background}
    )
    clear(commands)
}


flush_pipelines :: proc(pipelines: [dynamic]Pipeline) -> []Pipeline {
    return utils.snapshot_dynamic_array(Pipeline, pipelines)
}

flush_dynamic_string :: proc(arr: [dynamic]string) -> []string {
    return utils.snapshot_dynamic_array(string, arr)
}

flush_redirects :: proc(redirects: [dynamic]Redirect) -> []Redirect {
    return utils.snapshot_dynamic_array(Redirect, redirects)
}

flush_commands :: proc(commands: [dynamic]Parsed_Command) -> []Parsed_Command {
    return utils.snapshot_dynamic_array(Parsed_Command, commands)
}
