--
-- obj/alliance/targetInfo.lua
-- 工会作战的目标信息
--================================================

TargetInfo = class("TargetInfo")

--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function TargetInfo:ctor()
	-- type 1-玩家 2-boss
	self.type = 1

	-- 目标坐标
	self.position = {x=1, y=1}

	-- 目标id
	self.id = 1001

	-- 目标名称
	self.name = ""

	-- 目标工会
	self.alliance = ""

	-- 所在工会级别
	self.rank = 5
end