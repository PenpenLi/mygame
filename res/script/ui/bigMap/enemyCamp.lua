--
-- ui/bigMap/enemyCamp.lua
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
	
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5148), tileInfo_.position)

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

	self.attack:addTouchEventListener(OnAttackTouched)

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
	self.kindom = content:getChildByName("Label_13787_Copy3")
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
	self.kindom:setString(hp.lang.getStrByID(1310)..": "..hp.lang.getStrByID(5147))
	self.position:setString(hp.lang.getStrByID(1204)..string.format(": K:%s X:%d Y:%d", "2-2", self.tileInfo.position.x, self.tileInfo.position.y))
	self.image:loadTexture(config.dirUI.heroHeadpic..self.armyInfo.image..".png")
end