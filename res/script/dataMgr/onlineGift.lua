--
-- file: dataMgr/onlineGift.lua
-- desc: 在线礼包
--================================================

-- 对象
-- ==========================
local onlineGift = {}

-- 私有数据
-- ==========================
local itemSid	--礼包开出道具的sid
local cd		--打开礼包需要等待cd

-- 构造方法
function onlineGift.create()
	
end

-- 初始化
function onlineGift.init()
	itemSid = 0
	cd = 0
end

-- 初始化网络数据
function onlineGift.initData(data_)
	local data = data_.onlineGift
	itemSid = data[1]
	cd = data[2]
end

-- 同步数据
function onlineGift.syncData(data_)
	
end

-- 心跳
function onlineGift.heartbeat(dt)
	if cd>0 then
		if cd<=dt then
			cd = 0
			hp.msgCenter.sendMsg(hp.MSG.ONLINE_GIFT)
		else
			cd = cd-dt
		end
	end
end

-- 对外接口
-- ==========================

function onlineGift.initByData(data_)
	itemSid = data_[1]
	cd = data_[2]
	hp.msgCenter.sendMsg(hp.MSG.ONLINE_GIFT)
end

-- 获取礼包道具的sid
function onlineGift.getItemSid()
	return itemSid
end

-- 获取礼包打开需要的cd
function onlineGift.getCD()
	return cd
end


return onlineGift