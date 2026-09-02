#!/bin/sh
# Builds trsh and runs it directly, without a wrapper process staying
# alive (unlike `odin run .`, which keeps `odin` running as the parent
# of trsh and breaks Ctrl+C handling in interactive mode).
set -e
odin build . -out:trsh
exec ./trsh
