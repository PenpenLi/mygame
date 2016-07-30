--
-- ui/mainMenu.lua
-- 主菜单
--===================================
require "ui/UI"


UI_mainMenu = class("UI_mainMenu", UI)


--init
function UI_mainMenu:init(selectedIndex_)
	-- data
	-- ===============================


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainMenu.json")
	local panelMenu = wigetRoot:getChildByName("Panel_menu")

	-- 菜单
	local imgFudi = panelMenu:getChildByName("ImageView_fudi"):getChildByName("ImageView_itemIcon")	--府邸
	local imgZc = panelMenu:getChildByName("ImageView_zc"):getChildByName("ImageView_itemIcon")	--主城
	local imgZb = panelMenu:getChildByName("ImageView_zb"):getChildByName("ImageView_itemIcon")	--争霸
	local imgZy = panelMenu:getChildByName("ImageView_zy"):getChildByName("ImageView_itemIcon")	--战役
	local imgItems = panelMenu:getChildByName("ImageView_items"):getChildByName("ImageView_itemIcon")	--菜单
	local chatTouchNode = panelMenu:getChildByName("Panel_chatTouch")
	local labelChat1 = panelMenu:getChildByName("Label_chat1")
	local labelChat2 = panelMenu:getChildByName("Label_chat2")

	-- 府邸特效
	require "ui/common/effect.lua"
	self.light = inLight(imgFudi:getVirtualRenderer(),3)
	imgFudi:addChild(self.light)
	self.imgFudi_new = imgFudi:getChildByName("Image_new")
	if player.mansionMgr.isLight() then
		self.light:setVisible(true)
		self.imgFudi_new:setVisible(true)
	else
		self.light:setVisible(false)
		self.imgFudi_new:setVisible(false)
	end

	-- 争霸地图特效
	self.conflictLight = inLight(imgZb:getVirtualRenderer(),4)
	self.conflictLight:setVisible(false)
	imgZb:addChild(self.conflictLight)
	self.imgZb_new = imgZb:getChildByName("Image_new")
	local function conflictShow()
		if self.conflictLight == nil then
			return
		end

		if game.curScene == nil then
			return
		end

		if game.curScene.mapLevel == 2 then
			self.conflictLight:setVisible(false)
		end

		local show_ = player.marchMgr.getConflict()
		self.conflictLight:setVisible(show_)
		self.imgZb_new:setVisible(show_)
	end
	self.conflictShow = conflictShow
	conflictShow()
	
	--
	-- 菜单选中效果
	local itemSelectedBg = panelMenu:getChildByName("Image_selected")
	local curItem = nil
	local function selectMenuItem(itemNode)
		curItem = itemNode
		itemSelectedBg:setPositionX(itemNode:getParent():getPositionX())
	end

	if selectedIndex_==1 then
		selectMenuItem(imgFudi)
	elseif selectedIndex_==2 then
		selectMenuItem(imgZc)
	elseif selectedIndex_==3 then
		selectMenuItem(imgZb)
	elseif selectedIndex_==4 then
		selectMenuItem(imgZy)
	elseif selectedIndex_==5 then
		selectMenuItem(imgItems)
	end

	local function recheckSelectMenu()
		if game.curScene.mapLevel==3 then
			selectMenuItem(imgZc)
		elseif game.curScene.mapLevel==2 then
			selectMenuItem(imgZb)
		end
	end
	self.recheckSelectMenu = recheckSelectMenu

	local mapSwitching = false --正在切换地图
	local function memuItemOnTouched(sender, eventType)
		if mapSwitching then
			return
		end
		local tick_ = os.clock()
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==imgFudi then
				if game.curScene.mapLevel==3 then
					self:closeAll()
					require("ui/mansion/mansion")
					local ui = UI_mansion.new()
					self:addUI(ui)
				else
					mapSwitching = true
					require("scene/cityMap")
					local map = cityMap.new(true)
					map:enter()
				end
				player.guide.stepEx({2002, 4001, 7007})
			elseif sender==imgZc then
				if game.curScene.mapLevel==3 then
					if curItem~=imgZc then
						game.curScene:onEnterAnim()
					end
					self:closeAll()
				else
					mapSwitching = true
					require("scene/cityMap")
					local map = cityMap.new()
					map:enter()
				end
			elseif sender==imgZb then
				if game.curScene.mapLevel==2 then
					self:closeAll()
					if curItem~=imgZb then
						game.curScene:onEnterAnim()
					end
				else
					mapSwitching = true
					require("scene/kingdomMap")
					local map = kingdomMap.new()
					map:enter()
				end
			elseif sender==imgZy then
				if curItem ~= imgZy then
					self:closeAll()
					require "ui/copy/copyMainNew"
					local ui_ = UI_copyMainNew.new()
					self:addUI(ui_)
				end
			elseif sender==imgItems then
				self:closeAll()
				require("ui/mainMenuMore")
				local ui = UI_mainMenuMore.new()
				self:addUI(ui)
			end
			selectMenuItem(sender)
		end
		player.clockEnd("memuItemOnTouched", tick_, 0.3)
	end

	local function onChatTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:closeAll()
			require("ui/chat/chatRoom")
			local ui = UI_chatRoom.new()
			self:addModalUI(ui)
		end
	end
	imgFudi:addTouchEventListener(memuItemOnTouched)
	imgZc:addTouchEventListener(memuItemOnTouched)
	imgZy:addTouchEventListener(memuItemOnTouched)
	imgZb:addTouchEventListener(memuItemOnTouched)
	imgItems:addTouchEventListener(memuItemOnTouched)
	chatTouchNode:addTouchEventListener(onChatTouched)

	-- 聊天
	local colorArea = cc.c3b(255, 255, 255) --区域聊天颜色
	local colorUnion = cc.c3b(0, 255, 240) --联盟聊天颜色
	local colorPm = cc.c3b(19, 235, 24) --私聊聊天颜色
	local colorEnemy = cc.c3b(255, 83, 83) --敌国聊天颜色
	local titleArea = hp.lang.getStrByID(3613)
	local titleUnion = hp.lang.getStrByID(3614)
	local titlePm = hp.lang.getStrByID(3629)
	local function getChatText(chatInfo)
		local chatTxt = ""
		local color = nil
		if string.len(chatInfo.srcUnion)>0 then
			chatTxt = hp.lang.getStrByID(21) .. chatInfo.srcUnion .. hp.lang.getStrByID(22) .. chatInfo.srcName .. ": " .. chatInfo.text
		else
			chatTxt = chatInfo.srcName .. ": " .. chatInfo.text
		end

		local chatTxt_ = hp.common.utf8_strSub(chatTxt, 52)
		if string.len(chatTxt_)<string.len(chatTxt) then
			chatTxt_ = chatTxt_ .. "..."
		end

		if chatInfo.type==4 then
		-- 联盟
			chatTxt = "[" .. titleUnion .. "]" .. chatTxt_
			color = colorUnion
		elseif chatInfo.type==5 then
		-- 私聊
			chatTxt = "[" .. titlePm .. "]" .. chatTxt_
			color = colorPm
		else
		-- 区域
			chatTxt = "[" .. titleArea .. "]" .. chatTxt_
			if chatInfo.srcServerId~=player.serverMgr.getMyServerID() then
				color = colorEnemy
			else
				color = colorArea
			end
		end

		return color, chatTxt
	end
	local function popChatInfo(chatInfo, bAnimation)
		if chatInfo==nil then
			labelChat2:setString("")
		else
			local color, txt = getChatText(chatInfo)
			labelChat2:setColor(color)
			labelChat2:setString(txt)
			if bAnimation then
				local function blinkEnd()
					labelChat2:setVisible(true)
				end
				labelChat2:stopAllActions()
				labelChat2:runAction(cc.Sequence:create(cc.Blink:create(3, 6), cc.CallFunc:create(blinkEnd)))
			end
		end

		local chatInfo = player.chatRoom.getPenultChatInfo()
		if chatInfo==nil then
			labelChat1:setString("")
		else
			local color, txt = getChatText(chatInfo)
			labelChat1:setColor(color)
			labelChat1:setString(txt)
		end
	end
	popChatInfo(player.chatRoom.getLastChatInfo())
	self.popChatInfo = popChatInfo
	
	-- 和新手指引界面绑定
	local function bindGuideUI(step)
		if step==2002 or step==4001 or step==7007  then --返回府邸
			player.guide.bind2Node(step, imgFudi, memuItemOnTouched)
		elseif step==7003 then --返回府邸
			player.guide.bind2Node(step, imgZy, memuItemOnTouched)
		end
	end
	self.bindGuideUI = bindGuideUI

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)

	-- registMsg
	self:registMsg(hp.MSG.CHATINFO_NEW)
	self:registMsg(hp.MSG.GUIDE_STEP)
	self:registMsg(hp.MSG.MAIN_MENU_MANSION_LIGHT)
	self:registMsg(hp.MSG.MARCH_MANAGER)
end

-- onMsg
function UI_mainMenu:onMsg(msg_, parm_)
	if msg_==hp.MSG.CHATINFO_NEW then
		if 6~=parm_.type then
		-- 不是系统公告
			self.popChatInfo(parm_.chat, true)
		end
	elseif msg_==hp.MSG.GUIDE_STEP then
	-- 新手指引
		self.bindGuideUI(parm_)
	elseif msg_ == hp.MSG.MAIN_MENU_MANSION_LIGHT then
		self.light:setVisible(parm_)
		self.imgFudi_new:setVisible(parm_)
	elseif msg_ == hp.MSG.MARCH_MANAGER then
		if parm_ == nil then
			return
		end
		if parm_.msgType == 1 then
			self.conflictShow()
		end
	end
end