#!/usr/bin/env bash

set -eu
source test_helper.sh

describe '--version'
it "shows version numbers"
  @run  ./crystal-examples --version
  @grep '^[0-9]*\.[0-9]*\.[0-9]'

