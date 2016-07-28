--
-- ui/union/changeColor.lua
-- 公会战
--===================================
require "ui/fullScreenFrame"

UI_changeColor = class("UI_changeColor", UI)

--init
function UI_changeColor:init(tab_)
	-- data
	-- ===============================

	-- ui data

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5141))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_changeColor:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "changeColor.json")
end

function UI_changeColor:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
		end
	end

	-- 切换标签
	local function onTabTouched(sender, eventType)
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorSelected)
			self.uiTabText[sender:getTag()]:setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorSelected)
				self.uiTabText[sender:getTag()]:setColor(self.colorSelected)
			else
				sender:setColor(self.colorUnselected)
				self.uiTabText[sender:getTag()]:setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			self:tabPage(sender:getTag())
		end
	end

	self.onTabTouched = onTabTouched
	self.onJoinDefenseTouched = onJoinDefenseTouched
	self.onJoinAttackTouched = onJoinAttackTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_changeColor:close()
	self.super.close(self)
end