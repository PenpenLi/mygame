--
-- ui/frame/popFrame.lua
-- 架构 - 弹出窗口
--===================================
require "ui/UI"


UI_popFrame = class("UI_popFrame", UI)

local OFFSET = 6

--init
function UI_popFrame:init(ui_, title_, position_)
	-- data
	-- ===============================


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "popFrame.json")
	self.wigetRoot = wigetRoot
	self.panelFrame = wigetRoot:getChildByName("Panel_frame")
	self.bottom = self.panelFrame:getChildByName("Image_bottom")
	self.top = self.panelFrame:getChildByName("Image_top")
	self.imageBase = self.panelFrame:getChildByName("ImageView_base")

	self.contentContainer = wigetRoot:getChildByName("Panel_4628")
	self.btnClose = self.contentContainer:getChildByName("ImageView_close")
	self.titleBg = self.contentContainer:getChildByName("ImageView_title")
	local title = self.titleBg:getChildByName("Label_title")
	self.bookMarkContainer = self.contentContainer:getChildByName("ImageView_7941")
	local bookMark = self.bookMarkContainer:getChildByName("ImageView_7942")
	if position_ ~= nil then
		self.bookMarkContainer:setVisible(true)
	end

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
	local function OnAddBookMarkTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/addBookMark"
			ui = UI_addBookMark.new(position_, 1)
			self:addModalUI(ui)
		end
	end

	bookMark:addTouchEventListener(OnAddBookMarkTouched)

	self.btnClose:addTouchEventListener(OnBtnCloseTouched)
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end

-- setTitle
function UI_popFrame:resetSize(ui_)
	local x, y = ui_:getPosition()
	local sz_ = ui_:getSize()
	self.panelFrame:setPosition(x, y)
	self.contentContainer:setPosition(x, y)

	local x1_, y1_ = self.top:getPosition()
	self.top:setPosition(x1_, sz_.height + OFFSET)
	local deltaHeight = sz_.height - y1_ + OFFSET

	local sz1_ = self.imageBase:getSize()
	sz1_.height = sz1_.height + deltaHeight
	self.imageBase:setSize(sz1_)

	-- bookmark
	x_, y_ = self.bookMarkContainer:getPosition()
	self.bookMarkContainer:setPosition(x_, y_ + deltaHeight)

	-- title
	x_, y_ = self.titleBg:getPosition()
	self.titleBg:setPosition(x_, y_ + deltaHeight)

	-- close
	x_, y_ = self.btnClose:getPosition()
	self.btnClose:setPosition(x_, y_ + deltaHeight)
end

function UI_popFrame:setIsModalUI(modal_)
	if modal_ == false then
		self.wigetRoot:setTouchEnabled(false)
		self.wigetRoot:setBackGroundColorOpacity(0)
	else
		self.wigetRoot:setTouchEnabled(true)
		self.wigetRoot:setBackGroundColorOpacity(100)
	end
end

function UI_popFrame:setTitleVisible(vis_)
	self.titleBg:setVisible(vis_)
end

function UI_popFrame:setWidth(width_)
	local sz_ = self.imageBase:getSize()
	local deltaW_ = width_ - sz_.width
	sz_.width = width_
	self.imageBase:setSize(sz_)

	local sz_ = self.top:getSize()
	sz_.width = width_
	self.top:setSize(sz_)

	local sz_ = self.bottom:getSize()
	sz_.width = width_
	self.bottom:setSize(sz_)

	local x_, y_ = self.btnClose:getPosition()
	self.btnClose:setPosition(x_, y_ + math.floor(deltaW_/2))
end