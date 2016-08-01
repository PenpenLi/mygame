--
-- scene/Scene.lua
-- 场景基类
--================================================
require "ui/common/hintFrame"
require "ui/common/httpErrorHint"

Scene = Scene or class("Scene")

local HINT_FRAME_NUM_AT_ONE_TIME = 3

--
-- ctor
-------------------------------
function Scene:ctor(...)
	self.heartbeatInterval = config.interval.sceneHeartbeat
	
	self.super.init(self)
	self:init(...)
end


--
-- init
----------------------------
function Scene:init()
	self.valid = true --是否有效

	-- create scene and layer
	self.scene = cc.Scene:create()
	self.layer = cc.Layer:create()
	self.msgLayer = cc.Layer:create()
	self.noticeLayer = cc.Layer:create()
	self.scene:addChild(self.layer)
	self.scene:addChild(self.msgLayer)
	self.scene:addChild(self.noticeLayer)

	-- regist heartbeat
	local tickCount = 0
	local function sceneTick(dt)
		tickCount = tickCount+dt
		if tickCount >= self.heartbeatInterval then
			self:heartbeat(tickCount)
			tickCount = 0
		end
	end
	
	-- catch event
	local function onSceneEvent(event)
		if "enter" == event then
			self:onEnter()
			self.scene:scheduleUpdateWithPriorityLua(sceneTick, 1)

			-- Android OS, catch Keypad event
			if game.application:getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
				local function onKeypadEvent(event)
					if event=="backClicked" or event==nil then
						if self.quitDlg == nil then
							require("ui/msgBox/warningMsgBox")
							local function onCancel()
								self.quitDlg = nil
							end
							self.quitDlg =  UI_warningMsgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(11),
												hp.lang.getStrByID(6035), hp.lang.getStrByID(6036), game.over, onCancel)
							self:addModalUI(self.quitDlg, 1000)
						else
							self:removeModalUI(self.quitDlg)
							self.quitDlg = nil
						end
					end
				end
				self.layer:setKeyboardEnabled(true)
				self.layer:registerScriptKeypadHandler(onKeypadEvent)
			end

			-- 
			-- [[ touchLayer ]]
			-- 获取并处理地图上的点击事件
			--==============================================
			local touchLayer = cc.Layer:create()
			self.scene:addChild(touchLayer)
			local touchX = 0
			local touchY = 0
			local mvSp = 40*hp.uiHelper.RA_scale
			local function touchLayerOnTouched(event, px, py)
				if event=="began" then
					touchX = px
					touchY = py
					touchLayer:removeAllChildren()
				elseif event=="moved" then
					local x = touchX-px
					local y = touchY-py
					if x>mvSp or x<-mvSp or y>mvSp or y<-mvSp then
						touchX = px
						touchY = py
					else
						return
					end
				elseif event=="ended" then
					return true
				elseif event=="cancelled" then
					return true
				end

				local emitter = cc.ParticleSystemQuad:create(config.dirUI.particle .. "touch.plist")
				emitter:setAnchorPoint(0, 0)
				emitter:setPosition(px, py)
				touchLayer:addChild(emitter)
				return true --must
			end
			touchLayer:setTouchEnabled(true)
			touchLayer:registerScriptTouchHandler(touchLayerOnTouched, false, 0, false)
		elseif "exit" == event then
			self.scene:unregisterScriptHandler()
			if game.application:getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
				self.layer:unregisterScriptKeypadHandler()
				self.layer:setKeyboardEnabled(false)
			end
			self.scene:unscheduleUpdate()
			self:onExit()
        end
	end
	self.scene:registerScriptHandler(onSceneEvent)

	-- ui
	self.uis = {} -- 数组，ui集合
	self.uiTickCount = 0
	-- msg
	self.manageMsg = {}

	-- hint msg init
	self.hintFrames = {}
	for i = 1, HINT_FRAME_NUM_AT_ONE_TIME do
		local ui_ = UI_hintFrame.new()
		self:addMsgUI(ui_.layer)
		self.hintFrames[i] = ui_
	end
	self.hintFrameMgr = require("obj/hintFrameMgr")
	self.hintFrameMgr.attachHintFrame(self.hintFrames)

	-- http error hint
	self.httpErrorFrames = {}
	for i = 1, 1 do
		local ui_ = UI_httpErrorHint.new()
		self:addMsgUI(ui_.layer)
		self.httpErrorFrames[i] = ui_
	end
	self.httpErrorHint = require("obj/hintFrameMgr1")
	self.httpErrorHint.attachHintFrame(self.httpErrorFrames)

	self:initSysNotice()
