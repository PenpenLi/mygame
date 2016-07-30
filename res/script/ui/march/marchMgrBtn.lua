--
-- ui/march/marchMgrBtn.lua
-- 行军管理按钮
--===================================
require "ui/UI"


UI_marchMgrBtn = class("UI_marchMgrBtn", UI)


--init
function UI_marchMgrBtn:init()
	-- data
	-- ===============================
	local function onButtonTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/march/marchManagerUI"
			local ui_ = UI_marchManagerUI.new()
			self:addUI(ui_)
		end
	end

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bigMapArmyBtn.json")
	local image_ = wigetRoot:getChildByName("Panel_2"):getChildByName("Image_3")
	soldier_ = image_:getChildByName("Image_4")
	image_:addTouchEventListener(onButtonTouched)

	require "ui/common/effect.lua"
	self.conflictLight = inLight(soldier_:getVirtualRenderer(),4)
	self.conflictLight:setVisible(false)
	soldier_:addChild(self.conflictLight)

	local function conflictShow()
		if self.conflictLight == nil then
			return
		end

		local show_ = player.marchMgr.getConflict()
		self.conflictLight:setVisible(show_)
	end
	self.conflictShow = conflictShow
	conflictShow()

	self.numBg = image_:getChildByName("Image_5")
	self.num = self.numBg:getChildByName("Label_6")

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)

	self:registMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	self:registMsg(hp.MSG.MARCH_MANAGER)

	self:updateInfo()
end

function UI_marchMgrBtn:updateInfo()
	local num_ = player.getMarchMgr().getFieldArmyNum()
	self.num:setString(num_)
	if num_ == 0 then
		self.numBg:setVisible(false)
	else
		self.numBg:setVisible(true)
	end
end

function UI_marchMgrBtn:onMsg(msg_, param_)
	if msg_ == hp.MSG.MARCH_ARMY_NUM_CHANGE then
		self:updateInfo()
	elseif msg_ == hp.MSG.MARCH_MANAGER then
		if param_ == nil then
			return
		end
		if param_.msgType == 1 then
			self.conflictShow()
		end
	end
end