--
-- ui//world/topMenu.lua
-- 世界顶部菜单
--===================================
require "ui/UI"

UI_topMenuWorld = class("UI_topMenuWorld", UI)

local resList = {"rock", "wood", "mine", "food", "silver"}

--init
function UI_topMenuWorld:init()
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
			game.curScene:gotoPosition(player.serverMgr.getMyServer().name)
		end
	end

	-- 查找
	function OnSearchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/world/worldSearch"
			local ui_ = UI_worldSearch.new()
			self:addModalUI(ui_)
		end
	end

	-- 要塞
	function onFortressTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/common/successBox"
			local box_ = UI_successBox.new(hp.lang.getStrByID(5300), hp.lang.getStrByID(5301), nil)
  			self:addModalUI(box_)		
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
			require "ui/goldShop/goldShop"
			local ui = UI_goldShop.new()
			self:closeAll()
			self:addUI(ui)
		end
	end
	
	self.backHome:addTouchEventListener(OnBackHomeTouched)
	self.search:addTouchEventListener(OnSearchTouched)
	self.fortress:addTouchEventListener(onFortressTouched)
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
	self:registMsg(hp.MSG.COPY_NOTIFY)

	self:updateInfo()
end

function UI_topMenuWorld:updateInfo()
	self.uiEnerge:setString(player.getResourceShow("gold"))
end

function UI_topMenuWorld:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "topMenuWorld.json")
	local content = self.wigetRoot:getChildByName("Panel_8268")

	self.backHome = content:getChildByName("ImageView_8269")
	self.search = content:getChildByName("ImageView_8271")
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
end

-- onMsg
function UI_topMenuWorld:onMsg(msg_, resInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED then
		local strNum = hp.common.changeNumUnit(resInfo_.num)
		if self[resInfo_.name] ~= nil then
			self[resInfo_.name]:setString(strNum)
		end
	elseif msg_ == hp.MSG.COPY_NOTIFY then
		if resInfo_.msgType == 6 then
			self:updateInfo()
		end
	end
end