 --
-- file: playerData/vipStatus.lua
-- desc: VIP状态
--================================================

-- hp.MSG.VIP 好友管理消息
-- param = 1 --等级变化
-- param = 2 --积分变化
-- param = 3 --CD状态变化
--===================================================

-- obj
-- =======================
local vipStatus = {}


-- private data
-- =======================
local lv = 1
local points = 0
local vipInfo = nil
local cd = 0.0
local streakDay = 0

-- private function
-- =======================
local function checkVipInfo()
	for i,info in ipairs(game.data.vip) do
		if info.level==lv then
			vipInfo = info
			return
		end
	end

	vipInfo = nil
end


-- public function
-- =======================
-- init
function vipStatus.init()
	lv = 1
	points = 0
	cd = 0.0
	streakDay = 0
	checkVipInfo()
end

-- initByData
function vipStatus.initByData(data_)
	if data_~=nil then
		lv = data_[1]
		points = data_[2]
		cd = data_[3]
		streakDay = data_[4]
		checkVipInfo()
	end
end

-- getLv
function vipStatus.getLv()
	return lv
end

-- setLv
function vipStatus.setLv(lv_)
	lv = lv_
	checkVipInfo()
	hp.msgCenter.sendMsg(hp.MSG.VIP, 1)
end

-- getPoints
function vipStatus.getPoints()
	return points
end

-- setPoints
function vipStatus.setPoints(points_)
	points = points_
	hp.msgCenter.sendMsg(hp.MSG.VIP, 2)
end

-- addPoints
function vipStatus.addPoints(points_)
	points = points+points_
	for i,vipInfo in ipairs(game.data.vip) do
		if vipInfo.points>points then
			lv = vipInfo.level-1
			checkVipInfo()
			hp.msgCenter.sendMsg(hp.MSG.VIP, 1)
			hp.msgCenter.sendMsg(hp.MSG.VIP, 2)
			return
		end
	end
	lv = 10
	checkVipInfo()
	hp.msgCenter.sendMsg(hp.MSG.VIP, 1)
	hp.msgCenter.sendMsg(hp.MSG.VIP, 2)
end

-- 
function vipStatus.getVipInfo()
	return vipInfo
end

-- getCD
function vipStatus.getCD()
	return cd
end

-- setCD
function vipStatus.setCD(cd_)
	if cd_<0 then
		cd = 0
	else
		cd = cd_
	end
	hp.msgCenter.sendMsg(hp.MSG.VIP, 3)
end

-- isActive
function vipStatus.isActive()
	if cd>0 then
		return true
	end

	return false
end

function vipStatus.getStreakDay()
	return streakDay
end

-- heartbeat
function vipStatus.heartbeat(dt_)
	if cd>0 then
		if cd>dt_ then
			cd = cd-dt_
		else
			cd = 0
			hp.msgCenter.sendMsg(hp.MSG.VIP, 3)
		end
	end
end

return vipStatus
