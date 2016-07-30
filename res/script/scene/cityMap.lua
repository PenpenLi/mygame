
-- scene/cityMap.lua
-- 城市地图
--================================================
require "scene/Scene"
require "obj/building"
require "obj/cityPeople"

cityMap = class("cityMap", Scene)


--
-- init
----------------------------
function cityMap:init(enterFudi_)
	self.mapLevel = 3 --3级地图
	self.enterFudi = enterFudi_

	-- 变量初始化
	--================================
	self.tileMap = nil
	self.tileMapSize = nil
	self.tileMapBgLayer = nil
	self.objs = {} -- 数组，物体集合
	self.objMap = {} -- 二维数组，坐标点上的物体
	self.objTickCount = 0

	-- 
	self.isMoved = false --地图是否被移动
	self.touchedObj = nil --地图上被触摸的物体

	
	-- [[ mapLayer ]]
	-- 地图
	--==============================================
	self.mapLayer = cc.Layer:create()
		-- mapScrollView
		self.mapScrollView = cc.ScrollView:create()
		self.mapScrollView:setAnchorPoint(0, 0)
			-- mapContainer
			self.mapContainer = cc.Layer:create()
			self.mapContainer:setAnchorPoint(0, 0)
				-- bgLayer
				self.bgLayer = cc.Layer:create()
				self.bgLayer:setAnchorPoint(0, 0)
				self.mapContainer:addChild(self.bgLayer)
				-- objLayer
				self.objLayer = cc.Layer:create()
				self.objLayer:setAnchorPoint(0, 0)
				self.mapContainer:addChild(self.objLayer)
		self.mapScrollView:initWithViewSize(game.visibleSize, self.mapContainer)
		-- mapFadeOutText
		self.mapFadeOutText = cc.Label:createWithTTF("", "font/main.ttf", 16)
		self.mapFadeOutText:setVisible(false)
	self.mapLayer:addChild(self.mapScrollView)
	self.mapLayer:addChild(self.mapFadeOutText)


	local tileMapW = 8192 --瓦片地图的宽
	local tileMapH = 4096 --瓦片地图的高
	local mapBW = 896	--一块地图的宽
	local mapBH = 896	--一块地图的高
	local mapBNumW = 5	--宽度上有多少块组成
	local mapBNumH = 3	--高度上有多少块组成
	local mapWidth = mapBW*mapBNumW
	local mapHeight = mapBH*mapBNumH


	-- mapScrollView
	self.mapScrollView:setContentSize(cc.size(mapWidth, mapHeight))
	local minScale = game.visibleSize.width/mapWidth
	local minScaleY = game.visibleSize.height/mapHeight
	if minScale<minScaleY then
		minScale = minScaleY
	end
	minScale = minScale*1.1
	--self.mapScrollView:setMinScale(minScale)
	--self.mapScrollView:setMaxScale(minScale*3)
	self.mapScrollView:setBounceable(false)
	self.mapScrollView:setZoomScale(minScale*1.2)
	self.mapScrollView:setContentOffset(cc.p(0, 0))

	---- mapBg
	for i=1, mapBNumH do
		for j=1, mapBNumW do
			local mapBg = cc.Sprite:create(string.format("%scitybg%d-%d.png", config.dirUI.map, i,j))
			mapBg:setAnchorPoint(0, 0)
			mapBg:setPosition((j-1)*mapBW, (i-1)*mapBH)
			self.bgLayer:addChild(mapBg)
		end
	end

	-- tileMap
	local tileMap = cc.TMXTiledMap:create(config.dirUI.map .. "cell.tmx")
	self.bgLayer:addChild(tileMap)
	tileMap:setAnchorPoint(0, 0)
	tileMap:setPosition(-(tileMapW-mapWidth)/2, -(tileMapH-mapHeight)/2)
	-- 对Map需要的变量赋值
	self.tileMap = tileMap
	self.tileMapSize = tileMap:getMapSize()
	self.tileMapBgLayer = tileMap:getLayer("bg")
	
	-- [[ touchLayer ]]
	-- 获取并处理地图上的点击事件
	--==============================================
	self.touchLayer = cc.Layer:create()
	local function touchLayerOnTouched(event, px, py)
		local p = cc.p(px, py)
		if event=="began" then
			self:onTouchBegan(p)
		elseif event=="moved" then
			self:onTouchMoved(p)
		elseif event=="ended" then
			self:onTouchEnded(p)
		elseif event=="cancelled" then
			self:onTouchCancelled(p)
		end
		return true --must
	end
	self.touchLayer:setTouchEnabled(true)
	self.touchLayer:registerScriptTouchHandler(touchLayerOnTouched, false, 0, false)
	--self.touchLayer:registerScriptTouchHandler(handler, isMultiTouches=false, priority=0, swallowTouches=true)


	-- [[ infoLayer ]]
	-- 城内信息放置层
	--==========================
	self.infoLayer = cc.Layer:create()
	-- headerInfo
	require "ui/common/mainHeaderInfo"
	local hearderUI = UI_mainHeaderInfo.new()
	hearderUI:onAdd(self)
	self.infoLayer:addChild(hearderUI.layer)
	table.insert(self.uis, hearderUI)
	-- cityInfo
	require "ui/cityInfo"
	local cityInfo = UI_cityInfo.new()
	cityInfo:onAdd(self)
	self.infoLayer:addChild(cityInfo.layer)
	table.insert(self.uis, cityInfo)
	-- cd队列
	require "ui/common/cdList"
	local cdUI = UI_cdList.new()
	cdUI:onAdd(self)
	self.infoLayer:addChild(cdUI.layer)
	table.insert(self.uis, cdUI)

	-- [[ uiLayer ]]
	-- ui放置层，位于主菜单之下
	--==========================
	self.uiLayer = cc.Layer:create()
	self.UIs = {}

	-- [[ menuLayer ]]
	-- menu放置层
	--==========================
	self.menuLayer = cc.Layer:create()
	require "ui/mainMenu"
	local mainMenu = nil
	if enterFudi_ then
		mainMenu = UI_mainMenu.new(1)
	else
		mainMenu = UI_mainMenu.new(2)
	end
	mainMenu:onAdd(self)
	self.menuLayer:addChild(mainMenu.layer)
	table.insert(self.uis, mainMenu)
	self.mainMenu = mainMenu

	-- require "ui/talk/talkBtn"
	-- local talkBtn = UI_talkBtn.new()
	-- talkBtn:onAdd(self)
	-- self.menuLayer:addChild(talkBtn.layer)
	-- table.insert(self.uis, mainMenu)

	-- [[ modalUILayer ]]
	-- modal dialog放置层
	--==========================
	self.modalUILayer = cc.Layer:create()
	self.modalUIs = {}


	-- 添加各层到场景
	--==========================
	self:addCCNode(self.mapLayer)
	self:addCCNode(self.touchLayer)
	self:addCCNode(self.infoLayer)
	self:addCCNode(self.uiLayer)
	self:addCCNode(self.menuLayer)
	self:addCCNode(self.modalUILayer)

	-- 添加地块及其上面的建筑
	local buildingMgr = player.buildingMgr
	for k, v in ipairs(game.data.block) do
		if v.type==1 then
			self:addBuilding(v, buildingMgr.getBuildingByBsid(1, v.sid))
		elseif v.type==2 then
			self:addBuilding(v, buildingMgr.getBuildingByBsid(2, v.sid))
		end
	end
	-- 添加行人
	for i,v in ipairs(game.data.cityPeople) do
		CityPeople.new(self, v)
	end
	-- 添加装饰元素
	for i,v in ipairs(game.data.cityElement) do
		local eleNode = cc.Sprite:create(config.dirUI.cityElement .. v.img)
		local p = self:pMap2Tilemap(cc.p(v.x, v.y))
		eleNode:setAnchorPoint(0.5, 0.2)
		eleNode:setPosition(v.x, v.y)
		eleNode:setLocalZOrder(p.x+p.y)
		if v.flip==1 then
			eleNode:setScaleX(-1)
		end
		self.objLayer:addChild(eleNode)
	end

	-- 注册消息
	self:registMsg(hp.MSG.CD_FINISHED)
