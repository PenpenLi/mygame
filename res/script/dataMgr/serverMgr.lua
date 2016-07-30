 --
-- file: dataMgr/serverMgr.lua
-- desc: 服务器信息管理
--================================================


-- 对象
-- ================================
-- ********************************
local serverMgr = {}


-- 私有数据
-- ================================
-- ********************************
local mapServers = {} -- 服务器映射表
local openServerIndexs = {} --正常开启的服务器ID列表

-- 自己的服务器信息、位置坐标
local myPlatform = "test"
local myServerInfo = nil --我所在服务器信息
local myPosServerInfo = nil --我现在所处位置的服务器信息，跨服战到别的国家时候 和myServerInfo会不一样
local myPosition = cc.p(0, 0)
-- 纵向横向服务器个数
local mapWidth = 1
local mapHeight = 1


-- 私有函数
-- ================================
-- ********************************

--
-- initMapServers
-- 初始化服务器映射表
local function initMapServers()
	for _, mapInfo in ipairs(game.data.serverMap) do
		if mapInfo.x>mapWidth then
			mapWidth = mapInfo.x
		end
		if mapInfo.y>mapHeight then
			mapHeight = mapInfo.y
		end
		local server = hp.gameDataLoader.getInfoBySid("serverList", mapInfo.sid)
		server.x = mapInfo.x
		server.y = mapInfo.y
		if mapServers[mapInfo.y]==nil then
			mapServers[mapInfo.y] = {}
		end
		mapServers[mapInfo.y][mapInfo.x] = server

		cclog_("mapServers", mapInfo.y, mapInfo.x, server.name)
	end

	for index, serverInfo in ipairs(game.data.serverList) do
		if serverInfo.status==0 then
		-- 正常开启的服务器
			table.insert(openServerIndexs, index)
		end
	end
end


-- public function
-- ==========================


-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function serverMgr.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function serverMgr.init()
	-- body
end

-- initData
-- 使用玩家登陆数据进行初始化
function serverMgr.initData(data_)
	myServerInfo = serverMgr.getServerBySid(data_.serverID)
	myPosServerInfo = serverMgr.getServerBySid(data_.k)
	myPosition = cc.p(data_.x, data_.y)
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function serverMgr.syncData(data_)
	if data_.x~=nil and data_.y~=nil then
		if data_.k~=nil then
			serverMgr.moveCity(data_.x, data_.y, data_.k, true, data_.comeback)
		else
			serverMgr.moveCity(data_.x, data_.y, data_.serverID, nil, data_.comeback)
		end
	end
end

-- heartbeat
-- 心跳操作
function serverMgr.heartbeat(dt_)
	-- body
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

-- initBySDKplatform
-- 根据平台，加载服务器信息数据
function serverMgr.initBySDKplatform()
	mapServers = {}
	openServerIndexs = {}
	myServerInfo = nil
	myPosition = cc.p(0, 0)

	myPlatform = game.sdkHelper.getPlatformCode()

	cclog("serverMgr.initBySDKplatform -------------------%s", myPlatform)
	game.data.serverList    =    hp.gameDataLoader.loadFileData("data/serverInfo/".. myPlatform .."_ServerList.tab")
	game.data.serverMap     =    hp.gameDataLoader.loadFileData("data/serverInfo/".. myPlatform .."_ServerMap.tab")
	initMapServers()
end

-- getMyServer
-- 获取自己的服务器信息
function serverMgr.getMyServer()
	return myServerInfo
end

-- getMyPosServer
-- 获取自己所在位置的服务器信息
function serverMgr.getMyPosServer()
	return myPosServerInfo
end

-- getMyCountry
-- 获取所属国家 魏蜀吴
function serverMgr.getMyCountry()
	return hp.lang.getStrByID(myServerInfo.country)
end

-- getCountryByPos
-- 获取所属国家 魏蜀吴
function serverMgr.getCountryByPos(kx_, ky_)
	local kx = kx_
	local ky = ky_
	if ky_==nil then
		kx = kx_.kx
		ky = kx_.ky
	end

	return hp.lang.getStrByID(mapServers[ky][kx].country)
end

-- getMyPosition
-- 获取自己的坐标信息
function serverMgr.getMyPosition()
	return myPosition
end

-- getServerBySid
-- 通过服务器sid获取服务器信息
function serverMgr.getServerBySid(ksid_)
	for _, server in ipairs(game.data.serverList) do
		if ksid_==server.sid then
			return server
		end
	end

	return nil
end

-- getServerByName
-- 通过服务器名字获取服务器信息
function serverMgr.getServerByName(kname_)
	for _, server in ipairs(game.data.serverList) do
		if kname_==server.name then
			return server
		end
	end

	return nil
