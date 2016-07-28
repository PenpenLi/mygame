--
-- scene/kingdomMap.lua
-- 王国地图
--================================================
require "scene/Scene"


kingdomMap = class("kingdomMap", Scene)


local mykr = 2
local mykl = 2

local g_resTextColor = cc.c4b(255, 216, 0, 255)
local g_allyTextColor = cc.c4b(107, 229, 225, 255)
local g_enemyTextColor = cc.c4b(255, 83, 83, 255)
local g_myUnionName = ""
local g_myName = ""

local function getMyInfo()
	local alliance = player.getAlliance()
	if alliance:getUnionID()==0 then
		g_myUnionName = ""
	else
		g_myUnionName = alliance:getBaseInfo().name	--发送者公会
	end
	g_myName = player.getName()
end

--
--=========================================================
-- init
function kingdomMap:init()
	self.mapLevel = 2 --2级地图

	getMyInfo()
	--data
	--============================
	self.mapRefreshFlag = false
	self.mapRefreshOk = true
	self.centerPosition = {kx=1, ky=1, x=0, y=0}
	self.tickCount = 10
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
		self.labelMapInfo = cc.Label:createWithTTF("", "font/main.ttf", 28)
		self.labelMapInfo:setPosition(game.visibleSize.width/2, 200)
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
		self.labelMapInfo:setString(string.format("k:%d-%d x:%d y:%d", kdCoor.kx, kdCoor.ky, kdCoor.x, kdCoor.y))
		self.centerPosition = {kx=kdCoor.kx, ky=kdCoor.ky, x=kdCoor.x, y=kdCoor.y}
	end
	self.mapScrollView:setContentSize(cc.size(self.pw, self.ph))
	self.mapScrollView:setBounceable(false)
	--self.mapScrollView:setMaxScale(2)
	--self.mapScrollView:setMinScale(1)
	self.mapScrollView:setZoomScale(1.2)
	self.mapScrollView:setDelegate()
	self.mapScrollView:registerScriptHandler(onScrolled, 0)
	self.bgLayer:addChild(self.viewLayer)
	self.bgLayer:addChild(self.armyLayer)

	self:gotoPosition(0, player.getPosition())

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
	require "ui/bigMap/topMenu" 
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
	local mainMenu = UI_mainMenu.new()
	mainMenu:onAdd(self)
	self.menuLayer:addChild(mainMenu.layer)
	table.insert(self.uis, mainMenu)
	mainMenu.setMapIconState()
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
	ui_:onAdd(self)
	self.uiLayer:addChild(ui_.layer)
	table.insert(self.uis, ui_)
	table.insert(self.UIs, ui_)
	self.mainMenu.setMapIconState()
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
	self.mainMenu.setMapIconState()
end

