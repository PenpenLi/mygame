--
-- player.lua
--
--================================================
require "obj/soldier"
require "obj/cdBox"
require "obj/alliance/alliance"

player = player or {}


-- private variables
------------------------------------
local userDefault = {}
local playerData = {}
local totalLevel = 4
local soldierType = 4
local traps = {}
local cityArmy = nil
local totalArmy = nil
local marchArmy = nil
local hurtArmy = nil
local bookMarks = nil
local mainTask = 1001
local dailyTask = {}
local branchTask = {}
local rewardList = {}
local totalCapture = nil
local resetTime = {}
local alliance = nil

-- private functions
------------------------------------
local function initUserDefault()
	local udef = cc.UserDefault:getInstance()
	math.randomseed(os.time())
	local randId = string.format("t%d%d", math.random(999), math.random(999))
	userDefault.uid = udef:getStringForKey("uid", randId)
	userDefault.pwd = udef:getStringForKey("pwd", "pwd123")
	userDefault.name = udef:getStringForKey("name", randId)
	userDefault.param = udef:getStringForKey("param", "aaa")
	userDefault.serverAddress = udef:getStringForKey("serverAddress", config.server.domain)

	udef:setStringForKey("uid", userDefault.uid)
	udef:setStringForKey("pwd", userDefault.pwd)
	udef:setStringForKey("name", userDefault.name)
	udef:setStringForKey("param", userDefault.param)
	udef:setStringForKey("serverAddress", userDefault.serverAddress)
	udef:flush()
end

-- public functions
------------------------------------
--
-- init
--
function player.init()
	initUserDefault()
	cdBox.init()

	playerData = {}
	playerData.h_p_key = nil
	playerData.systime = 0
	playerData.lv = 1
	playerData.exp = 0
	playerData.gold = 30
	playerData.diamond = 300
	playerData.silver = 9999
	playerData.food = 8888
	playerData.wood = 7777
	playerData.rock = 6666
	playerData.mine = 11111
	
	playerData.build_in = {}
	playerData.build_out = {}
	playerData.branch = {}
	playerData.research = {}
	playerData.items = {}
	playerData.materials = {}
	alliance = Alliance.new()

	-- 装备背包
	player.equipBag = require("playerData/equipBag")
	player.equipBag.init()
	-- 好友
	player.friendMgr = require("playerData/friendMgr")
	player.friendMgr.init()
	-- VIP信息
	player.vipStatus = require("playerData/vipStatus")
	player.vipStatus.init()
	-- helper
	player.helper = require("playerData/helper")
	player.helper.init()
	-- 指引信息
	player.guide = require("playerData/guide")
	player.guide.init()
	-- 在线礼包
	player.onlineGift = require("playerData/onlineGift")
	player.onlineGift.init()

	player.marchMgr = require("playerData/marchMgr")
	-- 英雄
	player.hero = require("playerData/hero")
	player.hero.init()
	-- 科技
	player.researchMgr = require("playerData/researchMgr")
	player.researchMgr.init()
	-- 建筑
	player.buildingMgr = require("playerData/buildingMgr")
	player.buildingMgr.init()
end


--
-- heartbeat
--
function player.heartbeat(dt)
	--cclog("player.heartbeat === %f", dt)
	if playerData.h_p_key==nil then
		return
	end
	dump(playerData, "heartbeat")

	playerData.systime = playerData.systime+dt
	
	cdBox.heartbeat(dt)
	hp.chatRoom.heartbeat(dt)
	player.vipStatus.heartbeat(dt)
	player.onlineGift.heartbeat(dt)
	player.marchMgr.heartBeat(dt)

	alliance:heartBeat(dt)
end


