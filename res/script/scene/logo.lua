--
-- scene/logo.lua
--
--================================================
require "scene/Scene"


SceneLogo = class("SceneLogo", Scene)


--
-- init
--
function SceneLogo:init()
	local bg = cc.Sprite:create(config.dirUI.root .. "login/logo.png")
	bg:setScale(hp.uiHelper.RA_scale)
	bg:setPosition(game.origin.x + game.visibleSize.width/2, game.origin.y + game.visibleSize.height/2)
	
	self:addCCNode(bg)
end
