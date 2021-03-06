--
-- file: hp/gameDataLoader.lua
-- desc: 从tab表加载游戏数据
--================================================

--
--
--=====================================
hp.gameDataLoader = {}


-- data types
local int = 1
local str = 2
local ints = 3
local strs = 4

-- string --> array
local function strSplit(str_, sep_, type_)
	local t = {}
	
	for str in string.gmatch(str_, "([^"..sep_.."]+)") do
		if type_==int then
			table.insert(t, tonumber(str))
		else
			table.insert(t, str)
		end
	end
	
	return t
end

-- type string desc --> type int desc
local function datatypeTrans(types_)
	local types = {}
	
	for k,v in ipairs(types_) do
		if "int"==string.lower(v) then
			table.insert(types, int)
		elseif "string"==string.lower(v) then
			table.insert(types, str)
		elseif "ints"==string.lower(v) then
			table.insert(types, ints)
		elseif "strings"==string.lower(v) then
			table.insert(types, strs)
		else
			cclog("game data type(%s) error", v)
		end
	end
	
	return types
end

-- loadFileData
function hp.gameDataLoader.loadFileData(file_)
	local data = {}
	local strLines = cc.FileUtils:getInstance():getStringFromFile(file_)
	local strLen = string.len(strLines)
	
	local i = 1
	local keys = {}
	local keyNum = 0
	local types = {}
	local values = {}
	local strLine = nil

	local pos = 1
	while pos<strLen do
		local posStart, posEnd = string.find(strLines, "\r\n", pos)
		if posStart==nil or posEnd==nil then
			strLine = string.sub(strLines, pos, strLen)
			pos = strLen
		else
			if pos~=posStart then
				strLine = string.sub(strLines, pos, posStart-1)
			else
				strLine = ""
			end
			pos = posEnd+1
		end

		if i==1 then
		elseif i==2 then
		elseif i==3 then
			keys = strSplit(strLine, "\t")
			keyNum = table.getn(keys)
		elseif i==4 then
			types = datatypeTrans(strSplit(strLine, "\t"))
		elseif string.len(strLine)>0 then
			local j = 1
			local d = {}
			values = strSplit(strLine, "\t")
			for j=1, keyNum, 1 do
				if int==types[j] then
					d[keys[j]] = tonumber(values[j])
				elseif str==types[j] then
					d[keys[j]] = values[j]
				elseif ints==types[j] then
					d[keys[j]] = strSplit(values[j], "|", int)
				elseif strs==types[j] then
					d[keys[j]] = strSplit(values[j], "|")
				end
			end
			table.insert(data, d)
		end
		
		i = i+1
	end

	return data
end

