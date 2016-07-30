--
-- scene/kingdomMap.lua
-- 王国地图
--================================================
require "scene/Scene"

local kmapHttpHelper = require("scene/assist/kmapHttpHelper")


kingdomMap = class("kingdomMap", Scene)


local refreshTickCont = 12.0 --定时刷新时间
local posViewTickCont = 11.0 --移动地图时，将计时调整时间

local myServerInfo = nil --自己的服务器
local myPosServerInfo = nil --自己位置的服务器
local activityServerInfo = nil --世界活动敌对服务器

local myPosServerX = 2
local myPosServerY = 2

local g_resTextColor = cc.c4b(255, 216, 0, 255)
local g_allyTextColor = cc.c4b(107, 229, 225, 255)
local g_enemyTextColor = cc.c4b(255, 83, 83, 255)
local g_myUnionID = 0
local g_myUnionName = ""
local g_myID = 0
local g_myName = ""

local function getMyInfo()
	local alliance = player.getAlliance()
	g_myUnionID = alliance:getUnionID()
	if g_myUnionID==0 then
		g_myUnionName = ""
	else
		g_myUnionName = alliance:getBaseInfo().name	--发送者公会
	end
	g_myName = player.getName()
	g_myID = player.getID()
end


--
--=========================================================
-- init
function kingdomMap:init()
	self.mapLevel = 2 --2级地图

	getMyInfo()
	--data
	--============================
	self.centerPosition = {kx=-1, ky=-1, x=0, y=0}
	self.tickCount = 0
	self.objs = {}
	self.armys = {}
	self.armyObjs = {}
	self.armyRefreashOk = true

	self.touchBeganP = cc.p(0, 0)

	--初始化
	--===========================
	self:initMapInfo()
	self:initMapView()
	self:initArmyView()
	self:initResInfo()
	self:initFortress()
	self:initGuideLayer()
	kmapHttpHelper.init(self)

	-- [[ mapLayer ]]
	-- 地图层
	--===========================
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
		self.mapScrollView:initWithViewSize(game.visibleSize, self.mapContainer)

		-- mapInfo
		self.labelMapInfo = cc.Label:createWithTTF("", "font/main.ttf", math.ceil(28*hp.uiHelper.RA_scale))
		self.labelMapInfo:setPosition(game.visibleSize.width/2, 200*hp.uiHelper.RA_scaleY)
	self.mapLayer:addChild(self.mapScrollView)
	self.mapLayer:addChild(self.labelMapInfo)

	local mapInfo = self.mapInfo
	local function onScrolled()
		local tilew = mapInfo.map.tilew
		local tileh = mapInfo.map.tileh
		local p = self.mapScrollView:getContentOffset()
		local scale = self.mapScrollView:getZoomScale()

		local px = math.floor((-p.x/scale)/tilew)
		local py = math.floor(self.h-(-p.y/scale)/(tileh/2))
		self:posMapView(px, py)

		local kdCoor = self:coWorld2Kindom(cc.p(game.visibleSize.width/2, game.visibleSize.height/2))
		local serverInfo = player.serverMgr.getServerByPos(kdCoor.kx, kdCoor.ky)
		self.labelMapInfo:setString(player.serverMgr.formatPosition(kdCoor, true))

		if self.centerPosition.kx~=kdCoor.kx or self.centerPosition.ky~=kdCoor.ky then
			self:resetFortressPos(kdCoor.kx, kdCoor.ky)
		end
		self.centerPosition = kdCoor
	end
	self.mapScrollView:setContentSize(cc.size(self.pw, self.ph))
	self.mapScrollView:setBounceable(false)
	local minScale = hp.uiHelper.RA_scale
	--self.mapScrollView:setMinScale(minScale)
	--self.mapScrollView:setMaxScale(2*minScale)
	self.mapScrollView:setZoomScale(1.2*minScale)
	self.mapScrollView:setDelegate()
	self.mapScrollView:registerScriptHandler(onScrolled, 0)
	self.bgLayer:addChild(self.viewLayer)
	self.bgLayer:addChild(self.fortressLayer)
	self.bgLayer:addChild(self.armyLayer)
	self.bgLayer:addChild(self.guideLayer)

	self:gotoPosition(player.serverMgr.getMyPosition())

	-- [[ touchLayer ]]
	-- 地图触屏处理层
	--===========================
	self.touchLayer = cc.Layer:create()
	local function touchLayerOnTouched(event, touchs)
		if event=="began" then
			self:onTouchBegan(touchs)
		elseif event=="moved" then
			self:onTouchMoved(touchs)
		elseif event=="ended" then
			self:onTouchEnded(touchs)
		elseif event=="cancelled" then
			self:onTouchCancelled(touchs)
		end
		return true --must
	end
	self.touchLayer:setTouchEnabled(true) 
	self.touchLayer:registerScriptTouchHandler(touchLayerOnTouched, true, 0, false)
	--self.touchLayer:registerScriptTouchHandler(handler, isMultiTouches=false, priority=0, swallowTouches=true)


	-- [[ infoLayer ]]
	-- 地图信息信息放置层
	--==========================
	-- top信息
	self.infoLayer = cc.Layer:create()
	require "ui/bigMap/common/topMenu" 
	local topMenu = UI_topMenu.new()
	topMenu:onAdd(self)
	self.infoLayer:addChild(topMenu.layer)
	table.insert(self.uis, topMenu)
	-- 行军管理按钮
	require "ui/march/marchMgrBtn"
	local ui_ = UI_marchMgrBtn.new()
	ui_:onAdd(self)
	self.infoLayer:addChild(ui_.layer)
	table.insert(self.uis, ui_)
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
	local mainMenu = UI_mainMenu.new(3)
	mainMenu:onAdd(self)
	self.menuLayer:addChild(mainMenu.layer)
	table.insert(self.uis, mainMenu)
	self.mainMenu = mainMenu

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

	-- add message
	self:registMsg(hp.MSG.MAP_ARMY_ATTACK)
	self:registMsg(hp.MSG.UNION_JOIN_SUCCESS)
	self:registMsg(hp.MSG.UNION_NOTIFY)
	self:registMsg(hp.MSG.KING_BATTLE)
	self:registMsg(hp.MSG.CITY_POS_CHANGED)
	self:registMsg(hp.MSG.KINGDOM_ACTIVITY)

	-- 2级地图指定地图信息管理
	self.conflictManager = require("playerData/conflictManager")
	self.conflictManager.init()

	self.sourceUIHelper = require("scene/assist/sourceUIHelper")
	self.sourceUIHelper.init()
end

-- onEnter
function kingdomMap:onEnter()
	self:onEnterAnim()
end

function kingdomMap:coWorld2Kindom(coWorld)
	local tilep = self:pScreen2Tile(coWorld)
	local showp = self:pTile2Real(tilep)
	local kx = math.ceil((tilep.x+1)/self.mapInfo.map.w)
	local ky = math.ceil((tilep.y+1)/self.mapInfo.map.h)
	local x = showp.x%(self.mapInfo.map.w*2)
	local y = showp.y%self.mapInfo.map.h
	return {kx=kx,ky=ky,x=x,y=y}
end

-- addUI
function kingdomMap:addUI(ui_)
	ui_.uiType_ = 0
	self.uiLayer:addChild(ui_.layer)
	table.insert(self.uis, ui_)
	table.insert(self.UIs, ui_)
	ui_:onAdd(self)
end

-- removeUI
function kingdomMap:removeUI(ui_)
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
function kingdomMap:removeAllUI()
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
function kingdomMap:addModalUI(ui_, zOrder_)
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
function kingdomMap:removeModalUI(ui_)
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
function kingdomMap:removeAllModalUI()
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


