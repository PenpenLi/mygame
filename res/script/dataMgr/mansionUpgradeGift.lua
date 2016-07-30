--
-- file: dataMgr/mansionUpgradeGift.lua
-- desc: 府邸升级礼包
--========================================

-- 对象
-- ==========================
local mansionUpgradeGift = {}

-- 私有数据
-- ==========================

-- 已领取等级
local level

-- 构造函数
function mansionUpgradeGift.create()

end

-- 初始化
function mansionUpgradeGift.init()
	level = 21
end

-- 初始化网络数据
function mansionUpgradeGift.initData(data)
	level = data.giftC
end

-- 同步数据
function mansionUpgradeGift.syncData(data)

end

-- 心跳
function mansionUpgradeGift.heartbeat(dt)

end

-- 对外接口
-- ==========================

-- 获取已领取府邸升级礼包等级
function mansionUpgradeGift.getLevel()
	return level
end

-- 设置已领取府邸升级礼包等级
function mansionUpgradeGift.setLevel(level_)
	level = level_
end

return mansionUpgradeGift