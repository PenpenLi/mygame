--
-- ui/frame/popFrameRed.lua
-- 架构 - 弹出窗口-红色
--===================================
require "ui/UI"


UI_popFrameRed = class("UI_popFrameRed", UI)


--init
function UI_popFrameRed:init(ui_, title_)
	-- data
	-- ===============================


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "popFrameRed.json")

	-- 底板
	self.panelFrame = wigetRoot:getChildByName("Panel_frame")
	self.edge = {}
	self.angle = {}
	for i = 1, 4 do
		self.edge[i] = self.panelFrame:getChildByName("ImageView_edge"..i)
		self.angle[i] = self.panelFrame:getChildByName("ImageView_angle"..i)
	end
	self.imageBase = self.panelFrame:getChildByName("ImageView_base")

	-- 关闭按钮等
	self.contentContainer = wigetRoot:getChildByName("Panel_4628")
	-- 关闭
	self.btnClose = self.contentContainer:getChildByName("ImageView_close")
	-- 标题
	self.titleBg = self.contentContainer:getChildByName("ImageView_title")
	local title = self.titleBg:getChildByName("Label_title")

	if title_==nil then
		self.titleBg:setVisible(false)
		self.btnClose:setVisible(false)
		self.btnClose:setTouchEnabled(false)
	else
		title:setString(title_)
	end

	self:resetSize(ui_)

	local function OnBtnCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	-- call back

	self.btnClose:addTouchEventListener(OnBtnCloseTouched)
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end

-- setTitle
function UI_popFrameRed:resetSize(ui_)
	local x, y = ui_:getPosition()
	local sz_ = ui_:getSize()
	local oldSize = self.panelFrame:getSize()
	self.panelFrame:setPosition(x, y)
	self.contentContainer:setPosition(x, y)

	local size = self.edge[1]:getSize()
	size.height = size.height + sz_.height - oldSize.height
	x, y = self.edge[1]:getPosition()
	self.edge[1]:setSize(size)
	self.edge[1]:setPosition(x, y + (sz_.height - oldSize.height) / 2 )

	x, y = self.edge[3]:getPosition()
	self.edge[3]:setSize(size)
	self.edge[3]:setPosition(x, y + (sz_.height - oldSize.height) / 2 )

	local size = self.imageBase:getSize()
	size.height = size.height + sz_.height - oldSize.height
	self.imageBase:setSize(size)
	x, y = self.imageBase:getPosition()
	self.imageBase:setPosition(x, y + (sz_.height - oldSize.height) / 2 )

	x_, y_ = self.angle[1]:getPosition()
	self.angle[1]:setPosition(x_, y_ + sz_.height - oldSize.height)
	x_, y_ = self.angle[2]:getPosition()
	self.angle[2]:setPosition(x_, y_ + sz_.height - oldSize.height)
	x_, y_ = self.edge[2]:getPosition()
	self.edge[2]:setPosition(x_, y_ + sz_.height - oldSize.height)
	x_, y_ = self.btnClose:getPosition()
	self.btnClose:setPosition(x_, y_ + sz_.height - oldSize.height)
	x_, y_ = self.titleBg:getPosition()
	self.titleBg:setPosition(x_, y_ + sz_.height - oldSize.height)
end