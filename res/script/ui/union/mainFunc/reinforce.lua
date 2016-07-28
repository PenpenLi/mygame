--
-- ui/union/reinforce.lua
-- 支援士兵
--===================================
require "ui/frame/popFrame"

UI_reinforce = class("UI_reinforce", UI)

--init
function UI_reinforce:init(id_)
	-- data
	-- ===============================
	self.member = player.getAlliance():getMemberByID(id_)

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local popFrame = UI_popFrame.new(self.widgetRoot, hp.lang.getStrByID(1820))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.widgetRoot)
end

function UI_reinforce:initCallBack()
	local function onReinforceTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			print("aaa",self.member)
			require "ui/march/march"			
			if self.member ~=nil then
				UI_march.openMarchUI(self, self.member:getPosition(), 6, 0)
			end
		end
	end

	local function onCancelTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	self.onCancelTouched = onCancelTouched
	self.onReinforceTouched = onReinforceTouched
end

function UI_reinforce:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "reinforce.json")
	local content_ = self.widgetRoot:getChildByName("Panel_11")

	content_:getChildByName("Label_6"):setString(hp.lang.getStrByID(1153))
	content_:getChildByName("Label_7"):setString(hp.lang.getStrByID(2412))
	content_:getChildByName("Label_12"):setString(hp.lang.getStrByID(1154))
	content_:getChildByName("Label_12_0"):setString(hp.lang.getStrByID(1155))

	self.soldierNum = content_:getChildByName("Label_16")

	self.widgetRoot:getChildByName("Panel_3"):getChildByName("Image_5"):addTouchEventListener(self.onReinforceTouched)
	self.widgetRoot:getChildByName("Panel_3"):getChildByName("Image_5_0"):addTouchEventListener(self.onCancelTouched)
end