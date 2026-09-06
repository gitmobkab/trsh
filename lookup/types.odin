package lookup

import "../builtins"

Command_Kind :: enum {
    Builtin,
    External
}

Found_Command :: struct {
    kind: Command_Kind,
    path: string,
    builtin_proc: builtins.builtin_cmd
}