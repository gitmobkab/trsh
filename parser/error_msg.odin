package parser


get_error_msg :: proc(err: Error) -> string {
    parse_error := err.(Parse_Error)
    switch parse_error.kind {
    case .Missing_Redirect_Target:
        return "no filename specified after redirection"
    case .Invalid_Redirect_Target:
        return "the specified redirect target is not a valid filename"
    case .Bad_Pipe_Usage:
        return "missing command or redirections before pipe"
    case .Missing_Background_Pipeline:
        return "no command preceding background operator"
    case :
        return "unknown error case..."
    }
}