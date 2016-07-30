--------------------------
-- file:playerData/soldierManager.lua
-- 描述:士兵管理器，粗略的士兵管理，主要处理士兵的数量等基本信息。对于行军等详细信息，无法获取，需要从行军管理其中获取。
-- 加入了医馆管理，主要为正在治疗的伤兵
-- =======================
require "obj/army"

-- obj
-- =======================
local soldierManager = {}

-- 本地数据
-- =======================
local local_totalLevel = 4
local local_soldierType = 4

local local_cityArmy = nil
local local_totalArmy = nil
local local_marchArmy = nil
local local_hurtArmy = nil
local local_healingInfo = nil

-- 本地方法
-- =======================
-- 更新数据
local function updateSoldiers(info_)
	local changed_ = false
	local changeList_ = {0,0,0,0}
	if info_.branch ~= nil then
		changed_ = true
		for i, v in ipairs(info_.branch) do
			if i > globalData.SOLDIER_TYPE then
				break
			end
			local_totalArmy:setSoldier(i, info_.branch[i])
		end
		changeList_[2] = 1
	end

	if info_.branchA ~= nil then
		changed_ = true
		for i, v in ipairs(info_.branchA) do
			if i > globalData.SOLDIER_TYPE then
				break
			end
			local_marchArmy:setSoldier(i, info_.branchA[i])
		end
		changeList_[3] = 1
	end

	if info_.branchH ~= nil then
		changed_ = true
		for i, v in ipairs(info_.branchH) do
			if i > globalData.SOLDIER_TYPE then
				break
			end
			local_hurtArmy:setSoldier(i, info_.branchH[i])
		end
		changeList_[4] = 1
		hp.msgCenter.sendMsg(hp.MSG.HOSPITAL_HURT_REFRESH)
	end

	if changed_ == true then
		local_cityArmy:clear()
		local_cityArmy:addArmy(local_totalArmy)
		local_cityArmy:subArmy(local_hurtArmy)
		local_cityArmy:subArmy(local_marchArmy)
		changeList_[1] = 1
		hp.msgCenter.sendMsg(hp.MSG.SOLDIER_NUM_CHANGE,changeList_)
	end
end

-- 清空医疗队列
local function clearHealList()
	if local_healingInfo == nil then
		return
	end
	
	for i, v in ipairs(local_healingInfo.soldier) do
		local_healingInfo.soldier[i] = 0
	end
end

-- =======================
-- 全局方法
-- =======================
-- 构造
function soldierManager.create()
	-- body
	local_cityArmy = Army.new()
	local_totalArmy = Army.new()
	local_marchArmy = Army.new()
	local_hurtArmy = Army.new()
end

-- 初始化
function soldierManager.init()
	-- 初始化数据
	local_cityArmy:init()
	local_totalArmy:init()
	local_marchArmy:init()
	local_hurtArmy:init()
	local_healingInfo = nil
end

--初始化数据
function soldierManager.initData(info_)
	updateSoldiers(info_)
	soldierManager.initSoldierHealingInfo(info_.branchHN)
end

-- 数据同步
function soldierManager.syncData(info_)
	updateSoldiers(info_)
end

function soldierManager.heartbeat(dt_)
	-- body
end

-- =======================
-- 外部接口
-- =======================
function soldierManager.getCityArmy()
	return local_cityArmy
end

function soldierManager.getTotalArmy()
	return local_totalArmy
end

function soldierManager.getHurtArmy()
	return local_hurtArmy
end

function soldierManager.getMarchArmy()
	return local_marchArmy
end

-- 士兵训练完成
function soldierManager.soldierTrainFinish(cdInfo_)
	local_totalArmy:addSoldier(cdInfo_.type, cdInfo_.number)
	local_cityArmy:addSoldier(cdInfo_.type, cdInfo_.number)
	Scene.showMsg({1000, soldierManager.getArmyInfoByType(cdInfo_.type).name, cdInfo_.number})
	hp.msgCenter.sendMsg(hp.MSG.BARRACK_TRAIN_FIN, cdInfo_)
	hp.msgCenter.sendMsg(hp.MSG.SOLDIER_NUM_CHANGE,{1,1,0,0})
end

-- 派出部队
function soldierManager.armyLeave(army_)
	local_cityArmy:subArmy(army_)
	hp.msgCenter.sendMsg(hp.MSG.SOLDIER_NUM_CHANGE,{1,0,0,0})
end

