#+feature dynamic-literals
package builtins

BUILTINS := map[string]builtin_cmd{
    "cd" = cd,
    "pwd" = pwd,
    "exit" = exit,
    "alias" = alias,
}