end


-- 系统公告
function Scene:initSysNotice()
	-- 位置参数
	local marginTop = 220
	local marginL = 100
	local barHeight = 90

	-- 背景
	local noticeBar = cc.Sprite:create(config.dirUI.common .. "sys_notice_bar.png")
	noticeBar:setAnchorPoint(0, 0)
	noticeBar:setPosition(0, game.visibleSize.height-marginTop*hp.uiHelper.RA_scaleY)
	noticeBar:setScaleX(hp.uiHelper.RA_scaleX)
	noticeBar:setScaleY(hp.uiHelper.RA_scaleY)

	-- 文字
	local noticeClipper = cc.ClippingNode:create()
	local noticeLabel = cc.Label:createWithTTF("", "font/main.ttf", math.ceil(26*hp.uiHelper.RA_scale))
	noticeLabel:setTextColor(cc.c4b(107, 229, 225, 255))
    local w = game.visibleSize.width - marginL*hp.uiHelper.RA_scaleX
    local h = hp.uiHelper.RA_scaleY*barHeight
    local stencilDraw = cc.DrawNode:create()
    local ps = { cc.p( 0, 0), cc.p(w, 0), cc.p(w, h), cc.p(0, h) }
    stencilDraw:drawPolygon(ps, table.getn(ps), cc.c4f(1,0,0,1), 0, cc.c4f(0,0,0,0))
	noticeClipper:setStencil(stencilDraw)
	noticeClipper:setPosition(marginL*hp.uiHelper.RA_scaleX, game.visibleSize.height-marginTop*hp.uiHelper.RA_scaleY)
	noticeLabel:setAnchorPoint(0, 0.5)
	noticeLabel:setPosition(w, h/2)
	noticeClipper:addChild(noticeLabel)

	noticeBar:setOpacity(0)

	self.noticeLayer:addChild(noticeBar)
	self.noticeLayer:addChild(noticeClipper)
	self.noticeBar = noticeBar
	self.noticeLabel = noticeLabel
	self.noticeViewSize = cc.size(w, h)
	self.noticeBarStatus = 0 -- 0:隐藏 1:显示
	self:showSysNotice()

	self:registMsg(hp.MSG.CHATINFO_NEW)
end

--
-- preEnter
----------------------------
function Scene:preEnter()
	if self.quitDlg then
	-- 关闭退出对话框
		self:removeModalUI(self.quitDlg)
		self.quitDlg = nil
	end
end


--
-- onEnter
----------------------------
function Scene:onEnter()
end

--
-- onEnterAnim
----------------------------
function Scene:onEnterAnim()
	-- 捕获所有触摸消息, 播放动画过程中，不允许点击
	local animLayer = cc.Layer:create()
	animLayer:setTouchEnabled(true)
	animLayer:registerScriptTouchHandler(function(...) return true end)
	local function onAnimFinished()
		self:removeCCNode(animLayer)
	end
	local cloud = hp.sequenceAniHelper.createAnimSprite_byPng("clouds", 13, 0.1, false, onAnimFinished)
	cloud:setScaleX(hp.uiHelper.RA_scaleX * 2)
	cloud:setScaleY(hp.uiHelper.RA_scaleY * 2)
	cloud:setAnchorPoint(0, 0)
	animLayer:addChild(cloud)
	self:addCCNode(animLayer)
end

--
-- preExit
----------------------------
function Scene:preExit()
	self:unregistAllMsg()
	for i,v in ipairs(self.uis) do
		v:onRemove()
	end
	self.hintFrameMgr.detachHintFrame()
	self.httpErrorHint.detachHintFrame()

	self.valid = false
end

-- isValid
function Scene:isValid()
	return self.valid
end

--
-- onExit
----------------------------
function Scene:onExit()
end


--
-- heartbeat
----------------------------
function Scene:heartbeat(dt)
	-- 执行所有ui的heartbeat
	self.uiTickCount = self.uiTickCount+dt
	if self.uiTickCount>=config.interval.uiHeartbeat then
		for i, ui in ipairs(self.uis) do
			ui:heartbeat(self.uiTickCount)
		end
		self.uiTickCount = 0
	end
end



--
-- public functions
--==============================================

--
-- enter
----------------------------
function Scene:enter()
	local tick_ = os.clock()
	self:preEnter()
	
	if game.director:getRunningScene() == nil then
		game.director:runWithScene(self.scene)
	else
		game.curScene:preExit()
		game.director:replaceScene(self.scene)
	end
	
	game.curScene = self
	player.clockEnd("Scene:enter", tick_, 0.2)
