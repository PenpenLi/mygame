-------------------------------------------------------
-- file:dataMgr/activity/unionActivityMgr.lua
-- 描述:联盟活动管理
-- 消息：1.活动 2.成员 3.历史记录 4.刷新 5.开启 6.结束
-- ====================================================

-- 对象
-- ================================
local unionActivityMgr = {}

-- 私有数据
-- ================================
local activity
local request_time = 60
local request_history = true

local httpCmd = {
	ACTIVITY = 3,
	HISTORY = 4,
	MEMBERLIST = 5,
}

-- 公有数据
-- ================================
UNION_ACTIVITY_STATUS = {
	OPEN = 0,
	CLOSE = 1,
	NOT_OPEN = 2,
}

UNION_ACTIVITY_PAGE = 0

-- 私有函数
-- ================================

-- 解析活动
local function parseActivity(data)
	activity.sid = data.sid
	activity.totalTime = data.cd - data.time
	activity.beginTime = data.time
	activity.endTime = data.cd
	activity.score = data.leaScore

	-- 活动状态
	local time = player.getServerTime()

	if activity.endTime < time then
		activity.status = UNION_ACTIVITY_STATUS.CLOSE
	elseif activity.beginTime > time then
		activity.status = UNION_ACTIVITY_STATUS.NOT_OPEN
	else
		activity.status = UNION_ACTIVITY_STATUS.OPEN
	end
end

-- 解析历史
local function parseHistory(data)
	activity.history = data.RANK
end

-- 解析成员列表
local function parseMemberList(data)
	activity.member = data.leaScore
end

-- 网络消息处理
local function sendHttpCmd(type_, ui_)
	local oper = {}
	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			if type_ == httpCmd.ACTIVITY then
				parseActivity(data)
				hp.msgCenter.sendMsg(hp.MSG.UNION_ACTIVITY, 1)
			end
			if type_ == httpCmd.HISTORY then
				parseHistory(data)
				hp.msgCenter.sendMsg(hp.MSG.UNION_ACTIVITY, 3)
			end
			if type_ == httpCmd.MEMBERLIST then
				parseMemberList(data)
				hp.msgCenter.sendMsg(hp.MSG.UNION_ACTIVITY, 2)
			end
		end	
	end

	local cmdData={operation={}}
	oper.channel = 23
	oper.type = type_
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	if ui_ then
		ui_:showLoading(cmdSender)
	end
end

-- player调用接口函数
-- ================================

-- 构造函数
function unionActivityMgr.create()

end

-- 初始化
function unionActivityMgr.init()
	activity = {}
	activity.sid = 0
	activity.totalTime = 0
	activity.beginTime = 0
	activity.endTime = 0
	activity.score = 0
	activity.status = UNION_ACTIVITY_STATUS.CLOSE
	activity.history = {}
	activity.member = {}
end

-- 初始化网络数据
function unionActivityMgr.initData(data)
	sendHttpCmd(httpCmd.ACTIVITY)
end

-- 同步数据
function unionActivityMgr.syncData(data)
	
end

-- 心跳
function unionActivityMgr.heartbeat(dt)
	if activity.status == UNION_ACTIVITY_STATUS.OPEN then
		-- 活动结束
		if activity.endTime < player.getServerTime() then
			request_history = true
			activity.status = UNION_ACTIVITY_STATUS.CLOSE
			hp.msgCenter.sendMsg(hp.MSG.UNION_ACTIVITY, 6)
		end
	elseif activity.status == UNION_ACTIVITY_STATUS.NOT_OPEN then
		-- 活动开始
		if activity.beginTime <= player.getServerTime() then
			activity.status = UNION_ACTIVITY_STATUS.OPEN
			hp.msgCenter.sendMsg(hp.MSG.UNION_ACTIVITY, 5)
		end
	elseif request_time <= 0 then
		sendHttpCmd(httpCmd.ACTIVITY)
		request_time = 60
	else
		request_time = request_time - dt
	end
end

-- 对外接口
-- ================================

-- 刷新并获取成员列表
function unionActivityMgr.updateMember(ui_)
	sendHttpCmd(httpCmd.MEMBERLIST, ui_)
end

-- 刷新历史记录
function unionActivityMgr.updateHistory(ui_)
	if request_history then
		request_history = false
		sendHttpCmd(httpCmd.HISTORY, ui_)
	else
		hp.msgCenter.sendMsg(hp.MSG.UNION_ACTIVITY, 3)
	end
end

-- 获取活动
function unionActivityMgr.getActivity()
	return activity
end

-- 刷新活动
function unionActivityMgr.updateActivity(ui_)
	sendHttpCmd(httpCmd.ACTIVITY, ui_)
end

return unionActivityMgr