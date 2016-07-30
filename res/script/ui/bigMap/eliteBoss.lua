--
-- ui/bigMap/eliteBoss.lua
-- 精英boss点击弹出界面 
--===================================
require "ui/frame/popFrame"
require "ui/msgBox/msgBox"

UI_eliteBoss = class("UI_eliteBoss", UI)


-- init
function UI_eliteBoss:init(titleInfo_)
	-- data
	-- ===============================
	self.tileInfo = titleInfo_
	self.bossInfo_ = hp.gameDataLoader.getInfoBySid("newBoss", titleInfo_.objInfo.sid)
	-- ui
	-- ===============================
	self:initCallBack()
	self:initUI()
	-- addCCNode
	-- ===============================
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(11617))
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_eliteBoss:initCallBack()

	local function onAttackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function attck()
				if player.getAlliance():getUnionID() == 0 then				
					require "ui/common/successBox"
					local ui_ = UI_successBox.new(hp.lang.getStrByID(1259), hp.lang.getStrByID(1258))
					self:addModalUI(ui_)
				else
					require "ui/bigMap/war/rally"
					local ui_ = UI_rally.new(self.tileInfo.position)
					self:addModalUI(ui_)
				end
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

	self.onAttackTouched = onAttackTouched
end

function UI_eliteBoss:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "eliteBossInfo.json")

	local content = self.wigetRoot:getChildByName("Panel_content")
	local percent = hp.common.round(self.tileInfo.objInfo.life / self.bossInfo_.maxLife * 100)
	-- 基础信息
	content:getChildByName("Label_hp"):setString(percent .. "%")
	content:getChildByName("Label_name"):setString(self.bossInfo_.shortName)
	content:getChildByName("Label_power"):setString(hp.lang.getStrByID(7903) .. self.bossInfo_.power)
	content:getChildByName("Label_desc"):setString(self.bossInfo_.desc)
	content:getChildByName("Label_info1"):setString(hp.lang.getStrByID(11703))
	content:getChildByName("Label_info2"):setString(hp.lang.getStrByID(11701))
	content:getChildByName("Image_icon"):loadTexture(config.dirUI.bossHead .. self.bossInfo_.headPic)
	content:getChildByName("ProgressBar_hp"):setPercent(percent)
	-- 掉落材料信息
	for i = 1, #self.bossInfo_.propSids do
		local materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", self.bossInfo_.propSids[i])
		local icon = content:getChildByName("Image_box" .. i .. "Icon")
		icon:loadTexture(config.dirUI.material .. materialInfo.type .. ".png")
		if i == 4 then
			icon:setVisible(true)
		end
	end
	-- 联盟礼包
	content:getChildByName("Image_box5Icon"):loadTexture(config.dirUI.unionGift .. self.bossInfo_.leagueGift .. ".png")
	-- 战斗
	local fight_btn = content:getChildByName("Image_fight")
	fight_btn:getChildByName("Label_fight"):setString(hp.lang.getStrByID(11702))
	fight_btn:getChildByName("Label_cost"):setString(string.format(hp.lang.getStrByID(7907), self.bossInfo_.bodyForce))
	content:getChildByName("Label_tips"):setString(hp.lang.getStrByID(8030))
	-- 是否为同一服务器
	if player.serverMgr.isMyPosServer(self.tileInfo.position.kx, self.tileInfo.position.ky) then
		fight_btn:addTouchEventListener(self.onAttackTouched)
	else
		fight_btn:loadTexture(config.dirUI.common .. "button_gray.png")
	end
end