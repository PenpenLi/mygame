--
-- file: hp/uiEffect.lua
-- desc: ui特效处理
--===================================


hp.uiEffect = {}


-- init
-- 初始化
-------------------------------------------
function hp.uiEffect.init()
end



--
-- uiEffect functions
--=========================================

--
-- innerGlow
-- 内发光
-- @ccNode_: 执行内发光的节点
-- @glowType_: 发光类型
function hp.uiEffect.innerGlow(ccNode_, glowType_)
	local innerGlow = cc.Sprite:create(config.dirUI.common .. "goldLight" .. glowType_ .. ".png")

	local aSq = cc.Sequence:create(cc.FadeOut:create(1.2), cc.FadeIn:create(0.7))
	local aRep = cc.RepeatForever:create(aSq)
	innerGlow:runAction(aRep)

	local sz1 = innerGlow:getContentSize()
	local sz2 = ccNode_:getContentSize()
	innerGlow:setScaleX(sz2.width/sz1.width)
	innerGlow:setScaleY(sz2.height/sz1.height)
	innerGlow:setPosition(sz2.width/2.0, sz2.height/2.0)

	ccNode_:addChild(innerGlow)
	return innerGlow
end

