--
-- ui/bigMap/battle/titleGrant.lua
-- 称号授予 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_titleGrant = class("UI_titleGrant", UI)

--init
function UI_titleGrant:init(title_)
	-- data
	-- ===============================
	self.title = title_

	-- ui
	-- ===============================
	self:initUI()
	
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5371))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function onGrantTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local str_ = self.inputText:getString()
			if str_ == "" then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5388), hp.lang.getStrByID(5387), nil)
      			self:addModalUI(box_)
			else
				self:showLoading(player.fortressMgr.httpReqGrantTitle(self.title, str_), sender)
			end
			self:close()
		end
	end
	self.grantBtn:addTouchEventListener(onGrantTouched)
end

function UI_titleGrant:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fortressGrant.json")
	local content = self.wigetRoot:getChildByName("Panel_5")

	-- 名称
	content:getChildByName("Label_4"):setString(hp.lang.getStrByID(5372))

	-- 输入
	local label_ = content:getChildByName("Label_6")
	self.inputText = hp.uiHelper.labelBind2EditBox(label_)
	self.inputText.setDefaultText(hp.lang.getStrByID(5373))

	-- 授予按钮
	self.grantBtn = content:getChildByName("Image_7")
	self.grantBtn:getChildByName("Label_8"):setString(hp.lang.getStrByID(5370))
end