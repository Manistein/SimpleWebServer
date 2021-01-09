#!/bin/bash

# /***
# * 安装jemalloc
# * @author wuyinjie
# * @since 2021-01-06 
# */

parentPath=$(dirname $(pwd))

cd $parentPath/skynet/3rd
rm -rf jemalloc

tar -zxvf $parentPath/3rd/src/jemalloc.tar.gz -C ./
mv jemalloc* jemalloc
