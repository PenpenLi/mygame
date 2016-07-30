--
-- ui/mansion/primeminister.lua
-- 丞相页面
--===================================

require "ui/fullScreenFrame"
require "ui/common/effect"
require "ui/msgBox/msgBox"
require "ui/item/speedItem"

UI_PrimeMinister = class("UI_PrimeMinister", UI)

------------------------------------------------
-- priority: 1.可操作 2.加速 3.刷新 4.不可操作
------------------------------------------------

-- init
function UI_PrimeMinister:init()

	self.itemTbl = {}

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "primeMinisterUi.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(8131))
	uiFrame:setTopShadePosY(888)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	-- 顺序:名将拍卖，国王活动，联盟帮助，医馆，城卫军，联盟军，禁卫军，体力，研究，行军，建筑，训练士兵，制造陷阱

	local listview = wigetRoot:getChildByName("ListView_content")
	listview:setClippingType(1)
	listview:getItem(0):getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(8178))
	local item = listview:getItem(1):clone()
	listview:removeItem(1)

	local heroItem = require("ui/mansion/pmItem/heroItem")
	heroItem.init(self, item, 1)
	table.insert(self.itemTbl, heroItem)
	self.heroItem = heroItem
	
	local kingactItem = require("ui/mansion/pmItem/kingactItem")
	kingactItem.init(self, item, 2)
	table.insert(self.itemTbl, kingactItem)
	self.kingactItem = kingactItem
	
	-- 获取府邸等级
	local mansionLevel = player.buildingMgr.getBuildingMaxLvBySid(1001)
	if mansionLevel < 8 then
		local king = kingactItem.getItem()
		king:setVisible(false)
		local size = king:getSize()
		size.height = 0
		king:setSize(size)
	end

	local unionhelpItem = require("ui/mansion/pmItem/unionhelpItem")
	unionhelpItem.init(self, item, 3)
	table.insert(self.itemTbl, unionhelpItem)
	self.unionhelpItem = unionhelpItem

	local hospitalItem = require("ui/mansion/pmItem/hospitalItem")
	hospitalItem.init(self, item, 4)
	table.insert(self.itemTbl, hospitalItem)
	self.hospitalItem = hospitalItem

	local localforceItem = require("ui/mansion/pmItem/localforceItem")
	localforceItem.init(self, item, 5)
	table.insert(self.itemTbl, localforceItem)
	self.localforceItem = localforceItem

	local unionforceItem = require("ui/mansion/pmItem/unionforceItem")
	unionforceItem.init(self, item, 6)
	table.insert(self.itemTbl, unionforceItem)
	self.unionforceItem = unionforceItem

	local vipforceItem = require("ui/mansion/pmItem/vipforceItem")
	vipforceItem.init(self, item, 7)
	table.insert(self.itemTbl, vipforceItem)
	self.vipforceItem = vipforceItem

	local battleItem = require("ui/mansion/pmItem/battleItem")
	battleItem.init(self, item, 8)
	table.insert(self.itemTbl, battleItem)
	self.battleItem = battleItem

	local researchItem = require("ui/mansion/pmItem/researchItem")
	researchItem.init(self, item, 9)
	table.insert(self.itemTbl, researchItem)
	self.researchItem = researchItem

	local marchItem = require("ui/mansion/pmItem/marchItem")
	marchItem.init(self, item, 10)
	table.insert(self.itemTbl, marchItem)
	self.marchItem = marchItem

	local builderItem = require("ui/mansion/pmItem/builderItem")
	builderItem.init(self, item, 11)
	table.insert(self.itemTbl, builderItem)
	self.builderItem = builderItem

	local trainsoldierItem = require("ui/mansion/pmItem/trainsoldierItem")
	trainsoldierItem.init(self, item, 12)
	table.insert(self.itemTbl, trainsoldierItem)
	self.trainsoldierItem = trainsoldierItem

	local maketrapItem = require("ui/mansion/pmItem/maketrapItem")
	maketrapItem.init(self, item, 13)
	table.insert(self.itemTbl, maketrapItem)
	self.maketrapItem = maketrapItem

	-- 按钮发光
	local function btnLight()
		item_ = listview:getItem(1)
		for i,item in ipairs(self.itemTbl) do
			if item_ == item.getItem() and item.getPriority ~= 4 then
				item.setBtnLight()
			end 
		end
	end

	-- 按钮不发光
	local function removeBtnLight()
		item_ = listview:getItem(1)
		for i,item in ipairs(self.itemTbl) do
			if item_ == item.getItem() then
				item.removeBtnLight()
			end 
		end
	end

	-- 插入
	local function insert(item_)
		if item_ == nil then
			return
		end
		removeBtnLight()
		-- 更新数据
		item_.setData()
		local oldIndex = listview:getIndex(item_.getItem())
		local newIndex = 1
		local checkTbl = player.checkedPMTbl.getCheckedTbl()
		for isCheck = 0, 1 do
			for priority = 1, 4 do
				for i,item in ipairs(self.itemTbl) do
					if isCheck == checkTbl[i] and item.getPriority() == priority then
						if item == item_ then
							if newIndex ~= oldIndex then
								-- 移除
								listview:removeItem(oldIndex)
								-- 插入
								listview:insertCustomItem(item_.getItem(), newIndex)
							end
							btnLight()
							return
						end
						newIndex = newIndex + 1
					end
				end
			end
		end
	end
	self.insert = insert

	-- 排序（仅第一次时使用）
	local function sort()
		local checkTbl = player.checkedPMTbl.getCheckedTbl()
		for isCheck = 0, 1 do
			for priority = 1, 4 do
				for i,item in ipairs(self.itemTbl) do
					if isCheck == checkTbl[i] and item.getPriority() == priority then
						listview:pushBackCustomItem(item:getItem())
					end
				end
			end
		end
		btnLight()
	end
	sort()

	self:registMsg(hp.MSG.CD_STARTED)
	self:registMsg(hp.MSG.CD_FINISHED)
	self:registMsg(hp.MSG.MISSION_DAILY_COLLECTED)
	self:registMsg(hp.MSG.MISSION_DAILY_REFRESH)
	self:registMsg(hp.MSG.UNION_DATA_PREPARED)
	self:registMsg(hp.MSG.PM_CHECK_CHANGE)
	self:registMsg(hp.MSG.MARCH_MANAGER)
	self:registMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	self:registMsg(hp.MSG.KING_BATTLE)
	self:registMsg(hp.MSG.COPY_NOTIFY)
	self:registMsg(hp.MSG.UNION_HELP_INFO_CHANGE)
	self:registMsg(hp.MSG.HOSPITAL_HEAL_FINISH)
	self:registMsg(hp.MSG.FAMOUS_HERO_NUM_CHANGE)
	self:registMsg(hp.MSG.MISSION_DAILY_QUICKFINISH)

	-- 进行新手引导绑定
	-- =========================================
	self:registMsg(hp.MSG.GUIDE_STEP)
	local function bindGuideUI( step )
		if step==2007 or step==4005  then
			local function builderTouched(sender, touchType_)
				if touchType_==TOUCH_EVENT_ENDED then
					self:closeAll()
					player.guide.stepEx({2007, 4005})
				end
			end
			listview:jumpToBottom()
			listview:visit()
			player.guide.bind2Node(step, builderItem.getItemBtn(), builderTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
end

function UI_PrimeMinister:onMsg(msg, parm)
	if msg==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(parm)
		return
	end
	cclog_("PrimeMinister got Msg", msg, parm)
	local item
	if msg == hp.MSG.CD_STARTED or msg == hp.MSG.CD_FINISHED then
		if parm.cdType == cdBox.CDTYPE.BUILD then
			item = self.builderItem
		elseif parm.cdType == cdBox.CDTYPE.RESEARCH then
			item = self.researchItem
		elseif parm.cdType == cdBox.CDTYPE.BRANCH then
			item = self.trainsoldierItem
		elseif parm.cdType == cdBox.CDTYPE.TRAP then
			item = self.maketrapItem
		elseif parm.cdType == cdBox.CDTYPE.VIP or parm.cdType == cdBox.CDTYPE.VIPTASK then
			item = self.vipforceItem
		elseif parm.cdType == cdBox.CDTYPE.DAILYTASK then
			item = self.localforceItem
		elseif parm.cdType == cdBox.CDTYPE.LEAGUETASK then
			item = self.unionforceItem
		elseif parm.cdType == cdBox.CDTYPE.REMEDY then
			item = self.hospitalItem
		end
	elseif msg == hp.MSG.MISSION_DAILY_REFRESH or msg == hp.MSG.MISSION_DAILY_COLLECTED or msg == hp.MSG.MISSION_DAILY_QUICKFINISH then
		if parm == 1 then
			item = self.localforceItem
		elseif parm == 2 then
			item = self.unionforceItem
		elseif parm == 3 then
			item = self.vipforceItem
		end
	elseif msg == hp.MSG.PM_CHECK_CHANGE then
		item = self.itemTbl[parm]
	elseif msg == hp.MSG.MARCH_MANAGER or msg == hp.MSG.MARCH_ARMY_NUM_CHANGE then
		item = self.marchItem
	elseif msg == hp.MSG.UNION_DATA_PREPARED or msg == hp.MSG.UNION_HELP_INFO_CHANG then
		item = self.unionhelpItem
	elseif msg == hp.MSG.KING_BATTLE then
		item = self.kingactItem
	elseif msg == hp.MSG.COPY_NOTIFY then
		item = self.battleItem
	elseif msg == hp.MSG.HOSPITAL_HEAL_FINISH then
		item = self.hospitalItem
	elseif msg == hp.MSG.FAMOUS_HERO_NUM_CHANGE then
		item = self.heroItem
	end
	self.insert(item)
end

function UI_PrimeMinister:heartbeat(dt)
	for i,item in ipairs(self.itemTbl) do
		item.heartbeat(dt)
	end
end

function UI_PrimeMinister:onRemove()
	for i,item in ipairs(self.itemTbl) do
		item.onRemove()
	end
	self.super.onRemove(self)
end