--
-- 数据同步
--
function player.synData(data_)
	dump(data_,"player.synData");
	local data = data_
	--同步系统时间
	if data.systime~=nil then
		playerData.systime = data.systime
	end
	-- 同步资源资源
	for i,v in ipairs(game.data.resType) do
		if data[v[1]] ~=nil then
			player.setResource(v[1], data[v[1]])
		end
	end
	-- 同步战力
	if data.power~=nil then
		player.setPower(data.power)
	end
	-- 同步邮件
	if data.not_Read~=nil then
		hp.mailCenter.synNewMail(data.not_Read)
	end
	-- 同步士兵
	if ((data.branch ~= nil) or (data.branchA ~= nil) or (data.branchH ~= nil)) then
		player.updateSoldiers(data)
	end
	-- 同步陷阱
	if data.trap ~= nil then
		player.updateTraps(data.trap)
	end
	-- 同步任务
	player.initTasks(data)
	-- 同步英雄
	if data.hero~=nil then
		player.hero.initByData(data.hero)
	end
	-- 同步联盟
	player.updateAlliance(data)
	-- 处理提示信息
	player.dealHintFrameInfo(data.notice)
	-- 同步道具
	local items = data.items
	if items~=nil then
		for i=1, #items, 2 do
			player.setItemNum(items[i], items[i+1])
		end
	end
	items = data.items1
	if items~=nil then
		for i=1, #items, 2 do
			player.setItemNum(items[i], items[i+1])
		end
	end
	items = data.items2
	if items~=nil then
		for i=1, #items, 2 do
			player.setItemNum(items[i], items[i+1])
		end
	end
	--等级
	if data.lv~=nil then
		player.setLv(data.lv)
	end
	--经验
	if data.exp~=nil then
		player.setExp(data.exp)
	end
	cdBox.synData(data.cd)
	-- 部队数量
	player.marchMgr.initData(data_)
	-- 同步cd
	if data.cd ~= nil then
		local i = 1
		while i < table.getn(data.cd) do
			cdBox.setCD(data.cd[i], data.cd[i + 2])
			i = i + 3
		end
	end
end

--
-- public function
--======================================
-- UserDefault
function player.getUserDefault()
	return userDefault
end
function player.getServerAddress()
	return userDefault.serverAddress
end
function player.setServerAddress(serverAddress_)
	local udef = cc.UserDefault:getInstance()
	userDefault.serverAddress = "http://" .. serverAddress_ .. "/"
	udef:setStringForKey("serverAddress", userDefault.serverAddress)
	udef:flush()
end
function player.flushUserDefualt()
	local udef = cc.UserDefault:getInstance()
	udef:setStringForKey("uid", userDefault.uid)
	udef:setStringForKey("pwd", userDefault.pwd)
	udef:setStringForKey("name", userDefault.name)
	udef:setStringForKey("param", userDefault.param)
	udef:setStringForKey("serverAddress", userDefault.serverAddress)
	udef:flush()
end

-- data
-----------------------------------
-- initData
function player.initData(data_)
	playerData = data_

	-- cdBox
	cdBox.initCD(playerData.cd)
	playerData.cd = nil
	cdBox.initCDInfo(cdBox.CDTYPE.BUILD, playerData.build_cd)
	playerData.build_cd = nil
	cdBox.initCDInfo(cdBox.CDTYPE.EQUIP, playerData.equipcd)
	playerData.equipcd = nil
	cdBox.initCDInfo(cdBox.CDTYPE.BRANCH, playerData.branch_cd)
	playerData.branch_cd = nil
	cdBox.initCDInfo(cdBox.CDTYPE.TRAP, playerData.trap_cd)
	playerData.trap_cd = nil
	cdBox.initCDInfo(cdBox.CDTYPE.REMEDY, playerData.branchHN)
	-- cd帮助
	cdBox.initCDHelpInfo(playerData.cdh)

	-- 城内建筑
	player.buildingMgr.initByData(playerData.build_in, playerData.build_out)
	playerData.build_in = nil
	playerData.build_out = nil

	-- 英雄
	player.hero.initByData(playerData.hero)
	-- 科技
	player.researchMgr.initByData(playerData.ability)
	playerData.ability = nil

	-- 邮件
	hp.mailCenter.initUnreadInfo(playerData.not_Read)

	-- army infomation
	player.initSoldiers(playerData)

	-- soldier heal time
	player.initSoldierHealingInfo(playerData.branchHN)

	-- traps information
	player.initTraps(playerData.trap)

	-- init tasks
	player.initTasks(playerData)

	-- init alliance
	player.initAlliance(playerData)

	-- init march manager
	player.marchMgr.initData(playerData)
	
	-- 背包
	--======================================
	local items_ = {}
	-- 道具
	local items = playerData.items
	if items~=nil then
		for i=1, #items, 2 do
			items_[items[i]] = items[i+1]
		end
	end
	--材料
	local items1 = playerData.items1
	if items1~=nil then
		for i=1, #items1, 2 do
			items_[items1[i]] = items1[i+1]
		end
	end
	playerData.items1 = nil
	--宝石
	local items2 = playerData.items2
	if items2~=nil then
		for i=1, #items2, 2 do
			items_[items2[i]] = items2[i+1]
		end
	end
	playerData.items2 = nil
	playerData.items = items_

	-- 装备背包
	player.equipBag.initByData(playerData.equipL, playerData.equip, playerData.equipN)
	-- 好友列表
	player.friendMgr.initByData(playerData.friend, playerData.fRecvInvites, playerData.fSentInvites)
	-- vip信息
	player.vipStatus.initByData(playerData.vip)
	-- 新手指引
	player.guide.initByData(playerData.guide)
	-- 在线礼包
	player.onlineGift.initByData(playerData.onlineGift)
	-- 聊天功能
	hp.chatRoom.initByData()
