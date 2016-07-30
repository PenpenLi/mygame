--
-- obj/army.lua
-- 军队
--================================================
require "obj/soldier"

Army = class("Army")

--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function Army:ctor()
	self.hero = nil
	self.soldierList = {}
	for i = 1, globalData.TOTAL_LEVEL do
		local soldier_ = Soldier.new(i, 0)
		self.soldierList[i] = soldier_
	end
end

-- 初始化
function Army:init()
	self.hero = nil
	for i, v in ipairs(self.soldierList) do
		v:setNumber(0)
	end
end

-- 获取英雄
function Army:getHero()
	return self.hero
end

-- 设置英雄
function Army:setHero(hero_)
	self.hero = hero_
end

-- 获取军队的士兵总数
function Army:getSoldierTotalNumber()
	local num_ = 0
	for i, v in ipairs(self.soldierList) do
		num_ = num_ + v:getNumber()
	end
	return num_
end

-- 根据类型获取士兵数量
function Army:getSoldierNumberByType(type_)
	for i, v in ipairs(self.soldierList) do
		if type_ == v:getSoldierType() then
			return v:getNumber()
		end
	end
end

-- 军队负重能力
function Army:getArmyLoaded()
	local loaded_ = 0
	for i, v in ipairs(self.soldierList) do
		local loadByType_ = player.helper.getLoadedByType(v:getSoldierInfo().loaded * v:getNumber(), i)
		loaded_ = loaded_ + loadByType_
	end
	return loaded_
end

-- 添加某种类型的士兵
function Army:addSoldier(type_, num_)
	local exist_ = false
	for i, v in ipairs(self.soldierList) do
		if v:getSoldierType() == type_ then
			v:addNumber(num_)
			exist_ = true
		end
	end

	if not exist_ then
		cclog_(string.format("Army:addSoldier not exist type:%d", type_))
	end
end

-- 计算行军时间
function Army:calcMarchTime(destination_)
	local unitMarchTime_ = {}
	for i, v in ipairs(self.soldierList) do
		if v:getNumber() ~= 0 then
			local unitTime_ = player.helper.getMarchTime(v:getSoldierInfo().moveSpeed, i)
			table.insert(unitMarchTime_, unitTime_)
		end
	end

	local maxTime_ = hp.common.getMaxNumber(unitMarchTime_)
	if maxTime_ == 0 then
		return 0
	end
	if maxTime_ == nil then
		return 0
	end
	local mainCityPos_ = player.serverMgr.getMyPosition()
	local distance_ = math.sqrt(math.pow(mainCityPos_.x - destination_.x, 2) + math.pow(mainCityPos_.y - destination_.y, 2))
	local costTime_ = math.floor(distance_ * maxTime_)
	return costTime_
end

-- 设置某种类型的士兵数量
function Army:setSoldier(type_, num_)
	local exist_ = false
	for i, v in ipairs(self.soldierList) do
		if v:getSoldierType() == type_ then
			self.soldierList[i]:setNumber(num_)
			exist_ = true
		end
	end
end

-- 获取粮草消耗
function Army:getCharge()
	local num = 0
	local addin_ = player.helper.getAttrAddn(47)
	for i,v in ipairs(self.soldierList) do
		if v ~= nil then
			num = num + v:getCharge()
		end
	end
	return math.floor(num*(1+addin_/10000))
end

-- 获取某种类型的士兵信息
function Army:getSoldierByType(type_)
	return self.soldierList[type_]
end

-- 分离一些士兵出去
function Army:subArmy(army_)
	for i = 1, globalData.TOTAL_LEVEL do
		self.soldierList[i]:addNumber(-army_:getSoldierByType(i):getNumber())
	end
end

-- 军队合并
function Army:addArmy(army_)
	for i = 1, globalData.TOTAL_LEVEL do
		self.soldierList[i]:addNumber(army_:getSoldierByType(i):getNumber())
	end
end

-- 清空
function Army:clear()
	for i = 1, globalData.TOTAL_LEVEL do
		self.soldierList[i]:setNumber(0)
	end
end

-- 战力
function Army:getPower()
	local power_ = 0
	for i, v in ipairs(self.soldierList) do
		power_ = power_ + v:getPower()
	end
	return power_
end