--------------------------
-- file:playerData/questManager.lua
-- 描述:任务管理
-- =======================

-- obj
-- =======================
local questManager = {}
local quickFinishLevel = {7,8,-1}

-- 本地数据
-- =======================
local local_mainTask = {}		-- 城池任务-主线任务
local local_branchTask = {}		-- 城池任务-支线任务
local local_finishMain = {}		-- 城池任务-主线奖励
local local_finishBranch = {}	-- 城池任务-支线奖励
local local_dailyTask = {}		-- 日常任务
local local_resetTime = {}		-- 重置时间-日常任务	

-- 本地方法
-- =======================
-- 初始化日常任务
local function initDailyTask(info_)
	local ret_ = false
	if info_ == nil then
		return ret_
	end

	local function initTask(taskInfo_)
		local task_ = {}
		local doingID_ = taskInfo_[1]
		local enabled_ = 1
		local index_ = 0
		if doingID_ ~= 0 then		
			enabled_ = 2
		end	
		local doingEndTime = taskInfo_[2]
		for i, v in ipairs(taskInfo_[3]) do
			local flag_ = 3
			local endTime_ = 0
			if doingID_ == v[1] then
				if doingEndTime == 0 then
					flag_ = 1 -- 1-领奖 2-进行中 3-未进行
				elseif doingEndTime > 0 then
					flag_ = 2					
					endTime_ = doingEndTime + player.getServerTime()
				end	
				index_ = i	
			end
			task_[i] = {
			name="日常任务",
			id=v[1],
			quality=v[2],
			time=v[3],
			contribute=v[6],
			item=v[7],
			resource={0,v[4],v[8][1],v[8][2],v[8][3],v[8][4],v[5],0,0,0},
			enabled=enabled_,
			flag=flag_,
			endTime = endTime_,
		}
		end

		if index_ > 0 then
			local temp = task_[index_]
			table.remove(task_, index_)
			table.insert(task_, 1, temp)
		end
		return task_
	end

	if info_.task2 ~= nil then
		local_dailyTask[1] = initTask(info_.task2)
		local_resetTime[1] = info_.task2[4]
		local task_ = local_dailyTask[1][1]
		if task_ ~= nil then
			if task_.flag == 2 then
				cdBox.initCDInfo(cdBox.CDTYPE.DAILYTASK, {task_.endTime - player.getServerTime(), task_.time})
			end
		end
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_REFRESH, 1)
	end

	if info_.task3 ~= nil then
		local_dailyTask[2] = initTask(info_.task3)
		local_resetTime[2] = info_.task3[4]
		local task_ = local_dailyTask[2][1]
		if task_ ~= nil then
			if task_.flag == 2 then
				cdBox.initCDInfo(cdBox.CDTYPE.LEAGUETASK, {task_.endTime - player.getServerTime(), task_.time})
			end
		end
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_REFRESH, 2)
	end

	if info_.task4 ~= nil then
		local_dailyTask[3] = initTask(info_.task4)
		local_resetTime[3] = info_.task4[4]
		local task_ = local_dailyTask[3][1]
		if task_ ~= nil then
			if task_.flag == 2 then
				cdBox.initCDInfo(cdBox.CDTYPE.VIPTASK, {task_.endTime - player.getServerTime(), task_.time})
			end
		end
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_REFRESH, 3)
	end
end

-- 支线任务初始化
local function initBranchTasks(info_)
	if info_ == nil then
		return false
	end

	local_branchTask = {}
	for i, v in ipairs(info_) do
		local taskInfo_ = hp.gameDataLoader.getInfoBySid("quests", v)
		if taskInfo_~=nil then
			-- 支线从2开始，下标减1
			local type_ = taskInfo_.type - 1
			if local_branchTask[type_] == nil then
				local_branchTask[type_] = {}
			end
			table.insert(local_branchTask[type_], v)
		end
	end

	-- 排序
	for k, v in pairs(local_branchTask) do
		local function comp(t1, t2)
			if t1 < t2 then
				return true
			else
				return false
			end
		end

		table.sort(v, comp)
	end
	return true
end

-- 主线任务初始化
local function initMainTask(info_)
	if info_ == nil then
		return false
	end
	local_mainTask = info_
	return true
end