-- removeUI
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
	self.mainMenu.setMapIconState()
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
	local mapInfo = require(config.dirUI.map .. "kingdomMapInfo")
	local mapData = cc.FileUtils:getInstance():getStringFromFile(config.dirUI.map .. "data.client")
	local maps = {
					{mapData, mapData, mapData},
					{mapData, mapData, mapData},
					{mapData, mapData, mapData},
				}
	self.mapInfo = mapInfo
	self.maps = maps
	
	-- 地图的总宽高(瓦片)
	self.w = mapInfo.map.w * table.getn(maps[1])
	self.h = mapInfo.map.h * table.getn(maps)
	-- 一个王国地图的宽高(像素)
	self.kpw = mapInfo.map.w * mapInfo.map.tilew
	self.kph = mapInfo.map.h * mapInfo.map.tileh / 2
	-- 地图的总宽高(像素)
	self.pw = self.kpw * table.getn(maps[1]) + mapInfo.map.tilew/2
	self.ph = self.kph * table.getn(maps) + mapInfo.map.tileh/2
	
	-- 瓦片纹理、纹理矩形
	local tileTextures = {}
	local tileTexturesRect = {}
	for i, v in ipairs(mapInfo.imgs) do
		local texture2D = cc.Director:getInstance():getTextureCache():addImage(config.dirUI.map .. v.path)
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

	local viewW = math.ceil(game.visibleSize.width*2/(tilew*2))
	local viewH = math.ceil(game.visibleSize.height*2/(tileh))
	self.viewW = viewW
	self.viewH = viewH
	local w = viewW*3
	local h = viewH*3

	local psx = -tilew*(viewW+1)
	local psy = tileh*(viewH-1/2)

	-- 创建精灵
	local viewLayer = cc.Layer:create()
	local viewGroundLayer = cc.Layer:create()
	local viewObjLayer = cc.Layer:create()
	local viewDescLayer = cc.Layer:create()
	viewLayer:addChild(viewGroundLayer)
	viewLayer:addChild(viewObjLayer)
	viewLayer:addChild(viewDescLayer)

	local viewSprites = {}
	local groundNode = nil
	local objNode = nil
	local descBgNode = nil
	local descNode = nil
	local xTmp = 1
	local yTmp = 1

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
			descNode:setPosition(84, 12)
			if i%2==1 then
				xTmp = psx+tilew*j+px
				yTmp = psy-tileh/2*i-py-tileh/4
				groundNode:setPosition(xTmp, yTmp)
				objNode:setPosition(xTmp+xoffset, yTmp+yOffset)
				descBgNode:setPosition(xTmp+xoffset, yTmp+yOffset-tileh/2)
			else
				xTmp = psx+tilew*j+tilew/2+px
				yTmp = psy-tileh/2*i-py-tileh/4
				groundNode:setPosition(xTmp, yTmp)
				objNode:setPosition(xTmp+xoffset, yTmp+yOffset)
				descBgNode:setPosition(xTmp+xoffset, yTmp+yOffset-tileh/2)
			end

			viewGroundLayer:addChild(groundNode)
			viewObjLayer:addChild(objNode)
			viewDescLayer:addChild(descBgNode)
			descBgNode:addChild(descNode)

			viewSprites[i][j] = {
				groundNode = groundNode,
				objNode = objNode,
				descBgNode = descBgNode,
				descNode = descNode,
				}
		end
	end

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
		resInfos[v.sid] = resInfo
	end

	local homeImgPath = config.dirUI.map .. "home_icon.png"
	local homeTexture2D = cc.Director:getInstance():getTextureCache():addImage(homeImgPath)

	-- boss info
	local bossInfos = {}
	for i, v in ipairs(game.data.boss) do
		local bossInfo_ = {}
		local bossImagePath = config.dirUI.common.."boss1.png"
		bossInfo_.texture2D = cc.Director:getInstance():getTextureCache():addImage(bossImagePath)
		bossInfo_.info = v
		bossInfos[v.sid] = bossInfo_
	end

	self.resInfos = resInfos
	self.homeTexture2D = homeTexture2D
	self.bossInfos = bossInfos
end


