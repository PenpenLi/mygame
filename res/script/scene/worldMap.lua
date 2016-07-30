--
-- scene/worldMap.lua
-- 世界地图
--================================================
require "scene/Scene"

worldMap = class("worldMap", Scene)

local OBJ_SCALE = {
	[0] = 0.5,
	[1] = 0.8,
}

local NAME_SIZE = 24

local DESC_SIZE = 22

local DESC_SERVER_STATE = 26

local OBJECT_TYPE = {
	SERVER = 0,
	CAPITAL = 1,
}

-- 对象Tag
local OBJECT_TAG = {
	LIGHT = 1,
}

-- 地图信息
local AXIS_X = 5
local AXIS_Y = 2
local PIC_HEIGHT = 1024
local PIC_WIDTH = 512

local NAME_COLOR = {
	cc.c4b(3, 229, 0, 255),		-- 自己
	cc.c4b(0, 224, 255, 255),	-- 同阵营
	cc.c4b(255, 0, 0, 255),		-- 敌对
	cc.c4b(255, 212, 7, 255)	-- 首都
}

local SERVER_STATE_COLOR = cc.c4b(255, 0, 0, 255)

local SHOW_DESC_SCALE = 1.2 	-- 达到1.2时显示描述

--
--=========================================================
-- init
function worldMap:init()
	self.mapLevel = 1 --1级地图

	--data
	--============================
	self.worldHttpHelper = require "scene/assist/worldHttpHelper"
	self.worldHttpHelper.init()

	self.touchBeganP = cc.p(0, 0)
	self.touchedInfo = {}		-- 点击对象信息
	self.curChooseInfo = {}		-- 当前选中对象
	self.serverInfo = {}		-- 矩阵，存储，以服务器sid为key,{sid={serverInfo={},UI={obj,title,nameBg,name,titleName,kingUnion,king,createTime,serverState}}}

	-- ui data
	self.uiDescLayer = nil
	self.uiTouchPop = nil
	-- 初始化界面显示数据
	self:initMapShowData()

	--初始化
	--===========================
	self:initMapView()

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

	self.mapLayer:addChild(self.mapScrollView)

	-- mapInfo
	local mapInfo = self.mapInfo
	self.mapScrollView:setContentSize(cc.size(self.mapSize.width, self.mapSize.height))
	self.mapScrollView:setBounceable(false)
	local minScale = hp.uiHelper.RA_scale * 0.5
	--self.mapScrollView:setMinScale(minScale)
	--self.mapScrollView:setMaxScale(2*hp.uiHelper.RA_scale)
	self.mapScrollView:setZoomScale(1.2*hp.uiHelper.RA_scale)
	self.mapScrollView:setDelegate()

	self.bgLayer:addChild(self.viewLayer)

	self:gotoPosition(player.serverMgr.getMyServer().name)

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
	self.touchLayer:setTouchEnabled(false) 
	self.touchLayer:registerScriptTouchHandler(touchLayerOnTouched, true, 0, false)


	-- [[ infoLayer ]]
	-- 地图信息信息放置层
	--==========================
	-- top信息
	self.infoLayer = cc.Layer:create()
	-- require "ui/bigMap/common/topMenu" 
	require "ui/world/topMenuWorld" 
	local topMenu = UI_topMenuWorld.new()
	topMenu:onAdd(self)
	self.infoLayer:addChild(topMenu.layer)
	table.insert(self.uis, topMenu)
	-- -- 行军管理按钮
	-- require "ui/march/marchMgrBtn"
	-- local ui_ = UI_marchMgrBtn.new()
	-- ui_:onAdd(self)
	-- self.infoLayer:addChild(ui_.layer)
	-- table.insert(self.uis, ui_)
	-- -- cd队列
	-- require "ui/common/cdList"
	-- local cdUI = UI_cdList.new()
	-- cdUI:onAdd(self)
	-- self.infoLayer:addChild(cdUI.layer)
	-- table.insert(self.uis, cdUI)


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
	local mainMenu = UI_mainMenu.new(self)
	mainMenu:onAdd(self)
	self.menuLayer:addChild(mainMenu.layer)
	table.insert(self.uis, mainMenu)
	self.mainMenu = mainMenu

	-- [[ modalUILayer ]]
	-- modal dialog放置层
	--==========================
	self.modalUILayer = cc.Layer:create()
	self.modalUIs = {}

	require "ui/world/worldTouchPop"
	local ui_ = UI_worldTouchPop.new()
	self.modalUILayer:addChild(ui_.layer)
	self.uiTouchPop = ui_
	self.uiTouchPop:hide()


	-- 添加各层到场景
	--==========================
	self:addCCNode(self.mapLayer)
	self:addCCNode(self.touchLayer)
	self:addCCNode(self.infoLayer)
	self:addCCNode(self.uiLayer)
	self:addCCNode(self.menuLayer)
	self:addCCNode(self.modalUILayer)

	-- add message
	-- self:registMsg(hp.MSG.MAP_ARMY_ATTACK)
	-- self:registMsg(hp.MSG.UNION_JOIN_SUCCESS)
	-- self:registMsg(hp.MSG.UNION_NOTIFY)
	-- self:registMsg(hp.MSG.KING_BATTLE)
	self:registMsg(hp.MSG.WORLD_INFO)

	self.worldHttpHelper.httpReqWorldInfo()
