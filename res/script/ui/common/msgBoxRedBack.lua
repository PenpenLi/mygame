--
-- ui/common/msgBoxRedBack.lua
-- 破除防御提示
--===================================
require "ui/UI"


UI_msgBoxRedBack = class("UI_msgBoxRedBack", UI)


--init
function UI_msgBoxRedBack:init(title_, text_, confirmText_, cancelText_, callBack_)
	-- data
	-- ===============================

	-- ui
	-- ===============================

	-- 初始化界面
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "breakGuardFrame.json")
	local content_ = wigetRoot:getChildByName("Panel_4")

	content_:getChildByName("Label_15"):setString(title_)

	content_:getChildByName("Label_25"):setString(text_)

	local cancel_ = content_:getChildByName("Image_18_0")
	cancel_:getChildByName("Label_19"):setString(cancelText_)

	local confirm_ = content_:getChildByName("Image_18")
	confirm_:getChildByName("Label_19"):setString(confirmText_)

	-- call back
	local function OnBtnCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function OnMarchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if callBack_ ~= nil then
				callBack_()
			end
			self:close()
		end
	end

	content_:getChildByName("Image_16"):addTouchEventListener(OnBtnCloseTouched)
	cancel_:addTouchEventListener(OnBtnCloseTouched)
	confirm_:addTouchEventListener(OnMarchTouched)

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end