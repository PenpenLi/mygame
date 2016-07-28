--
-- obj/building.lua
-- 建筑物
--================================================


Building = class("Building")


--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function Building:ctor(container_, block_, build_)
	self.container = container_
	self.block = block_
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
function Building:init()
	if self.build~=nil then
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

		local level = self.build.lv-1
		for i, v in ipairs(game.data.upgrade) do
			if self.build.sid==v.buildSid and level==v.level then
				self.imgPath = string.format("%s%s", config.dirUI.building, v.img)
				break
			end
		end
	else
		self.imgPath = string.format("%s%s.png", config.dirUI.building, self.block.img)
	end

	self:initPosition()
	self.ccNode = cc.Sprite:create(self.imgPath)
	self.ccNode:setAnchorPoint(0, 0)
	self.ccLayer = cc.Layer:create()
	self.ccLayer:addChild(self.ccNode)
	self.ccLayer:setCascadeColorEnabled(true)

	if self.bInfo~=nil and self.bInfo.showtype==15 then
		local ps = cc.p(self.position.x+96, self.position.y-34)
		self.ccLayer:setPosition(ps)
	else
		self.ccLayer:setPosition(self.position)
	end
	self.ccLayer:setLocalZOrder(self.block.right+self.block.bottom)
	self.container.objLayer:addChild(self.ccLayer)
	self:setLvInfo()
	self:checkUpIcon()

	if self.bInfo~=nil and self.bInfo.showtype==1 then
		self:Jmp2Here()
	end
	return true
end

--
-- initPosition
-------------------------------
function Building:initPosition()
	local container = self.container
	local p_lb = container:pTilemap2Map(cc.p(self.block.left, self.block.bottom))
	local p_rb = container:pTilemap2Map(cc.p(self.block.right, self.block.bottom))
	local p_lt = container:pTilemap2Map(cc.p(self.block.left-1, self.block.top-1))
	local p_rt = container:pTilemap2Map(cc.p(self.block.right+1, self.block.top-1))
	self.size = cc.size(p_rt.x-p_lb.x, p_lt.y-p_rb.y)
	self.position = cc.p(p_lb.x, p_rb.y)
	self.centerPosition = cc.p((p_rt.x+p_lb.x)/2, (p_rb.y+p_lt.y)/2)
end


--
-- setLvInfo
-- 设置建筑的等级信息
-------------------------------
function Building:setLvInfo()
	if self.bInfo~=nil then
		-- 等级图标
		if self.bInfo.maxLv>1 then
			local px = 1
			local py = 1
			local sz = self.size
			if self.bInfo.showtype==1 then
				px = sz.width*3/4-56
				py = sz.height/4+32
			elseif self.bInfo.showtype==15 then
				px = 360
				py = 144
			else
				px = sz.width*3/4-16
				py = sz.height/4+8
			end
			local plateSprite = cc.Sprite:create(config.dirUI.building .. "lvPlate.png")
			local lvSprite = cc.Sprite:create(string.format("%slv%d.png", config.dirUI.building, self.build.lv))
			plateSprite:setPosition(px, py)
			lvSprite:setPosition(30, 30)
			plateSprite:addChild(lvSprite)
			self.ccNode:addChild(plateSprite)

			-- 升级图标
			if self.bInfo.maxLv>self.build.lv then
				if self.bInfo.showtype==1 then
					px = sz.width*15/16-56
					py = sz.height*7/16+32
				elseif self.bInfo.showtype==15 then
					px = 416
					py = 192
				else
					px = sz.width*15/16-16
					py = sz.height*7/16+16
				end
				local upSprite = cc.Sprite:create(config.dirUI.building .. "upFlag.png")
				upSprite:setPosition(px, py)
				self.ccNode:addChild(upSprite)
				self.uplvIcon = upSprite
			else
				self.uplvIcon = nil
			end
		end
	end
end

--checkCanUpgrade
-- 检查是否显示升级图标
function Building:checkUpIcon()
	if self.uplvIcon~=nil then
		if cdBox.getCD(cdBox.CDTYPE.BUILD)>0 then
		-- cd中...
			self.uplvIcon:setVisible(false)
			return
		end

		local upInfo = self.upInfo
		local buildingMgr = player.buildingMgr
		for i, mustSid in ipairs(upInfo.mustBuildSid) do
			if mustSid>0 then
				if buildingMgr.getBuildingMaxLvBySid(mustSid)<upInfo.mustBuildLv[i] then
				-- 前需建筑未达到
					self.uplvIcon:setVisible(false)
					return
				end
			end
		end

		self.uplvIcon:setVisible(true)
	end
end


--
-- heartbeat
-------------------------------
function Building:heartbeat(dt)
end

--
-- Jmp2Here
--------------------------------
function Building:Jmp2Here()
	local position = self.centerPosition
	local scale = self.container.mapScrollView:getZoomScale()
	local p = cc.p(game.visibleSize.width/2-position.x*scale, game.visibleSize.height/2-position.y*scale)
	self.container.mapScrollView:setContentOffset(p)
end

--
-- Scroll2Here
--------------------------------
function Building:Scroll2Here(dt)
	local position = self.centerPosition
	local scale = self.container.mapScrollView:getZoomScale()
	local p = cc.p(game.visibleSize.width/2-position.x*scale, game.visibleSize.height/2-position.y*scale)
	self.container.mapScrollView:setContentOffsetInDuration(p, dt)