end

-- onEnter
function worldMap:onEnter()
	self:onEnterAnim()
end

function worldMap:coWorld2Kindom(coWorld)
	local tilep = self:pScreen2Tile(coWorld)
	local showp = self:pTile2Real(tilep)
	local kx = math.ceil((tilep.x+1)/self.mapInfo.map.w)
	local ky = math.ceil((tilep.y+1)/self.mapInfo.map.h)
	local x = showp.x%(self.mapInfo.map.w*2)
	local y = showp.y%self.mapInfo.map.h
	return {kx=kx,ky=ky,x=x,y=y}
end

-- addUI
function worldMap:addUI(ui_)
	ui_.uiType_ = 0
	self.uiLayer:addChild(ui_.layer)
	table.insert(self.uis, ui_)
	table.insert(self.UIs, ui_)
	ui_:onAdd(self)

	-- 重设菜单
	self.mainMenu.reset()
end

-- removeUI
function worldMap:removeUI(ui_)
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

	-- 重设菜单
	self.mainMenu.reset()
end

-- removeAllUI
function worldMap:removeAllUI()
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

	-- 重设菜单
	self.mainMenu.reset()
end


-- addModalUI
function worldMap:addModalUI(ui_, zOrder_)
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
function worldMap:removeModalUI(ui_)
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
function worldMap:removeAllModalUI()
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

	self.uiTouchPop:hide()
end


--
--=========================================================
-- 初始化地图显示数据
function worldMap:initMapShowData()	
	-- 地图尺寸
	self.mapSize = {width=AXIS_X*PIC_WIDTH,height=AXIS_Y*PIC_HEIGHT}
end

