--
-- scene/logo.lua
-- 游戏logo界面
--================================================
require "scene/Scene"


SceneLogo = class("SceneLogo", Scene)


--
-- init
--
function SceneLogo:init()
	local bg = cc.Sprite:create(config.dirUI.common .. "logo.png")
	bg:setScale(hp.uiHelper.RA_scale)
	bg:setPosition(game.origin.x + game.visibleSize.width/2, game.origin.y + game.visibleSize.height/2)

	local function callFunction()
		game.sdkHelper.loginAuto()
	end

	local action_ = cc.Sequence:create(cc.FadeIn:create(1.0), cc.DelayTime:create(1.0), cc.CallFunc:create(callFunction))
	bg:runAction(action_)
	
	self:addCCNode(bg)
end
