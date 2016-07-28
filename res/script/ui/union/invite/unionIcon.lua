--
-- ui/union/unionIcon.lua
-- 工会图标选择
--===================================
require "ui/fullScreenFrame"

UI_unionIcon = class("UI_unionIcon", UI)

local totalIcon_ = 11

--init
function UI_unionIcon:init()
	-- data
	-- ===============================
	self.defaultChoose = 1

	-- ui data
	self.chozenImg = nil

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(1800))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.horContainer)

	self:initShow()
end

function UI_unionIcon:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "iconChoose.json")
	self.listView = self.wigetRoot:getChildByName("ListView_29976")
	local content_ = self.wigetRoot:getChildByName("Panel_29972")

	-- 描述
	content_:getChildByName("Label_29973"):setString(hp.lang.getStrByID(1802))

	-- 确认按钮
	local confirm_ = content_:getChildByName("ImageView_29974")
	confirm_:getChildByName("Label_29975"):setString(hp.lang.getStrByID(1506))
	confirm_:addTouchEventListener(self.onConfirmTouched)

	self.horContainer = self.listView:getChildByName("Panel_29977"):clone()
	self.horContainer:retain()
	self.listView:removeLastItem()
end

function UI_unionIcon:initCallBack()
	local function onIconTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender == self.chozenImg then
				return
			end
			sender:getChildByName("ImageView_29980"):setVisible(true)
			self.chozenImg:getChildByName("ImageView_29980"):setVisible(false)
			self.chozenImg = sender
		end
	end

	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			hp.msgCenter.sendMsg(hp.MSG.UNION_CHOOSE_ICON, self.chozenImg:getTag())
			self:close()
		end
	end

	self.onIconTouched = onIconTouched
	self.onConfirmTouched = onConfirmTouched
end

function UI_unionIcon:initShow()
	local container = self.horContainer:clone()
	local content_ = container:getChildByName("Panel_30029")
	self.listView:pushBackCustomItem(container)	
	local index = 1
	for i = 1, totalIcon_ do
		local icon_ = content_:getChildByName(string.format("ImageView_%d", index))

		-- set image
		icon_:getChildByName("ImageView_29979"):loadTexture(string.format("%s%d.png", config.dirUI.icon, i))

		-- set clickEvent
		icon_:addTouchEventListener(self.onIconTouched)

		-- set tag
		icon_:setTag(i)

		if index == 4 then
			container = self.horContainer:clone()
			self.listView:pushBackCustomItem(container)	
			content_ = container:getChildByName("Panel_30029")		
			index = 1
		else
			index = index + 1
		end

		if i == 1 then
			icon_:getChildByName("ImageView_29980"):setVisible(true)
			self.chozenImg = icon_
		end
	end

	-- hide redundant ui
	for i = index, 4 do
		content_:getChildByName(string.format("ImageView_%d", i)):setVisible(false)
	end
end

function UI_unionIcon:close()
	self.horContainer:release()
	self.super.close(self)
end