end

-- h_p_key 
function player.h_p_key()
	return playerData.h_p_key
end

-- getServerTime
function player.getServerTime()
	return playerData.systime
end

-- id
function player.getID()
	return playerData.id
end

-- name
function player.getName()
	return playerData.name
end
-- lv
function player.getLv()
	return playerData.lv
end
function player.setLv(lv_)
	local tempLev=playerData.lv
	playerData.lv = lv_
	hp.msgCenter.sendMsg(hp.MSG.LV_CHANGED, playerData.lv)
	if tempLev<lv_ then
		hp.msgCenter.sendMsg(hp.MSG.HERO_LV_UP, lv_)
	end
end
-- exp
function player.getExp()
	return playerData.exp
end
function player.setExp(exp_)
	playerData.exp = exp_
	hp.msgCenter.sendMsg(hp.MSG.EXP_CHANGED, playerData.exp)
end
function player.addExp(exp_)
	local maxLv = table.getn(game.data.heroLevel)
	local lv = playerData.lv
	if lv==maxLv then
		return
	end

	playerData.exp = playerData.exp + exp_

	for i=lv+1, maxLv do
		local lvInfo = game.data.heroLevel[i]
		if playerData.exp>=lvInfo.exp then
			lv = lv+1
			playerData.exp = playerData.exp-lvInfo.exp
		else
			break
		end
	end
	if lv~=playerData.lv then
		playerData.lv = lv
		hp.msgCenter.sendMsg(hp.MSG.LV_CHANGED, playerData.lv)
		hp.msgCenter.sendMsg(hp.MSG.HERO_LV_UP, playerData.lv)	
		if lv==maxLv then
			playerData.exp = 0
		end
	end
	hp.msgCenter.sendMsg(hp.MSG.EXP_CHANGED, playerData.exp)
end

-- getPower
function player.getPower()
	return playerData.power
end
-- setPower
function player.setPower(power_)
	if playerData.power~=power_ then
		playerData.power = power_
		hp.msgCenter.sendMsg(hp.MSG.POWER_CHANGED, power_)
	end
end

-- 坐标
----------------
function player.getPosition()
	return {x=playerData.x, y=playerData.y}
end

function player.setPosition(x_, y_)
	playerData.x = x_
	playerData.y = y_
end

-- 资源
------------------------------
-- getResourceShow
function player.getResourceShow(res_)
	return hp.common.changeNumUnit(player.getResource(res_))
end

-- getResource
function player.getResource(res_)
	if playerData[res_]==nil then
		return 0
	end

	return playerData[res_]
end
-- addResource
function player.setResource(res_, num_)
	playerData[res_] = num_

	hp.msgCenter.sendMsg(hp.MSG.RESOURCE_CHANGED, {name=res_, num=playerData[res_]})
