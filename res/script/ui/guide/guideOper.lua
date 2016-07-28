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
	local panelFrame = widgetRoot:getChildByName("Panel_frame")
	local panelCont = widgetRoot:getChildByName("Panel_cont")
	local bgImg = panelFrame:getChildByName("Image_bg")
	local pointImg = panelCont:getChildByName("Image_point")
	local touchImg = panelCont:getChildByName("Image_touchPoint")
	local bLeft = touchImg:getChildByName("Image_left")
	local bTop = touchImg:getChildByName("Image_top")
	local bRight = touchImg:getChildByName("Image_right")
	local bBottom = touchImg:getChildByName("Image_bottom")

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
			pointImg:setRotation(px+sz.width/2, py)
		end
	end
	-- 箭头呼吸动画
	local aUp = cc.ScaleTo:create(1, 1.1*hp.uiHelper.RA_scale)
	local aDown = cc.ScaleTo:create(0.5, 1.0*hp.uiHelper.RA_scale)
	local scaleSq = cc.Sequence:create(aUp, aDown)
	local scaleRep = cc.RepeatForever:create(scaleSq)
	pointImg:runAction(scaleRep)
	-- 边框
	if guideInfo.type==2 then
	-- 隐藏边框
		bLeft:setVisible(false)
		bTop:setVisible(false)
		bRight:setVisible(false)
		bBottom:setVisible(false)

		game.curScene:removeAllUI()
		game.curScene:removeAllModalUI()
		bindBuild = game.curScene:getBuilding(guideInfo.bType, guideInfo.bSid)
		bindBuild:Scroll2Here(1)
		posPoint()
	else
		-- 边框动画
		local aOut = cc.FadeOut:create(1)
		local aIn = cc.FadeIn:create(0.5)
		local aSq = cc.Sequence:create(aOut, aIn)
		local aRep = cc.RepeatForever:create(aSq)
		bLeft:runAction(aRep)
		bTop:runAction(aRep:clone())
		bRight:runAction(aRep:clone())
		bBottom:runAction(aRep:clone())
	end
	-- 点击处理
	local function btnOnTouched(sender, eventType)
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

		bgImg:setPosition(p)
		touchImg:setPosition(p)
		touchImg:setSize(sz)
		touchImg:setScale(1.0)
		local bSz = bLeft:getSize()
		bSz.width = bSz.width*hp.uiHelper.RA_scale
		bSz.height = sz.height + bSz.width
		bLeft:setPosition(0, sz.height/2)
		bLeft:setSize(bSz)
		bRight:setPosition(sz.width, sz.height/2)
		bRight:setSize(bSz)
		bSz.height = sz.width + bSz.width
		bTop:setPosition(sz.width/2, sz.height)
		bTop:setSize(bSz)
		bBottom:setPosition(sz.width/2, 0)
		bBottom:setSize(bSz)
		posPoint()

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