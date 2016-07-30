--
-- ui/goldShop/goldShop.lua
-- 商城
--===================================
require "ui/fullScreenFrame"

UI_goldShop = class("UI_goldShop", UI)

--init
function UI_goldShop:init(tab_)
	-- data
	-- ===============================
	self.tab = 1
	if tab_ ~= nil then
		self.tab = tab_
	end

	-- ui data
	self.uiTab = {}
	self.uiTabText = {}
	self.uiTickTime = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(824)
	uiFrame:setTitle(hp.lang.getStrByID(5495), "title1")
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)

	self.sizeSelected = self.uiTab[1]:getScale()
	self.sizeUnselected = self.uiTab[2]:getScale()
	self.colorSelected = self.uiTab[1]:getColor()
	self.colorUnselected = self.uiTab[2]:getColor()

	self:registMsg(hp.MSG.GOLD_SHOP)

	self:tabPage(self.tab)
end

function UI_goldShop:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "diamondShop.json")
	local content_ = self.wigetRoot:getChildByName("Panel_5")
	local idList_ = {5477, 5478, 5479}
	for i = 1, 3 do
		self.uiTab[i] = content_:getChildByName("tab_"..i)
		self.uiTab[i]:setTag(i)
		self.uiTab[i]:addTouchEventListener(self.onTabTouched)
		self.uiTabText[i] = self.uiTab[i]:getChildByName("Label_1")
		self.uiTabText[i]:setString(hp.lang.getStrByID(idList_[i]))
	end

	self.listView = self.wigetRoot:getChildByName("ListView_29885")
	self.item1 = self.listView:getChildByName("Panel_87"):clone()
	self.item1:retain()
	self.item2 = self.listView:getChildByName("Panel_87_0"):clone()
	self.item2:retain()
	self.listView:removeAllItems()
end

function UI_goldShop:tabPage(id_)
	local scale_ = {self.sizeUnselected, self.sizeUnselected, self.sizeUnselected}	
	local color_ = {self.colorUnselected, self.colorUnselected, self.colorUnselected}
	scale_[id_] = self.sizeSelected
	color_[id_] = self.colorSelected

	for i = 1, 3 do
		self.uiTab[i]:setColor(color_[i])
		self.uiTab[i]:setScale(scale_[i])
		self.uiTabText[i]:setColor(color_[i])
	end

	self.tab = id_
	self.uiLoadingBar = {}
	self:refreshShow()
end

function UI_goldShop:refreshShow()
	self.listView:jumpToTop()
	if self.tab == 1 then		
		self:refreshPage1()
	elseif self.tab == 2 then
		self:refreshPage2()
	elseif self.tab == 3 then
		self:refreshPage3()
	end
	self:tickUpdate()
end

function UI_goldShop:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/goldShop/goldItemDetail"
			local ui_ = UI_goldItemDetail.new(sender:getTag())
			self:addModalUI(ui_)
		end
	end

	-- 充值钻石
	local function onChargeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			cclog_("charge", sender:getTag())
			player.goldShopMgr.buyItem(sender:getTag())
		end
	end

	-- 切换标签
	local function onTabTouched(sender, eventType)
		if self.tab == sender:getTag() then
			return
		end
		
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
	self.onChargeTouched = onChargeTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_goldShop:onRemove()
	self.item1:release()
	self.item2:release()
	self.super.onRemove(self)
end

function UI_goldShop:refreshPage1()
	self.listView:removeAllItems()
	self.uiTickTime = {}
	local index_ = 1

	local function addOneItem(v)
		local item_ = self.item1:clone()
		self.listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_89")
		-- 背景
		item_:getChildByName("Panel_88"):getChildByName("Image_90"):loadTexture(config.dirUI.common..v.info.bg_pic)
		-- 图标
		content_:getChildByName("Image_91"):loadTexture(config.dirUI.common..v.info.icon_pic)
		-- 花费
		content_:getChildByName("Image_92"):getChildByName("Label_93"):setString(v.info.money)
		-- 名称
		content_:getChildByName("Label_95"):setString(v.info.name)
		-- 描述
		content_:getChildByName("Label_96"):setString(v.info.desc)
		-- 详细信息
		local moreInfo_ = content_:getChildByName("Image_97")
		moreInfo_:getChildByName("Label_98"):setString(hp.lang.getStrByID(5481))
		moreInfo_:setTag(v.info.sid)
		moreInfo_:addTouchEventListener(self.onMoreInfoTouched)
		-- 充值
		local charge_ = content_:getChildByName("Image_97_0")
		charge_:getChildByName("Label_98"):setString(hp.lang.getStrByID(5480))
		charge_:setTag(v.info.sid)
		charge_:addTouchEventListener(self.onChargeTouched)
		self.uiTickTime[index_] = charge_:getChildByName("Image_103"):getChildByName("Label_105")
		-- 不可以购买
		if v.valid ~= 0 then
			charge_:setTouchEnabled(false)
			charge_:loadTexture(config.dirUI.common.."button_gray.png")
		end
		index_ = index_ + 1
	end

	-- 一次性和限时礼包
	local info_ = player.goldShopMgr.getShopItem()[1]
	for i, v in ipairs(info_) do
		addOneItem(v)
	end
