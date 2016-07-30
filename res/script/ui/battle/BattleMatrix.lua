--
-- ui/battle/BattleMatrix.lua
-- 军队方阵
--================================================

local battleCfg = require("ui/battle/battleCfg")


 -- 战斗动画类，方阵中的具体一个动画
 -- ===============================
local BattleAnim = class("BattleAnim")

-- getSpriteFrames
local function getSpriteFrames(name_, fn_)
	local frames = {}
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(string.format("%s%s/%s.plist", config.dirUI.animation, "battle", name_))
	for i=1, fn_ do
		local strName = string.format("animation/%s/%s/%d.png", "battle", name_, i)
		local frame = frameCache:getSpriteFrame(strName)
		if frame==nil then
			cclog_("getSpriteFrames=================", strName)
		else
			table.insert(frames, frame)
		end
	end

	return frames
end

--
-- ctor
-------------------------------
function BattleAnim:ctor(animInfo_, dir_)
	self.animInfo = animInfo_
	self.dir = dir_

	self.actionframes = {}
	self.actions = {}
	self.curAction = nil

	self:init()
end

--
-- init
-------------------------------
function BattleAnim:init()
	self:initAction("advance")
	self.spriteNode = cc.Sprite:createWithSpriteFrame( self.actionframes["advance"][1] )
	--self.spriteNode:setScale(0.5)
end

-- initAction
-- 初始化帧动画
function BattleAnim:initAction(actionName_)
	local animInfo = self.animInfo
	local strTmp = animInfo[actionName_]
	if strTmp==nil or strTmp=="-1" then
	-- 没有此动作
		return false
	end

	strTmp = string.format("%s%d", strTmp, self.dir)
	local fn = animInfo[actionName_.."Fn"]
	local ft = animInfo[actionName_.."Ft"]/1000

	local frames = getSpriteFrames(strTmp, fn)
	local animation = cc.Animation:createWithSpriteFrames(frames, ft)
	local animate = cc.Animate:create(animation)

	self.actionframes[actionName_] = frames
	self.actions[actionName_] = animate
	return true
end


-- stand
-- 执行前进动作动画
function BattleAnim:stand()
	self:stopAction()

	if self:initAction("stand") then
		self.curAction = cc.RepeatForever:create(self.actions["stand"])
		self.spriteNode:runAction(self.curAction)
	end
end

-- advance
-- 执行前进动作动画
function BattleAnim:advance()
	self:stopAction()

	self:initAction("advance")
	self.curAction = cc.RepeatForever:create(self.actions["advance"])
	self.spriteNode:runAction(self.curAction)
end

-- attack
-- 执行攻击动作动画
function BattleAnim:attack(times_, callback_)
	self:stopAction()

	self:initAction("attack")
	if callback_~=nil then
		local action = cc.Sequence:create(self.actions["attack"], cc.CallFunc:create(callback_))
		self.curAction = cc.Repeat:create(action, times_)
	else
		self.curAction = cc.Repeat:create(self.actions["attack"], times_)
	end
	self.spriteNode:runAction(self.curAction)
end

-- die
-- 执行死亡动画
function BattleAnim:die(callback_)
	self:stopAction()

	self:initAction("die")
	local fout = cc.FadeOut:create(1)
	if callback_~=nil then
		self.curAction = cc.Sequence:create(self.actions["die"], fout, cc.CallFunc:create(callback_))
	else
		self.curAction = cc.Sequence:create(self.actions["die"], fout)
	end
	self.spriteNode:runAction(self.curAction)
end

-- cheer
-- 执行欢呼动作动画
function BattleAnim:cheer()
	self:stopAction()

	if self:initAction("cheer") then
		self.curAction = cc.RepeatForever:create(self.actions["cheer"])
		self.spriteNode:runAction(self.curAction)
	end
end

-- stopAction
function BattleAnim:stopAction()
	if self.curAction~=nil then
		self.spriteNode:stopAction(self.curAction)
		self.curAction = nil
	end
end



-- 战场军队方阵类
-- ===============================
BattleMatrix = class("BattleMatrix")


--
-- ctor
-------------------------------
function BattleMatrix:ctor(sid_, dir_, numScale_, skewX_)
	local animInfo = hp.gameDataLoader.getInfoBySid("battleArmy", sid_)
	local lineNum = math.ceil(animInfo.maxLineNum*numScale_)

	self.animInfo = animInfo
	self.lineNum = lineNum
	self.dir = dir_
	self.skewX = skewX_
	self.armyAnims = {}

	self:init()
end

--
-- init
-------------------------------
function BattleMatrix:init()
	local armyNode = cc.Node:create()
	self.armyNode = armyNode

	if self.dir==1 then
	-- 面朝下的
		for i=self.lineNum, 1, -1 do
			self:addArmyLine(i)
		end
	else
	-- 面朝上的
		for i=1, self.lineNum do
			self:addArmyLine(i)
		end
	end
end

-- addArmyLine
function BattleMatrix:addArmyLine(lineNum_)
	local animInfo = self.animInfo
	local px = -animInfo.spaceX*(animInfo.numPerLine-1)/2
	local py = 0
	if self.dir==1 then
		py = animInfo.spaceY*(lineNum_-1)
	else
		py = -animInfo.spaceY*(lineNum_-1)
	end

	local lineNode = cc.Node:create()
	lineNode:setPosition(py*self.skewX, py)

	for i=1, animInfo.numPerLine do
		local x = px+animInfo.spaceX*(i-1)
		local y = -x*battleCfg.skew
		local anim = BattleAnim.new(animInfo, self.dir)
		anim.spriteNode:setPosition(x, y)
		lineNode:addChild(anim.spriteNode)

		table.insert(self.armyAnims, anim)
	end

	self.armyNode:addChild(lineNode)
end

-- stand
-- 前进
function BattleMatrix:stand()
	for i, v in ipairs(self.armyAnims) do
		v:stand()
	end
end

-- advance
-- 前进
function BattleMatrix:advance()
	for i, v in ipairs(self.armyAnims) do
		v:advance()
	end
end

-- attack
-- 攻击
function BattleMatrix:attack(times_, callback_)
	for i, v in ipairs(self.armyAnims) do
		if i==1 then
		--只需要第一个人执行这个回调
			v:attack(times_, callback_)
		else
			v:attack(times_)
		end
	end
end

-- die
-- 死亡
function BattleMatrix:die(callback_)
	for i, v in ipairs(self.armyAnims) do
		if i==1 then
		--只需要第一个人执行这个回调
			v:die(callback_)
		else
			v:die()
		end
	end
end


-- cheer
-- 欢呼
function BattleMatrix:cheer()
	for i, v in ipairs(self.armyAnims) do
		v:cheer()
	end
end

-- stopAction
-- 停止
function BattleMatrix:stopAction()
	for i, v in ipairs(self.armyAnims) do
		v:stopAction()
	end
end

-- getSize
function BattleMatrix:getSize()
	local animInfo = self.animInfo
	return cc.size( animInfo.spaceX*animInfo.numPerLine, animInfo.spaceY*self.lineNum )
end

-- getSize
function BattleMatrix:getSpace()
	return self.animInfo.armySpace
end

-- 
