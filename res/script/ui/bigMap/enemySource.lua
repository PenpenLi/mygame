--
-- ui/bigMap/enemySource.lua
-- 点击敌人占领资源点弹出UI 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_enemySource = class("UI_enemySource", UI)

local imageList = {"silver.png", "food.png", "wood.png", "rock.png", "mine.png"}

--init
function UI_enemySource:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_
	self.resourceInfo = hp.gameDataLoader.getInfoBySid("resources", tileInfo_.objInfo.sid)

	-- ui
	-- ===============================
	self:initUI()	
	local popFrame = UI_popFrame.new(self.wigetRoot, self.resourceInfo.name, tileInfo_.position)

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
				UI_march.openMarchUI(self, tileInfo_.position, 3)
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

	self.information:addTouchEventListener(OnInfoTouched)
	self.attack:addTouchEventListener(OnOccupyTouched)
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
	content:getChildByName("ImageView_13759"):loadTexture(config.dirUI.common..imageList[self.resourceInfo.growth])
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
	self.information:getChildByName("Label_13776"):setString(hp.lang.getStrByID(1303))

	-- 攻击
	self.attack = content:getChildByName("ImageView_13777")
	self.attack:getChildByName("Label_13778"):setString(hp.lang.getStrByID(1026))
end

function UI_enemySource:initShow()
	local armyInfo_ = self.tileInfo.objInfo.armyInfo
	-- 占领者
	self.owner:setString(armyInfo_.name)
	if armyInfo_.unionID ~= 0 then
		local rankInfo_ = hp.gameDataLoader.getInfoBySid("unionRank", armyInfo_.rank)
		self.ownerImage:setVisible(true)
		self.ownerImage:loadTexture(config.dirUI.common..rankInfo_.image)
	end
end