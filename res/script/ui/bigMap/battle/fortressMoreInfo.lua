--
-- ui/bigMap/battle/fortressMoreInfo.lua
-- 重镇信息
--===================================
require "ui/frame/popFrame"

UI_fortressMoreInfo = class("UI_fortressMoreInfo", UI)

--init
function UI_fortressMoreInfo:init()
	-- data
	-- ===============================

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

function UI_fortressMoreInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fortressMoreInfo.json")
	local content_ = self.wigetRoot:getChildByName("Panel_1")

	for i = 2, 9 do
		content_:getChildByName("Label_"..i):setString(hp.lang.getStrByID(5360+i))
	end

	local okButton = content_:getChildByName("Image_3")
	self.buttonText = okButton:getChildByName("Label_4")
	self.buttonText:setString(hp.lang.getStrByID(5200))
	okButton:addTouchEventListener(self.onOKTouched)
end

function UI_fortressMoreInfo:initCallBack()
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