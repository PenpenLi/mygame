--
-- file: playerData/bufManager/titleBufManager.lua
-- desc: 头衔加成管理器
-- msg:	 TITLE_INFO
-- msgType: 1-刷新
--================================================

-- 全局数据
-- ==================

-- 加成管理器
-- ==================
local titleBufManager = {}

-- 本地数据
-- ==================

local local_title = 0
local local_info = nil

local function initTileInfo(id_)
	local_title = id_
	local_info = nil
	if id_ ~= 0 then
		local_info = hp.gameDataLoader.getInfoBySid("kingTitle", id_)
	end
	hp.msgCenter.sendMsg(hp.MSG.TITLE_INFO, {msgType = 1})
end

-- ==================
-- 全局方法
-- ==================
function titleBufManager.create()
	-- body
end

function titleBufManager.init()
	local_title = 0
	local_info = nil
end

function titleBufManager.initData(info_)
	if info_.title == nil then
		return
	end

	initTileInfo(info_.title)
end

function titleBufManager.syncData(info_)
	if info_.title == nil then
		return
	end

	initTileInfo(info_.title)
end

function titleBufManager.heartbeat(dt_)
	-- body
end

-- ==================
-- 外部接口
-- ==================
-- 获取普通道具加成
function titleBufManager.getAttrAddn(attrType_)
	local addn_ = 0

	if local_info ~= nil then
		for i, v in ipairs(local_info.attrs) do
			if v == attrType_ then
				addn_ = addn_ + local_info.value[i]
			end
		end
	end

	return addn_
end

return titleBufManager