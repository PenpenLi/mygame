--
-- file: playerData/buildingMgr.lua
-- desc: 玩家建筑管理
--================================================

-- obj
-- ==========================
local  buildingMgr = {}


-- private data
-- ==========================
local insideBuildings = {}		--bsid-城内建筑 {[bsid] = building, ...}
local outsideBuildings = {}		--bsid-城外建筑
local buildingMap = {}			--sid-建筑 映射表	{[sid]={building, ...}, ...}


-- private function
-- ==========================
local function initBuildingByData(bType_, data_)
	local building = {}
	building.sid = data_[1]		--建筑sid
	building.lv = data_[2]		--建筑等级
	building.bsid = data_[3]	--建筑所在地块的sid
	building.bType = bType_	--类型: 1--城内建筑，2--城外建筑

	return building
end

-- public function
-- ==========================
-- init
function buildingMgr.init()
	insideBuildings = {}
	outsideBuildings = {}
	buildingMap = {}
end

-- initByData
function buildingMgr.initByData(insideData_, outsideData_)
	buildingMap = {}

	insideBuildings = {}
	if insideData_~=nil then
		for i, data in ipairs(insideData_) do
			buildingMgr.addBuilding(initBuildingByData(1, data))
		end
	end

	outsideBuildings = {}
	if outsideData_~=nil then
		for i, data in ipairs(outsideData_) do
			buildingMgr.addBuilding(initBuildingByData(2, data))
		end
	end
end

-- getBuildings
-- 获取建筑列表
-- @bType_: 建筑类型, 1--城内，2--城外
function buildingMgr.getBuildings(bType_)
	if bType_==1 then
		return insideBuildings
	elseif bType_==2 then
		return outsideBuildings
	end

	return {}
end

-- addBuilding
-- 添加一个建筑
function buildingMgr.addBuilding(building_)
	local blist = buildingMgr.getBuildings(building_.bType)
	blist[building_.bsid] = building_
	buildingMap[building_.sid] = buildingMap[building_.sid] or {}
	table.insert(buildingMap[building_.sid], building_)
end

-- removeBuilding
-- 移除一个建筑
function buildingMgr.removeBuilding(building_)
	local blist = buildingMgr.getBuildings(building_.bType)
	blist[building_.bsid] = nil

	if buildingMap[building_.sid]~=nil then
		for i,v in ipairs(buildingMap[building_.sid]) do
			if building_.bsid==v.bsid then
				table.remove(buildingMap[building_.sid], i)
			end
		end
	end
end

-- getBuildingsBySid
-- 获取指定sid的所有建筑
-- @sid_: 建筑sid
function buildingMgr.getBuildingsBySid(sid_)
	return buildingMap[sid_] or {}
end

-- getMaxLvBuildingBySid
-- 获取指定sid中等级最高的建筑
-- @sid_: 建筑sid
function buildingMgr.getMaxLvBuildingBySid(sid_)
	local building = nil
	if buildingMap[sid_]~=nil then
		for i,v in ipairs(buildingMap[sid_]) do
			if building==nil or building.lv<v.lv then
				building = v
			end
		end
	end

	return building
end

-- getBuildingMaxLvBySid
-- 获取指定sid的建筑最大等级
-- @sid_: 建筑sid
function buildingMgr.getBuildingMaxLvBySid(sid_)
	local lv = 0
	if buildingMap[sid_]~=nil then
		for i,v in ipairs(buildingMap[sid_]) do
			if lv<v.lv then
				lv = v.lv
			end
		end
	end

	return lv
end

-- getBuildingNumBySid
-- 获取指定sid的建筑个数
-- @sid_: 建筑sid
function buildingMgr.getBuildingNumBySid(sid_)
	if buildingMap[sid_]~=nil then
		return table.getn(buildingMap[sid_])
	end

	return 0
end

-- getBuildingByBsid
-- 获取指定地块上的建筑
-- @bType_: 地块类型, 1--城内; 2--城外
-- @bSid_: 地块sid
function buildingMgr.getBuildingByBsid(bType_, bSid_)
	local blist = buildingMgr.getBuildings(bType_)

	return blist[bSid_]
end

return buildingMgr
