----------------------------
-- playerData/takeInHeroMgr.lua
-- 关押英雄
-- =======================

-- 对象
-- ================================
-- ********************************
local takeInHeroMgr = {}


-- 私有数据
-- ================================
-- ********************************
local hasHeroNum = 0 --关押的英雄数量



-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function takeInHeroMgr.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function takeInHeroMgr.init()
	hasHeroNum = 0
end

-- initData
-- 使用玩家登陆数据进行初始化
function takeInHeroMgr.initData(data_)
	local data = data_.heroS
	if data~=nil then
		hasHeroNum = data
	end
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function takeInHeroMgr.syncData(data_)
	local data = data_.heroS
	if data~=nil then
		hasHeroNum = data
		hp.msgCenter.sendMsg(hp.MSG.FAMOUS_HERO_NUM_CHANGE, hasHeroNum)
	end
end

-- heartbeat
-- 心跳操作
function takeInHeroMgr.heartbeat(dt_)
	-- body
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

function takeInHeroMgr.getHeroNum()
	return hasHeroNum
end


return takeInHeroMgr

