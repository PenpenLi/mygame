--
-- ui/mansion/giftItem/onlineGiftItem.lua
-- 在线礼包
--===================================

-- 类
--===================================
OnlineGiftItem = class("OnlineGiftItem")

-- 初始化
function OnlineGiftItem:ctor(item_, parent_)
	self.item = item_
	self.parent = parent_
	self:initTouchEvent()
	self:initUI()
end

-- 初始化事件
function OnlineGiftItem:initTouchEvent()
	-- 领取
	local function getOnlineGift(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/cityMap/onlineGift.lua"
			local ui_ = UI_onlineGift.new()
			self.parent:addModalUI(ui_)			
		end
	end
	self.getOnlineGift = getOnlineGift
end

-- 初始化界面
function OnlineGiftItem:initUI()
	local panelitem1 = self.item:getChildByName("Panel_content")
	panelitem1:getChildByName("Label_title"):setString(hp.lang.getStrByID(8124))
	panelitem1:getChildByName("Label_timeTitle"):setString(hp.lang.getStrByID(8125))
	panelitem1:getChildByName("Image_getBtn"):getChildByName("Label_info"):setString(hp.lang.getStrByID(8123))
	self.panelitem1 = panelitem1

	self.boxLabelTime = panelitem1:getChildByName("Label_time")
	self.boxBtnGet = panelitem1:getChildByName("Image_getBtn")

	local cd = player.onlineGift.getCD()
	
	if cd > 0 then
		self.priority = 2
		self.boxBtnGet:loadTexture(config.dirUI.common .. "button_gray1.png")
		self.boxBtnGet:setTouchEnabled(false)
		self.boxLabelTime:setColor(cc.c3b(244, 66, 69))
		self.boxLabelTime:setString(hp.datetime.strTime(cd))
	else
		self.priority = 1
		self.boxBtnGet:loadTexture(config.dirUI.common .. "button_blue1.png")
		self.boxBtnGet:setTouchEnabled(true)
		self.boxLabelTime:setColor(cc.c3b(60, 223, 16))
		self.boxLabelTime:setString(hp.lang.getStrByID(8128))
	end
	self.boxBtnGet:addTouchEventListener(self.getOnlineGift)
	self.isFirst = false
	self:heartbeat(0)
end

-- 心跳
function OnlineGiftItem:heartbeat(dt)

	if player.onlineGift.getItemSid() == 0 then
		self.panelitem1:setVisible(false)
		self.item:getChildByName("Panel_content2"):getChildByName("Label_title"):setString(hp.lang.getStrByID(8126))
		self.boxLabelTime:setColor(cc.c3b(29, 232, 10))
		return
	end

	local cd = player.onlineGift.getCD()
	
	if cd > 0 then
		if self.isFirst then
			self.boxBtnGet:loadTexture(config.dirUI.common .. "button_gray1.png")
			self.boxBtnGet:setTouchEnabled(false)
			self.boxLabelTime:setColor(cc.c3b(244, 66, 69))
			self.isFirst = false
		end
		self.boxLabelTime:setString(hp.datetime.strTime(cd))
	elseif cd == 0 and not self.isFirst then
		self.boxBtnGet:loadTexture(config.dirUI.common .. "button_blue1.png")
		self.boxBtnGet:setTouchEnabled(true)
		self.boxLabelTime:setColor(cc.c3b(60, 223, 16))
		self.boxLabelTime:setString(hp.lang.getStrByID(8128))
		self.isFirst = true
	end	
end