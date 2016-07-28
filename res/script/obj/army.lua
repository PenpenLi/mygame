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
function Army:ctor(hero_, soldierNum_)
	self.hero = hero_
	self.soldierList = {}
	for i = 1, player.getSoldierType() do
		local soldier_ = Soldier.new(i, 0)
		self.soldierList[i] = soldier_
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
		loaded_ = loaded_ + v:getSoldierInfo().loaded * v:getNumber()
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
		print(string.format("Army:addSoldier not exist type:%d", type_))
	end
end

-- 计算行军时间
function Army:calcMarchTime(destination_, add_)
	local unitMarchTime_ = {}
	for i, v in ipairs(self.soldierList) do
		if v:getNumber() ~= 0 then
			table.insert(unitMarchTime_, v:getSoldierInfo().moveSpeed)
		end
	end

	local maxTime_ = hp.common.getMaxNumber(unitMarchTime_)
	if maxTime_ == 0 then
		return 0
	end
	if maxTime_ == nil then
		return 0
	end
	local mainCityPos_ = player.getPosition()
	local distance_ = math.sqrt(math.pow(mainCityPos_.x - destination_.x, 2) + math.pow(mainCityPos_.y - destination_.y, 2))
	local costTime_ = math.floor(distance_ * maxTime_)
	return costTime_ / (1 + add_)
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
	for i,v in ipairs(self.soldierList) do
		if v ~= nil then
			num = num + v:getCharge()
		end
	end
	return num
end

-- 获取某种类型的士兵信息
function Army:getSoldierByType(type_)
	return self.soldierList[type_]
end

-- 分离一些士兵出去
function Army:subArmy(army_)
	for i = 1, player.getSoldierType() do
		self.soldierList[i]:addNumber(-army_:getSoldierByType(i):getNumber())
	end
end

-- 军队合并
function Army:addArmy(army_)
	for i = 1, player.getSoldierType() do
		self.soldierList[i]:addNumber(army_:getSoldierByType(i):getNumber())
	end
end

-- 清空
function Army:clear()
	for i = 1, player.getSoldierType() do
		self.soldierList[i]:setNumber(0)
	end
end