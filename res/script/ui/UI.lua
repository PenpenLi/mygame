--
-- ui/UI.lua
--
--================================================


UI = UI or class("UI")

--
-- auto functions
--==============================================

-- ctor
function UI:ctor(...)
	self.parent = nil
	
	self.super.init(self)
	self:init(...)
end

-- init
function UI:init()
	self.layer = ccui.Layout:create()
	self.uiLayer = ccui.Layout:create()
	self.loadingLayer = ccui.Layout:create()
	self.layer:addChild(self.uiLayer)
	self.layer:addChild(self.loadingLayer)
	self.frameNode = self.uiLayer
	self.isFrame = false	--是否为框架ui
	self.valid = true --是否有效
	
	self.loadingLayer:setSize(cc.size(0, 0))
	self.loadingNum = 0
	-- 子ui
	self.children = {}
	-- msg
	self.manageMsg = {}
end

-- onAdd
function UI:onAdd(parent_)
	self.parent = parent_
end

-- onRemove
function UI:onRemove()
	for i, v in ipairs(self.children) do
		v:onRemove()
	end

	self:unregistAllMsg()
	self.valid = false
end

-- isValid
function UI:isValid()
	return self.valid
end

-- heartbeat
function UI:heartbeat(dt)
	for i,v in ipairs(self.children) do
		v:heartbeat(dt)
	end
end

--
-- public functions
--==============================================

--
-- close
----------------------------
function UI:close()
	if self.valid then
		if self.uiType_==-1 then
			self.parent:close()
		elseif self.uiType_==0 then
			self.parent:removeUI(self)
		elseif self.uiType_==1 then
			self.parent:removeModalUI(self)
		end
	end
end

function UI:closeAll()
	local scene = nil
	if self.uiType_==-1 then
		scene = self.parent.parent
	else
		scene = self.parent
	end

	scene:removeAllModalUI()
	scene:removeAllUI()
end


--
-- addCCNode
----------------------------
function UI:addCCNode(ccNode_)
	hp.uiHelper.uiAdaption(ccNode_)
	self.frameNode:addChild(ccNode_)
end

--
-- removeCCNode
----------------------------
function UI:removeCCNode(ccNode_)
	self.frameNode:removeChild(ccNode_)
end

--
-- addChildUI
----------------------------
function UI:addChildUI(ui_)
	ui_.uiType_ = -1
	ui_:onAdd(self)
	self.frameNode:addChild(ui_.layer)
	table.insert(self.children, ui_)

	if ui_.isFrame then
		-- 如果该子ui是框架，将frameNode设置为该ui的根节点
		-- 注意：框架ui只能有一个，并且必须第一个被添加
		self.frameNode = ui_.wigetRoot
	end
end

--
-- removeChildUI
----------------------------
function UI:removeChildUI(ui_)
	for i,ui in ipairs(self.children) do
		if ui_==ui then
			table.remove(self.children, i)

			ui_:onRemove()
			self.frameNode:removeChild(ui_.layer)
			break
		end
	end
end


--
-- addUI
----------------------------
function UI:addUI(ui_)
	local scene = nil
	if self.uiType_==-1 then
		scene = self.parent.parent
	else
		scene = self.parent
	end
	
	scene:addUI(ui_)
end

--
-- removeUI
----------------------------
function UI:removeUI(ui_)
	local scene = nil
	if self.uiType_==-1 then
		scene = self.parent.parent
	else
		scene = self.parent
	end

	scene:removeUI(ui_)
end

--
-- addModalUI
-- @ui_ :UI
-- @zOrder_ : 100--guide; 1000--exitMsgBox
----------------------------
function UI:addModalUI(ui_, zOrder_)
	local scene = nil
	if self.uiType_==-1 then
		scene = self.parent.parent
	else
		scene = self.parent
	end

	scene:addModalUI(ui_, zOrder_)
end

--
-- removeModalUI
----------------------------
function UI:removeModalUI(ui_)
	local scene = nil
	if self.uiType_==-1 then
		scene = self.parent.parent
	else
		scene = self.parent
	end

	scene:removeModalUI(ui_)
end

--
-- 消息处理
--=============================
-- registMsg
function UI:registMsg(msg_)
	if hp.msgCenter.addMsgMgr(msg_, self) then
		table.insert(self.manageMsg, msg_)
	end
end

-- unregistMsg
function UI:unregistMsg(msg_)
	if hp.msgCenter.removeMsgMgr(msg_, self) then
		for i,v in ipairs(self.manageMsg) do
			if v==msg_ then
				table.remove(self.manageMsg, i)
			end
		end
	end
end

-- unregistAllMsg
function UI:unregistAllMsg()
	for i,v in ipairs(self.manageMsg) do
		hp.msgCenter.removeMsgMgr(v, self)
	end

	self.manageMsg = {}
end

-- onMsg
function UI:onMsg(msg_, parm_)
end

-- showLoading
function UI:showLoading(cmdSender_, operNode_)
	local p
	if operNode_==nil then
		p = cc.p(game.visibleSize.width/2, game.visibleSize.height/2)
	else
		local p1= operNode_:convertToWorldSpace(cc.p(0, 0))
		local sz = operNode_:getSize()
		local p2 = operNode_:convertToWorldSpace(cc.p(sz.width, sz.height))
		sz = cc.size(p2.x-p1.x, p2.y-p1.y)
		p = cc.p(p1.x+sz.width/2, p1.y+sz.height/2)
	end

	local loadingNode = hp.sequenceAniHelper.createAnimSprite("common", "loading", 9, 0.1)
	loadingNode:setPosition(p)
	self.loadingLayer:addChild(loadingNode)
	self.loadingNum = self.loadingNum+1
	if self.loadingNum==1 then
		self.loadingLayer:setSize(game.visibleSize)
		local menuUI = game.curScene.mainMenu
		if menuUI~=nil then
			menuUI.loadingLayer:setSize(game.visibleSize)
		end
	end

	cmdSender_:bindLoadingUI(self, loadingNode)
end

-- hideLoading
function UI:hideLoading(loadingNode_)
	if not self:isValid() then
	-- 界面或许已经关闭
		local menuUI = game.curScene.mainMenu
		if menuUI~=nil then
			menuUI.loadingLayer:setSize(cc.size(0, 0))
		end
		return
	end

	self.loadingNum = self.loadingNum-1
	if self.loadingNum<=0 then
		self.loadingLayer:setSize(cc.size(0, 0))
		local menuUI = game.curScene.mainMenu
		if menuUI~=nil then
			menuUI.loadingLayer:setSize(cc.size(0, 0))
		end
	end

	self.loadingLayer:removeChild(loadingNode_)
end
