--
-- file: dataMgr/noviceGiftMgr.lua
-- desc: 新手礼包
--================================================

-- 对象
-- ================================
local noviceGiftMgr = {}

-- 私有数据
-- ================================
local day
local isSign
local days

-- 私有函数
-- ================================

-- player调用接口函数
-- ================================

-- 构造函数，player对象构建时，加载此模块，并调用
function noviceGiftMgr.create()
end

-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function noviceGiftMgr.init()
	day = 0
	isSign = false
	days = {}
end

-- 使用玩家登陆数据进行初始化
function noviceGiftMgr.initData(data_)
	if data_.new7d then
		day = data_.new7d[1] + 1
		isSign = data_.new7d[2] ~= 0
		for i = 1, 14 do
			local d = hp.common.band(data_.new7d[3], math.pow(2, i - 1))
			table.insert(days, d)
		end
	else
		day = -1
		isSign = true
	end
end

-- 根据服务器心跳返回的数据，进行数据同步
function noviceGiftMgr.syncData(data_)
end

-- 心跳操作
function noviceGiftMgr.heartbeat(dt_)
end

-- 对外接口
-- ================================

-- 获取今日领取时间
function noviceGiftMgr.getDay()
	return day
end

-- 获取今日是否可领取
function noviceGiftMgr.isSign()
	return isSign
end

-- 获取领取列表
function noviceGiftMgr.getDays()
	return days
end

-- 领取
function noviceGiftMgr.receive()
	days[day] = 1
	isSign = true
	hp.msgCenter.sendMsg(hp.MSG.NOVICE_GIFT)
end

return noviceGiftMgr