end

function UI_goldShop:refreshPage2()
	self.listView:removeAllItems()
	self.uiTickTime = {}

	local info_ = player.goldShopMgr.getShopItem()[2]
	for i, v in ipairs(info_) do
		local item_ = self.item1:clone()
		self.listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_89")
		-- 背景
		item_:getChildByName("Panel_88"):getChildByName("Image_90"):loadTexture(config.dirUI.common..v.info.bg_pic)
		-- 图标
		content_:getChildByName("Image_91"):loadTexture(config.dirUI.common..v.info.icon_pic)
		-- 花费
		content_:getChildByName("Image_92"):getChildByName("Label_93"):setString(v.info.money)
		-- 名称
		content_:getChildByName("Label_95"):setString(v.info.name)
		-- 描述
		content_:getChildByName("Label_96"):setString(v.info.desc)
		-- 详细信息
		local moreInfo_ = content_:getChildByName("Image_97")
		moreInfo_:getChildByName("Label_98"):setString(hp.lang.getStrByID(5481))
		moreInfo_:setTag(v.info.sid)
		moreInfo_:addTouchEventListener(self.onMoreInfoTouched)
		-- 充值
		local charge_ = content_:getChildByName("Image_97_0")
		charge_:getChildByName("Label_98"):setString(hp.lang.getStrByID(5480))
		charge_:setTag(v.info.sid)
		charge_:addTouchEventListener(self.onChargeTouched)
		self.uiTickTime[i] = charge_:getChildByName("Image_103"):getChildByName("Label_105")
		-- 不可以购买
		if v.valid ~= 0 then
			charge_:setTouchEnabled(false)
			charge_:loadTexture(config.dirUI.common.."button_gray.png")
		end
	end
end

function UI_goldShop:refreshPage3()
	self.listView:removeAllItems()
	self.uiTickTime = {}

	local info_ = player.goldShopMgr.getShopItem()[3]
	for i, v in ipairs(info_) do
		cclog_(i)
		local item_ = self.item2:clone()
		self.listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_89")
		-- 花费
		content_:getChildByName("Image_92"):getChildByName("Label_93"):setString(v.info.money)
		-- 名称
		content_:getChildByName("Label_95"):setString(v.info.name)
		-- 描述
		content_:getChildByName("Label_96"):setString(v.info.desc)
		-- 充值
		local charge_ = content_:getChildByName("Image_97_0")
		charge_:getChildByName("Label_98"):setString(hp.lang.getStrByID(5480))
		charge_:setTag(v.info.sid)
		charge_:addTouchEventListener(self.onChargeTouched)
	end
end

function UI_goldShop:tickUpdate()
	local shopItem_ = player.goldShopMgr.getShopItem()
	local items_ = shopItem_[self.tab]
	for i, v in ipairs(self.uiTickTime) do
		-- 无限时间		
		if items_[i].endTime == -1 then
			v:setString(hp.lang.getStrByID(5511))
		else
			local dt_ = items_[i].endTime - player.getServerTime()
			if dt_ < 0 then
				dt_ = 0
			end
			v:setString(hp.datetime.strTime(dt_))
		end
	end
end

function UI_goldShop:heartbeat(dt_)
	self:tickUpdate()
end

function UI_goldShop:onMsg(msg_, param_)
	if msg_ == hp.MSG.GOLD_SHOP then
		if param_.msgType == 1 then
			self:refreshShow()
		end
	end
end