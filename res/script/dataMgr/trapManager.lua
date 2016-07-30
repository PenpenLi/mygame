--------------------------
-- file:playerData/trapManager.lua
-- 描述:陷阱管理器
-- =======================
require "obj/trap"

-- obj
-- =======================
local trapManager = {}
local traps = {}

-- 本地数据
-- =======================

-- 本地方法
-- =======================
-- 清空数据
local function clearTraps()
	for i, v in pairs(traps) do
		v:setTrapNumber(0)
	end
end

-- 更新数据
local function updateTraps(traps_)
	clearTraps()
	cclog_("updateTraps+++")
	for i, v in ipairs(traps_) do
		cclog_(v[1], v[2])
		traps[tostring(v[1])]:setTrapNumber(v[2])
	end
	hp.msgCenter.sendMsg(hp.MSG.TRAP_MESSAGE, {mstType=2})
end

-- =======================
-- 全局方法(Player调用)
-- =======================
-- 构造
function trapManager.create()
	-- body
end

-- 初始化
function trapManager.init()
	traps = {}
	for i, v in ipairs(game.data.trap) do
		traps[tostring(v.sid)] = Trap.new(v.sid, 0)
	end
end

--初始化数据
function trapManager.initData(info_)
	if info_.trap ~= nil then
		updateTraps(info_.trap)
	end
end

-- 数据同步
function trapManager.syncData(info_)
	if info_.trap ~= nil then
		updateTraps(info_.trap)
	end
end

-- heartbeat
-- 心跳操作
function trapManager.heartbeat(dt_)
	-- body
end

-- =======================
-- 外部接口
-- =======================
-- 陷阱建造完成
function trapManager.trapTrainFinish(cdInfo_)
	traps[tostring(cdInfo_.sid)]:addNumber(cdInfo_.number)
	local trapInfo_ = hp.gameDataLoader.getInfoBySid("trap", cdInfo_.sid)
	Scene.showMsg({1002, trapInfo_.name, cdInfo_.number})
	hp.msgCenter.sendMsg(hp.MSG.TRAP_TRAIN_FIN, cdInfo_)
end

-- 获取城墙防御
function trapManager.getWallDefense()
	local defense = 0
	for k,v in pairs(traps) do
		defense = defense + v:getNumber()
	end
	return defense
end

-- 获取陷阱
function trapManager.getTraps()
	return traps
end

-- 增加陷阱
function trapManager.addTraps(sid_, num_)
	traps[tostring(sid_)]:addNumber(num_)
end

-- 获取陷阱数量
function trapManager.getTrapNum()
	local num = 0
	for k,v in pairs(traps) do
		if v ~= nil then
			num = num + v:getNumber()
		end
	end
	return num
end

-- 解散陷阱
function trapManager.fireTrap(sid_, num_)
	traps[tostring(sid_)]:addNumber(-num_)
	local trapInfo_ = hp.gameDataLoader.getInfoBySid("trap", sid_)
	Scene.showMsg({1003, trapInfo_.name, num_})
	hp.msgCenter.sendMsg(hp.MSG.TRAP_MESSAGE, {mstType=1})
end

-- 获取陷阱上限
function trapManager.getTrapUpLimit()
	local wall_ = game.data.wall[player.buildingMgr.getBuildingMaxLvBySid(1018)]
	return wall_.deadfallMax
end

return trapManager