local skynet = require "skynet"
local log    = require "common.lib.log"
local urllib = require "http.url"
local request= require "httpserver.modules.request"
require "lfs"

local root = "../web/static"
local cache_interval = 10 -- the interval of file cache is 10s

local cache = {}
local static_cache_mt = { 
	__index = function(t, k) 
		local v = cache[k]
		if v and skynet.time() < v.expired then 
			return v.content
		end 

		if not v then 
			v = {}
			v.modification = 0
			v.expired = 0
			v.content = nil
		end

		local filehandle = io.open(root .. k)	
		if filehandle then 
			local t = lfs.attributes(root .. k, "modification")
			if t <= v.modification then 
				filehandle:close()
				v.expired = skynet.time() + cache_interval
				return assert(v.content)
			end 

			v.content = filehandle:read("*a")
			v.expired = skynet.time() + cache_interval 
			v.modification = t

			cache[k] = v 
			filehandle:close()

			return v.content
		else 
			return nil 
		end
	end
}

local staticfiles = setmetatable({}, static_cache_mt)

local httpmethods = {}

local function do_request(method_name, params)
	local func = request[method_name]
	if not func then 
		return 501
	end

	local nparams = debug.getinfo(func, 'u').nparams
	local p = {}
	for i = 1, nparams do 
		p[i] = params[debug.getlocal(func, i)]
	end 
	return func(table.unpack(p, 1, nparams))
end

-- the reference of difference between get and post methods in http 
-- https://javarevisited.blogspot.com/2012/03/get-post-method-in-http-and-https.html#axzz6j1CJBLxh
function httpmethods.GET(id, path, query)
	if query and query ~= "" then -- invoke a method
		local q = nil
		q = urllib.parse_query(query) 
		local method_name = q["method"]
		if not method_name then 
			return 501 
		end

		return do_request(method_name, q)	
	else -- get a resource
		if path == "/" then 
			path = "/index.html"
		end 
		local content = staticfiles[path]
		if content then 
			return 200, content
		else 
			return 404
		end
	end 
end

function httpmethods.HEAD(id, path, query)
end 

function httpmethods.POST(id, path, query, body)
	local method_name = body["method"]
	if not method_name then 
		return 501 
	end 

	return do_request(method_name, body)
end

function httpmethods.PUT(id, path, query, body)
end

function httpmethods.DELETE(id, path)
end

function httpmethods.OPTIONS(id)
end

return httpmethods