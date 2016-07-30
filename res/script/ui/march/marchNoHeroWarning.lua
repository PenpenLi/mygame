--
-- ui/march/marchNoHeroWarning.lua
-- 未派出英雄
--===================================
require "ui/UI"


UI_marchNoHeroWarning = class("UI_marchNoHeroWarning", UI)


--init
function UI_marchNoHeroWarning:init(callBack_)
	-- data
	-- ===============================

	-- ui
	-- ===============================

	-- 初始化界面
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "marchNoHeroWarning.json")
	local content_ = wigetRoot:getChildByName("Panel_4")

	content_:getChildByName("Label_15"):setString(hp.lang.getStrByID(5086))

	content_:getChildByName("Label_25"):setString(hp.lang.getStrByID(5087))

	content_:getChildByName("Label_26"):setString(hp.lang.getStrByID(5088))

	local cancel_ = content_:getChildByName("Image_18_0")
	cancel_:getChildByName("Label_19"):setString(hp.lang.getStrByID(5090))

	local march_ = content_:getChildByName("Image_18")
	march_:getChildByName("Label_19"):setString(hp.lang.getStrByID(5089))

	-- 头像
	content_:getChildByName("Image_24"):loadTexture(config.dirUI.heroHeadpic..player.hero.getBaseInfo().sid..".png")

	-- call back
	local function OnBtnCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function OnMarchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			callBack_()
			self:close()
		end
	end

	local function onAddHeroMarchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			callBack_(true)
			self:close()
		end
	end 

	content_:getChildByName("Image_16"):addTouchEventListener(OnBtnCloseTouched)
	cancel_:addTouchEventListener(onAddHeroMarchTouched)
	march_:addTouchEventListener(OnMarchTouched)

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end