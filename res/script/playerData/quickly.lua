--
-- file: playerData/quickly.lua
-- desc: 快速建造、治疗、训练消耗计算
--================================================

-- 全局数据
-- ==================

-- 快速制造
-- ==================
local quicklyMgr = {}

-- 本地数据
-- ==================
local resourceMap_ = {2,3,4,5,6}
local diamondCostMap = {
	{{60,5},{900,70},{3600,130},{10800,300},{28800,650},{54000,1000},{86400,1500},{259200,4400}},
	{{3000,40},{15000,160},{50000,400},{200000,1200},{600000,3300}},
	{{30000,40},{150000,160},{500000,400},{2000000,1200},{6000000,3300}},
	{{10000,40},{50000,160},{150000,400},{500000,1200},{1500000,3300}},
	{{10000,40},{50000,160},{150000,400},{500000,1200},{1500000,3300}},
	{{10000,40},{50000,160},{150000,400},{500000,1200},{1500000,3300}}
}

local function getDiamondCost(num_, index_)
	if num_ == 0 then
		return 0
	end
	local box_ = diamondCostMap[index_]
	for i, v in ipairs(box_) do
		if v[1] > num_ then
			return v[2]
		end
	end
	
	-- 没有一个足够的资源，则反复使用最多的
	local max_ = box_[table.getn(box_)]
	local needNum_ = math.ceil(num_ / max_[1])
	return max_[2] * needNum_
end

-- 全局方法
-- ==================
function quicklyMgr.init()
end

-- 获得钻石消耗
-- items_格式{{sid_,num_},...}
function quicklyMgr.getDiamondCost(resouce_, time_, items_)
	local diamond_ = 0

	-- 道具花费
	if items_ ~= nil then
		for i, v in ipairs(items_) do
			local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", v[1])
			local have_ = player.getItemNum(v[1])
			local buyNum_ = v[2] - have_
			if buyNum_ > 0 then
				diamond_ = itemInfo_.sale * buyNum_
			end
		end
	end

	-- 资源花费钻石
	for i, v in ipairs(resourceMap_) do
		local need_ = resouce_[v] - player.getResource(game.data.resType[v][1])
		-- 不够则购买
		if need_ > 0 then
			diamond_ = diamond_ + getDiamondCost(need_, v)
		end
	end	
	cclog_("getDiamondCost",diamond_)
	-- 时间花费
	diamond_ = diamond_ + getDiamondCost(time_, 1)
	cclog_("getDiamondCosttime_",diamond_)
	return diamond_
end

return quicklyMgr