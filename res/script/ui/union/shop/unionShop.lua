--
-- ui/union/unionShop.lua
-- 公会商店底板
--===================================
require "ui/fullScreenFrame"

UI_unionShop = class("UI_unionShop", UI)

local baseTypeID_ = {2803,2804,2805,2807,2808}

--init
function UI_unionShop:init()
	-- data
	-- ===============================
	self.unionShopItemNum = 0
	self.shopItems = {}
	self.unionShopItems = {}
	self.unionShopMap = {}

	-- ui data
	self.popUI = nil
	self.uiItemMap = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(750)
	uiFrame:setTitle(hp.lang.getStrByID(5128))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.uiTitle)
	hp.uiHelper.uiAdaption(self.uiItem)

	self:registMsg(hp.MSG.UNION_NOTIFY)

	self:initShopItem()
	self:refreshShow()
	self:requestShopItems()
end

function UI_unionShop:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShop.json")
	local content_ = self.widgetRoot:getChildByName("Panel_26")
	-- 图标
	content_:getChildByName("Image_61"):loadTexture(config.dirUI.common.."alliance_48.png")

	-- 总金额
	self.uiMoney = content_:getChildByName("Label_62")
	self.uiMoney:setString(hp.lang.getStrByID(7001).."      "..tostring(player.getAlliance():getMyUnionInfoBase().contribute))

	-- 说明文字
	content_:getChildByName("Label_64"):setString(hp.lang.getStrByID(1176))
	-- 帮助
	content_:getChildByName("Image_7"):getChildByName("Image_63"):addTouchEventListener(self.onHelpTouched)

	self.listView = self.widgetRoot:getChildByName("ListView_17_0")
	self.uiTitle = self.listView:getItem(0):clone()
	self.uiTitle:retain()
	self.uiItem = self.listView:getItem(1):clone()
	self.uiItem:retain()
	for i = 1, 3 do
		self.uiItem:getChildByName("Panel_21"):getChildByName(tostring(i)):getChildByName("Image_117"):setVisible(false)
	end
	self.listView:removeAllItems()
	self.listView:addTouchEventListener(self.onListViewTouched)
end

function UI_unionShop:requestShopItems()
	local function onApplicantResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:initUnionShopItem(data.shop)
			self:refreshCatalog(data.shop)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 13
	oper.type = 2
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onApplicantResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionShop:initShopItem()
	for i, v in ipairs(hp.gameDataLoader.getTable("shopID")) do
		if v.societyNormalSid == -1 then
			break
		end
		local item_ = hp.gameDataLoader.getInfoBySid("item", v.societyNormalSid)
		if self.shopItems[item_.type] == nil then
			self.shopItems[item_.type] = {}
		end
		item_.subtype = 1
		local tag_ = item_.sid * 10 + 1
		table.insert(self.shopItems[item_.type], item_)
		self.unionShopMap[tag_] = item_
	end
end

function UI_unionShop:initUnionShopItem(info_)
	self.unionShopItemNum = table.getn(info_)
	for i, v in ipairs(info_) do
		local item_ = hp.gameDataLoader.getInfoBySid("item", v[1])
		if self.unionShopItems[item_.type] == nil then
			self.unionShopItems[item_.type] = {}
		end
		item_.number = v[2]
		item_.subtype = 2
		local tag_ = item_.sid * 10 + 2
		cclog_("+++++++", tag_)
		table.insert(self.unionShopItems[item_.type], item_)
		self.unionShopMap[tag_] = item_
		cclog_(self.unionShopMap[tag_].sid)
		cclog_(self.unionShopMap[tag_].number)
	end
end

