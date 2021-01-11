local skynet       = require "skynet"
local log          = require "common.lib.log"
local httpd        = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib       = require "http.url"
local cjson        = require "cjson"
local const        = require "common.define.const"
local httpmethods  = require "httpserver.modules.httpmethods"

local httphandler = {}

function httphandler.init()
end 

local function response(id, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
    if not ok then
        if err ~= sockethelper.socket_error then
            log.error("fd = %d, %s", id, err)
        end
    end
end

local function traceback(msg)
    local error_msg = tostring(msg) .. "\n" .. debug.traceback() .. "\n[END]"
    log.error(error_msg)
    return error_msg
end

function httphandler.read_request(id, addr)
    log.info("httphandler.read_request")
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id))

    log.info("code:%d", code)
    log.info("url:%s", url)
    log.info("method:%s", method)
    log.info("header:%s", cjson.encode(header))
    log.info("body:%s", body)

    if code ~= 200 then 
        response(id, code)
    else 
        local path, query = urllib.parse(url)
        log.info("path:%s query:%s", path, query)

        local func = httpmethods[method]
        if not func then 
            -- not implement
            response(id, 501)
            return
        end 

        local is_ok, code, content, header= xpcall(function() return func(id, path, query, body) end, traceback) 
        if not is_ok then 
            -- server internal error
            response(id, 500)
            return 
        end 

        log.info("code:%d content:%s", code, content)
        if code ~= 200 then 
            response(id, code)
        else
            response(id, code, content, header)
        end
    end
end

return httphandler