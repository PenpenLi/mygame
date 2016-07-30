--
-- ui/common/effect.lua
-- 特效
--===================================

-- 返回一个特效Node节点或者精灵sprite，
-- 自行添加，可控制隐藏特效

--参数需要一个精灵可以是动态精灵
--外发光(闪动)
function outLight( sprite ,type_, actionSid )

	local light = cc.Sprite:create(config.dirUI.common .. "goldLight2.png")

	local aOut = cc.FadeOut:create(1)
	local aIn = cc.FadeIn:create(0.5)
	local aSq = cc.Sequence:create(aOut, aIn)
	local aRep = cc.RepeatForever:create(aSq)
	light:runAction(aRep)
	
	--如果是动画，产生动画的动态模板
	--如果是普通精灵，获取当前帧图像作为模板
	local function createStencil(actionSid_)
		if actionSid_ ~= nil then
			return hp.sequenceAniHelper.createAnimSprite(type_, actionSid_, 6, 0.2)
		else
			return cc.Sprite:createWithSpriteFrame( sprite:getSpriteFrame() )
		end
	end
	
	--创建剪裁节点，蒙版有色部分将透过颜色
	local clipper = cc.ClippingNode:create()
	
	--蒙版是否反选
	clipper:setInverted(false)
	clipper:setAlphaThreshold(0.65)
	
	local stencil = cc.ClippingNode:create()
	stencil:setInverted(true)
	stencil:setAlphaThreshold(0.65)
	
	--设置外部模板内容
	local stcl1 = createStencil(actionSid)
	
	--光芒嵌入人体的厚度
	stcl1:setScale(1.0,1.0)
	
	stencil:setStencil(stcl1)
	stencil:addChild(light)
	
	--将前面的结果作为这里的内容再模板剪裁
	local stcl2 = createStencil(actionSid)
	
	--光芒厚度
	stcl2:setScale(1.06,1.04)
	
	clipper:setStencil(stcl2)
	clipper:addChild(stencil)

	local contentSize = sprite:getContentSize()
	clipper:setPosition(contentSize.width/2.0,contentSize.height/2.0)

	return clipper

end

--内发光(按钮闪动)
function inLight( sprite,type, actionSid )

	local light = cc.Sprite:create(config.dirUI.common .. "goldLight" .. type .. ".png")

	local aOut = cc.FadeOut:create(1.2)
	local aIn = cc.FadeIn:create(0.7)
	local aSq = cc.Sequence:create(aOut, aIn)
	local aRep = cc.RepeatForever:create(aSq)
	light:runAction(aRep)
	
	
	local function createStencil(actionSid_)
		if actionSid_ ~= nil then
			return hp.sequenceAniHelper.createAnimation(actionSid_)
		else
			return cc.Sprite:createWithSpriteFrame( sprite:getSpriteFrame() )
		end
	end
	
	--创建剪裁节点，蒙版有色部分将透过颜色
	local clipper = cc.ClippingNode:create()
	
	--蒙版是否反选
	clipper:setInverted(false)
	clipper:setAlphaThreshold(0.96)
	
	
	--蒙版 和其他绘制内容
	local stencil = createStencil(actionSid)
	local scaleSize = 1.00
	stencil:setScale(scaleSize,scaleSize)
	
	clipper:setStencil(stencil)
	clipper:addChild(light)

	local contentSize = sprite:getContentSize()
	clipper:setPosition(contentSize.width/2.0,contentSize.height/2.0)

	
	return clipper

end

