----------------------------------------------
-- dataMgr/mansionMgr/PrimeMinisterMgr.lua
-- 府邸丞相状态管理器
-- ===========================================

-- 对象
-- ================================
local primeMinisterMgr = {}

-- 私有数据
-- ================================
local kingActivityIsClick = false

-- 私有方法
-- ================================

-- 招募英雄
local function haveHeroCanRecruit()
	return player.takeInHeroMgr.getHeroNum() > 0
end

-- 国王争夺战
local function isStartKingActivity()
	-- 府邸等级不足8级
	if player.buildingMgr.getBuildingMaxLvBySid(1001) < 8 then
 		return false
	end
	local info = player.fortressMgr.getFortressInfo()
	if info ~= nil then
		return info.open == 0
	end
	return false
end

-- 联盟帮助
local function haveHelpAsk()
	local hasAlliance = player.getAlliance()
	-- 已加入联盟
	if hasAlliance:getUnionID() ~= 0 then
		local homePageInfo_ = hasAlliance:getUnionHomePageInfo()
		local helpNum = homePageInfo_["help"]
		-- 有帮助请求
		if helpNum ~= nil and helpNum > 0 then
			return true
		else
			return false
		end
	else
		return true
	end
end

-- 建筑工人
local function builderIsFree()
	return cdBox.getCDInfo(cdBox.CDTYPE.BUILD).cd <= 0
end

-- 书院
local function canResearch()
	-- 未建造书院
	if player.buildingMgr.getBuildingNumBySid(1007) == nil then
		return true
	else
		if cdBox.getCDInfo(cdBox.CDTYPE.RESEARCH).cd <= 0 then
			return true
		end
	end
	return false
end

-- 任务是否完成
local function questIsFinished(type_)
	if player.questManager.getDailyTasks(type_) ~= nil then
		return player.questManager.rewardNotCollected(type_)
	end
	return nil
end

-- 城卫军
local function localForcesIsFree()
	local quest = player.questManager.getDailyTasks(1)
	local taskNum
	
	if quest ~= nil then
		taskNum = #quest
	else
		taskNum = 0
	end

	if cdBox.getCDInfo(cdBox.CDTYPE.DAILYTASK).cd <= 0 then
		-- 未领取
		if questIsFinished(1) then
			return true
		-- 未全部完成
		elseif taskNum > 0 then
			return true
		end
	end
	return false
end

-- 联盟军
local function unionForcesIsFree()
	local quest = player.questManager.getDailyTasks(2)
	local taskNum

	if quest ~= nil then
		taskNum = #quest
	else
		taskNum = 0
	end
	
	-- 未加入联盟
	if player.getAlliance():getUnionID() == 0 then
		return true
	else
		if cdBox.getCDInfo(cdBox.CDTYPE.LEAGUETASK).cd <= 0 then
			-- 未领取
			if questIsFinished(2) then
				return true
			-- 未全部完成
			elseif taskNum > 0 then
				return true
			end
		end
	end

	return false
end

-- 禁卫军
local function vipForcesIsFree()
	local quest = player.questManager.getDailyTasks(3)
	local taskNum

	if quest ~= nil then
		taskNum = #quest
	else
		taskNum = 0
	end
	
	-- vip 激活
	if player.vipStatus.isActive() then
		if cdBox.getCDInfo(cdBox.CDTYPE.VIPTASK).cd <= 0 then
			-- 未领取
			if questIsFinished(3) then
				return true
			-- 未全部完成
			elseif taskNum > 0 then
				return true
			end
		end
	else
		return true
	end

	return false
end

-- 兵营
local function barracksIsFree()
	local lostSoldierNum = 0
	local barracksBuild = player.buildingMgr.getBuildingNumBySid(1009)
	
	local indexTmp = player.buildingMgr.getBuildingMaxLvBySid(1001)
	if indexTmp ~= nil and indexTmp > 0 then
		local gameData = game.data.main[indexTmp]
		local armyData = player.soldierManager.getTotalArmy()
		
		if gameData ~= nil and armyData ~= nil then
			lostSoldierNum = gameData.soldierMax * gameData.troopMax - armyData:getSoldierTotalNumber()
		end
	end
	
	-- 兵营未建造
	if barracksBuild == nil or barracksBuild <= 0 then
		return true
	else
		-- 空闲且可以招募
		if cdBox.getCDInfo(cdBox.CDTYPE.BRANCH).cd <= 0 and lostSoldierNum > 0 then
			return true
		end
	end
	return false
end

-- 医馆
local function hospitalIsFree()
	local hospitalBuild = player.buildingMgr.getBuildingNumBySid(1014)

	-- 医馆未建造
	if hospitalBuild == nil or hospitalBuild <= 0 then
		return true
	else
		local hurtArmy = player.soldierManager.getHurtArmy()
		-- 有伤兵且可以治愈
		if hurtArmy ~= nil and hurtArmy:getSoldierTotalNumber() > 0 and cdBox.getCDInfo(cdBox.CDTYPE.REMEDY).cd <=0 then
			return true
		end
	end
	return false
end

-- 城墙
local function wallIsFree()
	local barracklist = player.buildingMgr.getBuildingsBySid(1018)
	local barrackTrain = 0
	
	-- 可容纳陷阱总数
	for i,v in ipairs(barracklist) do
		barrackTrain = barrackTrain + hp.gameDataLoader.getBuildingInfoByLevel("wall", v.lv, "deadfallMax")
	end
	-- 空闲
	if cdBox.getCDInfo(cdBox.CDTYPE.TRAP).cd <= 0 then
		return barrackTrain - player.trapManager.getTrapNum() > 0
	end
	return false