-- posMapView
function kingdomMap:posMapView(tileX, tileY, mustFlag_)
	if tileY%2~=0 then
		tileY = tileY-1
	end

	local viewW = self.viewW
	local viewH = self.viewH

	if mustFlag_==nil and self.viewTileX~=nil and self.viewTileY~=nil then
		local x_ = self.viewTileX-tileX
		local y_ = self.viewTileY-tileY
		if -viewW<x_ and x_<viewW and -viewH<y_ and y_<viewH then
			return
		end
	end
	
	if mustFlag_==nil then
		self.mapRefreshFlag = true
	end


	self.viewTileX = tileX
	self.viewTileY = tileY

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
	local maps = self.maps
	local kmap = nil
	local gid = 1

	local sp = nil
	local strPos = nil
	local objTmp = nil
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
				viewSprites[i][j].groundNode:setVisible(false)
				j = j+1
			end
		else
			kr = math.ceil(y/kh)
			r = y - (kr-1)*kh
			for x=x1, x2 do
				if x<1 or x>w then
					viewSprites[i][j].groundNode:setVisible(false)
				else
					sp = viewSprites[i][j]
					kl = math.ceil(x/kw)
					l = x - (kl-1)*kw
					kmap = maps[kr][kl]
					gid = string.byte(kmap, (r-1)*kw+l)
					sp.groundNode:setVisible(true)
					sp.groundNode:setTexture(tileTextures[gid])
					sp.groundNode:setTextureRect(tileTexturesRect[gid])

					strPos = string.format("%d-%d", x-1, y-1)
					objTmp = self.objs[strPos]

					sp.objNode:removeAllChildren()
					if objTmp~=nil then
						if objTmp.type==1 then
							local x = 1
							sp.objNode:setVisible(true)
							sp.objNode:setTexture(self.homeTexture2D)
							sp.objNode:setTextureRect(self.homeTexture2D:getContentSize())
							sp.descBgNode:setVisible(true)
							local str = objTmp.name
							if objTmp.unionName ~= "" then
								str = "["..objTmp.unionName.."]"..objTmp.name
							end
							sp.descNode:setString(str)
							if g_myUnionName=="" then
								if g_myName==objTmp.name then
									sp.descNode:setTextColor(g_allyTextColor)
								else
									sp.descNode:setTextColor(g_enemyTextColor)
								end
							else
								if g_myUnionName==objTmp.unionName then
									sp.descNode:setTextColor(g_allyTextColor)
								else
									sp.descNode:setTextColor(g_enemyTextColor)
								end
							end
							if objTmp.proCD>0 then
							--新手保护中。。
								local ani = hp.sequenceAniHelper.createAnimation1(31001, 14, 0.1)
								ani:setPosition(116, 80)
								sp.objNode:addChild(ani)
							end
						elseif objTmp.type==2 then
							local resInfo = self.resInfos[objTmp.sid]
							sp.objNode:setVisible(true)
							sp.objNode:setTexture(resInfo.texture2D)
							sp.objNode:setTextureRect(resInfo.texture2D:getContentSize())
							sp.descBgNode:setVisible(true)
							sp.descNode:setString(resInfo.info.name)
							sp.descNode:setTextColor(g_resTextColor)
						elseif objTmp.type==4 then
							-- self.bossTexture2D
							local bossInfo_ = self.bossInfos[objTmp.sid]
							sp.objNode:setVisible(true)
							-- sp.objNode:setTexture(bossInfo_.texture2D)
							-- sp.objNode:setTextureRect(bossInfo_.texture2D:getContentSize())
							sp.objNode:setTextureRect(cc.size(0, 0))
							local aniNode = hp.sequenceAniHelper.createAnimation(bossInfo_.info.animation)
							sp.objNode:addChild(aniNode)
							sp.descBgNode:setVisible(true)
							sp.descNode:setString(bossInfo_.info.name)
							sp.descNode:setTextColor(g_enemyTextColor)
						end
					else
						sp.objNode:setVisible(false)
						sp.descBgNode:setVisible(false)
					end
				end
				j = j+1
			end
		end
		i = i+1
	end


	-- 获取边界焦点
	kl = math.ceil(x2/kw)
	l = (kl-1)*kw-tileX
	kr = math.ceil(y2/kh)
	r = tileY - (kr-1)*kh
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

	self.viewMask1:setVisible(true)
	self.viewMask2:setVisible(true)
	self.viewMask3:setVisible(true)
	self.viewMask4:setVisible(true)
	if kr1==mykr and kl1==mykl then
		self.viewMask1:setVisible(false)
	elseif kr2==mykr and kl2==mykl then
		self.viewMask2:setVisible(false)
	elseif kr3==mykr and kl3==mykl then
		self.viewMask3:setVisible(false)
	elseif kr==mykr and kl==mykl then
		self.viewMask4:setVisible(false)
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
function kingdomMap:refreshMapViewObjs(tileX, tileY)
	if tileY%2~=0 then
		tileY = tileY-1
	end

	local viewW = self.viewW
	local viewH = self.viewH

	self.viewTileX = tileX
	self.viewTileY = tileY

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
	local maps = self.maps
	local kmap = nil
	local gid = 1

	local sp = nil
	local strPos = nil
	local objTmp = nil
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
				--viewSprites[i][j].groundNode:setVisible(false)
				j = j+1
			end
		else
			kr = math.ceil(y/kh)
			r = y - (kr-1)*kh
			for x=x1, x2 do
				if x<1 or x>w then
					--viewSprites[i][j].groundNode:setVisible(false)
				else
					sp = viewSprites[i][j]
					-- kl = math.ceil(x/kw)
					-- l = x - (kl-1)*kw
					-- kmap = maps[kr][kl]
					-- gid = string.byte(kmap, (r-1)*kw+l)
					-- sp.groundNode:setVisible(true)
					-- sp.groundNode:setTexture(tileTextures[gid])
					-- sp.groundNode:setTextureRect(tileTexturesRect[gid])

					strPos = string.format("%d-%d", x-1, y-1)
					objTmp = self.objs[strPos]
					sp.objNode:removeAllChildren()
					if objTmp~=nil then
						if objTmp.type==1 then
							local x = 1
							sp.objNode:setVisible(true)
							sp.objNode:setTexture(self.homeTexture2D)
							sp.objNode:setTextureRect(self.homeTexture2D:getContentSize())
							sp.descBgNode:setVisible(true)
							local str = objTmp.name
							if objTmp.unionName ~= "" then
								str = "["..objTmp.unionName.."]"..objTmp.name
							end
							sp.descNode:setString(str)
							if g_myUnionName=="" then
								if g_myName==objTmp.name then
									sp.descNode:setTextColor(g_allyTextColor)
								else
									sp.descNode:setTextColor(g_enemyTextColor)
								end
							else
								if g_myUnionName==objTmp.unionName then
									sp.descNode:setTextColor(g_allyTextColor)
								else
									sp.descNode:setTextColor(g_enemyTextColor)
								end
							end
							if objTmp.proCD>0 then
							--新手保护中。。
								local ani = hp.sequenceAniHelper.createAnimation1(31001, 14, 0.1)
								ani:setPosition(116, 80)
								sp.objNode:addChild(ani)
							end
						elseif objTmp.type==2 then
							local resInfo = self.resInfos[objTmp.sid]
							sp.objNode:setVisible(true)
							sp.objNode:setTexture(resInfo.texture2D)
							sp.objNode:setTextureRect(resInfo.texture2D:getContentSize())
							sp.descBgNode:setVisible(true)
							sp.descNode:setString(resInfo.info.name)
							sp.descNode:setTextColor(g_resTextColor)
						elseif objTmp.type==4 then
							-- self.bossTexture2D
							local bossInfo_ = self.bossInfos[objTmp.sid]
							sp.objNode:setVisible(true)
							-- sp.objNode:setTexture(bossInfo_.texture2D)
							-- sp.objNode:setTextureRect(bossInfo_.texture2D:getContentSize())
							sp.objNode:setTextureRect(cc.size(0, 0))
							local aniNode = hp.sequenceAniHelper.createAnimation(bossInfo_.info.animation)
							sp.objNode:addChild(aniNode)
							sp.descBgNode:setVisible(true)
							sp.descNode:setString(bossInfo_.info.name)
							sp.descNode:setTextColor(g_enemyTextColor)
						end
					else
						-- changed by huanghaitao
						-- begin
						sp.objNode:setVisible(false)
						sp.descBgNode:setVisible(false)
						-- end
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
			if self.touchedInfo ~= nil then
				if self.touchedInfo.type==3 then
				--军队
					self.spriteTouched = self.touchedInfo.armyNode
				else
					self.spriteTouched = self.viewSprites[i][j].objNode
				end
			else
				self.spriteTouched = self.viewSprites[i][j].groundNode
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
		if self.touchedInfo ~= nil then
			if self.touchedInfo.type == 1 then
				-- 自己城市
				if player.getID() == self.touchedInfo.id then
					require "ui/bigMap/myCity"
					ui_ = UI_myCity.new(self.tileInfo)
					self:addModalUI(ui_)
				elseif player.getAlliance():getUnionID() == 0 then
					require "ui/bigMap/enemyCity"
					ui_ = UI_enemyCity.new(self.tileInfo)
					self:addModalUI(ui_)
				elseif player.getAlliance():getUnionID() == self.touchedInfo.unionID then
					require "ui/bigMap/unionCity"
					ui_ = UI_unionCity.new(self.tileInfo)
					self:addModalUI(ui_)					
				else
					require "ui/bigMap/enemyCity"
					ui_ = UI_enemyCity.new(self.tileInfo)
					self:addModalUI(ui_)
				end
			elseif self.touchedInfo.type == 2 then
				-- 资源
				if self.touchedInfo.armyInfo == nil then
					require "ui/bigMap/UISource"
					local ui_ = UI_source.new(self.tileInfo)
					self:addModalUI(ui_)
				else
					print("==========================", self.touchedInfo.armyInfo.pid, player.getID())
					if self.touchedInfo.armyInfo.pid == player.getID() then
						require "ui/bigMap/UISource"
						local ui_ = UI_source.new(self.tileInfo)
						self:addModalUI(ui_)
					else
						if player.getAlliance():getUnionID() == 0 then
							require "ui/bigMap/enemySource"
							local ui_ = UI_enemySource.new(self.tileInfo)
							self:addModalUI(ui_)
						elseif player.getAlliance():getUnionID() == self.touchedInfo.armyInfo.unionID then
							require "ui/bigMap/unionSource"
							local ui_ = UI_unionSource.new(self.tileInfo)
							self:addModalUI(ui_)
						else
							require "ui/bigMap/enemySource"
							local ui_ = UI_enemySource.new(self.tileInfo)
							self:addModalUI(ui_)
						end
					end
				end
			elseif self.touchedInfo.type == 3 then
				-- 军队				
				-- 自己部队
				if self.touchedInfo.armyInfo.pid == player.getID() then
					require "ui/bigMap/myArmyCamp"
					local ui_ = UI_myArmyCamp.new(self.tileInfo)
					self:addModalUI(ui_)
				else
					if player.getAlliance():getUnionID() == 0 then
						require "ui/bigMap/enemyCamp"
						local ui_ = UI_enemyCamp.new(self.tileInfo)
						self:addModalUI(ui_)
					elseif player.getAlliance():getUnionID() == self.touchedInfo.armyInfo.unionID then
						require "ui/bigMap/unionCamp"
						local ui_ = UI_unionCamp.new(self.tileInfo)
						self:addModalUI(ui_)					
					else
					-- 敌人部队
						require "ui/bigMap/enemyCamp"
						local ui_ = UI_enemyCamp.new(self.tileInfo)
						self:addModalUI(ui_)
					end
				end
			elseif self.touchedInfo.type == 4 then
				require "ui/bigMap/boss"
				local ui_ = UI_boss.new(self.tileInfo)
				self:addModalUI(ui_)
			end
		else
			require("ui/bigMap/emptyGround")
			ui = UI_emptyGround.new(self.tileInfo)
			self:addModalUI(ui)
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
	local y = (p_.y+0.5) * mapInfo.tileh/2
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
function kingdomMap:gotoPosition(kingdom_, p_)
	local scale = self.mapScrollView:getZoomScale()
	local mapInfo = self.mapInfo.map
	local p = self:pReal2Tile(p_)
	local x_ = (mykl-1)*mapInfo.w+p.x
	local y_ = (mykr-1)*mapInfo.h+p.y
	local x = (x_+1) * mapInfo.tilew - mapInfo.tilew/2
	local y = (y_+1) * mapInfo.tileh/2
	if y_%2==1 then
		x = x+mapInfo.tilew/2
	end

	x = x*scale - game.visibleSize.width/2
	y = (self.ph-y)*scale - game.visibleSize.height/2

	self.mapScrollView:setContentOffset(cc.p(-x, -y))
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
	local kmap = self.maps[kr][kl]
	local gid = string.byte(kmap, py*mapInfo.map.w+px+1)

	print(kr, kl, px, py, gid, mapInfo.tiles[gid])
	return mapInfo.tiles[gid]
