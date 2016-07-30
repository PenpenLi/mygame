--
-- ui/guidance/energy.lua
-- 体力页面
--===================================

require "ui/fullScreenFrame"
require "ui/common/effect"
require "ui/msgBox/msgBox"
require "ui/item/speedItem"

UI_Energy = class("UI_Energy", UI)

------------------------------------------------
-- priority: 1.可操作 2.加速 3.刷新 4.不可操作
------------------------------------------------

-- init
function UI_Energy:init()

	self.itemTbl = {}

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "primeMinisterUi.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(11506), "title1")
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

	local battleItem = require("ui/guidance/energyItems/battleItem")
	battleItem.init(self, item, 8)
	table.insert(self.itemTbl, battleItem)
	self.battleItem = battleItem

	local bossItem = require("ui/guidance/energyItems/bossItem")
	bossItem.init(self, item, 14)
	table.insert(self.itemTbl, bossItem)
	self.bossItem = bossItem

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

	self:registMsg(hp.MSG.COPY_NOTIFY)
	self:registMsg(hp.MSG.PM_CHECK_CHANGE)
end

function UI_Energy:onMsg(msg, parm)
	self.sort()
end

function UI_Energy:heartbeat(dt)
	for i,item in ipairs(self.itemTbl) do
		item.heartbeat(dt)
	end
end

function UI_Energy:onRemove()
	for i,item in ipairs(self.itemTbl) do
		item.onRemove()
	end
	self.super.onRemove(self)
end