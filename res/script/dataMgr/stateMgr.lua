--
-- file: dataMgr/stateMgr.lua
-- desc: 管理玩家身上的各种状态
--================================================

-- 对象
-- ================================
-- ********************************
local stateMgr = {}

-- 私有数据
-- ================================
-- ********************************
local noSpeakState = false --是否被禁言


-- 私有函数
-- ================================
-- ********************************

-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function stateMgr.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function stateMgr.init()
	noSpeakState = false
end

-- initData
-- 使用玩家登陆数据进行初始化
function stateMgr.initData(data_)
	local noSpeak = data_.speak
	if noSpeak and noSpeak~=0 then
		noSpeakState = true
	end
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function stateMgr.syncData(data_)
	if data_.logout~=nil then
	-- 被服务器踢下线
		if data_.logout==1 or data_.logout==2 then
			game.sdkHelper.onDisconnect(data_.logout)
		else
			game.sdkHelper.onDisconnect(3)
		end
	elseif data_.speak~= nil then
		if data_.speak == 0 then
			require("ui/msgBox/warningMsgBox")
			local quitMsg =  UI_warningMsgBox.new(hp.lang.getStrByID(10601), hp.lang.getStrByID(10605),
								hp.lang.getStrByID(10603))
			game.curScene:addModalUI(quitMsg, 998)
			noSpeakState = false
		elseif data_.speak == 1 then
			require("ui/msgBox/warningMsgBox")
			local quitMsg =  UI_warningMsgBox.new(hp.lang.getStrByID(10601), hp.lang.getStrByID(10604),
								hp.lang.getStrByID(10603))
			game.curScene:addModalUI(quitMsg, 998)
			noSpeakState = true
		end

	end

end

-- heartbeat
-- 心跳操作
function stateMgr.heartbeat(dt_)
	-- body
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

function stateMgr.getNospeak( ... )
	-- body
	return noSpeakState
end



return stateMgr