--
--=========================================================
-- initMapInfo
function kingdomMap:initMapInfo()
	--
	--===============================
	-- local serverList = {}
	-- for i, srvInfo in ipairs(game.data.serverList) do
	-- 	serverList[srvInfo.y] = serverList[srvInfo.y] or {}
	-- 	serverList[srvInfo.y][srvInfo.x] = srvInfo
	-- end

	local mapInfo = require(config.dirUI.map .. "kingdomMapInfo")
	local mapData = cc.FileUtils:getInstance():getStringFromFile(config.dirUI.map .. "data.client")
	self.mapInfo = mapInfo
	self.mapData = mapData

	myServerInfo = player.serverMgr.getMyServer()
	myPosServerInfo = player.serverMgr.getMyPosServer()
	myPosServerY = myPosServerInfo.y
	myPosServerX = myPosServerInfo.x

	-- 获取跨服活动的服务器信息
	local activity = player.kingdomActivityMgr.getActivity()
	if activity and activity.status == UNION_ACTIVITY_STATUS.OPEN then
		activityServerInfo = player.serverMgr.getServerBySid(activity.serverID)
	else
		activityServerInfo = nil
	end


	-- 世界地图的大小(国家)
	local sz = player.serverMgr.getWorldSize()
	-- 地图的总宽高(瓦片)
	self.w = mapInfo.map.w * sz.width
	self.h = mapInfo.map.h * sz.height
	-- 一个王国地图的宽高(像素)
	self.kpw = mapInfo.map.w * mapInfo.map.tilew
	self.kph = mapInfo.map.h * mapInfo.map.tileh / 2
	-- 地图的总宽高(像素)
	self.pw = self.kpw * sz.width + mapInfo.map.tilew/2
	self.ph = self.kph * sz.height + mapInfo.map.tileh/2
	
	-- 瓦片纹理、纹理矩形
	local tileTextures = {}
	local tileTexturesRect = {}
	for i, v in ipairs(mapInfo.imgs) do
		local texture2D = cc.Director:getInstance():getTextureCache():addImage(config.dirUI.map .. v.path)
		texture2D:retain()
		local gid = v.firstid
		for h=0, v.h-1 do
			for w=0, v.w-1 do
				tileTextures[gid] = texture2D
				tileTexturesRect[gid] = cc.rect(mapInfo.tileSet.w*w, mapInfo.tileSet.h*h, mapInfo.tileSet.w, mapInfo.tileSet.h)
				gid = gid+1
			end
		end
	end
	self.tileTextures = tileTextures
	self.tileTexturesRect = tileTexturesRect
end

-- initMapView
function kingdomMap:initMapView()
	local mapInfo = self.mapInfo
	local tilew = mapInfo.map.tilew
	local tileh = mapInfo.map.tileh
	local px = mapInfo.tileSet.x
	local py = mapInfo.tileSet.y

	local minScale = hp.uiHelper.RA_scale
	local viewW = math.ceil(game.visibleSize.width*2/(tilew*2*minScale))
	local viewH = math.ceil(game.visibleSize.height*2/(tileh*minScale))
	self.viewW = viewW
	self.viewH = viewH
	local w = viewW*3
	local h = viewH*3

	local psx = -tilew*(viewW+1)
	local psy = tileh*(viewH-1/2)

	-- 创建精灵
	local viewLayer = cc.Layer:create()
	local viewGroundLayer = cc.Layer:create()
	local viewLevelLayer = cc.Layer:create()
	local viewIconLayer = cc.Layer:create()
	local viewDescLayer = cc.Layer:create()
	viewLayer:addChild(viewGroundLayer)
	viewLayer:addChild(viewLevelLayer)
	viewLayer:addChild(viewIconLayer)
	viewLayer:addChild(viewDescLayer)

	local viewSprites = {}
	local groundNode = nil
	local objNode = nil
	local descBgNode = nil
	local descNode = nil
	local vipNode = nil
	local markNode = nil
	local titleNode = nil
	local plateSprite = nil
	local lvSprite = nil

	local xTmp = 1
	local yTmp = 1
	local xTmp1 = 1
	local yTmp1 = 1

	local xoffset = mapInfo.tileSet.w/2+px
	local yOffset = mapInfo.tileSet.h/2+py

	for i=1, h do
		viewSprites[i] = {}
		for j=1, w do
			groundNode = cc.Sprite:create()
			groundNode:setAnchorPoint(0, 0)
			objNode = cc.Sprite:create()
			descBgNode = cc.Sprite:create(config.dirUI.map .. "name_bg.png")
			descNode = cc.Label:createWithTTF("", "font/main.ttf", 20)
			vipNode = cc.Sprite:create()
			markNode = cc.Sprite:create()
			titleNode = cc.Sprite:create()
			plateSprite = cc.Sprite:create(config.dirUI.building .. "lvPlate.png")
			lvSprite = cc.Sprite:create()
			plateSprite:addChild(lvSprite)
			plateSprite:setVisible(false)

			-- ground and obj
			if i%2==1 then
				xTmp = psx+tilew*j+px
				yTmp = psy-tileh/2*i-py-tileh/4
			else
				xTmp = psx+tilew*j+tilew/2+px
				yTmp = psy-tileh/2*i-py-tileh/4
			end
			groundNode:setPosition(xTmp, yTmp)
			objNode:setPosition(tilew/2+10, 30)
			objNode:setAnchorPoint(0.5, 0)
			groundNode:addChild(objNode)

			-- other infos
			xTmp1 = xTmp+xoffset
			yTmp1 = yTmp+yOffset-tileh/2
			descBgNode:setPosition(xTmp1, yTmp1)
			descNode:setPosition(xTmp1, yTmp1-2)
			yTmp1 = yTmp+yOffset
			markNode:setPosition(xTmp1, yTmp1+50)
			titleNode:setPosition(xTmp1-70, yTmp1+50)
			plateSprite:setPosition(xTmp1+tilew/4, yTmp1-tileh/4)		
			lvSprite:setPosition(30, 30)	
			plateSprite:setScale(0.5)

			viewGroundLayer:addChild(groundNode)
			viewDescLayer:addChild(descBgNode)
			viewDescLayer:addChild(descNode)
			descBgNode:addChild(vipNode)
			vipNode:setScale(0.4)
			vipNode:setPosition(-8, 14)
			viewIconLayer:addChild(markNode)
			viewIconLayer:addChild(titleNode)			
			viewLevelLayer:addChild(plateSprite)

			viewSprites[i][j] = {
				groundNode = groundNode,
				objNode = objNode,
				descBgNode = descBgNode,
				descNode = descNode,
				vipNode = vipNode,
				markNode = markNode,
				titleNode = titleNode,
				plateSprite = plateSprite,
				lvSprite = lvSprite
				}
		end
	end

	--
	-- 
	local x = tilew*viewW/2
	local y = tileh*viewH/2
	local viewRect = {}
	viewRect.top = self.mapInfo.map.tileh*viewH
	viewRect.bottom = -self.mapInfo.map.tileh*viewH/2
	viewRect.left = -self.mapInfo.map.tilew*viewW
	viewRect.right = self.mapInfo.map.tilew*viewW*2
	self.viewRect = viewRect
	--蒙版1
	local viewMask1 = cc.Sprite:create(config.dirUI.map .. "mask.png")
	viewMask1:setAnchorPoint(1, 0)
	viewMask1:setScale(1024)
	viewMask1:setPosition(x, y)
	viewLayer:addChild(viewMask1)
	self.viewMask1 = viewMask1
	--蒙版2
	local viewMask2 = cc.Sprite:create(config.dirUI.map .. "mask.png")
	viewMask2:setAnchorPoint(0, 0)
	viewMask2:setScale(1024)
	viewMask2:setPosition(x, y)
	viewLayer:addChild(viewMask2)
	self.viewMask2 = viewMask2
	--蒙版3
	local viewMask3 = cc.Sprite:create(config.dirUI.map .. "mask.png")
	viewMask3:setAnchorPoint(1, 1)
	viewMask3:setScale(1024)
	viewMask3:setPosition(x, y)
	viewLayer:addChild(viewMask3)
	self.viewMask3 = viewMask3
	--蒙版4
	local viewMask4 = cc.Sprite:create(config.dirUI.map .. "mask.png")
	viewMask4:setAnchorPoint(0, 1)
	viewMask4:setScale(1024)
	viewMask4:setPosition(x, y)
	viewLayer:addChild(viewMask4)
	self.viewMask4 = viewMask4
	--水平边界横线
	local viewBorderH = cc.Sprite:create(config.dirUI.map .. "border.png")
	viewBorderH:setScaleX(1024)
	viewBorderH:setPosition(x, y)
	viewLayer:addChild(viewBorderH)
	self.viewBorderH = viewBorderH
	--垂直边界横线
	local viewBorderV = cc.Sprite:create(config.dirUI.map .. "border.png")
	viewBorderV:setRotation(90)
	viewBorderV:setScaleX(1024)
	viewBorderV:setPosition(x, y)
	viewLayer:addChild(viewBorderV)
	self.viewBorderV = viewBorderV

	self.viewLayer = viewLayer
	self.viewSprites = viewSprites
