--
-- ui/chat/chatRoom_search.lua
-- 聊天室好友搜索界面
--===================================
require "ui/fullScreenFrame"


UI_chatRoom_search = class("UI_chatRoom_search", UI)


--init
function UI_chatRoom_search:init()
	-- data
	-- ===============================
	local friendMgr = player.friendMgr

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "chatRoom_search.json")

	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)

	--editbox
	local panelCont = widgetRoot:getChildByName("Panel_searchCont")
	local editLabel = panelCont:getChildByName("Label_editBox")
	local searchBtn = panelCont:getChildByName("Image_searchBtn")
	panelCont:getChildByName("Label_desc"):setString(hp.lang.getStrByID(3611))
	searchBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(3612))

	local function onEditChanged(str)
		if string.len(str)>0 then
			searchBtn:loadTexture(config.dirUI.common .. "button_green.png")
			searchBtn:setTouchEnabled(true)
		else
			searchBtn:loadTexture(config.dirUI.common .. "button_gray.png")
			searchBtn:setTouchEnabled(false)
		end
	end
	local editBoxCtrl = hp.uiHelper.labelBind2EditBox(editLabel)
	editBoxCtrl.setMaxLength(8)
	editBoxCtrl.setOnChangedHandle(onEditChanged)

	local function showInfo(titleStrId, infoStrId)
		require("ui/msgBox/msgBox")
		local msgBox = UI_msgBox.new(hp.lang.getStrByID(titleStrId), 
			hp.lang.getStrByID(infoStrId), 
			hp.lang.getStrByID(1209)
			)
		self:addModalUI(msgBox)
	end
	self.showInfo = showInfo
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local text = editBoxCtrl:getString()
			if string.len(text)>0 then
				if text==player.getName() then
					showInfo(3615, 3617)
					return
				end
				if table.getn(friendMgr.getFriends())>=friendMgr.getMaxSize() then
				--好友已满
					showInfo(3615, 3616)
					return
				end

				friendMgr.sendInvite(text)
				editBoxCtrl.setString("")
			end
		end
	end
	searchBtn:addTouchEventListener(onBtnTouched)

	-- registMsg
	self:registMsg(hp.MSG.FRIEND_MGR)
end

-- onMsg
function UI_chatRoom_search:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.FRIEND_MGR then
		if paramInfo_.oper==3 then
			if paramInfo_.rst==0 then
			--成功
				self.showInfo(3619, 3620)
			elseif paramInfo_.rst==14 then
			-- 查无此人
				self.showInfo(3615, 3618)
			end
		end
	end
end