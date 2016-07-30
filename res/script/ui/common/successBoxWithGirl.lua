--
-- ui/common/successBoxWithGirl.lua
-- 成功弹出框
--===================================

UI_successBoxWithGirl = class("UI_successBoxWithGirl", UI)

--init
function UI_successBoxWithGirl:init(text_, callBack_, color_)
	-- data
	-- ===============================
	self.text = text_
	self.callBack = callBack_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)
end

function UI_successBoxWithGirl:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "successBoxWithGirl.json")
	local content_ = self.wigetRoot:getChildByName("Panel_6")

	content_:getChildByName("Label_30165"):setString(self.text)

	local okButton = content_:getChildByName("ImageView_30166")
	self.buttonText = okButton:getChildByName("Label_30167")
	if color_ == "red" then
		self.buttonText:setColor(cc.c3b(255, 255, 255))
	end
	self.buttonText:setString(hp.lang.getStrByID(5200))
	okButton:addTouchEventListener(self.onOKTouched)
end

function UI_successBoxWithGirl:initCallBack()
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

function UI_successBoxWithGirl:setButtonText(str_)
	self.buttonText:setString(str_)
end