--内发光(按钮闪动,不考虑透明色,整个图片闪光)
function inLight1( sprite,type, actionSid )

	local light = cc.Sprite:create(config.dirUI.common .. "goldLight" .. type .. ".png")

	local aOut = cc.FadeOut:create(1.2)
	local aIn = cc.FadeIn:create(0.7)
	local aSq = cc.Sequence:create(aOut, aIn)
	local aRep = cc.RepeatForever:create(aSq)
	light:runAction(aRep)
	
	
	local function createStencil(actionSid_)
		if actionSid_ ~= nil then
			return hp.sequenceAniHelper.createAnimation(actionSid_)
		else
			return cc.Sprite:createWithSpriteFrame( sprite:getSpriteFrame() )
		end
	end
	
	--创建剪裁节点，蒙版有色部分将透过颜色
	local clipper = cc.ClippingNode:create()
	
	--蒙版是否反选
	clipper:setInverted(false)
	clipper:setAlphaThreshold(1.0)
	
	
	--蒙版 和其他绘制内容
	local stencil = createStencil(actionSid)
	local scaleSize = 1.00
	stencil:setScale(scaleSize,scaleSize)
	
	clipper:setStencil(stencil)
	clipper:addChild(light)

	local contentSize = sprite:getContentSize()
	clipper:setPosition(contentSize.width/2.0,contentSize.height/2.0)

	
	return clipper

end

--内发光(整个图片闪光，通用)
function inLight2( sprite,type, actionSid )

	local light = cc.Sprite:create(config.dirUI.common .. "goldLight" .. type .. ".png")
	-- 计算缩放
	local lightSize_ = light:getContentSize()
	cclog_("lightSize_",lightSize_.width,lightSize_.height)
	local spriteSize_ = sprite:getContentSize()
	cclog_("spriteSize_",spriteSize_.width,spriteSize_.height)
	local scale_ = spriteSize_.width / lightSize_.width
	local scaleY_ = spriteSize_.height / lightSize_.height
	if scale_ < scaleY_ then
		scale_ = scaleY_
	end
	light:setScale(scale_, scale_)

	local aOut = cc.FadeOut:create(1.2)
	local aIn = cc.FadeIn:create(0.7)
	local aSq = cc.Sequence:create(aOut, aIn)
	local aRep = cc.RepeatForever:create(aSq)
	light:runAction(aRep)
	
	
	local function createStencil(actionSid_)
		if actionSid_ ~= nil then
			return hp.sequenceAniHelper.createAnimation(actionSid_)
		else
			return cc.Sprite:createWithSpriteFrame( sprite:getSpriteFrame() )
		end
	end
	
	--创建剪裁节点，蒙版有色部分将透过颜色
	local clipper = cc.ClippingNode:create()
	
	--蒙版是否反选
	clipper:setInverted(false)
	clipper:setAlphaThreshold(0.65)
	
	
	--蒙版 和其他绘制内容
	local stencil = createStencil(actionSid)
	local scaleSize = 1.00
	stencil:setScale(scaleSize,scaleSize)
	
	clipper:setStencil(stencil)
	clipper:addChild(light)

	local contentSize = sprite:getContentSize()
	clipper:setPosition(contentSize.width/2.0,contentSize.height/2.0)

	
	return clipper

end

--建筑升级内发光(一次)
function BuildInLight(sprite,dur,actionSid )

	local light = cc.Sprite:create(config.dirUI.common .. "goldLight2.png")
	--线性变换
	local aOut = cc.FadeOut:create(dur)
	--local ani = cc.EaseExponentialIn:create(aOut)
	light:runAction(aOut)
	
	
	local function createStencil(actionSid_)
		if actionSid_ ~= nil then
			return hp.sequenceAniHelper.createAnimation(actionSid_)
		else
			return cc.Sprite:createWithSpriteFrame( sprite:getSpriteFrame() )
		end
	end
	
	--创建剪裁节点，蒙版有色部分将透过颜色
	local clipper = cc.ClippingNode:create()
	
	--蒙版是否反选
	clipper:setInverted(false)
	clipper:setAlphaThreshold(0.05)
	
	
	--蒙版 和其他绘制内容
	local stencil = createStencil(actionSid)
	local scaleSize = 1.02
	stencil:setScale(scaleSize,scaleSize)
	
	clipper:setStencil(stencil)
	clipper:addChild(light)

	local contentSize = sprite:getContentSize()
	clipper:setPosition(contentSize.width/2.0,contentSize.height/2.0)
	
	local scaleSizeX = contentSize.width
	contentSize = light:getContentSize()
	scaleSizeX = scaleSizeX/contentSize.width
	light:setScale(scaleSizeX,scaleSizeX)
	
	return clipper

