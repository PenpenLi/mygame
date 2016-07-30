--------------------------
-- file:playerData/copyManager.lua
-- 描述:副本管理器
-- 消息：COPY_NOTIFY: msgType={1-开启新副本 2-星级改变 3-完成关卡 4-领奖成功 5-奖励改变 6-体力变化 7-开启副本组 8-战斗结束}
-- =======================

-- obj
-- =======================
local copyManager = {}

local GIFTSTATE = {
	INVALID = 0,
	VALID	= 1,
	OPENED	= 2
}

-- 本地数据
-- =======================
local local_copyGroup = {}
local local_copies = {}	-- 全局副本管理
local local_dirty = true
local local_groupNum = 0

-- 本地方法
-- =======================
-- 解析副本
local function parseCopy(info_)
	cclog_("parseCopy")
	local copy_ = {}
	copy_.id = info_[1]
	copy_.open = true
	copy_.times = 0
	copy_.star = info_[2]
	copy_.info = hp.gameDataLoader.getInfoBySid("instance", copy_.id)
	copy_.limited = -1
	copy_.attackTimes = info_[3]
	copy_.remainPower = info_[4]
	local totalPower = 0
	for i, v in ipairs(copy_.info.branchNums) do
		if v ~= 0 then
			local solInfo_ = nil
			local point_ = 0
			if i == 5 then
				solInfo_ = hp.gameDataLoader.getInfoBySid("trap", copy_.info.branchSids[i])
				point_ = solInfo_.point
			else
				solInfo_ = hp.gameDataLoader.getInfoBySid("army", copy_.info.branchSids[i])
				point_ = solInfo_.addPoint
			end

			-- 战力计算
			local power_ = v * point_
			totalPower = totalPower + power_
		end
	end
	copy_.power = totalPower
	-- if copy_.info.type == 1 then
	-- 	copy_.limited = 3
	-- end
	return copy_
end

local function defaultCopy(sid_)
	local copy_ = {}
	copy_.id = sid_
	copy_.open = false
	copy_.times = 0
	copy_.star = 0
	copy_.info = hp.gameDataLoader.getInfoBySid("instance", copy_.id)
	copy_.limited = -1
	copy_.attackTimes = 0
	copy_.remainPower = -1
	local totalPower = 0
	for i, v in ipairs(copy_.info.branchNums) do
		if v ~= 0 then
			local solInfo_ = nil
			local point_ = 0
			if i == 5 then
				solInfo_ = hp.gameDataLoader.getInfoBySid("trap", copy_.info.branchSids[i])
				point_ = solInfo_.point
			else
				solInfo_ = hp.gameDataLoader.getInfoBySid("army", copy_.info.branchSids[i])
				point_ = solInfo_.addPoint
			end

			-- 战力计算
			local power_ = v * point_
			totalPower = totalPower + power_
		end
	end
	copy_.power = totalPower
	-- if copy_.info.type == 1 then
	-- 	copy_.limited = 3
	-- end
	return copy_
end

-- 解析副本组
local function parseCopyGroup(info_)
	cclog_("parseCopyGroup")
	local copyGroup_ = {}
	copyGroup_.id = info_[1]
	copyGroup_.open = true
	copyGroup_.star = 0
	copyGroup_.gift = {}
	copyGroup_.copies = {}
	copyGroup_.clear = true

	for i, v in ipairs(info_[3]) do
		local copy_ = parseCopy(v)
		copy_.groupID = copyGroup_.id
		copyGroup_.star = copyGroup_.star + copy_.star
		copyGroup_.copies[copy_.id] = copy_
		local_copies[copy_.id] = copy_
	end

	for i, v in ipairs(hp.gameDataLoader.getTable("instance")) do
		if math.floor(v.sid/100) == copyGroup_.id then
			if copyGroup_.copies[v.sid] == nil then
				local copy_ = defaultCopy(v.sid)
				copyGroup_.copies[v.sid] = copy_
				local_copies[copy_.id] = copy_
				copyGroup_.copies[v.sid].groupID = copyGroup_.id
			end
		end
	end

	copyGroup_.info = hp.gameDataLoader.getInfoBySid("instanceGroup", copyGroup_.id)

	-- 宝箱状态修改
	for i = 1, 3 do
		local state_ = hp.common.band(info_[2], math.pow(2, i - 1))
		if state_ == 0 then
			if copyGroup_.star >= copyGroup_.info.giftStar[i] then
				copyGroup_.gift[i] = GIFTSTATE.VALID
			else
				copyGroup_.gift[i] = GIFTSTATE.INVALID
			end
		else
			copyGroup_.gift[i] = GIFTSTATE.OPENED
		end
	end
	return copyGroup_
end