end
-- addResource
function player.addResource(res_, num_)
	playerData[res_] = playerData[res_] or 0
	playerData[res_] = playerData[res_]+num_

	hp.msgCenter.sendMsg(hp.MSG.RESOURCE_CHANGED, {name=res_, num=playerData[res_]})
end
-- expendResource
function player.expendResource(res_, num_)
	playerData[res_] = playerData[res_] or 0
	playerData[res_] = playerData[res_]-num_

	hp.msgCenter.sendMsg(hp.MSG.RESOURCE_CHANGED, {name=res_, num=playerData[res_]})
end

-- item
-- 道具
------------------------------
-- getItemList 
-- 获取道具列表
function player.getItemList()
	return playerData.items
end
-- getItemNum 
-- 获取道具个数
function player.getItemNum(itemSid_)
	return playerData.items[itemSid_] or 0
end
-- setItemNum 
-- 设置道具个数
function player.setItemNum(itemSid_, num_)
	playerData.items[itemSid_] = num_

	hp.msgCenter.sendMsg(hp.MSG.ITEM_CHANGED, {sid=itemSid_, num=playerData.items[itemSid_]})
end
-- addItem
-- 添加道具
function player.addItem(itemSid_, num_)
	playerData.items[itemSid_] = playerData.items[itemSid_] or 0
	playerData.items[itemSid_] = playerData.items[itemSid_]+num_

	hp.msgCenter.sendMsg(hp.MSG.ITEM_CHANGED, {sid=itemSid_, num=playerData.items[itemSid_]})
end
-- expendItem
-- 消耗道具
function player.expendItem(itemSid_, num_)
	playerData.items[itemSid_] = playerData.items[itemSid_] or 0
	playerData.items[itemSid_] = playerData.items[itemSid_]-num_

	hp.msgCenter.sendMsg(hp.MSG.ITEM_CHANGED, {sid=itemSid_, num=playerData.items[itemSid_]})
end


-- barrack
-----------------------------
function player.getBarrackData()
	return player.barrackData
end

function player.SetBarrackData(barrackData_)
	player.barrackData = barrackData_
end


function player.soldierTrainFinish(cdInfo_)
	totalArmy:addSoldier(cdInfo_.type, cdInfo_.number)
	cityArmy:addSoldier(cdInfo_.type, cdInfo_.number)
	Scene.showMsg({1000, player.getArmyInfoByType(cdInfo_.type).name, cdInfo_.number})
	hp.msgCenter.sendMsg(hp.MSG.BARRACK_TRAIN_FIN, cdInfo_)
end

function player.trapTrainFinish(cdInfo_)
	traps[tostring(cdInfo_.sid)]:addNumber(cdInfo_.number)
	Scene.showMsg({1002, player.getTrapInfoBySid(cdInfo_.sid).name, cdInfo_.number})
	hp.msgCenter.sendMsg(hp.MSG.TRAP_TRAIN_FIN, cdInfo_)
end

function player.getWallDefense()
	local defense = 0
	for k,v in pairs(traps) do
		defense = defense + v:getNumber()
	end
	return defense
end

-- about soldier operation
function player.initSoldiers(info_)
	require "obj/army"

	cityArmy = Army.new()
	totalArmy = Army.new()
	marchArmy = Army.new()
	hurtArmy = Army.new()

	player.updateSoldiers(info_)	
end

function player.updateSoldiers(info_)
	if info_.branch ~= nil then
		for i, v in ipairs(info_.branch) do
			if i > player.getSoldierType() then
				break
			end
			totalArmy:setSoldier(i, info_.branch[i])
		end
	end

	if info_.branchA ~= nil then
		for i, v in ipairs(info_.branchA) do
			if i > player.getSoldierType() then
				break
			end
			marchArmy:setSoldier(i, info_.branchA[i])
		end
	end

	if info_.branchH ~= nil then
		for i, v in ipairs(info_.branchH) do
			if i > player.getSoldierType() then
				break
			end
			hurtArmy:setSoldier(i, info_.branchH[i])
		end
		hp.msgCenter.sendMsg(hp.MSG.HOSPITAL_HURT_REFRESH)
	end
	cityArmy:clear()
	cityArmy:addArmy(totalArmy)
	cityArmy:subArmy(hurtArmy)
	cityArmy:subArmy(marchArmy)

