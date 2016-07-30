 --
-- file: dataMgr/vipStatus.lua
-- desc: VIP状态
--================================================

-- hp.MSG.VIP 好友管理消息
-- param = 1 --等级变化
-- param = 2 --积分变化
-- param = 3 --CD状态变化
--===================================================

-- 对象
-- ================================
-- ********************************
local vipStatus = {}


-- 私有数据
-- ================================
-- ********************************
local lv = 1 --VIP等级
local points = 0 --VIP积分
local vipInfo = nil --VIP信息
local cd = 0.0 --cd
local streakDay = 0 --连续登录天数


-- 私有函数
-- ================================
-- ********************************
local function checkVipInfo()
	for i,info in ipairs(game.data.vip) do
		if info.level==lv then
			vipInfo = info
			return
		end
	end

	vipInfo = nil
end


-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function vipStatus.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function vipStatus.init()
	lv = 1
	points = 0
	cd = 0.0
	streakDay = 0
	checkVipInfo()
end

-- initData
-- 使用玩家登陆数据进行初始化
function vipStatus.initData(data_)
	local data = data_.vip
	if data~=nil then
		lv = data[1]
		points = data[2]
		cd = data[3]
		streakDay = data[4]
		checkVipInfo()
	end
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function vipStatus.syncData(data_)
	local data = data_.vip
	if data~=nil then
		vipStatus.setLv(data[1])
		vipStatus.setPoints(data[2])
		vipStatus.setCD(data[3])
		streakDay = data[4]
	end
end

-- heartbeat
-- 心跳操作
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


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

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

--
-- getAttrAddn
-- 获取VIP属性加成
-- @attrType_: 加成属性类型
function vipStatus.getAttrAddn(attrType_)
	for k, v in pairs(vipInfo) do
		if type(v)=='table' and v[1]==attrType_ then
			return v[2]
		end
	end
	return 0
end



return vipStatus
