#!/bin/sh
brew ls --versions llvm

if [[ $? != 0 ]]; then
  brew install llvm
fi

echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.bashrc

BIN_PATH="$(swift build --show-bin-path)"
XCTEST_PATH="$(find ${BIN_PATH} -name '*.xctest')"

COV_BIN=$XCTEST_PATH
if [[ "$OSTYPE" == "darwin"* ]]; then
    f="$(basename $XCTEST_PATH .xctest)"
    COV_BIN="${COV_BIN}/Contents/MacOS/$f"
fi

llvm-cov report \
    "${COV_BIN}" \
    -instr-profile=.build/debug/codecov/default.profdata \
    -ignore-filename-regex=".build|Tests" \
    -use-color


bash -c '<(curl -s https://codecov.io/bash)'