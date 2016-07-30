--
-- file: scene/assist/kmapHttpHelper.lua
-- desc: 大地图网络数据
--================================================

local kmapHttpHelper = {}


-- private data
-- ==========================
local kmap = nil --大地图对象
local worldSize = player.serverMgr.getWorldSize() --世界的大小
local kWidth = 1 --一个国家的宽度
local kHeight = 1 --一个国家的高度
local viewRange = 1 --可视区域范围

-- 
local requireMap = {}

-- private function
-- ==========================
local function sendRequire(requireInfo)
	local serverInfo = requireInfo.serverInfo
	requireInfo.sendingFlag = true
	requireInfo.newFlag = false

	-- 创建设置HTTP请求
	local xhr = cc.XMLHttpRequest:new()
	local function onHttpResponse()
		if not requireInfo.newFlag then
		-- 无新请求，置空
			requireMap[serverInfo.sid] = nil
		else
		-- 还有新的请求，发送状态置为false
			requireInfo.sendingFlag = false
		end

		local status = xhr.status
		local response = xhr.response
		cclog("kmapHttpHelper === Http Status Code: %d", status)
		cclog("kmapHttpHelper === Http response: %s", response)
		if status~=200 then
			return
		end

		--解析json数据
		local dataResponse = json.decode(response, 1)
		kmap:onResponseMapInfo(serverInfo.x, serverInfo.y, requireInfo.x, requireInfo.y, viewRange, dataResponse)
		xhr:unregisterScriptHandler()

	end
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Accept-Language", "zh-CN")
	xhr:setRequestHeader("Accept-Encoding", "gzip, deflate")
	xhr.timeout = -1 --must -1
	xhr:registerScriptHandler(onHttpResponse)

	--发送请求数据
	local url = serverInfo.url .. config.server.cmdWorld
	local data = "type=1&x="..requireInfo.x .. "&y="..requireInfo.y .. "&range="..viewRange
	xhr:open("POST", url)
	xhr:send(data)

	cclog("kmapHttpHelper.url === %s", url)
	cclog("kmapHttpHelper.data === %s", data)
end

-- addRequire
-- 将一个请求放入请求表中
local function addRequire(kx_, ky_, x_, y_)
	local requireInfo = nil
	local serverInfo = player.serverMgr.getServerByPos(kx_, ky_)
	if serverInfo==nil then
		cclog("kmapHttpHelper Error: serverInfo=nil; kx_=%d, ky_=%d", kx_, ky_)
		return
	end
	if serverInfo.status~=0 then
	-- 状态为非正常服务器
		return
	end

	-- 每个服务器，每次只能有一个请求
	local ksid = serverInfo.sid
	requireInfo = requireMap[ksid]
	if requireInfo==nil then
	-- 如果表中没有，创建新的请求对象
		requireInfo = {}
		requireInfo.serverInfo = serverInfo
		requireInfo.sendingFlag = false --是否正在向此服务器发送请求
	end
	requireInfo.newFlag = true --新的请求
	requireInfo.x = x_
	requireInfo.y = y_

	requireMap[ksid] = requireInfo
end

-- public function
-- ==========================
-- init
-- 初始化
function kmapHttpHelper.init(kmap_)
	kmap = kmap_
	requireMap = {}

	local mapInfo = kmap.mapInfo.map
	kWidth = mapInfo.w*2
	kHeight = mapInfo.h
	viewRange = kmap.viewH
end

-- requireData
-- 请求数据
function kmapHttpHelper.requireData(tilePos_)
	local sendFlag = false
	--发送当前国家
	local kx = tilePos_.kx
	local ky = tilePos_.ky
	local x = tilePos_.x
	local y = tilePos_.y
	addRequire(kx, ky, x, y)
	if tilePos_.y<viewRange then
	-- 上面的国家
		ky = tilePos_.ky-1
		if ky>=1 then
			kx = tilePos_.kx
			x = tilePos_.x
			y = kHeight-1
			addRequire(kx, ky, x, y)
			sendFlag = true
		end
	elseif kHeight-tilePos_.y<viewRange then
	-- 下面的国家
		ky = tilePos_.ky+1
		if ky<=worldSize.height then
			kx = tilePos_.kx
			x = tilePos_.x
			y = 0
			addRequire(kx, ky, x, y)
			sendFlag = true
		end
	end
	if tilePos_.x<viewRange then
	-- 左边的国家
		kx = tilePos_.kx-1
		if kx>=1 then
			x = kWidth-1
			if sendFlag then
				addRequire(kx, ky, x, y)
			end
			ky = tilePos_.ky
			y = tilePos_.y
			addRequire(kx, ky, x, y)
		end
	elseif kWidth-tilePos_.x<viewRange then
	-- 右边的国家
		kx = tilePos_.kx+1
		if kx<=worldSize.width then
			x = 0
			if sendFlag then
				addRequire(kx, ky, x, y)
			end
			ky = tilePos_.ky
			y = tilePos_.y
			addRequire(kx, ky, x, y)
		end
	end
end

-- heartbeat
function kmapHttpHelper.heartbeat(dt)
	for ksid, requireInfo in pairs(requireMap) do
		if requireInfo.newFlag and (not requireInfo.sendingFlag) then
		-- 只有新请求 并且未向此服务器有请求时
			sendRequire(requireInfo)
		end
	end
end


return kmapHttpHelper
