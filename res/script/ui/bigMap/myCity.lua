--
-- ui/bigMap/myCity.lua
-- 自己城市弹出界面 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_myCity = class("UI_myCity", UI)

--init
function UI_myCity:init(tileInfo_)
	-- ===============================
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================
	self:initUI()
	
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1306).."."..player.getName(), tileInfo_.position)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function OnEnterCityTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require("scene/cityMap")
			map = cityMap.new()
			map:enter()
		end
	end

	self.enterCity:addTouchEventListener(OnEnterCityTouched)

	-- 初始显示
	self:initShow()
end

function UI_myCity:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "myCity.json")
	local content = self.wigetRoot:getChildByName("Panel_13785_Copy0")

	-- 头像
	self.image = content:getChildByName("ImageView_13786")

	-- 描述
	self.name = content:getChildByName("Label_13787_Copy0")
	self.power = content:getChildByName("Label_13787")
	self.kill = content:getChildByName("Label_13787_Copy1")
	self.alliance = content:getChildByName("Label_13787_Copy2")
	self.kindom = content:getChildByName("Label_13787_Copy3")
	self.position = content:getChildByName("Label_13787_Copy4")

	-- 回城
	self.enterCity = content:getChildByName("ImageView_13793")
	self.enterCity:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1304))
end

function UI_myCity:initShow()
	self.name:setString(hp.lang.getStrByID(1307)..": "..player.getName())
	self.power:setString(string.format(hp.lang.getStrByID(2032), player.getPower()))
	self.kill:setString(hp.lang.getStrByID(1308)..": "..self.tileInfo.objInfo.kill)
	if player.getAlliance():getUnionID() == 0 then
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..hp.lang.getStrByID(5147))
	else
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..player.getAlliance():getBaseInfo().name)
	end
	self.kindom:setString(hp.lang.getStrByID(1310)..": "..hp.lang.getStrByID(5147))
	self.position:setString(hp.lang.getStrByID(1204)..string.format(": K:%s X:%d Y:%d", "2-2", player.getPosition().x, player.getPosition().y))
	-- 头像
	self.image:loadTexture(config.dirUI.heroHeadpic..self.tileInfo.objInfo.image..".png")
end