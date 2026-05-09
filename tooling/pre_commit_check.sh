#!/usr/bin/env sh
# Purpose: Local pre-commit sanity check.
# Runs formatter and analyzer; exits non-zero on failure.

dart format --set-exit-if-changed . && dart analyze