end

function player.getCityArmy()
	return cityArmy
end

function player.getTotalArmy()
	return totalArmy
end

function player.getHurtArmy()
	return hurtArmy
end

function player.getMarchArmy()
	return marchArmy
end

-- 派出部队
function player.armyLeave(army_)
	cityArmy:subArmy(army_)
end

-- 士兵返回
function player.armyBack(army_)
	cityArmy:addArmy(army_)
end

-- 解散士兵
function player.fireSoldier(type_, num_)
	totalArmy:addSoldier(type_, -num_)
	cityArmy:addSoldier(type_, -num_)
	Scene.showMsg({1001, player.getArmyInfoByType(type_).name, num_})
	hp.msgCenter.sendMsg(hp.MSG.SOLDIER_NUM_CHANGE,{1,1,0,0})
end

function player.getArmyInfoByType(type_)
	local index = totalLevel * (type_ - 1) + player.getSoldierLevel(type_)
	return game.data.army[index]	
end

function player.getSoldierType()
	return soldierType
end

function player.getTotalLevel()
	return totalLevel
end

function player.getTypeName(type_)
	if type_ == -1 then
		return ""
	else
		print("type_", type_)
		return hp.gameDataLoader.getTable("armyType")[type_].name
	end
end

-- about trap operation
function player.initTraps(info_)
	for i, v in ipairs(game.data.trap) do
		require "obj/trap"
		traps[tostring(v.sid)] = Trap.new(v.sid, 0)
	end

	player.updateTraps(info_)
end

function player.updateTraps(traps_)
	for i, v in ipairs(traps_) do
		traps[tostring(v[1])]:addNumber(v[2])
	end
end

function player.getTrapInfoBySid(sid_)
	for i,v in ipairs(game.data.trap) do
		if v.sid == sid_ then
			return v
		end
	end
end

function player.getTraps()
	return traps
end

function player.addTraps(sid_, num_)
	traps[tostring(sid_)]:addNumber(num_)
end

function player.getTrapNum()
	local num = 0
	for k,v in pairs(traps) do
		if v ~= nil then
			num = num + v:getNumber()
		end
	end
	return num
end

-- 解散陷阱
function player.fireTrap(sid_, num_)
	traps[tostring(sid_)]:addNumber(-num_)
	Scene.showMsg({1003, player.getTrapInfoBySid(sid_).name, num_})
	hp.msgCenter.sendMsg(hp.MSG.TRAP_NUM_CHANGE)
end

-- academy
-----------------------------
function player.getSoldierLevel(type_)
	local begin_ = type_ * player.getTotalLevel()
	for i = begin_, begin_ - player.getTotalLevel() + 1, -1 do
		if game.data.army[i].unlock == -1 then
			return 1
		elseif player.researchMgr.isTechResearch(game.data.army[i].unlock) then
			return i % player.getTotalLevel()
		end
	end
end

-- bookMark
-----------------------------
function player.getBookMark()
	return bookMarks
end

function player.parseBookMark(bmList)
	require "obj/bookMark"
	bookMarks = {}
	for i,v in ipairs(bmList) do
		local obj = BookMark.new(v)
		bookMarks[i] = obj
	end
end

function player.addBookMark(info_)
	if bookMarks == nil then
		return
	else
		local obj = BookMark.new(info_)
		table.insert(bookMarks, obj)
	end
end

function player.editBookMark(index_, subType_, name_)
	for i, v in ipairs(bookMarks) do
		if v:getIndex() == index_ then
			v.name = name_
			v.type = subType_
			hp.msgCenter.sendMsg(hp.MSG.BIGMAP_BOOKMARK, {2, index_, v})
			break
		end
	end
end

function player.deleteBookMark(index_)
	if bookMarks == nil then
		return
	else
		for i, v in ipairs(bookMarks) do
			if v:getIndex() == index_ then
				table.remove(bookMarks, i)
				hp.msgCenter.sendMsg(hp.MSG.BIGMAP_BOOKMARK, {1, index_})
				break
			end
		end
	end
end

