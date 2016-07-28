--
-- file: playerData/hero.lua
-- desc: 玩家英雄
--================================================

-- obj
-- ==========================
local hero = {}


-- private data
-- ==========================
local baseInfo = {}
local constInfo = nil
local skillList = {}
local isValid = false

-- private function
-- ==========================


-- public function
-- ==========================

-- init
function hero.init()
	isValid = false
end

-- initByData
function hero.initByData(data_)
	if data_==nil then
		isValid = false
		return
	end

	-- 基础属性
	baseInfo = {}
	baseInfo.sid = data_[1]			--sid
	baseInfo.name = data_[2]		--名字
	baseInfo.state = data_[3]		--状态
	baseInfo.armyID = data_[4]		--行军id
	baseInfo.id = data_[6]			--id
	baseInfo.img = data_[7]			--图片

	-- 英雄常量属性
	constInfo = hp.gameDataLoader.getInfoBySid("hero", baseInfo.sid)

	--技能
	skillList = {}
	local skillData = data_[5]
	for i=1, #skillData, 2 do
		skillList[skillData[i]] = skillData[i+1] 
	end

	isValid = true

	-- 通知英雄及其技能变化
	hp.msgCenter.sendMsg(hp.MSG.HERO_INFO_CHANGE)
	hp.msgCenter.sendMsg(hp.MSG.SKILL_CHANGED)
end

-- getBaseInfo
function hero.getBaseInfo()
	return baseInfo
end

-- getConstInfo
function hero.getConstInfo()
	return constInfo
end

-- getSkillList
function hero.getSkillList()
	return skillList
end

-- isValid
function hero.isValid()
	return isValid
end


-- getSkillLv
function hero.getSkillLv(skillId_)
	return skillList[skillId_] or 0
end

-- getAttrAddn
-- 获取属性加成
-- @attrType_: 加成属性类型
function hero.getAttrAddn(attrType_)
	local addn = 0

	if hero.isValid() then
		-- 英雄技能加成
		for i, skillInfo in ipairs(game.data.skill) do
			local lv = skillList[skillInfo.sid] or 0
			if lv>0 then
				if attrType_==skillInfo.type1 then
					addn = addn+skillInfo.value1[lv]
				end
				if attrType_==skillInfo.type2 then
					addn = addn+skillInfo.value2[lv]
				end
			end
		end

		-- 特殊技能(天赋)加成
		local lv = player.getLv()
		for i, v in ipairs(constInfo.flair) do
			if v>0 then
				if lv>=constInfo.flairLv[i] then
					local spInfo = hp.gameDataLoader.getInfoBySid("spSkill", v)
					if spInfo~=nil then
						if attrType_==spInfo.type1 then
							addn = addn+spInfo.value1
						end
						if attrType_==spInfo.type2 then
							addn = addn+spInfo.value2
						end
						if attrType_==spInfo.type3 then
							addn = addn+spInfo.value3
						end
					end
				end
			end
		end

		-- 装备加成
		local equips = player.equipBag.getEquips_equiped()
		for k, equip in pairs(equips) do
			local equipInfo = hp.gameDataLoader.getInfoBySid("equip", equip.sid)
			if equipInfo~=nil then
				if attrType_==equipInfo.type1 then
					addn = addn+equipInfo.value1[equip.lv]
				end
				if attrType_==equipInfo.type2 then
					addn = addn+equipInfo.value2[equip.lv]
				end
				if attrType_==equipInfo.type3 then
					addn = addn+equipInfo.value3[equip.lv]
				end
				if attrType_==equipInfo.type4 then
					addn = addn+equipInfo.value4[equip.lv]
				end
			end
			-- 宝石加成
			for i, v in ipairs(equip.gems) do
				if v>0 then
					local gemInfo = hp.gameDataLoader.getInfoBySid("gem", v)
					if gemInfo~=nil then
						for i, type_ in ipairs(gemInfo.key) do
							if attrType_==type_ then
								addn = addn+gemInfo.value[i]
							end
						end
					end
				end
			end
		end
	end

	return addn
end

return hero