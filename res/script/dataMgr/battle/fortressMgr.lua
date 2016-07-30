--------------------------
-- file:playerData/battle/fortressMgr.lua
-- 描述:要塞信息管理
-- mstType:1-国王改变 2-授予头衔 3-活动结束 4-活动开启 5-数据刷新
-- =======================

-- obj
-- =======================
local fortressMgr = {}

-- 本地数据
-- =======================
-- 静态数据
local TIMING_INTERVAL = 300

local local_dirtyMark = true
local local_reference = {}
local local_interval = 0
local local_battleInfo = nil

-- 本地方法
-- =======================
-- 更新数据
local function updateData(info_)
	if info_ == nil then
		return
	end
	local table_ = {__index=function() return 0 end}
	setmetatable(info_, table_)
	-- 以前的国王
	local oldKingID_
	if local_battleInfo ~= nil then
		oldKingID_ = local_battleInfo.pid
	end
	local_battleInfo = {}
	local_battleInfo.startTime = info_[1]
	local_battleInfo.endTime = info_[2]
	local_battleInfo.totalTime = local_battleInfo.endTime - local_battleInfo.startTime
	cclog_("local_battleInfo.startTimebattleInfo.startTimebattleInfo.startTime",local_battleInfo.startTime, local_battleInfo.endTime, player.getServerTime())
	if local_battleInfo.startTime > player.getServerTime() then
		local_battleInfo.open = globalData.OPEN_STATUS.NOT_OPEN
	elseif local_battleInfo.endTime > player.getServerTime() then
		local_battleInfo.open = globalData.OPEN_STATUS.OPEN
	else
		local_battleInfo.open = globalData.OPEN_STATUS.CLOSE
	end
	local unionInfo_ = info_[3]
	setmetatable(unionInfo_, table_)
	local_battleInfo.unionID = unionInfo_[1]
	local_battleInfo.unionName = unionInfo_[2]
	local_battleInfo.pid = unionInfo_[3]
	local_battleInfo.king = unionInfo_[4]
	local_battleInfo.cityName = "成都"
	local_battleInfo.position = {x=unionInfo_[5],y=unionInfo_[6]}
	local_battleInfo.image = unionInfo_[7]
	local_battleInfo.sign = unionInfo_[8]
	local_battleInfo.level = unionInfo_[9]
	local_battleInfo.title = {}
	local_battleInfo.occupier = info_[4]
	local_battleInfo.occupierID = info_[5]
	local_battleInfo.occupierUnionID = info_[8]
	local titleList_ = {}
	for i, v in ipairs(info_[6]) do
		titleList_[v[1]] = v
	end
	local_battleInfo.occupierTime = info_[7]

	for i, v in ipairs(hp.gameDataLoader.getTable("kingTitle")) do
		if v.sid ~= 3001 then
			local title_ = {}
			title_.info = v
			title_.sid = v.sid
			local tmp_ = titleList_[v.sid]
			title_.granted = false		
			if tmp_ ~= nil then
				title_.pid = tmp_[2]
				title_.playerName = tmp_[3]
				title_.granted = true
			end
			table.insert(local_battleInfo.title, title_)
		end
	end
	-- 国王是否改变
	if oldKingID_ ~= local_battleInfo.pid then
		hp.msgCenter.sendMsg(hp.MSG.KING_BATTLE, {msgType=1})
	end
	local_dirtyMark = false
end

local function grantSuccess(sid_, name_, pid_)
	for i, v in ipairs(local_battleInfo.title) do
		if v.sid == sid_ then
			v.granted = true
			v.pid = pid_
			v.playerName = name_
			Scene.showMsg({1024})
			hp.msgCenter.sendMsg(hp.MSG.KING_BATTLE, {msgType=2, index=i})
			break
		end
	end
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
				updateData(data.king)
				hp.msgCenter.sendMsg(hp.MSG.KING_BATTLE, {msgType=5})
			elseif type_ == 2 then
				grantSuccess(param_.sid, param_.name, data.id)
			end

			if callBack_ ~= nil then
				callBack_()
			end
		end	
	end

	local cmdData={operation={}}
	oper.channel = 24
	oper.type = type_
	for k, v in pairs(param_) do
		oper[k] = v
	end	
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	return cmdSender
end

function requestData()
	sendHttpCmd(1, {})
end

-- =======================
-- 全局方法
-- =======================
function fortressMgr.create()
	-- body
end

-- 初始化
function fortressMgr.init()
	local_dirtyMark = true
	local_reference = {}
	local_interval = 0
	local_battleInfo = nil
end

-- 数据初始化
function fortressMgr.initData(info_)
	requestData()
end

-- 数据同步
function fortressMgr.syncData(data_)
	if data_.king == 1 then
		local_dirtyMark = true
		if hp.common.getTableTotalNum(local_reference) > 0 then
			requestData()
		end
	elseif data_.king == 2 then
		requestData()
	end
end

function fortressMgr.heartbeat(dt_)
	if local_battleInfo == nil then
		return
	end

	local status_ = local_battleInfo.open
	if status_ == globalData.OPEN_STATUS.CLOSE then		
		local_interval = local_interval + dt_
		if local_interval > TIMING_INTERVAL then
			requestData()
			local_interval = 0
		end
		return
	end

	if status_ == globalData.OPEN_STATUS.OPEN then
		if local_battleInfo.endTime < player.getServerTime() then
			local_battleInfo.open = globalData.OPEN_STATUS.CLOSE
			hp.msgCenter.sendMsg(hp.MSG.KING_BATTLE, {msgType=3})
			return
		end
	else
		if local_battleInfo.startTime < player.getServerTime() then
			local_battleInfo.open = globalData.OPEN_STATUS.OPEN
			hp.msgCenter.sendMsg(hp.MSG.KING_BATTLE, {msgType=4})
		end
	end
end

-- =======================
-- 外部接口
-- =======================
-- 网络请求
function fortressMgr.httpReqGrantTitle(sid_, name_)
	local cmdSender = sendHttpCmd(2, {sid=sid_, name=name_})
	return cmdSender
end

function fortressMgr.subscribeData(name_)
	local_reference[name_] = 1
	if local_dirtyMark then
		requestData()
	end
end

function fortressMgr.unSubscribeData(name_)
	if local_reference[name_] == 1 then
		local_reference[name_] = nil
	end
end

-- 获取重镇信息
function fortressMgr.getFortressInfo()
	return local_battleInfo
end

return fortressMgr