end

-- onEnter
function cityMap:onEnter()
	if self.enterFudi then
	-- 需要进入府邸内部界面
		require("ui/mansion/mansion")
		local ui = UI_mansion.new()
		self:addUI(ui)
	else
		self:onEnterAnim()
	end
	
	-- 进入新手指引
	--===============================
	player.guide.run()
end

-- onMsg
function cityMap:onMsg(msg_, paramInfo_)
	self.super.onMsg(self, msg_, paramInfo_)
	
	if msg_==hp.MSG.CD_FINISHED then
		if paramInfo_.cdType==cdBox.CDTYPE.BUILD then
			self:checkAllBuildingsUpIcon()
		end
	end
end

-- addUI
function cityMap:addUI(ui_)
	ui_.uiType_ = 0
	self.uiLayer:addChild(ui_.layer)
	table.insert(self.uis, ui_)
	table.insert(self.UIs, ui_)
	ui_:onAdd(self)
end

-- removeUI
function cityMap:removeUI(ui_)
	for i,ui in ipairs(self.uis) do
		if ui_==ui then
			table.remove(self.uis, i)

			ui_:onRemove()
			self.uiLayer:removeChild(ui_.layer)
			break
		end
	end

	for i,ui in ipairs(self.UIs) do
		if ui_==ui then
			table.remove(self.UIs, i)
			break
		end
	end
