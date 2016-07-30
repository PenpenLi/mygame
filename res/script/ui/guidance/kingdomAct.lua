--
-- ui/guidance/kingdomAct.lua
-- 国王活动页面
--===================================

require "ui/fullScreenFrame"
require "ui/common/effect"
require "ui/msgBox/msgBox"
require "ui/item/speedItem"

UI_KingdomAct = class("UI_KingdomAct", UI)

------------------------------------------------
-- priority: 1.可操作 2.加速 3.刷新 4.不可操作
------------------------------------------------

-- init
function UI_KingdomAct:init()

	self.itemTbl = {}

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "primeMinisterUi.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(11507), "title1")
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

	local kingactItem = require("ui/guidance/kingdomItems/kingactItem")
	kingactItem.init(self, item, 2)
	table.insert(self.itemTbl, kingactItem)
	self.kingactItem = kingactItem

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

		listview:removeItem(1)

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

	self:registMsg(hp.MSG.KING_BATTLE)
end

function UI_KingdomAct:onMsg(msg, parm)
	self.kingactItem.setData()
end

function UI_KingdomAct:heartbeat(dt)
	for i,item in ipairs(self.itemTbl) do
		item.heartbeat(dt)
	end
end

function UI_KingdomAct:onRemove()
	for i,item in ipairs(self.itemTbl) do
		item.onRemove()
	end
	self.super.onRemove(self)
end