-- 解散士兵
function soldierManager.fireSoldier(type_, num_)
	local_totalArmy:addSoldier(type_, -num_)
	local_cityArmy:addSoldier(type_, -num_)
	Scene.showMsg({1001, soldierManager.getArmyInfoByType(type_).name, num_})
	hp.msgCenter.sendMsg(hp.MSG.SOLDIER_NUM_CHANGE,{1,1,0,0})
end

function soldierManager.getArmyInfoByType(type_)
	local index = local_totalLevel * (type_ - 1) + player.getSoldierLevel(type_)
	return game.data.army[index]	
end

function soldierManager.getTypeName(type_)
	if type_ == -1 then
		return ""
	else
		return hp.gameDataLoader.getTable("armyType")[type_].name
	end
end

-- 初始化正在治疗的伤兵信息
function soldierManager.initSoldierHealingInfo(info_)
	if info_ == nil then
		return
	end

	local healingInfo_ = {}
	healingInfo_.cd = info_[1]
	healingInfo_.endTime = info_[1] + player.getServerTime()
	healingInfo_.totalTime = info_[2]
	healingInfo_.soldier = {}
	for i = 1, globalData.SOLDIER_TYPE do
		healingInfo_.soldier[i] = info_[2 + i]
	end
	local_healingInfo = healingInfo_
end

-- 完成士兵治疗
function soldierManager.healSoldierFinish(cdInfo_)
	local total_ = 0	
	for i, v in ipairs(cdInfo_) do
		total_ = total_ + v
		local_hurtArmy:addSoldier(i, -v)
		local_cityArmy:addSoldier(i, v)
	end
	Scene.showMsg({1007, total_})
	clearHealList()
	hp.msgCenter.sendMsg(hp.MSG.HOSPITAL_HEAL_FINISH)
	hp.msgCenter.sendMsg(hp.MSG.SOLDIER_NUM_CHANGE,{1,0,0,1})
end

function soldierManager.getHealingSoldierNumber()
	if local_healingInfo == nil then
		return 0
	end

	local num_ = 0
	for i, v in ipairs(local_healingInfo.soldier) do
		num_ = num_ + v
	end
	return num_
end

function soldierManager.getHealingSoldierByType(type_)
	if local_healingInfo == nil then
		return 0
	end

	return local_healingInfo.soldier[type_]
end

function soldierManager.getHealableSoldierNum(type_)
	return soldierManager.getHurtArmy():getSoldierNumberByType(type_) - soldierManager.getHealingSoldierByType(type_)
end

-- 单次兵营训练上限
function soldierManager.getTrainOnceUpLimit()
	local barracklist = player.buildingMgr.getBuildingsBySid(1009)
	local barrackTrain = 0

	for i, v in ipairs(barracklist) do
		barrackTrain = barrackTrain + game.data.barrack[v.lv].soldierMax
	end
	return barrackTrain
end

-- 城池士兵容量
function soldierManager.getCitySoldierLimit()
	return player.helper.getNumPerTroop() * player.helper.getTroopNum()
end

-- 当前可训练上限
function soldierManager.getCurTrainUpLimit(type_)
	local maxTrainNum = {}
	maxTrainNum[1] = soldierManager.getTrainOnceUpLimit()

	local trainingInfo_ =  cdBox.getCDInfo(cdBox.CDTYPE.BRANCH)
	local trainingNum_ = trainingInfo_.number
	if trainingNum_ == nil then
		trainingNum_ = 0
	end	
	if trainingInfo_.cd == 0 then
		trainingNum_ = 0
	end
	maxTrainNum[2] = soldierManager.getCitySoldierLimit() - local_totalArmy:getSoldierTotalNumber() - trainingNum_
	if maxTrainNum[2] < 0 then
		maxTrainNum[2] = 0
	end
	local min1 = hp.common.getMinNumber(maxTrainNum)

	-- resource limit
	local resource = {player.getResource("rock"),player.getResource("wood"),player.getResource("mine"),player.getResource("food"),player.getResource("silver")}
	local soldierInfo = soldierManager.getArmyInfoByType(type_)
	local trainCost = {soldierInfo.costs[5], soldierInfo.costs[4], soldierInfo.costs[6], soldierInfo.costs[3], soldierInfo.costs[2]}
	local lackRes_ = {}
	for i = 1, table.getn(resource) do
		lackRes_[i] = false
		if trainCost[i] ~= 0 then
			local num_ = math.floor(resource[i]/trainCost[i])
			maxTrainNum[table.getn(maxTrainNum) + 1] = num_
			if num_ == 0 then
				lackRes_[i] = true
			end
		end
	end

	local min = hp.common.getMinNumber(maxTrainNum)
	return min, min, lackRes_
end

return soldierManager