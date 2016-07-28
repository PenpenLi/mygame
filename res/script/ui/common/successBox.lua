--
-- ui/common/successBox.lua
-- 成功弹出框
--===================================
require "ui/frame/popFrame"

UI_successBox = class("UI_successBox", UI)

--init
function UI_successBox:init(title_, text_, callBack_)
	-- data
	-- ===============================
	self.text = text_
	self.callBack = callBack_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, title_)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_successBox:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "successBox.json")
	local content_ = self.wigetRoot:getChildByName("Panel_6")

	content_:getChildByName("Label_30165"):setString(self.text)

	local okButton = content_:getChildByName("ImageView_30166")
	okButton:getChildByName("Label_30167"):setString(hp.lang.getStrByID(1209))
	okButton:addTouchEventListener(self.onOKTouched)
end

function UI_successBox:initCallBack()
	local function onOKTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.callBack ~= nil then
				self.callBack()
			end
			self:close()
		end
	end

	self.onOKTouched = onOKTouched
end