end

-- removeAllUI
function cityMap:removeAllUI()
	for i=#self.UIs, 1, -1 do
		local UI = self.UIs[i]
		for i,ui in ipairs(self.uis) do
			if UI==ui then
				table.remove(self.uis, i)
				break
			end
		end
		UI:onRemove()
		self.uiLayer:removeChild(UI.layer)
	end

	self.UIs = {}
end

-- addModalUI
function cityMap:addModalUI(ui_, zOrder_)
	ui_.uiType_ = 1
	ui_:onAdd(self)
	if zOrder_~=nil then
		self.modalUILayer:addChild(ui_.layer, zOrder_)
	else
		self.modalUILayer:addChild(ui_.layer)
	end
	table.insert(self.uis, ui_)
	table.insert(self.modalUIs, ui_)
end

-- removeModalUI
function cityMap:removeModalUI(ui_)
	for i,ui in ipairs(self.uis) do
		if ui_==ui then
			table.remove(self.uis, i)

			ui_:onRemove()
			self.modalUILayer:removeChild(ui_.layer)
			break
		end
	end

	for i,ui in ipairs(self.modalUIs) do
		if ui_==ui then
			table.remove(self.modalUIs, i)
			break
		end
	end
end

-- removeAllModalUI
function cityMap:removeAllModalUI()
	for i=#self.modalUIs, 1, -1 do
		local modalUI = self.modalUIs[i]
		for i,ui in ipairs(self.uis) do
			if modalUI==ui then
				table.remove(self.uis, i)
				break
			end
		end
		modalUI:onRemove()
		self.modalUILayer:removeChild(modalUI.layer)
	end

	self.modalUIs = {}
end

-- --
-- -- heartbeat
-- ----------------------------
-- function cityMap:heartbeat(dt)
-- 	self.super.heartbeat(self, dt)

-- 	-- 执行所有物体的heartbeat
-- 	self.objTickCount = self.objTickCount+dt
-- 	if self.objTickCount>=config.interval.objHeartbeat then
-- 		for i, obj in ipairs(self.objs) do
-- 			obj:heartbeat(self.objTickCount)
-- 		end
-- 		self.objTickCount = 0
-- 	end

-- end


--
-- 坐标转换
--========================================================
-- 屏幕坐标 --> 地图坐标
function cityMap:pScreen2Map(p_)
	local p = self.mapScrollView:getContentOffset()
	local scale = self.mapScrollView:getZoomScale()
	return cc.p((p_.x - p.x)/scale, (p_.y - p.y)/scale)
end

-- 地图坐标 --> 瓦片坐标
function cityMap:pMap2Tilemap(p_)
	local p = p_
	local px, py = self.tileMap:getPosition()
	local tileSize = self.tileMap:getTileSize()
	local midWidth = self.tileMapSize.width/2
	p.x = p.x-px
	p.y = p.y-py
	
	local x = math.floor(midWidth+(p.x/tileSize.width-p.y/tileSize.height))
	local y = math.floor(self.tileMapSize.height+midWidth - (p.x/tileSize.width + p.y/tileSize.height))

	return cc.p(x, y)
end

-- 屏幕坐标 --> 瓦片坐标
function cityMap:pScreen2Tilemap(p_)
	local p = self:pScreen2Map(p_)
	local px, py = self.tileMap:getPosition()
	local tileSize = self.tileMap:getTileSize()
	local midWidth = self.tileMapSize.width/2
	p.x = p.x-px
	p.y = p.y-py
	
	local x = math.floor(midWidth+(p.x/tileSize.width-p.y/tileSize.height))
	local y = math.floor(self.tileMapSize.height+midWidth - (p.x/tileSize.width + p.y/tileSize.height))

	return cc.p(x, y)
end

-- 瓦片坐标 --> 地图坐标
function cityMap:pTilemap2Map(p_)
	local p = self.tileMapBgLayer:getPositionAt(p_)
	local px, py = self.tileMap:getPosition()
	return cc.p(px+p.x, py+p.y)
end

-- 瓦片坐标 --> 屏幕坐标
function cityMap:pTilemap2Screen(p_)
	local pt1 = self.mapScrollView:getContentOffset()
	local scale = self.mapScrollView:getZoomScale()
	local pt2 = self:pTilemap2Map(p_)
	
	return cc.p(pt2.x*scale+pt1.x, pt2.y*scale+pt1.y)
end

-- 瓦片大小 --> 地图大小
function cityMap:sizeTilemap2Map(size_)
	local tileSize = self.tileMap:getTileSize()
	
	return cc.size(size_.width*tileSize.width, size_.height*tileSize.height)
