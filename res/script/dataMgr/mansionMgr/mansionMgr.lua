---------------------------------------
-- dataMgr/mansionMgr/mansionMgr.lua
-- 府邸状态管理器
-- ====================================

-- 对象
-- ================================
local mansionMgr = {}

-- 公有方法
-- ================================

-- 构造函数
function mansionMgr.create()
	mansionMgr.primeMinisterMgr = require("dataMgr/mansionMgr/primeMinisterMgr")
	mansionMgr.primeMinisterMgr.create()
	mansionMgr.generaMgr = require("dataMgr/mansionMgr/generalMgr")
	mansionMgr.generaMgr.create()
	mansionMgr.protocolOfficerMgr = require("dataMgr/mansionMgr/protocolOfficerMgr")
	mansionMgr.protocolOfficerMgr.create()
end

-- 初始化
function mansionMgr.init()
	mansionMgr.primeMinisterMgr.init()
	mansionMgr.generaMgr.init()
	mansionMgr.protocolOfficerMgr.init()
end

-- 初始化网络数据
function mansionMgr.initData(data)

	-- 注册消息
	local function registMsg(msg_)
		hp.msgCenter.addMsgMgr(msg_, mansionMgr)
	end

	-- 联盟数据
	player.getAlliance():prepareData(dirtyType.UNIONGIFT, "mansionMgr")
	-- 礼官
	registMsg(hp.MSG.ONLINE_GIFT)
	registMsg(hp.MSG.UNION_DATA_PREPARED) -- 使者
	registMsg(hp.MSG.UNION_RECEIVE_GIFT)
	registMsg(hp.MSG.UPGRADEGIFT_GET)
	registMsg(hp.MSG.VIP)
	registMsg(hp.MSG.SIGN_IN)
	-- 丞相
	registMsg(hp.MSG.CD_STARTED)
	registMsg(hp.MSG.CD_FINISHED)
	registMsg(hp.MSG.MISSION_DAILY_COLLECTED)
	registMsg(hp.MSG.MISSION_DAILY_REFRESH)
	registMsg(hp.MSG.MISSION_DAILY_QUICKFINISH)
	registMsg(hp.MSG.UNION_DATA_PREPARED)
	registMsg(hp.MSG.PM_CHECK_CHANGE)
	registMsg(hp.MSG.MARCH_MANAGER)
	registMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	registMsg(hp.MSG.KING_BATTLE)
	registMsg(hp.MSG.COPY_NOTIFY)
	registMsg(hp.MSG.UNION_HELP_INFO_CHANGE)
	registMsg(hp.MSG.HOSPITAL_HEAL_FINISH)
	registMsg(hp.MSG.FAMOUS_HERO_NUM_CHANGE)
	-- 将军
	registMsg(hp.MSG.SKILL_CHANGED)
	registMsg(hp.MSG.LV_CHANGED)
	registMsg(hp.MSG.HERO_INFO_CHANGE)
	-- 斥候
	registMsg(hp.MSG.MAIL_CHANGED)
end

-- 同步数据
function mansionMgr.syncData(data)

end

-- 心跳
function mansionMgr.heartbeat(dt)

end

-- 对外接口
-- ================================

-- 是否发光
function mansionMgr.isLight()
	if player.postmanAndEnvoyMgr.getPostmanIsLightOnMsg() then
		return true
	end
	if player.postmanAndEnvoyMgr.getEnvoyIsLightOnMsg() then
		return true
	end
	if mansionMgr.primeMinisterMgr.isLight() then
		return true
	end
	if mansionMgr.generaMgr.isLight() then
		return true
	end
	if mansionMgr.protocolOfficerMgr.isLight() then
		return true
	end
	return false
end

function mansionMgr:onMsg(msg_, param_)
	hp.msgCenter.sendMsg(hp.MSG.MAIN_MENU_MANSION_LIGHT, mansionMgr.isLight())
end


return mansionMgr