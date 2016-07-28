--
-- ui/mainMenu.lua
-- 主菜单
--===================================
require "ui/UI"


UI_mainMenu = class("UI_mainMenu", UI)


--init
function UI_mainMenu:init()
	-- data
	-- ===============================


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainMenu.json")
	local panelFrame = wigetRoot:getChildByName("Panel_frame")
	local panelMenu = wigetRoot:getChildByName("Panel_menu")

	-- 菜单
	local imgMap = panelMenu:getChildByName("ImageView_mapBg"):getChildByName("ImageView_mapIcon")
	local imgQuests = panelMenu:getChildByName("ImageView_quests")
	local imgItems = panelMenu:getChildByName("ImageView_items")
	local imgUnion = panelMenu:getChildByName("ImageView_union")
	local imgMail = panelMenu:getChildByName("ImageView_mail")
	local imgMore = panelMenu:getChildByName("ImageView_more")
	local imgChat = panelMenu:getChildByName("ImageView_chat")
	local labelChat1 = panelMenu:getChildByName("Label_chat1")
	local labelChat2 = panelMenu:getChildByName("Label_chat2")
	self.questNum = imgQuests:getChildByName("ImageView_numbg")
	self.questComplete = imgQuests:getChildByName("Image_ok")

	--
	--
	local itemSelectedBg = panelFrame:getChildByName("Image_itemBg")
	local function selectMenuItem(itemNode)
		if itemNode==nil then
			itemSelectedBg:setVisible(false)
		else
			itemSelectedBg:setVisible(true)
			itemSelectedBg:setPositionX(itemNode:getPositionX())
		end
	end
	local function setMapIconState()
		local mapLv = self.parent.mapLevel
		local uiNum = #self.parent.UIs
		if uiNum==1 then
			if mapLv==1 then
				--
			elseif mapLv==2 then
				imgMap:loadTexture(config.dirUI.common .. "map_icon.png")
			else
				imgMap:loadTexture(config.dirUI.common .. "city_icon.png")
			end
		elseif uiNum==0 then
			if mapLv==1 then
				--
			elseif mapLv==2 then
				imgMap:loadTexture(config.dirUI.common .. "city_icon.png")
			else
				imgMap:loadTexture(config.dirUI.common .. "map_icon.png")
			end
			selectMenuItem(nil)
		end
		
	end
	self.setMapIconState = setMapIconState

	local mapSwitching = false --正在切换地图
	local function memuItemOnTouched(sender, eventType)
		if mapSwitching then
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==imgMap then
				if #self.parent.UIs>0 then
					self:closeAll()
					player.guide.stepEx({4007, 5007})
				else
					local map = nil
					if self.parent.mapLevel==1 then
						require("scene/cityMap")
						map = cityMap.new()
					elseif self.parent.mapLevel==2 then
						require("scene/cityMap")
						map = cityMap.new()
					else
						require("scene/kingdomMap")
						map = kingdomMap.new()
					end
					mapSwitching = true
					map:enter()
				end
				return
			end
			if sender==imgChat then
				require("ui/chat/chatRoom")
				local ui = UI_chatRoom.new()
				self:addModalUI(ui)
				return
			end
			
			self:closeAll()
			selectMenuItem(sender)
			if sender==imgQuests then
				require "ui/quest/questMain"
				ui_ = UI_questMain.new()
				self:addUI(ui_)
				player.guide.step(4002)
			elseif sender==imgItems then
				require("ui/item/shopItem")
				local ui = UI_shopItem.new()
				self:addUI(ui)
				player.guide.step(5002)
			elseif sender==imgUnion then
				if player.getAlliance():getUnionID() == 0 then
					require("ui/union/invite/unionCreate")
					local ui = UI_unionCreate.new()
					self:addUI(ui)
				else
					require "ui/union/unionMain"
					local ui_ = UI_unionMain.new()
					self:addUI(ui_)
				end
			elseif sender==imgMail then
				require("ui/mail/mail")
				local ui = UI_mail.new()
				self:addUI(ui)
			elseif sender==imgMore then
			end
		end
	end

	local function onChatTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/chat/chatRoom")
			local ui = UI_chatRoom.new()
			self:addModalUI(ui)
		end
	end
	imgMap:addTouchEventListener(memuItemOnTouched)
	imgQuests:addTouchEventListener(memuItemOnTouched)
	imgItems:addTouchEventListener(memuItemOnTouched)
	imgUnion:addTouchEventListener(memuItemOnTouched)
	imgMail:addTouchEventListener(memuItemOnTouched)
	imgMore:addTouchEventListener(memuItemOnTouched)
	imgChat:addTouchEventListener(memuItemOnTouched)
	labelChat1:addTouchEventListener(onChatTouched)
	labelChat2:addTouchEventListener(onChatTouched)

	-- mail
	local function setMailInfo()
		local numBg = imgMail:getChildByName("ImageView_numbg")
		local unreadNum = hp.mailCenter.getAllUnreadMailNum()
		if unreadNum>0 then
			numBg:setVisible(true)
			numBg:getChildByName("Label_num"):setString(unreadNum)
		else
			numBg:setVisible(false)
		end
	end
	setMailInfo()
	self.setMailInfo = setMailInfo

	-- 聊天
	local function getChatText(chatInfo)
		local chatTxt = ""
		if string.len(chatInfo.srcUnion)>0 then
			chatTxt = "[" .. chatInfo.srcUnion .. "]" .. chatInfo.srcName .. ": " .. chatInfo.text
		else
			chatTxt = chatInfo.srcName .. ": " .. chatInfo.text
		end

		local chatTxt_ = hp.common.utf8_strSub(chatTxt, 52)
		if string.len(chatTxt_)<string.len(chatTxt) then
			chatTxt_ = chatTxt_ .. "..."
		end

		return chatTxt_
	end
	local function popChatInfo(chatInfo, bAnimation)
		if chatInfo==nil then
			labelChat2:setString("")
		else
			labelChat2:setString(getChatText(chatInfo))
			if bAnimation then
				labelChat2:runAction(cc.Blink:create(3, 6))
			end
		end

		local chatInfo = hp.chatRoom.getPenultChatInfo()
		if chatInfo==nil then
			labelChat1:setString("")
		else
			labelChat1:setString(getChatText(chatInfo))
		end
	end
	popChatInfo(hp.chatRoom.getLastChatInfo())
	self.popChatInfo = popChatInfo
	
	-- 和新手指引界面绑定
	local function bindGuideUI(step)
		if step==4002 then --领任务奖励
			player.guide.bind2Node(step, imgQuests, memuItemOnTouched)
		elseif step==4007 or step==5007 then --回到主程
			player.guide.bind2Node(step, imgMap, memuItemOnTouched)
		elseif step==5002 then --使用道具
			player.guide.bind2Node(step, imgItems, memuItemOnTouched)
		end
	end
	self.bindGuideUI = bindGuideUI


	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)


	-- registMsg
	self:registMsg(hp.MSG.MAIL_CHANGED)
	self:registMsg(hp.MSG.MISSION_DAILY_COLLECTED)
	self:registMsg(hp.MSG.MISSION_DAILY_COMPLETE)
	self:registMsg(hp.MSG.MISSION_MAIN_STATUS_CHANGE)
	self:registMsg(hp.MSG.MISSION_DAILY_RECIEVE_CHANGE)
	self:registMsg(hp.MSG.CHATINFO_NEW)
	self:registMsg(hp.MSG.GUIDE_STEP)
	self:registMsg(hp.MSG.MISSION_DAILY_REFRESH)

	self:updateReceiveTask()
