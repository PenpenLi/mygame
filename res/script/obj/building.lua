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
		if player.buildingMgr.getBuildingMaxLvBySid(1001)>=self.block.needMainLv then
			self.imgPath = string.format("%s%s.png", config.dirUI.building, self.block.img)
		else
		-- 主建筑未达到等级
			self.imgPath = string.format("%s%s_unopened.png", config.dirUI.building, self.block.img)
			self.unopenedFlag = true
		end
	end

	
	-- 注册消息
	self.manageMsg = {}
	if self.build ~= nil then
		if self.build.sid == 1014 then
			self:registMsg(hp.MSG.HOSPITAL_HURT_REFRESH)
			self:registMsg(hp.MSG.HOSPITAL_HEAL_FINISH)
			self.markImage = "mark_hospital.png"
		elseif self.build.sid == 1007 then
			self.markImage = "mark_research.png"
			self:registMsg(hp.MSG.CD_STARTED)
			self:registMsg(hp.MSG.CD_FINISHED)
		elseif self.build.sid == 1022 then
			self.markImage = "mark_tavern.png"
			self:registMsg(hp.MSG.FAMOUS_HERO_NUM_CHANGE)
		elseif self.build.sid == 1016 then
			self.markImage = "mark_captive.png"
			self:registMsg(hp.MSG.FAMOUS_HERO_NUM_CHANGE)
		end
	end

	-- 设置相应节点
	self:initPosition()
	self.ccLayer = cc.Layer:create()
	self.ccLayer:setCascadeColorEnabled(true)
	if self.bInfo~=nil and self.bInfo.showtype==15 then
	-- 城墙特殊处理
		self.ccNode = cc.Sprite:create(self.imgPath .. "_corner.png")
		self.ccLayer:setPosition(3046, 1246)
		self:citywallNodeInit()
	else
		self.ccNode = cc.Sprite:create(self.imgPath)
		self.ccLayer:setPosition(self.position)
	end
	-- 创建建筑精灵
	self.ccNode:setAnchorPoint(0, 0)
	self.ccNode:setCascadeColorEnabled(true)
	self.ccLayer:addChild(self.ccNode)
	self.container.objLayer:addChild(self.ccLayer)
	if self.bInfo~=nil then
		if self.bInfo.showtype==15 then
			self.ccLayer:setLocalZOrder(70)
		else
			self.ccLayer:setLocalZOrder(self.block.left+self.block.top)
		end

		if self.bInfo.showtype==1 then
		-- 主建筑，界面跳转到此
			self:Jmp2Here()
		end

		-- 特殊处理
		self:setAnimationRole()
		self:setLvInfo()
		self:checkUpIcon()
		self:showMark()
	else
		self.ccLayer:setLocalZOrder(self.block.left+self.block.top-25)
	end

	self:removeGuide()
	return true
end

--
-- citywallNodeInit
-- 特殊处理城墙
------------------------------
function Building:citywallNodeInit()
	local px = 0
	local py = 430
	local pTmp = 0
	local pAdd = 0

	if string.byte(self.imgPath, -1)==49 then
		pAdd = 2
	elseif string.byte(self.imgPath, -1)==50 then
		py = 425
	end

	-- 拐角到城门
	local wallPart = cc.Sprite:create(self.imgPath .. "_front.png")
	px = px - wallPart:getContentSize().width
	pTmp = pTmp+pAdd
	wallPart:setAnchorPoint(0, 0)
	wallPart:setPosition(px, px/2+pTmp)
	self.ccNode:addChild(wallPart)
	-- 城门
	wallTmp = cc.Sprite:create(self.imgPath .. "_gate.png")
	px = px-wallTmp:getContentSize().width
	pTmp = pTmp+pAdd*2
	wallTmp:setAnchorPoint(0, 0)
	wallTmp:setPosition(px, px/2+pTmp)
	self.ccNode:addChild(wallTmp)
	-- 城门左边
	for i=1, 4 do
		wallPart = cc.Sprite:create(self.imgPath .. "_front.png")
		px = px - wallPart:getContentSize().width
		pTmp = pTmp+pAdd
		wallPart:setAnchorPoint(0, 0)
		wallPart:setPosition(px, px/2+pTmp)
		self.ccNode:addChild(wallPart)
	end
	-- 右边城墙
	px = 0
	for i=1, 5 do
		wallPart = cc.Sprite:create(self.imgPath .. "_back.png")
		wallPart:setAnchorPoint(1, 0)
		wallPart:setPosition(px, py)
		self.ccNode:addChild(wallPart)

		local w = wallPart:getContentSize().width
		px = px - w
		py = py + w/2
	end
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