end

-- getServerByPos
-- 通过坐标获取服务器信息
function serverMgr.getServerByPos(kx_, ky_)
	return mapServers[ky_][kx_]
end

-- moveCity
-- 迁城
-- @x_:x坐标
-- @y_:y坐标
-- @ksid:迁往国家的id
-- @onlyPos_:跨服战时候使用，如果为true，只是位置迁往，不转服务器
-- @gotoPos_:如果在二级地图，去到这个位置
----------------------------------
function serverMgr.moveCity(x_, y_, ksid_, onlyPos_, gotoPos_)
	-- 迁服
	if ksid_~=nil then
		myPosServerInfo = serverMgr.getServerBySid(ksid_)
		if not onlyPos_ then
			myServerInfo = myPosServerInfo
			serverMgr.setMyServerID(myServerInfo.sid)
		end
	end
	
	-- 移动位置
	if x_~=nil and y_~=nil then
		myPosition = cc.p(x_, y_)
	end

	hp.msgCenter.sendMsg(hp.MSG.CITY_POS_CHANGED, {server=myPosServerInfo, position=myPosition})

	if gotoPos_ then
		if game.curScene.mapLevel == 2 then
			game.curScene:gotoPosition(myPosition)
		end
	end
end

-- getWorldSize
-- 获取世界地图大小
function serverMgr.getWorldSize()
	return cc.size(mapWidth, mapHeight)
end

-- isMyServer
-- 是否为自己的服务器
function serverMgr.isMyServer(kx_, ky_)
	if kx_~=myServerInfo.x or ky_~=myServerInfo.y then
		return false
	end

	return true
end

-- isMyPosServer
-- 是否为自己的服务器
function serverMgr.isMyPosServer(kx_, ky_)
	if kx_~=myPosServerInfo.x or ky_~=myPosServerInfo.y then
		return false
	end

	return true
end

-- randomServer
-- 随机一个服务器
function serverMgr.randomServer()
	local rIndex = 1
	if game.sdkHelper.getPlatformCode() ~= "test" then
		rIndex = openServerIndexs[math.random(#openServerIndexs)]
	end

	return game.data.serverList[rIndex]
end

-- 
-- formatMyPosition
-- 格式化自己的位置
function serverMgr.formatMyPosition(hideDes_)
	local strPos = string.format("K:%s X:%d Y:%d", myServerInfo.name, myPosition.x, myPosition.y)
	if hideDes_ then
		return strPos
	end

	return string.format(hp.lang.getStrByID(1905), strPos)
end

-- 
-- formatMyServerPosition
-- 格式化国家的位置
function serverMgr.formatMyServerPosition(pos_, hideDes_)
	local strPos = string.format("K:%s X:%d Y:%d", myServerInfo.name, pos_.x, pos_.y)
	if hideDes_ then
		return strPos
	end

	return string.format(hp.lang.getStrByID(1905), strPos)
end

--
-- formatPosition
-- 格式化一个位置
function serverMgr.formatPosition(kPos_, hideDes_)
	local strPos = string.format("K:%s X:%d Y:%d", serverMgr.getServerByPos(kPos_.kx, kPos_.ky).name, kPos_.x, kPos_.y)
	if hideDes_ then
		return strPos
	end

	return string.format(hp.lang.getStrByID(1905), strPos)
end

--
-- 获取自己的服务器id
function serverMgr.getMyServerID()
	if myServerInfo==nil or myServerInfo.status<0 then
		local udef = cc.UserDefault:getInstance()
		local serverID = udef:getIntegerForKey(myPlatform .. "_serverID", 0)
		if serverID<=0 then
		-- 如果没有选择个服务器，随机一个服务器
			myServerInfo = serverMgr.randomServer()
			udef:setIntegerForKey(myPlatform .. "_serverID", myServerInfo.sid)
			udef:flush()
		else
			myServerInfo = serverMgr.getServerBySid(serverID)
		end
	end

	return myServerInfo.sid
end

--
-- 设置自己的服务器id
function serverMgr.setMyServerID(serverID_)
	if serverID_~=myServerInfo.sid then
	-- 
		local udef = cc.UserDefault:getInstance()
		myServerInfo = serverMgr.getServerBySid(serverID_)
		udef:setIntegerForKey(myPlatform .. "_serverID", myServerInfo.sid)
		udef:flush()
	end
end

--
-- 获取自己服务器的url
function serverMgr.getMyServerAddress()
	serverMgr.getMyServerID()

	return myServerInfo.url
end


return serverMgr
