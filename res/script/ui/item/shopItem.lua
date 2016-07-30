--
-- ui/item/shopItem.lua
-- 道具主界面
--===================================
require "ui/fullScreenFrame"
require "ui/item/itemUsedFunc"
require "ui/common/promotionInfo"


UI_shopItem = class("UI_shopItem", UI)


--init
function UI_shopItem:init(hType_, itemType_)
	-- data
	-- ===============================
	if hType_==nil then
		self.headerType = 1
	else
		self.headerType = hType_
	end
	if itemType_==nil then
		self.itemType = 1
	else
		self.itemType = itemType_
	end


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2800))
	uiFrame:setTopShadePosY(656)
	local promotionUI = UI_promotionInfo.new()
	local rootWidget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "shopItem.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(promotionUI)
	self:addCCNode(rootWidget)


	--
	-- ===============================
	-- headerTab
	-----------------------------
	local headerTab = rootWidget:getChildByName("Panel_headTab")
	local shopTab = headerTab:getChildByName("ImageView_shop")
	local shopTabText = shopTab:getChildByName("Label_name")
	local meTab = headerTab:getChildByName("ImageView_me")
	local meTabText = meTab:getChildByName("Label_name")
	local scaleSelected = shopTab:getScale()
	local colorSelected = shopTab:getColor()
	local scaleUnselected = meTab:getScale()
	local colorUnselected = meTab:getColor()
	local headerTabSelected = shopTab
	shopTabText:setString(hp.lang.getStrByID(2801))
	meTabText:setString(hp.lang.getStrByID(2802))
	local function tabHeaderType(tabNode)
			headerTabSelected:setColor(colorUnselected)
			headerTabSelected:setScale(scaleUnselected)
			headerTabSelected:getChildByName("Label_name"):setColor(colorUnselected)
			headerTabSelected = tabNode
			headerTabSelected:setColor(colorSelected)
			headerTabSelected:setScale(scaleSelected)
			headerTabSelected:getChildByName("Label_name"):setColor(colorSelected)

			self.headerType = headerTabSelected:getTag()
	end
	local function onHeaderTabTouched(sender, eventType)
		if sender==headerTabSelected then
			return
		end

		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(colorSelected)
			sender:getChildByName("Label_name"):setColor(colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(colorSelected)
				sender:getChildByName("Label_name"):setColor(colorSelected)
			else
				sender:setColor(colorUnselected)
				sender:getChildByName("Label_name"):setColor(colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			tabHeaderType(sender)
			self:updateItemList()
			player.guide.step(5004)
		end
	end
	shopTab:addTouchEventListener(onHeaderTabTouched)
	meTab:addTouchEventListener(onHeaderTabTouched)
	if headerTabSelected:getTag()~=self.headerType then
	--切换tab
		tabHeaderType(headerTab:getChildByTag(self.headerType))
	end

	-- typeTab
	-----------------------------
	local typeSelected = nil
	local typeTab = rootWidget:getChildByName("Panel_typeTabbg")
	local typeText = rootWidget:getChildByName("Panel_typeTab_text")
	local typeTabs = {}
	local typeTexts = {}
	local typeSelect = typeTab:getChildByName("Image_select")

	local unsColor = nil
	local sColor = cc.c3b(255, 255, 255)
	local function tabType(tabNode)
			typeTexts[self.itemType]:setColor(unsColor)
			typeSelected = tabNode
			self.itemType = typeSelected:getTag()
			typeTexts[self.itemType]:setColor(sColor)
			typeSelect:setPosition(typeSelected:getPosition())
	end
	local function onTypeTabTouched(sender, eventType)
		if sender==typeSelected then
			return
		end
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			tabType(sender)
			self:updateItemList()
		end
	end

	for i=1,5 do
		typeTabs[i] = typeTab:getChildByName("Image_" .. i)
		typeTabs[i]:addTouchEventListener(onTypeTabTouched)
		typeTexts[i] = typeText:getChildByName("Label_" .. i)
	end
	typeTexts[1]:setString(hp.lang.getStrByID(2803))
	typeTexts[2]:setString(hp.lang.getStrByID(2804))
	typeTexts[3]:setString(hp.lang.getStrByID(2805))
	typeTexts[4]:setString(hp.lang.getStrByID(2807))
	typeTexts[5]:setString(hp.lang.getStrByID(2808))
	unsColor = typeTexts[1]:getColor()
	tabType(typeTab:getChildByTag(self.itemType))

	-- list
	-----------------------------
	local itemList = rootWidget:getChildByName("ListView_items")
	local descItem = itemList:getChildByName("Panel_desc"):clone()
	local item1 = itemList:getChildByName("Panel_item1"):clone()
	local item2 = itemList:getChildByName("Panel_item2"):clone()
	-- retain must
	descItem:retain()
	item1:retain()
	item2:retain()
	local function onScrollEvent(t1, t2, t3)
		if t2==ccui.ScrollviewEventType.scrollToBottom then
			self:pushLoadingItem(2)
		end
	end
	--itemList:setDelegate()
	itemList:addEventListenerScrollView(onScrollEvent)

	--
	self.itemList = itemList
	self.descItem = descItem
	self.item1 = item1
	self.item2 = item2
	self:updateItemList()

	--
	-- registMsg
	self:registMsg(hp.MSG.ITEM_CHANGED)
end


--
--onRemove
function UI_shopItem:onRemove()
	-- must release
	self.descItem:release()
	self.item1:release()
	self.item2:release()

	self.super.onRemove(self)
end

-- onMsg
function UI_shopItem:onMsg(msg_, itemInfo_)
	if msg_==hp.MSG.ITEM_CHANGED then
		local itemNode = self.itemList:getChildByTag(itemInfo_.sid)
		if itemNode~=nil then
			if self.headerType==2 and itemInfo_.num<=0 then
			--用完了
				self.itemList:removeItem(self.itemList:getIndex(itemNode))
			else
				local strNum = string.format(string.format(hp.lang.getStrByID(2403), itemInfo_.num))
				itemNode:getChildByName("Panel_cont"):getChildByName("Label_num"):setString(strNum)
			end
		end
	end
end


function UI_shopItem:updateItemList()
	local itemType = self.itemType
	local itemList = self.itemList
	local descItem = self.descItem
	local itemTemp = nil

	-- 更新列表
	itemList:removeAllItems()
	itemList:jumpToTop()

	-- 列表描述
	itemTemp = descItem:clone()
	itemList:pushBackCustomItem(itemTemp)
	itemTemp:getChildByName("Panel_cont"):getChildByName("Label_desc"):setString(hp.lang.getStrByID(2810+itemType))

	self.loadingFinished = false
	self.loadingIndex = 0 --已经加载的索引
	self:pushLoadingItem(4)
end

--
function UI_shopItem:pushLoadingItem(loadingNumOnce)
	if self.loadingFinished then
		return
	end

	local loadingNum = 0

	local headerType = self.headerType
	local itemType = self.itemType
	local itemList = self.itemList
	local item1 = self.item1
	local item2 = self.item2
	local itemTemp = nil

	-- 根据sid获取ItemInfo
	local function getItemInfoBySid(sid)
		for i, itemInfo in ipairs(game.data.item) do
			if sid==itemInfo.sid then
				return itemInfo
			end
		end

		return nil
	end

	local operItemInfo = nil
	local function onBuyItemHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				if tag==1 then
				--购买道具
					player.expendResource("gold", operItemInfo.sale)
					player.addItem(operItemInfo.sid, 1)

					-- edit by huangwei
					Scene.showMsg({3002, getItemInfoBySid(operItemInfo.sid).name, 1})
					-- edit by huangwei end
				elseif tag==2 then
				-- 使用道具
					player.expendItem(operItemInfo.sid, 1)
					itemUsedFunc(operItemInfo, data)
					player.guide.step(5006)

					-- edit by huangwei
					Scene.showMsg({3000, getItemInfoBySid(operItemInfo.sid).name, 1})
					-- edit by huangwei end
					
					-- 宝石/材料宝箱提示获得的物品
					if data.items ~= nil then						
						local gemInfo = hp.gameDataLoader.getInfoBySid("gem", data.items[1])
						if gemInfo~=nil then
							require("ui/smith/gemMaterialInfo")
							local ui = UI_gemMaterialInfo.new(1,gemInfo)
							self:addModalUI(ui)
						else
							local materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", data.items[1])
							if materialInfo~=nil then
								require("ui/smith/gemMaterialInfo")
								local ui = UI_gemMaterialInfo.new(2,materialInfo)
								self:addModalUI(ui)
							end
						end
					end
				end
			end
		end

		operItemInfo=nil
	end
	-- 操作
	local function onItemOperTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if operItemInfo~=nil then
				-- 一个未从服务器返回的操作
				return
			end

			local itemInfo = getItemInfoBySid(sender:getTag())
			if headerType==1 then
			-- 购买
				if player.getResource("gold")<itemInfo.sale then
					-- 金币不够
					require("ui/msgBox/msgBox")
					UI_msgBox.showCommonMsg(self, 1)
					return
				end

				local cmdData={operation={}}
				local oper = {}
				oper.channel = 13
				oper.type = 1
				oper.subtype = 0
				oper.sid = sender:getTag()
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
				self:showLoading(cmdSender, sender)
			else
			-- 使用
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 14
				oper.type = 1
				oper.sid = sender:getTag()
				oper.gold = 0
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 2)
				self:showLoading(cmdSender, sender)
			end

			operItemInfo = itemInfo
		end
	end

	-- 设置frame位置
	local function resetItemFrameNode1(nodeFrame, nodeName, height)
		local nodeTmp = nodeFrame:getChildByName(nodeName)
		local px, py = nodeTmp:getPosition()
		nodeTmp:setPosition(px, py+height)
	end
	-- 设置frame高度
	local function resetItemFrameNode2(nodeFrame, nodeName, height)
		local nodeTmp = nodeFrame:getChildByName(nodeName)
		local sz = nodeTmp:getSize()
		sz.height = sz.height+height/hp.uiHelper.RA_scaleY
		nodeTmp:setSize(sz)
	end

	-- 设置一项的显示
	local function setItemInfo(itemNode, itemInfo)
		local itemCont = itemNode:getChildByName("Panel_cont")
		itemCont:getChildByName("Label_name"):setString(itemInfo.name)
		itemCont:getChildByName("Label_desc"):setString(itemInfo.desc)
		itemCont:getChildByName("ImageView_item"):loadTexture(string.format("%s%d.png", config.dirUI.item, itemInfo.sid))
		itemCont:getChildByName("Label_num"):setString(string.format(hp.lang.getStrByID(2403), player.getItemNum(itemInfo.sid)))
		local operBtn = itemCont:getChildByName("ImageView_oper")
		operBtn:setTag(itemInfo.sid)
		itemNode:setTag(itemInfo.sid)
		if headerType==1 then
			local buyNode = operBtn:getChildByName("Panel_buy")
			buyNode:getChildByName("Label_num"):setString(itemInfo.sale)
			buyNode:setVisible(true)
			operBtn:getChildByName("Panel_use"):setVisible(false)
			operBtn:addTouchEventListener(onItemOperTouched)
		else
			operBtn:getChildByName("Panel_buy"):setVisible(false)
			if itemInfo.isUsed==1 then
				operBtn:getChildByName("Panel_use"):setVisible(true)
				operBtn:addTouchEventListener(onItemOperTouched)
			else
				operBtn:getChildByName("Panel_use"):setVisible(false)
				operBtn:setVisible(false)
			end
		end

		if itemInfo.funStyle==12 then
		-- 可展开项目
			local openList = itemNode:getChildByName("ListView_openList")
			local openItem = openList:getItem(0)
			local itemTmp = openItem
			for i, v in ipairs(itemInfo.parmeter1) do
				if i>1 then
					itemTmp = openItem:clone()
					openList:pushBackCustomItem(itemTmp)
				end
				local subItemInfo = getItemInfoBySid(v)
				if subItemInfo~=nil then
					local itemCnt = itemTmp:getChildByName("Panel_cont")
					itemCnt:getChildByName("ImageView_item"):loadTexture(string.format("%s%d.png", config.dirUI.item, subItemInfo.sid))
					itemCnt:getChildByName("Label_name"):setString(subItemInfo.name)
					itemCnt:getChildByName("Label_num"):setString(itemInfo.parmeter2[i])
				end

				if i%2==0 then
					itemTmp:getChildByName("Panel_frame"):setVisible(false)
				end
			end

			local itemSize = openItem:getSize()
			local height = itemSize.height*(#itemInfo.parmeter1-1)
			local itemFrame = itemNode:getChildByName("Panel_frame")
			resetItemFrameNode1(itemFrame, "1", height)
			resetItemFrameNode1(itemFrame, "2", height)
			resetItemFrameNode1(itemFrame, "3", height)
			resetItemFrameNode2(itemFrame, "4", height)
			resetItemFrameNode2(itemFrame, "5", height)
			resetItemFrameNode2(itemFrame, "6", height)

			local sz = itemNode:getSize()
			sz.height = sz.height+height
			itemNode:setSize(sz)
			local sz = openList:getSize()
			sz.height = sz.height+height
			openList:setSize(sz)
			local px, py = itemCont:getPosition()
			py = py+height
			itemCont:setPosition(px, py)
		end
	end

	-- 列表项
	if headerType==1 then
	-- 商店物品
		local totalNum = #game.data.item
		for i=self.loadingIndex+1, totalNum do
			local itemInfo = game.data.item[i]
			if itemType==itemInfo.type then
				if itemCanSold(itemInfo.sid) then
					if itemInfo.funStyle==12 then
						itemTemp = item1:clone()
					else
						itemTemp = item2:clone()
					end
					setItemInfo(itemTemp, itemInfo)
					itemList:pushBackCustomItem(itemTemp)
					loadingNum = loadingNum+1
					self.loadingIndex = i
					if loadingNum>=loadingNumOnce then
						break
					end
				end
			elseif self.loadingIndex~=0 then
			-- 加载完成
				self.loadingIndex = i
				--self.loadingFinished = true
				--break
			end

			if i==totalNum then
			-- 加载完成
				self.loadingIndex = i
				self.loadingFinished = true
			end
		end
	else
	-- 我的物品
		local totalNum = #game.data.item
		for i=self.loadingIndex+1, totalNum do
			local itemInfo = game.data.item[i]
			if itemType==itemInfo.type then
				if player.getItemNum(itemInfo.sid)>0 then
					if itemInfo.funStyle==12 then
						itemTemp = item1:clone()
					else
						itemTemp = item2:clone()
					end
					setItemInfo(itemTemp, itemInfo)
					itemList:pushBackCustomItem(itemTemp)
					loadingNum = loadingNum+1
					self.loadingIndex = i
					if loadingNum>=loadingNumOnce then
						break
					end
				end
			elseif self.loadingIndex~=0 then
			-- 加载完成
				self.loadingIndex = i
				--self.loadingFinished = true
				--break
			end

			if i==totalNum then
			-- 加载完成
				self.loadingIndex = i
				self.loadingFinished = true
			end
		end
	end
end