-- setAnimationRole
-- 设置动画角色
function Building:setAnimationRole()
	local bInfo = self.bInfo
	if bInfo~=nil then
		if bInfo.animation~="-1" then
			local animSprite = hp.sequenceAniHelper.createAnimSprite("cityMap", bInfo.animation, bInfo.animationFn, bInfo.animationFt/1000, 3)
			animSprite:setPosition(bInfo.animationPos[1], bInfo.animationPos[2])
			self.ccNode:addChild(animSprite)
		end
	end
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
			-- 主建筑
				px = sz.width*3/4-56
				py = sz.height/4+32
			elseif self.bInfo.showtype==15 then
			-- 城墙
				px = -546
				py = -330
			else
			-- 其他建筑
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
				-- 主建筑
					px = sz.width*15/16-56
					py = sz.height*7/16+32
				elseif self.bInfo.showtype==15 then
				-- 城墙
					px = -460
					py = -280
				else
				-- 其他建筑
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
-- getPos2Position
--------------------------------
function Building:getPos2Position()
	local position = self.centerPosition
	local scale = self.container.mapScrollView:getZoomScale()
	local p = cc.p(game.visibleSize.width/2-position.x*scale, game.visibleSize.height/2-position.y*scale)
	local maxSize = self.container.mapScrollView:getContentSize()
	local mx = -(maxSize.width*scale-game.visibleSize.width)
	local my = -(maxSize.height*scale-game.visibleSize.height)
	if p.x>0 then
		p.x = 0
	elseif p.x<mx then
		p.x=mx
	end
	if p.y>0 then
		p.y = 0
	elseif p.y<my then
		p.y=my
	end

	return p
end

--
-- Jmp2Here
--------------------------------
function Building:Jmp2Here()
	local p = self:getPos2Position()
	self.container.mapScrollView:setContentOffset(p)
end

--
-- Scroll2Here
--------------------------------
function Building:Scroll2Here(dt)
	local p = self:getPos2Position()
	self.container.mapScrollView:setContentOffsetInDuration(p, dt)
end

-- 添加指引
function Building:addGuide()
	self:removeGuide()
	-- 箭头
	local guide = cc.Sprite:create(config.dirUI.common .. "guide_point.png")
	guide:setScale(1.5)
	guide:setRotation(180)
	guide:setPosition(self.centerPosition)
	guide:setAnchorPoint(cc.p(0.5, 1))
	-- 跳跃动画
	local aJump = cc.JumpBy:create(0.8, cc.p(0, 0), 50, 1)
	local jumpRep = cc.RepeatForever:create(aJump)
	guide:runAction(jumpRep)

	self.container.guide = guide
	self.container.objLayer:addChild(self.container.guide, 99999)
end

-- 删除指引
function Building:removeGuide()
	if self.container.guide then
		self.container.guide:removeFromParent()
		self.container.guide = nil
	end
end


--
-- 事件处理
--======================================

-- onFocus
function Building:onFocus()
	cclog_(self.block.sid)
	self.ccLayer:setColor(cc.c3b(128, 128, 128))
end

