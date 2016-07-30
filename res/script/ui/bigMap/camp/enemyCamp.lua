--
-- ui/bigMap/camp/enemyCamp.lua
-- 敌人营地弹出界面 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_enemyCamp = class("UI_enemyCamp", UI)

--init
function UI_enemyCamp:init(tileInfo_)
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
	local function OnAttackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then	
			local function onConfirm1Touched()
				require "ui/march/march"
				UI_march.openMarchUI(self, tileInfo_.position, globalData.MARCH_TYPE.ATTACK_CAMP)
				self:close()
			end

			if player.getNewGuyGuard() ~= 0 then
	   			require "ui/common/msgBoxRedBack"
	   			local ui_ = UI_msgBoxRedBack.new(hp.lang.getStrByID(5143), hp.lang.getStrByID(5144), hp.lang.getStrByID(1209),
	   				hp.lang.getStrByID(2412), onConfirm1Touched)
	   			self:addModalUI(ui_)
	   		else
	   			onConfirm1Touched()
	   		end
		end
	end

	local function onScoutTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			if player.researchMgr.getResearchLv(110) > 0 then
				require "ui/bigMap/war/scout"
				ui_ = UI_scout.new(self.tileInfo.position, self.tileInfo.objInfo.armyInfo.name)
				self:addModalUI(ui_)
			else
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5192), hp.lang.getStrByID(5193), nil)
      			self:addModalUI(box_)
			end
		end
	end

	local function onProfileTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			ui_ = UI_playerInfo.new(self.armyInfo.pid, self.armyInfo.serverID)
			self:addUI(ui_)
			self:close()
		end
	end

	self.scout:addTouchEventListener(onScoutTouched)
	self.attack:addTouchEventListener(OnAttackTouched)
	self.profile:addTouchEventListener(onProfileTouched)

	-- 初始显示
	self:initShow()
end

function UI_enemyCamp:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "enemyCamp.json")
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
	-- 返回
	self.profile = btnContent:getChildByName("ImageView_13793")
	self.profile:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1312))

	-- 查看信息
	self.scout = btnContent:getChildByName("ImageView_13793_Copy0")
	self.scout:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1313))

	-- 进攻
	self.attack = btnContent:getChildByName("ImageView_13925")
	self.attack:getChildByName("Label_13927"):setString(hp.lang.getStrByID(1026))
end

function UI_enemyCamp:initShow()
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