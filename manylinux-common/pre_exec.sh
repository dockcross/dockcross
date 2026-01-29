#!/usr/bin/env bash

# Add the BUILDER_USER to the builder group so `pip install` doesn't get access
# denied errors.
usermod -a -G builder $BUILDER_USER
