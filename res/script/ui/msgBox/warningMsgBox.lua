--
-- ui/msgBox/warningMsgBox.lua
-- 消息框
--===================================
require "ui/frame/popFrame"


UI_warningMsgBox = class("UI_warningMsgBox", UI)


--init
function UI_warningMsgBox:init(title_, msg_, okText_, cancelText_, onOK_, onCancel_)
	-- data
	-- ===============================
	self.OK = false
	self.onOk = onOK_
	self.onCancel = onCancel_


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "warningMsgBox.json")
	local uiFrame = UI_popFrame.new(wigetRoot, title_)

	local contNode = wigetRoot:getChildByName("Panel_cont")
	local btnCancel = contNode:getChildByName("ImageView_no")
	local btnOk = contNode:getChildByName("ImageView_yes")
	local okLabel = btnOk:getChildByName("Label_text")
	local cancelLabel = btnCancel:getChildByName("Label_text")
	local descLabel = contNode:getChildByName("Label_desc")

	if okText_~=nil then
		okLabel:setString(okText_)
	end
	if cancelText_~=nil then
		cancelLabel:setString(cancelText_)
	else
		local px, py = btnOk:getPosition()
		px = game.visibleSize.width/2
		btnOk:setPosition(px, py)
		btnCancel:setVisible(false)
	end
	if msg_~=nil then
		descLabel:setString(msg_)
	end


	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnOk then
				self.OK = true
			end
			self:close()
		end
	end
	btnCancel:addTouchEventListener(onBtnTouched)
	btnOk:addTouchEventListener(onBtnTouched)


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end

function UI_warningMsgBox:onRemove()
	if self.OK then
		if self.onOk~=nil and type(self.onOk)=='function' then
			self.onOk()
		end
	else
		if self.onCancel~=nil and type(self.onCancel)=='function' then
			self.onCancel()
		end
	end

	self.super.onRemove(self)
end