end

--
-- addCCNode
----------------------------
function Scene:addCCNode(ccNode_)
	self.layer:addChild(ccNode_)
end

--
-- removeCCNode
----------------------------
function Scene:removeCCNode(ccNode_)
	self.layer:removeChild(ccNode_)
end

--
-- addUI
-- ui_ : ui/UI
----------------------------
function Scene:addUI(ui_)
	ui_.uiType_ = 0
	ui_:onAdd(self)
	self.layer:addChild(ui_.layer)
	table.insert(self.uis, ui_)
end

--
-- removeUI
-- ui_ : ui/UI
----------------------------
function Scene:removeUI(ui_)
	for i,ui in ipairs(self.uis) do
		if ui_==ui then
			table.remove(self.uis, i)

			ui_:onRemove()
			self.layer:removeChild(ui_.layer)
			break
		end
	end
end

--
-- addModalUI
-- ui_ : ui/UI
----------------------------
function Scene:addModalUI(ui_, zOrder_)
	ui_.uiType_ = 1
	ui_:onAdd(self)
	if zOrder_~=nil then
		self.layer:addChild(ui_.layer, zOrder_)
	else
		self.layer:addChild(ui_.layer)
	end
	table.insert(self.uis, ui_)
end

--
-- removeModalUI
-- ui_ : ui/UI
----------------------------
function Scene:removeModalUI(ui_)
	for i,ui in ipairs(self.uis) do
		if ui_==ui then
			table.remove(self.uis, i)

			ui_:onRemove()
			self.layer:removeChild(ui_.layer)
			break
		end
	end
end

function Scene:closeAllUI()
	self:removeAllModalUI()
	self:removeAllUI()
end

--
-- addMsgUI
-- ui_ : ui/UI
----------------------------
function Scene:addMsgUI(ui_)
	self.msgLayer:addChild(ui_)
end


--
-- 消息处理
--=============================================
-- registMsg
function Scene:registMsg(msg_)
	if hp.msgCenter.addMsgMgr(msg_, self) then
		table.insert(self.manageMsg, msg_)
	end
end

-- unregistMsg
function Scene:unregistMsg(msg_)
	if hp.msgCenter.removeMsgMgr(msg_, self) then
		for i,v in ipairs(self.manageMsg) do
			if v==msg_ then
				table.remove(self.manageMsg, i)
			end
		end
	end
end

-- unregistMsg
function Scene:unregistAllMsg()
	for i,v in ipairs(self.manageMsg) do
		hp.msgCenter.removeMsgMgr(v, self)
	end

	self.manageMsg = {}
end

-- onMsg
function Scene:onMsg(msg_, parm_)
	if msg_==hp.MSG.CHATINFO_NEW then
		if parm_.type==6 then
			self:showSysNotice()
		end
	end
end


function Scene.showMsg(param_)	
	game.curScene.hintFrameMgr.popHintFrame(param_)
end

function Scene.showHttpErrorMsg(param_)	
	game.curScene.httpErrorHint.popHintFrame(param_)
end

-- 系统公告
function Scene:showSysNotice()
	local curNoticeInfo = player.chatRoom.curShowNotice()
	if curNoticeInfo~=nil and self.noticeBarStatus==0 then
		self.noticeBarStatus = 1
		local noticeBar = self.noticeBar
		local noticeLabel = self.noticeLabel
		local noticeViewSize = self.noticeViewSize

		local function resetNotice()
			noticeBar:stopAllActions()
			noticeBar:setOpacity(255)

			noticeLabel:stopAllActions()
			noticeLabel:setString(curNoticeInfo.text)
			noticeLabel:setPosition(noticeViewSize.width, noticeViewSize.height/2)

			local noticeLen = self.noticeLabel:getContentSize().width
			local at = 5+noticeLen/(100*hp.uiHelper.RA_scaleX)
			local mvAction = cc.MoveTo:create(at, cc.p(-noticeLen-20, self.noticeViewSize.height/2))
			local function checkNextNotice()
				curNoticeInfo = player.chatRoom.nextShowNotice()
				if curNoticeInfo~=nil then
					resetNotice()
				else
					local hideAct = cc.FadeOut:create(2)
					noticeBar:runAction(hideAct)
					noticeLabel:setString("")
					self.noticeBarStatus = 0
				end
			end

			local act = cc.Sequence:create(mvAction, cc.CallFunc:create(checkNextNotice))
			noticeLabel:runAction(act)
		end
		resetNotice()
	end
end