-- 奖励列表初始化
local function initRewardList(list_)
	if list_ == nil then
		return false
	end

	-- 之前的最新主线奖励
	local oldFinishMain = local_finishMain[table.getn(local_finishMain)]
	local oldFinisBranck = local_finishBranch[table.getn(local_finishBranch)]
	local_finishBranch = {}
	local_finishMain = {}
	for i, v in ipairs(list_) do
		local questInfo_ = hp.gameDataLoader.getInfoBySid("quests", v)
		if questInfo_ ~= nil then
			if questInfo_.type == 1 then
				table.insert(local_finishMain, v)
			else
				table.insert(local_finishBranch, v)
			end
		else
			cclog("questManager.initRewardList can not find task info sid=%d", v)
		end
	end
	-- 排序
	table.sort(local_finishMain)
	table.sort(local_finishBranch)
	-- 新的主线完成
	local newFinishMain = local_finishMain[table.getn(local_finishMain)]
	if newFinishMain ~= nil then
		if newFinishMain ~= oldFinishMain then
			hp.msgCenter.sendMsg(hp.MSG.MISSION_COMPLETE, 1)
		end
	end
	-- 新的支线完成
	local newFinishBranch = local_finishBranch[table.getn(local_finishBranch)]
	if newFinishBranch ~= nil then
		if newFinishBranch ~= oldFinisBranck then
			hp.msgCenter.sendMsg(hp.MSG.MISSION_COMPLETE, 2)		
		end
	end
	cclog_("initRewardList")
	return true
end

-- 城池任务领奖
local function empireQuestCollected(questID_)
	local questInfo_ = hp.gameDataLoader.getInfoBySid("quests", questID_)
	-- 更新资源
	for j, w in ipairs(questInfo_.reward) do
		local rewardInfo_ = hp.gameDataLoader.getInfoBySid("rewards", w)
		-- 道具
		for i, v in ipairs(rewardInfo_.item) do
			if v ~= -1 then
				player.addItem(v, rewardInfo_.num[i])
			end
		end
	end

	if questInfo_.type == 1 then
		questManager.removeMainReward(questID_)
	else
		questManager.removeBranchReward(questID_)
	end
end

-- 城池任务奖励字符串
local function getEmpireQuestRewardStr(questID_)
	local reward_ = hp.gameDataLoader.getInfoBySid("rewards", questID_)
	if reward_ == nil then
		return nil
	end

	local str_ = ""
	local stringTable_ = {}
	-- 道具
	for i, v in ipairs(reward_.item) do
		if v ~= -1 then
			local item_ = hp.gameDataLoader.getItemByID(v)
			if item_ ~= nil then
				table.insert(stringTable_, item_.name.."x"..reward_.num[i])
			end
		end
	end
	-- 资源
	for i, v in ipairs(reward_.resource) do
		if v ~= 0 then
			local resourceInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
			table.insert(stringTable_, resourceInfo_.name.."x"..v)
		end
	end

	for i, v in ipairs(stringTable_) do
		if i == 1 then
			str_ = v
		else
			str_ = str_..","..v
		end
	end

	return str_
end

-- 更新任务
local function updateQuest(data_)
	local ret = {false, false, false, false}
	-- 主线任务
	if initMainTask(data_.task0) then
		ret[1] = true
	end

	-- 支线任务
	if initBranchTasks(data_.task1) then
		ret[3] = true
	end

	-- 帝国任务奖励列表
	if initRewardList(data_.finish) then
		ret[2] = true
	end

	-- 日常任务初始化
	initDailyTask(data_)

	if ret[1] == true then
		hp.msgCenter.sendMsg(hp.MSG.MISSION_REFRESH, 1)
	end
	if ret[2] == true then
		hp.msgCenter.sendMsg(hp.MSG.MISSION_REFRESH, 2)
	end
	if ret[3] == true then
		hp.msgCenter.sendMsg(hp.MSG.MISSION_REFRESH, 3)
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
				empireQuestCollected(oper.sid)
				hp.msgCenter.sendMsg(hp.MSG.MISSION_COLLECT, oper.sid)
			elseif type_ == 2 then
			
			elseif type_ == 3 then
				questManager.startDailyTask(oper.task, data.id)
			elseif type_ == 5 then
				questManager.quickFinishTask(oper.task, data.id)
			elseif type_ == 6 then
				questManager.dailyTaskCollected(oper.task)
			end

			if callBack_ ~= nil then
				callBack_()
			end
		end	
	end

	local cmdData={operation={}}
	oper.channel = 2
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
function questManager.create()
	-- body
end

-- 初始化
function questManager.init()	
	local_mainTask = {}		-- 城池任务-主线任务
	local_branchTask = {}	-- 城池任务-支线任务
	local_finishMain = {}	-- 城池任务-主线奖励
	local_finishBranch = {}	-- 城池任务-支线奖励
	local_dailyTask = {}		-- 日常任务
	local_resetTime = {}		-- 重置时间-日常任务	
end

-- 任务初始化
function questManager.initData(data_)
	updateQuest(data_)
