#!/bin/bash

# $1: src root directory
# $2: build directory
# $3: target file
# $4: config file
# $5: make flags

if [ $# -lt 4 ]; then
    exit 1
fi

source_dir=$1
build_dir=$2
target=$3
config=$4
flags=$5

# クリーンコンパイルのオプションを実行
if [ $target == "clean" ]; then
    # make mrproper O=$build_dir -s
    rm -r O=$build_dir
    exit 0
fi

cd $source_dir

# ディレクトリがなければ作る
if [ ! -d $build_dir ]; then
    mkdir -p $build_dir
fi

# configファイルを配置
if [ ! -f $build_dir/.config -o $config -nt $build_dir/.config ]; then
    cp $config $build_dir/.config
fi

# 前提:ビルドするにはmake config prepare scriptsが必要

# oldnoconfigはconfigに完全に依存するので省略可能
if [ ! -f $build_dir/.config.touch -o $build_dir/.config -nt $build_dir/.config.touch ]; then
    make oldnoconfig O=$build_dir $flags -s
    touch $build_dir/.config.touch
fi

# prepareはtargetと混ぜると何故かbounds.sがないとエラーになるので、これだけ手動生成してやる
if [ ! -f $build_dir/kernel/bounds.s ]; then
    make kernel/bounds.s O=$build_dir $flags -s
fi

# scriptsは毎回内容は変わらない癖に遅すぎる。
# 最初の一回と、必要な時だけ手動で更新するようにする。
if [ ! -f $build_dir/.scripts.touch ]; then
    make scripts O=$build_dir $flags -s
    touch $build_dir/.scripts.touch
fi

# prepareと混ぜてmake
make prepare KCFLAGS="-fsyntax-only" O=$build_dir $flags ${target%.c}.o -s 2>&1 | grep "^$target"
#make prepare KCFLAGS="-fsyntax-only" O=$build_dir $flags ${target%.c}.o -s
# make prepare KCFLAGS+="-fsyntax-only" O=$build_dir $flags ${target%.c}.o -s KCFLAGS+="-Wall" KCFLAGS+="-Wextra" KCFLAGS+="-Wno-unused-parameter" KCFLAGS+="-Wno-sign-compare" KCFLAGS+="-Wno-pointer-sign" KCFLAGS+="-Wno-missing-field-initializers" KCFLAGS+="-Wformat=2" KCFLAGS+="-Wstrict-aliasing=2" KCFLAGS+="-Wdisabled-optimization" KCFLAGS+="-Wfloat-equal" KCFLAGS+="-Wpointer-arith" KCFLAGS+="-Wdeclaration-after-statement" KCFLAGS+="-Wbad-function-cast" KCFLAGS+="-Wcast-align" KCFLAGS+="-Wredundant-decls" KCFLAGS+="-Winline"
# make prepare O=$build_dir $flags -s
# make KCFLAGS="-fsyntax-only" O=$build_dir $flags ${target%.c}.o -s

exit 0