local function defaultGroup(sid_)
	local info_ = hp.gameDataLoader.getInfoBySid("instanceGroup", sid_)
	if info_ == nil then
		return nil
	end

	local copyGroup_ = {}
	copyGroup_.info = info_
	copyGroup_.id = sid_
	copyGroup_.open = false
	copyGroup_.star = 0
	copyGroup_.gift = {}
	copyGroup_.copies = {}
	copyGroup_.clear = false

	-- 宝箱状态修改
	for i = 1, 3 do
		copyGroup_.gift[i] = GIFTSTATE.INVALID
	end
	return copyGroup_
end

-- 开启关卡
local function openStage(sid_)
	if local_copies[sid_] == nil then
		cclog_(string.format("openStage error, sid:%d not exist!", sid_))
	else
		local_copies[sid_].open = true
		Scene.showMsg({1019, local_copies[sid_].info.name})
		hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 1, id = sid_})
	end
end

-- 开启副本组
local function openCopyGroup(info_)
	local group_ = parseCopyGroup(info_)
	group_.clear = false
	-- 前置副本通关
	local pre_ = local_copyGroup[group_.info.preSid]
	if pre_ ~= nil then
		pre_.clear = true
	end

	if local_copyGroup[group_.id] ~= nil then
		cclog_(string.format("openCopyGroup error, sid:%d already exist!", group_.id))
	else
		local_copyGroup[group_.id] = group_
		Scene.showMsg({1020, group_.info.name})
	end
	return group_.id
end

-- 评定星级
local function evaluateStar(sid_, star_)
	local info_ = local_copies[sid_]
	local delta_ = star_ - info_.star
	if delta_ > 0 then
		local oldState_ = local_copyGroup[info_.groupID].gift
		local gift_ = {}
		info_.star = star_
		local curStar_ = local_copyGroup[info_.groupID].star + delta_
		cclog_("info_.groupID",info_.groupID)
		local_copyGroup[info_.groupID].star = curStar_

		-- 增加星星后，宝箱情况
		local indexList = {}
		for i, v in ipairs(oldState_) do
			gift_[i] = v
			if v == GIFTSTATE.INVALID then
				if curStar_ >= local_copyGroup[info_.groupID].info.giftStar[i] then
					-- 状态改变-激活
					gift_[i] = GIFTSTATE.VALID
					table.insert(indexList, i)
				end
			end
		end

		local_copyGroup[info_.groupID].gift = gift_
		for i, v in ipairs(indexList) do
			hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 5, index = v, gsid = info_.groupID})
		end
		hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 2, id = sid_, star = star_})
	end
end

-- 数据更新
local function updateData(info_)
	cclog_("updateData")
	local id_ = 0
	-- 基本数据,不完全加载
	for i, v in ipairs(info_.jihadM) do
		local group_ = parseCopyGroup(v)
		local_copyGroup[group_.id] = group_

		if id_ < group_.id then
			id_ = group_.id
		end
	end

	local_copyGroup[id_].clear = false

	-- 处理次数
	-- if info_.jihadC ~= nil then
	-- 	for i = 1, math.floor(table.getn(info_.jihadC)/2) do
	-- 		local_copies[info_.jihadC[i]].times = info_.jihadC[i+1]
	-- 	end
	-- end
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
			if type_ == 2 then
				cclog_(1)
			elseif type_ == 3 then
				if data.prop ~= nil then
					-- player.addItem(data.prop, 1)
					
					local info_ = hp.gameDataLoader.getItemByID(data.prop)
					if info_ ~= nil then
						Scene.showMsg({1021, info_.name, 1})
					end
				end
				local index_ = oper.index + 1
				local_copyGroup[oper.id].gift[index_] = GIFTSTATE.OPENED
				hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 4, index = index_, gsid = oper.id})
			end

			if callBack_ ~= nil then
				callBack_()
			end
		end	
	end

	local cmdData={operation={}}
	oper.channel = 21
	oper.type = type_
	for k, v in pairs(param_) do
		oper[k] = v
	end	
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	return cmdSender
end

local function requestCopyData()
	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			updateData(data)
			local_dirty = false
			hp.msgCenter.sendMsg(hp.MSG.COPY_DATA_REQUEST)
		end	
	end

	local oper = {}
	local cmdData={operation={}}
	oper.channel = 21
	oper.type = 1
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	return cmdSender
end

-- =======================
-- 全局方法
-- =======================
function copyManager.create()
	-- body
end

-- 初始化
function copyManager.init()
	local_copyGroup = {}
	local_copies = {}	-- 全局副本管理
	local_groupNum = table.getn(hp.gameDataLoader.getTable("instanceGroup"))
	local_dirty = true
end

function copyManager.initData(data_)
	-- body
