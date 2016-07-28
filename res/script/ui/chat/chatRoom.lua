--
-- ui/chat/chatRoom.lua
-- 聊天主界面
--===================================
require "ui/fullScreenFrame"

UI_chatRoom = UI_chatRoom or class("UI_chatRoom", UI)


--
UI_chatRoom.g_uiType = UI_chatRoom.g_uiType or 1
UI_chatRoom.g_param1 = UI_chatRoom.g_param1 or 1
UI_chatRoom.g_param2 = UI_chatRoom.g_param2


--init
function UI_chatRoom:init()
	-- data
	-- ===============================
	local friendMgr = player.friendMgr

	local curUIType = 1
	local curChildUI = nil
	self.folderState = false
	self.tickCount = 0
	-- fun
	local loadFriendList

	if hp.chatRoom.getChannelType()==1 then
		UI_chatRoom.g_uiType = 1
		UI_chatRoom.g_param1 = 1
		UI_chatRoom.g_param2 = nil
	end

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "chatRoom.json")

	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)

	-- tab
	local panelCont = widgetRoot:getChildByName("Panel_cont")
	local tabArea = panelCont:getChildByName("ImageView_tabArea")
	local tabAreaTxt = tabArea:getChildByName("Label_name")
	local tabUnion = panelCont:getChildByName("ImageView_tabUnion")
	local tabUnionTxt = tabUnion:getChildByName("Label_name")
	tabAreaTxt:setString(hp.lang.getStrByID(3613))
	tabUnionTxt:setString(hp.lang.getStrByID(3614))
	local sScaleX = tabArea:getScaleX()
	local sScaleY = tabArea:getScaleY()
	local sColor = tabArea:getColor()
	local nScaleX = tabUnion:getScaleX()
	local nScaleY = tabUnion:getScaleY()
	local nColor = tabUnion:getColor()
	local curTab = 1
	local function setCurTab(tab)
		if curTab==1 then
			tabArea:setScaleX(nScaleX)
			tabArea:setScaleY(nScaleY)
			tabArea:setColor(nColor)
			tabAreaTxt:setColor(nColor)
			tabArea:setTouchEnabled(true)
		elseif curTab==2 then
			tabUnion:setScaleX(nScaleX)
			tabUnion:setScaleY(nScaleY)
			tabUnion:setColor(nColor)
			tabUnionTxt:setColor(nColor)
			tabUnion:setTouchEnabled(true)
		end

		curTab = tab
		if curTab==1 then
			tabArea:setScaleX(sScaleX)
			tabArea:setScaleY(sScaleY)
			tabArea:setColor(sColor)
			tabAreaTxt:setColor(sColor)
			tabArea:setTouchEnabled(false)
		elseif curTab==2 then
			tabUnion:setScaleX(sScaleX)
			tabUnion:setScaleY(sScaleY)
			tabUnion:setColor(sColor)
			tabUnionTxt:setColor(sColor)
			tabUnion:setTouchEnabled(false)
		end
	end
	-- 好友面板
	local leftCont = widgetRoot:getChildByName("Panel_leftCont")
	local leftSz = leftCont:getSize()
	local onLineLable = leftCont:getChildByName("Image_numbg"):getChildByName("Label_num")
	onLineLable:setString(0)
	local reqNumBg = leftCont:getChildByName("Image_numbg_req")
	local reqLable = reqNumBg:getChildByName("Label_num")
	reqNumBg:setVisible(false)
	leftCont:getChildByName("Label_title"):setString(hp.lang.getStrByID(3607))
	leftCont:getChildByName("Label_friends"):setString(hp.lang.getStrByID(3607))
	leftCont:getChildByName("Label_online"):setString(hp.lang.getStrByID(3608))
	leftCont:getChildByName("Label_add"):setString(hp.lang.getStrByID(3609))
	leftCont:getChildByName("Label_requests"):setString(hp.lang.getStrByID(3610))

	-- 设置折叠状态
	local function setFolderState(state)
		self.folderState = state
		if self.folderState then
			widgetRoot:setPosition(leftSz.width, 0)
			curChildUI.layer:setPosition(leftSz.width, 0)
			loadFriendList()
		else
			widgetRoot:setPosition(0, 0)
			curChildUI.layer:setPosition(0, 0)
		end
	end

	-- 设置子界面
	local titleIcon = panelCont:getChildByName("Image_icon")
	local titleTxt = panelCont:getChildByName("Label_text")
	local settingBtn = panelCont:getChildByName("Image_settingBtn")
	local function setChildUI(uiType, param1, param2)
		if (uiType==2 or uiType==3) and uiType==curUIType then
			setFolderState(false)
			return
		end

		if curChildUI~=nil then
			self:removeChildUI(curChildUI)
		end

		if uiType==1 then
		--聊天
			UI_chatRoom.g_uiType = uiType
			UI_chatRoom.g_param1 = param1
			UI_chatRoom.g_param2 = param2
			
			if param1==1 then
			--区域聊天
				hp.chatRoom.setChannelType(1)
				setCurTab(1)
				titleIcon:loadTexture(config.dirUI.common .. "chat_province_a_icon.png")
				titleIcon:setScale(1)
				titleTxt:setString("我的区域")
				settingBtn:setVisible(false)
				require "ui/chat/chatRoom_chat"
				curChildUI = UI_chatRoom_chat.new(1)
			elseif param1==2 then
			--公会聊天
				hp.chatRoom.setChannelType(2)
				setCurTab(2)
				titleIcon:loadTexture(config.dirUI.icon .. "9.png")
				titleIcon:setScale(1)
				titleTxt:setString("我的公会")
				settingBtn:setVisible(true)
				require "ui/chat/chatRoom_chat"
				curChildUI = UI_chatRoom_chat.new(2)
			else
			--私聊
				setCurTab(0)
				titleIcon:loadTexture(config.dirUI.heroHeadpic .. param2.icon .. ".png")
				titleIcon:setScale(0.5)
				if string.len(param2.union)>0 then
					titleTxt:setString("[" .. param2.union .. "]" .. param2.name)
				else
					titleTxt:setString(param2.name)
				end
				settingBtn:setVisible(false)
				require "ui/chat/chatRoom_chat"
				curChildUI = UI_chatRoom_chat.new(3, param2)
			end
		elseif uiType==2 then
		-- 搜索
			setCurTab(0)
			titleIcon:loadTexture(config.dirUI.common .. "chaticon_addFriend.png")
			titleIcon:setScale(1)
			titleTxt:setString(hp.lang.getStrByID(3609))
			settingBtn:setVisible(false)
			require "ui/chat/chatRoom_search"
			curChildUI = UI_chatRoom_search.new()
		elseif uiType==3 then
		-- 好友邀请
			setCurTab(0)
			titleIcon:loadTexture(config.dirUI.common .. "chaticon_wait.png")
			titleIcon:setScale(1)
			titleTxt:setString(hp.lang.getStrByID(3610))
			settingBtn:setVisible(false)
			require "ui/chat/chatRoom_invites"
			curChildUI = UI_chatRoom_invites.new()
		end

		setFolderState(false)
		self:addChildUI(curChildUI)
		curUIType = uiType
	end
	setChildUI(UI_chatRoom.g_uiType, UI_chatRoom.g_param1, UI_chatRoom.g_param2)
	
	local function onTabTouched(sender, eventType)
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(sColor)
			sender:getChildByName("Label_name"):setColor(sColor)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(sColor)
				sender:getChildByName("Label_name"):setColor(sColor)
			else
				sender:setColor(nColor)
				sender:getChildByName("Label_name"):setColor(nColor)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			setChildUI(1, sender:getTag())
		end
	end
	tabArea:addTouchEventListener(onTabTouched)
	tabUnion:addTouchEventListener(onTabTouched)

	-- btn
	--------------------------------------
	local btnFold = panelCont:getChildByName("Image_friendlistBtn")
	local btnClose = panelCont:getChildByName("Image_closeBtn")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnClose then
				self:close()
			elseif sender==btnFold then
				setFolderState(not self.folderState)
			end
		end
	end
	btnFold:addTouchEventListener(onBtnTouched)
	btnClose:addTouchEventListener(onBtnTouched)

	--好友列表
	-------------------------------------
	local friendList = widgetRoot:getChildByName("ListView_friends")
	local friendItemModel = friendList:getItem(0)
	friendItemModel:getChildByName("Panel_cont"):getChildByName("Label_delete"):setString(hp.lang.getStrByID(1848))
	friendList:setItemModel(friendItemModel)
	friendList:removeAllItems()

	local totalNum = 0 
	local onLineNum = 0
	local friendLoaded = false
	--设置好友信息
	local operItem = nil
	local isMoved = false
	local function onDeleteBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local fInfo = friendMgr.getFriendInfo(sender:getTag(), 1)
			friendMgr.sendDelete(fInfo.id)
		end
	end
	local function onFriendItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_BEGAN then
			isMoved = false
		elseif eventType==TOUCH_EVENT_MOVED then
			if isMoved then
				return
			else
				isMoved = true
			end

			if operItem~=nil then
				local deleteBtn = operItem:getChildByName("Image_delete")
				local deleteLable = operItem:getChildByName("Label_delete")
				deleteBtn:setVisible(false)
				deleteLable:setVisible(false)
				deleteBtn:setTouchEnabled(false)
				if operItem==sender then
					operItem=nil
					return
				end
			end
			operItem = sender
			local deleteBtn = operItem:getChildByName("Image_delete")
			local deleteLable = operItem:getChildByName("Label_delete")
			deleteBtn:setVisible(true)
			deleteLable:setVisible(true)
			deleteBtn:setTouchEnabled(true)
			deleteBtn:setTag(sender:getTag())
			deleteBtn:addTouchEventListener(onDeleteBtnTouched)
		elseif eventType==TOUCH_EVENT_ENDED then
			if not isMoved then
				local fInfo = friendMgr.getFriendInfo(sender:getTag(), 1)
				setChildUI(1, 3, fInfo)
			end
		else
		end
	end

	local function setFriendInfo(node, friendInfo)
		local nodeCont = node:getChildByName("Panel_cont")
		node:setTag(friendInfo.localId)
		nodeCont:setTag(friendInfo.localId)
		nodeCont:addTouchEventListener(onFriendItemTouched)
		
		if friendInfo.onlineFlag then
			nodeCont:getChildByName("Image_online"):loadTexture(config.dirUI.common .. "online_icon.png")
		else
			nodeCont:getChildByName("Image_online"):loadTexture(config.dirUI.common .. "offline_icon.png")
		end
		if string.len(friendInfo.union)>0 then
			nodeCont:getChildByName("Label_name"):setString("[" .. friendInfo.union .. "]" .. friendInfo.name)
		else
			nodeCont:getChildByName("Label_name"):setString(friendInfo.name)
		end
	end
	--加载好友列表
	local function addFriendItem(friendInfo)
		if not friendLoaded then
			return
		end

		if friendInfo.onlineFlag then
		-- 在线的放置到前面
			friendList:insertDefaultItem(onLineNum)
			itemNode = friendList:getItem(onLineNum)
			setFriendInfo(itemNode, friendInfo)
			onLineNum = onLineNum+1
			onLineLable:setString(onLineNum)
		else
			friendList:pushBackDefaultItem()
			itemNode = friendList:getItem(totalNum)
			setFriendInfo(itemNode, friendInfo)
		end
		totalNum = totalNum+1
	end
	local function deleteFriendItem(friendInfo)
		if not friendLoaded then
			return
		end

		local itemNode = friendList:getChildByTag(friendInfo.localId)
		if itemNode~=nil then
			if operItem~=nil and operItem:getTag()==friendInfo.localId then
				operItem = nil
			end
			friendList:removeItem(friendList:getIndex(itemNode))
			if friendInfo.onlineFlag then
				onLineNum = onLineNum-1
				onLineLable:setString(onLineNum)
			end
			totalNum = totalNum-1

		end
	end
	self.addFriendItem = addFriendItem
	self.deleteFriendItem = deleteFriendItem

	function loadFriendList()
		self.tickCount = 0
		friendMgr.friendSync()
		if friendLoaded then
			return
		else
			friendLoaded = true
		end

		local friends = friendMgr.getFriends(1)
		local itemNode = nil
		for i, friendInfo in ipairs(friends) do
			addFriendItem(friendInfo)
		end
	end

	-- 设置未处理邀请个数
	local function getRecvInviteNum()
		local num = table.getn(friendMgr.getFriends(2))
		if num>0 then
			reqNumBg:setVisible(true)
			reqLable:setString(num)
		else
			reqNumBg:setVisible(false)
		end
		
	end
	getRecvInviteNum()
	self.getRecvInviteNum = getRecvInviteNum


	-- 搜索好友、好友邀请
	------------------------------------
	local leftFrame = widgetRoot:getChildByName("Panel_leftFrame")
	local addFriendBg = leftFrame:getChildByName("Image_titleBg2")
	local invitesBg = leftFrame:getChildByName("Image_titleBg3")
	local function onBgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==addFriendBg then
				setChildUI(2)
			elseif sender==invitesBg then
				setChildUI(3)
			end
		end
	end
	addFriendBg:addTouchEventListener(onBgTouched)
	invitesBg:addTouchEventListener(onBgTouched)

	-- registMsg
	self:registMsg(hp.MSG.FRIEND_MGR)
end

-- onMsg
function UI_chatRoom:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.FRIEND_MGR then
		if paramInfo_.oper==1 then
		-- 添加
			if paramInfo_.type==1 then
			--好友
				self.addFriendItem(paramInfo_.fInfo)
			elseif paramInfo_.type==2 then
			--邀请
				self.getRecvInviteNum()
			end
		elseif paramInfo_.oper==2 then
		-- 删除
			if paramInfo_.type==1 then
			--好友
				self.deleteFriendItem(paramInfo_.fInfo)
			elseif paramInfo_.type==2 then
			--邀请
				self.getRecvInviteNum()
			end
		end
	end
end

-- heartbeat
function UI_chatRoom:heartbeat(dt)
	self.tickCount = self.tickCount+dt
	if self.tickCount>10 then
		self.tickCount = 0
		player.friendMgr.friendSync()
	end
end
