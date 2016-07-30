--
-- file: dataMgr/resourceMgr.lua
-- desc: 玩家资源(钻石、白银、粮草...)管理
--================================================


-- 对象
-- ================================
-- ********************************
local resourceMgr = {}


-- 私有数据
-- 注: 这些数据仅在此定义，初始化操作请放入resourceMgr.init()
-- ================================
-- ********************************
local resourceMap


-- 私有函数
-- ================================
-- ********************************


-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function resourceMgr.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function resourceMgr.init()
	resourceMap = {}
end

-- initData
-- 使用玩家登陆数据进行初始化
function resourceMgr.initData(data_)
	for i, v in ipairs(game.data.resInfo) do
		if data_[v.code] ~=nil then
			resourceMap[v.code] = data_[v.code]
		end
	end
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function resourceMgr.syncData(data_)
	for i, v in ipairs(game.data.resInfo) do
		if data_[v.code] ~=nil then
			resourceMgr.setResource(v.code, data_[v.code])
		end
	end
end

-- heartbeat
-- 心跳操作
function resourceMgr.heartbeat(dt_)
	-- body
end


-- 对外接口
-- ================================
-- ********************************

-- getResourceShow
-- 获取资源量显示( 以k为单位 )
function resourceMgr.getResourceShow(res_)
	if res_=="gold" then
		return hp.common.changeNumUnit1(resourceMgr.getResource(res_),100000)
	else
		return hp.common.changeNumUnit(resourceMgr.getResource(res_))
	end
end

-- getResource
-- 获取资源数量
function resourceMgr.getResource(res_)
	return resourceMap[res_] or 0
end

-- setResource
-- 设置资源数量
function resourceMgr.setResource(res_, num_)
	resourceMap[res_] = num_

	hp.msgCenter.sendMsg(hp.MSG.RESOURCE_CHANGED, {name=res_, num=resourceMap[res_]})
end

-- addResource
-- 添加资源
function resourceMgr.addResource(res_, num_)
	resourceMap[res_] = resourceMgr.getResource(res_)+num_

	hp.msgCenter.sendMsg(hp.MSG.RESOURCE_CHANGED, {name=res_, num=resourceMap[res_]})
end

-- expendResource
-- 消耗资源
function resourceMgr.expendResource(res_, num_)
	resourceMap[res_] = resourceMgr.getResource(res_)-num_

	hp.msgCenter.sendMsg(hp.MSG.RESOURCE_CHANGED, {name=res_, num=resourceMap[res_]})
end



return resourceMgr
