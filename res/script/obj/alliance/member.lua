--
-- obj/alliance/member.lua
-- 工会成员
--================================================

Member = class("Member")

--
-- auto functions
--==============================================

local localID = 1

--
-- ctor
-------------------------------
function Member:ctor()
	-- id
	self.id = 0
	-- 本地id
	self.localID = localID
	localID = localID + 1	
	-- 工会中级别
	self.rank = 5

	-- 名字
	self.name = ""

	-- 坐标
	self.position = {x=1, y=1}

	-- 头像
	self.image = ""

	-- 签名
	self.sign = ""

	-- 杀敌
	self.kill = 0
end

function Member:init(info_)
	self.id = info_[1]
	self.rank = info_[2]
	self.name = info_[3]
	self.position.x = info_[4]
	self.position.y = info_[5]
	self.image = info_[6]
	self.sign = info_[7]
	self.kill = info_[8]
	self.power = info_[9]
end

function Member:getRank()
	return self.rank
end

function Member:getName()
	return self.name
end

function Member:getKill()
	return self.kill
end

function Member:getSign()
	return self.sign
end

function Member:getImage()
	return self.image
end

function Member:getPosition()
	return self.position
end

function Member:getID()
	return self.id
end

function Member:getLocalID()
	return self.localID
end

function Member:getPower()
	return self.power
end