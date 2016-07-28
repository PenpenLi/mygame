--
-- file: playerData/helper.lua
-- desc: 玩家公共数据获取
--================================================
require "playerData/bufManager"

local helper = {}

helper.bufMap = {}
helper.bufCalcMap = {
	researchBufMgr.getAdditionByAttrID,	-- 1 科技加成
	heroBufMgr.getAdditionByAttrID,	-- 2 英雄加成
}


--
-- init
function helper.init()
end


--
-- getFreeCD
-- 获取免费加速的时间
function helper.getFreeCD()
	if player.vipStatus.isActive() then
		local vipInfo = player.vipStatus.getVipInfo()
		if vipInfo~=nil then
			return vipInfo.award1
		end
	end

	return 300
end


--
-- getAttrAddn
-- 获取属性加成
-- @attrType_: 加成属性类型
function helper.getAttrAddn(attrType_)
	local addn = 0
	addn = addn+player.hero.getAttrAddn(attrType_)			--英雄加成
	addn = addn+player.researchMgr.getAttrAddn(attrType_)	--科技加成

	cclog("helper.getAttrAddn================: %d", addn)
	return addn
end

--
-- getBuildRealCD
-- 获取建造实际时间
-- @originalCD_: 原始时间
function helper.getBuildRealCD(originalCD_)
	local addn = 0
	addn = helper.getAttrAddn(107)
	if addn>0 then
		return math.floor(originalCD_/(1+addn/10000))
	end

	return originalCD_
end

--
-- getResearchRealCD
-- 获取科研实际时间
-- @originalCD_: 原始时间
function helper.getResearchRealCD(originalCD_)
	local addn = 0
	addn = helper.getAttrAddn(106)
	if addn>0 then
		return math.floor(originalCD_/(1+addn/10000))
	end

	return originalCD_
end


-- 获取士兵训练速度加成
function helper.getSoldierTrainAdd()
	if researchBufMgr == nil then
		print("KJDSfihwoiehpqihewrpoih")
	end
	local addition_ = researchBufMgr.getAdditionByAttrID(109) + heroBufMgr.getAdditionByAttrID(109)
	return addition_ / 10000
end

-- getSoldierTrainCD
function helper.getSoldierTrainCd(info_, num_)
	local addition_ = researchBufMgr.getAdditionByAttrID(109)
	return (info_.cd * num_) * addition_ / 10000
end

-- 获取陷阱训练速度加成
function helper.getTrapTrainAdd()
	local addition_ = researchBufMgr.getAdditionByAttrID(111) + heroBufMgr.getAdditionByAttrID(111)
	return addition_ / 10000
end

-- 获取行军速度加成
function helper.getMarchSpeedAdd()
	local addition_ = researchBufMgr.getAdditionByAttrID(45) + heroBufMgr.getAdditionByAttrID(45)
	return addition_ / 10000
end

-- 运送资源速度加成
function helper.getAdditionByID(sid_)
	local addition_ = 0
	if helper.bufMap[sid_] ~= nil then
		for i, v in ipairs(helper.bufMap[sid_]) do
			addition_ = addition_ + v(sid_)
		end
	end
	return addition_ / 10000
end


--
-- getResOutput
-- 获取资源产量
-- @resType_: 资源类型
function helper.getResOutput(resType_)
	local num = 0
	local addn = 0
	local bList = {}

	if resType_==1 then --银币
		bList = player.buildingMgr.getBuildingsBySid(1017)
		addn = helper.getAttrAddn(101)
		for i, b in ipairs(bList) do
			for i, res in ipairs(game.data.villa) do
				if b.lv==res.level then
					num = num+res.resCount
					break
				end
			end
		end
	else
		if resType_==2 then
			bList = player.buildingMgr.getBuildingsBySid(1002)
			addn = helper.getAttrAddn(102)
		elseif resType_==3 then
			bList = player.buildingMgr.getBuildingsBySid(1003)
			addn = helper.getAttrAddn(103)
		elseif resType_==4 then
			bList = player.buildingMgr.getBuildingsBySid(1005)
			addn = helper.getAttrAddn(104)
		elseif resType_==5 then
			bList = player.buildingMgr.getBuildingsBySid(1004)
			addn = helper.getAttrAddn(105)
		end

		for i, b in ipairs(bList) do
			for i, res in ipairs(game.data.res) do
				if b.lv==res.level and b.sid==res.buildsid then
					num = num+res.resCount
					break
				end
			end
		end
	end

	if addn>0 then
		return math.floor(num*(1+addn/10000))
	end

	return num
end

--
-- getResCapacity
-- 获取资源容量
-- @resType_: 资源类型
function helper.getResCapacity(resType_)
	local num = 0
	local bList = {}

	if resType_==1 then --银币
		bList = player.buildingMgr.getBuildingsBySid(1017)
		addn = helper.getAttrAddn(101)
		for i, b in ipairs(bList) do
			for i, res in ipairs(game.data.villa) do
				if b.lv==res.level then
					num = num+res.max
					break
				end
			end
		end
	else
		if resType_==2 then
			bList = player.buildingMgr.getBuildingsBySid(1002)
		elseif resType_==3 then
			bList = player.buildingMgr.getBuildingsBySid(1003)
		elseif resType_==4 then
			bList = player.buildingMgr.getBuildingsBySid(1005)
		elseif resType_==5 then
			bList = player.buildingMgr.getBuildingsBySid(1004)
		end

		for i, b in ipairs(bList) do
			for i, res in ipairs(game.data.res) do
				if b.lv==res.level and b.sid==res.buildsid then
					num = num+res.max
					break
				end
			end
		end
	end

	return num
end

return helper