end


-- initResInfo
-- 初始化资源点信息
function kingdomMap:initResInfo()
	local resInfos = {}
	for i, v in ipairs(game.data.resources) do
		local resInfo = {}
		local resImgPath = string.format("%sres%d.png", config.dirUI.map, v.sid)
		resInfo.info = v
		resInfo.texture2D = cc.Director:getInstance():getTextureCache():addImage(resImgPath)
		resInfo.texture2D:retain()
		resInfos[v.sid] = resInfo
	end

	local homeTexture2D = {}
	local hostileTexture2D = {}
	local x = 1
	for i=1, 5 do
		homeTexture2D[i] = cc.Director:getInstance():getTextureCache():addImage(config.dirUI.map .. "home_icon"..i..".png")
		hostileTexture2D[i] = cc.Director:getInstance():getTextureCache():addImage(config.dirUI.map .. "hostile_home"..i..".png")
		homeTexture2D[i]:retain()
		hostileTexture2D[i]:retain()
	end

	-- boss info
	local bossInfos = {}
	for i, v in ipairs(game.data.boss) do
		local bossInfo_ = {}
		bossInfos[v.sid] = v
	end

	self.resInfos = resInfos
	self.homeTexture2D = homeTexture2D
	self.hostileTexture2D = hostileTexture2D
	self.bossInfos = bossInfos
end


-- posMapView
function kingdomMap:posMapView(tileX, tileY, mustRefresh)
	if tileY%2~=0 then
		tileY = tileY-1
	end

	local viewW = self.viewW
	local viewH = self.viewH

	if mustRefresh then
	else
		if mustFlag_==nil and self.viewTileX~=nil and self.viewTileY~=nil then
			local x_ = self.viewTileX-tileX
			local y_ = self.viewTileY-tileY
			if -viewW<x_ and x_<viewW and -viewH<y_ and y_<viewH then
				return
			end
		end
	end

	-- 停顿一下，请求地图信息
	self.tickCount = posViewTickCont

	self.viewTileX = tileX
	self.viewTileY = tileY
	self:refreshMapViewObjs()

	local x1 = tileX-viewW+1
	local x2 = tileX+2*viewW
	local y1 = tileY-2*viewH+1
	local y2 = tileY+viewH
	local h = self.h
	local w = self.w
	local kh = self.mapInfo.map.h
	local kw = self.mapInfo.map.w

	-- 获取边界焦点
	local kl = math.ceil(x2/kw)
	local l = (kl-1)*kw-tileX
	local kr = math.ceil(y2/kh)
	local r = tileY - (kr-1)*kh
	local x = (l+0.25)*self.mapInfo.map.tilew
	local y = (r-0.5)*self.mapInfo.map.tileh/2
	local viewRect = self.viewRect

	if x<viewRect.left then
		x = viewRect.left
	elseif x>viewRect.right then
		x = viewRect.right
	end
	if y<viewRect.bottom then
		y = viewRect.bottom
	elseif y>viewRect.top then
		y = viewRect.top
	end

	local kr1 = kr-1
	local kl1 = kl-1
	local kr2 = kr-1
	local kl2 = kl
	local kr3 = kr
	local kl3 = kl-1

	-- 自己国家 和 开启国战的活动国家 亮起
	if (activityServerInfo and kr1==activityServerInfo.y and kl1==activityServerInfo.x) or (kr1==myServerInfo.y and kl1==myServerInfo.x) then
		self.viewMask1:setVisible(false)
	else
		self.viewMask1:setVisible(true)
	end
	if (activityServerInfo and kr2==activityServerInfo.y and kl2==activityServerInfo.x) or (kr2==myServerInfo.y and kl2==myServerInfo.x) then
		self.viewMask2:setVisible(false)
	else
		self.viewMask2:setVisible(true)
	end
	if (activityServerInfo and kr3==activityServerInfo.y and kl3==activityServerInfo.x) or (kr3==myServerInfo.y and kl3==myServerInfo.x) then
		self.viewMask3:setVisible(false)
	else
		self.viewMask3:setVisible(true)
	end
	if (activityServerInfo and kr==activityServerInfo.y and kl==activityServerInfo.x) or (kr==myServerInfo.y and kl==myServerInfo.x) then
		self.viewMask4:setVisible(false)
	else
		self.viewMask4:setVisible(true)
	end

	self.viewMask1:setPosition(x, y)
	self.viewMask2:setPosition(x, y)
	self.viewMask3:setPosition(x, y)
	self.viewMask4:setPosition(x, y)
	self.viewBorderH:setPosition(x, y)
	self.viewBorderV:setPosition(x, y)

	self.viewLayer:setPosition(tileX*self.mapInfo.map.tilew, self.ph-tileY*(self.mapInfo.map.tileh/2))
end

