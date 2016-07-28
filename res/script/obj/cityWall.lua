--
-- obj/cityWall.lua
-- 城墙
--================================================


CityWall = class("CityWall")


--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function CityWall:ctor(container_, build_)
	self.container = container_
	self.block = {sid=27, type=1, top=47, left=47, right=52, left=52}
	self.build = build_

	self.bInfo = nil
	self.upInfo = nil
	self.imgPath = nil

	self.ccLayer = nil
	self.ccNode = nil

	self:init()
end


--
-- init
-------------------------------
function CityWall:init()
	for i,v in ipairs(game.data.building) do
		if self.build.sid==v.sid then
			self.bInfo = v
			break
		end
	end

	for i, v in ipairs(game.data.upgrade) do
		if self.build.sid==v.buildSid and self.build.lv==v.level then
			self.upInfo = v
			break
		end
	end


	self.imgPath = string.format("%s%s.png", config.dirUI.building, "city_wall1_1.png")

	self.ccNode = cc.Sprite:create(self.imgPath)
	self.ccLayer = cc.Layer:create()
	self.ccLayer:addChild(self.ccNode)
	self.ccLayer:setCascadeColorEnabled(true)
	self.ccLayer:setPosition(self:getCenterPosition())
	self.container.objLayer:addChild(self.ccLayer)

	return true
end

--
-- heartbeat
-------------------------------
function CityWall:heartbeat(dt)
end

--
-- getCenterPosition
-------------------------------
function CityWall:getCenterPosition()
	local container = self.container
	local p_lb = container:pTilemap2Map(cc.p(self.block.left, self.block.bottom))
	local p_rb = container:pTilemap2Map(cc.p(self.block.right, self.block.bottom))
	local p_lt = container:pTilemap2Map(cc.p(self.block.left-1, self.block.top-1))
	local p_rt = container:pTilemap2Map(cc.p(self.block.right+1, self.block.top-1))

	return cc.p((p_rt.x+p_lb.x)/2, (p_rb.y+p_lt.y)/2)
end


--
-- 事件处理
--======================================

-- onFocus
function CityWall:onFocus()
	self.ccLayer:updateDisplayedColor(cc.c3b(128, 128, 128))
end

-- onLostFocus
function CityWall:onLostFocus()
	self.ccLayer:updateDisplayedColor(cc.c3b(255, 255, 255))
end


-- onClicked
function CityWall:onClicked()
	self:onLostFocus()

	require "ui/wall/wall"
	local ui = UI_wall.new(self)
	self.container:addUI(ui)
end


function CityWall:upgradeBuilding()
	self.build.lv = self.build.lv+1
	
	for i,v in ipairs(game.data.building) do
		if self.build.sid==v.sid then
			self.bInfo = v
			break
		end
	end

	for i, v in ipairs(game.data.upgrade) do
		if self.build.sid==v.buildSid and self.build.lv==v.level then
			self.upInfo = v
			break
		end
	end
end

