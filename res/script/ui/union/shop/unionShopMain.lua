--
-- ui/union/shop/unionShopMain.lua
-- 公会商店主界面
--===================================
require "ui/fullScreenFrame"

UI_unionShopMain = class("UI_unionShopMain", UI)

--init
function UI_unionShopMain:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(830)
	uiFrame:setTitle(hp.lang.getStrByID(5128))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	self:registMsg(hp.MSG.UNION_NOTIFY)
end

function UI_unionShopMain:initCallBack()
	local function onHelpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/union/shop/unionShopContribute"
			local ui_ = UI_unionShopContribute.new()
			self:addModalUI(ui_)
		end
	end

	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/union/shop/unionShopContribute"
			local ui_ = UI_unionShopContribute.new()
			self:addModalUI(ui_)		
		end
	end

	local function onItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()
			if tag_ == 1 then
				require "ui/union/shop/unionShop"
				local ui_ = UI_unionShop.new()
				self:addUI(ui_)
			elseif tag_ == 2 then				
				local authority_ = hp.gameDataLoader.getInfoBySid("allienceRank", player.getAlliance():getMyUnionInfo():getRank())
				cclog_("player.getAlliance():getMyUnionInfo():getRank()",player.getAlliance():getMyUnionInfo():getRank())
				if authority_.shopBuy == 1 then
					require "ui/union/shop/unionShopCatalog"
					local ui_ = UI_unionShopCatalog.new()
					self:addUI(ui_)
				else
					require "ui/union/shop/unionShopCatalogBuy"
					local ui_ = UI_unionShopCatalogBuy.new()
					self:addUI(ui_)
				end
			elseif tag_ == 3 then
				require "ui/union/shop/unionShopHistory"
				local ui_ = UI_unionShopHistory.new()
				self:addUI(ui_)				
			end
		end
	end

	self.onHelpTouched = onHelpTouched
	self.onItemTouched = onItemTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_unionShopMain:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShopMain.json")
	local content_ = self.widgetRoot:getChildByName("Panel_26_0")
	cclog_("player.getAlliance():getFunds()",player.getAlliance():getFunds())
	self.uiMoney = content_:getChildByName("Label_62")
	self.uiMoney:setString(hp.lang.getStrByID(7001).."      "..tostring(player.getAlliance():getMyUnionInfoBase().contribute))
	content_:getChildByName("Image_7"):getChildByName("Image_63"):addTouchEventListener(self.onHelpTouched)

	local listView_ = self.widgetRoot:getChildByName("ListView_36")
	local idList_ = {1173,1174,1175}
	for i = 1, 3 do
		local item_ = listView_:getItem(i - 1)
		local content_ = item_:getChildByName("Panel_41")
		item_:setTag(i)
		item_:addTouchEventListener(self.onItemTouched)
		content_:getChildByName("Label_39"):setString(hp.lang.getStrByID(idList_[i]))
	end
	local moreInfo_ = listView_:getItem(3):getChildByName("Panel_41"):getChildByName("Image_38")
	moreInfo_:addTouchEventListener(self.onMoreInfoTouched)
	moreInfo_:getChildByName("Label_62"):setString(hp.lang.getStrByID(1030))
end

function UI_unionShopMain:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_NOTIFY then
		if param_.msgType == 4 then
			self.uiMoney:setString(hp.lang.getStrByID(7001).."      "..tostring(player.getAlliance():getMyUnionInfoBase().contribute))
		end
	end
end