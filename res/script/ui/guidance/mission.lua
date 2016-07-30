--
-- ui/guidance/mission.lua
-- 任务页面
--===================================

require "ui/fullScreenFrame"
require "ui/common/effect"
require "ui/msgBox/msgBox"
require "ui/item/speedItem"

UI_Mission = class("UI_Mission", UI)

------------------------------------------------
-- priority: 1.可操作 2.加速 3.刷新 4.不可操作
------------------------------------------------

-- init
function UI_Mission:init()

	self.itemTbl = {}

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "primeMinisterUi.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(11505), "title1")
	uiFrame:setTopShadePosY(888)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	local listview = wigetRoot:getChildByName("ListView_content")
	listview:setClippingType(1)
	listview:getItem(0):getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(8178))
	local item = listview:getItem(1):clone()
	listview:removeItem(1)

	local localforceItem = require("ui/guidance/missionItems/localforceItem")
	localforceItem.init(self, item, 5)
	table.insert(self.itemTbl, localforceItem)
	self.localforceItem = localforceItem

	local unionforceItem = require("ui/guidance/missionItems/unionforceItem")
	unionforceItem.init(self, item, 6)
	table.insert(self.itemTbl, unionforceItem)
	self.unionforceItem = unionforceItem

	local vipforceItem = require("ui/guidance/missionItems/vipforceItem")
	vipforceItem.init(self, item, 7)
	table.insert(self.itemTbl, vipforceItem)
	self.vipforceItem = vipforceItem

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

	-- 排序
	local function sort()
		removeBtnLight()

		for i = 1, 3 do
			listview:removeItem(1)
		end

		local checkTbl = player.checkedPMTbl.getCheckedTbl()
		for isCheck = 0, 1 do
			for priority = 1, 4 do
				for i,item in ipairs(self.itemTbl) do
					if isCheck == checkTbl[item.getCheckIndex()] and item.getPriority() == priority then
						listview:pushBackCustomItem(item.getItem())
						item.setData()
					end
				end
			end
		end

		btnLight()
	end
	sort()
	self.sort = sort

	self:registMsg(hp.MSG.CD_STARTED)
	self:registMsg(hp.MSG.CD_FINISHED)
	self:registMsg(hp.MSG.MISSION_DAILY_COLLECTED)
	self:registMsg(hp.MSG.MISSION_DAILY_REFRESH)
	self:registMsg(hp.MSG.MISSION_DAILY_QUICKFINISH)
	self:registMsg(hp.MSG.PM_CHECK_CHANGE)
end

function UI_Mission:onMsg(msg, parm)
	if msg == hp.MSG.CD_STARTED or msg == hp.MSG.CD_FINISHED then
		if parm.cdType == cdBox.CDTYPE.VIP or parm.cdType == cdBox.CDTYPE.VIPTASK then
			self.vipforceItem.setData()
		elseif parm.cdType == cdBox.CDTYPE.DAILYTASK then
			self.localforceItem.setData()
		elseif parm.cdType == cdBox.CDTYPE.LEAGUETASK then
			self.unionforceItem.setData()
		end
		self.sort()
	elseif msg == hp.MSG.MISSION_DAILY_REFRESH or msg == hp.MSG.MISSION_DAILY_COLLECTED or msg == hp.MSG.MISSION_DAILY_QUICKFINISH then
		if parm == 1 then
			self.localforceItem.setData()
		elseif parm == 2 then
			self.unionforceItem.setData()
		elseif parm == 3 then
			self.vipforceItem.setData()
		end
		self.sort()
	else
		self.sort()
	end
end

function UI_Mission:heartbeat(dt)
	for i,item in ipairs(self.itemTbl) do
		item.heartbeat(dt)
	end
end

function UI_Mission:onRemove()
	for i,item in ipairs(self.itemTbl) do
		item.onRemove()
	end
	self.super.onRemove(self)
end