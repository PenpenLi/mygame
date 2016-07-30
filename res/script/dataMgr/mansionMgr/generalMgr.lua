----------------------------------------
-- dataMgr/mansionMgr/generalMgr.lua
-- 府邸将军状态管理器
-- =====================================

-- 对象
-- ================================
local generalMgr = {}

-- 私有函数
-- ================================

-- 获取状态
local function status()
	return player.hero.getSkillPoint() > 0
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