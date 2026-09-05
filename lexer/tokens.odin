package lexer

SINGLE_QUOTE :: '\''
DOUBLE_QUOTE :: '"'
ESCAPE_CHAR :: '\\'

REDIRECT_TOKEN_KINDS := []Token_Kind{
    .Redirect_In,
    .Redirect_Out,
    .Redirect_Append
}

Token :: struct {
    kind: Token_Kind,
    content: string,
}

Token_Kind :: enum i8 {
    Incomplete = -1,
    None = 0,
    Word,
    Semicolon,
    Pipe,
    Redirect_In,
    Redirect_Out,
    Redirect_Append,
    Background,
}