function player.getBookMarkByIndex(index_)
	for i, v in ipairs(bookMarks) do
		if v:getIndex() == index_ then
			return v
		end
	end
	return nil
end


-- 任务
-- 任务初始化
function player.initTasks(data_)
	local ret = {false, false, false, false}
	-- 主线任务
	if player.initMainTask(data_.task0) then
		ret[1] = true
	end

	-- 支线任务
	if player.initBranchTasks(data_.task1) then
		ret[3] = true
	end

	-- 帝国任务奖励列表
	if player.initRewardList(data_.finish) then
		ret[2] = true
	end

	-- 日常任务初始化
	player.initDailyTask(data_)

	if ret[1] == true then
		hp.msgCenter.sendMsg(hp.MSG.MISSION_MAIN_REFRESH, 1)
	elseif ret[2] == true then
		hp.msgCenter.sendMsg(hp.MSG.MISSION_MAIN_REFRESH, 2)
	elseif ret[3] == true then
		hp.msgCenter.sendMsg(hp.MSG.MISSION_MAIN_REFRESH, 3)
	end
end

-- 初始化日常任务
function player.initDailyTask(info_)
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
		dailyTask[1] = initTask(info_.task2)
		resetTime[1] = info_.task2[4]
		local task_ = dailyTask[1][1]
		if task_ ~= nil then
			if task_.flag == 2 then
				cdBox.initCDInfo(cdBox.CDTYPE.DAILYTASK, {task_.endTime - player.getServerTime(), task_.time})
			end
		end
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_REFRESH, 1)
	end

	if info_.task3 ~= nil then
		dailyTask[2] = initTask(info_.task3)
		resetTime[2] = info_.task3[4]
		local task_ = dailyTask[2][1]
		if task_ ~= nil then
			if task_.flag == 2 then
				cdBox.initCDInfo(cdBox.CDTYPE.LEAGUETASK, {task_.endTime - player.getServerTime(), task_.time})
			end
		end
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_REFRESH, 2)
	end

	if info_.task4 ~= nil then
		dailyTask[3] = initTask(info_.task4)
		resetTime[3] = info_.task4[4]
		local task_ = dailyTask[3][1]
		if task_ ~= nil then
			if task_.flag == 2 then
				cdBox.initCDInfo(cdBox.CDTYPE.VIPTASK, {task_.endTime - player.getServerTime(), task_.time})
			end
		end
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_REFRESH, 3)
	end
end

function player.getDailyTasks(type_)
	return dailyTask[type_]
end

-- 支线任务初始化
function player.initBranchTasks(info_)
	if info_ == nil then
		return false
	end

	playerData.task1 = info_
	branchTask = {}
	for i, v in ipairs(info_) do
		local taskInfo_ = hp.gameDataLoader.getInfoBySid("quests", v)
		if taskInfo_~=nil then
			-- 支线从2开始，下标减1
			local type_ = taskInfo_.type - 1
			if branchTask[type_] == nil then
				branchTask[type_] = {}
			end
			table.insert(branchTask[type_], v)
		end
	end
	return true
end

-- 主线任务初始化
function player.initMainTask(info_)
	if info_ == nil then
		return false
	end
	playerData.task0 = info_
	mainTask = info_
	return true
end

-- 奖励列表初始化
function player.initRewardList(list_)
	if list_ == nil then
		return false
	end

	playerData.finishBranch = {}
	playerData.finishMain = {}
	for i, v in ipairs(list_) do
		local questInfo_ = hp.gameDataLoader.getInfoBySid("quests", v)
		if questInfo_ ~= nil then
			if questInfo_.type == 1 then
				table.insert(playerData.finishMain, v)
			else
				table.insert(playerData.finishBranch, v)
			end
		else
			cclog("player.initRewardList can not find task info sid=%d", v)
		end
	end
	print("initRewardList")
	hp.msgCenter.sendMsg(hp.MSG.MISSION_MAIN_STATUS_CHANGE, 2)
	return true
end

