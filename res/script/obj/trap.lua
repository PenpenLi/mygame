--
-- obj/trap.lua
-- 陷阱
--================================================


Trap = class("Trap")

--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function Trap:ctor(sid_, num_)	
	self.sid = sid_
	self.num = tonumber(num_)
end

function Trap:getNumber()
	return self.num
end

function Trap:addNumber(addNum_)
	self.num = self.num + addNum_
end

function Trap:getTrapSid()
	return self.sid
end

function Trap:setTrapNumber(num_)
	self.num = num_
end