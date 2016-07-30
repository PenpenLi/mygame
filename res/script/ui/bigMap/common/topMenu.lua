--
-- ui//bigMap/common/topMenu.lua
-- 顶部菜单
--===================================
require "ui/UI"


UI_topMenu = class("UI_topMenu", UI)

local resList = {"rock", "wood", "mine", "food", "silver"}

--init
function UI_topMenu:init()
	-- data
	-- ===============================


	-- ui
	-- ===============================
	self:initUI()

	-- 资源加载
	for i, v in ipairs(resList) do
		if self[v] ~= nil then
			--local strNum = string.format("%d", player.getResource(v))
			self[v]:setString(player.getResourceShow(v))
		end
	end

	-- call back
	-- 回城
	function OnBackHomeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			game.curScene:gotoPosition(player.serverMgr.getMyPosition())
		end
	end

	-- 书签管理
	function OnBookMarkTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/func/UIbookMark"
			local ui = UI_bookMark.new()
			self:addUI(ui)
		end
	end

	-- 查找
	function OnSearchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/func/search"
			local ui_ = UI_search.new()
			self:addModalUI(ui_)
		end
	end

	-- 王国地图
	function OnKindomMapTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			cclog_("kindomMap")
			require "scene/worldMap"
			local map = worldMap.new()
			map:enter()
		end
	end

	-- 要塞
	function onFortressTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/battle/fortressPopInfo"
			local ui_ = UI_fortressPopInfo.new()
			self:addModalUI(ui_)			
		end
	end

	-- 全屏/退出全屏
	function OnFullScreenTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			cclog_("fullScreen")
		end
	end

	local function onResItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/item/resourceItem"
			local ui  = UI_resourceItem.new(sender:getTag())
			self:addUI(ui)
		end
	end

	local function onEnergeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/item/energyItem"
			local ui = UI_energyItem.new()
			self:addUI(ui)
		end
	end
	
	self.backHome:addTouchEventListener(OnBackHomeTouched)
	self.bookMark:addTouchEventListener(OnBookMarkTouched)
	self.search:addTouchEventListener(OnSearchTouched)
	self.kdMap:addTouchEventListener(OnKindomMapTouched)
	self.fortress:addTouchEventListener(onFortressTouched)
	-- self.fullScreen:addTouchEventListener(OnFullScreenTouched)
	self.uiEnergeBg:addTouchEventListener(onEnergeTouched)
	self.rockImg:addTouchEventListener(onResItemTouched)
	self.woodImg:addTouchEventListener(onResItemTouched)
	self.mineImg:addTouchEventListener(onResItemTouched)
	self.foodImg:addTouchEventListener(onResItemTouched)
	self.silverImg:addTouchEventListener(onResItemTouched)

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)

	-- registMsg
	self:registMsg(hp.MSG.RESOURCE_CHANGED)
	self:registMsg(hp.MSG.KING_BATTLE)
	self:registMsg(hp.MSG.COPY_NOTIFY)

	self:updateInfo()
end

function UI_topMenu:updateInfo()
	self.uiEnerge:setString(player.getEnerge().."/"..100)
end

function UI_topMenu:updateShow()
	local fortress_ = player.fortressMgr.getFortressInfo()
	if fortress_ == nil then
		return
	end
	
	if fortress_.open == globalData.OPEN_STATUS.OPEN then
		local light1 = inLight(self.fortress:getVirtualRenderer(),1)
		self.fortress:addChild(light1)
	else
		self.fortress:removeAllChildren()
	end
end

function UI_topMenu:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "topMenu.json")
	local content = self.wigetRoot:getChildByName("Panel_8268")

	self.backHome = content:getChildByName("ImageView_8269")
	self.bookMark = content:getChildByName("ImageView_8270")
	self.search = content:getChildByName("ImageView_8271")
	self.kdMap = content:getChildByName("ImageView_8272")
	self.fortress = content:getChildByName("ImageView_8274")
	-- self.fullScreen = content:getChildByName("ImageView_8273")
	self.uiEnergeBg = content:getChildByName("Image_147")
	self.uiEnerge = self.uiEnergeBg:getChildByName("Label_148")

	-- 资源
	-- rock
	local rockPanel_ = content:getChildByName("Panel_8276")
	self.rock = rockPanel_:getChildByName("Label_8277")
	self.rockImg = rockPanel_:getChildByName("ImageView_8275")
	-- wood
	local woodPanel_ = content:getChildByName("Panel_8277")
	self.wood = woodPanel_:getChildByName("Label_8277")
	self.woodImg = woodPanel_:getChildByName("ImageView_8275")
	-- mine
	local minePanel_ = content:getChildByName("Panel_8278")
	self.mine = minePanel_:getChildByName("Label_8277")
	self.mineImg = minePanel_:getChildByName("ImageView_8275")
	-- food
	local foodPanel_ = content:getChildByName("Panel_8279")
	self.food = foodPanel_:getChildByName("Label_8277")
	self.foodImg = foodPanel_:getChildByName("ImageView_8275")
	-- silver
	local silverPanel_ = content:getChildByName("Panel_8280")
	self.silver = silverPanel_:getChildByName("Label_8277")
	self.silverImg = silverPanel_:getChildByName("ImageView_8275")

	self:updateShow()
end

-- onMsg
function UI_topMenu:onMsg(msg_, resInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED then
		local strNum = hp.common.changeNumUnit(resInfo_.num)
		if self[resInfo_.name] ~= nil then
			self[resInfo_.name]:setString(strNum)
		end 
	elseif msg_ == hp.MSG.KING_BATTLE then
		self:updateShow()
	elseif msg_ == hp.MSG.COPY_NOTIFY then
		if resInfo_.msgType == 6 then
			self:updateInfo()
		end
	end
end