end

function questManager.syncData(data_)
	-- body
	updateQuest(data_)
end

function questManager.heartbeat(dt_)
	-- body
end

-- =======================
-- 外部接口
-- =======================
-- 领取主线奖励
function questManager.httpReqCollectEmpireReward(questID_, callBack_)
	local param_ = {}
	param_.sid = questID_
	local cmdSender = sendHttpCmd(1, param_, callBack_)
	return cmdSender
end

-- 开始日常任务
function questManager.httpReqStartDailyQuest(type_, questID_, callBack_)
	local param_ = {}
	param_.task = type_
	param_.id = questID_
	local cmdSender = sendHttpCmd(3, param_, callBack_)
	return cmdSender
end

-- 领取日常奖励
function questManager.httpReqCollectDailyReward(type_, callBack_)
	local param_ = {}
	param_.task = type_
	local cmdSender = sendHttpCmd(6, param_, callBack_)
	return cmdSender
end

-- 快速完成，VIP功能
function questManager.httpReqFinishTaskQuickly(type_, questID_, callBack_)
	local param_ = {}
	param_.task = type_
	param_.id = questID_
	local cmdSender = sendHttpCmd(5, param_, callBack_)
	return cmdSender
end

-- 获取日常任务信息
function questManager.getDailyTasks(type_)
	return local_dailyTask[type_]
end

-- 获取主线任务信息
-- {id, reward = true/false}
function questManager.getMainQuestInfo()
	local info_ = {id = local_mainTask[1], reward = false}
	if local_finishMain[1] ~= nil then
		local taskInfo_ = hp.gameDataLoader.getInfoBySid("quests", local_finishMain[1])
		info_.id = local_finishMain[1]
		info_.reward = true
	end
	if info_.id == nil then
		return nil
	else
		return info_
	end
end

-- 获取支线任务
function questManager.getBranchQuest()
	return local_branchTask
end

-- 正在进行的主线任务
function questManager.getDoingMainQuestInfo()
	return local_mainTask[1]
end

-- 判断是否可以领奖的任务
function questManager.isRewardCollectable(taskID_)
	for i, v in ipairs(local_finishBranch) do
		if v == taskID_ then
			return true
		end
	end

	for i, v in ipairs(local_finishMain) do
		if v == taskID_ then
			return true
		end
	end
	return false
end

-- 获取支线奖励
function questManager.getBranchReward()
	return local_finishBranch
end

-- 获取主线奖励
function questManager.getMainReward()
	return local_finishMain[1]
end

-- 移除支线奖励
function questManager.removeBranchReward(taskID_)
	for i, v in ipairs(local_finishBranch) do
		if v == taskID_ then
			cclog("remove branch reward:%d", taskID_)
			table.remove(local_finishBranch, i)
		end
	end
	Scene.showMsg({1009, getEmpireQuestRewardStr(taskID_)})
	cclog_("removeBranchReward")
end

-- 移除主线奖励
function questManager.removeMainReward(taskID_)
	for i, v in ipairs(local_finishMain) do
		if v == taskID_ then
			cclog("remove branch reward:%d", taskID_)
			table.remove(local_finishMain, i)
		end
	end
	Scene.showMsg({1009, getEmpireQuestRewardStr(taskID_)})
	cclog_("removeMainReward")
end

-- 进行日常任务
function questManager.startDailyTask(type_, taskID_)
	local temp = nil
	local index_ = 0
	local cdBoxID_ = {11,12,13}
	for i, v in ipairs(local_dailyTask[type_]) do
		if v.id == taskID_ then
			index_ = i
			temp = v
			temp.flag = 2
			temp.endTime = player.getServerTime() + temp.time
			cdBox.initCDInfo(cdBoxID_[type_], {temp.time, temp.time})
		else
			local_dailyTask[type_][i].enabled = 2
		end
	end
	table.remove(local_dailyTask[type_], index_)
	table.insert(local_dailyTask[type_], 1, temp)
	hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_START, type_)
end

