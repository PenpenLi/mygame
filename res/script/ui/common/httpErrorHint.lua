--
-- ui/common/httpErrorHint.lua
-- http请求失败提示框
--===================================
require "ui/frame/popFrame"
require "ui/frame/popFrameRed"

UI_httpErrorHint = class("UI_httpErrorHint", UI)

--init
function UI_httpErrorHint:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local function onCloseToucded()
		if self.callBack ~= nil then
			self.callBack()
		end
		self.callBack = nil
		self.layer:setVisible(false)
	end
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5287))
	popFrame:setCloseEvent(onCloseToucded)
	self.popFrame = popFrame

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	self.layer:setVisible(false)
end

function UI_httpErrorHint:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "successBox.json")
	local content_ = self.wigetRoot:getChildByName("Panel_6")

	self.uiText = content_:getChildByName("Label_30165")

	local okButton = content_:getChildByName("ImageView_30166")
	self.buttonText = okButton:getChildByName("Label_30167")
	self.buttonText:setString(hp.lang.getStrByID(5200))
	okButton:addTouchEventListener(self.onOKTouched)
end

function UI_httpErrorHint:initCallBack()
	local function onOKTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.callBack ~= nil then
				self.callBack()
			end
			self.callBack = nil
			self.layer:setVisible(false)
		end
	end

	self.onOKTouched = onOKTouched
end

function UI_httpErrorHint:setInfo(param_)
	local result_ = param_.result
	local type_ = param_.type
	local channel_ = param_.channel

	if channel_ == nil then
		return false
	end

	if type_ == nil then
		return false
	end
	
	if param_.result < 0 then
		channel_ = 0
		type_ = 0
	end

	hintInfo_ = hp.gameDataLoader.multiConditionSearch("notice", {result=result_,channel=channel_,type=type_})
	if hintInfo_ == nil then
		return false
	elseif hintInfo_.show ~= 3 then
		return false
	end

	self.uiText:setString(hintInfo_.client)
	self.popFrame:setTitle(hintInfo_.title)
	return true
end

function UI_httpErrorHint:pop(callBack_)
	self.callBack = callBack_

	self.layer:setVisible(true)
end

function UI_httpErrorHint:moveUp(pos_)
end