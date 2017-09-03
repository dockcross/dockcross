#!/bin/bash

# This is the entrypoint script for the dockerfile. Executed in the
# container at runtime.

if [[ $# == 0 ]]; then
    # Presumably the image has been run directly, so help the user get
    # started by outputting the dockcross script
    if [[ -n $DEFAULT_DOCKCROSS_IMAGE ]]; then
        head -n 2 /dockcross/dockcross
        echo "DEFAULT_DOCKCROSS_IMAGE=$DEFAULT_DOCKCROSS_IMAGE"
        tail -n +4 /dockcross/dockcross
    else
        cat /dockcross/dockcross
    fi
    exit 0
fi

# If we are running docker natively, we want to create a user in the container
# with the same UID and GID as the user on the host machine, so that any files
# created are owned by that user. Without this they are all owned by root.
# The dockcross script sets the BUILDER_UID and BUILDER_GID vars.
if [[ -n $BUILDER_UID ]] && [[ -n $BUILDER_GID ]]; then

    groupadd -o -g $BUILDER_GID $BUILDER_GROUP 2> /dev/null
    useradd -o -m -g $BUILDER_GID -u $BUILDER_UID $BUILDER_USER 2> /dev/null
    export HOME=/home/${BUILDER_USER}
    shopt -s dotglob
    cp -r /root/* $HOME/
    chown -R $BUILDER_UID:$BUILDER_GID $HOME

    # Additional updates specific to the image
    if [[ -e /dockcross/pre_exec.sh ]]; then
        /dockcross/pre_exec.sh
    fi

    # Execute project specific pre execution hook
    if [[ -e /work/.dockcross ]]; then
       gosu $BUILDER_UID:$BUILDER_GID /work/.dockcross
    fi

    # Enable passwordless sudo capabilities for the user
    chown root:$BUILDER_GID $(which gosu)
    chmod +s $(which gosu); sync

    # Run the command as the specified user/group.
    exec gosu $BUILDER_UID:$BUILDER_GID "$@"
else
    # Just run the command as root.
    exec "$@"
fi
