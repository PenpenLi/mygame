--
-- ui/chat/chatRoom_invites.lua
-- 聊天室好友搜索界面
--===================================
require "ui/fullScreenFrame"


UI_chatRoom_invites = class("UI_chatRoom_search", UI)


--init
function UI_chatRoom_invites:init()
	-- data
	-- ===============================
	local friendMgr = player.friendMgr
	local recvNum = 0
	local sendNum = 0

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "chatRoom_invites.json")

	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)


	--
	local invitesList = widgetRoot:getChildByName("ListView_invites")
	local titleItem = invitesList:getItem(0)
	local recvItem = invitesList:getItem(1):clone()
	local sendItem = invitesList:getItem(2):clone()
	recvItem:retain()
	sendItem:retain()
	self.recvItem = recvItem
	self.sendItem = sendItem

	invitesList:removeItem(2)
	invitesList:removeItem(1)
	local function onAccept(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local fInfo = friendMgr.getFriendInfo(sender:getTag(), 2)
			friendMgr.acceptInvite(fInfo.id)
		end
	end
	local function onRefuse(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local fInfo = friendMgr.getFriendInfo(sender:getTag(), 2)
			friendMgr.refuseInvite(fInfo.id)
		end
	end
	local function addRecvItem(fInfo)
			local item = recvItem:clone()
			item:setTag(fInfo.localId)
			local itemCont = item:getChildByName("Panel_cont")
			local headImg = itemCont:getChildByName("Image_head")
			local nameLabel = itemCont:getChildByName("Label_name")
			local uinonLabel = itemCont:getChildByName("Label_uinon")
			local timeLabel = itemCont:getChildByName("Label_time")
			local btnAccept = itemCont:getChildByName("Image_accept")
			local btnRefuse = itemCont:getChildByName("Image_refuse")
			nameLabel:setString(string.format(hp.lang.getStrByID(3625), fInfo.name))
			uinonLabel:setString(string.format(hp.lang.getStrByID(3626), fInfo.union))
			timeLabel:setString(os.date(hp.lang.getStrByID(3627), fInfo.time))
			btnAccept:setTag(fInfo.localId)
			btnRefuse:setTag(fInfo.localId)
			btnAccept:addTouchEventListener(onAccept)
			btnRefuse:addTouchEventListener(onRefuse)

			invitesList:insertCustomItem(item, recvNum+1)
			recvNum = recvNum+1
	end
	local function addSendItem(fInfo)
		local item = sendItem:clone()
		item:setTag(fInfo.localId)
		local itemCont = item:getChildByName("Panel_cont")
		local headImg = itemCont:getChildByName("Image_head")
		local nameLabel = itemCont:getChildByName("Label_name")
		if string.len(fInfo.union)>0 then
			nameLabel:setString(string.format("(%s)%s", fInfo.union, fInfo.name))
		else
			nameLabel:setString(fInfo.name)
		end
		invitesList:pushBackCustomItem(item)
		sendNum = sendNum+1
	end
	local function deleteRecvItem(fInfo)
		local itemNode = invitesList:getChildByTag(fInfo.localId)
		if itemNode~=nil then
			invitesList:removeItem(invitesList:getIndex(itemNode))
			recvNum = recvNum-1
		end
	end
	local function deleteSendItem(fInfo)
		local itemNode = invitesList:getChildByTag(fInfo.localId)
		if itemNode~=nil then
			invitesList:removeItem(invitesList:getIndex(itemNode))
			sendNum = sendNum-1
		end
	end
	self.addRecvItem = addRecvItem
	self.deleteRecvItem = deleteRecvItem
	self.addSendItem = addSendItem
	self.deleteSendItem = deleteSendItem

	local function setRecvInvites() 
		titleItem:setTag(0)
		titleItem:getChildByName("Panel_cont"):getChildByName("Label_title"):setString(hp.lang.getStrByID(3621))
		local friends = friendMgr.getFriends(2)
		for i, fInfo in ipairs(friends) do
			addRecvItem(fInfo)
		end
	end
	local function setSendInvites()
		local itemTmp = titleItem:clone()
		itemTmp:setTag(0)
		itemTmp:getChildByName("Panel_cont"):getChildByName("Label_title"):setString(hp.lang.getStrByID(3622))
		invitesList:pushBackCustomItem(itemTmp)

		local friends = friendMgr.getFriends(3)
		for i, fInfo in ipairs(friends) do
			addSendItem(fInfo)
		end
	end
	setRecvInvites()
	setSendInvites()

	-- registMsg
	self:registMsg(hp.MSG.FRIEND_MGR)
end

-- onMsg
function UI_chatRoom_invites:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.FRIEND_MGR then
		if paramInfo_.oper==1 then
			if paramInfo_.type==2 then
				self.addRecvItem(paramInfo_.fInfo)
			elseif paramInfo_.type==3 then
				self.addSendItem(paramInfo_.fInfo)
			end
		elseif paramInfo_.oper==2 then
			if paramInfo_.type==2 then
				self.deleteRecvItem(paramInfo_.fInfo)
			elseif paramInfo_.type==3 then
				self.deleteSendItem(paramInfo_.fInfo)
			end
		end
	end
end

--
--onRemove
function UI_chatRoom_invites:onRemove()
	-- must release
	self.recvItem:release()
	self.sendItem:release()

	self.super.onRemove(self)
end