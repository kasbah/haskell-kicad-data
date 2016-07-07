#!/bin/bash
# Run our parser on all the footprint files we found so far GitHub
set -eu
set -o verbose
set -o pipefail
TEST_DIR=dist/build
TEMP_DIR=$TEST_DIR/parse-tmp
TEST_EXE=$TEST_DIR/parse
ROOT=$(pwd)

mkdir -p $TEST_DIR

if [ ! -d "$TEMP_DIR" ]; then
  git clone --depth=1 "https://github.com/kasbah/kicad_footprints" "$TEMP_DIR"
  cd "$TEMP_DIR" && ./init.sh && ./update.sh
else
  cd "$TEMP_DIR" && ./update.sh
fi
cd "$ROOT"

echo "Compiling."
if [[ -v TRAVIS ]]; then
  ghc tests/Parse.hs -tmpdir "$TEMP_DIR" -o "$TEST_EXE"
else
  cabal exec -- ghc tests/Parse.hs -tmpdir "$TEMP_DIR" -o "$TEST_EXE"
fi

echo "Running parse on all files."
find "$TEMP_DIR/" -name "*.kicad_mod" -print0 | xargs -0 -P 2 "$TEST_EXE" > /dev/null

if [ $? -eq 0 ]
then echo "- PARSE SUCEEDED -";
else echo "- PARSE FAILED -" && exit 2;
fi
