--
-- ui/fullScreenFrame.lua
-- 架构 - 全屏ui
--===================================
require "ui/UI"


UI_fullScreenFrame = class("UI_fullScreenFrame", UI)


--init
function UI_fullScreenFrame:init(hideGold_)
	-- data
	-- ===============================
	self.isFrame = true

	if hideGold_ then
		self.hideGold = true
	else
		self.hideGold = false
	end


	-- ui
	-- ===============================
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fullScreenFrame.json")
	local contPanel = self.wigetRoot:getChildByName("Panel_cont")
	local backNode = contPanel:getChildByName("ImageView_back")
	local function backNodeOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end
	backNode:addTouchEventListener(backNodeOnTouched)
	-- gold
	local goldNode = contPanel:getChildByName("ImageView_gold")
	if self.hideGold then
		goldNode:setVisible(false)
	else
		goldNode:setVisible(true)
		self.goldNumNode = goldNode:getChildByName("Label_num")
		self.goldNumNode:setString(player.getResourceShow("gold"))
	end

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)


	-- registMsg
	-- self:registMsg(hp.MSG.RESOURCE_CHANGED)
end

-- setTitle
function UI_fullScreenFrame:setTitle(strTitle)
	local titleNode = self.wigetRoot:getChildByName("Panel_cont"):getChildByName("BitmapLabel_title")
	titleNode:setString(strTitle)
end

-- onMsg
function UI_fullScreenFrame:onMsg(msg_, resInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED and not self.hideGold then
		if resInfo_.name=="gold" then
			self.goldNumNode:setString(hp.common.changeNumUnit(resInfo_.num))
		end
	end
end