-- onLostFocus
function Building:onLostFocus()
	self.ccLayer:setColor(cc.c3b(255, 255, 255))
end

-- onClicked
function Building:onClicked()
	self:removeGuide()
	self:onLostFocus()
	cclog_("bsid:",self.block.sid)
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
			-- 使馆
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
			local ui = UI_buildingDef.new(self)
			self.container:addUI(ui)
		end
	else
		if self.unopenedFlag then
			require("ui/msgBox/msgBox")
			local msgTxt = string.format(hp.lang.getStrByID(2304), self.block.needMainLv)
			local ui = UI_msgBox.new(hp.lang.getStrByID(6034), msgTxt, hp.lang.getStrByID(1209))
			self.container:addModalUI(ui)
		else
			require "ui/buildList"
			local ui  = UI_buildList.new(self)
			self.container:addUI(ui)
		end
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

	-- 医馆消息
	if self.build ~= nil then
		if self.build.sid == 1014 then
			self:registMsg(hp.MSG.HOSPITAL_HURT_REFRESH)
			self:registMsg(hp.MSG.HOSPITAL_HEAL_FINISH)
			self.markImage = "mark_hospital.png"
		elseif self.build.sid == 1007 then
			self.markImage = "mark_research.png"
			self:registMsg(hp.MSG.CD_STARTED)
			self:registMsg(hp.MSG.CD_FINISHED)
		elseif self.build.sid == 1022 then
			self.markImage = "mark_tavern.png"
			self:registMsg(hp.MSG.FAMOUS_HERO_NUM_CHANGE)
		end
	end
	
	player.buildingMgr.addBuilding(self.build)

	self.ccLayer:removeChild(self.ccNode)
	self.ccNode = cc.Sprite:create(self.imgPath)
	self.ccNode:setAnchorPoint(0, 0)
	self.ccLayer:addChild(self.ccNode)
	self.ccLayer:setLocalZOrder(self.block.left+self.block.top)
	
	self:setAnimationRole()
	self:setLvInfo()

	cc.SimpleAudioEngine:getInstance():playEffect("sound/build.mp3")

	--
	self.container:checkAllBuildingsUpIcon()
	
	--effect
	self:starEffect()

	self:showMark()
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
	if self.bInfo.showtype==15 then
	-- 城墙
		self.ccNode = cc.Sprite:create(self.imgPath .. "_corner.png")
		self:citywallNodeInit()
	else
		self.ccNode = cc.Sprite:create(self.imgPath)
	end
	self.ccNode:setAnchorPoint(0, 0)
	self.ccNode:setCascadeColorEnabled(true)
	self.ccLayer:addChild(self.ccNode)
	self:setAnimationRole()
	self:setLvInfo()

	if self.bInfo.showtype==1 then
	-- 府邸升级
		hp.msgCenter.sendMsg(hp.MSG.UPGRADEGIFT_GET)

		for i, b in ipairs(self.container.objs) do
			b:checkOpened(self.build.lv)
		end
	end

	cc.SimpleAudioEngine:getInstance():playEffect("sound/build.mp3")

	--
	self.container:checkAllBuildingsUpIcon()
	
	--effect
	self:starEffect()
	self:showMark()
end

-- 拆除建筑
function Building:destoryBuilding()
	self.imgPath = string.format("%s%s.png", config.dirUI.building, self.block.img)
	self.ccLayer:removeChild(self.ccNode)
	self.ccNode = cc.Sprite:create(self.imgPath)
	self.ccNode:setAnchorPoint(0, 0)
	self.ccLayer:addChild(self.ccNode)
	self.ccLayer:setLocalZOrder(0)

	player.buildingMgr.removeBuilding(self.build)

	self.build = nil
	self.bInfo = nil
	self.upInfo = nil
	self.uplvIcon = nil

	cc.SimpleAudioEngine:getInstance():playEffect("sound/build.mp3")

	self.container:checkAllBuildingsUpIcon()
	
	--销毁特效
	self:destroyEffect()