end


--粒子系统
function particleSysQ(dur,contentSize_)
	local _emitter
	if contentSize_.width > 500 then
	--大于500 为府邸
		_emitter = cc.ParticleSystemQuad:create(config.dirUI.particle .. "build_main.plist")
		--设置粒子发射器的生存时间
		_emitter:setDuration(dur)
		_emitter:setPosition(contentSize_.width/2.0, contentSize_.height/2.0)
		_emitter:setPosVar(cc.p(400, 300))
		_emitter:setTotalParticles(600)
	else
		_emitter = cc.ParticleSystemQuad:create(config.dirUI.particle .. "buildP.plist")
		--设置粒子发射器的生存时间
		_emitter:setDuration(dur)
		_emitter:setPosition(contentSize_.width/2.0, contentSize_.height/4.0)
		--粒子波动范围
		_emitter:setPosVar(cc.p(contentSize_.width/3, contentSize_.height/4))
		--设置粒子数量
		_emitter:setTotalParticles(contentSize_.width/12)
	end

	return _emitter
end


-- add by huangwei
-- 府邸人物外发光（图片适应）
function outLight1(sid)
	local outlight

	if sid == "cx" then
		outlight = cc.Sprite:create(config.dirUI.effect .. "outlight/" .. sid .. ".png")
	elseif sid == "lg" then
		outlight = cc.Sprite:create(config.dirUI.effect .. "outlight/" .. sid .. ".png")
		outlight:setPosition(cc.p(-3, -6))
	elseif sid == "jj" then
		outlight = cc.Sprite:create(config.dirUI.effect .. "outlight/" .. sid .. ".png")
		outlight:setPosition(cc.p(-10, -20))
	elseif sid == "ch" then
		outlight = cc.Sprite:create(config.dirUI.effect .. "outlight/" .. sid .. ".png")
	elseif sid == "sz" then
		outlight = cc.Sprite:create(config.dirUI.effect .. "outlight/" .. sid .. ".png")
	else
		outlight = cc.Sprite:create()
		return outlight
	end

	local action1 = cc.FadeOut:create(1)
	local action2 = cc.FadeIn:create(0.5)
	local actions = cc.Sequence:create(action1, action2)
	outlight:runAction(cc.RepeatForever:create(actions))
	outlight:setAnchorPoint(cc.p(0, 0))

	return outlight
end

-- 物体外发光,图片可选,行为固定
function outLight2(image_)
	local outlight = cc.Sprite:create(image_)

	local action1 = cc.FadeOut:create(1)
	local action2 = cc.FadeIn:create(0.5)
	local actions = cc.Sequence:create(action1, action2)
	outlight:runAction(cc.RepeatForever:create(actions))
	outlight:setAnchorPoint(cc.p(0.5, 0.5))

	return outlight
end

-- 拖尾效果
function brightTail()
	local bt = hp.sequenceAniHelper.createAnimSprite("common", "brightTail", 11, 0.1)
	return bt
end

-- 文字切换动画
function setLabelAni(label, str1, str2)
	local timesFlag = false
	local function resetString()
		if timesFlag then
			timesFlag = false
			label:setString(str1)
		else
			timesFlag = true
			label:setString(str2)
		end
	end
	local a1 = cc.FadeOut:create(0.5)
	local a2 = cc.CallFunc:create(resetString)
	local a3 = cc.FadeIn:create(0.5)
	local a4 = cc.DelayTime:create(1)
	local a = cc.RepeatForever:create(cc.Sequence:create(a1, a2, a3, a4))
	label:runAction(a)
	resetString()
end