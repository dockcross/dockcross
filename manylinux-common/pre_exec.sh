#!/bin/bash

for DIR in /opt/python/*/lib/python*/site-packages; do
  chown -R $BUILDER_UID:$BUILDER_GID $DIR
done
for DIR in /opt/python/*/bin; do
  chown -R $BUILDER_UID:$BUILDER_GID $DIR
done
for DIR in /opt/python/*; do
  mkdir $DIR/man
  chown -R $BUILDER_UID:$BUILDER_GID $DIR/man
done
for DIR in /opt/python/*/share; do
  chown -R $BUILDER_UID:$BUILDER_GID $DIR
done