end

-- 瓦片大小 --> 屏幕大小
function cityMap:sizeTilemap2Screen(size_)
	local tileSize = self.tileMap:getTileSize()
	local scale = self.mapScrollView:getZoomScale()
	
	return cc.size((size_.width*tileSize.width)*scale, (size_.height*tileSize.height)*scale)
end


--
-- touch消息
--==========================================================

-- onTouchBegan
function cityMap:onTouchBegan(p_)
	self.touchBeganP = p_
	local p = self:pScreen2Tilemap(p_)
	p_ = self:pScreen2Map(p_)
	self.isMoved = false

	if self.touchedObj~=nil then
	-- 处理多点触摸问题
		self.touchedObj:onLostFocus()
		self.touchedObj = nil
	end

	cclog("onTouchBegan--------------------------- x=%d, y=%d, x1=%d, y1=%d", p.x, p.y, p_.x, p_.y)
	-- 获取触摸到的物体
	if self.objMap[p.x]~=nil then
		self.touchedObj = self.objMap[p.x][p.y]
	end
	if self.touchedObj~=nil then
		self.touchedObj:onFocus()
	end
end

-- onTouchMoved
function cityMap:onTouchMoved(p_)
	local px = p_.x - self.touchBeganP.x
	local py = p_.y - self.touchBeganP.y
	if -5<px and px<5 and -5<py and py<5 then
	-- 移动小于5个像素
		return
	end

	self.isMoved = true
end

-- onTouchEnded
function cityMap:onTouchEnded(p_)
	if self.touchedObj~=nil then
		if self.isMoved==true then
			self.touchedObj:onLostFocus()
		else
			self.touchedObj:onClicked()
		end

		self.touchedObj = nil
	end
end

-- onTouchCancelled
function cityMap:onTouchCancelled(p_)
end


--
-- public function
--===================================

-- showFadeOutMsg
function cityMap:showFadeOutMsg(msg_, position_)
	local action = cc.FadeOut:create(2)
	self.mapFadeOutText:setString(msg_)
	if nil==position_ then
		self.mapFadeOutText:setPosition(self.touchP)
	else
		self.mapFadeOutText:setPosition(position_)
	end
	self.mapFadeOutText:setVisible(true)
	self.mapFadeOutText:runAction(action)
end

-- addBuilding
function cityMap:addBuilding(block_, build_)
	local obj = Building.new(self, block_, build_)
	for i=block_.left, block_.right do
		self.objMap[i] = self.objMap[i] or {}
		for j=block_.top, block_.bottom do
			self.objMap[i][j] = obj
		end
	end

	if build_~=nil and build_.sid==1018 then
	-- 城墙特殊处理
		for i=73, 79 do
			self.objMap[i] = self.objMap[i] or {}
			for j=46, 124 do
				self.objMap[i][j] = obj
			end
		end
		for i=19, 70 do
			self.objMap[i] = self.objMap[i] or {}
			for j=33, 40 do
				self.objMap[i][j] = obj
			end
		end
		local corners = {{70, 39}, {70, 40}, {69, 40}, {69, 41}}
		for i,v in ipairs(corners) do
			for i=0, 6 do
				local x_ = v[1]+i
				local y_ = v[2]+i
				self.objMap[x_] = self.objMap[x_] or {}
				self.objMap[x_][y_] = obj
			end
		end
	end

	table.insert(self.objs, obj)
end


-- getBuilding
function cityMap:getBuilding(bType_, bSid_)
	for i, v in ipairs(self.objs) do
		if bType_==v.block.type and bSid_==v.block.sid then
			return v
		end
	end

	return nil
end


-- getBlock
-- 获取一个已开放的空闲格子
function cityMap:getBlock(bType_)
	for i, v in ipairs(self.objs) do
		if bType_==v.block.type and v.build==nil and not v.unopenedFlag then
			return v
		end
	end

	return nil
end

-- getBuildingBySid
function cityMap:getBuildingBySid(sid_)
	local building = nil
	for i, v in ipairs(self.objs) do
		if v.build~=nil and sid_==v.build.sid then
			if building==nil then
				building = v
			else
				if v.build.lv>building.build.lv then
					building = v
				end
			end
		end
	end

	return building
end

-- checkAllBuildingsUpIcon
function cityMap:checkAllBuildingsUpIcon()
	for i, build in ipairs(self.objs) do
		build:checkUpIcon()
	end
end

-- add by huanghaitao
function cityMap:preExit()
	local tick_ = os.clock()
	self.super.preExit(self)
	for i, build in ipairs(self.objs) do
		build:onRemove()
	end 
	player.clockEnd("cityMap:preExit", tick_, 0.3)
end