#+feature dynamic-literals
package parser

import "core:strings"

import "../utils"

operator_token_map := map[rune]Token_Kind{
    ';' = .Semicolon,
    '>' = .Redirect_Out,
    '<' = .Redirect_In,
    '|' = .Pipe,
    '&' = .Background
}

parse :: proc(s: string) -> [dynamic]Token {
    tokens: [dynamic]Token
    current_word := strings.builder_make()
    defer strings.builder_destroy(&current_word)

    for char in s {
        if strings.is_space(char) {
            if builder_not_empty(&current_word) {
                flush_word(&tokens, &current_word)
            }
        } else if operator_token, ok := get_operator_token(char); ok {
            if builder_not_empty(&current_word) {
                flush_word(&tokens, &current_word)
            }
            flush_token(&tokens, operator_token)
        } else {
            strings.write_rune(&current_word, char)
        }
    }
    if builder_not_empty(&current_word) {
        flush_word(&tokens, &current_word)
    }
    return tokens
}

get_operator_token :: proc(char: rune) -> (Token, bool) {
    token_kind, ok := operator_token_map[char]
    if ok {
        return Token{kind = token_kind}, true
    }
    return {}, false
}

builder_not_empty :: proc(b: ^strings.Builder) -> bool {
    return len(b.buf) != 0
}

/*
    append a word into tokens and reset the passed word_builder
*/
flush_word :: proc(tokens: ^[dynamic]Token, word_builder: ^strings.Builder) {
    flush_token(
        tokens,
        Token{.Word, utils.builder_to_string(word_builder)}
    )
    strings.builder_reset(word_builder)
}

flush_token :: proc(tokens: ^[dynamic]Token, token: Token) {
    append(tokens, token)
}