end


--heartbeat
function UI_mainMenu:heartbeat(dt)
end

function UI_mainMenu:updateReceiveTask()
	local receivableNum_ = 0
	for i = 1, 3 do
		for j, v in ipairs(player.getDailyTasks(i)) do
			if v.flag == 3 then
				receivableNum_ = receivableNum_ + 1
			end
		end
	end
	if receivableNum_ > 0 then
		self.questNum:setVisible(true)
		self.questNum:getChildByName("Label_num"):setString(tostring(receivableNum_))
	else
		self.questNum:setVisible(false)
	end

	local num_ = player.getNotCollectedNum()
	if self.questComplete ~= nil then
		if num_ > 0 then
			self.questComplete:setVisible(true)
		else
			self.questComplete:setVisible(false)
		end
	end
end

-- onMsg
function UI_mainMenu:onMsg(msg_, parm_)
	if msg_==hp.MSG.MAIL_CHANGED then
		if parm_.type==7 then
			-- 总未读邮件个数发生变化
			self.setMailInfo()
		end
	elseif msg_ == hp.MSG.MISSION_DAILY_COMPLETE or msg_ == hp.MSG.MISSION_DAILY_COLLECTED or
		msg_ == hp.MSG.MISSION_MAIN_STATUS_CHANGE or msg_ == hp.MSG.MISSION_DAILY_RECIEVE_CHANGE or
		msg_ == hp.MSG.MISSION_DAILY_REFRESH then
		self:updateReceiveTask()
	elseif msg_==hp.MSG.CHATINFO_NEW then
		if hp.chatRoom.getChannelType()==parm_.type or 3==parm_.type then
		--当前频道聊天和私人聊天
			self.popChatInfo(parm_.chat, true)
		end
	elseif msg_==hp.MSG.GUIDE_STEP then
	-- 新手指引
		self.bindGuideUI(parm_)
	end
end