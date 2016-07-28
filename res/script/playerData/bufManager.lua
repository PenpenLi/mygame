--
-- file: playerData/bufManager.lua
-- desc: 各加成管理器
--================================================

-- 全局数据
-- ==================

-- 科技加成
-- ==================
researchBufMgr = {}

-- 本地数据
-- ==================

-- 全局方法
-- ==================

-- 根据属性id获取加成
function researchBufMgr.getAdditionByAttrID(sid_)
	local researchs_ = hp.gameDataLoader.getTable("research")
	if researchs_ == nil then
		return 0
	end

	for i, v in ipairs(researchs_) do
		if v.type1 == sid_ then
			if player.researchMgr.isTechResearch(v.sid) then
				return v.value1
			end
		elseif v.type2 == sid_ then
			if player.researchMgr.isTechResearch(v.sid) then
				return v.value2
			end
		end
	end
	return 0
end


-- 英雄加成
-- ==================
heroBufMgr = {}

-- 本地数据
-- ==================

-- 全局方法
-- ==================

-- 根据属性id获取加成
function heroBufMgr.getAdditionByAttrID(sid_)
	return 0
end