--------------------------
-- file:playerData/activity/soloActivityMgr.lua
-- 描述:单人活动管理
-- {msgType:1-请求历史 2-点数同步 3-活动结束 4-活动开启 5-数据刷新}
-- =======================

-- obj
-- =======================
local soloActivityMgr = {}

-- 本地数据
-- =======================
-- 静态数据
local TIMING_INTERVAL = 10

-- 变量
local local_activities = {}
local local_interval = 0
local local_historyDirty =true

-- 本地方法
-- =======================
-- 解析活动
local function parseActivity(info_)
	local activity_ = {}
	activity_.total = info_.cd - info_.time
	activity_.beginTime = info_.time
	activity_.endTime = info_.cd
	cclog_("sdhfihwerjnkdnkfkdj-------------=============",activity_.beginTime,player.getServerTime(),activity_.endTime-player.getServerTime())
	if activity_.endTime < player.getServerTime() then
		activity_.status = globalData.ACTIVITY_STATUS.CLOSE
	elseif activity_.beginTime > player.getServerTime() then
		activity_.status = globalData.ACTIVITY_STATUS.NOT_OPEN
		cclog_("notNOT_OPEN")
	else
		activity_.status = globalData.ACTIVITY_STATUS.OPEN
	end
	activity_.id = info_.sid
	activity_.point = info_.perScore
	activity_.info = hp.gameDataLoader.getInfoBySid("personalEvent", activity_.id)
	return activity_
end

-- 解析历史
local function parseHistory(info_)
	local history_ = {}
	history_.beginTime = info_[1]
	history_.endTime = info_[2]
	history_.player = {}
	for i, v in ipairs(info_[3]) do
		local player_ = {}
		player_.reward = v[4]
		player_.unionName = v[2]
		player_.name = v[1]
		player_.kingdom = v[3]
		player_.rank = i
		table.insert(history_.player, player_)
	end
	return history_
end

-- 历史数据处理
local function updateHistory(info_)
	history = {}
	if info_ == nil then
		return
	end

	for i, v in ipairs(info_) do
		local history_ = parseHistory(v)
		table.insert(history, history_)
	end

	-- 排序
	local function func(t1, t2)
		if t1.beginTime > t2.beginTime then
			return true 
		end
	end
	table.sort(history, func)
	hp.msgCenter.sendMsg(hp.MSG.SOLO_ACTIVITY, {msgType=1})
end

-- 数据更新
local function updateData(info_)
	cclog_("updateData")

	local_activities[1] = parseActivity(info_)
	hp.msgCenter.sendMsg(hp.MSG.SOLO_ACTIVITY, {msgType=5})
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
				updateData(data)
			elseif type_ == 2 then
				updateHistory(data.RANK)
				local_historyDirty = false
			end

			if callBack_ ~= nil then
				callBack_()
			end
		end	
	end

	local cmdData={operation={}}
	oper.channel = 23
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
function soloActivityMgr.create()
	-- body
end

-- 初始化
function soloActivityMgr.init()
	local_activities = {}
	local_interval = 0
	local_historyDirty = true
end

-- 数据初始化
function soloActivityMgr.initData(info_)
	sendHttpCmd(1, {})
end

-- 数据同步
function soloActivityMgr.syncData(data_)
	if data_.perScore ~= nil then
		cclog_("asdfasdf++++++++++++++++++++++++++----------------activity")
		if local_activities[1] ~= nil then
			local_activities[1].point = data_.perScore
			hp.msgCenter.sendMsg(hp.MSG.SOLO_ACTIVITY, {msgType=2})
		end
	end
end

function soloActivityMgr.heartbeat(dt_)
	local activity_ = local_activities[1]
	if activity_ == nil then
		return
	end

	local status_ = activity_.status
	if status_ == globalData.ACTIVITY_STATUS.CLOSE then		
		local_interval = local_interval + dt_
		if local_interval > TIMING_INTERVAL then
			sendHttpCmd(1, {})
			local_interval = 0
		end
		local_historyDirty = true
		return
	end

	if status_ == globalData.ACTIVITY_STATUS.OPEN then
		if activity_.endTime < player.getServerTime() then
			local_activities[1].status = globalData.ACTIVITY_STATUS.CLOSE
			hp.msgCenter.sendMsg(hp.MSG.SOLO_ACTIVITY, {msgType=3})
			return
		end
	else
		if activity_.beginTime < player.getServerTime() then
			local_activities[1].status = globalData.ACTIVITY_STATUS.OPEN
			hp.msgCenter.sendMsg(hp.MSG.SOLO_ACTIVITY, {msgType=4})
		end
	end
end

-- =======================
-- 外部接口
-- =======================
-- 历史请求
function soloActivityMgr.httpReqRequestHistory()
	if local_historyDirty then
		return sendHttpCmd(2, {})
	else
		hp.msgCenter.sendMsg(hp.MSG.SOLO_ACTIVITY, {msgType=1})
		return nil
	end
end

-- 获取活动
function soloActivityMgr.getActivity()
	return local_activities[1]
end

-- 获取历史
function soloActivityMgr.getHistory()
	return history
end

return soloActivityMgr