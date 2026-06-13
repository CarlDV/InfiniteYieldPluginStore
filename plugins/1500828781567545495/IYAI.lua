local GITHUB_BASE_URL = "https://raw.githubusercontent.com/imluri/IYAI/main/IYAI"

local function httpGet(url)
	local p = { Url = url, Method = "GET" }
	local ok, res
	if syn and syn.request then
		ok, res = pcall(syn.request, p)
	elseif request then
		ok, res = pcall(request, p)
	else
		return nil, "No HTTP function available"
	end
	if not ok                                    then return nil, "Request error: " .. tostring(res) end
	if not res or not res.Body or res.Body == "" then return nil, "Empty response" end
	if res.StatusCode and res.StatusCode ~= 200  then return nil, "HTTP " .. tostring(res.StatusCode) end
	return res.Body, nil
end

local src, err = httpGet(GITHUB_BASE_URL .. "/IYAI_Core.iy")
if not src then error("[IYAI] Failed to fetch core: " .. tostring(err)) end

local fn, ce = loadstring(src)
if not fn then error("[IYAI] Compile error: " .. tostring(ce)) end

local coreFn = fn()
if type(coreFn) ~= "function" then error("[IYAI] Core must return a function.") end

local Plugin = coreFn(GITHUB_BASE_URL)
if type(Plugin) ~= "table" then error("[IYAI] Core did not return a Plugin table.") end

return Plugin
