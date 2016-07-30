--
-- ui/bigMap/battle/fortressInfo.lua
-- 重镇信息
--===================================
require "ui/frame/popFrame"

UI_fortressInfo = class("UI_fortressInfo", UI)

--init
function UI_fortressInfo:init()
	-- data
	-- ===============================
	self.text = text_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = nil
	popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5358))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_fortressInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fortressInfo.json")
	local content_ = self.wigetRoot:getChildByName("Panel_1")

	content_:getChildByName("Label_2"):setString(hp.lang.getStrByID(5360))

	local okButton = content_:getChildByName("Image_3")
	self.buttonText = okButton:getChildByName("Label_4")
	self.buttonText:setString(hp.lang.getStrByID(5200))
	okButton:addTouchEventListener(self.onOKTouched)
end

function UI_fortressInfo:initCallBack()
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