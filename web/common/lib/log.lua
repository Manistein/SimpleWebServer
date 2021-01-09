local skynet = require "skynet"

local log = {}

function log.info(fmt, ...)
	skynet.error(string.format("[info]:%s", string.format(fmt, ...)))
end 

function log.error(fmt, ...)
	skynet.error(string.format("[error]:%s", string.format(fmt, ...)))
end

return log