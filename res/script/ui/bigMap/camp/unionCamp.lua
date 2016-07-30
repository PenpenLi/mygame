--
-- ui/bigMap/camp/unionCamp.lua
-- 敌人营地弹出界面 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_unionCamp = class("UI_unionCamp", UI)

--init
function UI_unionCamp:init(tileInfo_)
	-- ===============================
	self.tileInfo = tileInfo_
	self.armyInfo = self.tileInfo.objInfo.armyInfo

	-- ui
	-- ===============================
	self:initUI()
	
	local name_ = hp.lang.getStrByID(5304)
	if self.armyInfo.unionID == 0 then
		name_ = name_..self.armyInfo.name
	else
		name_ = name_..hp.lang.getStrByID(21)..self.armyInfo.unionName..hp.lang.getStrByID(22)..self.armyInfo.name
	end
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5148), tileInfo_.position, name_)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function onProfileTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			ui_ = UI_playerInfo.new(self.armyInfo.pid, self.armyInfo.serverID)
			self:addUI(ui_)
			self:close()
		end
	end

	self.profile:addTouchEventListener(onProfileTouched)

	-- 初始显示
	self:initShow()
end

function UI_unionCamp:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionCamp.json")
	local content = self.wigetRoot:getChildByName("Panel_13785_Copy0")

	-- 头像
	self.image = content:getChildByName("ImageView_13786")

	-- 描述
	self.name = content:getChildByName("Label_13787_Copy0")
	self.power = content:getChildByName("Label_13787")
	self.kill = content:getChildByName("Label_13787_Copy1")
	self.alliance = content:getChildByName("Label_13787_Copy2")
	self.kingdom = content:getChildByName("Label_13787_Copy3")
	self.position = content:getChildByName("Label_13787_Copy4")

	local btnContent = content:getChildByName("Panel_13928")
	-- 查看信息
	self.profile = btnContent:getChildByName("ImageView_13793")
	self.profile:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1312))
end

function UI_unionCamp:initShow()
	self.name:setString(hp.lang.getStrByID(1307)..": "..self.armyInfo.name)
	self.power:setString(string.format(hp.lang.getStrByID(2032), self.armyInfo.power))
	self.kill:setString(hp.lang.getStrByID(1308)..": "..self.armyInfo.kill)
	if self.armyInfo.unionID == 0 then
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..hp.lang.getStrByID(5147))
	else
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..self.armyInfo.unionName)
	end
	self.kingdom:setString(hp.lang.getStrByID(5494)..": "..player.serverMgr.getCountryByPos(self.tileInfo.position))
	self.position:setString(player.serverMgr.formatPosition(self.tileInfo.position))
	self.image:loadTexture(config.dirUI.heroHeadpic..self.armyInfo.image..".png")
end