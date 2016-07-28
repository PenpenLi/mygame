--
-- file: playerData/onlineGift.lua
-- desc: 在线礼包
--================================================

-- obj
-- ==========================
local onlineGift = {}


-- private data
-- ==========================
local itemSid = 0	--礼包开出道具的sid
local cd = 0		--打开礼包需要等待cd


-- private function
-- ==========================


-- public function
-- ==========================
-- init
-- 初始化
function onlineGift.init()
	itemSid = 0
	cd = 0
end

-- initByData
-- 用网络数据初始化
function onlineGift.initByData(data_)
	itemSid = data_[1]
	cd = data_[2]
	hp.msgCenter.sendMsg(hp.MSG.ONLINE_GIFT)
end

-- heartbeat
-- 心跳
function onlineGift.heartbeat(dt)
	if cd>0 then
		if cd<dt then
			cd = 0
			hp.msgCenter.sendMsg(hp.MSG.ONLINE_GIFT)
		else
			cd = cd-dt
		end
	end
end

-- getItemSid
-- 获取礼包道具的sid
function onlineGift.getItemSid()
	return itemSid
end

-- getCD
-- 获取礼包打开需要的cd
function onlineGift.getCD()
	return cd
end


return onlineGift