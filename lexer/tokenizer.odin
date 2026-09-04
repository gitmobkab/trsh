#+feature dynamic-literals
package parser

import "core:unicode/utf8"
import "core:strings"

import "../utils"

operator_token_map := map[rune]Token_Kind{
    ';' = .Semicolon,
    '>' = .Redirect_Out,
    '<' = .Redirect_In,
    '|' = .Pipe,
    '&' = .Background
}

tokenize :: proc(s: string) -> (_tokens: [dynamic]Token){
    tokens: [dynamic]Token

    current_word := strings.builder_make()
    defer strings.builder_destroy(&current_word)

    runes := utf8.string_to_runes(s)
    cursor := 0


    for cursor < len(runes) {
        char := runes[cursor]
        
        switch {
            case strings.is_space(char):
            if builder_not_empty(&current_word) {
                flush_word(&tokens, &current_word)
            }
        case char == SINGLE_QUOTE || char == DOUBLE_QUOTE:
            quotted_word, new_cursor := handle_quote_char(char, runes, cursor + 1)
            strings.write_string(&current_word, quotted_word)
            cursor = new_cursor
        case:
            if operator_token, ok := get_operator_token(char); ok {
                if builder_not_empty(&current_word) {
                    flush_word(&tokens, &current_word)
                }
                flush_token(&tokens, operator_token)
            } else {
                strings.write_rune(&current_word, char)
            }
        }

        if cursor == int(Token_Kind.Incomplete) {
            break
        } 
        cursor += 1
    }
    if builder_not_empty(&current_word) {
        flush_word(&tokens, &current_word)
    }
    return tokens
}


handle_quote_char :: proc(char: rune, runes: []rune, start: int) -> (string, int) {
    if char == SINGLE_QUOTE {
        return parse_single_quote(runes, start)
    } else if char == DOUBLE_QUOTE {
        return parse_double_quote(runes, start)
    } else {
        return "", int(Token_Kind.None) // need changes (maybe)
    }
}

parse_single_quote :: proc(runes: []rune, start: int) -> (string, int) {
    return consume_quoted(runes, start, SINGLE_QUOTE, false)
}

parse_double_quote :: proc(runes: []rune, start: int) -> (string, int) {
    return consume_quoted(runes, start, DOUBLE_QUOTE, true)
}

consume_quoted :: proc(runes: []rune, start: int, quote_char: rune, process_escapes: bool) -> (string, int) {
    quotted_word := strings.builder_make()
    defer strings.builder_destroy(&quotted_word)

    i := start
    for i < len(runes) {
        c := runes[i]
        if c == quote_char {
            return utils.builder_to_string(&quotted_word), i + 1  
        }
        if process_escapes && c == ESCAPE_CHAR && i + 1 < len(runes) {
            next := runes[i + 1]
            if next == quote_char || next == ESCAPE_CHAR {
                strings.write_rune(&quotted_word, next)
                i += 2
                continue
            }
        }
        strings.write_rune(&quotted_word, c)
        i += 1
    }
    return utils.builder_to_string(&quotted_word), int(Token_Kind.Incomplete)
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

mark_incomplete :: proc(tokens: ^[dynamic]Token) {
    flush_token(tokens, Token{kind = .Incomplete})
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