-- 刷新地图上的物体
function kingdomMap:refreshMapViewObjs()
	local tileX = self.viewTileX
	local tileY = self.viewTileY

	if tileY%2~=0 then
		tileY = tileY-1
	end

	local viewW = self.viewW
	local viewH = self.viewH

	local x1 = tileX-viewW+1
	local x2 = tileX+2*viewW
	local y1 = tileY-2*viewH+1
	local y2 = tileY+viewH

	local h = self.h
	local w = self.w
	local kh = self.mapInfo.map.h
	local kw = self.mapInfo.map.w
	
	local kr = 1
	local r = 1
	local kl = 1
	local l = 1

	local viewSprites = self.viewSprites
	local tileTextures = self.tileTextures
	local tileTexturesRect = self.tileTexturesRect
	local mapData = self.mapData
	local gid = 1

	local sp = nil
	local strPos = nil
	local objTmp = nil

	local bMainTable = game.data.main
	-- viewSprites[i][j] = {
	-- 			groundNode = groundNode,
	-- 			objNode = objNode,
	--			descBgNode = descBgNode,
	-- 			descNode = descNode,
	-- 			}

	local i = 1
	local j = 1
	for y=y1, y2 do
		j = 1
		if y<1 or y>h then
			for x=x1, x2 do
				sp = viewSprites[i][j]
				sp.objNode:removeAllChildren()
				sp.markNode:setVisible(false)
				sp.titleNode:setVisible(false)					
				sp.plateSprite:setVisible(false)
				sp.groundNode:setVisible(false)
				sp.descBgNode:setVisible(false)
				sp.descNode:setVisible(false)

				j = j+1
			end
		else
			kr = math.ceil(y/kh)
			r = y - (kr-1)*kh
			for x=x1, x2 do
				sp = viewSprites[i][j]
				sp.objNode:removeAllChildren()
				sp.markNode:setVisible(false)
				sp.titleNode:setVisible(false)					
				sp.plateSprite:setVisible(false)

				if x<1 or x>w then
					sp.groundNode:setVisible(false)
					sp.descBgNode:setVisible(false)
					sp.descNode:setVisible(false)
				else
					local vipLv = 0
					sp.groundNode:setVisible(true)

					strPos = string.format("%d-%d", x-1, y-1)
					objTmp = self.objs[strPos]
					if objTmp~=nil then
					-- 地面上有物体
						if objTmp.type==1 then
						-- 城池
							local homeTexture
							if activityServerInfo and objTmp.serverID==activityServerInfo.sid then
							-- 跨服活动开启
								homeTexture=self.hostileTexture2D[bMainTable[objTmp.level].mapImg]
							else
								homeTexture=self.homeTexture2D[bMainTable[objTmp.level].mapImg]
							end

							sp.objNode:setTexture(homeTexture)
							sp.objNode:setTextureRect(homeTexture:getContentSize())
							local str = objTmp.name
							if objTmp.unionName ~= "" then
								str = hp.lang.getStrByID(21)..objTmp.unionName..hp.lang.getStrByID(22)..objTmp.name
							end
							sp.descNode:setString(str)
							if g_myUnionID==0 then
								if g_myName==objTmp.name then
									sp.descNode:setTextColor(g_allyTextColor)
								else
									sp.descNode:setTextColor(g_enemyTextColor)
								end
							else
								if g_myUnionID==objTmp.unionID then
									sp.descNode:setTextColor(g_allyTextColor)
								else
									sp.descNode:setTextColor(g_enemyTextColor)
								end
							end
							if objTmp.proCD>0 then
							--新手保护中。。
								local ani = hp.sequenceAniHelper.createAnimSprite("bigMap", "protect", 12, 0.1)
								ani:setPosition(116, 80)
								sp.objNode:addChild(ani)
							end

							local fireTime_ = objTmp.defeated-player.getServerTime()
							if fireTime_ > 0 then
								local ani = hp.sequenceAniHelper.createAnimSprite("bigMap", "fire", 12, 0.1)
								ani:setPosition(116, 96)
								sp.objNode:addChild(ani)
							end
							sp.plateSprite:setVisible(true)
							sp.lvSprite:setTexture(string.format("%slv%d.png", config.dirUI.building, objTmp.level))
							-- 俘虏
							if objTmp.captive > 0 then
								sp.markNode:setVisible(true)
								sp.markNode:setTexture(config.dirUI.common.."kd_10.png")
							else
								sp.markNode:setVisible(false)
							end
							-- 头衔
							if objTmp.title ~= 0 and objTmp ~= nil then
								sp.titleNode:setVisible(true)
								sp.titleNode:setTexture(config.dirUI.title..objTmp.title..".png")
							end
							--vip
							if objTmp.vipCD>0 and objTmp.vipLv>0 then
								vipLv = objTmp.vipLv
								sp.vipNode:setTexture(config.dirUI.common.."vip_icon_"..vipLv..".png")
							end
						elseif objTmp.type==2 then
						-- 资源点
							local resInfo = self.resInfos[objTmp.sid]
							local objTmpArmy = self.armyObjs[strPos]
							sp.objNode:setTexture(resInfo.texture2D)
							sp.objNode:setTextureRect(resInfo.texture2D:getContentSize())
							sp.descNode:setString(resInfo.info.name)
							sp.descNode:setTextColor(g_resTextColor)
							if objTmpArmy then
							--有军队在采集
								local armyInfo = objTmpArmy.armyInfo
								if armyInfo.pid==g_myID then
								-- 自己
									sp.markNode:setTexture(config.dirUI.common.."kd_7.png")
								elseif armyInfo.unionID==0 or armyInfo.unionID~=g_myUnionID then
								-- 敌军
									sp.markNode:setTexture(config.dirUI.common.."kd_9.png")
								else
								-- 盟友
									sp.markNode:setTexture(config.dirUI.common.."kd_8.png")
								end
								sp.markNode:setVisible(true)
							end
						elseif objTmp.type==4 then
						-- 野怪
							local bossInfo = self.bossInfos[objTmp.sid]
							sp.objNode:setVisible(true)
							sp.objNode:setTextureRect(cc.size(0, 0))
							local aniNode = hp.sequenceAniHelper.createAnimation(bossInfo.animation)
							local hpBg = cc.Sprite:create(config.dirUI.common .. "boss_hp_proBg3.png")
							local hp = cc.Sprite:create(config.dirUI.common .. "boss_hp_pro3.png")
							hpBg:addChild(hp)
							hp:setAnchorPoint(0, 0)
							hp:setPosition(2, 2)
							hp:setTextureRect(cc.rect(0, 0, math.ceil(objTmp.life*125/bossInfo.maxLife), 12))

							hpBg:setPosition(24, 0)
							aniNode:addChild(hpBg)
							aniNode:setAnchorPoint(0.5, 0)
							aniNode:setPosition(0, 24)
							sp.objNode:addChild(aniNode)
							sp.descNode:setString(bossInfo.name)
							sp.descNode:setTextColor(g_enemyTextColor)
						end

						sp.objNode:setVisible(true)
						sp.descBgNode:setVisible(true)
						sp.descNode:setVisible(true)
						sp.descBgNode:setTextureRect(cc.rect(0, 0, sp.descNode:getContentSize().width+20, 28))

						if vipLv>0 then
							sp.vipNode:setVisible(true)
						else
							sp.vipNode:setVisible(false)
						end
						--地表用平地设置
						sp.groundNode:setTexture(tileTextures[1])
						sp.groundNode:setTextureRect(tileTexturesRect[1])
					else
					-- 空地
						local objTmpArmy = self.armyObjs[strPos]
						if objTmpArmy~=nil then
						-- 有驻军
							sp.objNode:setTexture(config.dirUI.map.."camp.png")
							sp.objNode:setVisible(true)
							sp.descBgNode:setVisible(false)
							sp.descNode:setVisible(false)
							-- 地表用平地设置
							sp.groundNode:setTexture(tileTextures[1])
							sp.groundNode:setTextureRect(tileTexturesRect[1])

							-- 营地改为不显示玩家名
							-- local armyInfo = objTmpArmy.armyInfo
							-- local str = armyInfo.name
							-- if armyInfo.unionID ~= 0 then
							-- 	str = hp.lang.getStrByID(21)..armyInfo.unionName..hp.lang.getStrByID(22)..armyInfo.name
							-- else
							-- 	str = armyInfo.name
							-- end
							-- sp.descNode:setString(str)
							-- if g_myUnionID==0 then
							-- 	if g_myName==armyInfo.name then
							-- 		sp.descNode:setTextColor(g_allyTextColor)
							-- 	else
							-- 		sp.descNode:setTextColor(g_enemyTextColor)
							-- 	end
							-- else
							-- 	if g_myUnionID==armyInfo.unionID then
							-- 		sp.descNode:setTextColor(g_allyTextColor)
							-- 	else
							-- 		sp.descNode:setTextColor(g_enemyTextColor)
							-- 	end
							-- end
							-- sp.descBgNode:setVisible(true)
							-- sp.descNode:setVisible(true)
							-- sp.descBgNode:setTextureRect(cc.rect(0, 0, sp.descNode:getContentSize().width+20, 28))

						else
						-- 无驻军
							sp.objNode:setVisible(false)
							sp.descBgNode:setVisible(false)
							sp.descNode:setVisible(false)

							-- 获取并设置地表
							kl = math.ceil(x/kw)
							l = x - (kl-1)*kw
							gid = string.byte(mapData, (r-1)*kw+l)
							sp.groundNode:setTexture(tileTextures[gid])
							sp.groundNode:setTextureRect(tileTexturesRect[gid])
						end
					end
				end
				j = j+1
			end
		end
		i = i+1
	end
end

