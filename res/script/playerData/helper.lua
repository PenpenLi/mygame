--
-- file: playerData/helper.lua
-- desc: 玩家公共数据获取
--================================================

local helper = {}

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

	return 0
end


--
-- getAttrAddn
-- 获取属性加成
-- @attrType_: 加成属性类型
function helper.getAttrAddn(attrType_, addnSelete_)
	local addn = 0
	if addnSelete_ == nil then
		addn = addn+player.hero.getAttrAddn(attrType_)			--英雄加成
		addn = addn+player.researchMgr.getAttrAddn(attrType_)	--科技加成
		addn = addn+player.vipStatus.getAttrAddn(attrType_)		--vip加成
		addn = addn+player.bufManager.getAttrAddn(attrType_)	--道具加成
		addn = addn+player.bufManager.getSpecialAttrAddn(attrType_)	--特殊加成
		addn = addn+player.buildBufManager.getAttrAddn(attrType_)	--建筑加成
		addn = addn+player.titleBufManager.getAttrAddn(attrType_)	--头衔加成
	else
		if hp.common.band(addnSelete_, globalData.ADDNFILTER.RESEARCH) == 1 then
			addn = addn+player.researchMgr.getAttrAddn(attrType_)	--科技加成
		end
		if hp.common.band(addnSelete_, globalData.ADDNFILTER.HERO) == 1 then
			addn = addn+player.hero.getAttrAddn(attrType_)	--英雄加成
		end
		if hp.common.band(addnSelete_, globalData.ADDNFILTER.VIP) == 1 then
			addn = addn+player.vipStatus.getAttrAddn(attrType_)	--VIP加成
		end
		if hp.common.band(addnSelete_, globalData.ADDNFILTER.ITEMBUF) == 1 then
			addn = addn+player.bufManager.getAttrAddn(attrType_)	--道具加成
		end
		if hp.common.band(addnSelete_, globalData.ADDNFILTER.SPECIALBUF) == 1 then
			addn = addn+player.bufManager.getSpecialAttrAddn(attrType_)	--特殊加成
		end		
		if hp.common.band(addnSelete_, globalData.ADDNFILTER.BUILDBUFF) == 1 then
			addn = addn+player.buildBufManager.getAttrAddn(attrType_)	--建筑加成
		end
		if hp.common.band(addnSelete_, globalData.ADDNFILTER.TITLEBUFF) == 1 then
			addn = addn+player.titleBufManager.getAttrAddn(attrType_)	--头衔加成
		end
	end

	-- cclog("helper.getAttrAddn================: %d", addn)
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


-- 获取士兵训练时间
function helper.getSoldierTrainTime(time_)
	local addition_ = helper.getAttrAddn(109)
	return math.floor(time_ / (1 + addition_ / 10000))
end

-- 获取陷阱训练时间
function helper.getTrapTrainTime(time_)
	local addition_ = helper.getAttrAddn(111)
	return math.floor(time_ / (1 + addition_ / 10000))
end

-- 获取行军时间
function helper.getMarchTime(time_, type_)
	local typeAddMap_ = {5,15,25,35}
	local addition_ = helper.getAttrAddn(45) + helper.getAttrAddn(typeAddMap_[type_])
	return math.floor(time_ / (1 + addition_ / 10000))
end

-- 运送资源速度加成
function helper.getResourceTransTime(time_, type_)
	local typeAddMap_ = {5,15,25,35}
	local addition_ = helper.getAttrAddn(201) + helper.getAttrAddn(45) + helper.getAttrAddn(typeAddMap_[type_])
	return math.floor(time_ / (1 + addition_ / 10000))
end

-- 负载
function helper.getLoadedByType(loaded_, type_)
	local typeAddMap_ = {4,14,24,34}
	local addition_ = helper.getAttrAddn(44) + helper.getAttrAddn(typeAddMap_[type_])
	return math.floor(loaded_ * (1 + addition_ / 10000))
end


--
-- getResOutput
-- 获取资源产量
-- @resType_: 资源类型
-- @addRes_: 增产还是总产量(nil表示总产)
-- @filter_: 计算哪些加成(nil表示全部)
function helper.getResOutput(resType_, addRes_, filter_)
	local num = 0
	local addn = 0
	local bList = {}

	if resType_==1 then --银币
		bList = player.buildingMgr.getBuildingsBySid(1017)
		if filter_ == nil then
			addn = helper.getAttrAddn(101)
		else
			addn = helper.getAttrAddn(101,filter_)
		end
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
			if filter_ == nil then
				addn = helper.getAttrAddn(102)
			else
				addn = helper.getAttrAddn(102,filter_)
			end
		elseif resType_==3 then
			bList = player.buildingMgr.getBuildingsBySid(1003)
			if filter_ == nil then
				addn = helper.getAttrAddn(103)
			else
				addn = helper.getAttrAddn(103,filter_)
			end
		elseif resType_==4 then
			bList = player.buildingMgr.getBuildingsBySid(1005)
			if filter_ == nil then
				addn = helper.getAttrAddn(104)
			else
				addn = helper.getAttrAddn(104,filter_)
			end
		elseif resType_==5 then
			bList = player.buildingMgr.getBuildingsBySid(1004)
			if filter_ == nil then
				addn = helper.getAttrAddn(105)
			else
				addn = helper.getAttrAddn(105,filter_)
			end
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

	if addn < 0 then
		addn = 0
	end

	if addRes_ == true then
		return math.floor(num*addn/10000)
	else
		return math.floor(num*(1+addn/10000))
	end
end

-- 获取指定资源建筑的产量
function helper.getSingleBuildResOutput(build_)
	local addn = 0
	local num_ = 0
	local sidMap_ = {[1002]=102,[1003]=103,[1004]=105,[1005]=104}
	if build_.sid == 1017 then
		addn = helper.getAttrAddn(101)
		num_ = hp.gameDataLoader.multiConditionSearch("villa", {level=build_.lv}).resCount
	else
		addn = helper.getAttrAddn(sidMap_[build_.sid])
		num_ = hp.gameDataLoader.multiConditionSearch("res", {buildsid=build_.sid,level=build_.lv}).resCount
	end
	return math.floor(num_*(1+addn/10000))
end

-- 获取VIP增加的资源产量
function helper.getVIPAddRes(type_)
	return helper.getResOutput(type_, true, globalData.ADDNFILTER.VIP)
end

-- 获取科技增加的资源产量
function helper.getResearchAddRes(type_)
	return helper.getResOutput(type_, true, globalData.ADDNFILTER.RESEARCH)
end

-- 获取英雄增加的资源产量
function helper.getHeroAddRes(type_)
	return helper.getResOutput(type_, true, globalData.ADDNFILTER.HERO)
end

-- 获取道具增加的资源产量
function helper.getItemBufAddRes(type_)
	return helper.getResOutput(type_, true, globalData.ADDNFILTER.ITEMBUF)
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

-- 获取单次出兵上限
function helper.getNumPerTroop()
	local addin_ = helper.getAttrAddn(302)
	local main_ = game.data.main[player.buildingMgr.getBuildingMaxLvBySid(1001)]
	return hp.common.round((1 + addin_/10000) * main_.soldierMax)
end

-- 获取可派出队伍数
function helper.getTroopNum()
	local addin_ = helper.getAttrAddn(130)
	local main_ = game.data.main[player.buildingMgr.getBuildingMaxLvBySid(1001)]
	return (main_.troopMax + addin_/10000)
end

-- 获取最大负重
function helper.getMaxResourceLoaded()
	return 0
end

return helper