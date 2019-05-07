#!/bin/bash

set -e

export TARGET_COMMIT=88b01308dc0a98d366a63de60d04a7bf00d70226
export REBASE_COMMIT=d65e721ef824becd76773368718701cd0db83e59

##### Initialization #####
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

sudo cat /proc/cpuinfo
sudo cat /proc/meminfo
free
sudo dmidecode

curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain none
export PATH="$PATH:$HOME/.cargo/bin"

mkdir -p toolchain-none/{bin,lib}
cp /bin/false toolchain-none/bin/rustc
rustup toolchain link none toolchain-none
rustup default none

##### Set up Rust repo #####
git clone https://github.com/rust-lang/rust.git
cd rust

git submodule init
git submodule update src/doc/* src/stdsimd src/tools/*
git submodule update --depth=1 # Fetching submodules is very slow. This can speed it up.

git fetch origin $TARGET_COMMIT
git reset --hard $TARGET_COMMIT
git rebase $REBASE_COMMIT

echo "[llvm]" >> config.toml
echo "allow-old-toolchain = true" >> config.toml
echo "[rust]" >> config.toml
echo "codegen-units = 0" >> config.toml

./x.py build src/tools/cargo --stage=1
./x.py build --stage=1
cp build/x86_64-unknown-linux-gnu/stage1-tools-bin/cargo build/x86_64-unknown-linux-gnu/stage1/bin/cargo

cd ..

##### Benchmark target commit #####
BENCHMARK_COMMIT=$TARGET_COMMIT bash bench.sh

##### Switch to base commit #####
cd rust

git reset --hard $REBASE_COMMIT

./x.py build src/tools/cargo --stage=1
./x.py build --stage=1
cp build/x86_64-unknown-linux-gnu/stage1-tools-bin/cargo build/x86_64-unknown-linux-gnu/stage1/bin/cargo

cd ..

##### Benchmark base commit #####
BENCHMARK_COMMIT=$REBASE_COMMIT bash bench.sh
