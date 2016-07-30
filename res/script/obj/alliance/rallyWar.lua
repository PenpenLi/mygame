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
	self.ownerInfo.totalName = info_[1]
	if info_[2] ~= "" then
		self.ownerInfo.totalName = hp.lang.getStrByID(21)..info_[2]..hp.lang.getStrByID(22)..info_[1]
	end
	-- 现在这个是敌军
	self.ownerInfo.position = {}
	self.ownerInfo.position.x = info_[12]
	self.ownerInfo.position.y = info_[13]
	self.ownerInfo.position.k = info_[14]

	-- 目标信息
	self.targetInfo = {}
	self.targetInfo.name = info_[3]
	self.targetInfo.union = info_[4]
	self.targetInfo.totalName = info_[3]
	if info_[4] ~= "" then
		self.targetInfo.totalName = hp.lang.getStrByID(21)..info_[4]..hp.lang.getStrByID(22)..info_[3]
	end
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

	-- 友军坐标
	self.friendPos = {}
	self.friendPos.x = info_[15]
	self.friendPos.y = info_[16]
	self.friendPos.k = info_[17]
end

function RallyWar:joinWar(army_)
	self.curSoldier = self.curSoldier + army_:getSoldierTotalNumber()
end