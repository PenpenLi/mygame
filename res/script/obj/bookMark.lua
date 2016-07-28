--
-- obj/bookMark.lua
-- 书签
--================================================


BookMark = class("BookMark")

--
-- auto functions
--==============================================

local index_ = 1

--
-- ctor
-------------------------------
function BookMark:ctor(info_)
	self.index = index_
	index_ = index_ + 1
	self.name = info_[1]
	self.type = info_[5]
	self.position = {}
	-- self.position.kx = 
	-- self.position.kx = 
	self.position.k = info_[2]
	self.position.x = info_[3]
	self.position.y = info_[4]
end

function BookMark:getType()
	return self.type
end

function BookMark:getName()
	return self.name
end

function BookMark:getPosK()
	return self.position.k
end

function BookMark:getPosX()
	return self.position.x
end

function BookMark:getPosY()
	return self.position.y
end

function BookMark:getIndex()
	return self.index
end