-- initMapView
function worldMap:initMapView()
	-- 我的服务器
	local myServer_ = player.serverMgr.getMyServer()
	-- 地图大小
	local mapSize_ = player.serverMgr.getWorldSize()

	local viewLayer = cc.Layer:create()
	local viewGroundLayer = cc.Layer:create()	-- 地表
	local viewObjLayer = cc.Layer:create()		-- 物体
	local viewNameLayer = cc.Layer:create()		-- 名称
	local viewIconLayer = cc.Layer:create()		-- 图标
	local viewDescLayer = cc.Layer:create()		-- 描述
	viewLayer:addChild(viewGroundLayer)
	viewLayer:addChild(viewObjLayer)
	viewLayer:addChild(viewNameLayer)
	viewLayer:addChild(viewIconLayer)
	viewLayer:addChild(viewDescLayer)
	self.viewObjLayer = viewObjLayer

	-- 图标
	-- 自己服务器，唯一
	local myServerIcon_ = cc.Sprite:create(config.dirUI.common.."kd_7.png")
	viewIconLayer:addChild(myServerIcon_)
	self.myServerIcon = myServerIcon_

	-- 背景
	for i = 1, AXIS_Y do
		for j = 1, AXIS_X do
			local bg_ = cc.Sprite:create()
			bg_:setAnchorPoint(0, 0)
			local x_ = PIC_WIDTH * (j - 1)
			local y_ = self.mapSize.height - PIC_HEIGHT * i
			cclog_("x_,y_",x_,y_)
			bg_:setPosition(x_, y_)
			bg_:setTexture(string.format(config.dirUI.world .. "map/%d.png",(i-1)*AXIS_X+j))
			viewGroundLayer:addChild(bg_)
		end
	end
	
	-- 读取服务器信息
	for _, v in ipairs(game.data.serverList) do
		local info_ = {}
		local ui_ = {}
		info_.serverInfo = v
		info_.UI = ui_		

		-- 城市
		local obj_ = cc.Sprite:create()
		local texture2D_ = cc.Director:getInstance():getTextureCache():addImage(config.dirUI.world..v.img)
		local objSize_ = texture2D_:getContentSize()
		obj_:setTag(v.sid)
		obj_:setTexture(config.dirUI.world..v.img)
		obj_:setPosition(v.position[1], v.position[2])
		local scale_ = OBJ_SCALE[v.type]
		obj_:setScale(scale_)
		viewObjLayer:addChild(obj_)
		ui_.obj = obj_

		-- 名称
		local nameBgNode_ = cc.Sprite:create(config.dirUI.map.."name_bg.png")
		local nameNode_ = cc.Label:createWithTTF("", "font/main.ttf", NAME_SIZE)
		nameBgNode_:setPosition(v.position[1], v.position[2] - objSize_.height*scale_/2)
		nameNode_:setPosition(v.position[1], v.position[2] - objSize_.height*scale_/2)
		viewNameLayer:addChild(nameBgNode_)
		viewNameLayer:addChild(nameNode_)
		ui_.nameBg = nameBgNode_
		ui_.name = nameNode_

		nameNode_:setString(v.name)		
		if v.type == OBJECT_TYPE.CAPITAL then
			nameNode_:setColor(NAME_COLOR[4])
		elseif myServer_.sid == v.sid then
			nameNode_:setColor(NAME_COLOR[1])
		elseif myServer_.country == v.country then
			nameNode_:setColor(NAME_COLOR[2])
		else
			nameNode_:setColor(NAME_COLOR[3])
		end
		nameBgNode_:setTextureRect(cc.rect(0, 0, nameNode_:getContentSize().width+40, 36))

		-- 图标
		-- 自己服务器
		if myServer_.sid == v.sid then
			myServerIcon_:setPosition(v.position[1] - objSize_.width*scale_/3, v.position[2] - objSize_.height*scale_/2)
		end

		-- 头衔
		local titleNode_ = cc.Sprite:create(config.dirUI.title.."1001.png")
		titleNode_:setVisible(false)
		titleNode_:setPosition(v.position[1], v.position[2] + objSize_.height*scale_/2)
		viewIconLayer:addChild(titleNode_)
		ui_.title = titleNode_

		-- 描述
		local labelPos_ = {v.position[1] - objSize_.width*scale_/2, v.position[2] - objSize_.height*scale_/2}
		local titleName_ = cc.Label:createWithTTF("", "font/main.ttf", DESC_SIZE)
		local kingUnion_ = cc.Label:createWithTTF("", "font/main.ttf", DESC_SIZE)
		local king_ = cc.Label:createWithTTF("", "font/main.ttf", DESC_SIZE)
		local createTime_ = cc.Label:createWithTTF("", "font/main.ttf", DESC_SIZE)
		titleName_:setVisible(false)
		kingUnion_:setVisible(false)
		king_:setVisible(false)
		createTime_:setVisible(false)
		titleName_:setPosition(labelPos_[1], labelPos_[2] - DESC_SIZE * 1.5)
		kingUnion_:setPosition(labelPos_[1], labelPos_[2] - DESC_SIZE * 1.5 * 2)
		king_:setPosition(labelPos_[1], labelPos_[2] - DESC_SIZE * 1.5 * 3)
		createTime_:setPosition(labelPos_[1], labelPos_[2] - DESC_SIZE * 1.5 * 4)
		titleName_:setAnchorPoint(0, 0.5)
		kingUnion_:setAnchorPoint(0, 0.5)
		king_:setAnchorPoint(0, 0.5)
		createTime_:setAnchorPoint(0, 0.5)
		viewDescLayer:addChild(titleName_)
		viewDescLayer:addChild(kingUnion_)
		viewDescLayer:addChild(king_)
		viewDescLayer:addChild(createTime_)
		ui_.titleName = titleName_
		ui_.kingUnion = kingUnion_
		ui_.king = king_
		ui_.createTime = createTime_
		self.uiDescLayer = viewDescLayer

		-- 服务器状态
		local stateLabel_ = cc.Label:createWithTTF("", "font/main.ttf", DESC_SERVER_STATE) 		
		if v.type == 1 then
			stateLabel_:setAnchorPoint(0.5, 0.5)
			stateLabel_:setPosition(v.position[1], v.position[2] - objSize_.height*scale_/2 - DESC_SIZE * 1.5)
		else
			stateLabel_:setAnchorPoint(0, 0.5)
			stateLabel_:setPosition(v.position[1] + objSize_.width*scale_/4, v.position[2] - objSize_.height*scale_/2)
		end
		viewDescLayer:addChild(stateLabel_)
		stateLabel_:setVisible(false)
		ui_.serverState = stateLabel_

		-- test
		titleName_:setString("asdfasdf")
		kingUnion_:setString("asdfasdf")
		king_:setString("asdfasdf")
		createTime_:setString("asdfasdf")

		self.serverInfo[v.sid] = info_
	end

	self.viewLayer = viewLayer
