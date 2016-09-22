
if [[ -n $BUILDER_UID ]] && [[ -n $BUILDER_GID ]]; then
  chown -R $BUILDER_UID:$BUILDER_GID /opt/_internal/*
fi