end

-- add by huanghaitao test
-- begin
function kingdomMap:objAppearOnMap()
	print("kingdomMap:objAppearOnMap")
	self:requestMapInfo()
end

function kingdomMap:requestMapInfo()
	-- 刷新地图
	local cmdData={}
	cmdData.type = 1
	cmdData.x = self.centerPosition.x
	cmdData.y = self.centerPosition.y
	cmdData.range = self.viewH


	local function onHttpResponse(status, response, tag)
		if not self:isValid() then
		-- 地图已经退出
			return
		end

		self.mapRefreshOk = true
		self.tickCount = 0

		if status~=200 then
			return
		end

		local resInfo = hp.httpParse(response)
		if resInfo.result~=0 then
			return
		end

		local mapInfo = self.mapInfo.map
		local xs = (mykl-1)*mapInfo.w
		local ys = (mykr-1)*mapInfo.h

		-- 清除以前的数据
		local p = self:pReal2Tile(cc.p(cmdData.x, cmdData.y))
		local pOriginX=xs+p.x
		local pOriginY=ys+p.y
		for i=pOriginX-cmdData.range, pOriginX+cmdData.range do
			for j=pOriginY-cmdData.range, pOriginY+cmdData.range do
				local strPos = string.format("%d-%d", i, j)
				if self.objs[strPos]~=nil then
					self.objs[strPos] = nil
				end
			end
		end

		-- type 1-城市 2-资源 3-军队 4-boss
		if resInfo.city~=nil then
		-- 城市
			for i,v in ipairs(resInfo.city) do
				local p = self:pReal2Tile(cc.p(v[3], v[4]))
				local strPos = string.format("%d-%d", xs+p.x, ys+p.y)
				local objTmp = {}
				self.objs[strPos] = objTmp
				objTmp.id = v[1] 
				objTmp.type = 1
				objTmp.name = v[2]
				objTmp.unionID = v[6]
				objTmp.unionName = v[7]
				objTmp.power = v[8]
				objTmp.kill = v[9]
				objTmp.image = v[10]
				objTmp.proCD = v[11]	--新手保护
				objTmp.vipCD = v[12]	--vip
				objTmp.conCD = v[13]	--免侦查
			end
		end
		if resInfo.pool~=nil then
		-- 资源点
			for i,v in ipairs(resInfo.pool) do
				local p = self:pReal2Tile(cc.p(v[3], v[4]))
				local strPos = string.format("%d-%d", xs+p.x, ys+p.y)
				local objTmp = {}
				self.objs[strPos] = objTmp
				objTmp.type = 2
				objTmp.sid = v[1]
				objTmp.resNum = v[2]
			end
		end
		if resInfo.army~=nil then
		-- 军队
			self.armyObjs = {}
			for i, armyInfo in ipairs(self.armys) do
				self.armyLayer:removeChild(armyInfo.ccLayer)
				self.armys = {}
			end
			
			for i, v in ipairs(resInfo.army) do
				self:addArmy(v)
			end
		end
		if resInfo.boss~=nil then
		-- boss boss1.png
			for i, v in ipairs(resInfo.boss) do
				local p = self:pReal2Tile(cc.p(v[3], v[4]))
				local strPos = string.format("%d-%d", xs+p.x, ys+p.y)
				local objTmp = {}
				self.objs[strPos] = objTmp
				objTmp.type = 4
				objTmp.sid = v[1]
				objTmp.life = v[2]
			end
		end

		self:refreshMapViewObjs(self.viewTileX, self.viewTileY)
	end

	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld)
