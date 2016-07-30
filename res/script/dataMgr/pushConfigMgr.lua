--------------------------
-- file:dataMgr/pushConfigMgr.lua
-- 描述:推送配置管理
-- 消息：hp.MSG.PUSH_CONFIG {msgType:1-数据返回 2-设置推送}
-- =======================

-- obj
-- =======================
local pushConfigMgr = {}

-- 本地数据
-- =======================
-- 静态数据
local local_ServerStateMap = {[0]=3,[1]=2,[2]=1}
local local_LocalStateMap = {[1]=2,[2]=1,[3]=0}

-- 变量
local local_pushConfig = {}
local local_dirty = true
local local_newConfig = {}

-- 本地方法
-- =======================
local function updateConfig(info_)
	local_pushConfig = {}
	for i, v in ipairs(info_) do
		local_pushConfig[v[1]] = local_ServerStateMap[v[2]]
	end
	local_dirty = false
end

-- 网络消息处理
local function sendHttpCmd(type_, param_, callBack_)
	local oper = {}
	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			if type_ == 1 then
				updateConfig(data.mobileSend)
				hp.msgCenter.sendMsg(hp.MSG.PUSH_CONFIG, {msgType = 1})
			elseif type_ == 2 then
				for i, v in ipairs(local_newConfig) do
					local_pushConfig[v[1]] = local_ServerStateMap[v[2]]
				end
				local_newConfig = {}
				hp.msgCenter.sendMsg(hp.MSG.PUSH_CONFIG, {msgType = 2})
			end

			if callBack_ ~= nil then
				callBack_()
			end
		end	
	end

	local cmdData={operation={}}
	oper.channel = 28
	oper.type = type_
	for k, v in pairs(param_) do
		oper[k] = v
	end	
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	return cmdSender
end

-- =======================
-- 全局方法
-- =======================
function pushConfigMgr.create()
	-- body
end

-- 初始化
function pushConfigMgr.init()
	local_pushConfig = {}
	local_dirty = true
	local_newConfig = {}
end

function pushConfigMgr.initData(data_)
	-- body
end

-- 数据同步
function pushConfigMgr.syncData(data_)
end

function pushConfigMgr.heartbeat(dt_)
	-- body
end

-- =======================
-- 外部接口
-- =======================
-- 更新推送设置
function pushConfigMgr.httpReqChangePushConfig(config_)
	local needChange_ = false
	local_newConfig = {}
	-- 检查一次是否需要更新
	for k, v in pairs(config_) do
		if v ~= local_pushConfig[k] then
			local tmp_ = {}
			tmp_[1] = k
			tmp_[2] = local_LocalStateMap[v]
			table.insert(local_newConfig, tmp_)
			needChange_ = true
		end
	end

	if needChange_ then
		local param_ = {}
		param_.mobileSend = local_newConfig
		return sendHttpCmd(2, param_)
	else
		return nil
	end
end

function pushConfigMgr.httpReqRequestPushConfig()
	if local_dirty then
		sendHttpCmd(1, {})
	else
		-- 已经有数据
		hp.msgCenter.sendMsg(hp.MSG.PUSH_CONFIG, {msgType = 1})
	end
end

function pushConfigMgr.getPushConfig()
	return local_pushConfig
end

return pushConfigMgr