--
-- ui/mail/normalMail.lua
-- 普通邮件
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_normalMail = class("UI_normalMail", UI)


--init
function UI_normalMail:init(Info,mailType_,mailIndex,parent)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "normalMail.json")
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	local Panel_cont = Panel_item:getChildByName("Panel_cont")

	Panel_cont:getChildByName("Label_name"):setString(Info.heroName)
	
	Panel_cont:getChildByName("Label_info"):setString(Info.content)
	
	local heroIcon = Panel_cont:getChildByName("Image_heroIcon")
	if Info.isSystem == 1 then
		heroIcon:loadTexture(config.dirUI.common .. "systemHeadPic.png")
	else
		heroIcon:loadTexture(config.dirUI.heroHeadpic .. Info.heroIconSid .. ".png")
	end

	local function popPlayerInfo(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			local ui_ = UI_playerInfo.new(Info.sendId)
			parent:addUI(ui_)
		end
	end
	heroIcon:addTouchEventListener(popPlayerInfo)
	
	Panel_item:getChildByName("Panel_replyCont"):getChildByName("Label_reply"):setString( hp.lang.getStrByID(7921))
	Panel_item:getChildByName("Panel_blockCont"):getChildByName("Label_block"):setString( hp.lang.getStrByID(7922))
	local replyBtn = Panel_item:getChildByName("Panel_replyCont"):getChildByName("ImageView_reply")
	local blockBtn = Panel_item:getChildByName("Panel_blockCont"):getChildByName("ImageView_block")
	local replyBtnIco = Panel_item:getChildByName("Panel_replyCont"):getChildByName("Image_ico")
	local replyBtn1 = Panel_item:getChildByName("Panel_replyCont"):getChildByName("Image_replyBtn")

	if Info.isSystem == 1 then
		
		Panel_item:getChildByName("Panel_replyCont"):setVisible(false)
        Panel_item:getChildByName("Panel_blockCont"):setVisible(false)
		
		Panel_item:getChildByName("Panel_delCont"):setPositionX(220)
		
	else
		
		function replyBtnOnTouched(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType==TOUCH_EVENT_ENDED then
				
				require "ui/mail/writeMail.lua"
				local uiFrame = UI_writeMail.new(Info.sendName)
				self:addUI(uiFrame)
				
			end
		end
		replyBtn1:addTouchEventListener(replyBtnOnTouched)
		replyBtn:addTouchEventListener(replyBtnOnTouched)
		--block
		

		function blockBtnOnTouched(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType==TOUCH_EVENT_ENDED then
				--self:close()
				
			end
		end
		
		blockBtn:addTouchEventListener(blockBtnOnTouched)

	end
	

	--del
	Panel_item:getChildByName("Panel_delCont"):getChildByName("Label_delete"):setString( hp.lang.getStrByID(1221))
		
	local delBtn = Panel_item:getChildByName("Panel_delCont"):getChildByName("ImageView_delete")
	function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	
	delBtn:addTouchEventListener(delBtnOnTouched)
	
	
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
