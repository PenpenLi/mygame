--------------------------
-- file:scene/assist/worldHttpHelper.lua
-- 描述:世界地图辅助
-- 消息：WORLD_MAP: msgType={1-数据请求}
-- =======================

-- obj
-- =======================
local worldHttpHelper = {}

-- 本地数据
-- =======================
local local_worldInfo = {}

-- 本地方法
-- =======================
-- 解析一个服务器信息
local function parseOneServer(info_)
	local server_ = {}
	server_.sid = info_[1]
	server_.kingUnion = info_[2]
	server_.king = info_[3]
	server_.createTime = info_[4]
	server_.title = 0					-- 头衔
	server_.serverState = 0				-- 服务器状态
	return server_
end

-- 解析服务器信息
local function updateWorldInfo(info_)
	local_worldInfo = {}
	-- for i, v in ipairs(hp.gameDataLoader.getTable("serverList")) do
	-- 	local_worldInfo[v.sid] = parseOneServer(v)
	-- end
	for i, v in ipairs(info_) do
		local_worldInfo[v[1]] = parseOneServer(v)
	end
end

-- 网络消息处理
local function sendHttpCmd(type_, param_, callBack_)
	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			if type_ == 10 then
				updateWorldInfo(data.king)
				hp.msgCenter.sendMsg(hp.MSG.WORLD_INFO, {msgType = 1})
			end

			if callBack_ ~= nil then
				callBack_()
			end
		end	
	end	

	local cmdData={}
	cmdData.type = 10
	for k, v in pairs(param_) do
		cmdData[k] = v
	end	
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld)
	return cmdSender
end

-- =======================
-- 外部接口
-- =======================
function worldHttpHelper.init()
	local_worldInfo = {}
end

function worldHttpHelper.httpReqWorldInfo()
	local param_ = {}
	return sendHttpCmd(10, param_)
	-- updateWorldInfo()
	-- hp.msgCenter.sendMsg(hp.MSG.WORLD_INFO, {msgType = 1})
end

function worldHttpHelper.getWorldInfo()
	return local_worldInfo
end

return worldHttpHelper