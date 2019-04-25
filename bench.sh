#!/bin/bash

set -e

git clone https://github.com/sfanxiang/lolbench.git
cd lolbench && git checkout split-less && git log --format="%H" -n 1 && git submodule update --init && cd ..

rustup toolchain link bench rust/build/x86_64-unknown-linux-gnu/stage1
rustup default bench

rustc --version && cargo --version

cd lolbench
RUST_BACKTRACE=1 cargo run --release measure --site-dir site-dir --data-dir data-dir --single-toolchain bench --runner $LOLBENCH_RUNNER
mkdir -p "$BUILD_ARTIFACTSTAGINGDIRECTORY/$BENCHMARK_COMMIT/$LOLBENCH_RUNNER"
cp -R data-dir "$BUILD_ARTIFACTSTAGINGDIRECTORY/$BENCHMARK_COMMIT/$LOLBENCH_RUNNER/data-dir"
cd ..
