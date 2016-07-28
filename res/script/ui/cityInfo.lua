--
-- ui/cityInfo.lua
-- 城内信息
--===================================
require "ui/UI"


UI_cityInfo = class("UI_cityInfo", UI)


--init
function UI_cityInfo:init()
	-- data
	-- ===============================
	self.cdItems = {}
	local cdItems = self.cdItems
	local isFolded = true


	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "cityInfo.json")


	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)


	--英雄头像、vip、权力值
	local infoNode = widgetRoot:getChildByName("Panel_headInfo")
	local heroHead = infoNode:getChildByName("ImageView_head")
	local heroFrame = heroHead:getChildByName("ImageView_photoFrame")
	local heroExpPro = heroFrame:getChildByName("LoadingBar_exp")
	local heroLv = heroFrame:getChildByName("Label_lv")
	local vipBtn = heroHead:getChildByName("Image_vip")
	local vipLabel = vipBtn:getChildByName("Label_lv")
	local powerLabel = infoNode:getChildByName("ImageView_powerBg"):getChildByName("BitmapLabel_num")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==heroHead then
				require "ui/hero/hero"
				local ui  = UI_hero.new(player.hero)
				self:addUI(ui)
			elseif sender==vipBtn then
				require "ui/vip/vip"
				local ui  = UI_vip.new()
				self:addUI(ui)
			end
		end
	end
	heroHead:addTouchEventListener(onBtnTouched)
	vipBtn:addTouchEventListener(onBtnTouched)
	local function setHeroLv()
		local lv = player.getLv()
		local exp = player.getExp()
		local heroConstInfo = nil
		local pointCount = 0
		for i,v in ipairs(game.data.heroLv) do
			if v.level==lv then
				heroConstInfo = v
				break
			end
		end
		if heroConstInfo~=nil then
			heroExpPro:setPercent(exp*100/heroConstInfo.exp)
		else
			heroExpPro:setPercent(100)
		end
		heroLv:setString(lv)
	end
	local function setVipLv()
		vipLabel:setString("VIP" .. player.vipStatus.getLv())
	end
	local function setVipState()
		if player.vipStatus.isActive() then
			vipBtn:loadTexture(config.dirUI.common .. "main_vip_btn.png")
		else
			vipBtn:loadTexture(config.dirUI.common .. "main_vip_btn_inactive.png")
		end
	end
	local function setPower()
		powerLabel:setString(player.getPower())
	end
	local function setHeadIcon()
		heroHead:loadTexture(config.dirUI.heroHeadpic .. player.hero.getBaseInfo().sid..".png")
	end
	setHeroLv()
	setVipLv()
	setVipState()
	setPower()
	setHeadIcon()
	self.setVipState = setVipState
	self.setVipLv = setVipLv
	self.setHeroLv = setHeroLv
	self.setPower = setPower
	self.setHeadIcon = setHeadIcon
	
	-- 资源
	-- rock
	local goldItem = infoNode:getChildByName("ImageView_gold")
	self.goldNode = goldItem:getChildByName("Label_num")
	self.goldNode:setString(player.getResourceShow("gold"))
	-- rock
	local rockItem = infoNode:getChildByName("ImageView_rock")
	self.rockNode = rockItem:getChildByName("Label_num")
	self.rockNode:setString(player.getResourceShow("rock"))
	-- wood
	local woodItem = infoNode:getChildByName("ImageView_wood")
	self.woodNode = woodItem:getChildByName("Label_num")
	self.woodNode:setString(player.getResourceShow("wood"))
	-- mine
	local mineItem = infoNode:getChildByName("ImageView_mine")
	self.mineNode = mineItem:getChildByName("Label_num")
	self.mineNode:setString(player.getResourceShow("mine"))
	-- food
	local foodItem = infoNode:getChildByName("ImageView_food")
	self.foodNode = foodItem:getChildByName("Label_num")
	self.foodNode:setString(player.getResourceShow("food"))
	-- silver
	local silverItem = infoNode:getChildByName("ImageView_silver")
	self.silverNode = silverItem:getChildByName("Label_num")
	self.silverNode:setString(player.getResourceShow("silver"))

	local function onResItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/item/resourceItem"
			local ui  = UI_resourceItem.new(sender:getTag())
			self:addUI(ui)
		end
	end
	rockItem:addTouchEventListener(onResItemTouched)
	woodItem:addTouchEventListener(onResItemTouched)
	mineItem:addTouchEventListener(onResItemTouched)
	foodItem:addTouchEventListener(onResItemTouched)
	silverItem:addTouchEventListener(onResItemTouched)

	-- 跳动宝箱
	--====================
	local contPanel = widgetRoot:getChildByName("Panel_cont")
	-- 在线礼包
	local onlineBox = contPanel:getChildByName("Image_goldenBox")
	local onlineBoxBg = contPanel:getChildByName("Image_goldenBox_bg")
	local onlineBoxCD = onlineBoxBg:getChildByName("Label_text")
	local onlineBox_px, onlineBox_py = onlineBox:getPosition()
	local function setOnlineBoxInfo()
		if player.onlineGift.getItemSid()<=0 then
		-- 没有礼包
			onlineBox:setVisible(false)
			onlineBoxBg:setVisible(false)
			onlineBox:setTouchEnabled(false)
		else
			onlineBox:setVisible(true)
			onlineBox:setTouchEnabled(true)
			local cd = player.onlineGift.getCD()
			if cd<=0 then
				onlineBoxBg:setVisible(false)
				local jump1 = cc.JumpBy:create(1.0, cc.p(0, 0), 40*hp.uiHelper.RA_scale, 1)
				onlineBox:runAction(cc.RepeatForever:create(jump1))
			else
				onlineBoxBg:setVisible(true)
				onlineBoxCD:setString(hp.datetime.strTime(cd))
				onlineBox:stopAllActions()
				onlineBox:setPosition(onlineBox_px, onlineBox_py)
			end
		end
	end
	local function refreshOnlineBoxCD()
		local cd = player.onlineGift.getCD()
		if cd>0 then
			onlineBoxCD:setString(hp.datetime.strTime(cd))
		end
	end
	setOnlineBoxInfo()
	self.setOnlineBoxInfo = setOnlineBoxInfo
	self.refreshOnlineBoxCD = refreshOnlineBoxCD
	local function onOnlineBoxTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/cityMap/onlineGift"
			local ui = UI_onlineGift.new()
			self:addModalUI(ui)
		end
	end
	onlineBox:addTouchEventListener(onOnlineBoxTouched)

	-- 免费钻石
	--====================
	local freeGoldBg_= contPanel:getChildByName("Image_freeGold_bg")
	freeGoldBg_:setVisible(false)
	local function freeGoldPop()
		if player.getFristLeague() == 0 then
			freeGoldBg_:setVisible(true)
			local diamond_ = freeGoldBg_:getChildByName("Image_freeGold")
			local label_ = freeGoldBg_:getChildByName("Label_text")
			label_:setString(hp.lang.getStrByID(6018))

			-- add animation
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(config.dirUI.animation.."diamond.ExportJson")
			local amature_ = ccs.Armature:create("diamond")
			amature_:getAnimation():play("aniDiamond")
			local x_, y_ = diamond_:getPosition()
			local sz_ = diamond_:getSize()
			amature_:setPosition(sz_.width / 2, sz_.height / 2)
			diamond_:addChild(amature_)

			local function onOperTouched(sender, eventType)
				hp.uiHelper.btnImgTouched(sender, eventType)
				if eventType==TOUCH_EVENT_ENDED then
					require "ui/guide/joinUnion"
					ui_ = UI_unionJoinDiamond.new()
					self:addModalUI(ui_)
				end
			end
			diamond_:addTouchEventListener(onOperTouched)
		end		
	end
	self.freeGoldBg_ = freeGoldBg_
	self.freeGoldPop = freeGoldPop

	if player.guide.isFinished() == true then
		freeGoldPop()
	end

	-- 公会任务指引
	--====================
	local function onFightTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/fight/unionFightMain"
			ui_ = UI_unionFightMain.new()
			self:addUI(ui_)
		end
	end
	local unionFight = contPanel:getChildByName("Image_6")
	local unionFightNumBg = unionFight:getChildByName("Image_9")
	local unionFightText = unionFightNumBg:getChildByName("Label_10")
	unionFight:getChildByName("Image_7"):addTouchEventListener(onFightTouched)

	-- 公会帮助提示
	--====================
	local function onHelpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/mainFunc/unionHelp"
			ui_ = UI_unionHelp.new()
			self:addUI(ui_)
		end
	end
	local unionhelp = contPanel:getChildByName("Image_6_0")
	local unionHelpText = unionhelp:getChildByName("Image_9"):getChildByName("Label_10")
	unionhelp:getChildByName("Image_7"):addTouchEventListener(onHelpTouched)


	local function updateHelpIcon()
		local info_ = player.getAlliance():getUnionHomePageInfo()
		print("info_.helpinfo_.helpinfo_.helpinfo_.helpinfo_.helpinfo_.helpinfo_.helpinfo_.help",info_.help)
		if info_.help == nil then
			return
		end

		if info_.help > 0 then
			unionhelp:setVisible(true)
			unionhelp:setTouchEnabled(true)
			unionHelpText:setString(info_.help)
		else
			unionhelp:setVisible(false)
			unionhelp:setTouchEnabled(false)
		end
	end
	self.updateHelpIcon = updateHelpIcon

	local function updateFightIcon()
		local info_ = player.getAlliance():getUnionHomePageInfo()

		if info_.joinAble == nil then
			return
		end

		local totalJoinAble_ = 0
		if info_.joinTimes > 0 then
			totalJoinAble_ = info_.joinAble + info_.battle
		else
			totalJoinAble_ = info_.battle
		end

		if totalJoinAble_ > 0 then -- 可以加入的小型作战
			unionFight:setVisible(true)
			unionFight:setTouchEnabled(true)
			unionFightNumBg:setVisible(true)
			unionFightText:setString(totalJoinAble_)
		else
			if info_.createTimes > 0 then
				unionFight:setVisible(true)
				unionFight:setTouchEnabled(true)
				unionFightNumBg:setVisible(false)
			else
				local bigCreatable_ = false
				if player.getAlliance():getMyUnionInfo():getRank() >= 4 then
					bigCreatable_ = true
				end
				unionFight:setVisible(bigCreatable_)
				unionFightNumBg:setVisible(false)
				unionFight:setTouchEnabled(bigCreatable_)
			end
		end
	end
	self.updateFightIcon = updateFightIcon

	updateHelpIcon()
	updateFightIcon()

	-- 主界面主线任务
	--====================
	local function updateMainQuest()
		local id_ = player.getDoingMainQuestInfo()
		local info_ = hp.gameDataLoader.getInfoBySid("quests", id_)

		local back_ = contPanel:getChildByName("Image_11")
		if info_ == nil then
			back_:setVisible(false)
		else
			back_:getChildByName("Label_12"):setString(info_.text)
		end
	end
	self.updateMainQuest = updateMainQuest
	updateMainQuest()

	-- registMsg
	self:registMsg(hp.MSG.RESOURCE_CHANGED)
	self:registMsg(hp.MSG.VIP)
	self:registMsg(hp.MSG.ONLINE_GIFT)
	self:registMsg(hp.MSG.LV_CHANGED)
	self:registMsg(hp.MSG.EXP_CHANGED)
	self:registMsg(hp.MSG.POWER_CHANGED)
	self:registMsg(hp.MSG.HERO_INFO_CHANGE)
	self:registMsg(hp.MSG.UNION_JOIN_SUCCESS)
	self:registMsg(hp.MSG.GUIDE_OVER)
	self:registMsg(hp.MSG.UNION_DATA_PREPARED)
	self:registMsg(hp.MSG.MISSION_MAIN_REFRESH)
	self:registMsg(hp.MSG.MISSION_MAIN_STATUS_CHANGE)
	self:registMsg(hp.MSG.HERO_LV_UP)
