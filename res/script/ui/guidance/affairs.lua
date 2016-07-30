--
-- ui/guidance/affairs.lua
-- 内政页面
--===================================

require "ui/fullScreenFrame"
require "ui/common/effect"
require "ui/msgBox/msgBox"
require "ui/item/speedItem"

UI_Affairs = class("UI_Affairs", UI)

------------------------------------------------
-- priority: 1.可操作 2.加速 3.刷新 4.不可操作
------------------------------------------------

-- init
function UI_Affairs:init()

	self.itemTbl = {}

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "primeMinisterUi.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(11503), "title1")
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

	local researchItem = require("ui/guidance/affairsItems/researchItem")
	researchItem.init(self, item, 9)
	table.insert(self.itemTbl, researchItem)
	self.researchItem = researchItem

	local builderItem = require("ui/guidance/affairsItems/builderItem")
	builderItem.init(self, item, 11)
	table.insert(self.itemTbl, builderItem)
	self.builderItem = builderItem

	local maketrapItem = require("ui/guidance/affairsItems/maketrapItem")
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
	self:registMsg(hp.MSG.PM_CHECK_CHANGE)

	-- 和新手指引界面绑定
	-- ======================
	local function bindGuideUI(step)
		if step==20071 or step==40052 then --指向建造
			listview:visit()
			local function onBuild( sender, eventType )
				hp.uiHelper.btnImgTouched(sender, eventType)
				if eventType==TOUCH_EVENT_ENDED then
					self:closeAll()
					player.guide.stepEx({20071, 40052})
				end
			end
			player.guide.bind2Node(step, builderItem.getItemBtn(), onBuild)
		end
	end
	self.bindGuideUI = bindGuideUI
	self:registMsg(hp.MSG.GUIDE_STEP)
end

function UI_Affairs:onMsg(msg, parm)
	if msg == hp.MSG.PM_CHECK_CHANGE then
		self.sort()
	elseif msg==hp.MSG.GUIDE_STEP then
	-- 新手指引
		self.bindGuideUI(parm)
	else
		if parm.cdType == cdBox.CDTYPE.BUILD then
			self.builderItem.setData()
			self.sort()
		elseif parm.cdType == cdBox.CDTYPE.RESEARCH then
			self.researchItem.setData()
			self.sort()
		elseif parm.cdType == cdBox.CDTYPE.TRAP then
			self.maketrapItem.setData()
			self.sort()
		end
	end
end

function UI_Affairs:heartbeat(dt)
	for i,item in ipairs(self.itemTbl) do
		item.heartbeat(dt)
	end
end

function UI_Affairs:onRemove()
	for i,item in ipairs(self.itemTbl) do
		item.onRemove()
	end
	self.super.onRemove(self)
end