-- loadData
function hp.gameDataLoader.loadData()
	local data = {}
	local loadFunc = hp.gameDataLoader.loadFileData
	
	data.block         =    loadFunc("data/block.tab")
	data.building      =    loadFunc("data/Building.tab")
	data.upgrade       =    loadFunc("data/BuildingUpgrade.tab")
	data.res           =    loadFunc("data/B_ziyuan.tab")
	data.army 		   =    loadFunc("data/Army.tab")
	data.barrack	   =    loadFunc("data/B_barracks.tab")
	data.research      =    loadFunc("data/Research.tab")
	data.main  		   =    loadFunc("data/B_main.tab")
	data.skill         =    loadFunc("data/Skill.tab")
	data.hero          =    loadFunc("data/Hero.tab")
	data.heroLv        =    loadFunc("data/HeroLv.tab")
	data.trap          =    loadFunc("data/Trap.tab")
	data.wall          =    loadFunc("data/B_wall.tab")
	data.resources     =    loadFunc("data/Resources.tab")
	data.fieldFunc     =    loadFunc("data/FieldFunction.tab")
	data.item          =    loadFunc("data/Item.tab")
	data.hospital      =    loadFunc("data/B_hospital.tab")
	data.quests		   =	loadFunc("data/Quests.tab")
	data.rewards	   =	loadFunc("data/QuestRewards.tab")
	data.resInfo	   = 	loadFunc("data/ResInfo.tab")
	data.equip         =    loadFunc("data/Equipment.tab")
	data.equipMaterial =    loadFunc("data/EquipmentMaterial.tab")
	data.equipOdds     =    loadFunc("data/EquipmentOdds.tab")
	data.hospital 	   =	loadFunc("data/B_hospital.tab")
	data.gem           =    loadFunc("data/Gem.tab")
	data.boss		   = 	loadFunc("data/BOSS.tab")
	data.newBoss	   = 	loadFunc("data/NEWBOSS.tab")
	data.unionRank	   =	loadFunc("data/unionRank.tab")
	data.attr		   = 	loadFunc("data/Attribute.tab")
	data.market		   =	loadFunc("data/B_marketplace.tab")
	data.armyType	   =	loadFunc("data/ArmyType.tab")
	data.allienceRank  =	loadFunc("data/AllienceRank.tab")
	data.shopID		   =	loadFunc("data/ShopID.tab")
	data.vip		   =	loadFunc("data/Vip.tab")
	data.altar		   =	loadFunc("data/B_altar.tab")
	data.smallFight    =	loadFunc("data/SmallBattle.tab")
	data.bigFight      =	loadFunc("data/LargeBattle.tab")
	data.guide         =    loadFunc("data/Guide.tab")
	data.embassy	   =	loadFunc("data/B_embassy.tab")
	data.academy       =	loadFunc("data/B_academy.tab")
	data.prison        =	loadFunc("data/B_prison.tab")
	data.storehouse    =	loadFunc("data/B_storehouse.tab")
	data.gymnos    	   =	loadFunc("data/B_gymnos.tab")
	data.forge    	   =	loadFunc("data/B_forge.tab")
	data.unionGift	   =	loadFunc("data/AllienceGift.tab")
	data.unionGiftlv   =	loadFunc("data/AllienceGiftLv.tab")
	data.hintFrame	   =	loadFunc("data/hintFrame.tab")
	data.spSkill	   =	loadFunc("data/SpecialSkill.tab")
	data.watchtower	   =	loadFunc("data/B_watchtower.tab")
	data.hallofwar     =    loadFunc("data/B_hallofwar.tab")
	data.villa         =    loadFunc("data/B_villa.tab")
	data.instanceGroup =    loadFunc("data/InstanceGroup.tab")
	data.instance      =    loadFunc("data/Instance.tab")
	data.groupShow     =    loadFunc("data/instanceGroupShow.tab")
	data.bufShow	   =	loadFunc("data/BufShowConfig.tab")
	data.uiBufManager  =	loadFunc("data/UIBufManager.tab")
	data.battleArmy	   =	loadFunc("data/battleArmy.tab")
	data.notice		   =	loadFunc("data/notice.tab")
	data.mansionTalk   =	loadFunc("data/MansionTalk.tab")
	data.personalEvent =	loadFunc("data/PersonalEvent.tab")
	data.eventRank 	   =	loadFunc("data/EventRank.tab")
	data.kingTitle 	   =	loadFunc("data/KingTitle.tab")
	data.cityPeople    =    loadFunc("data/cityPeople.tab")
	data.cityElement   =    loadFunc("data/CityElement.tab")
	data.playerBattleInfo   =    loadFunc("data/PlayerBattleInfo.tab")
	data.recharge     =    loadFunc("data/Recharge.tab")
	data.allienceEvent =    loadFunc("data/AllienceEvent.tab")
	data.unionActRank  =    loadFunc("data/A_EventRank.tab")
	data.resType       =    {{"gold", "钻石"}, {"silver", "白银"}, {"food", "粮草"}, 
							{"wood", "木材"}, {"rock", "石材"}, {"mine", "生铁"}, 
							{"exp", "武将经验"}, {"chip", "赌资"}, {"vip_exp", "VIP积分"}}
	data.daily         =    loadFunc("data/Daily.tab")
	data.daily_s       = 	loadFunc("data/Daily_S.tab")
	data.kingEvent     = 	loadFunc("data/KingEvent.tab")
	data.k_eventRank_a =	loadFunc("data/K_EventRank_A.tab")
	data.k_eventRank_e =	loadFunc("data/K_EventRank_E.tab")
	data.pushConfig	   =	loadFunc("data/pushConfig.tab")
	data.serverList    =    loadFunc("data/serverInfo/test_ServerList.tab")
	data.noviceGift	   =    loadFunc("data/Daily_X.tab")
	data.bossActivity  =    loadFunc("data/BossEvent.tab")
	data.newBoss	   =	loadFunc("data/NEWBOSS.tab")

	return data
end



function hp.gameDataLoader.getTable(table_)
	return game.data[table_]
end

function hp.gameDataLoader.getInfoBySid(table_, sid_)
	local tb = game.data[table_]
	if tb == nil then
		cclog(string.format("=========table:%s is nil", table_))
		return
	end

	for i,v in ipairs(tb) do
		if v.sid == sid_ then
			return v
		end
	end

	cclog(string.format("=========can not find sid:%s in table:%s", sid_, table_))
	return nil
end

function hp.gameDataLoader.getBuildingInfoByLevel(table_, level_, field_, default_)
	local tb = game.data[table_]
	if tb == nil then
		cclog(string.format("=========table:%s is nil", table_))
		return default_
	end

	if tb[level_] ~= nil then
		return tb[level_][field_]
	else
		cclog(string.format("=========can not find level_:%s in table:%s", level_, table_))
		return default_
	end
end

-- 多重条件查找 param_: {field_=value_, field_=value_, ...}
function hp.gameDataLoader.multiConditionSearch(table_, param_)
	local tb = game.data[table_]
	if tb == nil then
		cclog(string.format("=========table:%s is nil", table_))
		return
	end

	for i,v in ipairs(tb) do
		local result_ = true
		for j, w in pairs(param_) do
			if v[j] ~= w then
				result_ = false
				break
			end
		end

		if result_ == true then
			return v
		end
	end

	return nil
end

-- 获取道具
function hp.gameDataLoader.getItemByID(sid_)	
	local info_ = hp.gameDataLoader.getInfoBySid("gem", sid_)
	local table_ = "gem"

	if info_ == nil then
		info_ = hp.gameDataLoader.getInfoBySid("equipMaterial", sid_)		
		table_ = "material"				
	end

	if info_ == nil then
		info_ = hp.gameDataLoader.getInfoBySid("item", sid_)
		table_ = "item"
	end

	return info_, table_
end