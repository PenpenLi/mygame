--
-- ui/chat/chatRoom_chat.lua
-- 聊天室聊天界面
--===================================
require "ui/fullScreenFrame"


UI_chatRoom_chat = class("UI_chatRoom_chat", UI)


--init
function UI_chatRoom_chat:init(type_, playerInfo_)
	-- data
	-- ===============================
	local friendMgr = player.friendMgr
	local chatType = type_ --聊天类型:1--区域 2--公会 3--私聊
	local playerInfo = playerInfo_
	local playerId = nil
	if playerInfo then
		playerId = playerInfo.id
	end

	self.chatType = chatType
	self.playerId = playerId

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "chatRoom_chat.json")

	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)

	-- 编辑框
	local chatList = widgetRoot:getChildByName("ListView_chatList")
	local panelCont = widgetRoot:getChildByName("Panel_cont")
	local editBoxLabel = panelCont:getChildByName("Label_editBox")
	local editBoxCtrl = hp.uiHelper.labelBind2EditBox(editBoxLabel)
	editBoxCtrl.setMaxLength(100)
	-- btn
	local btnSend = panelCont:getChildByName("Image_sendBtn")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local text = editBoxCtrl:getString()
			if string.len(text)>0 then
				chatList:visit()
				if player.chatRoom.sendChat(text, chatType, playerId) then
					editBoxCtrl.setString("")
				end
			end
		end
	end
	btnSend:addTouchEventListener(onBtnTouched)

	local chatModel = chatList:getItem(0)
	local chatModelMe = chatList:getItem(1):clone()
	chatModelMe:retain()
	self.chatModelMe = chatModelMe
	chatList:setItemModel(chatModel)
	chatList:removeAllItems()
	local function onChatItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local chatInfo = player.chatRoom.getChatInfoByID(chatType, playerId, sender:getTag())
			require("ui/chat/chatOper")
			local ui = UI_chatOper.new(chatInfo)
			self:addModalUI(ui)
		end
	end
	local function addChatInfo(chatInfo, setPos_)
		local needToBottom = false
		if setPos_ then
			chatList:refreshView()
			local listCont = chatList:getInnerContainer()
			local x, y = listCont:getPosition()
			if y>-80 then
				needToBottom = true
			end
		end

		if player.getID()==chatInfo.srcId then
			chatList:pushBackCustomItem(chatModelMe:clone())
		else
			chatList:pushBackDefaultItem()
		end
		local chatItem = chatList:getItem(chatList:getChildrenCount() - 1)
		local itemCont = chatItem:getChildByName("Panel_cont")
		local imgHead = itemCont:getChildByName("Image_head")
		local imgVip = itemCont:getChildByName("Image_vip")
		local nameLabel = itemCont:getChildByName("Label_name")
		local chatLabel = itemCont:getChildByName("Label_text")
		local timeLabel = itemCont:getChildByName("Label_time")

		itemCont:setTag(chatInfo.id)
		imgHead:setTag(chatInfo.id)
		itemCont:addTouchEventListener(onChatItemTouched)
		imgHead:addTouchEventListener(onChatItemTouched)

		--vip
		if chatInfo.vipLv<=0 then
			imgVip:setVisible(false)
			nameLabel:setPosition(imgVip:getPosition())
		else
			imgVip:loadTexture(string.format("%svip_icon_%d.png", config.dirUI.common, chatInfo.vipLv))
		end
		imgHead:loadTexture(config.dirUI.heroHeadpic .. chatInfo.srcIcon .. ".png")
		local nameText = chatInfo.srcName
		if string.len(chatInfo.srcUnion)>0 then
		-- 联盟
			nameText = hp.lang.getStrByID(21) .. chatInfo.srcUnion .. hp.lang.getStrByID(22) .. nameText
		end
		if string.len(chatInfo.srcTitle)>0 then
		-- 称号
			nameText = hp.lang.getStrByID(21) .. chatInfo.srcTitle .. hp.lang.getStrByID(22) .. nameText
		end
		if player.serverMgr.getMyServerID()~=chatInfo.srcServerId then
		-- 不同的国家
			local serverInfo = player.serverMgr.getServerBySid(chatInfo.srcServerId)
			nameText = hp.lang.getStrByID(21) .. serverInfo.name .. hp.lang.getStrByID(22) .. nameText
		end
		nameLabel:setString(nameText)
		chatLabel:setString(chatInfo.text)
		timeLabel:setString(os.date("%c", chatInfo.time))

		if needToBottom then
			chatList:refreshView()
			chatList:scrollToBottom(0.2, false)
		end
	end
	self.addChatInfo = addChatInfo

	local chatInfos = player.chatRoom.getChatInfos(chatType, playerId)
	for i,v in ipairs(chatInfos) do
		addChatInfo(v)
	end
	chatList:refreshView()
	chatList:scrollToBottom(0.01, false)

	-- registMsg
	self:registMsg(hp.MSG.CHATINFO_NEW)
end

-- onMsg
function UI_chatRoom_chat:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.CHATINFO_NEW then
		if paramInfo_.type==self.chatType and paramInfo_.id==self.playerId then
			self.addChatInfo(paramInfo_.chat, true)
		end
	end
end

--
--onRemove
function UI_chatRoom_chat:onRemove()
	-- must release
	self.chatModelMe:release()

	self.super.onRemove(self)
end
