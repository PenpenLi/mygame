--
-- ui/common/unlockWarSlot.lua
-- 解锁战争槽
--===================================
require "ui/frame/popFrame"

UI_unlockWarSlot = class("UI_unlockWarSlot", UI)

--init
function UI_unlockWarSlot:init(rallyInfo_, callBack_)
	-- data
	-- ===============================
	self.callBack = callBack_
	self.item = hp.gameDataLoader.getInfoBySid("item", 20701)
	self.rallyInfo = rallyInfo_
	self.num = 1

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1193))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_unlockWarSlot:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unlockWarSlot.json")
	local content_ = self.wigetRoot:getChildByName("Panel_10")

	-- 描述
	content_:getChildByName("Label_11"):setString(hp.lang.getStrByID(1194))
	-- 为自己开放
	content_:getChildByName("Label_11_0"):setString(hp.lang.getStrByID(1195))
	-- 为别人开放
	content_:getChildByName("Label_11_0_1"):setString(hp.lang.getStrByID(1196))

	local forMeBtn_ = content_:getChildByName("Image_16")
	forMeBtn_:addTouchEventListener(self.onOpenForMeTouched)
	forMeBtn_:getChildByName("Label_17"):setString(hp.lang.getStrByID(1197))
	forMeBtn_:getChildByName("ImageView_gold_0_0_0"):getChildByName("Label_goldCost"):setString(tostring(self.item.sale * self.num))

	local forOtherBtn_ = content_:getChildByName("Image_16_0")
	forOtherBtn_:addTouchEventListener(self.onOpenForOtherTouched)
	forOtherBtn_:getChildByName("Label_17"):setString(hp.lang.getStrByID(1198))
	forOtherBtn_:getChildByName("ImageView_gold_0_0_0"):getChildByName("Label_goldCost"):setString(tostring(self.item.sale * self.num))
end

function UI_unlockWarSlot:initCallBack()
	local function onOpenForMeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self.callBack(player.getID())
			self:close()
		end
	end

	local function onOpenForOtherTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self.callBack(self.rallyInfo.fellowID)		
			self:close()	
		end
	end

	self.onOpenForMeTouched = onOpenForMeTouched
	self.onOpenForOtherTouched = onOpenForOtherTouched
end