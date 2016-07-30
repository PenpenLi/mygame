----------------------------------------------------------------
-- file:dataMgr/activity/bossActivityMgr.lua
-- 描述:精英BOSS活动管理器
-- 消息:1.活动更新成功 2.活动开启 3.活动结束 4.boss刷新
-- =============================================================

-- 对象
-- ================================
local bossActivityMgr = {}

-- 私有数据
-- ================================

-- 活动数据
local activity
-- 请求周期
local request_time

-- 网络请求
local httpCmd = {
	ACTIVITY = 8,
}

-- 公有数据
-- ================================

-- 活动状态
BOSS_ACTIVITY_STATUS = {
	OPEN = 0,
	CLOSE = 1,
	NOT_OPEN = 2,
}

-- 私有函数
-- ================================

-- 解析活动
local function parseActivity(data)
	-- "sid":1001,"time":1417968000,"cd":1419436800,"cd1":1471193258
	activity = {}
	activity.sid = data.sid
	activity.beginTime = data.time
	activity.endTime = data.cd
	activity.refreshTime = data.cd1
	
	local time = player.getServerTime()

	if time > activity.endTime then
		activity.status = BOSS_ACTIVITY_STATUS.CLOSE
	elseif time < activity.beginTime then
		if activity.beginTime - time > 60 * 60 * 24 * 3 then
			activity.status = BOSS_ACTIVITY_STATUS.CLOSE
		else
			activity.status = BOSS_ACTIVITY_STATUS.NOT_OPEN
		end
	else
		activity.status = BOSS_ACTIVITY_STATUS.OPEN
	end

	hp.msgCenter.sendMsg(hp.MSG.BOSS_ACTIVITY, 1)
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
			parseActivity(data)
		elseif data.result == 1 then
			-- 活动未开启
			activity = nil
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
function bossActivityMgr.create()

end

-- 初始化
function bossActivityMgr.init()
	activity = {}
	activity.sid = 0
	activity.beginTime = 0
	activity.endTime = 0
	activity.refreshTime = 0
	activity.status = BOSS_ACTIVITY_STATUS.CLOSE --初始化关闭
	request_time = 60
end

-- 初始化网络数据
function bossActivityMgr.initData(data)
	sendHttpCmd(httpCmd.ACTIVITY)
end

-- 同步数据
function bossActivityMgr.syncData(data)
	
end

-- 心跳
function bossActivityMgr.heartbeat(dt)
	local time = player.getServerTime()
	if not activity then
		return;
	end
	if activity.status == BOSS_ACTIVITY_STATUS.NOT_OPEN then
		-- 活动开始
		if time >= activity.beginTime then
			activity.status = BOSS_ACTIVITY_STATUS.OPEN
			hp.msgCenter.sendMsg(hp.MSG.BOSS_ACTIVITY, 2)
		end
	elseif activity.status == BOSS_ACTIVITY_STATUS.OPEN then
		-- 活动结束
		if time > activity.endTime then
			activity.status = BOSS_ACTIVITY_STATUS.CLOSE
			hp.msgCenter.sendMsg(hp.MSG.BOSS_ACTIVITY, 3)
		end
	end
	if request_time > 0 then
		request_time = request_time - dt
	end
end

-- 对外接口
-- ================================

-- 刷新活动
function bossActivityMgr.updateActivity(ui)
	sendHttpCmd(httpCmd.ACTIVITY, ui)
end

-- 获取活动
function bossActivityMgr.getActivity()
	return activity
end

-- boss刷新时间
function bossActivityMgr.getTime()
	local time = activity.refreshTime - player.getServerTime()
	if time < 0 then
		if request_time <= 0 then
			sendHttpCmd(httpCmd.ACTIVITY)
			request_time = 60
		end
		return 0
	else
		return time
	end
end

return bossActivityMgr