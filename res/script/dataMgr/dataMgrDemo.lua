--
-- file: dataMgr/dataMgrDemo.lua
-- desc: 玩家管理demo
-- 注: 模块的描述尽量写清楚
--================================================


-- 对象
-- ================================
-- ********************************
local dataMgrDemo = {}


-- 私有数据
-- 注: 这些数据仅在此定义，初始化操作请放入dataMgrDemo.init()
-- ================================
-- ********************************
local x = 1


-- 私有函数
-- ================================
-- ********************************
local function function_prv( ... )
end


-- player调用接口函数
-- 以下函数必须实现(即使不被调用)，提供给player调用
-- 注: 这些接口尽量不在游戏的其他地方调用
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
-- 注: 如果需要引进其他模块，请放到此接口
function dataMgrDemo.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
-- 注: 需要在此重新初始化所有数据
function dataMgrDemo.init()
	-- body
end

-- initData
-- 使用玩家登陆数据进行初始化
-- 注: 在此没有必要发消息，因为没有地方需要这个消息
function dataMgrDemo.initData(data_)
	-- body
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function dataMgrDemo.syncData(data_)
	-- body
end

-- heartbeat
-- 心跳操作
-- 注: 这个心跳间隔最少为1秒
function dataMgrDemo.heartbeat(dt_)
	-- body
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

-- function_plb
function dataMgrDemo.function_plb(dt_)
	-- body
end



return dataMgrDemo
