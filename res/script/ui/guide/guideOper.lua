--
-- ui/guide/guideOper.lua
-- 引导操作界面
--===================================
require "ui/UI"


UI_guideOper = class("UI_guideOper", UI)



--init
function UI_guideOper:init(guideInfo)
	-- data
	-- ===============================
	local bindBuild = nil
	local bindNode = nil
	local bindTouchedFun = nil

	--
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "guideOper.json")

	-- 
	self:addCCNode(widgetRoot)

	--
	--================
	local panelCont = widgetRoot:getChildByName("Panel_cont")
	local pointImg = panelCont:getChildByName("Image_point")
	local touchImg = panelCont:getChildByName("Image_touchPoint")

	-- 放置箭头
	local function posPoint()
		local px, py = touchImg:getPosition()
		local sz = touchImg:getSize()
		if guideInfo.pointDir==1 then
			pointImg:setRotation(0)
			pointImg:setPosition(px, py-sz.height/2)
		elseif guideInfo.pointDir==2 then
			pointImg:setRotation(180)
			pointImg:setPosition(px, py+sz.height/2)
		elseif guideInfo.pointDir==3 then
			pointImg:setRotation(90)
			pointImg:setPosition(px-sz.width/2, py)
		elseif guideInfo.pointDir==4 then
			pointImg:setRotation(270)
			pointImg:setPosition(px+sz.width/2, py)
		end
	end
	-- 箭头呼吸动画
	local aUp = cc.ScaleTo:create(0.8, 1.2*hp.uiHelper.RA_scale)
	local aDown = cc.ScaleTo:create(0.4, 1.0*hp.uiHelper.RA_scale)
	local scaleSq = cc.Sequence:create(aUp, aDown)
	local scaleRep = cc.RepeatForever:create(scaleSq)
	pointImg:runAction(scaleRep)

	-- 边框
	if guideInfo.type==2 then
		game.curScene:removeAllUI()
		game.curScene:removeAllModalUI()
		bindBuild = game.curScene:getBuilding(guideInfo.bType, guideInfo.bSid)
		bindBuild:Scroll2Here(1)
		posPoint()

		local actLight = cc.TintTo:create(0.4, 255, 255, 0)
		local actDark = cc.TintTo:create(0.8, 192, 192, 192)
		local actBuild = cc.RepeatForever:create(cc.Sequence:create(actDark, actLight))
		bindBuild.ccNode:runAction(actBuild)
	end
	-- 点击处理
	local function btnOnTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			touchImg:setTouchEnabled(false)
		end
		
		if guideInfo.type==2 then
		--处理地块
			if eventType==TOUCH_EVENT_BEGAN then
				bindBuild:onFocus()
			elseif eventType==TOUCH_EVENT_MOVED then
				if sender:hitTest(sender:getTouchMovePos())==true then
					bindBuild:onFocus()
				else
					bindBuild:onLostFocus()
				end
			else
				if eventType==TOUCH_EVENT_ENDED then
					bindBuild:onClicked()
					bindBuild.ccNode:stopAllActions()
					bindBuild.ccNode:setColor(cc.c3b(255, 255, 255))
					player.guide.step(guideInfo.step)
				else
					bindBuild:onLostFocus()
				end
			end
		else
		-- 处理按钮
			bindTouchedFun(bindNode, eventType)
		end
	end
	touchImg:addTouchEventListener(btnOnTouched)

	local function bindNodeFun(ccNode, nodeTouchedFun)
		local p1= ccNode:convertToWorldSpace(cc.p(0, 0))
		local sz = ccNode:getSize()
		local p2 = ccNode:convertToWorldSpace(cc.p(sz.width, sz.height))
		sz = cc.size(p2.x-p1.x, p2.y-p1.y)
		local p = cc.p(p1.x+sz.width/2, p1.y+sz.height/2)

		touchImg:setPosition(p)
		touchImg:setSize(sz)
		touchImg:setScale(1.0)
		posPoint()

		local touchWave = hp.sequenceAniHelper.createAnimSprite("common", "touchWave", 12, 0.1)
		touchWave:setPosition(sz.width/2, sz.height/2)
		if guideInfo.pointDir==1 then
			touchWave:setRotation(180)
		elseif guideInfo.pointDir==2 then
			touchWave:setRotation(0)
		elseif guideInfo.pointDir==3 then
			touchWave:setRotation(270)
		elseif guideInfo.pointDir==4 then
			touchWave:setRotation(90)
		end
		touchImg:addChild(touchWave)

		bindNode = ccNode
		bindTouchedFun = nodeTouchedFun
	end
	self.bindNodeFun = bindNodeFun

	--
	-- 文字描述
	if guideInfo.desc~="-1" then
		local textNode = panelCont:getChildByName("Label_text")
		textNode:setString(guideInfo.desc)
		textNode:setVisible(true)
		widgetRoot:getChildByName("Panel_textBg"):setVisible(true)
	end
end


function UI_guideOper:onBind2Node(ccNode_, nodeTouchedFun_)
	self.bindNodeFun(ccNode_, nodeTouchedFun_)
end