end


function Building:starEffect()
--建筑建造或升级
	if self.bInfo==nil then
		return
	end
	if self.bInfo.showtype==15 then
	-- 城墙
		local duration = 1.0
		local emitter = cc.ParticleSystemQuad:create(config.dirUI.particle .. "build_citywall.plist")
		emitter:setDuration(duration)
		emitter:setAnchorPoint(0, 0)
		emitter:setPosition(-760, -320)
		emitter:setPosVar(cc.p(1200, 120))
		emitter:setRotation(-26)
		emitter:setTotalParticles(800)
		self.ccNode:addChild(emitter)
		--
		emitter = cc.ParticleSystemQuad:create(config.dirUI.particle .. "build_citywall.plist")
		emitter:setDuration(duration)
		emitter:setAnchorPoint(0, 0)
		emitter:setPosition(-500, 800)
		emitter:setPosVar(cc.p(120, 1000))
		emitter:setRotation(-64)
		emitter:setTotalParticles(800)
		self.ccNode:addChild(emitter)

		self.ccNode:setColor(cc.c3b(255, 255, 0))
		self.ccNode:runAction(cc.TintTo:create(1.6, 255, 255, 255))
	else
		require("ui/common/effect")
		local duration = 1.0
		local contentSize = self.ccNode:getContentSize()
		local light = BuildInLight(self.ccNode, duration)
		local emitter = particleSysQ(duration, contentSize)

		self.ccNode:addChild(light)
		self.ccNode:addChild(emitter)
		self.ccNode:setColor(cc.c3b(255, 255, 0))
		self.ccNode:runAction(cc.TintTo:create(duration, 255, 255, 255))
	end
end

function Building:destroyEffect()
--建筑销毁
	
end

-- 设置显示图标
function Building:showMark()
	if self.build == nil then
		return
	end

	local show_ = false
	if self.build.sid == 1014 then
		if player.soldierManager.getHurtArmy():getSoldierTotalNumber() > 0 then
			show_ = true
		end
	elseif self.build.sid == 1007 then		
		if cdBox.getCD(cdBox.CDTYPE.RESEARCH) == 0 then
			show_ = true
		end
	elseif self.build.sid == 1022 then
		if player.takeInHeroMgr.getHeroNum() > 0 then
			show_ = true
		end
	elseif self.build.sid == 1016 then
		
	else
		return
	end

	local markNode_ = self.ccNode:getChildByTag(1234)
	if show_ == false then
		if markNode_ ~= nil then
			markNode_:removeFromParent()
			markNode_ = nil
		end
	else
		if markNode_ == nil then
			if self.markImage ~= nil then
				markNode_ = cc.Sprite:create(config.dirUI.common..self.markImage)
				markNode_:setTag(1234)
				markNode_:setPosition(self.size.width/2, self.size.height*1.2)
				self.ccNode:addChild(markNode_)
			end
		end
	end	
end

-- checkOpened
function Building:checkOpened(mainLv_)
	if self.unopenedFlag then
		if mainLv_>=self.block.needMainLv then
			self.imgPath = string.format("%s%s.png", config.dirUI.building, self.block.img)
			self.ccNode:setTexture(self.imgPath)
			self.unopenedFlag = false
		end
	end
end

-- 处理消息
function Building:onMsg(msg_, param_)
	self:showMark()
end

-- registMsg
function Building:registMsg(msg_)
	if hp.msgCenter.addMsgMgr(msg_, self) then
		table.insert(self.manageMsg, msg_)
	end
end

-- unregistAllMsg
function Building:unregistAllMsg()
	for i,v in ipairs(self.manageMsg) do
		hp.msgCenter.removeMsgMgr(v, self)
	end

	self.manageMsg = {}
end

function Building:onRemove()
	self:unregistAllMsg()
end