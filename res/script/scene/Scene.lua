--
-- scene/Scene.lua
-- 场景基类
--================================================
require "obj/hintFrameMgr"
require "ui/common/hintFrame"

Scene = Scene or class("Scene")

local HINT_FRAME_NUM_AT_ONE_TIME = 3

--
-- ctor
-------------------------------
function Scene:ctor()
	self.heartbeatInterval = config.interval.sceneHeartbeat
	
	self.super.init(self)
	self:init()
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
	self.scene:addChild(self.layer)
	self.scene:addChild(self.msgLayer)

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
		elseif "exit" == event then
			self.scene:unregisterScriptHandler()
			if game.application:getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
				self.layer:unregisterScriptKeypadHandler()
			end
			self.scene:unscheduleUpdate()
			self:onExit()
        end
	end
	self.scene:registerScriptHandler(onSceneEvent)

	-- Android OS, catch Keypad event
	if game.application:getTargetPlatform()==cc.PLATFORM_OS_ANDROID then
		local function onKeypadEvent(event)
			if event=="backClicked" or event==nil then
				require("ui/msgBox/warningMsgBox")
				local msgBox =  UI_warningMsgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(11),
									hp.lang.getStrByID(6035), hp.lang.getStrByID(6036), game.over)
				self:addModalUI(msgBox, 1000)
			end
		end
		self.layer:setKeypadEnabled(true)
		self.layer:registerScriptKeypadHandler(onKeypadEvent)
	end

	-- ui
	self.uis = {} -- 数组，ui集合
	self.uiTickCount = 0
	-- msg
	self.manageMsg = {}

	-- hint msg init
	self.hintFrames = {}
	for i = 1, HINT_FRAME_NUM_AT_ONE_TIME do
		ui_ = UI_hintFrame.new()
		self:addMsgUI(ui_.wigetRoot)
		self.hintFrames[i] = ui_
	end
	hintFrameMgr.attachHintFrame(self.hintFrames)
end


--
-- preEnter
----------------------------
function Scene:preEnter()
end


--
-- onEnter
----------------------------
function Scene:onEnter()
end


--
-- preExit
----------------------------
function Scene:preExit()
	self:unregistAllMsg()
	for i,v in ipairs(self.uis) do
		v:onRemove()
	end
	hintFrameMgr.detachHintFrame()

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
	self:preEnter()
	
	if game.director:getRunningScene() == nil then
		game.director:runWithScene(self.scene)
	else
		game.curScene:preExit()
		game.director:replaceScene(self.scene)
	end
	
	game.curScene = self
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
end


function Scene.showMsg(param_)	
	hintFrameMgr.popHintFrame(param_)
end