-- 触屏处理
--======================================================
-- onTouchBegan
function kingdomMap:onTouchBegan(touchs_)
	local pNum = table.getn(touchs_)
	if pNum==3 then
		self.touchBeganP = cc.p(touchs_[1], touchs_[2])
		local p = self:pScreen2Tile(self.touchBeganP)
		local x = self.viewTileX-self.viewW-1
		local y = self.viewTileY-2*self.viewH-1
		local i = p.y-y
		local j = p.x-x
		if self.spriteTouched==nil then
			local strPos = string.format("%d-%d", p.x, p.y)
			self.touchedInfo = self.objs[strPos]
			if self.touchedInfo==nil then
				self.touchedInfo = self.armyObjs[strPos]
			else
				local army = self.armyObjs[strPos]
				if army~=nil then
					self.touchedInfo.armyInfo = army.armyInfo
				else
					self.touchedInfo.armyInfo = nil
				end
			end

			self.tileType = self:getTileType(p)
			self.tileInfo = {}
			self.tileInfo.tileType = self.tileType
			self.tileInfo.position = self:coWorld2Kindom(cc.p(touchs_[1], touchs_[2]))
			self.tileInfo.objInfo = self.touchedInfo

			local p_ = self.tileInfo.position
			if (p_.x == 255 and p_.y == 511) or (p_.x == 255 and p_.y == 509) or 
				(p_.x == 254 and p_.y == 510) or (p_.x == 256 and p_.y == 510) then
				-- 重镇
				self.spriteTouched = self.fortress
				self.touchedInfo = {type=10}
				self.tileInfo.position.x = 255
				self.tileInfo.position.y = 511
			else
				if self.touchedInfo ~= nil then
				-- 点击到了物体(城池、资源点、boss、驻军)
					self.spriteTouched = self.viewSprites[i][j].objNode
				else
					self.spriteTouched = self.viewSprites[i][j].groundNode
				end
			end
			self.spriteTouched:updateDisplayedColor(cc.c3b(128, 128, 128))
		else
			local spriteTmp = self.spriteTouched
			self.spriteTouched = nil
			spriteTmp:updateDisplayedColor(cc.c3b(255, 255, 255))
		end
	else
		--多点触摸
		if self.spriteTouched~=nil then
			local spriteTmp = self.spriteTouched
			self.spriteTouched = nil
			spriteTmp:updateDisplayedColor(cc.c3b(255, 255, 255))
		end
	end
end
-- onTouchMoved
function kingdomMap:onTouchMoved(touchs_)
	local pNum = table.getn(touchs_)
	if pNum==3 then
		local px = touchs_[1] - self.touchBeganP.x
		local py = touchs_[2] - self.touchBeganP.y
		if -5<px and px<5 and -5<py and py<5 then
		-- 移动小于5个像素
			return
		end
	end

	if self.spriteTouched~=nil then
		local spriteTmp = self.spriteTouched
		self.spriteTouched = nil
		spriteTmp:updateDisplayedColor(cc.c3b(255, 255, 255))
	end
end
-- onTouchEnded
function kingdomMap:onTouchEnded(touchs_)
	if self.spriteTouched~=nil then
		local spriteTmp = self.spriteTouched
		self.spriteTouched = nil
		spriteTmp:updateDisplayedColor(cc.c3b(255, 255, 255))
		self:removeGuidePoint()

		local tpos = self.tileInfo.position
		local ui_ = nil
		if self.touchedInfo ~= nil then
			if self.touchedInfo.type == 1 then
			-- 城市
				local cityInfo = self.touchedInfo
				if g_myID == cityInfo.id then
				-- 自己城市
					require "ui/bigMap/city/myCity"
					ui_ = UI_myCity.new(self.tileInfo)
					self:addModalUI(ui_)
				elseif g_myUnionID==0 or g_myUnionID~=cityInfo.unionID then
				-- 敌方城市
					require "ui/bigMap/city/enemyCity"
					ui_ = UI_enemyCity.new(self.tileInfo)
					self:addModalUI(ui_)
				else
				-- 友军城市
					require "ui/bigMap/city/unionCity"
					ui_ = UI_unionCity.new(self.tileInfo)
					self:addModalUI(ui_)
				end
			elseif self.touchedInfo.type == 2 then
			-- 资源点
				local armyInfo = self.touchedInfo.armyInfo
				if armyInfo == nil then
				-- 无人占领
					require "ui/bigMap/source/UISource"
					ui_ = UI_source.new(self.tileInfo)
					self:addModalUI(ui_)
				else
					if g_myID == armyInfo.pid then
					-- 自己占领
						local resourceInfo = hp.gameDataLoader.getInfoBySid("resources", self.tileInfo.objInfo.sid)		
						if resourceInfo.growth == 0 then
							-- 钻石
							require "ui/bigMap/source/mySourceGold"
							ui_ = UI_mySourceGold.new(self.tileInfo)
							self:addModalUI(ui_)
						else
							-- 一般资源
							require "ui/bigMap/source/mySource"
							ui_ = UI_mySource.new(self.tileInfo)
							self:addModalUI(ui_)
						end						
					elseif g_myUnionID==0 or g_myUnionID~=armyInfo.unionID then
					-- 敌方占领
						require "ui/bigMap/source/enemySource"
						ui_ = UI_enemySource.new(self.tileInfo)
						self:addModalUI(ui_)
					else
					-- 友军占领
						require "ui/bigMap/source/unionSource"
						ui_ = UI_unionSource.new(self.tileInfo)
						self:addModalUI(ui_)
					end
				end
				self.sourceUIHelper.openSourceUI(ui_)
			elseif self.touchedInfo.type == 3 then
			-- 军队
				local armyInfo = self.touchedInfo.armyInfo
				if g_myID == armyInfo.pid then
				-- 自己军队
					require "ui/bigMap/camp/myArmyCamp"
					ui_ = UI_myArmyCamp.new(self.tileInfo)
					self:addModalUI(ui_)
				elseif g_myUnionID==0 or g_myUnionID~=armyInfo.unionID then
				-- 敌方军队
					require "ui/bigMap/camp/enemyCamp"
					ui_ = UI_enemyCamp.new(self.tileInfo)
					self:addModalUI(ui_)
				else
				-- 友军军队
					require "ui/bigMap/camp/unionCamp"
					ui_ = UI_unionCamp.new(self.tileInfo)
					self:addModalUI(ui_)
				end
			elseif self.touchedInfo.type == 4 then
			-- Boss
				require "ui/bigMap/boss"
				ui_ = UI_boss.new(self.tileInfo)
				self:addModalUI(ui_)
			elseif self.touchedInfo.type == 10 then
			-- 重镇
				require "ui/bigMap/battle/fortress"
				ui_ = UI_fortress.new(self.tileInfo)
				self:addModalUI(ui_)
			end
		else
		-- 空地
			require("ui/bigMap/common/emptyGround")
			ui_ = UI_emptyGround.new(self.tileInfo)
			self:addModalUI(ui_)
		end

		-- 清除之前点击出现的军队信息
		self:removeArmyByClick()
		if tpos.kx==myPosServerX and tpos.ky==myPosServerY then
		-- 如果点击是本国，获取点击地块数据
			self.conflictManager.httpReqRequestData(self.tileInfo.position.x, self.tileInfo.position.y)
		end
	end
end
-- onTouchCancelled
function kingdomMap:onTouchCancelled(touchs_)
end

-- 坐标转换
--======================================================
-- 屏幕坐标 --> 地图坐标
function kingdomMap:pScreen2Map(p_)
	local p = self.mapScrollView:getContentOffset()
	local sz = self.mapScrollView:getContentSize()
	local scale = self.mapScrollView:getZoomScale()
	return cc.p((p_.x-p.x)/scale, sz.height-(p_.y - p.y)/scale)
end

-- 地图坐标 --> 瓦片坐标
function kingdomMap:pMap2Tile(p_)
	local sz = self.mapScrollView:getContentSize()
end

-- 瓦片坐标 --> 地图坐标
function kingdomMap:pTile2Map(p_)
	--local scale = self.mapScrollView:getZoomScale()
	local mapInfo = self.mapInfo.map
	local x = (p_.x+0.5) * mapInfo.tilew
	local y = (p_.y+1) * mapInfo.tileh/2
	if p_.y%2~=0 then
		x = x+mapInfo.tilew/2
	end

	return cc.p(x, self.ph-y)
end


-- 屏幕坐标 --> 瓦片坐标
function kingdomMap:pScreen2Tile(p_)
	local mapInfo = self.mapInfo.map
	local p = self:pScreen2Map(p_)
	local x = p.x
	local y = p.y

	local y1 = y%mapInfo.tileh
	local y2 = mapInfo.tileh/2
	local ty = 0
	if y1>y2 then
		ty = y1-y2
	else
		ty = y2-y1
	end
	local N=math.floor(x/mapInfo.tilew - ty/mapInfo.tileh)

	local x1 = x%mapInfo.tilew
	local x2 = mapInfo.tilew/2
	local tx = 0
	if y1<y2 then
		if x1<x2 then
			tx = x2-x1
		else
			tx = x1-x2
		end
	else
		if x1<x2 then
			tx = x1
		else
			tx = mapInfo.tilew - x1
		end
	end
	local M=math.floor(y/y2 - tx/x2)

	return cc.p(N, M)
