----------------------------------------
-- dataMgr/mansionMgr/generalMgr.lua
-- 府邸将军状态管理器
-- =====================================

-- 对象
-- ================================
local generalMgr = {}

-- 私有函数
-- ================================

-- 未使用天赋点
local function haveUnusedPoint()
	local lv = player.getLv()
	local pointCount = 0
	local pointUsed = 0
	-- 所有天赋点
	for i,v in ipairs(game.data.heroLv) do
		pointCount = pointCount + v.dit
		if v.level == lv then
			break
		end
	end
	-- 已使用天赋点
	local skillList = player.hero.getSkillList()
	for k,v in pairs(skillList) do
		pointUsed = pointUsed + v
	end
	return pointCount - pointUsed > 0
end

-- 获取状态
local function status()
	if haveUnusedPoint() then
		return true
	end
end

-- 构造函数
function generalMgr.create()

end

-- 初始化
function generalMgr.init()

end

-- 初始化网络数据
function generalMgr.initData(data)

end

-- 同步数据
function generalMgr.syncData(data)
	
end

-- 心跳
function generalMgr.heartbeat(dt)

end

-- 对外接口
-- ================================

-- 是否发光
function generalMgr.isLight()
	return status()
end

return generalMgr