-----------------------------------------------
-- dataMgr/mansionMgr/protocolOfficerMgr.lua
-- 府邸礼官状态管理器
-- ============================================

-- 对象
-- ================================
local protocolOfficerMgr = {}

-- 私有方法
-- ================================

-- 新手奖励
local function haveNoviceGfit()
	return not player.noviceGiftMgr.isSign()
end

-- 是否签到
local function isSign()
	return not player.signinMgr.isSign()
end

-- 在线礼包
local function haveOnlineGift()
	-- cd完毕
	local canReceive = player.onlineGift.getCD() <= 0
	-- 有礼包
	local onlineGift = player.onlineGift.getItemSid() > 0
	return canReceive and onlineGift
end

-- 联盟礼包
local function haveUnionGift()
	local unionGitf = player.getAlliance():getUnionGift()

	for i,v in ipairs (unionGitf) do
		-- 可以领取
		if v.state == 1 and v.endTime > player.getServerTime() then
			return true
		end
	end
	return false
end

-- 升级礼包
local function haveUpgradeGift()
	-- 服务器府邸等级
	local serverLevel = player.mansionUpgradeGift.getLevel()
	-- 本地府邸等级
	local localLevel = player.buildingMgr.getBuildingMaxLvBySid(1001)

	return serverLevel < localLevel
end

-- 获取状态
local function status()
	if haveNoviceGfit() then
		return true
	end
	if isSign() then
		return true
	end
	if haveOnlineGift() then
		return true
	end
	if haveUnionGift() then
		return true
	end
	if haveUpgradeGift() then
		return true
	end
	return false
end

-- 构造函数
function protocolOfficerMgr.create()
	
end

-- 初始化
function protocolOfficerMgr.init()
	
end

-- 初始化网络数据
function protocolOfficerMgr.initData(data)
	
end

-- 同步数据
function protocolOfficerMgr.syncData(data)
	
end

-- 心跳
function protocolOfficerMgr.heartbeat(dt)
	
end

-- 对外接口
-- ================================

-- 是否发光
function protocolOfficerMgr.isLight()
	return status()
end

return protocolOfficerMgr