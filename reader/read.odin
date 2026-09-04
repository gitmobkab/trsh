package reader

import "core:strings"
import "core:os"
import "core:io"

import "../utils"






read_line :: proc () -> (string, os.Error) {
    buf: [1024]byte

    line_builder := strings.builder_make()
    defer strings.builder_destroy(&line_builder)
    for {
        count, err := os.read(os.stdin, buf[:])
        if err != nil {
            return "", err
        }
        if count == 0 {
            return "", io.Error.EOF
        }
        strings.write_bytes(&line_builder, buf[:count])
        
        if buf[count - 1] == '\n' {
            break
        }
    }
    raw_line := utils.builder_to_string(&line_builder)
    line := strings.trim_space(raw_line)
    return line, nil
}
