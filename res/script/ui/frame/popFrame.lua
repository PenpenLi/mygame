--
-- ui/frame/popFrame.lua
-- 架构 - 弹出窗口
--===================================
require "ui/UI"


UI_popFrame = class("UI_popFrame", UI)


--init
function UI_popFrame:init(ui_, title_, position_, name_)
	-- data
	-- ===============================


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "popFrame.json")
	self.wigetRoot = wigetRoot

	--
	-- ===============================
	local frameNode = wigetRoot:getChildByName("Panel_frame")
	local contNode = wigetRoot:getChildByName("Panel_4628")

	-- 标题
	local titleBg = contNode:getChildByName("ImageView_title")
	local title = titleBg:getChildByName("Label_title")
	local btnClose = contNode:getChildByName("ImageView_close")
	if title_==nil then
		titleBg:setVisible(false)
		btnClose:setVisible(false)
	else
		title:setString(title_)
		local function OnBtnCloseTouched(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType==TOUCH_EVENT_ENDED then
				if self.closeCallBack ~= nil then
					self.closeCallBack()
				else
					self:close()
				end
			end
		end
		btnClose:addTouchEventListener(OnBtnCloseTouched)
	end

	-- 坐标收藏
	local bookMarkContainer = contNode:getChildByName("ImageView_7941")
	if position_ ~= nil then
		-- local bookMark = bookMarkContainer:getChildByName("ImageView_7942")
		local bookMark = bookMarkContainer
		local function OnAddBookMarkTouched(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then
				require "ui/bigMap/func/addBookMark"
				local ui = UI_addBookMark.new(position_, 1, name_)
				self:addModalUI(ui)
			end
		end
		bookMark:addTouchEventListener(OnAddBookMarkTouched)
	else
		bookMarkContainer:setVisible(false)
	end

	-- 根据ui_，重新设置背景
	local bgParts = frameNode:getChildren()
	-- 设置容器位置
	local x, y = ui_:getPosition()
	local sz = ui_:getSize()
	local x1, y1 = frameNode:getPosition()
	local sz1 = bgParts[1]:getSize()
	frameNode:setPosition(x1, y+sz1.height)
	contNode:setPosition(0, y + sz.height - sz1.height)
	-- 设置9宫格拼接
	y = sz.height - sz1.height*2
	if y<0 then
		y = 0
	elseif y%2==1 then
		y = y+1
	end
	-- 设置1、2、3
	for i=1, 3 do
		x1, y1 = bgParts[i]:getPosition()
		bgParts[i]:setPosition(x1, y)
	end
	-- 设置4、5、6
	for i=4, 6 do
		sz = bgParts[i]:getSize()
		sz.height = y
		bgParts[i]:setSize(sz)
	end

	self.titleBg = titleBg
	self.title = title
	self.bgParts = bgParts

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end

-- resetSize
function UI_popFrame:resetSize(ui_)
	
end

-- setIsModalUI
function UI_popFrame:setIsModalUI(modal_)
	if modal_ == false then
		self.wigetRoot:setTouchEnabled(false)
		self.wigetRoot:setBackGroundColorOpacity(0)
	else
		self.wigetRoot:setTouchEnabled(true)
		self.wigetRoot:setBackGroundColorOpacity(100)
	end
end

-- setTitleVisible
function UI_popFrame:setTitleVisible(vis_)
	self.titleBg:setVisible(vis_)
end

-- setCloseEvent
function UI_popFrame:setCloseEvent(callBack_)
	self.closeCallBack = callBack_
end

-- setTitle
function UI_popFrame:setTitle(title_)
	self.title:setString(title_)
end

function UI_popFrame:setBgOpacity(opacity_)
	for i, v in ipairs(self.bgParts) do
		v:setOpacity(opacity_)
	end
end
