--
-- obj/soldier.lua
-- 士兵
--================================================


Soldier = class("Soldier")

--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function Soldier:ctor(type_, num_)
	self.soldierType = type_
	if type(num_) == "number" then
		self.num = num_
	else
		self.num = tonumber(num_)
	end
end

function Soldier:getNumber()
	return self.num
end

function Soldier:setNumber(num_)
	self.num = num_
end

function Soldier:addNumber(addNum_)
	self.num = self.num + addNum_
	if self.num < 0 then
		print("Soldier:addNumber num less than 0")
	end
end

function Soldier:getSoldierInfo()
	local soldierLevel = player.getSoldierLevel(self.soldierType)
	local totalLevel = player.getTotalLevel()
	local index_ = totalLevel * (self.soldierType - 1) + soldierLevel
	local ret = game.data.army[index_]
	return ret
end

function Soldier:getSoldierType()
	return self.soldierType
end

function Soldier:getCharge()
	local Info_ = self:getSoldierInfo()
	if Info_ == nil then
		print("nil")
	else
		return Info_.charge * self.num
	end
end