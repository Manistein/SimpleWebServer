local socket              = require "socket"
local httpd               = require "http.httpd"
local sockethelper        = require "http.sockethelper"
local urllib              = require "http.url"
local cjson               = require "cjson"
local skynet              = require "skynet"
local log                 = require "common.lib.log"

local mode, agent_count, server_port, command_path = ...

if mode == "agent" then
    local httphandler     = require(command_path)

    skynet.start(function()
        skynet.dispatch("lua", function (_,_,id,addr)
            log.info("----------------------------")
            log.info("new connection id:%d addr:%s command_path:%s", id, addr, command_path)
            socket.start(id)

            pcall(httphandler.read_request, id, addr) 

            log.info("fd close id:%s", id)
            socket.close(id)
        end)

        if httphandler.init then
            httphandler.init()
        end
    end)
else
    skynet.start(function()
        local agent = {}
        for i= 1, agent_count do
            agent[i] = skynet.newservice(SERVICE_NAME, "agent", agent_count, server_port, command_path)
        end
        local id = socket.listen("0.0.0.0", server_port)
        log.info("httpserver listen web port " .. server_port)

        local balance = 1
        socket.start(id, function(id, addr)
            skynet.send(agent[balance], "lua", id, addr)
            balance = balance + 1
            if balance > #agent then
                balance = 1
            end
        end)

        log.info("httpserver start success!!!") 
    end)
end