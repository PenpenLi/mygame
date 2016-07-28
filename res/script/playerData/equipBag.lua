--
-- file: playerData/equipBag.lua
-- desc: 玩家装备包
--================================================


-- obj
--=======================
local equipBag = {}

-- 装备类型
equipBag.EquipType = 
{
	WEAPON = 1,			--武器
	HEAD = 2,			--头部
	CHEST = 3,			--胸部
	ACCESSORY = 4,		--装饰
	FOOT = 5,			--鞋子
}

-- private datas
--=======================
local size = 12				--背包容量
local maxSize = 24			--背包最大容量
local equips = {}			--装备列表
local equips_equiped = {}	--已穿戴的装备

-- 装备类
local Equip = class("Equip")
-- ctor
function Equip:ctor(dataInfo_)
	self.sid = dataInfo_[1]
	self.id = dataInfo_[2]
	self.lv = dataInfo_[3]+1

	self.gems = {}
	for i, v in ipairs(dataInfo_[4]) do
		table.insert(self.gems, v)
	end

	self.equipedFlag = false
end
-- isEquiped
function Equip:isEquiped()
	return self.equipedFlag
end
-- 摧毁
function Equip:destory()
	for i,v in ipairs(equips) do
		if v.id==self.id then
			table.remove(equips, i)
			return true
		end
	end

	return false
end

-- private fuctions
--=======================


-- public functions
--=======================

-- init
function equipBag.init()
end

-- initByData
-- 用网络数据初始化
function equipBag.initByData(size_, equips_, equips_equiped_)
	size = size_

	equips = {}
	if equips_~=nil then
		for i, v in ipairs(equips_) do
			local equip = Equip.new(v)
			table.insert(equips, equip)
		end
	end

	equips_equiped = {}
	if equips_equiped_~=nil then
		for i, v in ipairs(equips_equiped_) do
			if v>0 then
				equipBag.equipEquip(i, v)
			end
		end
	end
end

-- addEquip
-- 添加装备
function equipBag.addEquip(equipData_)
	local equip = Equip.new(equipData_)
	table.insert(equips, equip)
end

-- getMaxSize
-- 获取背包最大容量
function equipBag.getMaxSize()
	return maxSize
end

-- getSize
-- 获取背包容量
function equipBag.getSize()
	return size
end

-- extendSize
-- 扩充背包容量
function equipBag.extendSize(size_)
	size = size+size_
	if size>maxSize then
		size = maxSize
	end
end

-- getEquips
-- 获取装备列表
function equipBag.getEquips()
	return equips
end

-- getEquipsByType
-- 获取指定类型的装备
function equipBag.getEquipsByType(type_)
	local equips_ = {}
	for i,v in ipairs(equips) do
		local constInfo = hp.gameDataLoader.getInfoBySid("equip", v.sid)
		if type_==constInfo.type then
			table.insert(equips_, v)
		end
	end

	return equips_
end

-- getEquips_equiped
-- 获取已穿戴装备列表
function equipBag.getEquips_equiped()
	return equips_equiped
end

-- getEquipById
-- 获取指定id的一件装备
function equipBag.getEquipById(id_)
	for i,v in ipairs(equips) do
		if id_==v.id then
			return v
		end
	end

	return nil
end

-- equipEquip
-- 穿上一个指定id_的装备
function equipBag.equipEquip(pos_, id_)
	equipBag.unequipEquip(pos_)
	local equip = equipBag.getEquipById(id_)
	if equip~=nil then
		equip.equipedFlag = true
		equips_equiped[pos_] = equip
	end
end

-- unequipEquip
-- 脱掉指定位置的装备
function equipBag.unequipEquip(pos_)
	local equip = equips_equiped[pos_]
	if equip~=nil then
		equip.equipedFlag = false
		equips_equiped[pos_] = nil
	end
end

return equipBag