-- 获取主线任务信息
-- {id, reward = true/false}
function player.getMainQuestInfo()
	local info_ = {id = playerData.task0[1], reward = false}
	if playerData.finishMain[1] ~= nil then
		local taskInfo_ = hp.gameDataLoader.getInfoBySid("quests", playerData.finishMain[1])
		info_.id = playerData.finishMain[1]
		info_.reward = true
	end
	return info_
end

-- 正在进行的主线任务
function player.getDoingMainQuestInfo()
	return playerData.task0[1]
end

-- 获取直线任务id
function player.getBranchQuestID(type_, group_)
	return branchTask[type_][group_]
end

-- 获取支线任务
function player.getBranchQuest()
	return branchTask
end

-- 判断是否可以领奖的任务
function player.isRewardCollectable(taskID_)
	for i, v in ipairs(playerData.finishBranch) do
		if v == taskID_ then
			return true
		end
	end

	for i, v in ipairs(playerData.finishMain) do
		if v == taskID_ then
			return true
		end
	end
	return false
end

-- 获取支线奖励
function player.getBranchReward()
	return playerData.finishBranch
end

-- 获取主线奖励
function player.getMainReward()
	return playerData.finishMain[1]
end

-- 移除支线奖励
function player.removeBranchReward(taskID_)
	for i, v in ipairs(playerData.finishBranch) do
		if v == taskID_ then
			cclog("remove branch reward:%d", taskID_)
			table.remove(playerData.finishBranch, i)
		end
	end
	Scene.showMsg({1009})
	print("removeBranchReward")
	hp.msgCenter.sendMsg(hp.MSG.MISSION_MAIN_STATUS_CHANGE, 3)
end

-- 移除主线奖励
function player.removeMainReward(taskID_)
	for i, v in ipairs(playerData.finishMain) do
		if v == taskID_ then
			cclog("remove branch reward:%d", taskID_)
			table.remove(playerData.finishMain, i)
		end
	end
	Scene.showMsg({1009})
	print("removeMainReward")
	hp.msgCenter.sendMsg(hp.MSG.MISSION_MAIN_STATUS_CHANGE, 1)
end

-- 进行日常任务
function player.startDailyTask(type_, taskID_)
	local temp = nil
	local index_ = 0
	local cdBoxID_ = {11,12,13}
	for i, v in ipairs(dailyTask[type_]) do
		if v.id == taskID_ then
			index_ = i
			temp = v
			temp.flag = 2
			temp.endTime = player.getServerTime() + temp.time
			cdBox.initCDInfo(cdBoxID_[type_], {temp.time, temp.time})
		else
			dailyTask[type_][i].enabled = 2
		end
	end
	table.remove(dailyTask[type_], index_)
	table.insert(dailyTask[type_], 1, temp)
	hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_CHANGE)
	hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_RECIEVE_CHANGE)	
end

-- 获取进行的日常任务
function player.getDoingDailyInfo(type_)
	if dailyTask[type_][1] == nil then
		return nil
	end

	if dailyTask[type_][1].flag == 2 then
		return dailyTask[type_][1]
	else
		return nil
	end
end

function player.dailyTaskFinish(cdType_, cdInfo_)
	local index_ = 0
	if cdType_ == cdBox.CDTYPE.DAILYTASK then
		index_ = 1
	elseif cdType_ == cdBox.CDTYPE.LEAGUETASK then
		index_ = 2
	elseif cdType_ == cdBox.CDTYPE.VIPTASK then
		index_ = 3
	end

	Scene.showMsg({1008})
	local task_ = dailyTask[index_]

	if task_[1].flag == 2 then
		task_[1].flag = 1
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_STATUS_CHANGE)
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_COMPLETE, index_)
	else
		print("player.dailyTaskFinish error", cdType_)
	end
end

-- 根据id获取任务
function player.getDailyTaskInfo(type_, id_)
	for i, v in ipairs(dailyTask[type_]) do
		if v.id == id_ then
			return v
		end
	end
end

function player.dailyTaskCollected(type_)
	if dailyTask[type_][1].flag ~= 1 then
		cclog("dailyTask %d can not be collected", type_)
	else
		Scene.showMsg({1009})
		table.remove(dailyTask[type_], 1)
		for i, v in ipairs(dailyTask[type_]) do
			dailyTask[type_][i].enabled = 1
		end
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_STATUS_CHANGE)
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_COLLECTED, type_)
		hp.msgCenter.sendMsg(hp.MSG.MISSION_DAILY_RECIEVE_CHANGE)
	end
