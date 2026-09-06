package parser

import "../lexer"


Error_Kind :: enum u8 {
    Missing_Redirect_Target,
    Invalid_Redirect_Target,
    Bad_Pipe_Usage,
    Missing_Background_Pipeline
}

Error :: union {
    Parse_Error
}

Parse_Error :: struct{
    location: int,
    kind: Error_Kind,
}

Redirect :: struct {
    kind: lexer.Token_Kind,
    target: string
}

Parsed_Command :: struct {
    argv: []string, // argv[0] == command name
    redirects: []Redirect
}

Pipeline :: struct {
    commands: []Parsed_Command,
    background: bool
}