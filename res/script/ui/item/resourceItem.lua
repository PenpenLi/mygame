--
-- ui/item/resourceItem.lua
-- 资源道具主界面
--===================================
require "ui/fullScreenFrame"
require "ui/item/itemUsedFunc"


UI_resourceItem = class("UI_resourceItem", UI)


--init
function UI_resourceItem:init(itemType_)
	-- data
	-- ===============================
	local resources = {"silver", "food", "wood", "rock", "mine"}
	self.resources = resources
	if itemType_==nil then
		self.itemType = 1
	else
		self.itemType = itemType_
	end


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2840))
	uiFrame:setTopShadePosY(780)
	local rootWidget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "resourceItem.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(rootWidget)

	--
	-- ===============================
	-- headerTab
	local tabFrame = rootWidget:getChildByName("Panel_frame")
	local tabFrames = tabFrame:getChildren()
	local tab = rootWidget:getChildByName("Panel_typeTab")
	local tabs = tab:getChildren()
	self.resourceTabs = tabs
	for i=1, 5 do
		tabs[i]:setString(player.getResource(resources[i]))
	end
	local typeSelect = nil
	local selImg = tabFrames[#tabFrames]
	local function tabType(tabNode)
			typeSelect = tabNode
			selImg:setPosition(typeSelect:getPosition())
			self.itemType = typeSelect:getTag()
	end
	tabType(tabFrames[self.itemType])
	local function onTypeTabTouched(sender, eventType)
		if sender==typeSelect then
			return
		end
		if eventType==TOUCH_EVENT_ENDED then
			tabType(sender)
			self:updateItemList(true)
		end
	end
	for i,v in ipairs(tabFrames) do
		v:addTouchEventListener(onTypeTabTouched)
	end

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
	self:updateItemList(true)

	--
	-- registMsg
	self:registMsg(hp.MSG.ITEM_CHANGED)
	self:registMsg(hp.MSG.RESOURCE_CHANGED)
end


--
--onRemove
function UI_resourceItem:onRemove()
	-- must release
	self.item1:release()
	self.item2:release()

	self.super.onRemove(self)
end

-- onMsg
function UI_resourceItem:onMsg(msg_, itemInfo_)
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
					-- local buyNode = operBtn:getChildByName("Panel_buy")
					-- buyNode:getChildByName("Label_num"):setString(itemInfo.sale)
					-- buyNode:setVisible(true)
					-- operBtn:getChildByName("Panel_use"):setVisible(false)
					self:updateItemList(false)
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
	elseif msg_==hp.MSG.RESOURCE_CHANGED then
		if itemInfo_.name=="rock" then
			self.resourceTabs[4]:setString(itemInfo_.num)
		elseif itemInfo_.name=="wood" then
			self.resourceTabs[3]:setString(itemInfo_.num)
		elseif itemInfo_.name=="mine" then
			self.resourceTabs[5]:setString(itemInfo_.num)
		elseif itemInfo_.name=="food" then
			self.resourceTabs[2]:setString(itemInfo_.num)
		elseif itemInfo_.name=="silver" then
			self.resourceTabs[1]:setString(itemInfo_.num)
		end
	end
end


function UI_resourceItem:updateItemList(jumpTop_)
	local itemList = self.itemList
	-- 更新列表
	itemList:removeAllItems()

	-- 跳转到顶部
	if jumpTop_ then
		itemList:jumpToTop()
	end

	self.loadingFinished = false
	self.loadingIndex = 0 --已经加载的索引
	self:pushLoadingItem(999)
end

--
function UI_resourceItem:pushLoadingItem(loadingNumOnce)
	if self.loadingFinished then
		return
	end

	local loadingNum = 0

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
					-- edit by huangwei
					Scene.showMsg({3001, getItemInfoBySid(operItemInfo.sid).name, 1})
					-- edit by huangwei end
				elseif tag==2 then
				-- 使用
					player.expendItem(operItemInfo.sid, 1) --消耗道具
					-- edit by huangwei
					Scene.showMsg({3000, getItemInfoBySid(operItemInfo.sid).name, 1})
					-- edit by huangwei end
				end
				-- 添加资源
				player.addResource(self.resources[operItemInfo.parmeter1[1]], operItemInfo.parmeter2[1])
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
			local itemInfo = getItemInfoBySid(itemSid)
			if itemNum<=0 then
			-- 购买使用
				if player.getResource("gold")<itemInfo.sale then
					-- 金币不够
					require("ui/msgBox/msgBox")
					UI_msgBox.showCommonMsg(self, 1)
					return
				end

				local cmdData={operation={}}
				local oper = {}
				oper.channel = 14
				oper.type = 1
				oper.sid = itemSid
				oper.gold = itemInfo.sale
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
				oper.sid = itemSid
				oper.gold = 0
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
		local itemNum = player.getItemNum(itemInfo.sid)
		itemCont:getChildByName("Label_name"):setString(itemInfo.name)
		itemCont:getChildByName("Label_desc"):setString(itemInfo.desc)
		itemCont:getChildByName("ImageView_item"):loadTexture(string.format("%s%d.png", config.dirUI.item, itemInfo.sid))
		itemCont:getChildByName("Label_num"):setString(string.format(hp.lang.getStrByID(2403), itemNum))
		local operBtn = itemCont:getChildByName("ImageView_oper")
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
	local item1Parm = {} --拥有道具的项
	local item2Parm = {} --未拥有道具的项
	local totalNum = #game.data.item
	for i=self.loadingIndex+1, totalNum do
		local itemInfo = game.data.item[i]
		if itemInfo.type==2 and #itemInfo.parmeter1==1 and itemType==itemInfo.parmeter1[1] then
			if itemCanShow(itemInfo.sid) then
				if itemInfo.funStyle==12 then
					itemTemp = item1:clone()
				else
					itemTemp = item2:clone()
				end
				setItemInfo(itemTemp, itemInfo)

				-- 排序插入 -------
				if player.getItemNum(itemInfo.sid) >0 then
					local index = #item1Parm+1
					for i, v in ipairs(item1Parm) do
						if itemInfo.parmeter2[1]<v then
							index = i
							break
						end
					end
					table.insert(item1Parm, index, itemInfo.parmeter2[1])
					itemList:insertCustomItem(itemTemp, index-1)
				else
					local index = #item2Parm+1
					for i, v in ipairs(item2Parm) do
						if itemInfo.parmeter2[1]<v then
							index = i
							break
						end
					end
					table.insert(item2Parm, index, itemInfo.parmeter2[1])
					itemList:insertCustomItem(itemTemp, #item1Parm+index-1)
				end
				-- 排序插入 -------

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


