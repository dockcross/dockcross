#!/bin/sh

# Emulate the sudo command

exec gosu root:root "$@"