end

-- 瓦片坐标 --> 真实坐标
function kingdomMap:pTile2Real(p_)
	if p_.y%2==0 then
		return cc.p(p_.x*2, p_.y)
	else
		return cc.p(p_.x*2+1, p_.y)
	end
end


-- 真实坐标 --> 瓦片坐标
function kingdomMap:pReal2Tile(p_)
	return cc.p(math.floor(p_.x/2), p_.y)
end

-- 外部使用 added by hthuang
function kingdomMap.pReal2TilePub(p_)
	return cc.p(math.floor(p_.x/2), p_.y)
end

-- public
--======================================================
-- 跳转到一个坐标
-- @p_: 坐标点
-- @kName_: 国家名字
-- @kSid_: 国家sid
function kingdomMap:gotoPosition(p_, kName_, kSid_)
	-- 获取国家坐标
	local kx = myPosServerX
	local ky = myPosServerY
	local kServer = nil

	if kSid_ then
	-- 通过sid获取国家服务器信息
		kServer = player.serverMgr.getServerBySid(kSid_)
	end
	if kName_ and kServer==nil then
	-- 通过名字获取国家服务器信息
		kServer = player.serverMgr.getServerByName(kName_)
	end
	if kServer then
		kx = kServer.x
		ky = kServer.y
	end

	-- 设置具体偏移坐标
	local scale = self.mapScrollView:getZoomScale()
	local mapInfo = self.mapInfo.map
	local p = self:pReal2Tile(p_)
	local x_ = (kx-1)*mapInfo.w+p.x
	local y_ = (ky-1)*mapInfo.h+p.y
	local x = (x_+1) * mapInfo.tilew - mapInfo.tilew/2
	local y = (y_+1) * mapInfo.tileh/2
	if y_%2==1 then
		x = x+mapInfo.tilew/2
	end

	x = x*scale - game.visibleSize.width/2
	y = (self.ph-y)*scale - game.visibleSize.height/2
	self.mapScrollView:setContentOffset(cc.p(-x, -y))
end

function kingdomMap:getCurPosition()
	return self.centerPosition
end

-- getTileType
-- 获取地块属性
-------------------------------------------
function kingdomMap:getTileType(p_)
	local mapInfo = self.mapInfo
	local kr = math.ceil((p_.y+1)/mapInfo.map.h)
	local kl = math.ceil((p_.x+1)/mapInfo.map.w)
	local px = p_.x%mapInfo.map.w
	local py = p_.y%mapInfo.map.h
	local gid = string.byte(self.mapData, py*mapInfo.map.w+px+1)

	cclog_(kr, kl, px, py, gid, mapInfo.tiles[gid])
	return mapInfo.tiles[gid]
end

-- add by huanghaitao test
-- begin
function kingdomMap:objAppearOnMap()
	cclog_("kingdomMap:objAppearOnMap")
	self:requestMapInfo()
end

-- onResponseMapInfo
-- 响应返回地图信息
function kingdomMap:onResponseMapInfo(kx_, ky_, x_, y_, range_, dataInfo_)
	if not self:isValid() then
	-- 地图已经退出
		return
	end

	local mapInfo = self.mapInfo.map
	local xs = (kx_-1)*mapInfo.w
	local ys = (ky_-1)*mapInfo.h

	-- 清除以前的数据
	x_ = math.floor(x_/2)
	for i=x_-range_, x_+range_ do
		if 0<=i and i<mapInfo.w then
			for j=y_-range_, y_+range_ do
				if 0<=j and j<mapInfo.h then
					local strPos = string.format("%d-%d", xs+i, ys+j)
					if self.objs[strPos]~=nil then
						self.objs[strPos] = nil
					end
				end
			end
		end
	end

	-- type 1-城市 2-资源 3-军队 4-boss
	if dataInfo_.city~=nil then
	-- 城市
		for i,v in ipairs(dataInfo_.city) do
			local p = self:pReal2Tile(cc.p(v[3], v[4]))
			local strPos = string.format("%d-%d", xs+p.x, ys+p.y)
			local objTmp = {}
			self.objs[strPos] = objTmp
			objTmp.id = v[1] 
			objTmp.type = 1
			objTmp.name = v[2]
			objTmp.captive = v[5]
			objTmp.unionID = v[6]
			objTmp.unionName = v[7]
			objTmp.power = v[8]
			objTmp.kill = v[9]
			objTmp.image = v[10]
			objTmp.proCD = v[11]	--新手保护
			objTmp.vipCD = v[12]	--vip
			objTmp.conCD = v[13]	--免侦查
			objTmp.level = v[14]	-- 府邸等级
			objTmp.defeated = v[15] + player.getServerTime() -- 冒火时间
			objTmp.title = v[16]
			objTmp.vipLv = v[17]	--VIP等级
			objTmp.serverID = v[18]	--所属服务器的ID
		end
	end
	if dataInfo_.pool~=nil then
	-- 资源点
		for i,v in ipairs(dataInfo_.pool) do
			local p = self:pReal2Tile(cc.p(v[3], v[4]))
			local strPos = string.format("%d-%d", xs+p.x, ys+p.y)
			local objTmp = {}
			self.objs[strPos] = objTmp
			objTmp.type = 2
			objTmp.sid = v[1]
			objTmp.resNum = v[2]
		end
	end
	
	if kx_==myPosServerX and ky_==myPosServerY and dataInfo_.army~=nil then
	-- 军队
		for k, armyInfo in pairs(self.armys) do
			if armyInfo.byClick ~= true then
				self:removeArmy(k)
			else
				armyInfo.needShow = false
			end
		end
		self.armyObjs = {}

		for i, v in ipairs(dataInfo_.army) do
			self:addArmy(v)
		end
	end
	if dataInfo_.boss~=nil then
	-- boss boss1.png
		for i, v in ipairs(dataInfo_.boss) do
			local p = self:pReal2Tile(cc.p(v[3], v[4]))
			local strPos = string.format("%d-%d", xs+p.x, ys+p.y)
			local objTmp = {}
			self.objs[strPos] = objTmp
			objTmp.type = 4
			objTmp.sid = v[1]
			objTmp.life = v[2]
		end
	end

	self:refreshMapViewObjs()
end

-- onResponseMapInfo
-- 向服务器请求地图信息
function kingdomMap:requestMapInfo()
	self.tickCount = 0
	kmapHttpHelper.requireData(self.centerPosition)
end
-- end

--
function kingdomMap:heartbeat(dt)
	self.super.heartbeat(self, dt)

	-- 检查行军部队
	self:checkArmy(dt)

	-- 定时刷新地图信息
	self.tickCount = self.tickCount+dt
	if self.tickCount>=refreshTickCont then
		self.tickCount = 0
		self:requestMapInfo()
	end

	self.conflictManager.heartBeat(dt)
	kmapHttpHelper.heartbeat(dt)
end

-- initArmyView
-- 初始化行军
function kingdomMap:initArmyView()
	local armyLayer = cc.Layer:create()

	self.armyLayer = armyLayer
end

-- initGuideLayer
function kingdomMap:initGuideLayer()
	local guideLayer = cc.Layer:create()
	self.guideLayer = guideLayer
end

