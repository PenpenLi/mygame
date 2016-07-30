--
-- ui/msgBox/msgBoxWithGirl.lua
-- 消息框
--===================================

UI_msgBoxWithGirl = class("UI_msgBoxWithGirl", UI)


--init
function UI_msgBoxWithGirl:init(msg_, okText_, cancelText_, onOK_, onCancel_, color_)
	-- data
	-- ===============================
	self.OK = false
	self.onOk = onOK_
	self.onCancel = onCancel_


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "msgBoxWithGirl.json")

	local contNode = wigetRoot:getChildByName("Panel_cont")
	local btnCancel = contNode:getChildByName("ImageView_cancel")
	local btnOk = contNode:getChildByName("ImageView_ok")
	local okLabel = btnOk:getChildByName("Label_text")
	local cancelLabel = btnCancel:getChildByName("Label_text")
	local descLabel = contNode:getChildByName("Label_desc")

	if color_ == "red" then
		descLabel:setColor(cc.c3b(255, 255, 255))
	end

	if okText_~=nil then
		okLabel:setString(okText_)
	end
	if cancelText_~=nil then
		cancelLabel:setString(cancelText_)
	else
		local px, py = btnOk:getPosition()
		px = config.resSize.width/2
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

	local fontSize = descLabel:getFontSize()
	local lineNum = descLabel:getVirtualRenderer():getStringNumLines()
	local rootSize = wigetRoot:getSize()
	local px, py = wigetRoot:getPosition()
	
	if lineNum>1 then
		descLabel:setTextHorizontalAlignment(0)
	end

	local descHeight = fontSize * lineNum
	rootSize.height = rootSize.height+descHeight
	py = py-descHeight/2
	wigetRoot:setSize(rootSize)
	wigetRoot:setPosition(px, py)

	px, py = descLabel:getPosition()
	descLabel:setPosition(px, py+descHeight)

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end

function UI_msgBoxWithGirl:onRemove()
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