end
-- end

--
function kingdomMap:heartbeat(dt)

	self.super.heartbeat(self, dt)
	if self.tickCount<1 then
		self.tickCount = self.tickCount+dt
		return
	end

	-- 检查行军部队
	self:checkArmy(dt)

	self.tickCount = self.tickCount+dt
	if self.tickCount>12 or self.mapRefreshFlag then
		self.mapRefreshFlag = true
		self.tickCount = 0
	end

	if self.mapRefreshFlag and self.mapRefreshOk then
		self.mapRefreshFlag = false
		self.mapRefreshOk = false
		self:requestMapInfo()
	end
end

-- initArmyView
-- 初始化行军
function kingdomMap:initArmyView()
	local armyLayer = cc.Layer:create()
	local armyTexture = cc.Director:getInstance():getTextureCache():addImage(config.dirUI.map .. "army.png")
	local armyRext = {}

	for i=0, 2 do
		for j=0, 3 do
			table.insert(armyRext, cc.rect(j*69, i*69, 69, 69))
		end
	end

	self.armyLayer = armyLayer
	self.armyTexture = armyTexture
	self.armyRext = armyRext
end


-- 添加行军
function kingdomMap:addArmy(armyInfo_)
	local armyInfo = self.armys[armyInfo_[1]]
	if armyInfo~=nil then
		-- 部队已存在
		self.armys[armyInfo_[1]] = nil
		self.armyLayer:removeChild(armyInfo.ccLayer)
		if armyInfo.pStart.x==armyInfo.pEnd.x and armyInfo.pStart.y==armyInfo.pEnd.y then
			-- 部队为驻扎部队
			local strPos = string.format("%d-%d", armyInfo.pEnd.x, armyInfo.pEnd.y)
			if self.armyObjs[strPos]~=nil then
				self.armyObjs[strPos]= nil
			end
		end
	end

	local mapInfo = self.mapInfo.map
	local xs = (mykl-1)*mapInfo.w
	local ys = (mykr-1)*mapInfo.h

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
	self.armys[armyInfo.id] = armyInfo

	local ccLayer = cc.Layer:create()
	armyInfo.ccLayer = ccLayer

	local spriteArmy = nil
	local nowTime = player.getServerTime()
	local p1 = self:pTile2Map(armyInfo.pStart)
	local p2 = self:pTile2Map(armyInfo.pEnd)

	--if armyInfo.tEnd==armyInfo.tStart or nowTime>armyInfo.tEnd then
	if armyInfo.pStart.x==armyInfo.pEnd.x and armyInfo.pStart.y==armyInfo.pEnd.y then
		-- 部队为驻扎部队
		spriteArmy = hp.sequenceAniHelper.createAnimation(21001)--cc.Sprite:createWithSpriteFrame(cc.SpriteFrame:createWithTexture(self.armyTexture, self.armyRext[1]))
		spriteArmy:setPosition(p2)
		local strPos = string.format("%d-%d", armyInfo.pEnd.x, armyInfo.pEnd.y)
		self.armyObjs[strPos] = {}
		self.armyObjs[strPos].type = 3
		self.armyObjs[strPos].armyNode = spriteArmy
		self.armyObjs[strPos].armyInfo = armyInfo
	else
		--行军路线
		local armyLine = cc.DrawNode:create()
		armyLine:drawSegment(p1, p2, 2, cc.c4f(1, 0, 1, 1))
		ccLayer:addChild(armyLine)
		local ratioTime = (nowTime-armyInfo.tStart)/(armyInfo.tEnd-armyInfo.tStart)
		if ratioTime<0 then
			ratioTime = 0
		end
		local pNow = {}
		pNow.x = p1.x + (p2.x-p1.x)*ratioTime
		pNow.y = p1.y + (p2.y-p1.y)*ratioTime

		-- 行军动画
		spriteArmy = hp.sequenceAniHelper.createAnimation(21002)
		spriteArmy:setPosition(pNow)
		spriteArmy:runAction(cc.MoveTo:create(armyInfo.tEnd-nowTime, p2))

		if pNow.x>p2.x then
			spriteArmy:setScaleX(-1)
		end
	end

	ccLayer:addChild(spriteArmy)
	self.armyLayer:addChild(ccLayer)
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
			if self.armys[v]~=nil then
				local armyInfo = self.armys[v]
				self.armys[v] = nil
				self.armyLayer:removeChild(armyInfo.ccLayer)
				if armyInfo.pStart.x==armyInfo.pEnd.x and armyInfo.pStart.y==armyInfo.pEnd.y then
					-- 部队为驻扎部队
					local strPos = string.format("%d-%d", armyInfo.pEnd.x, armyInfo.pEnd.y)
					if self.armyObjs[strPos]~=nil then
						self.armyObjs[strPos]= nil
					end
				end
			end
		end

		if resInfo.army~=nil then
		-- 军队
			for i, v in ipairs(resInfo.army) do
				self:addArmy(v)
			end
		end
	end

	local nowTime = player.getServerTime()
	for k, armyInfo in pairs(self.armys) do
		if armyInfo.pStart.x~=armyInfo.pEnd.x or armyInfo.pStart.y~=armyInfo.pEnd.y then
		-- 非驻扎部队
			if nowTime>armyInfo.tEnd then
				-- 部队已到达
				table.insert(changedArmys, k)
			end
		end
	end

	if #changedArmys>0 then
		local cmdData={}
		cmdData.type = 2
		cmdData.id = changedArmys
		local cmdSender = hp.httpCmdSender.new(onHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld)
	end
end

function kingdomMap:onMsg(msg_, param_)
	if msg_ == hp.MSG.MAP_ARMY_ATTACK then
		self:addArmy(param_)
	end
end