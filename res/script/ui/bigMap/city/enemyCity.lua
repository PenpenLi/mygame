--
-- ui/bigMap/city/enemyCity.lua
-- 敌人城市弹出界面 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_enemyCity = class("UI_enemyCity", UI)

--init
function UI_enemyCity:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================
	self:initUI()
	
	local info_ = hp.gameDataLoader.getTable("fieldFunc")[self.tileInfo.tileType]
	local name_ = hp.lang.getStrByID(5302)
	if tileInfo_.objInfo.unionID == 0 then
		name_ = name_..tileInfo_.objInfo.name
	else
		name_ = name_..hp.lang.getStrByID(21)..tileInfo_.objInfo.unionName..hp.lang.getStrByID(22)..tileInfo_.objInfo.name
	end
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1306).."."..tileInfo_.objInfo.name, tileInfo_.position, name_)

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
				UI_march.openMarchUI(self, tileInfo_.position, globalData.MARCH_TYPE.ATTACK_CITY)
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

	local function onRallyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			if player.getAlliance():getUnionID() == 0 then				
				require "ui/common/successBox"
				local ui_ = UI_successBox.new(hp.lang.getStrByID(1259), hp.lang.getStrByID(1258))
				self:addModalUI(ui_)
			else
				local buildLv = player.buildingMgr.getBuildingMaxLvBySid(1013)
				if buildLv<=0 then
					require "ui/common/noBuildingNotice"
					local ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(1257), 1013, 1, hp.lang.getStrByID(1259))
					self:addModalUI(ui_)
				else
					local function onConfirm1Touched()
						require "ui/bigMap/war/rally"
						local ui_ = UI_rally.new(self.tileInfo.position)
						self:addModalUI(ui_)
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
		end
	end

	local function onScoutTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			if player.researchMgr.getResearchLv(110) > 0 then
				require "ui/bigMap/war/scout"
				ui_ = UI_scout.new(self.tileInfo.position, self.tileInfo.objInfo.name)
				self:addModalUI(ui_)
			else
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5192), hp.lang.getStrByID(5193), nil)
      			self:addModalUI(box_)
			end
		end
	end

	local function onCaptiveTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/war/capturedHero"
			ui_ = UI_capturedHero.new(self.tileInfo)
			self:addModalUI(ui_)
		end
	end

	local function onProfileTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			ui_ = UI_playerInfo.new(self.tileInfo.objInfo.id, self.tileInfo.objInfo.serverID)
			self:addUI(ui_)
			self:close()
		end
	end

	self.profile:addTouchEventListener(onProfileTouched)
	self.heroes:addTouchEventListener(onCaptiveTouched)

	-- 是否为同一服务器
	if player.serverMgr.isMyPosServer(self.tileInfo.position.kx, self.tileInfo.position.ky) then
		self.attack:addTouchEventListener(OnAttackTouched)
		self.rally:addTouchEventListener(onRallyTouched)
		self.scout:addTouchEventListener(onScoutTouched)
	else
	-- 不同服务器，一下操作不可用
		self.attack:loadTexture(config.dirUI.common .. "button_gray.png")
		self.rally:loadTexture(config.dirUI.common .. "button_gray.png")
		self.scout:loadTexture(config.dirUI.common .. "button_gray.png")
	end

	-- 初始显示
	self:initShow()
end

function UI_enemyCity:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "enemyCity.json")
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

	local btnContent = content:getChildByName("Panel_13929")
	-- 概览
	self.profile = btnContent:getChildByName("ImageView_13796_Copy0")
	self.profile:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1312))

	-- 侦察
	self.scout = btnContent:getChildByName("ImageView_13796_Copy1")
	self.scout:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1313))

	-- 工会战
	self.rally = btnContent:getChildByName("ImageView_13796")
	self.rally:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1314))

	-- 进攻
	self.attack = btnContent:getChildByName("ImageView_13797")
	self.attack:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1026))

	-- 抓的英雄
	btnContent:getChildByName("Label_13844"):setString(string.format(hp.lang.getStrByID(1311), self.tileInfo.objInfo.name))
	self.heroes = btnContent:getChildByName("ImageView_13793")
	self.heroes:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1315))
end

function UI_enemyCity:initShow()
	self.name:setString(hp.lang.getStrByID(1307)..": "..self.tileInfo.objInfo.name)
	self.power:setString(string.format(hp.lang.getStrByID(2032), self.tileInfo.objInfo.power))
	self.kill:setString(hp.lang.getStrByID(1308)..": "..self.tileInfo.objInfo.kill)
	if self.tileInfo.objInfo.unionID == 0 then
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..hp.lang.getStrByID(5147))
	else
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..self.tileInfo.objInfo.unionName)
	end
	self.kingdom:setString(hp.lang.getStrByID(5494)..": "..player.serverMgr.getCountryByPos(self.tileInfo.position))
	self.position:setString(player.serverMgr.formatPosition(self.tileInfo.position))
	self.image:loadTexture(config.dirUI.heroHeadpic..self.tileInfo.objInfo.image..".png")
end