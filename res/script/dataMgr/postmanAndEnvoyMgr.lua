------------------------------------
-- dataMgr/postmanAndEnvoyMgr.lua
-- 斥候和使者状态管理
-- =================================

-- 对象
-- ================================
local postmanAndEnvoyMgr = {}

-- 私有数据
-- ================================
local envoyIsLight
local postmanIsLight

local envoyIsClick
local curUnionWarNum
local postmanIsClick
local curMailNum

local isFirst

-- 构造函数
function postmanAndEnvoyMgr.create()

end

-- 初始化
function postmanAndEnvoyMgr.init()
	envoyIsLight = false
	postmanIsLight = false
	envoyIsClick = false
	curUnionWarNum = 0
	postmanIsClick = false
	curMailNum = 0
	isFirst = true

	-- 注册消息
	local function registMsg(msg_)
		hp.msgCenter.addMsgMgr(msg_, mansionMgr)
	end
	-- 联盟数据更改
	registMsg(hp.MSG.UNION_DATA_PREPARED)
end

-- 初始化网络数据
function postmanAndEnvoyMgr.initData(data)
	
end

-- 同步数据
function postmanAndEnvoyMgr.syncData(data)

end

-- 心跳
function postmanAndEnvoyMgr.heartbeat(dt)

end

-- 对外接口
-- ================================

function postmanAndEnvoyMgr.setEnvoyIsLight(param_)
	envoyIsLight = param_
	hp.msgCenter.sendMsg(hp.MSG.PM_CHECK_CHANGE)
end

function postmanAndEnvoyMgr.setPostmanIsLight(param_)
	postmanIsLight = param_
	hp.msgCenter.sendMsg(hp.MSG.PM_CHECK_CHANGE)
end

function postmanAndEnvoyMgr.getEnvoyIsLight()
	return envoyIsLight
end

function postmanAndEnvoyMgr.getPostmanIsLightOnInit()
	postmanIsLight = false
	if postmanIsClick then
		return postmanIsLight
	end
	
	curMailNum = player.mailCenter.getAllUnreadMailNum()
	 
	local isLight = curMailNum > 0
	if isLight then
		postmanIsLight = true
	end
	return postmanIsLight
end

function postmanAndEnvoyMgr.getPostmanIsLightOnMsg()

	local mailNum = player.mailCenter.getAllUnreadMailNum()
	
	if curMailNum < mailNum then
		postmanIsLight = true
		postmanIsClick = false 
	else
		curMailNum = mailNum
		postmanIsLight = false
	end
	return postmanIsLight
end

function postmanAndEnvoyMgr.getEnvoyIsLightOnMsg()
	
	local unionWar = player.getAlliance():getUnionHomePageInfo().unionWar

	if unionWar == nil then
		return false
	elseif unionWar > curUnionWarNum then
		envoyIsLight = true
		envoyIsClick = false 
	else
		curUnionWarNum = unionWar
	end
	
	return envoyIsLight
end


function postmanAndEnvoyMgr.getEnvoyIsLightOnInit()
	
	envoyIsLight = false
	
	if envoyIsClick then
		return envoyIsLight
	end
	
	curUnionWarNum = player.getAlliance():getUnionHomePageInfo().unionWar
	
	if curUnionWarNum == nil then
		curUnionWarNum = 0
	elseif curUnionWarNum > 0 then
		envoyIsLight = true
	end

	isFirst = false
	
	return envoyIsLight
end



function postmanAndEnvoyMgr.getPostmanIsLight()
	return postmanIsLight
end

function postmanAndEnvoyMgr.getEnvoyIsLight()
	return envoyIsLight
end

function postmanAndEnvoyMgr.setEnvoyIsClick(param_)
	envoyIsClick = param_
end

function postmanAndEnvoyMgr.setPostmanIsClick(param_)
	postmanIsClick = param_
end

function postmanAndEnvoyMgr.setCurUnionWarNum(param_)
	curUnionWarNum = param_
end

function postmanAndEnvoyMgr.setCurMailNum(param_)
	curMailNum = param_
end

function postmanAndEnvoyMgr.getEnvoyIsClick()
	return envoyIsClick
end

function postmanAndEnvoyMgr.getPostmanIsClick()
	return postmanIsClick
end

function postmanAndEnvoyMgr.getCurUnionWarNum()
	return curUnionWarNum
end

function postmanAndEnvoyMgr.getCurMailNum()
	return curMailNum
end

function postmanAndEnvoyMgr.isFirst()
	return isFirst
end

function postmanAndEnvoyMgr.onMsg(msg_, param_)
	-- 联盟战争更新
	if param_ == dirtyType.VARIABLENUM and player.getAlliance():getUnionHomePageInfo().param.change.unionWar then
		envoyIsClick = false
	end
end


return postmanAndEnvoyMgr