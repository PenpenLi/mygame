--
-- ui/mail/normalMail.lua
-- 主建筑更多信息
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_normalMail = class("UI_normalMail", UI)


--init
function UI_normalMail:init(Info,mailType_,mailIndex)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "normalMail.json")
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	local Panel_cont = Panel_item:getChildByName("Panel_cont")

	Panel_cont:getChildByName("Label_name"):setString(Info.heroName)
	
	Panel_cont:getChildByName("Label_info"):setString(Info.content)
	
	if Info.isSystem == 1 then
		Panel_cont:getChildByName("Image_heroIcon"):loadTexture(config.dirUI.common .. "systemHeadPic.png")
	else
		Panel_cont:getChildByName("Image_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. Info.heroIconSid .. ".png")
	end
	
	Panel_item:getChildByName("Panel_replyCont"):getChildByName("Label_reply"):setString( hp.lang.getStrByID(7921))
	Panel_item:getChildByName("Panel_blockCont"):getChildByName("Label_block"):setString( hp.lang.getStrByID(7922))
	local replyBtn = Panel_item:getChildByName("Panel_replyCont"):getChildByName("ImageView_reply")
	local blockBtn = Panel_item:getChildByName("Panel_blockCont"):getChildByName("ImageView_block")
	local replyBtnIco = Panel_item:getChildByName("Panel_replyCont"):getChildByName("Image_ico")
	local replyBtn1 = Panel_item:getChildByName("Panel_replyCont"):getChildByName("Image_replyBtn")

	if Info.isSystem == 1 then
		replyBtn:loadTexture(config.dirUI.common .. "button_gray.png")
		replyBtn:setTouchEnabled(false)

		blockBtn:loadTexture(config.dirUI.common .. "button_gray.png")
		blockBtn:setTouchEnabled(false)

	else
		replyBtnIco:setColor(cc.c3b(255,255,255))
		--reply
		
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
			hp.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	
	delBtn:addTouchEventListener(delBtnOnTouched)
	
	
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
