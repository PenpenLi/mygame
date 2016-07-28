--
-- obj/alliance/rallyWar.lua
-- 工会战
--================================================

RallyWar = class("RallyWar")

--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function RallyWar:ctor(info_)
	-- 发起人信息
	-- id
	self.ownerInfo = {}
	self.ownerInfo.name = info_[1]
	self.ownerInfo.union = info_[2]

	-- 目标信息
	self.targetInfo = {}
	self.targetInfo.name = info_[3]
	self.targetInfo.union = info_[4]
	self.targetInfo.city = info_[10]
	self.targetInfo.position = {}
	self.targetInfo.position.x = 0
	self.targetInfo.position.y = 1

	-- 派兵上限
	self.totalSoldier = info_[6]

	-- 当前派兵
	self.curSoldier = info_[5]

	-- 结束时间
	self.lastTime = info_[7] + player.getServerTime()

	-- 总时间
	self.totalTime = info_[8]
	-- id
	self.id = info_[9]

	self.fellowID = info_[11]
end

function RallyWar:joinWar(army_)
	self.curSoldier = self.curSoldier + army_:getSoldierTotalNumber()
end