package lookup

import "../models"

Command_Kind :: enum {
    Builtin,
    External
}

Found_Command :: struct {
    kind: Command_Kind,
    path: string,
    builtin_proc: models.builtin_proc
}