end

--
-- 事件处理
--======================================

-- onFocus
function Building:onFocus()
	print(self.block.sid)
	self.ccLayer:updateDisplayedColor(cc.c3b(128, 128, 128))
end

-- onLostFocus
function Building:onLostFocus()
	self.ccLayer:updateDisplayedColor(cc.c3b(255, 255, 255))
end


-- onClicked
function Building:onClicked()
	self:onLostFocus()
	print("bsid:",self.block.sid)
	if self.build~=nil then
		local bInfo = nil
		for i,v in ipairs(game.data.building) do
			if self.build.sid==v.sid then
				bInfo = v
				break
			end
		end

		if bInfo.showtype==1 then
			--主建筑
			require "ui/mainBuilding"
			local ui  = UI_mainBuilding.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==2 or bInfo.showtype==14 then
			-- 生产类建筑
			require "ui/productionBuilding"
			local ui  = UI_productionBuilding.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==3 then
			-- 仓库
			require "ui/storage/storage"
			local ui  = UI_storage.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==4 then
			-- 学院
			require "ui/academy/academy"
			local ui = UI_academy.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==5 then
			-- 祭坛
			require "ui/altar/altar"
			local ui = UI_altar.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==6 then
			-- 兵营
			require "ui/barrack/barrack"
			local ui = UI_barracks.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==7 then
			-- 兵营
			require "ui/embassy/embassy"
			local ui = UI_embassy.new(self)
			self.container:addUI(ui)			
		elseif bInfo.showtype==8 then
			-- 铁匠铺
			require "ui/smith/smith"
			local ui = UI_smith.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==10 then
			-- 军政厅
			require "ui/hallOfWar/hallOFWar"
			local ui = UI_hallOfWar.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==11 then
			-- 医院
			require "ui/hospital/hospital"
			local ui = UI_hospital.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==12 then
			-- 市场
			require "ui/market/market"
			local ui = UI_market.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==13 then
			-- 地牢
			require "ui/prison/prison"
			local ui = UI_prison.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==15 then
			-- 城墙
			require "ui/wall/wall"
			local ui = UI_wall.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==16 then
			-- 哨塔
			require "ui/watchtower/watchtower"
			local ui = UI_watchtower.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==17 then
			-- 别院
			require "ui/gymnos/gymnos"
			local ui = UI_gymnos.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==18 then
			--墓地
			require "ui/cemetery/cemetery.lua"
			local ui = UI_cemetery.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==19 then
			--招贤馆
			require "ui/takeInHeroRoom/takeInHeroRoom"
			local ui = UI_takeInHeroRoom.new(self)
			self.container:addUI(ui)
		else
			require "ui/buildingDef"
			local ui  = UI_buildingDef.new(self)
			self.container:addUI(ui)
		end
	else 
		require "ui/buildList"
		local ui  = UI_buildList.new(self)
		self.container:addUI(ui)
	end
end

-- 建造建筑
function Building:buildBuilding(sid)
	self.build = {}
	self.build.sid = sid
	self.build.lv = 1
	self.build.bsid = self.block.sid
	self.build.bType = self.block.type

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
	for i, v in ipairs(game.data.upgrade) do
		if self.build.sid==v.buildSid and 0==v.level then
			self.imgPath = string.format("%s%s", config.dirUI.building, v.img)
			break
		end
	end
	
	player.buildingMgr.addBuilding(self.build)

	self.ccLayer:removeChild(self.ccNode)
	self.ccNode = cc.Sprite:create(self.imgPath)
	self.ccNode:setAnchorPoint(0, 0)
	self.ccLayer:addChild(self.ccNode)
	self:setLvInfo()

	cc.SimpleAudioEngine:getInstance():playEffect("sound/build.mp3")

	--
	self.container:checkAllBuildingsUpIcon()
end

-- 升级建筑
function Building:upgradeBuilding()
	for i, v in ipairs(game.data.upgrade) do
		if self.build.sid==v.buildSid and self.build.lv==v.level then
			self.imgPath = string.format("%s%s", config.dirUI.building, v.img)
			break
		end
	end
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

	self.ccLayer:removeChild(self.ccNode)
	self.ccNode = cc.Sprite:create(self.imgPath)
	self.ccNode:setAnchorPoint(0, 0)
	self.ccLayer:addChild(self.ccNode)
	self:setLvInfo()

	cc.SimpleAudioEngine:getInstance():playEffect("sound/build.mp3")

	--
	self.container:checkAllBuildingsUpIcon()
end

-- 拆除建筑
function Building:destoryBuilding()
	self.imgPath = string.format("%s%s.png", config.dirUI.building, self.block.img)
	self.ccLayer:removeChild(self.ccNode)
	self.ccNode = cc.Sprite:create(self.imgPath)
	self.ccNode:setAnchorPoint(0, 0)
	self.ccLayer:addChild(self.ccNode)

	player.buildingMgr.removeBuilding(self.build)

	self.build = nil
	self.bInfo = nil
	self.upInfo = nil
	self.uplvIcon = nil

	cc.SimpleAudioEngine:getInstance():playEffect("sound/build.mp3")

	--
	self.container:checkAllBuildingsUpIcon()
end
