--
-- ui/union/unionShopCatalogBuy.lua
-- 公会商店目录求购底板
--===================================
require "ui/fullScreenFrame"

UI_unionShopCatalogBuy = class("UI_unionShopCatalogBuy", UI)

local baseTypeID_ = {2803,2804,2805,2807,2808}

--init
function UI_unionShopCatalogBuy:init()
	-- data
	-- ===============================
	self.shopItems = {}

	-- ui data
	self.popUI = nil
	self.uiStar = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(750)
	uiFrame:setTitle(hp.lang.getStrByID(5129))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.uiTitle)
	hp.uiHelper.uiAdaption(self.uiItem)

	self:registMsg(hp.MSG.UNION_SHOP_STAR_CLICK)

	self:initShopItem()
	self:refreshShow()
	self:requestData()
end

function UI_unionShopCatalogBuy:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShop.json")
	local content_ = self.widgetRoot:getChildByName("Panel_26")
	-- 图标
	content_:getChildByName("Image_61"):loadTexture(config.dirUI.common.."alliance_49.png")

	-- 总金额
	self.uiMoney = content_:getChildByName("Label_62")
	self.uiMoney:setString(hp.lang.getStrByID(5120).."      "..tostring(player.getAlliance():getFunds()))

	-- 说明文字
	content_:getChildByName("Label_64"):setString(hp.lang.getStrByID(1176))
	-- 帮助
	content_:getChildByName("Image_7"):getChildByName("Image_63"):addTouchEventListener(self.onHelpTouched)

	self.listView = self.widgetRoot:getChildByName("ListView_17_0")
	self.uiTitle = self.listView:getItem(0):clone()
	self.uiTitle:retain()
	self.uiItem = self.listView:getItem(1):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()
	self.listView:addTouchEventListener(self.onListViewTouched)
end

function UI_unionShopCatalogBuy:initShopItem()
	for i, v in ipairs(hp.gameDataLoader.getTable("shopID")) do
		if v.societySpecialSid == -1 then
			break
		end
		local item_ = hp.gameDataLoader.getInfoBySid("item", v.societySpecialSid)
		if self.shopItems[item_.type] == nil then
			self.shopItems[item_.type] = {}
		end
		table.insert(self.shopItems[item_.type], item_)
	end
end

function UI_unionShopCatalogBuy:refreshShow()
	self.listView:removeAllItems()

	for i, v in pairs(self.shopItems) do
		local index_ = 1
		local title_ = self.uiTitle:clone()
		self.listView:pushBackCustomItem(title_)
		cclog_(i)
		title_:getChildByName("Panel_21"):getChildByName("Label_23"):setString(hp.lang.getStrByID(baseTypeID_[i]))
		local item_ = self.uiItem:clone()
		self.listView:pushBackCustomItem(item_)
		for j, w in ipairs(v) do
			local content_ = item_:getChildByName("Panel_21"):getChildByName(tostring(index_))
			local pic_ = content_:getChildByName("Image_66")
			pic_:setTag(w.sid)
			pic_:addTouchEventListener(self.onItemTouched)
			pic_:getChildByName("Image_67"):loadTexture(string.format("%s%s.png", config.dirUI.item, tostring(w.sid)))

			-- 货币图标
			content_:getChildByName("Image_115"):loadTexture(config.dirUI.common.."alliance_49.png")

			-- 售价
			content_:getChildByName("Label_116"):setString(w.societySale)

			-- 商品描述
			content_:getChildByName("Label_119"):setString(w.name)

			-- 星星
			self.uiStar[w.sid] = content_:getChildByName("Image_117"):getChildByName("Label_118")
			self.uiStar[w.sid]:setString(string.format(hp.lang.getStrByID(5527), 0))

			if index_ == 3 then
				index_ = 1
				item_ = self.uiItem:clone()
				self.listView:pushBackCustomItem(item_)
			else
				index_ = index_ + 1
			end
		end

		for i = index_, 3 do
			item_:getChildByName("Panel_21"):getChildByName(tostring(i)):setVisible(false)
		end

		if index_ == 1 then
			self.listView:removeLastItem()
		end
	end
end

function UI_unionShopCatalogBuy:requestData()
	local function onApplicantResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:updateInfo(data.shop)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 13
	oper.type = 7
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onApplicantResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionShopCatalogBuy:updateInfo(info_)
	for i, v in pairs(info_) do
		if self.uiStar[v[1]] ~= nil then
			self.uiStar[v[1]]:setString(string.format(hp.lang.getStrByID(5527), v[2]))
		end
	end
end

function UI_unionShopCatalogBuy:initCallBack()
	local function onHelpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/union/shop/unionShopFunds"
			local ui_ = UI_unionShopFunds.new()
			self:addModalUI(ui_)
		end
	end

	local function onItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local function onPopUICloseed()
				self.popUI = nil
			end
			if self.popUI ~= nil then
				self.popUI:changeItem(sender:getTag())
			else
				require "ui/union/shop/unionShopCatalogBuyPop"
				self.popUI = UI_unionShopCatalogBuyPop.new(sender:getTag(), onPopUICloseed)
				self:addModalUI(self.popUI)
			end
		end
	end

	local function onListViewTouched(sender, eventType)
		if self.popUI ~= nil then
			self.popUI:close()
			self.popUI = nil 
		end
	end

	self.onHelpTouched = onHelpTouched
	self.onItemTouched = onItemTouched
	self.onListViewTouched = onListViewTouched
end

function UI_unionShopCatalogBuy:onRemove()
	if self.popUI ~= nil then
		self.popUI:close()
		self.popUI = nil 
	end
	self.uiTitle:release()
	self.uiItem:release()
	self.super.onRemove(self)
end

function UI_unionShopCatalogBuy:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_SHOP_STAR_CLICK then
		local num_ = tonumber(self.uiStar[param_[1]]:getStringValue()) + param_[2]
		self.uiStar[param_[1]]:setString(num_)
	elseif msg_ == hp.MSG.UNION_NOTIFY then
		if param_.msgType == 3 then
			self.uiMoney:setString(hp.lang.getStrByID(5120).."      "..tostring(player.getAlliance():getFunds()))
		end		
	elseif msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.BASEINFO then
			self.uiMoney:setString(hp.lang.getStrByID(5120).."      "..tostring(player.getAlliance():getFunds()))
		end
	end
end