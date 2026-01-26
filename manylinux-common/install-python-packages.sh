#!/usr/bin/env bash

for PIP in /opt/python/*/bin/pip; do
  $PIP install --disable-pip-version-check --upgrade pip
  $PIP install scikit-build==0.8.1
done

# pip is installing everything as root.  We need to make sure whatever uid/gid
# is used when the image is run is able to update the python install.  We don't
# want to limit which uid/gid can be used, so instead we're going to:
#  - create a custom group
#  - change the group of the python directories to the new group
#  - change the permissions of the python directories to allow the group to write

# This GID isn't used in the manylinux image, but just to be safe, we'll verify
# it's still not in use during the image build.
BUILDER_GID=200
if id -g "$BUILDER_GID" 2> /dev/null; then
  echo "Error: builder gid $BUILDER_GID already exists!  Aborting"
  exit 1
fi

# Add the builder group
groupadd -g $BUILDER_GID builder

# Update the permissions for all python directories so they're owned by the
# builder group, and the builder group can write to them.
for DIR in /opt/python/*/lib/python*/site-packages; do
  chown -R :$BUILDER_GID $DIR
  chmod g+w $DIR
done
for DIR in /opt/python/*/bin; do
  chown -R :$BUILDER_GID $DIR
  chmod g+w $DIR
done
for DIR in /opt/python/*; do
  mkdir $DIR/man
  chown -R :$BUILDER_GID $DIR/man
  chmod g+w $DIR/man
done
for DIR in /opt/python/*/share; do
  chown -R :$BUILDER_GID $DIR
  chmod g+w $DIR
done
