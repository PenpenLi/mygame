--
-- ui/guide/noviceGift.lua
-- 引导对话界面
--===================================
require "ui/UI"


UI_noviceGift = class("UI_noviceGift", UI)


--init
function UI_noviceGift:init()
	-- data
	-- ===============================

	--
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "noviceGift.json")

	-- 
	self:addCCNode(widgetRoot)

	--
	--================
	local panelCont = widgetRoot:getChildByName("Panel_cont")
	local labelDesc = panelCont:getChildByName("Label_desc")
	local gift1Name = panelCont:getChildByName("Image_giftBg1"):getChildByName("Label_name")
	local gift2Name = panelCont:getChildByName("Image_giftBg2"):getChildByName("Label_name")
	local getBtn = panelCont:getChildByName("Image_get")
	local animPos = widgetRoot:getChildByName("Panel_frame"):getChildByName("Label_animPos")
	labelDesc:setString(hp.lang.getStrByID(9301))
	gift1Name:setString(hp.lang.getStrByID(9302))
	gift2Name:setString(hp.lang.getStrByID(9303))
	getBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(1413))

	local function onHttpResponse(status, response, tag)
		if status==200 then
			player.guide.getGift()
			self:close()
		end
	end
	local function onGetTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 22
			oper.type = 3
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onHttpResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end
	getBtn:addTouchEventListener(onGetTouched)

	-- 烟花动画
	--local cloud = hp.sequenceAniHelper.createAnimSprite_byPng("yanhua", 14, 0.08, true)
	local cloud = hp.sequenceAniHelper.createAnimSprite("common", "yanhua", 14, 0.08)
	--cloud:updateDisplayedColor(cc.c3b(255, 128, 128))
	cloud:setScale(2)
	cloud:setPosition(200, 0)
	animPos:addChild(cloud)
	--cloud = hp.sequenceAniHelper.createAnimSprite_byPng("yanhua", 14, 0.07, true)
	cloud = hp.sequenceAniHelper.createAnimSprite("common", "yanhua", 14, 0.07)
	--cloud:updateDisplayedColor(cc.c3b(192, 255, 192))
	cloud:setScale(2)
	cloud:setPosition(-160, -40)
	animPos:addChild(cloud)
	--cloud = hp.sequenceAniHelper.createAnimSprite_byPng("yanhua", 14, 0.1, true)
	cloud = hp.sequenceAniHelper.createAnimSprite("common", "yanhua", 14, 0.1)
	--cloud:updateDisplayedColor(cc.c3b(168, 168, 255))
	cloud:setScale(2)
	cloud:setPosition(0, -60)
	animPos:addChild(cloud)
	--cloud = hp.sequenceAniHelper.createAnimSprite_byPng("yanhua", 14, 0.11, true)
	cloud = hp.sequenceAniHelper.createAnimSprite("common", "yanhua", 14, 0.11)
	cloud:setScale(2)
	cloud:setPosition(20, 90)
	animPos:addChild(cloud)
end
