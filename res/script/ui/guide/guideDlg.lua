--
-- ui/guide/guideDlg.lua
-- 引导对话界面
--===================================
require "ui/UI"


UI_guideDlg = class("UI_guideDlg", UI)



--init
function UI_guideDlg:init(guideInfo)
	-- data
	-- ===============================

	--
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "guideDlg.json")

	-- 
	self:addCCNode(widgetRoot)

	--
	--================
	local panelCont = widgetRoot:getChildByName("Panel_cont")
	local panelFrame = widgetRoot:getChildByName("Panel_frame")

	-- 边框动画
	local borderImg = panelCont:getChildByName("Image_border")
	local touchWave = hp.sequenceAniHelper.createAnimSprite("common", "touchWave", 12, 0.1)
	touchWave:setScaleY(-1)
	borderImg:addChild(touchWave)

	-- 箭头呼吸动画
	local pointImg = panelCont:getChildByName("Image_point")
	local aUp = cc.ScaleTo:create(0.8, 1.2*hp.uiHelper.RA_scale)
	local aDown = cc.ScaleTo:create(0.4, 1.0*hp.uiHelper.RA_scale)
	local scaleSq = cc.Sequence:create(aUp, aDown)
	local scaleRep = cc.RepeatForever:create(scaleSq)
	pointImg:runAction(scaleRep)


	local btnStep = panelCont:getChildByName("Image_continue")
	local function btnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			player.guide.step(guideInfo.step)
		end
	end
	btnStep:addTouchEventListener(btnOnTouched)

	if guideInfo.guiderImg~="-1" then
		panelCont:getChildByName("Image_guider"):loadTexture(config.dirUI.common .. guideInfo.guiderImg)
	end

	-- 文字描述
	local descLabel = panelCont:getChildByName("Label_text")
	descLabel:setString(guideInfo.desc)
	-- --背景
	-- if guideInfo.step==6001 then
	-- 	descLabel:setColor(cc.c3b(255, 255, 255))
	-- 	panelFrame:getChildByName("Image_bg"):loadTexture(config.dirUI.common .. "dlg_bg_red.png")
	-- 	btnStep:loadTexture(config.dirUI.common .. "button_red.png")
	-- elseif guideInfo.step==9001 then
	-- 	panelFrame:getChildByName("Image_bg"):loadTexture(config.dirUI.common .. "dlg_bg_yellow.png")
	-- 	btnStep:loadTexture(config.dirUI.common .. "button_yellow.png")
	-- end
end
