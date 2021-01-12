local skynet = require "skynet"

skynet.start(function() 
	skynet.error("web server is booting...")

	-- create httpserver service
	skynet.uniqueservice("httpserver", "server", 8, 8080, "httpserver.modules.httphandler")

	skynet.error("web server boots success!")
	skynet.exit()
end)