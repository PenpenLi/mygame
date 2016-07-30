--
-- ui/mainBuilding/mainBuildLevel2.lua
-- 主城详细信息
--===================================
require "ui/fullScreenFrame"

UI_mainBuildLevel2 = class("UI_mainBuildLevel2", UI)

local titleID = {5261, 5262, 5263, 5264, 5265, 5266}

--init
function UI_mainBuildLevel2:init(type_)
	-- data
	-- ===============================
	self.type = type_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(titleID[type_]))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)
	hp.uiHelper.uiAdaption(self.item3)
	hp.uiHelper.uiAdaption(self.item4)

	self:refreshShow()
end

function UI_mainBuildLevel2:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainBuildLevel2.json")

	self.listView = self.wigetRoot:getChildByName("ListView_2")
	self.item1 = self.listView:getChildByName("Panel_3"):clone()
	self.item1:retain()
	self.item2 = self.listView:getChildByName("Panel_5"):clone()
	self.item2:retain()
	self.item3 = self.listView:getChildByName("Panel_5_0"):clone()
	self.item3:retain()
	self.item4 = self.listView:getChildByName("Panel_5_1"):clone()
	self.item4:retain()
	self.listView:removeAllItems()
end

function UI_mainBuildLevel2:refreshArmyInfo()
	-- 概览
	local item_ = self.item1:clone()
	self.listView:pushBackCustomItem(item_)
	local content_ = item_:getChildByName("Panel_10")

	content_:getChildByName("Image_11"):loadTexture(config.dirUI.common.."attack_icon.png")

	local title_ = hp.lang.getStrByID(titleID[self.type])
	content_:getChildByName("Label_12"):setString(string.format(hp.lang.getStrByID(5248), title_))

	content_:getChildByName("Label_12_0"):setString(string.format(hp.lang.getStrByID(5249), title_))

	--  信息
	local index_ = 1
	local function addOneItem()
		local item_ = self.item2:clone()
		self.listView:pushBackCustomItem(item_)
		if index_%2 == 1 then
			item_:getChildByName("Panel_32_0"):getChildByName("ImageView_8347"):setVisible(false)
		end
		index_ = index_ + 1
		return item_:getChildByName("Panel_10")
	end	
	-- 总兵力
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5250))
	content_:getChildByName("Label_31_0"):setString(player.soldierManager.getTotalArmy():getSoldierTotalNumber())
	-- 总军队
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5251))
	content_:getChildByName("Label_31_0"):setString(player.helper.getTroopNum())
	-- 每支军队士兵数
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5252))
	content_:getChildByName("Label_31_0"):setString(player.helper.getNumPerTroop())
	-- 最大负载上限
	-- content_ = addOneItem()
	-- content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5253))
	-- content_:getChildByName("Label_31_0"):setString(player.helper.getMaxResourceLoaded())
	-- 日常粮草消耗
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5254))
	local label_ = content_:getChildByName("Label_31_0")
	label_:setColor(cc.c3b(255, 0, 0))
	local charge_ = player.soldierManager.getTotalArmy():getCharge()
	if charge_ > 0 then
		charge_ = -charge_
	end
	label_:setString(charge_)
	-- 陷阱数量
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5255))
	content_:getChildByName("Label_31_0"):setString(player.trapManager.getTrapNum())
	-- 陷阱上限
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5256))
	content_:getChildByName("Label_31_0"):setString(player.trapManager.getTrapUpLimit())
	-- 援军
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5257))
	content_:getChildByName("Label_31_0"):setString(player.getSupportNum())
	-- 伤兵
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5258))
	content_:getChildByName("Label_31_0"):setString(player.soldierManager.getHurtArmy():getSoldierTotalNumber())

	-- 标题
	local item_ = self.item3:clone()
	self.listView:pushBackCustomItem(item_)
	item_:getChildByName("Panel_10"):getChildByName("Label_37"):setString(hp.lang.getStrByID(5259))

	-- 兵种信息
	local function addOneItem2()
		local item_ = self.item4:clone()
		self.listView:pushBackCustomItem(item_)
		return item_
	end	

	content_ = addOneItem2():getChildByName("Panel_10")
	content_:getChildByName("Label_43"):setColor(cc.c3b(255,163,31))
	content_:getChildByName("Label_43"):setString(hp.lang.getStrByID(1040))
	content_:getChildByName("Label_43_0"):setColor(cc.c3b(255,163,31))
	content_:getChildByName("Label_43_0"):setString(hp.lang.getStrByID(5221))
	content_:getChildByName("Label_43_1"):setColor(cc.c3b(255,163,31))
	content_:getChildByName("Label_43_1"):setString(hp.lang.getStrByID(5260))

	local army_ = player.soldierManager.getTotalArmy()
	local index_ = 1
	for i = 1, globalData.TOTAL_LEVEL do
		local soldier_ = army_:getSoldierByType(i)
		local item_ = addOneItem2()
		local content_ = item_:getChildByName("Panel_10")
		if index_%2 == 1 then
			item_:getChildByName("Panel_39"):setVisible(true)
		end
		local info_ = soldier_:getSoldierInfo()
		content_:getChildByName("Label_43"):setString(info_.name)
		content_:getChildByName("Label_43_0"):setString(soldier_:getNumber())
		local label_ = content_:getChildByName("Label_43_1")
		label_:setColor(cc.c3b(255, 0, 0))
		local charge_ = soldier_:getCharge()
		if charge_ > 0 then
			charge_ = -charge_
		end
		label_:setString(charge_)
		index_ = index_ + 1
	end
