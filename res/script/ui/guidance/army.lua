--
-- ui/guidance/army.lua
-- 军队页面
--===================================

require "ui/fullScreenFrame"
require "ui/common/effect"
require "ui/msgBox/msgBox"
require "ui/item/speedItem"

UI_Army = class("UI_Army", UI)

------------------------------------------------
-- priority: 1.可操作 2.加速 3.刷新 4.不可操作
------------------------------------------------

-- init
function UI_Army:init()

	self.itemTbl = {}

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "primeMinisterUi.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(11504), "title1")
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

	local hospitalItem = require("ui/guidance/armyItems/hospitalItem")
	hospitalItem.init(self, item, 4)
	table.insert(self.itemTbl, hospitalItem)
	self.hospitalItem = hospitalItem

	local marchItem = require("ui/guidance/armyItems/marchItem")
	marchItem.init(self, item, 10)
	table.insert(self.itemTbl, marchItem)
	self.marchItem = marchItem

	local trainsoldierItem = require("ui/guidance/armyItems/trainsoldierItem")
	trainsoldierItem.init(self, item, 12)
	table.insert(self.itemTbl, trainsoldierItem)
	self.trainsoldierItem = trainsoldierItem

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
	self:registMsg(hp.MSG.MARCH_MANAGER)
	self:registMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	self:registMsg(hp.MSG.PM_CHECK_CHANGE)
end

function UI_Army:onMsg(msg, parm)
	if msg == hp.MSG.CD_STARTED or msg == hp.MSG.CD_FINISHED then
		if parm.cdType == cdBox.CDTYPE.BRANCH then
			self.trainsoldierItem.setData()
			self.sort()
		elseif parm.cdType == cdBox.CDTYPE.REMEDY then
			self.hospitalItem.setData()
			self.sort()
		end
	elseif msg == hp.MSG.PM_CHECK_CHANGE then
		self.sort()
	else
		self.marchItem.setData()
		self.sort()
	end
end

function UI_Army:heartbeat(dt)
	for i,item in ipairs(self.itemTbl) do
		item.heartbeat(dt)
	end
end

function UI_Army:onRemove()
	for i,item in ipairs(self.itemTbl) do
		item.onRemove()
	end
	self.super.onRemove(self)
end