#!/bin/bash

# /***
# * 服务端启动关闭脚本
# * @author wuyinjie
# * @since 2021-01-06
# */

# 启动脚本
parentPath=$(dirname $(pwd))

function start_process() {
	ps -o command -C skynet | grep $1 &> /dev/null
	[ $? -eq 0 ] && echo "进程$3已经存在,禁止重复启动" && return
	echo "$parentPath/skynet/skynet $1 &> /dev/null &"
	nohup $parentPath/skynet/skynet $1 &> /dev/null &
	sleep 1
}

function stop_process() {
	echo "killing $1 ..."
	res=`ps aux | grep "$1" | grep -v tail | grep -v grep | awk '{print $2}'`
	[ "$res" != "" ] && kill $res
}

if [[ "$1" == "start" ]]; then
	start_process $2
elif [[ "$1" == "stop" ]]; then
	stop_process $2
else
	echo "unknow command $1"
fi

exit 0