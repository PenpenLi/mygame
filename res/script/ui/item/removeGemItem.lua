--
-- ui/item/removeGemItem.lua
-- 移除宝石道具
--===================================
require "ui/fullScreenFrame"
require "ui/item/itemUsedFunc"


UI_removeGemItem = class("UI_removeGemItem", UI)


--init
function UI_removeGemItem:init(equip_, pos_, useCallback_)
	-- data
	-- ===============================
	self.useCallback = useCallback_
	self.equip = equip_
	self.pos = pos_
	self.gemInfo = hp.gameDataLoader.getInfoBySid("gem", equip_.gems[pos_])


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(3511))

	local rootWidget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "commonItem.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(rootWidget)


	-- list
	local itemList = rootWidget:getChildByName("ListView_items")
	local item1 = itemList:getChildByName("Panel_item1"):clone()
	local item2 = itemList:getChildByName("Panel_item2"):clone()
	local item1Btn = item1:getChildByName("Panel_cont"):getChildByName("ImageView_oper")
	local item2Btn = item2:getChildByName("Panel_cont"):getChildByName("ImageView_oper")
	item1Btn:getChildByName("Panel_buy"):getChildByName("Label_buy"):setString(hp.lang.getStrByID(2838))
	item1Btn:getChildByName("Panel_use"):getChildByName("Label_use"):setString(hp.lang.getStrByID(2810))
	item2Btn:getChildByName("Panel_buy"):getChildByName("Label_buy"):setString(hp.lang.getStrByID(2838))
	item2Btn:getChildByName("Panel_use"):getChildByName("Label_use"):setString(hp.lang.getStrByID(2810))
	-- retain must
	item1:retain()
	item2:retain()
	local function onScrollEvent(t1, t2, t3)
		if t2==ccui.ScrollviewEventType.scrollToBottom then
			self:pushLoadingItem(2)
		end
	end
	itemList:addEventListenerScrollView(onScrollEvent)

	--
	self.itemList = itemList
	self.item1 = item1
	self.item2 = item2
	self:updateItemList()

	--
	-- registMsg
	self:registMsg(hp.MSG.ITEM_CHANGED)
end


--
--onRemove
function UI_removeGemItem:onRemove()
	-- must release
	self.item1:release()
	self.item2:release()

	self.super.onRemove(self)
end

-- onMsg
function UI_removeGemItem:onMsg(msg_, itemInfo_)
	if msg_==hp.MSG.ITEM_CHANGED then
		local itemNode = self.itemList:getChildByTag(itemInfo_.sid)
		if itemNode~=nil then
			local itemInfo = hp.gameDataLoader.getInfoBySid("item", itemInfo_.sid)
			local itemCont = itemNode:getChildByName("Panel_cont")
			local operBtn = itemCont:getChildByName("ImageView_oper")
			local strNum = string.format(string.format(hp.lang.getStrByID(2403), itemInfo_.num))
			itemCont:getChildByName("Label_num"):setString(strNum)
			if itemInfo_.num<=0 then
				if itemCanSold(itemInfo_.sid) then
					local buyNode = operBtn:getChildByName("Panel_buy")
					buyNode:getChildByName("Label_num"):setString(itemInfo.sale)
					buyNode:setVisible(true)
					operBtn:getChildByName("Panel_use"):setVisible(false)
				else
					self.itemList:removeItem(self.itemList:getIndex(itemNode))
				end
			else
				operBtn:getChildByName("Panel_buy"):setVisible(false)
				if itemInfo.isUsed then
					operBtn:getChildByName("Panel_use"):setVisible(true)
				else
					operBtn:getChildByName("Panel_use"):setVisible(true)
				end
			end
		end
	end
end


function UI_removeGemItem:updateItemList()
	local itemType = self.itemType
	local itemList = self.itemList
	local descItem = self.descItem
	local itemTemp = nil

	-- 更新列表
	itemList:removeAllItems()
	itemList:jumpToTop()

	self.loadingFinished = false
	self.loadingIndex = 0 --已经加载的索引
	self:pushLoadingItem(999)
end