end

-- 行军
local function canMarch()
	-- 空闲士兵
	local soldierNum = player.soldierManager.getCityArmy():getSoldierTotalNumber()
	-- 行军队列是否空闲
	local canMarch = player.marchMgr.canMarch()
	-- 可行军
	if canMarch and soldierNum > 0 then
		return true
	end
	return false
end

-- 体力
local function haveEnergy()
	local energy = player.getEnerge()

	if energy ~= nil and energy > 0 then
		return true
	end
	return false
end

-- 攻击boss
local function attackBoss()
	local energy = player.getEnerge()
	local num = player.soldierManager.getCityArmy():getSoldierTotalNumber()

	if energy ~= nil and energy >= 20 and num > 0 then
		return true
	end
	return false
end

-- 获取状态
local function status()
	-- 顺序:
	-- 名将拍卖，国王活动，联盟帮助，医馆，
	-- 城卫军，联盟军，禁卫军，体力，研究，
	-- 行军，建筑，训练士兵，制造陷阱

	local checkedTab = player.checkedPMTbl.getCheckedTbl()

	if checkedTab[1] == 0 and haveHeroCanRecruit() then
		return true
	end
	if checkedTab[2] == 0 and not kingActivityIsClick and isStartKingActivity() then
		return true
	end
	if checkedTab[3] == 0 and haveHelpAsk() then
		return true
	end
	if checkedTab[4] == 0 and hospitalIsFree() then
		return true
	end
	if checkedTab[5] == 0 and localForcesIsFree() then
		return true
	end
	if checkedTab[6] == 0 and unionForcesIsFree() then
		return true
	end
	if checkedTab[7] == 0 and vipForcesIsFree() then
		return true
	end
	if checkedTab[8] == 0 and haveEnergy() then
		return true
	end
	if checkedTab[9] == 0 and canResearch() then
		return true
	end
	if checkedTab[10] == 0 and canMarch() then
		return true
	end
	if checkedTab[11] == 0 and builderIsFree() then
		return true
	end
	if checkedTab[12] == 0 and barracksIsFree() then
		return true
	end
	if checkedTab[13] == 0 and wallIsFree() then
		return true
	end
	return false
end

-- 构造函数
function primeMinisterMgr.create()
	
end

-- 初始化
function primeMinisterMgr.init()
	
end

-- 初始化网络数据
function primeMinisterMgr.initData(data)
	
end

-- 同步数据
function primeMinisterMgr.syncData(data)
	
end

-- 心跳
function primeMinisterMgr.heartbeat(dt)

end

-- 对外接口
-- ================================

-- 内政状态
function primeMinisterMgr.affairsStatus()
	local num = 0
	local checkedTab = player.checkedPMTbl.getCheckedTbl()
	-- 建筑
	if checkedTab[11] == 0 and builderIsFree() then
		num = num + 1
	end
	-- 研究
	if checkedTab[9] == 0 and canResearch() then
		num = num + 1
	end
	-- 陷阱
	if checkedTab[13] == 0 and wallIsFree() then
		num = num + 1
	end
	return num
end

-- 军队状态
function primeMinisterMgr.armyStatus()
	local num = 0
	local checkedTab = player.checkedPMTbl.getCheckedTbl()
	-- 训练士兵
	if checkedTab[12] == 0 and barracksIsFree() then
		num = num + 1
	end
	-- 医馆伤兵
	if checkedTab[4] == 0 and hospitalIsFree() then
		num = num + 1
	end
	-- 出城采集
	if checkedTab[10] == 0 and canMarch() then
		num = num + 1
	end
	return num
end

-- 行动任务
function primeMinisterMgr.missionStatus()
	local num = 0
	local checkedTab = player.checkedPMTbl.getCheckedTbl()
	-- 城卫军
	if checkedTab[5] == 0 and localForcesIsFree() then
		num = num + 1
	end
	-- 联盟军
	if checkedTab[6] == 0 and unionForcesIsFree() then
		num = num + 1
	end
	-- 禁卫军
	if checkedTab[7] == 0 and vipForcesIsFree() then
		num = num + 1
	end
	return num
end

-- 体力状态
function primeMinisterMgr.energyStatus()
	local num = 0
	local checkedTab = player.checkedPMTbl.getCheckedTbl()
	if checkedTab[8] == 0 and haveEnergy() then
		num = num + 1
	end
	if checkedTab[14] == 0 and attackBoss() then
		num = num + 1
	end
	return num
end

-- 国王争夺战
function primeMinisterMgr.kingdomActStatus()
	local num = 0
	local checkedTab = player.checkedPMTbl.getCheckedTbl()
	if checkedTab[2] == 0 and not kingActivityIsClick and isStartKingActivity() then
		num = num + 1
	end
	return num
end

-- 是否发光
function primeMinisterMgr.isLight()
	-- return status()
	if primeMinisterMgr.affairsStatus() > 0 then
		return true
	end
	if primeMinisterMgr.armyStatus() > 0 then
		return true
	end
	if primeMinisterMgr.missionStatus() > 0 then
		return true
	end
	if primeMinisterMgr.energyStatus() > 0 then
		return true
	end
	if primeMinisterMgr.kingdomActStatus() > 0 then
		return true
	end
	return false
end

-- 国王争夺战已点击
function primeMinisterMgr.kingActivityClick()
	kingActivityIsClick = true
end

-- 国王争夺战是否点击
function primeMinisterMgr.getKingActivityIsClick()
	return kingActivityIsClick
end

return primeMinisterMgr