-- initFortress()
-- 初始化重镇
function kingdomMap:initFortress()
	local fortressLayer_ = cc.Layer:create()
	-- 重镇
	local city_ = cc.Sprite:create(config.dirUI.fortress.."fortress.png")
	local size_ = city_:getContentSize()
	local p1 = self:pTile2Map(cc.p(127,1024+511))
	local p2 = self:pTile2Map(cc.p(127,1024+509))
	local x_, y_ = p1.x, (p1.y + p2.y) / 2
	-- 光圈
	local shine_ = cc.Sprite:create(config.dirUI.common.."kd_12.png")
	shine_:setAnchorPoint(0.5, 0.5)
	shine_:setPosition(size_.width/2, size_.height/2)
	city_:addChild(shine_)
	-- 头顶标记
	local mark_ = cc.Sprite:create(config.dirUI.common.."kd_13.png")
	mark_:setAnchorPoint(0.5, 0.5)
	mark_:setPosition(size_.width/2, size_.height/2 + 180)
	city_:addChild(mark_)

	local function updateFortressInfo()
		if info_ == nil then
			return
		end
		local info_ = player.fortressMgr.getFortressInfo()
		if info_.open == globalData.OPEN_STATUS.OPEN then
			shine_:setVisible(false)
		else
			shine_:setVisible(true)
		end

		if info_.pid == 0 then
			mark_:setVisible(false)
		else
			mark_:setVisible(true)
		end
	end
	self.updateFortressInfo = updateFortressInfo
	updateFortressInfo()

	city_:setPosition(x_, y_)
	fortressLayer_:addChild(city_)
	self.fortressLayer = fortressLayer_
	self.fortress = city_
end

-- 重置重镇
function kingdomMap:resetFortressPos(kx_, ky_)
	local kInfo = player.serverMgr.getServerByPos(kx_, ky_)
	local mapInfo = self.mapInfo.map
	local tx = (kx_-1/2)*mapInfo.w
	local ty = (ky_-1/2)*mapInfo.h

	local p1 = self:pTile2Map(cc.p(tx-1, ty-1))
	local p2 = self:pTile2Map(cc.p(tx-1, ty-3))
	self.fortress:setTexture(config.dirUI.fortress..kInfo.img)
	self.fortress:setPosition(p1.x, (p1.y + p2.y) / 2)
end

-- 移除军队
function kingdomMap:removeArmy(armyId_)
	local armyInfo = self.armys[armyId_]
	if armyInfo==nil then
	-- 部队不存在
		return
	end

	self.armys[armyId_] = nil

	if armyInfo.type==0 then
	-- 行军
		self.armyLayer:removeChild(armyInfo.ccLayer)
	elseif armyInfo.type==1 then
	-- 驻扎
		local strPos = string.format("%d-%d", armyInfo.pEnd.x, armyInfo.pEnd.y)
		self.armyObjs[strPos]= nil
	elseif armyInfo.type==2 then
	-- 采集
		local strPos = string.format("%d-%d", armyInfo.pEnd.x, armyInfo.pEnd.y)
		self.armyObjs[strPos]= nil
	end
end

-- 移除点击出现的军队
function kingdomMap:removeArmyByClick()
	for k, armyInfo in pairs(self.armys) do
		cclog_("armyInfo.needShow",k,armyInfo.needShow)
		if armyInfo.byClick == true and armyInfo.needShow == false then
			self:removeArmy(k)
		else
			armyInfo.byClick = false
		end
	end
end

-- 添加行军
function kingdomMap:addArmy(armyInfo_, byClick_)
	local mapInfo = self.mapInfo.map
	local xs = (myPosServerX-1)*mapInfo.w
	local ys = (myPosServerY-1)*mapInfo.h

	-- 解析army数据
	local armyInfo = {}
	armyInfo.id = armyInfo_[1]
	armyInfo.pid = armyInfo_[2]
	local p = self:pReal2Tile(cc.p(armyInfo_[3], armyInfo_[4]))
	armyInfo.pStart = cc.p(xs+p.x, ys+p.y)
	p = self:pReal2Tile(cc.p(armyInfo_[5], armyInfo_[6]))
	armyInfo.pEnd = cc.p(xs+p.x, ys+p.y)
	armyInfo.tStart = armyInfo_[7]
	armyInfo.tEnd = armyInfo_[8]
	armyInfo.loaded = armyInfo_[9]
	armyInfo.type = armyInfo_[10]
	armyInfo.name1 = armyInfo_[11]
	armyInfo.name2 = armyInfo_[12]
	armyInfo.unionID = armyInfo_[13]
	armyInfo.unionName = armyInfo_[19]
	armyInfo.power = armyInfo_[20]
	armyInfo.kill = armyInfo_[21]
	armyInfo.image = armyInfo_[22]
	armyInfo.name = armyInfo_[23]
	armyInfo.rank = armyInfo_[24]
	if byClick_ == true then
		armyInfo.byClick = true
		armyInfo.needShow = false
		cclog_("self.armys[armyId_]",self.armys[armyInfo.id],armyInfo.id)
		if self.armys[armyInfo.id] ~= nil then
			armyInfo.needShow = self.armys[armyInfo.id].needShow
		end
	else
		armyInfo.needShow = true
		armyInfo.byClick = false
		if self.armys[armyInfo.id] ~= nil then
			armyInfo.byClick = self.armys[armyInfo.id].byClick
		end
	end

	self:removeArmy(armyInfo.id)
	self.armys[armyInfo.id] = armyInfo

	local nowTime = player.getServerTime()
	local p1 = self:pTile2Map(armyInfo.pStart)
	local p2 = self:pTile2Map(armyInfo.pEnd)

	if armyInfo.type==0 then
	-- 行军
		local ccLayer = cc.Layer:create()
		ccLayer:setLocalZOrder(1)

		-- 连线
		local function createLine(p1, p2, type_)
			local ccLayer = cc.Layer:create()
			local leftPath_ = config.dirUI.common.."foot_left1.png"
			local rightPath_ = config.dirUI.common.."foot_right1.png"
			if type_ == globalData.ARMY_BELONG.ENEMY then
				leftPath_ = config.dirUI.common.."foot_left1.png"
				rightPath_ = config.dirUI.common.."foot_right1.png"
			elseif type_ == globalData.ARMY_BELONG.ME then
				leftPath_ = config.dirUI.common.."foot_left2.png"
				rightPath_ = config.dirUI.common.."foot_right2.png"
			elseif type_ == globalData.ARMY_BELONG.ALLIANCE then
				leftPath_ = config.dirUI.common.."foot_left2.png"
				rightPath_ = config.dirUI.common.."foot_right2.png"
			end

			local interval_ = 50
			local lrInterval_ = {0.2,8}

			local vector_ = {p2.x-p1.x,p2.y-p1.y}
			local distance_ = math.sqrt(math.pow(vector_[1],2)+math.pow(vector_[2],2))
			local num_ = math.floor(distance_ / interval_)
			local delta_ = {}
			delta_.x = (vector_[1])/num_
			delta_.y = (vector_[2])/num_
			-- 旋转角度
			local angle_ = hp.common.rotateAngle(vector_)

			local y_ = {}
			local x_ = {}
			if vector_[1] == 0 then
				y_[1] = p1.y
				x_[1] = p1.x + lrInterval_[2]
				y_[2] = p1.y
				x_[2] = p1.x - lrInterval_[2]
			else
				y_[1] = p1.y + lrInterval_[2]*vector_[1]/distance_
				x_[1] = p1.x - vector_[2]*(y_[1]-p1.y)/vector_[1]
				y_[2] = p1.y - lrInterval_[2]*vector_[1]/distance_
				x_[2] = p1.x - vector_[2]*(y_[2]-p1.y)/vector_[1]
			end

			local leftBegin_ = {x=0,y=0}
			local rightBegin_ = {x=0,y=0}
			if ((x_[1] - p1.x)*vector_[2] - (y_[1] - p1.y)*vector_[1]) > 0 then
				-- 左脚起点
				leftBegin_.x = x_[2] - lrInterval_[1]*delta_.x
				leftBegin_.y = y_[2] - lrInterval_[1]*delta_.y

				-- 右脚起点
				rightBegin_.x = x_[1] + lrInterval_[1]*delta_.x
				rightBegin_.y = y_[1] + lrInterval_[1]*delta_.y
			elseif ((x_[2] - p1.x)*vector_[2] - (y_[2] - p1.y)*vector_[1]) > 0 then
				-- 左脚起点
				leftBegin_.x = x_[1] - lrInterval_[1]*delta_.x
				leftBegin_.y = y_[1] - lrInterval_[1]*delta_.y

				-- 右脚起点
				rightBegin_.x = x_[2] + lrInterval_[1]*delta_.x
				rightBegin_.y = y_[2] + lrInterval_[1]*delta_.y
			else
			end

			local left_ = nil
			local right_ = nil
			for i = 1, num_-1 do
				--left
				left_ = cc.Sprite:create(leftPath_)
				local pos_ = {x=leftBegin_.x+delta_.x*i,y=leftBegin_.y+delta_.y*i}
				left_:setPosition(pos_.x,pos_.y)
				ccLayer:addChild(left_)

				right_ = cc.Sprite:create(rightPath_)
				local pos_ = {x=rightBegin_.x+delta_.x*i,y=rightBegin_.y+delta_.y*i}
				right_:setPosition(pos_.x,pos_.y)
				ccLayer:addChild(right_)

				-- 旋转
				left_:setRotation(angle_)
				right_:setRotation(angle_)
			end
			return ccLayer
		end
		local type_ = 1
		if armyInfo.unionID==0 then
			if g_myName==armyInfo.name then
				type_ = globalData.ARMY_BELONG.ME
			else
				type_ = globalData.ARMY_BELONG.ENEMY
			end
		else
			if g_myUnionID==armyInfo.unionID then
				type_ = globalData.ARMY_BELONG.ALLIANCE
			else
				type_ = globalData.ARMY_BELONG.ENEMY
			end
		end
		local feet_ = createLine(p1,p2,type_)
		ccLayer:addChild(feet_)

		-- local armyLine = cc.DrawNode:create()
		-- armyLine:drawSegment(p1, p2, 2, cc.c4f(1, 0, 1, 1))
		-- ccLayer:addChild(armyLine)

		local ratioTime = (nowTime-armyInfo.tStart)/(armyInfo.tEnd-armyInfo.tStart)
		if ratioTime<0 then
			ratioTime = 0
		end
		local pNow = {}
		pNow.x = p1.x + (p2.x-p1.x)*ratioTime
		pNow.y = p1.y + (p2.y-p1.y)*ratioTime

		-- 行军动画
		spriteArmy = hp.sequenceAniHelper.createAnimSprite("bigMap", "march", 6, 0.2)
		spriteArmy:setAnchorPoint(0.5, 0.2)
		spriteArmy:setPosition(pNow)
		spriteArmy:runAction(cc.MoveTo:create(armyInfo.tEnd-nowTime, p2))

		if pNow.x>p2.x then
			spriteArmy:setScaleX(-1)
		end

		ccLayer:addChild(spriteArmy)
		self.armyLayer:addChild(ccLayer)
		armyInfo.ccLayer = ccLayer
	elseif armyInfo.type==1 then
	-- 驻扎		
		local strPos = string.format("%d-%d", armyInfo.pEnd.x, armyInfo.pEnd.y)
		local objTmp = {}
		self.armyObjs[strPos] = objTmp
		objTmp.type = 3
		objTmp.armyNode = spriteArmy
		objTmp.armyInfo = armyInfo
	elseif armyInfo.type==2 then
	-- 采集
		local strPos = string.format("%d-%d", armyInfo.pEnd.x, armyInfo.pEnd.y)
		local objTmp = {}
		self.armyObjs[strPos] = objTmp
		objTmp.type = 3
		objTmp.armyInfo = armyInfo
	end
