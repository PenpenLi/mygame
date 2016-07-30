--
-- ui/bigMap/boss.lua
-- boss点击弹出界面 
--===================================
require "ui/frame/popFrame"
require "ui/msgBox/msgBox"

UI_boss = class("UI_boss", UI)


-- init
function UI_boss:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_
	self.bossInfo_ = hp.gameDataLoader.getInfoBySid("boss", tileInfo_.objInfo.sid)
	-- ui
	-- ===============================
	self:initCallBack()
	self:initUI()
	-- addCCNode
	-- ===============================
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(7908))
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_boss:initCallBack()

	local function onAttackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function attck()
				require "ui/march/march"
				UI_march.openMarchUI(self, self.tileInfo.position, globalData.MARCH_TYPE.ATTACK_BOSS)
				self:close()
			end
			local function goShop()
				require "ui/item/energyItem"
				local ui = UI_energyItem.new()
				self:addUI(ui)
				self:close()
			end
			if self.bossInfo_.bodyForce > player.getEnerge() then
				local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(7909),
					hp.lang.getStrByID(10807), hp.lang.getStrByID(2412), goShop)
				self:addModalUI(msgbox)
			else
				attck()
			end
		end
	end

	-- 子菜单（过时）
	-- local function onInfoTouched(sender, eventType)
	-- 	hp.uiHelper.btnImgTouched(sender, eventType)
	-- 	if eventType == TOUCH_EVENT_ENDED then			
	-- 		require "ui/bigMap/bossInfo"
	-- 		ui_ = UI_bossInfo.new(self.bossInfo_)
	-- 		self:addModalUI(ui_)
	-- 	end
	-- end

	-- 关闭（过时）
	-- local function onCloseTouched(sender, eventType)
	-- 	hp.uiHelper.btnImgTouched(sender, eventType)
	-- 	if eventType == TOUCH_EVENT_ENDED then			
	-- 		self:close()
	-- 	end
	-- end

	self.onAttackTouched = onAttackTouched
	-- self.onInfoTouched = onInfoTouched
	-- self.onCloseTouched = onCloseTouched
end

function UI_boss:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bossInfo.json")

	local content = self.wigetRoot:getChildByName("Panel_content")
	local percent = hp.common.round(self.tileInfo.objInfo.life / self.bossInfo_.maxLife * 100)
	-- base info
	content:getChildByName("Label_hp"):setString(percent .. "%")
	content:getChildByName("Label_name"):setString(self.bossInfo_.name)
	content:getChildByName("Label_power"):setString(hp.lang.getStrByID(7903) .. self.bossInfo_.power)
	content:getChildByName("Label_desc"):setString(self.bossInfo_.desc)
	content:getChildByName("Label_info1"):setString(hp.lang.getStrByID(7904))
	content:getChildByName("Label_info2"):setString(hp.lang.getStrByID(7905))
	content:getChildByName("Label_fight"):setString(hp.lang.getStrByID(7906))
	content:getChildByName("Label_cost"):setString(string.format(hp.lang.getStrByID(7907), self.bossInfo_.bodyForce))
	content:getChildByName("Label_tips"):setString(hp.lang.getStrByID(8030))
	-- image info
	content:getChildByName("Image_icon"):loadTexture(config.dirUI.bossHead .. self.bossInfo_.headPic)
	content:getChildByName("ProgressBar_hp"):setPercent(percent)
	-- 必得道具
	content:getChildByName("Image_box1Icon"):loadTexture(config.dirUI.item .. self.bossInfo_.killProp .. ".png")
	content:getChildByName("Image_box2Icon"):loadTexture(config.dirUI.unionGift .. self.bossInfo_.leagueGift .. ".png")
	-- 随机道具
	content:getChildByName("Image_box3Icon"):loadTexture(config.dirUI.item .. self.bossInfo_.ambit50[2] .. ".png")
	content:getChildByName("Image_box4Icon"):loadTexture(config.dirUI.item .. self.bossInfo_.ambit80[3] .. ".png")
	-- 战斗
	-- 是否为同一服务器
	if player.serverMgr.isMyPosServer(self.tileInfo.position.kx, self.tileInfo.position.ky) then
		content:getChildByName("Image_fight"):addTouchEventListener(self.onAttackTouched)
	else
		content:getChildByName("Image_fight"):loadTexture(config.dirUI.common .. "button_gray.png")
	end
end