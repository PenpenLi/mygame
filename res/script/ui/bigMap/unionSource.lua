--
-- ui/bigMap/unionSource.lua
-- 点击资源弹出UI 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_unionSource = class("UI_unionSource", UI)

local imageList = {"gold.png", "silver.png", "food.png", "wood.png", "rock.png", "mine.png"}

--init
function UI_unionSource:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_
	self.totalRes = self.tileInfo.objInfo.resNum
	self.resourceInfo = hp.gameDataLoader.getInfoBySid("resources", tileInfo_.objInfo.sid)

	-- ui
	-- ===============================
	self:initUI()	
	local popFrame = UI_popFrame.new(self.wigetRoot, self.resourceInfo.name, tileInfo_.position)

	-- call back
	local function onInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/source/sourceInformation"
			ui_ = UI_sourceInformation.new(self.tileInfo)
			self:addModalUI(ui_)
		end
	end

	local function onViewTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			print("view")
		end
	end

	self.information:addTouchEventListener(onInfoTouched)
	self.view:addTouchEventListener(onViewTouched)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- 初始显示
	self:initShow()
end

function UI_unionSource:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionSource.json")
	local content = self.wigetRoot:getChildByName("Panel_12334")

	-- 描述
	content:getChildByName("Label_13757"):setString(hp.lang.getStrByID(1224))

	-- 数量
	content:getChildByName("Label_13758"):setString(hp.lang.getStrByID(1317))
	content:getChildByName("ImageView_13759"):loadTexture(config.dirUI.common..imageList[self.resourceInfo.growth+1])
	content:getChildByName("Label_13760"):setString(self.tileInfo.objInfo.resNum)

	-- 占领者
	content:getChildByName("Label_13761"):setString(hp.lang.getStrByID(1226)..":")
	self.ownerImage = content:getChildByName("ImageView_13762")
	self.owner = content:getChildByName("Label_13763")

	-- 提示
	content:getChildByName("Label_13764"):setString(hp.lang.getStrByID(1225))

	-- 查看
	self.view = content:getChildByName("ImageView_13775")
	self.view:getChildByName("Label_13776"):setString(hp.lang.getStrByID(1303))

	-- 信息
	self.information = content:getChildByName("ImageView_13777")
	self.information:getChildByName("Label_13778"):setString(hp.lang.getStrByID(6015))
end

function UI_unionSource:initShow()
	local armyInfo_ = self.tileInfo.objInfo.armyInfo
	-- 占领者
	self.owner:setString(armyInfo_.name)
	if armyInfo_.unionID ~= 0 then
		local rankInfo_ = hp.gameDataLoader.getInfoBySid("unionRank", armyInfo_.rank)
		self.ownerImage:setVisible(true)
		self.ownerImage:loadTexture(config.dirUI.common..rankInfo_.image)
	end
end