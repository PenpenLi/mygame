--
-- ui/battle/battleResult.lua
-- 战斗结果展示
--================================================

UI_battleResult = class("UI_battleResult", UI)

--init
function UI_battleResult:init(winState_, battleUI_)
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "battleResult.json")
	local panelCont = wigetRoot:getChildByName("Panel_cont")
	local text1 = panelCont:getChildByName("Label_text1")
	local text2 = panelCont:getChildByName("Label_text2")
	local animWinPos = panelCont:getChildByName("Panel_animWin")
	local animFailPos = panelCont:getChildByName("Panel_animFail")
	local btnOk = panelCont:getChildByName("Image_ok")
	local textOk = btnOk:getChildByName("Label_text")

	textOk:setString(hp.lang.getStrByID(1209))

	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			battleUI_:close()
		end
	end
	btnOk:addTouchEventListener(onConfirmTouched)

	if winState_==1 then
		local ani_ = hp.sequenceAniHelper.createAnimSprite("copy", "win", 13, 0.12, 2)
   		ani_:setScale(2)
		animWinPos:addChild(ani_)
	else
		animFailPos:addChild(hp.sequenceAniHelper.createAnimSprite("copy", "fail", 13, 0.12, 2))
		wigetRoot:getChildByName("Panel_frame"):getChildByName("Image_bg"):loadTexture(config.dirUI.common .. "copy_25_1.png")
		text1:setString(hp.lang.getStrByID(5315))
		text2:setString(hp.lang.getStrByID(5316))
	end

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
