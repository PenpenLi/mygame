--
-- ui/mainMenu.lua
-- 主菜单
--===================================
require "ui/UI"


UI_mainMenu = class("UI_mainMenu", UI)


--init
function UI_mainMenu:init(mapScene_)
	-- data
	-- ===============================

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainMenu.json")

	-- 菜单
	local panelMenu = widgetRoot:getChildByName("Panel_menu")
	local imgScene = panelMenu:getChildByName("ImageView_scene")
	local imgGuide = panelMenu:getChildByName("ImageView_guide")
	local imgUnion = panelMenu:getChildByName("ImageView_union")
	local imgMail = panelMenu:getChildByName("ImageView_mail")
	local imgBattle = panelMenu:getChildByName("ImageView_battle")
	local imgMore = panelMenu:getChildByName("ImageView_more")
	local iconScene = imgScene:getChildByName("ImageView_itemIcon")		--城池/地图切换
	local iconGuide = imgGuide:getChildByName("ImageView_itemIcon")		--指引
	local iconUnion = imgUnion:getChildByName("ImageView_itemIcon")		--联盟
	local iconMail = imgMail:getChildByName("ImageView_itemIcon")		--邮件
	local iconBattle = imgBattle:getChildByName("ImageView_itemIcon")	--战役
	local iconMore = imgMore:getChildByName("ImageView_itemIcon")		--菜单

	-- 重设菜单内容，提供打开关闭界面时使用
	local itemSelectedBg = panelMenu:getChildByName("Image_selected")-- 菜单选中效果
	local iconType = 0 --1:城内, 2:地图
	local function reset()
		local typeTmp = 1
		if mapScene_.mapLevel==1 then
		-- 世界地图
			typeTmp = 2
		elseif mapScene_.mapLevel==2 then
		-- 争霸地图
			if #mapScene_.UIs>0 then
				typeTmp = 2
			else
				typeTmp = 1
			end
		elseif mapScene_.mapLevel==3 then
		-- 城市地图
			if #mapScene_.UIs>0 then
				typeTmp = 1
			else
				typeTmp = 2
			end
		end

		if iconType~=typeTmp then
			iconType = typeTmp
			if iconType==1 then
				iconScene:loadTexture(config.dirUI.common .. "menu_city.png")
			elseif iconType==2 then
				iconScene:loadTexture(config.dirUI.common .. "menu_map.png")
			end

			if self.checkMapLight then
			-- 检查行军冲突
				self.checkMapLight()
			end
		end

		if #mapScene_.UIs<=0 then
		-- 如果关闭了所有界面，将选中背景隐藏
			itemSelectedBg:setVisible(false)
		end
	end
	self.reset = reset
	reset()


	local mapSwitching = false
	local function memuItemOnTouched(sender, eventType)
		if mapSwitching then
		--正在切换地图, 不在响应点击事件
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==iconScene then
			-- 场景切换的图标
				if #mapScene_.UIs>0 then
				-- 如果有界面打开，关闭所有打开的界面
					self:closeAll()
				else
				-- 切换场景
					mapSwitching = true
					if mapScene_.mapLevel==1 then
					-- 在世界地图，进入王国地图
						require("scene/kingdomMap")
						local map = kingdomMap.new()
						map:enter()
					elseif mapScene_.mapLevel==2 then
					-- 在王国地图，进入城内地图
						require("scene/cityMap")
						local map = cityMap.new()
						map:enter()
					elseif mapScene_.mapLevel==3 then
					-- 在城内地图，进入王国地图
						require("scene/kingdomMap")
						local map = kingdomMap.new()
						map:enter()
					end
				end

				player.guide.stepEx({7007})
			else
				self:closeAll()
				-- 选中菜单
				itemSelectedBg:setVisible(true)
				itemSelectedBg:setPosition(sender:getParent():getPosition())

				if sender==iconGuide then
					require("ui/guidance/guidance")
					local ui = UI_Guidance.new()
					self:addUI(ui)

					player.guide.stepEx({2002, 4005})
				elseif sender==iconUnion then
					if player.getAlliance():getUnionID() == 0 then
						require("ui/union/invite/unionCreate")
						local ui = UI_unionCreate.new()
						self:addUI(ui)
					else
						player.postmanAndEnvoyMgr.setEnvoyIsClick(true)
						player.postmanAndEnvoyMgr.setEnvoyIsLight(false)
						local warnum = player.getAlliance():getUnionHomePageInfo().unionWar
						if warnum == nil then
							warnum = 0
						end
						player.postmanAndEnvoyMgr.setCurUnionWarNum(warnum)
						
						self.checkUnionLight()

						require "ui/union/unionMain"
						local ui_ = UI_unionMain.new()
						self:addUI(ui_)
					end
				elseif sender==iconMail then
					player.postmanAndEnvoyMgr.setPostmanIsClick(true)
					player.postmanAndEnvoyMgr.setPostmanIsLight(false)
					player.postmanAndEnvoyMgr.setCurMailNum(player.mailCenter.getAllUnreadMailNum())
					self.checkMailLight()

					require("ui/mail/mail")
					local ui = UI_mail.new()
					self:addUI(ui)
				elseif sender==iconBattle then
					require "ui/copy/copyMainNew"
					local ui_ = UI_copyMainNew.new()
					self:addUI(ui_)
				elseif sender==iconMore then
					require("ui/mainMenuMore")
					local ui = UI_mainMenuMore.new()
					self:addUI(ui)
				end
			end
		end
	end
	iconScene:addTouchEventListener(memuItemOnTouched)
	iconGuide:addTouchEventListener(memuItemOnTouched)
	iconUnion:addTouchEventListener(memuItemOnTouched)
	iconMail:addTouchEventListener(memuItemOnTouched)
	iconBattle:addTouchEventListener(memuItemOnTouched)
	iconMore:addTouchEventListener(memuItemOnTouched)

	-- 提醒特效
	-- =================
	require "ui/common/effect.lua"
	-- 引导特效
	local guideNoticeImg = imgGuide:getChildByName("Image_notice")
	local guideLight = nil
	local function checkGuideLight(needLight_)
		local needLight = false
		if needLight_~=nil then
			needLight = needLight_
		else
			needLight = player.mansionMgr.isLight()
		end

		if needLight then
			if guideLight==nil then
				guideNoticeImg:setVisible(true)
				guideLight = inLight(iconGuide:getVirtualRenderer(), 3)
				iconGuide:addChild(guideLight)
			end
		else
			if guideLight~=nil then
				guideNoticeImg:setVisible(false)
				iconGuide:removeChild(guideLight)
				guideLight = nil
			end
		end
	end
	self.checkGuideLight = checkGuideLight
	checkGuideLight()

	-- 行军冲突特效
	local mapNoticeImg = imgScene:getChildByName("Image_notice")
	local mapLight = nil
	local function checkMapLight()
		if iconType==2 and player.marchMgr.getConflict() then
		-- 行军冲突
			if mapLight==nil then
				mapNoticeImg:setVisible(true)
				mapLight = inLight(iconScene:getVirtualRenderer(), 3)
				iconScene:addChild(mapLight)
			end 
		else
			if mapLight~=nil then
				mapNoticeImg:setVisible(false)
				iconScene:removeChild(mapLight)
				mapLight = nil
			end
		end
	end
	self.checkMapLight = checkMapLight
	checkMapLight()

	-- 联盟战争
	local unionWarNoticeImg = imgUnion:getChildByName("Image_notice")
	local unionLight = nil
	local frist_ = true
	local function checkUnionLight()
		local isFlash
		if frist_ then
			frist_ = false
			isFlash = player.postmanAndEnvoyMgr.getEnvoyIsLightOnInit()
		else
			isFlash = player.postmanAndEnvoyMgr.getEnvoyIsLightOnMsg()
		end

		if isFlash then
			if unionLight==nil then
				unionWarNoticeImg:setVisible(true)
				unionLight = inLight(iconUnion:getVirtualRenderer(), 3)
				iconUnion:addChild(unionLight)
			end
		else
			if unionLight~=nil then
				unionWarNoticeImg:setVisible(false)
				iconUnion:removeChild(unionLight)
				unionLight = nil
			end
		end
	end
	self.checkUnionLight = checkUnionLight
	checkUnionLight()

	-- 邮件特效
	local mailNoticeImg = imgMail:getChildByName("Image_notice")
	local mailLight = nil
	local frist = true
	local function checkMailLight()
		local isFlash
		if frist then
			frist = false
			isFlash = player.postmanAndEnvoyMgr.getPostmanIsLightOnInit()
		else
			isFlash = player.postmanAndEnvoyMgr.getPostmanIsLightOnMsg()
		end

		if isFlash then
		-- 有未读邮件
			if mailLight==nil then
				mailNoticeImg:setVisible(true)
				mailLight = inLight(iconMail:getVirtualRenderer(), 3)
				iconMail:addChild(mailLight)
			end 
		else
			if mailLight~=nil then
				mailNoticeImg:setVisible(false)
				iconMail:removeChild(mailLight)
				mailLight = nil
			end
		end
	end
	self.checkMailLight = checkMailLight
	checkMailLight()


	-- 聊天
	-- ================
	local chatPanel = widgetRoot:getChildByName("Panel_chat")
	local labelChat1 = chatPanel:getChildByName("Label_chat1")
	local labelChat2 = chatPanel:getChildByName("Label_chat2")

	local function onChatTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:closeAll()
			require("ui/chat/chatRoom")
			local ui = UI_chatRoom.new()
			self:addModalUI(ui)
		end
	end
	chatPanel:addTouchEventListener(onChatTouched)

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
	
	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)

	-- registMsg
	self:registMsg(hp.MSG.CHATINFO_NEW)
	self:registMsg(hp.MSG.MAIN_MENU_MANSION_LIGHT)
	self:registMsg(hp.MSG.MARCH_MANAGER)
	self:registMsg(hp.MSG.MAIL_CHANGED)
	self:registMsg(hp.MSG.UNION_DATA_PREPARED)


	-- 和新手指引界面绑定
	-- ======================
	local function bindGuideUI(step)
		if step==2002 or step==4005 then --指向引导
			player.guide.bind2Node(step, iconGuide, memuItemOnTouched)
		elseif step==7003 then --指向战役
			player.guide.bind2Node(step, iconBattle, memuItemOnTouched)
		elseif step==7007 then --指向城池
			player.guide.bind2Node(step, iconScene, memuItemOnTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
	self:registMsg(hp.MSG.GUIDE_STEP)
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
		self.checkGuideLight(parm_)
	elseif msg_ == hp.MSG.MARCH_MANAGER then
		if parm_ == nil then
			return
		end
		if parm_.msgType == 1 then
			self.checkMapLight()
		end
	elseif msg_==hp.MSG.MAIL_CHANGED then
		if parm_.type == 7 then
			self.checkMailLight()
		end
	elseif msg_ == hp.MSG.UNION_DATA_PREPARED then
		if parm_ == dirtyType.VARIABLENUM then
			self.checkUnionLight()
		end
	end
end