--
-- ui/quest/activateVIP.lua
-- VIP激活提示框
--===================================
require "ui/UI"
require "ui/frame/popFrame"


UI_activateVIP = class("UI_activateVIP", UI)


--init
function UI_activateVIP:init()
	-- data
	-- ===============================

	-- ui
	-- ===============================
	self:initCallBack()

	-- 初始化界面
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1403))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_activateVIP:initCallBack()
	local function onInfomationTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/vip/vip"
			local ui_ = UI_vip.new()
			self:addUI(ui_)
			self:close()
		end
	end

	local function onBecomeVIPTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/vip/vipDetails"
			local ui_ = UI_vipDetails.new(player.vipStatus.getLv())
			self:addUI(ui_)
			self:close()
		end
	end

	self.onInfomationTouched = onInfomationTouched
	self.onBecomeVIPTouched = onBecomeVIPTouched
end

function UI_activateVIP:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "activateVIP.json")

	local content_ = self.wigetRoot:getChildByName("Panel_2")
	content_:getChildByName("Label_3"):setString(hp.lang.getStrByID(5152))

	-- 信息
	local info_ = content_:getChildByName("Image_5")
	info_:getChildByName("Label_6"):setString(hp.lang.getStrByID(5154))
	info_:addTouchEventListener(self.onInfomationTouched)

	-- 成为VIP
	local beVIP_ = content_:getChildByName("Image_5_0")
	beVIP_:getChildByName("Label_6"):setString(hp.lang.getStrByID(5153))
	beVIP_:addTouchEventListener(self.onBecomeVIPTouched)
end