end

-- 检查行军
function kingdomMap:checkArmy(dt)
	if self.armyRefreashOk==false then
	-- 上次部队刷新还没完成
		return
	end

	local changedArmys = {}
	local function onHttpResponse(status, response, tag)
		if not self:isValid() then
		-- 地图已经退出
			return
		end
		self.armyRefreashOk = true

		if status~=200 then
			return
		end
		local resInfo = hp.httpParse(response)
		if resInfo.result~=0 then
			return
		end

		for i,v in ipairs(changedArmys) do
		-- 移除之前部队状态
			self:removeArmy(v)
		end

		if resInfo.army~=nil then
		-- 军队
			for i, v in ipairs(resInfo.army) do
				self:addArmy(v)
			end
		end

		self:refreshMapViewObjs()
	end

	local nowTime = player.getServerTime()
	for k, armyInfo in pairs(self.armys) do
		if armyInfo.type==0 or armyInfo.type==2 then
		-- 行军、采集
			if nowTime>armyInfo.tEnd then
				-- 部队已到达
				table.insert(changedArmys, k)
			end
		end
	end

	if #changedArmys>0 then
		self.armyRefreashOk = false
		local cmdData={}
		cmdData.type = 2
		cmdData.id = changedArmys
		local cmdSender = hp.httpCmdSender.new(onHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld, nil, nil, myPosServerInfo.url)
	end
end

function kingdomMap:onMsg(msg_, param_)
	self.super.onMsg(self, msg_, param_)
	
	if msg_ == hp.MSG.MAP_ARMY_ATTACK then
		self:addArmy(param_.army, param_.byClick)
		self:refreshMapViewObjs()
	elseif msg_==hp.MSG.UNION_JOIN_SUCCESS or (msg_==hp.MSG.UNION_NOTIFY and param_.msgType==2 ) then
		getMyInfo()
		self:requestMapInfo()
	elseif msg_ == hp.MSG.KING_BATTLE then
		if param_.msgType ~= 2 then
			self.updateFortressInfo()
		end
	elseif msg_ == hp.MSG.CITY_POS_CHANGED then
		myServerInfo = player.serverMgr.getMyServer()
		myPosServerInfo = player.serverMgr.getMyPosServer()
		myPosServerY = myPosServerInfo.y
		myPosServerX = myPosServerInfo.x
		self:posMapView(self.viewTileX, self.viewTileY, true)
	elseif msg_ == hp.MSG.KINGDOM_ACTIVITY then
		-- 获取跨服活动的服务器信息
		local activity = player.kingdomActivityMgr.getActivity()
		if activity and activity.status == UNION_ACTIVITY_STATUS.OPEN then
			activityServerInfo = player.serverMgr.getServerBySid(activity.serverID)
		else
			activityServerInfo = nil
		end
		self:posMapView(self.viewTileX, self.viewTileY, true)
	end
end

function kingdomMap:preExit()
	self.sourceUIHelper.exit()
	self.conflictManager.exit()
	self.super.preExit(self)
end


--
-- 导航箭头
-- showGuidePoint
function kingdomMap:showGuidePoint(p_, kName_, kSid_)
	local guidePoint = self.guidePoint
	if guidePoint==nil then
		guidePoint = cc.Sprite:create(config.dirUI.common .. "guide_point.png")
		self.guideLayer:addChild(guidePoint)
		self.guidePoint = guidePoint

		guidePoint:setScaleY(-1)
		guidePoint:setAnchorPoint(0.5, 1)
			-- 跳跃动画
		local aJump = cc.JumpBy:create(0.8, cc.p(0, 0), 50, 1)
		local jumpRep = cc.RepeatForever:create(aJump)
		guidePoint:runAction(jumpRep)

	end

	-- 获取国家坐标
	local kx = myPosServerX
	local ky = myPosServerY
	local kServer = nil

	if kSid_ then
	-- 通过sid获取国家服务器信息
		kServer = player.serverMgr.getServerBySid(kSid_)
	end
	if kName_ and kServer==nil then
	-- 通过名字获取国家服务器信息
		kServer = player.serverMgr.getServerByName(kName_)
	end
	if kServer then
		kx = kServer.x
		ky = kServer.y
	end
	
	-- 设置具体偏移坐标
	local mapInfo = self.mapInfo.map
	local p = self:pReal2Tile(p_)
	local x_ = (kx-1)*mapInfo.w+p.x
	local y_ = (ky-1)*mapInfo.h+p.y
	local p = self:pTile2Map(cc.p(x_, y_))
	guidePoint:setPosition(p)
end

--
-- removeGuidePoint
function kingdomMap:removeGuidePoint()
	if self.guidePoint~=nil then
		self.guideLayer:removeChild(self.guidePoint)
		self.guidePoint = nil
	end
end