function UI_unionShop:refreshShow()
	self.listView:removeAllItems()

	for i, v in pairs(self.shopItems) do
		local index_ = 1
		local title_ = self.uiTitle:clone()
		self.listView:pushBackCustomItem(title_)
		title_:getChildByName("Panel_21"):getChildByName("Label_23"):setString(hp.lang.getStrByID(baseTypeID_[i]))
		local item_ = self.uiItem:clone()
		self.listView:pushBackCustomItem(item_)
		for j, w in ipairs(v) do
			local content_ = item_:getChildByName("Panel_21"):getChildByName(tostring(index_))
			local pic_ = content_:getChildByName("Image_66")
			local tag_ = w.sid * 10 + 1
			self.uiItemMap[tag_] = content_
			pic_:setTag(tag_)
			pic_:addTouchEventListener(self.onItemTouched)
			pic_:getChildByName("Image_67"):loadTexture(string.format("%s%s.png", config.dirUI.item, tostring(w.sid)))

			-- 货币图标
			content_:getChildByName("Image_115"):loadTexture(config.dirUI.common.."alliance_48.png")

			-- 售价
			content_:getChildByName("Label_116"):setString(w.societySale)

			-- 商品描述
			content_:getChildByName("Label_119"):setString(w.name)

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

function UI_unionShop:refreshCatalog()
	if self.unionShopItemNum == 0 then
		return
	end
	local title_ = self.uiTitle:clone()
	title_:getChildByName("Panel_21"):getChildByName("Label_23"):setString(hp.lang.getStrByID(1182))
	self.listView:pushBackCustomItem(title_)
	for i, v in pairs(self.unionShopItems) do
		local index_ = 1
		local title_ = self.uiTitle:clone()
		self.listView:pushBackCustomItem(title_)
		title_:getChildByName("Panel_21"):getChildByName("Label_23"):setString(hp.lang.getStrByID(baseTypeID_[i]))
		local item_ = self.uiItem:clone()
		self.listView:pushBackCustomItem(item_)
		for j, w in ipairs(v) do
			local content_ = item_:getChildByName("Panel_21"):getChildByName(tostring(index_))
			local pic_ = content_:getChildByName("Image_66")
			local tag_ = w.sid * 10 + 2
			self.uiItemMap[tag_] = content_
			pic_:setTag(tag_)
			pic_:addTouchEventListener(self.onItemTouched)
			pic_:getChildByName("Image_67"):loadTexture(string.format("%s%s.png", config.dirUI.item, tostring(w.sid)))

			-- 货币图标
			content_:getChildByName("Image_115"):loadTexture(config.dirUI.common.."alliance_48.png")

			-- 售价
			content_:getChildByName("Label_116"):setString(w.societySale)

			-- 商品名称
			content_:getChildByName("Label_119"):setString(w.name)

			-- 数量
			content_:getChildByName("Image_117_0"):setVisible(true)
			content_:getChildByName("Image_117_0"):getChildByName("Label_118"):setString(tostring(w.number))

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

function UI_unionShop:initCallBack()
	local function onHelpTouched(sender, eventType)
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
			local info_ = self.unionShopMap[sender:getTag()]
			cclog_("+++++++",sender:getTag())
			local function onPopUICloseed()
				self.popUI = nil
			end
			if self.popUI ~= nil then
				self.popUI:changeItem(info_.sid, info_.subtype, info_.number)
			else
				require "ui/union/shop/unionShopPop"
				self.popUI = UI_unionShopPop.new(info_.sid, info_.subtype, info_.number, onPopUICloseed)
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

function UI_unionShop:onRemove()
	if self.popUI ~= nil then
		self.popUI:close()
		self.popUI = nil 
	end
	self.uiItem:release()
	self.uiTitle:release()
	self.super.onRemove(self)
end

function UI_unionShop:changeItemNumber(sid_, num_, subType_)
	cclog_("subType_",subType_)
	local tag_ = sid_ * 10 + subType_
	cclog_("tag_",tag_)
	local item_ = self.uiItemMap[tag_]
	local info_ = self.unionShopMap[tag_]
	if info_.subtype == 1 then
		return
	end
	
	if item_ ~= nil and info_ ~= nil then
		info_.number = info_.number - num_
		if info_.number <= 0 then
			item_:setVisible(false)
		else
			item_:getChildByName("Image_117_0"):getChildByName("Label_118"):setString(tostring(info_.number))
		end
	end
end

function UI_unionShop:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_NOTIFY then
		if param_.msgType == 4 then
			self.uiMoney:setString(hp.lang.getStrByID(7001).."      "..tostring(player.getAlliance():getMyUnionInfoBase().contribute))
		elseif param_.msgType == 5 then
			self:changeItemNumber(param_.sid, param_.num, param_.subType)
		end
	end
end