--
-- ui/fullScreenFrame.lua
-- 架构 - 全屏ui
--===================================
require "ui/UI"


UI_fullScreenFrame = class("UI_fullScreenFrame", UI)


--init
function UI_fullScreenFrame:init(hideGold_)
	-- data
	-- ===============================
	self.isFrame = true

	if hideGold_ then
		self.hideGold = true
	else
		self.hideGold = false
	end

	-- ui
	-- ===============================
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fullScreenFrame.json")
	local contPanel = self.widgetRoot:getChildByName("Panel_cont")
	self.contPanel = contPanel
	local backNode = contPanel:getChildByName("ImageView_back")
	local function backNodeOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end
	backNode:addTouchEventListener(backNodeOnTouched)
	self.backNode = backNode
	-- gold
	local goldNode = contPanel:getChildByName("ImageView_gold")
	if self.hideGold then
		goldNode:setVisible(false)
	else
		goldNode:setVisible(true)
		self.goldNumNode = goldNode:getChildByName("Label_num")
		self.goldNumNode:setString(player.getResourceShow("gold"))

		local function onGoldTouched(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType==TOUCH_EVENT_ENDED then
				require "ui/goldShop/goldShop"
				local ui = UI_goldShop.new()
				self:closeAll()
				self:addUI(ui)
			end
		end
		goldNode:addTouchEventListener(onGoldTouched)
	end

	-- addCCNode
	-- ===============================
	self:addCCNode(self.widgetRoot)


	-- registMsg
	self:registMsg(hp.MSG.RESOURCE_CHANGED)
end

-- onMsg
function UI_fullScreenFrame:onMsg(msg_, resInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED and not self.hideGold then
		if resInfo_.name=="gold" then
			self.goldNumNode:setString(hp.common.changeNumUnit1(resInfo_.num, 100000))
		end
	end
end

-- setTitle
-- @strTitle_ 标题
-- @fntFile_ 标题艺术字文件
function UI_fullScreenFrame:setTitle(strTitle_, fntFile_)


	local len = 0
	local titleNode = self.contPanel:getChildByName("BitmapLabel_title")

	if fntFile_ then
		titleNode:setFntFile(config.dirUI.font .. fntFile_ .. ".fnt")
	end

	if strTitle_~=nil then
		len = hp.common.utf8_strLen(strTitle_)
	end
	if len==0 then
	-- 无标题
		titleNode:setVisible(false)
		self.contPanel:getChildByName("Image_titleBg"):setVisible(false)
	else
		if len>4 then
		-- 调整标题框大小
			local titleBg = self.contPanel:getChildByName("Image_titleBg")
			local bgLeft = titleBg:getChildByName("Image_bgLeft")
			local bgRight = titleBg:getChildByName("Image_bgRight")
			local sz = titleBg:getSize()
			len = (len-4)*10
			sz.width = sz.width+len*2
			titleBg:setSize(sz)
			bgLeft:setPositionX(sz.width/2-len)
			bgRight:setPositionX(sz.width/2+len)
		end
		titleNode:setString(strTitle_)
	end
end

--
-- setBackEnabled
-- 隐藏
function UI_fullScreenFrame:setBackEnabled(enabled_)
	self.backNode:setVisible(enabled_)
	self.backNode:setTouchEnabled(enabled_)
end

--
-- hideBackground
-- 隐藏背景
function UI_fullScreenFrame:hideBackground()
	self.widgetRoot:getChildByName("Panel_frame"):getChildByName("ImageView_bg"):setVisible(false)
end

--
-- hideTopBackground
-- 隐藏顶部背景
function UI_fullScreenFrame:hideTopBackground()
	self.widgetRoot:getChildByName("Panel_frame"):getChildByName("Image_headBg"):setVisible(false)
end

--
-- hideTopShade
-- 隐藏头部渐变
function UI_fullScreenFrame:hideTopShade()
	self.widgetRoot:getChildByName("Panel_shade"):getChildByName("Image_shadeTop"):setVisible(false)
end

--
-- hideBottomShade
-- 隐藏底部渐变
function UI_fullScreenFrame:hideBottomShade()
	self.widgetRoot:getChildByName("Panel_shade"):getChildByName("Image_shadeBottom"):setVisible(false)
end

--
-- setTopShadePos
-- 设置头部渐变Y坐标
function UI_fullScreenFrame:setTopShadePosY(py_)
	local topBg = self.widgetRoot:getChildByName("Panel_frame"):getChildByName("Image_headBg")
	local topShade = self.widgetRoot:getChildByName("Panel_shade"):getChildByName("Image_shadeTop")
	local py = py_*hp.uiHelper.RA_scaleY
	topBg:setPositionY(py)
	topShade:setPositionY(py)
	topBg:setSize(cc.size(config.resSize.width, config.resSize.height-py_))
end

--
-- setBottomShadePosY
-- 设置底部渐变Y坐标
function UI_fullScreenFrame:setBottomShadePosY(py_)
	self.widgetRoot:getChildByName("Panel_shade"):getChildByName("Image_shadeBottom"):setPositionY(py_*hp.uiHelper.RA_scaleY)
end

--
-- setBgImg
-- 设置背景图片
function UI_fullScreenFrame:setBgImg(img)
	self.widgetRoot:getChildByName("Panel_frame"):getChildByName("ImageView_bg"):loadTexture(img)
end