end

function player.rewardNotCollected(type_)
	if dailyTask[type_][1] ~= nil then
		if dailyTask[type_][1].flag == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function player.getResetTime(type_)
	if type_ == 1 then
		print("getResetTime",type_,resetTime[type_], resetTime[type_] - player.getServerTime())
	end
	return resetTime[type_]
end

function player.getNotCollectedNum()
	local num_ = 0
	for i = 1, 3 do
		if player.rewardNotCollected(i) == true then
			num_ = num_ + 1
		end
	end
	num_ = num_ + table.getn(playerData.finishBranch) + table.getn(playerData.finishMain)
	return num_
end

 -- 地牢
 -- 获得所有俘虏
function player.getTotalCapture()
	return totalCapture;
end

function player.updateTotalCapture(info_)
	totalCapture = info_;
end


function player.initTotalCapture(info_)
	require "obj/army"

	cityArmy = Army.new()
	totalArmy = Army.new()
	marchArmy = Army.new()
	hurtArmy = Army.new()

	player.updateSoldiers(info_)	
end

-- 医馆
function player.initSoldierHealingInfo(info_)
	if info_ == nil then
		return
	end

	local healingInfo_ = {}
	healingInfo_.cd = info_[1]
	healingInfo_.endTime = info_[1] + player.getServerTime()
	healingInfo_.totalTime = info_[2]
	healingInfo_.soldier = {}
	for i = 1, player.getSoldierType() do
		healingInfo_.soldier[i] = info_[2 + i]
	end
	playerData.branchHN = healingInfo_
end

function player.getSoldierHealingInfo()
	return playerData.branchHN
end

-- 完成士兵治疗
function player.healSoldierFinish(cdInfo_)
	local total_ = 0	
	for i, v in ipairs(cdInfo_) do
		total_ = total_ + v
		hurtArmy:addSoldier(i, -v)
		cityArmy:addSoldier(i, v)
	end
	Scene.showMsg({1007, total_})
	player.clearHealList()
	hp.msgCenter.sendMsg(hp.MSG.HOSPITAL_HEAL_FINISH)
end

-- 清空医疗队列
function player.clearHealList()
	if playerData.branchHN == nil then
		return
	end
	
	for i, v in ipairs(playerData.branchHN.soldier) do
		playerData.branchHN.soldier[i] = 0
	end
end

function player.getHealingSoldierNumber()
	if playerData.branchHN == nil then
		return 0
	end

	local num_ = 0
	for i, v in ipairs(playerData.branchHN.soldier) do
		num_ = num_ + v
	end
	return num_
end

function player.getHealingSoldierByType(type_)
	if playerData.branchHN == nil then
		return 0
	end

	return playerData.branchHN.soldier[type_]
end

function player.getHealableSoldierNum(type_)
	return player.getHurtArmy():getSoldierNumberByType(type_) - player.getHealingSoldierByType(type_)
end


-- 工会
-- 初始化
function player.initAlliance(info_)
	alliance:init(info_)
	alliance:firstRequestData()
end

function player.getAlliance()
	return alliance
end

function player.updateAlliance(info_)
	alliance:synNetInfo(info_)
end

-- 处理提示信息
function player.dealHintFrameInfo(info_)
	if info_ == nil then
		return
	end

	print("number", table.getn(info_))
	for i, v in ipairs(info_) do
		for j, w in ipairs(v) do
			print(w)
		end
		Scene.showMsg(v)
	end
end

function player.getMarchMgr()
	return player.marchMgr
end

function player.getFristLeague()
	return playerData.fristLeague
end

function player.clearFristLeague()
	playerData.fristLeague = 1
end

function player.getNewGuyGuard()
	if cdBox.getCD(cdBox.CDTYPE.PEACE) > 0 then
		return 1
	else
		return 0
	end
end

function player.clearGuard()
	cdBox.setCD(cdBox.CDTYPE.PEACE, 0)
end