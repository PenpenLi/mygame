--
-- ui/union/joinSuccess.lua
-- 成功弹出框
--===================================
require "ui/UI"

UI_joinSuccess = class("UI_joinSuccess", UI)

--init
function UI_joinSuccess:init(frist_, create_)
	-- data
	-- ===============================
	self.frist = frist_
	self.create = create_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()
	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)
end

function UI_joinSuccess:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "joinSuccess.json")
	local content_ = self.wigetRoot:getChildByName("Panel_32965")

	if self.create == true then
		content_:getChildByName("Label_32966"):setString(hp.lang.getStrByID(5389))
		content_:getChildByName("ImageView_32967"):getChildByName("Label_32969"):setString(hp.lang.getStrByID(1845))
	else
		content_:getChildByName("Label_32966"):setString(hp.lang.getStrByID(1844))
		content_:getChildByName("ImageView_32967"):getChildByName("Label_32969"):setString(hp.lang.getStrByID(1845))
	end

	if self.frist == 0 then
		content_:getChildByName("ImageView_32967"):getChildByName("Label_32969"):setString(hp.lang.getStrByID(5317))
		content_:getChildByName("ImageView_32967"):getChildByName("ImageView_32968"):setVisible(false)
		content_:getChildByName("ImageView_32967"):getChildByName("Label_11"):setString(hp.lang.getStrByID(5497))
	end

	local okButton = content_:getChildByName("ImageView_32970")
	okButton:getChildByName("Label_32971"):setString(hp.lang.getStrByID(5200))
	okButton:addTouchEventListener(self.onOKTouched)
end

function UI_joinSuccess:initCallBack()
	local function onOKTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	self.onOKTouched = onOKTouched
end