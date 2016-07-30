--
-- file: hp/sequenceAniHelper.lua
-- desc: boss序列帧动画助手
--================================================

hp.sequenceAniHelper = {}

-- 创建动画
function hp.sequenceAniHelper.createAnimation(sid_)
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(string.format("%sboss/%d/boss0.plist", config.dirUI.animation, sid_))
	local frames = {}
	for i=1, 6 do
		local strName = string.format("boss/%d/%d.png", sid_, i)
		local frame = frameCache:getSpriteFrame(strName)
		table.insert(frames, frame)
	end
	local animation = cc.Animation:createWithSpriteFrames(frames, 0.2)
    local animate = cc.Animate:create(animation)
	local spriteArmy = cc.Sprite:createWithSpriteFrame(frames[1])
	spriteArmy:runAction(cc.RepeatForever:create(animate))
	return spriteArmy
end

-- 创建动画
function hp.sequenceAniHelper.createAnimation1(sid_, fs_, ft_)
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(string.format("%sboss/%d/boss0.plist", config.dirUI.animation, sid_))
	local frames = {}
	for i=1, fs_ do
		local strName = string.format("boss/%d/%d.png", sid_, i)
		local frame = frameCache:getSpriteFrame(strName)
		table.insert(frames, frame)
	end
	local animation = cc.Animation:createWithSpriteFrames(frames, ft_)
    local animate = cc.Animate:create(animation)
	local spriteArmy = cc.Sprite:createWithSpriteFrame(frames[1])
	spriteArmy:runAction(cc.RepeatForever:create(animate))
	return spriteArmy
end

-- 创建序列帧动画精灵
-- @type_: 分类
-- @name_: 名字
-- @fn_: 帧数
-- @ft_: 帧时间间隔, 浮点数，单位秒
-- @show_: 0 or nil-循环，1-移除，2-不移除, 3--带随机播放的循环
function hp.sequenceAniHelper.createAnimSprite(type_, name_, fn_, ft_, show_)
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(string.format("%s%s/%s.plist", config.dirUI.animation, type_, name_))
	local frames = {}
	local sIndex = 1
	if show_==3 then
		sIndex = math.random(fn_)
	end
	for i=sIndex, fn_ do
		local strName = string.format("animation/%s/%s/%d.png", type_, name_, i)
		local frame = frameCache:getSpriteFrame(strName)
		if frame==nil then
			cclog("createAnimSprite -- getSpriteFrame(%s) ERROR!", strName)
		else
			table.insert(frames, frame)
		end
	end
	for i=1, sIndex-1 do
		local strName = string.format("animation/%s/%s/%d.png", type_, name_, i)
		local frame = frameCache:getSpriteFrame(strName)
		if frame==nil then
			cclog("createAnimSprite -- getSpriteFrame(%s) ERROR!", strName)
		else
			table.insert(frames, frame)
		end
	end
	local animation = cc.Animation:createWithSpriteFrames(frames, ft_)
    local animate = cc.Animate:create(animation)
	local spriteAnim = cc.Sprite:createWithSpriteFrame(frames[1])
	if show_ == 1 then
		local callBack_ = function() spriteAnim:removeFromParent() end
		spriteAnim:runAction(cc.Sequence:create(animate, cc.CallFunc:create(callBack_)))
	elseif show_ == 2 then
		spriteAnim:runAction(animate)
	else
		spriteAnim:runAction(cc.RepeatForever:create(animate))
	end
	return spriteAnim
end

-- 任务完成动画特殊处理
function hp.sequenceAniHelper.createFinishQuestAni()
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(string.format("%squest/%s.plist", config.dirUI.animation, "mainFinish"))
	local frames = {}
	for i=1, 4 do
		local strName = string.format("animation/quest/mainFinish/%d.png", i)
		local frame = frameCache:getSpriteFrame(strName)
		table.insert(frames, frame)
	end
	local frames2 = {}
	for i=4, 16 do
		local strName = string.format("animation/quest/mainFinish/%d.png", i)
		local frame = frameCache:getSpriteFrame(strName)
		table.insert(frames2, frame)
	end
	local animation = cc.Animation:createWithSpriteFrames(frames, 0.1)
	local animation2 = cc.Animation:createWithSpriteFrames(frames2, 0.1)
    local animate = cc.Animate:create(animation)
    local animate2 = cc.Animate:create(animation2)
	local spriteAnim = cc.Sprite:createWithSpriteFrame(frames[1])
	local callBack_ = function() spriteAnim:removeFromParent() end
	spriteAnim:runAction(cc.Sequence:create(animate, cc.DelayTime:create(0.5), animate2,  cc.CallFunc:create(callBack_)))
	return spriteAnim
end


-- 创建序列帧动画精灵
-- @name_: 名字
-- @fn_: 帧数
-- @ft_: 帧时间间隔, 浮点数，单位秒
-- @loop_: 是否循环
-- @callBack_:动画播放结束回调
function hp.sequenceAniHelper.createAnimSprite_byPng(name_, fn_, ft_, loop_, callBack_)
	local frames = {}
	local textureCache = cc.Director:getInstance():getTextureCache()
	for i=1, fn_ do
		local strName = string.format("%s%s/%d.png", config.dirUI.animationPng, name_, i)
		local texture = textureCache:addImage(strName)
		local sz = texture:getContentSize()
		local frame = cc.SpriteFrame:createWithTexture(texture, cc.rect(0, 0, sz.width, sz.height))
		table.insert(frames, frame)
	end

	local animation = cc.Animation:createWithSpriteFrames(frames, ft_)
    local animate = cc.Animate:create(animation)
	local spriteAnim = cc.Sprite:createWithSpriteFrame(frames[1])
	if loop_ then
		spriteAnim:runAction(cc.RepeatForever:create(animate))
	else
		if callBack_==nil then
			callBack_ = function() spriteAnim:removeFromParent() end
		elseif callBack_==0 then
			spriteAnim:runAction(animate)
			return spriteAnim
		end
		spriteAnim:runAction(cc.Sequence:create(animate, cc.CallFunc:create(callBack_)))
	end
	return spriteAnim
end
