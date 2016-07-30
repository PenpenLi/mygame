--
-- ui/bigMap/source/UISource.lua
-- 点击资源弹出UI 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_source = class("UI_source", UI)

local imageList = {"gold.png", "silver.png", "food.png", "wood.png", "rock.png", "mine.png"}

--init
function UI_source:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_
	self.totalRes = self.tileInfo.objInfo.resNum
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
			require "ui/march/march"
			UI_march.openMarchUI(self, tileInfo_.position, globalData.MARCH_TYPE.OCCUPY_RESOURCE, {pickupRate=self.resourceInfo.pickupRate, sourceType=self.resourceInfo.growth})
			self:close()
		end
	end

	self.OnOccupyTouched = OnOccupyTouched

	self.information:addTouchEventListener(OnInfoTouched)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- 初始显示
	self:initShow()
end

function UI_source:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "source.json")
	local content = self.wigetRoot:getChildByName("Panel_12334")

	-- 描述
	content:getChildByName("Label_13757"):setString(hp.lang.getStrByID(1224))

	-- 数量
	content:getChildByName("Label_13758"):setString(hp.lang.getStrByID(1317))
	content:getChildByName("ImageView_13759"):loadTexture(config.dirUI.common..imageList[self.resourceInfo.growth+1])
	self.resNum = content:getChildByName("Label_13760")
	self.resNum:setString(self.totalRes)

	-- 占领者
	content:getChildByName("Label_13761"):setString(hp.lang.getStrByID(1226)..":")
	self.ownerImage = content:getChildByName("ImageView_13762")
	self.owner = content:getChildByName("Label_13763")

	-- 提示
	content:getChildByName("Label_13764"):setString(hp.lang.getStrByID(1225))

	-- 信息
	self.information = content:getChildByName("ImageView_13775")
	self.information:getChildByName("Label_13776"):setString(hp.lang.getStrByID(5154))

	-- 占领
	self.occupy = content:getChildByName("ImageView_13777")	
end

function UI_source:initShow()
	self.owner:setString(hp.lang.getStrByID(5183))
	self.occupy:getChildByName("Label_13778"):setString(hp.lang.getStrByID(1201))

	-- 是否为同一服务器
	if player.serverMgr.isMyPosServer(self.tileInfo.position.kx, self.tileInfo.position.ky) then
		self.occupy:addTouchEventListener(self.OnOccupyTouched)
	else
		self.occupy:loadTexture(config.dirUI.common .. "button_gray.png")
	end
end

function UI_source:getType()
	return globalData.ARMY_BELONG.NONE
end

function UI_source:updateInfo()
end

function UI_source:onRemove()
	hp.msgCenter.sendMsg(hp.MSG.SOURCEUI_CLOSE)
	self.super.onRemove(self)
end