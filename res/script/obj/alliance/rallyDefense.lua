--
-- obj/alliance/rallyDefense.lua
-- 工会防御
--================================================

RallyDefense = class("RallyDefense")

--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function RallyDefense:ctor()
	-- 发起人信息
	self.ownerInfo = nil

	-- 目标信息
	-- id
	self.id = 0

	-- 派兵上限
	self.totalSoldier = 10000

	-- 当前派兵
	self.curSoldier = 155

	-- 结束时间
	self.lastTime = 303

	-- 总时间
	self.totalTime = 1000
end