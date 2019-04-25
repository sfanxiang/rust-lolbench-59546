#!/bin/bash

set -e

git clone https://github.com/sfanxiang/lolbench.git --depth=1
cd lolbench && git log --format="%H" -n 1 && git submodule update --init && cd ..

rustup toolchain link bench rust/build/x86_64-unknown-linux-gnu/stage1
rustup default bench

rustc --version && cargo --version

cd lolbench
rm -f rust-toolchain
RUST_BACKTRACE=1 cargo run --release measure --site-dir site-dir --data-dir data-dir --single-toolchain bench --runner $LOLBENCH_RUNNER
mkdir -p "$BUILD_ARTIFACTSTAGINGDIRECTORY/$BENCHMARK_COMMIT/$LOLBENCH_RUNNER"
cp -R data-dir "$BUILD_ARTIFACTSTAGINGDIRECTORY/$BENCHMARK_COMMIT/$LOLBENCH_RUNNER/data-dir"
cd ..

rustup default none
rustup toolchain uninstall bench
rm -rf lolbench

stat /tmp/target-bench
rm -rf /tmp/target-bench
