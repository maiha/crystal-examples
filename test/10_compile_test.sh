#!/usr/bin/env bash

set -eu
source test_helper.sh

describe 'compile'
it "(setup config.toml)"
  @run  cp ../../bundled/config.toml .
  @run  sed -i -e 's/^bin\s*=.*$/bin = "crystal"/' config.toml
  @run  sed -i -e 's/^src_dir\s*=.*$/src_dir = "src"/' config.toml

it "gen"
  @run  ln -s ../../test/src .
  @run  ./crystal-examples compile setup
  @run  ./crystal-examples compile gen

it "(check generated files)"
        diff -cr ../../test/compile tmp
  @run  diff -cr ../../test/compile tmp