--
function UI_removeGemItem:pushLoadingItem(loadingNumOnce)
	if self.loadingFinished then
		return
	end

	local loadingNum = 0

	local itemType = self.itemType
	local itemList = self.itemList
	local item1 = self.item1
	local item2 = self.item2
	local itemTemp = nil


	local itemInfoFree = {
		sid = 20500, --免费
		name = hp.lang.getStrByID(3512),
		desc = hp.lang.getStrByID(3513),
		funStyle = 0,
		sale = 0,
	}

	-- 根据sid获取ItemInfo
	local function getItemInfoBySid(sid)
		for i, itemInfo in ipairs(game.data.item) do
			if sid==itemInfo.sid then
				return itemInfo
			end
		end

		return nil
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

	local operItemInfo = nil
	local function onBuyItemHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				if tag==1 then
				-- 购买使用
					player.expendResource("gold", operItemInfo.sale) --消耗金币
					if operItemInfo.sid~=20500 then
						player.addItem(self.equip.gems[self.pos], 1) --添加回收宝石
					end
				elseif tag==2 then
				-- 使用
					if operItemInfo.sid~=20500 then
						player.expendItem(operItemInfo.sid, 1) --消耗道具
						player.addItem(self.equip.gems[self.pos], 1) --添加回收宝石
					end
				end
				-- 使用回调
				self.equip.gems[self.pos] = 0
				if self.useCallback then
					self.useCallback()
				end

				self:close()
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

			local itemSid = sender:getTag()
			local itemNum = player.getItemNum(itemSid)
			local itemInfo = nil
			if itemSid==20500 then
				itemInfo = itemInfoFree
			else
				itemInfo = getItemInfoBySid(itemSid)
				if itemSid==20501 then
					if self.gemInfo.level>2 then
						require("ui/msgBox/msgBox")
						local msgBox = UI_msgBox.new(hp.lang.getStrByID(3514), 
							hp.lang.getStrByID(3515), 
							hp.lang.getStrByID(1209)
							)
						self:addModalUI(msgBox)
						return
					end
				elseif itemSid==20502 then
					if self.gemInfo.level>4 then
						require("ui/msgBox/msgBox")
						local msgBox = UI_msgBox.new(hp.lang.getStrByID(3514), 
							hp.lang.getStrByID(3515), 
							hp.lang.getStrByID(1209)
							)
						self:addModalUI(msgBox)
						return
					end
				end
			end
			if itemNum<=0 then
			-- 购买使用
				if player.getResource("gold")<itemInfo.sale then
					-- 金币不够
					require("ui/msgBox/msgBox")
					local msgBox = UI_msgBox.new(hp.lang.getStrByID(2826), 
						hp.lang.getStrByID(2827), 
						hp.lang.getStrByID(1209), 
						hp.lang.getStrByID(2412)
						)
					self:addModalUI(msgBox)
					return
				end

				local cmdData={operation={}}
				local oper = {}
				oper.channel = 7
				oper.type = 7
				oper.id = self.equip.id
				oper.loc = self.pos-1
				if itemInfo.sid==20500 then
					oper.sid = 0
				else
					oper.sid = itemInfo.sid
					oper.gold = itemInfo.sale
				end
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
				self:showLoading(cmdSender, sender)
			else
			-- 使用
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 7
				oper.type = 7
				oper.id = self.equip.id
				oper.loc = self.pos-1
				if itemInfo.sid==20500 then
					oper.sid = 0
				else
					oper.sid = itemInfo.sid
				end
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 2)
				self:showLoading(cmdSender, sender)
			end

			operItemInfo = itemInfo
		end
	end

	-- 设置一项的显示
	local function setItemInfo(itemNode, itemInfo)
		local itemCont = itemNode:getChildByName("Panel_cont")
		local operBtn = itemCont:getChildByName("ImageView_oper")
		itemCont:getChildByName("Label_name"):setString(itemInfo.name)
		itemCont:getChildByName("Label_desc"):setString(itemInfo.desc)
		itemCont:getChildByName("ImageView_item"):loadTexture(string.format("%s%d.png", config.dirUI.item, itemInfo.sid))

		if itemInfo.sid ==20500 then
			itemCont:getChildByName("Label_num"):setVisible(false)
			operBtn:getChildByName("Panel_buy"):setVisible(false)
			if itemInfo.isUsed then
				operBtn:getChildByName("Panel_use"):setVisible(true)
			else
				operBtn:getChildByName("Panel_use"):setVisible(true)
			end
			operBtn:getChildByName("Panel_use"):getChildByName("Label_use"):setString(hp.lang.getStrByID(2408))
			operBtn:loadTexture(config.dirUI.common .. "button_blue1.png")
		else
			local itemNum = player.getItemNum(itemInfo.sid)
			itemCont:getChildByName("Label_num"):setString(string.format(hp.lang.getStrByID(2403), itemNum))
			if itemNum<=0 then
				local buyNode = operBtn:getChildByName("Panel_buy")
				buyNode:getChildByName("Label_num"):setString(itemInfo.sale)
				buyNode:setVisible(true)
				operBtn:getChildByName("Panel_use"):setVisible(false)
			else
				operBtn:getChildByName("Panel_buy"):setVisible(false)
				if itemInfo.isUsed then
					operBtn:getChildByName("Panel_use"):setVisible(true)
				else
					operBtn:getChildByName("Panel_use"):setVisible(true)
				end
			end
		end
		operBtn:setTag(itemInfo.sid)
		itemNode:setTag(itemInfo.sid)
		operBtn:addTouchEventListener(onItemOperTouched)

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
	local totalNum = #game.data.item
	itemTemp = item2:clone()
	setItemInfo(itemTemp, itemInfoFree)
	itemList:pushBackCustomItem(itemTemp)
	for i=self.loadingIndex+1, totalNum do
		local itemInfo = game.data.item[i]
		if itemInfo.sid==20501 or itemInfo.sid==20502 or itemInfo.sid==20503 then
			if itemCanShow(itemInfo.sid) then
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
			self.loadingFinished = true
			break
		end

		if i==totalNum then
		-- 加载完成
			self.loadingIndex = i
			self.loadingFinished = true
		end
	end
end


