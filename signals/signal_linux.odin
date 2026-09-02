package signal

import "core:sys/posix"


ignore_sigint :: proc() {
    act: posix.sigaction_t
    act.sa_handler = auto_cast posix.SIG_IGN
    posix.sigemptyset(&act.sa_mask)
    act.sa_flags = {}
    posix.sigaction(.SIGINT, &act, nil)
}

default_sigint :: proc() {
    act: posix.sigaction_t
    act.sa_handler = auto_cast posix.SIG_DFL
    posix.sigemptyset(&act.sa_mask)
    act.sa_flags = {}
    posix.sigaction(.SIGINT, &act, nil)
}