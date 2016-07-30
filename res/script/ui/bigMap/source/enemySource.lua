--
-- ui/bigMap/source/enemySource.lua
-- 点击敌人占领资源点弹出UI 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_enemySource = class("UI_enemySource", UI)

local imageList = {"gold.png", "silver.png", "food.png", "wood.png", "rock.png", "mine.png"}

--init
function UI_enemySource:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_
	self.resourceInfo = hp.gameDataLoader.getInfoBySid("resources", tileInfo_.objInfo.sid)

	-- ui
	-- ===============================
	self:initUI()	
	local popFrame = UI_popFrame.new(self.wigetRoot, self.resourceInfo.name, tileInfo_.position, self.resourceInfo.name)

	-- call back
	local function OnInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/source/sourceInformation"
			ui_ = UI_sourceInformation.new(self.tileInfo)
			self:addModalUI(ui_)
		end
	end

	local function OnOccupyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local function onConfirm1Touched()
				require "ui/march/march"
				UI_march.openMarchUI(self, tileInfo_.position, globalData.MARCH_TYPE.ATTACK_RESOURCE)
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
			ui_ = UI_playerInfo.new(self.tileInfo.objInfo.armyInfo.pid, self.tileInfo.objInfo.armyInfo.serverID)
			self:addUI(ui_)
			self:close()
		end
	end

	self.scout:addTouchEventListener(onScoutTouched)
	self.information:addTouchEventListener(OnInfoTouched)
	self.attack:addTouchEventListener(OnOccupyTouched)
	self.profile:addTouchEventListener(onProfileTouched)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- 初始显示
	self:initShow()
end

function UI_enemySource:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "enemySource.json")
	local content = self.wigetRoot:getChildByName("Panel_12334")

	-- 描述
	content:getChildByName("Label_13757"):setString(hp.lang.getStrByID(1224))

	-- 数量
	content:getChildByName("Label_13758"):setString(hp.lang.getStrByID(1317))
	content:getChildByName("ImageView_13759"):loadTexture(config.dirUI.common..imageList[self.resourceInfo.growth + 1])
	content:getChildByName("Label_13760"):setString(self.tileInfo.objInfo.resNum)

	-- 占领者
	content:getChildByName("Label_13761"):setString(hp.lang.getStrByID(1226)..":")
	self.ownerImage = content:getChildByName("ImageView_13762")
	self.owner = content:getChildByName("Label_13763")

	-- 提示
	content:getChildByName("Label_13764"):setString(hp.lang.getStrByID(1225))

	-- 概览
	self.profile = content:getChildByName("ImageView_13775_Copy0")
	self.profile:getChildByName("Label_13776"):setString(hp.lang.getStrByID(1312))

	-- 侦察
	self.scout = content:getChildByName("ImageView_13777_Copy0")
	self.scout:getChildByName("Label_13778"):setString(hp.lang.getStrByID(1313))

	-- 信息
	self.information = content:getChildByName("ImageView_13775")
	self.information:getChildByName("Label_13776"):setString(hp.lang.getStrByID(5154))

	-- 攻击
	self.attack = content:getChildByName("ImageView_13777")
	self.attack:getChildByName("Label_13778"):setString(hp.lang.getStrByID(1026))
end

function UI_enemySource:initShow()
	local armyInfo_ = self.tileInfo.objInfo.armyInfo
	-- 占领者
	local name_ = armyInfo_.name
	if armyInfo_.unionID ~= 0 then
		name_ = hp.lang.getStrByID(21)..armyInfo_.unionName..hp.lang.getStrByID(22)..name_
	end
	self.owner:setString(name_)
	if armyInfo_.unionID ~= 0 then
		local rankInfo_ = hp.gameDataLoader.getInfoBySid("unionRank", armyInfo_.rank)
		self.ownerImage:setVisible(true)
		self.ownerImage:loadTexture(config.dirUI.common..rankInfo_.image)
	else
		self.ownerImage:setVisible(false)
	end
end

function UI_enemySource:getType()
	return globalData.ARMY_BELONG.ENEMY
end

function UI_enemySource:updateInfo()
	self:initShow()
end

function UI_enemySource:onRemove()
	hp.msgCenter.sendMsg(hp.MSG.SOURCEUI_CLOSE)
	self.super.onRemove(self)
end