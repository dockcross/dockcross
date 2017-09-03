#!/bin/bash

for PIP in /opt/python/*/bin/pip; do
  $PIP install --disable-pip-version-check --upgrade pip
  $PIP install scikit-build==0.6.1
done