-- 快速完成任务
function questManager.quickFinishTask(type_, taskID_)
	local taskInfo_ = nil
	for i, v in ipairs(local_dailyTask[type_]) do
		if v.id == taskID_ then
			table.remove(local_dailyTask[type_], i)
			taskInfo_ = v
			break
		end
	end

	-- 获取奖励
	local quest_ = taskInfo_
	local str_ = ""
	local stringTable_ = {}
	-- 道具
	if quest_.item ~= 0 then
		local item_ = hp.gameDataLoader.getItemByID(quest_.item)
		if item_ ~= nil then
			table.insert(stringTable_, item_.name.."x1")
		end
	end
	-- 贡献
	if quest_.contribute ~= 0 then
		table.insert(stringTable_, hp.lang.getStrByID(5110).."x"..quest_.contribute)
		table.insert(stringTable_, hp.lang.getStrByID(5120).."x"..quest_.contribute)
	end
	-- 资源
	for i, v in ipairs(quest_.resource) do
		if v ~= 0 then
			local resourceInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
			table.insert(stringTable_, resourceInfo_.name.."x"..v)
		end
	end

	for i, v in ipairs(stringTable_) do
		if i == 1 then
			str_ = v
		else
			str_ = str_..","..v
		end
	end
	Scene.showMsg({1009, str_})
	hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_QUICKFINISH, type_)
end

-- 获取进行的日常任务
function questManager.getDoingDailyInfo(type_)
	cclog_("getDoingDailyInfo", type_)
	if local_dailyTask[type_][1] == nil then
		return nil
	end

	if local_dailyTask[type_][1].flag == 2 then
		return local_dailyTask[type_][1]
	else
		return nil
	end
end

-- 日常任务完成
function questManager.dailyTaskFinish(cdType_, cdInfo_)
	local index_ = 0
	if cdType_ == cdBox.CDTYPE.DAILYTASK then
		index_ = 1
	elseif cdType_ == cdBox.CDTYPE.LEAGUETASK then
		index_ = 2
	elseif cdType_ == cdBox.CDTYPE.VIPTASK then
		index_ = 3
	end

	Scene.showMsg({1008})
	local task_ = local_dailyTask[index_]

	if task_[1].flag == 2 then
		task_[1].flag = 1
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_COMPLETE, index_)
	else
		cclog_("questManager.dailyTaskFinish error", cdType_)
	end
end

-- 根据id获取日常任务
function questManager.getDailyTaskInfo(type_, id_)
	for i, v in ipairs(local_dailyTask[type_]) do
		if v.id == id_ then
			return v
		end
	end
end

-- 领取日常任务奖励
function questManager.dailyTaskCollected(type_)
	if local_dailyTask[type_][1].flag ~= 1 then
		cclog("local_dailyTask %d can not be collected", type_)
	else
		local quest_ = local_dailyTask[type_][1]
		local str_ = ""
		local stringTable_ = {}
		-- 道具
		if quest_.item ~= 0 then
			local item_ = hp.gameDataLoader.getItemByID(quest_.item)
			if item_ ~= nil then
				table.insert(stringTable_, item_.name.."x1")
			end
		end
		-- 贡献
		if quest_.contribute ~= 0 then
			table.insert(stringTable_, hp.lang.getStrByID(5110).."x"..quest_.contribute)
			table.insert(stringTable_, hp.lang.getStrByID(5120).."x"..quest_.contribute)
		end
		-- 资源
		for i, v in ipairs(quest_.resource) do
			if v ~= 0 then
				local resourceInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
				table.insert(stringTable_, resourceInfo_.name.."x"..v)
			end
		end

		for i, v in ipairs(stringTable_) do
			if i == 1 then
				str_ = v
			else
				str_ = str_..","..v
			end
		end
		Scene.showMsg({1009, str_})
		table.remove(local_dailyTask[type_], 1)
		for i, v in ipairs(local_dailyTask[type_]) do
			local_dailyTask[type_][i].enabled = 1
		end
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_COLLECTED, type_)
	end
end

function questManager.rewardNotCollected(type_)
	if local_dailyTask[type_][1] ~= nil then
		if local_dailyTask[type_][1].flag == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function questManager.getResetTime(type_)
	return local_resetTime[type_]
end

function questManager.getNotCollectedNum()
	local num_ = 0
	for i = 1, 3 do
		if questManager.rewardNotCollected(i) == true then
			num_ = num_ + 1
		end
	end
	num_ = num_ + table.getn(local_finishBranch) + table.getn(local_finishMain)
	return num_
end

function questManager.refreshQuest(gold_, param_)
	local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", param_.id)
	local function onChangeResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			-- 更新资源
			Scene.showMsg({1018})					
			if tag == 1 then -- 消耗道具
				player.expendItem(param_.id, 1)
			elseif tag == 2 then -- 消耗元宝
				player.expendResource("gold", itemInfo_.sale)
			end
			updateQuest(data)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 2
	oper.type = 4
	oper.task = param_.type
	oper.gold = gold_
	local tag_ = 1
	if gold_ > 0 then
		tag_ = 2
	end
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onChangeResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
end

-- 获取可免费完成的vip等级
function questManager.getQuickFinishLevel(type_)
	return quickFinishLevel[type_]
end

return questManager