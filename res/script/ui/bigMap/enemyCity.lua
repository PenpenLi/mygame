--
-- ui/bigMap/enemyCity.lua
-- 自己城市弹出界面 
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
	
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1306).."."..tileInfo_.objInfo.name, tileInfo_.position)

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
					local ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(1257), 1013, 1)
					self:addModalUI(ui_)
				else
					local function onConfirm1Touched()
						require "ui/bigMap/rally"
						local ui_ = UI_rally.new(self.tileInfo)
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

	self.attack:addTouchEventListener(OnAttackTouched)
	self.rally:addTouchEventListener(onRallyTouched)

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
	self.kindom = content:getChildByName("Label_13787_Copy3")
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
	self.kindom:setString(hp.lang.getStrByID(1310)..": "..hp.lang.getStrByID(5147))
	self.position:setString(hp.lang.getStrByID(1204)..string.format(": K:%s X:%d Y:%d", "2-2", self.tileInfo.position.x, self.tileInfo.position.y))
	self.image:loadTexture(config.dirUI.heroHeadpic..self.tileInfo.objInfo.image..".png")
end