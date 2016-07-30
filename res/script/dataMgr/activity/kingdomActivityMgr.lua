----------------------------------------------------------------
-- file:dataMgr/activity/kingdomActivityMgr.lua
-- 描述:王国活动管理
-- 消息:1.活动更新成功 2.历史记录更新成功 3.活动开启 4.活动结束
-- =============================================================

-- 对象
-- ================================
local kingdomActivityMgr = {}

-- 私有数据
-- ================================

-- 活动数据
local activity
local history
-- 请求周期
local request_time
-- 首次请求（历史记录）
local frist_request


-- 网络请求
local httpCmd = {
	ACTIVITY = 6,
	HISTORY = 7,
}

-- 公有数据
-- ================================

-- 活动状态
KINGDOM_ACTIVITY_STATUS = {
	OPEN = 0,
	CLOSE = 1,
	NOT_OPEN = 2,
}


-- 私有函数
-- ================================

-- 解析活动
local function parseActivity(data)
	-- "serverID":2,"sid":101,"time":1414159,"cd":1414328,"leaScore":0,"perScore":0
	activity = {}
	activity.serverID = data.serverID
	activity.sid = data.sid
	activity.totalTime = data.cd - data.time
	activity.beginTime = data.time
	activity.endTime = data.cd
	activity.perScore = data.perScore

	-- 联盟积分
	if data.leaScore then
		activity.unionScore = data.leaScore
	else
		activity.unionScore = 0
	end

	local time = player.getServerTime()

	if activity.endTime < time then
		activity.status = KINGDOM_ACTIVITY_STATUS.CLOSE
	elseif activity.beginTime > time then
		activity.status = KINGDOM_ACTIVITY_STATUS.NOT_OPEN
	else
		activity.status = KINGDOM_ACTIVITY_STATUS.OPEN
	end

	hp.msgCenter.sendMsg(hp.MSG.KINGDOM_ACTIVITY, 1)
end

-- 解析历史
local function parseHistory(data)
	-- "RANK":[  [1414214580,1414383780,2,1,0,0,[],[]] , [1414401600,1414570800,2,1,0,0,[],[]]  ]
	for i,v1 in ipairs(data.RANK) do
		local history_ = {}
		history_.beginTime = v1[1]
		history_.endTime = v1[2]
		-- 胜负结果
		if v1[5] == v1[6] then
			history_.result = 0
		elseif v1[5] > v1[6] then
			history_.result = 1
		else
			history_.result = 2
		end
		history_.serverID1 = v1[3]
		history_.serverID2 = v1[4]
		history_.personRank = v1[7]
		history_.unionRank = v1[8]
		table.insert(history, history_)
	end

	hp.msgCenter.sendMsg(hp.MSG.KINGDOM_ACTIVITY, 2)
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
			end
			if type_ == httpCmd.HISTORY then
				parseHistory(data)
			end
		elseif data.result == 1 then
			-- 活动未开启
			activity = nil
			hp.msgCenter.sendMsg(hp.MSG.KINGDOM_ACTIVITY, 1)
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
function kingdomActivityMgr.create()

end

-- 初始化
function kingdomActivityMgr.init()
	activity = {}
	activity.serverID = 0
	activity.sid = 0
	activity.totalTime = 0
	activity.beginTime = 0
	activity.endTime = 0
	activity.perScore = 0
	activity.unionScore = 0
	activity.status = KINGDOM_ACTIVITY_STATUS.CLOSE --初始化关闭
	request_time = 300
	history = {}
	frist_request = true
end

-- 初始化网络数据
function kingdomActivityMgr.initData(data)
	sendHttpCmd(httpCmd.ACTIVITY)
end

-- 同步数据
function kingdomActivityMgr.syncData(data)
	
end

-- 心跳
function kingdomActivityMgr.heartbeat(dt)
	-- 请求周期递减
	if request_time > 0 then
		request_time = request_time - dt
	end

	if activity == nil then
		-- 重新请求活动信息
		if request_time <= 0 then
			request_time = 300
			sendHttpCmd(httpCmd.ACTIVITY)
		end
	else
		local time
		
		if activity.status == KINGDOM_ACTIVITY_STATUS.OPEN then
			time = activity.endTime - player.getServerTime()
			-- 活动结束
			if time <= 0 then
				request_time = 300
				-- 更新活动
				sendHttpCmd(httpCmd.ACTIVITY)
				-- 重置历史记录请求
				frist_request = true
				activity.status = KINGDOM_ACTIVITY_STATUS.CLOSE
				hp.msgCenter.sendMsg(hp.MSG.KINGDOM_ACTIVITY, 4)
			end
		elseif activity.status == KINGDOM_ACTIVITY_STATUS.NOT_OPEN then
			time = activity.beginTime - player.getServerTime()
			-- 活动开始
			if time <= 0 then
				activity.status = KINGDOM_ACTIVITY_STATUS.OPEN

				hp.msgCenter.sendMsg(hp.MSG.KINGDOM_ACTIVITY, 3)
			end
		end
	end
end

-- 对外接口
-- ================================

-- 获取活动
function kingdomActivityMgr.getActivity()
	return activity
end

-- 活动更新
function kingdomActivityMgr.updateActivity(ui)
	sendHttpCmd(httpCmd.ACTIVITY, ui)
end

-- 活动剩余时间
function kingdomActivityMgr.getTime()
	local time = 0

	if activity.status == KINGDOM_ACTIVITY_STATUS.OPEN then
		time = activity.endTime - player.getServerTime()
	elseif activity.status == KINGDOM_ACTIVITY_STATUS.NOT_OPEN then
		time = activity.beginTime - player.getServerTime()
	end

	if time > 0 then
		return time
	else
		return 0
	end
end

-- 获取历史记录
function kingdomActivityMgr.getHistory()
	return history
end

-- 更新历史记录
function kingdomActivityMgr.updateHistory(ui)
	if frist_request then
		sendHttpCmd(httpCmd.HISTORY, ui)
		frist_request = false
	else
		hp.msgCenter.sendMsg(hp.MSG.KINGDOM_ACTIVITY, 2)
	end
end

return kingdomActivityMgr