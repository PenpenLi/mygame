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
function hp.sequenceAniHelper.createAnimSprite(type_, name_, fn_, ft_)
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(string.format("%s%s/%s.plist", config.dirUI.animation, type_, name_))
	local frames = {}
	for i=1, fn_ do
		local strName = string.format("anim/%s/%s/%d.png", type_, name_, i)
		local frame = frameCache:getSpriteFrame(strName)
		table.insert(frames, frame)
	end
	local animation = cc.Animation:createWithSpriteFrames(frames, ft_)
    local animate = cc.Animate:create(animation)
	local spriteAnim = cc.Sprite:createWithSpriteFrame(frames[1])
	spriteAnim:runAction(cc.RepeatForever:create(animate))
	return spriteAnim
end