end

-- 触屏坐标处理函数
--======================================================
function worldMap:pScreen2Map(p_)
	local p = self.mapScrollView:getContentOffset()
	local scale = self.mapScrollView:getZoomScale()
	return cc.p((p_.x-p.x)/scale, (p_.y - p.y)/scale)
end

-- 点击判断
function worldMap:hitTest(pos_)
	cclog_("hitTest",pos_.x,pos_.y)
	self.spriteTouched = nil
	self.touchedInfo = {}
	local function pointInRect(p_, rect_)
		if (p_.x > rect_.x) and (p_.y > rect_.y) and (p_.x < rect_.x + rect_.width) and (p_.y < rect_.y + rect_.height) then
			return true
		else
			return false
		end
	end

	-- 地表城市，只能是服务器
	for _, node_ in ipairs(self.viewObjLayer:getChildren()) do
		local rect_ = node_:getBoundingBox()
		if pointInRect(pos_, rect_) then
			self.spriteTouched = node_
			self.touchedInfo = {}
			self.touchedInfo.info = self.serverInfo[node_:getTag()]
			self.touchedInfo.type = self.touchedInfo.info.serverInfo.type
			return true
		end
	end

	return false
end


-- 触屏处理
--======================================================
-- onTouchBegan
function worldMap:onTouchBegan(touchs_)
	local pNum = table.getn(touchs_)
	if pNum==3 then
		self.touchBeganP = cc.p(touchs_[1], touchs_[2])
		local mapPostion_ = self:pScreen2Map(self.touchBeganP)
		if self.spriteTouched==nil then
			if not self:hitTest(mapPostion_) then
				return
			end

			-- 仅当点击的是不同对象，才更新状态
			-- if self.curChooseInfo.obj ~= self.spriteTouched then
			self.spriteTouched:updateDisplayedColor(cc.c3b(128, 128, 128))
			-- end
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
function worldMap:onTouchMoved(touchs_)
	local pNum = table.getn(touchs_)
	if pNum==3 then
		local px = touchs_[1] - self.touchBeganP.x
		local py = touchs_[2] - self.touchBeganP.y
		if -5<px and px<5 and -5<py and py<5 then
		-- 移动小于5个像素
			return
		end
	else
		if self.mapScrollView:getZoomScale() > SHOW_DESC_SCALE then
			self.uiDescLayer:setVisible(true)
		else
			self.uiDescLayer:setVisible(false)
		end
	end

	if self.spriteTouched~=nil then
		local spriteTmp = self.spriteTouched
		self.spriteTouched = nil
		spriteTmp:updateDisplayedColor(cc.c3b(255, 255, 255))
	end
	self:clearTouchState()
end
-- onTouchEnded
function worldMap:onTouchEnded(touchs_)
	local spriteTmp = self.spriteTouched
	local lastObj_ = self.curChooseInfo.obj
	-- 清除上个点击对象状态
	self:clearTouchState()

	if spriteTmp~=lastObj_ then
		-- 当前点击状态修改
		if spriteTmp~=nil then
			if self.touchedInfo.type == OBJECT_TYPE.SERVER then
				local sid_ = self.touchedInfo.info.serverInfo.sid
				local worldInfo_ = self.worldHttpHelper.getWorldInfo()
				if worldInfo_[sid_] == nil then
					-- 维护中
					require "ui/common/successBox"
	    			local box_ = UI_successBox.new(hp.lang.getStrByID(5521), hp.lang.getStrByID(5520), nil)
	      			self:addModalUI(box_)
					self.curChooseInfo = {}
				else
					self.curChooseInfo = self.touchedInfo
					self.curChooseInfo.obj = spriteTmp
					local light_ = inLight2(spriteTmp,3)
					spriteTmp:addChild(light_)
					light_:setTag(OBJECT_TAG.LIGHT)
					-- 服务器
					self.uiTouchPop:show(sid_)
				end
			elseif self.touchedInfo.type == OBJECT_TYPE.CAPITAL then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5300), hp.lang.getStrByID(5301), nil)
      			self:addModalUI(box_)
				self.curChooseInfo = {}
			end
		end
	else
		-- 清除
		self.curChooseInfo = {}
	end

	-- 还原状态
	if spriteTmp~=nil then
		self.spriteTouched = nil
		spriteTmp:updateDisplayedColor(cc.c3b(255, 255, 255))
	else
		self.curChooseInfo = {}
	end
