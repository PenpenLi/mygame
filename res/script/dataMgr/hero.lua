--
-- file: dataMgr/hero.lua
-- desc: 玩家英雄
--================================================

-- 对象
-- ================================
-- ********************************
local hero = {}


-- 私有数据
-- ================================
-- ********************************
local baseInfo = {} --基础信息
local constInfo = nil --表信息
local skillList = {} --技能列表
local isValid = false --英雄是否产生相应加成效果
local extSkillPoint = 0 --额外技能点儿数


-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function hero.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function hero.init()
	baseInfo = {}
	constInfo = nil
	skillList = {}
	isValid = false

	extSkillPoint = 0
end

-- initData
-- 使用玩家登陆数据进行初始化
function hero.initData(data_)
	local data = data_.hero
	if data==nil then
		isValid = false
		return
	end

	-- 基础属性
	baseInfo.sid = data[1]			--sid
	baseInfo.name = data[2]			--名字
	baseInfo.state = data[3]		--状态
	baseInfo.armyID = data[4]		--行军id
	baseInfo.id = data[6]			--id
	baseInfo.img = data[7]			--图片
	baseInfo.caughtInfo = data[8]  --关押者信息
	baseInfo.reliveLeftTime = data[9]  --武将死亡后剩余复活时间

	-- 英雄常量属性
	constInfo = hp.gameDataLoader.getInfoBySid("hero", baseInfo.sid)

	--技能
	skillList = {}
	local skillData = data[5]
	for i=1, #skillData, 2 do
		skillList[skillData[i]] = skillData[i+1] 
	end

	-- 生效
	if baseInfo.state==2 or baseInfo.state==3 then
		isValid = false
	else
		isValid = true
	end

	-- 额外技能点数
	extSkillPoint = data_.incrP or 0
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function hero.syncData(data_)
	if data_.hero~=nil then
		hero.initData(data_)
		hp.msgCenter.sendMsg(hp.MSG.HERO_INFO_CHANGE)
	end

	-- 额外技能点
	if data_.incrP then
		if data_.incrP>extSkillPoint then
		-- 有新的技能点儿
			hp.msgCenter.sendMsg(hp.MSG.SKILL_CHANGED)
		end
		extSkillPoint = data_.incrP
	end
end

-- heartbeat
-- 心跳操作
function hero.heartbeat(dt_)
	if baseInfo.state==1 and #baseInfo.caughtInfo > 4 then
		baseInfo.caughtInfo[4] = baseInfo.caughtInfo[4] - dt_
		if baseInfo.caughtInfo[4] < 0 then
			baseInfo.caughtInfo[4] = 0
			baseInfo.state = 0
			hp.msgCenter.sendMsg(hp.MSG.HERO_INFO_CHANGE)
		end
	elseif baseInfo.state==2 then
		baseInfo.reliveLeftTime = baseInfo.reliveLeftTime - dt_
		if baseInfo.reliveLeftTime <= 0 then
			baseInfo.state = 3
			hp.msgCenter.sendMsg(hp.MSG.HERO_INFO_CHANGE)
		end
	end
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

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

-- setSkillList
function hero.setSkillList(skillList_)
	skillList = skillList_
	hp.msgCenter.sendMsg(hp.MSG.SKILL_CHANGED)
end

-- isValid
function hero.isValid()
	return isValid
end


-- getSkillLv
function hero.getSkillLv(skillId_)
	return skillList[skillId_] or 0
end


-- getSkillPoint
-- 获取技能点数
function hero.getSkillPoint()
	-- 获取等级产生的技能点数
	local lv = player.getLv()
	local lvPointNum = 0
	for i, v in ipairs(game.data.heroLv) do
		lvPointNum = lvPointNum+v.dit
		if v.level>=lv then
			break
		end
	end

	-- 获取已经分配的技能点数
	local pointUsed = 0
	for k,v in pairs(skillList) do
		pointUsed = pointUsed+v
	end

	return lvPointNum+extSkillPoint - pointUsed
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