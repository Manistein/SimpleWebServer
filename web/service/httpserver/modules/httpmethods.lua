local skynet = require "skynet"
local log    = require "common.lib.log"
local urllib = require "http.url"
local request= require "httpserver.modules.request"
local md5    = require "httpserver.modules.md5"
local const  = require "common.define.const"
local cjson  = require "cjson"
require "lfs"

local root = "../web/static"
local cache_interval = 5 * 60  

local function new_cache_object(k)
	local v = {}
	v.modification = 0
	v.expired = 0
	v.content = nil

	local filehandle = io.open(root .. k)	
	if filehandle then 
		local t = lfs.attributes(root .. k, "modification")
		v.content = filehandle:read("*a")
		v.expired = skynet.time() + cache_interval 
		v.modification = t

		filehandle:close()
		return v
	else 
		return nil 
	end
end

local cache = {}
local static_cache_mt = { 
	__index = function(t, k) 
		local v = cache[k]
		if v then 
			local t = lfs.attributes(root .. k, "modification")
			if t and t <= v.modification then 
				return v
			else 
				cache[k] = new_cache_object(k)
				return cache[k] 
			end 
		end

		cache[k] = new_cache_object(k)
		return cache[k]
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

local function get_header(path, v)
	local extension = path:match("^.+(%..+)$")
	log.info("path:%s extension:%s", path, extension)

	local header = nil 
	local content_type = const.extension2content_type[string.lower(extension:sub(2))]
	if content_type then 
		header = {}
		header["Content-Type"] = content_type
	end 

	local other_head = header or {}
	-- Notice:if you forget to assgin a value to ETag
	-- then the next request from browser will not contain
	-- if-none-match attribute in header 
	other_head.ETag = v.modification
	header = other_head

	return header
end 

local function process_path(path)
	if path == "/" then 
		path = "/index.html"
	end 

	local extension = path:match("^.+(%..+)$")
	if not extension then 
		path = path .. ".html"
	end 

	return path
end 

-- the reference of difference between get and post methods in http 
-- https://javarevisited.blogspot.com/2012/03/get-post-method-in-http-and-https.html#axzz6j1CJBLxh
function httpmethods.GET(id, path, query, body, header)
	if query and query ~= "" then -- invoke a method
		local q = nil
		q = urllib.parse_query(query) 
		local method_name = q["method"]
		if not method_name then 
			return 501 
		end

		return do_request(method_name, q)	
	else -- get a resource
		path = process_path(path)
		log.info("fd:%d try search file", id)
		local v = staticfiles[path]
		if v then 
			log.info("fd:%d file exist", id)
			log.info("fd:%d r_tag:%s f_tag:%s", id, header["if-none-match"], v.modification)

			if header["if-none-match"] and 
			   header["if-none-match"] == tostring(v.modification) then 
			   	log.info("fd:%d no modified", id)
				return 304 -- not modified
			end 

			if not v.content then 
				v = new_cache_object(path)
				cache[path] = v 
			end

			local h = get_header(path, v)
			log.info("response header %s", cjson.encode(h))
			log.info("response content type %s", type(v.content))
			return 200, v.content, h 
		else 
			return 404
		end
	end 
end

function httpmethods.HEAD(id, path, query)
	path = process_path(path)
	local v = staticfiles[path]
	if not v then 
		return 404
	end 

	return 200, nil, get_header(path, v)
end 

function httpmethods.POST(id, path, query, body)
	local method_name = body["method"]
	if not method_name then 
		return 501 
	end 

	return do_request(method_name, body)
end

-- TODO
function httpmethods.PUT(id, path, query, body)
	return 501
end

-- TODO
function httpmethods.DELETE(id, path)
	return 501
end

function httpmethods.OPTIONS(id)
	local header = {}	
	local func_str = ""

	for k, v in pairs(const.HTTP_METHODS) do 
		if func_str ~= "" then 
			func_str = func_str .. ","
		end 
		func_str = func_str .. v
	end

	header["Allow"] = func_str
	return 200, nil, header
end

function httpmethods.update(now)
	for k, v in pairs(cache) do 
		if now >= v.expired then 
			v.content = nil 
		end 
	end 
end

return httpmethods