end

-- 数据同步
function copyManager.syncData(data_)
end

function copyManager.heartbeat(dt_)
	-- body
end

-- =======================
-- 外部接口
-- =======================
function copyManager.httpReqGetTreasure(sid_, gift_)
	local param_ = {}
	param_.id = sid_
	param_.index = gift_ - 1
	local cmdSender = sendHttpCmd(3, param_, callBack_)
	return cmdSender
end

function copyManager.prepareData()
	if local_dirty == false then
		hp.msgCenter.sendMsg(hp.MSG.COPY_DATA_REQUEST)
	else
		return requestCopyData()
	end
end

-- 获得当前副本组的当前副本
function copyManager.getLastCopyInGroup(groupID_)
	local copies_ = {}
	local group_ = local_copyGroup[groupID_]
	if group_ == nil then
		return copies_
	end

	if group_.clear == nil then
		return copies_
	end

	local lastCopy_ = nil
	for i, v in pairs(group_.copies) do
		if v.open and v.star == 0 then
			table.insert(copies_, v)
		end

		if lastCopy_ == nil then
			lastCopy_ = v
		elseif lastCopy_.id < v.id then
			lastCopy_ = v
		end
	end

	if table.getn(copies_) > 0 then
		table.sort(copies_, function(t1, t2)
			if t2.id < t1.id then
				return true
			end
		end)
	else
		-- copies_[1] = lastCopy_
	end
	return copies_
end

function copyManager.getCopyGroups()
	return local_copyGroup
end

function copyManager.getCopies()
	return local_copies
end

function copyManager.getGroupNum()
	return local_groupNum
end

-- 获得副本组信息
function copyManager.getCopyGroup(sid_)
	if sid_ == -1 then
		return nil
	else
		local group_ = local_copyGroup[sid_]
		if group_ ~= nil then
			return group_
		else
			local tmpGroup_ = defaultGroup(sid_)
			return tmpGroup_
		end
	end
end

-- 获得第一个副本
function copyManager.getFirstCopyGroup()
	return local_copyGroup[101]
end

-- 获得当前宝箱阶段
function copyManager.getCurGiftIndex(group_)
	for i, v in ipairs(group_.gift) do
		if v ~= 2 then
			return i
		end
	end
	return 3
end

-- 处理战斗结果
function copyManager.handleFightResult(data_, attack_, defense_, battleUI_)
	-- 处理随机道具，目前一个
	if data_.prop ~= nil then
		local info_ = hp.gameDataLoader.getItemByID(data_.prop)
		if info_ ~= nil then
			Scene.showMsg({1021, info_.name, 1})
		end
	end

	-- 处理通过道具
	if data_.items ~= nil then
		local info_ = hp.gameDataLoader.getItemByID(data_.items)
		if info_ ~= nil then
			Scene.showMsg({1021, info_.name, 1})
		end
	end

	-- 战力处理
	if data_.power ~= nil then
		data_.lostPower = local_copies[data_.id].remainPower - data_.power
		local_copies[data_.id].remainPower = data_.power
	else
		data_.lostPower = 0
	end

	if data_.win == 0 then
		-- 开启新副本
		local openGroup_ = false
		local openSid_ = {}
		if data_.jihadM ~= nil then
			for i, v in ipairs(data_.jihadM) do
				table.insert(openSid_, openCopyGroup(v))
			end
			openGroup_ = true
		end

		-- 开启下个关卡
		if data_.jihad ~= nil then
			for i, v in ipairs(data_.jihad) do
				openStage(v)
			end
		end

		-- 攻击轮数清空
		data_.attackTimes = local_copies[data_.id].attackTimes + 1
		local_copies[data_.id].attackTimes = 0

		-- 挑战次数
		-- local_copies[data_.id].times = local_copies[data_.id].times + 1

		-- 星级设置
		evaluateStar(data_.id, data_.jihadS)

		-- 完成关卡
		hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 3, id = data_.id})
		
		if data_.jihad ~= nil then
			for i, v in ipairs(data_.jihad) do
				hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 1, id = v})
			end
		end	

		if openGroup_ == true then
			hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 7, openGsids = openSid_, gsid = local_copies[data_.id].groupID})
		end

		require "ui/copy/copyWin"
		local ui_ = UI_copyWin.new(data_, attack_, battleUI_)
		game.curScene:addModalUI(ui_)
	else
		-- 攻击轮数增加
		local_copies[data_.id].attackTimes = local_copies[data_.id].attackTimes + 1

		-- 失败
		require "ui/copy/copyFail"
		local ui_ = UI_copyFail.new(data_, attack_, battleUI_)
		game.curScene:addModalUI(ui_)
	end
	hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 8, id = data_.id})
end

return copyManager