#!/usr/bin/env bash

set -eu
source test_helper.sh

describe 'spec'
it "(setup config.toml)"
  @run  cp ../../bundled/config.toml .
  @run  sed -i -e 's/^bin\s*=.*$/bin = "crystal"/' config.toml
  @run  sed -i -e 's/^src_dir\s*=.*$/src_dir = "src"/' config.toml

it "gen"
  @run  ln -s ../../test/src .
  @run  ./crystal-examples test setup
  @run  ./crystal-examples test gen

it "(check generated files)"
        diff -cr ../../test/test tmp
  @run  diff -cr ../../test/test tmp