end

function UI_mainBuildLevel2:refreshResource()
	local typeMap_ = {0,3,2,4,5,6}
	local sidMap_ = {0,1002,1017,1003,1005,1004}

	local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", typeMap_[self.type])

	-- 概览
	local item_ = self.item1:clone()
	self.listView:pushBackCustomItem(item_)
	local content_ = item_:getChildByName("Panel_10")

	content_:getChildByName("Image_11"):loadTexture(config.dirUI.common..resInfo_.imageBig)

	local title_ = hp.lang.getStrByID(titleID[self.type])
	content_:getChildByName("Label_12"):setString(string.format(hp.lang.getStrByID(5248), title_))

	content_:getChildByName("Label_12_0"):setString(string.format(hp.lang.getStrByID(5249), title_))

	--  信息
	local index_ = 1
	local function addOneItem()
		local item_ = self.item2:clone()
		self.listView:pushBackCustomItem(item_)
		if index_%2 == 1 then
			item_:getChildByName("Panel_32_0"):getChildByName("ImageView_8347"):setVisible(false)
		end
		index_ = index_ + 1
		return item_:getChildByName("Panel_10")
	end	
	-- 小时产量
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5267))
	content_:getChildByName("Label_31_0"):setString(player.helper.getResOutput(typeMap_[self.type]-1).. "/hr")
	-- 当前拥有
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5268))
	content_:getChildByName("Label_31_0"):setString(player.getResource(resInfo_.code))
	-- 容量上限
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5269))
	content_:getChildByName("Label_31_0"):setString(player.helper.getResCapacity(typeMap_[self.type]))
	if self.type == 2 then
		-- 小时消耗
		content_ = addOneItem()
		content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5270))
		local label_ = content_:getChildByName("Label_31_0")
		label_:setColor(cc.c3b(255, 0, 0))
		local charge_ = player.soldierManager.getTotalArmy():getCharge()
		if charge_ > 0 then
			charge_ = -charge_
		end
		label_:setString(charge_)
	end
	-- VIP资源奖励
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5271))
	content_:getChildByName("Label_31_0"):setString("+"..player.helper.getVIPAddRes(typeMap_[self.type]-1))
	-- 英雄资源奖励
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5272))
	content_:getChildByName("Label_31_0"):setString("+"..player.helper.getHeroAddRes(typeMap_[self.type]-1))
	-- 加成道具奖励
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5273))
	content_:getChildByName("Label_31_0"):setString("+"..player.helper.getItemBufAddRes(typeMap_[self.type]-1))
	-- 书院奖励
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5274))
	content_:getChildByName("Label_31_0"):setString("+"..player.helper.getResearchAddRes(typeMap_[self.type]-1))
	-- 总奖励
	content_ = addOneItem()
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(5275))
	content_:getChildByName("Label_31_0"):setString("+"..player.helper.getResOutput(typeMap_[self.type]-1, true))

	-- 标题
	local item_ = self.item3:clone()
	self.listView:pushBackCustomItem(item_)
	item_:getChildByName("Panel_10"):getChildByName("Label_37"):setString(string.format(hp.lang.getStrByID(5276), resInfo_.build))

	-- 信息
	local function addOneItem2()
		local item_ = self.item4:clone()
		self.listView:pushBackCustomItem(item_)
		return item_
	end	

	content_ = addOneItem2():getChildByName("Panel_10")
	content_:getChildByName("Label_43"):setColor(cc.c3b(255,163,31))
	content_:getChildByName("Label_43"):setString(hp.lang.getStrByID(1409))
	content_:getChildByName("Label_43_0"):setColor(cc.c3b(255,163,31))
	content_:getChildByName("Label_43_0"):setString(hp.lang.getStrByID(5277))
	content_:getChildByName("Label_43_1"):setColor(cc.c3b(255,163,31))
	content_:getChildByName("Label_43_1"):setString(hp.lang.getStrByID(5242))

	local builds_ = player.buildingMgr.getBuildingsBySid(sidMap_[self.type])
	local index_ = 1
	for i, v in ipairs(builds_) do
		local item_ = addOneItem2()
		local content_ = item_:getChildByName("Panel_10")
		if index_%2 == 1 then
			item_:getChildByName("Panel_39"):setVisible(true)
		end
		content_:getChildByName("Label_43"):setString(resInfo_.build)
		local num_ = 0
		if v.sid == 1017 then
			num_ = hp.gameDataLoader.multiConditionSearch("villa", {level=v.lv}).resCount
		else
			num_ = hp.gameDataLoader.multiConditionSearch("res", {buildsid=v.sid,level=v.lv}).resCount
		end
		content_:getChildByName("Label_43_0"):setString(num_.."/hr")
		content_:getChildByName("Label_43_1"):setString(v.lv)
		index_ = index_ + 1
	end
end

function UI_mainBuildLevel2:refreshShow()
	if self.type == 1 then
		self:refreshArmyInfo()
	else
		self:refreshResource()
	end	
end

function UI_mainBuildLevel2:initCallBack()
end

function UI_mainBuildLevel2:onMsg(msg_, param_)
end

function UI_mainBuildLevel2:onRemove()
	self.item1:release()
	self.item2:release()
	self.item3:release()
	self.item4:release()
	self.super.onRemove(self)
end