#!/usr/bin/env bash

set -eu
source test_helper.sh

describe 'compile'
it "(setup config.toml)"
  @run  cp ../../bundled/config.toml .
  @run  sed -i -e 's/^bin\s*=.*$/bin = "crystal"/' config.toml
  @run  sed -i -e 's/^src_dir\s*=.*$/src_dir = "src"/' config.toml

it "setup"
  @run  ln -s ../../test/src .
  @run  ./crystal-examples compile setup

it "run"
  @run  ln -s ../../test/out .
  ./crystal-examples compile run

it "(check generated files)"
  ln -s tmp/src gen
  diff -cr out gen
  @run  diff -cr out gen
