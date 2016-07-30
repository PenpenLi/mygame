--
-- ui/chat/chatOperMore.lua
-- 聊天点击操作
--===================================
require "ui/frame/popFrame"


UI_chatOperMore = class("UI_chatOperMore", UI)


--init
function UI_chatOperMore:init(chatInfo_)
	-- data
	-- ===============================
	local friendMgr = player.friendMgr

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "chatOperMore.json")
	local uiFrame = UI_popFrame.new(wigetRoot)

	local function showInfo(titleStrId, infoStrId)
		require("ui/msgBox/msgBox")
		local msgBox = UI_msgBox.new(hp.lang.getStrByID(titleStrId), 
			hp.lang.getStrByID(infoStrId), 
			hp.lang.getStrByID(1209)
			)
		self:addModalUI(msgBox)
	end
	self.showInfo = showInfo

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	-- logic
	-- ===============================
	local contNode = wigetRoot:getChildByName("Panel_cont")
	local btnAddFrient = contNode:getChildByName("Image_addfriend")
	local btnSendMail = contNode:getChildByName("Image_mail")
	local btnViewPlayer = contNode:getChildByName("Image_view")
	local btnBlock = contNode:getChildByName("Image_block")
	local btnCancle = contNode:getChildByName("Image_cancle")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnAddFrient then
				if chatInfo_.srcName==player.getName() then
					showInfo(3615, 3617)
				elseif table.getn(friendMgr.getFriends())>=friendMgr.getMaxSize() then
				--好友已满
					showInfo(3615, 3616)
				else
					friendMgr.sendInvite(chatInfo_.srcName)
					showInfo(3619, 3620)
				end
				self:close()
			elseif sender==btnSendMail then
				require("ui/mail/writeMail")
				local ui = UI_writeMail.new(chatInfo_.srcName)
				self:closeAll()
				self:addUI(ui)
			elseif sender==btnViewPlayer then
				require("ui/common/playerInfo")
				local ui = UI_playerInfo.new(chatInfo_.srcId, chatInfo_.srcServerId)
				self:closeAll()
				self:addUI(ui)
			elseif sender==btnBlock then
			elseif sender==btnCancle then
				self:close()
			end
		end
	end
	btnAddFrient:addTouchEventListener(onBtnTouched)
	btnSendMail:addTouchEventListener(onBtnTouched)
	btnViewPlayer:addTouchEventListener(onBtnTouched)
	btnBlock:addTouchEventListener(onBtnTouched)
	btnCancle:addTouchEventListener(onBtnTouched)

	btnAddFrient:getChildByName("Label_text"):setString(hp.lang.getStrByID(3603))
	btnSendMail:getChildByName("Label_text"):setString(hp.lang.getStrByID(3604))
	btnViewPlayer:getChildByName("Label_text"):setString(hp.lang.getStrByID(3605))
	btnViewPlayer:getChildByName("Image_headIcon"):loadTexture(config.dirUI.heroHeadpic .. chatInfo_.srcIcon .. ".png")
	btnBlock:getChildByName("Label_text"):setString(hp.lang.getStrByID(3606))
	btnBlock:getChildByName("Image_headIcon"):loadTexture(config.dirUI.heroHeadpic .. chatInfo_.srcIcon .. ".png")
	btnCancle:getChildByName("Label_text"):setString(hp.lang.getStrByID(2412))
end
