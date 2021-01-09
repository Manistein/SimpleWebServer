#!/bin/bash

# /***
# * 编译、清理脚本
# * @author wuyinjie
# * @since 2021-01-06 
# */

parentPath=$(dirname $(pwd))

function build() {
	# 编译skynet
	echo "====================="
	echo "start build skyent..."
	cd $parentPath/skynet
	make linux

	# 编译log日志服务
	echo "====================="
	echo "start build service log..."
	cd $parentPath/3rd/src/service-log
	make

	# 编译cjson库
	echo "====================="
	echo "start build lua-cjson..."
	cd $parentPath/3rd/src/lua-cjson
	make

	# 编译lfs
	echo "====================="
	echo "start build lfs..."
	cd $parentPath/3rd/src/lfs
	make
	cd $parentPath/3rd/src/lfs/src
	mv lfs.so ../../../clib/lfs

	# 编译cryptex
	echo "====================="
	echo "start build cryptex..."
	cd $parentPath/3rd/src/cryptex
	make

	make all
}

function clean() {
	# 清理skynet
	echo "====================="
	echo "start clean skyent..."
	cd $parentPath/skynet
	make cleanall

	# 清理log日志服务
	echo "====================="
	echo "start clean service log..."
	cd $parentPath/3rd/src/service-log
	make clean

	# 清理cjson库
	echo "====================="
	echo "start clean cjson..."
	cd $parentPath/3rd/src/lua-cjson
	make clean

	# 清理lfs
	echo "====================="
	echo "start clean lfs..."
	cd $parentPath/3rd/src/lfs
	make clean

	# 清理cryptex
	echo "====================="
	echo "start clean cryptex..."
	cd $parentPath/3rd/src/cryptex
	make clean
}

if [[ "$1" == "all" ]]; then
	build
elif [[ "$1" == "clean" ]]; then
	clean
elif [[ "$1" == "rebuild" ]]; then
	clean
	build
else
	echo "不存在$1指令"
fi