end

-- onMsg
function UI_cityInfo:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED then
		if paramInfo_.name=="gold" then
			-- self.goldNode:setString(hp.common.changeNumUnit(paramInfo_.num))
		elseif paramInfo_.name=="rock" then
			self.rockNode:setString(hp.common.changeNumUnit(paramInfo_.num))
		elseif paramInfo_.name=="wood" then
			self.woodNode:setString(hp.common.changeNumUnit(paramInfo_.num))
		elseif paramInfo_.name=="mine" then
			self.mineNode:setString(hp.common.changeNumUnit(paramInfo_.num))
		elseif paramInfo_.name=="food" then
			self.foodNode:setString(hp.common.changeNumUnit(paramInfo_.num))
		elseif paramInfo_.name=="silver" then
			self.silverNode:setString(hp.common.changeNumUnit(paramInfo_.num))
		end
	elseif msg_==hp.MSG.VIP then
		if paramInfo_==1 then
			self.setVipLv()
		elseif paramInfo_==3 then
			self.setVipState()
		end
	elseif msg_==hp.MSG.ONLINE_GIFT then
		self.setOnlineBoxInfo()
	elseif msg_==hp.MSG.LV_CHANGED then
		self.setHeroLv()
	elseif msg_==hp.MSG.EXP_CHANGED then
		self.setHeroLv()
	elseif msg_==hp.MSG.POWER_CHANGED then
		self.setPower()
	elseif msg_==hp.MSG.HERO_INFO_CHANGE then
		self.setHeadIcon()
	elseif msg_==hp.MSG.UNION_JOIN_SUCCESS then
		if player.getFristLeague() == 0 then
			if self.freeGoldBg_ ~= nil then
				self.freeGoldBg_:setVisible(false)
			end
		end
	elseif msg_==hp.MSG.GUIDE_OVER then
		self.freeGoldPop()
	elseif msg_ == hp.MSG.UNION_DATA_PREPARED then
		if paramInfo_ == dirtyType.VARIABLENUM then
			self.updateHelpIcon()
			self.updateFightIcon()
		end
	elseif msg_ == hp.MSG.MISSION_MAIN_REFRESH then
		if paramInfo_ == 1 then
			self.updateMainQuest()
		end
	elseif msg_ == hp.MSG.MISSION_MAIN_STATUS_CHANGE then
		if paramInfo_ == 1 then
			self.updateMainQuest()
		end
	elseif msg_ == hp.MSG.HERO_LV_UP then
		require "ui/hero/heroLevelup"
		local ui  = UI_heroLevelup.new()
		self:addModalUI(ui)
	end
end

function UI_cityInfo:heartbeat(dt)
	self.refreshOnlineBoxCD()
end