end
-- onTouchCancelled
function worldMap:onTouchCancelled(touchs_)
end

function worldMap:clearTouchState()
	if self.curChooseInfo.type == nil then
		return
	end

	if self.curChooseInfo.type == OBJECT_TYPE.SERVER then
		if self.uiTouchPop ~= nil then
			self.uiTouchPop:hide()
		end

		-- 移除闪光
		self.curChooseInfo.obj:removeChildByTag(OBJECT_TAG.LIGHT)
	end

	self.curChooseInfo = {}
end

-- 逻辑处理
-- 刷新界面
function worldMap:refreshView()
	local worldInfo_ = self.worldHttpHelper.getWorldInfo()
	-- 本地保存的是所有的
	for k, v in pairs(self.serverInfo) do
		local ui_ = self.serverInfo[k].UI
		if worldInfo_[k] ~= nil then
			ui_.kingUnion:setVisible(true)
			ui_.king:setVisible(true)
			ui_.createTime:setVisible(true)
			local netInfo_ = worldInfo_[k]
			-- 联盟
			if netInfo_.kingUnion == "" then
				ui_.kingUnion:setString(string.format(hp.lang.getStrByID(5382), hp.lang.getStrByID(5147)))
			else
				ui_.kingUnion:setString(string.format(hp.lang.getStrByID(5382), netInfo_.kingUnion))
			end

			-- 国王
			if netInfo_.king == "" then
				ui_.king:setString(string.format(hp.lang.getStrByID(5513), hp.lang.getStrByID(5147)))
			else
				ui_.king:setString(string.format(hp.lang.getStrByID(5513), netInfo_.king))
			end

			local time_ = hp.datetime.strTime(player.getServerTime() - netInfo_.createTime)
			ui_.createTime:setString(string.format(hp.lang.getStrByID(5512), time_))

			if netInfo_.title == nil or netInfo_.title == 0 then
				ui_.title:setVisible(false)
				ui_.titleName:setVisible(false)
			else
				ui_.title:setVisible(true)
				ui_.titleName:setVisible(true)
				-- ui_.title:setTexture(config.dirUI.worldTitle..v.)
			end
		else
			cclog("worldMap:refreshView", "server not have sid:", k)
			-- 维护中

			ui_.serverState:setVisible(true)
			if k < 0 then
				-- 首都
				ui_.serverState:setString(hp.lang.getStrByID(5519))
				ui_.serverState:setColor(SERVER_STATE_COLOR)
			else
				ui_.serverState:setString(hp.lang.getStrByID(5515))
				ui_.serverState:setColor(SERVER_STATE_COLOR)
			end
		end
	end
end

-- 消息处理
function worldMap:onMsg(msg_, param_)
	self.super.onMsg(self, msg_, param_)
	
	if msg_ == hp.MSG.WORLD_INFO then
		if param_.msgType == 1 then
			self.touchLayer:setTouchEnabled(true) 
			self:refreshView()
		end
	end
end

function worldMap:gotoPosition(kindom_)
	local info_ = player.serverMgr.getServerByName(kindom_)
	if info_ == nil then
		return
	end

	local ksid_ = info_.sid
	local serverInfo_ = self.serverInfo[ksid_].serverInfo
	cclog_("serverInfo_.position[1]",serverInfo_.position[1],serverInfo_.position[2], scale_)
	local scale_ = self.mapScrollView:getZoomScale()
	local x_ = game.visibleSize.width / 2 - scale_ * serverInfo_.position[1]
	local y_ = game.visibleSize.height / 2 - scale_ * serverInfo_.position[2]
	local pos_ = cc.p(x_, y_)
	self.mapScrollView:setContentOffset(pos_)
end