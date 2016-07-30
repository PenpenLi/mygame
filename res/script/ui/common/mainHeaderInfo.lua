--
-- ui/common/mainHeaderInfo.lua
-- 城内信息
--===================================
require "ui/UI"


UI_mainHeaderInfo = class("UI_mainHeaderInfo", UI)


--init
function UI_mainHeaderInfo:init()
	-- data
	-- ===============================
	local normalColor = cc.c3b(255, 255, 255)
	local grayColor = cc.c3b(56, 56, 56)

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainHeaderInfo.json")


	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)


	--英雄头像、vip、权力值
	local infoNode = widgetRoot:getChildByName("Panel_headInfo")
	local heroHead = infoNode:getChildByName("ImageView_head")
	local heroState = heroHead:getChildByName("Image_state")
	local heroTime = heroHead:getChildByName("Label_time")
	local heroFrame = heroHead:getChildByName("ImageView_photoFrame")
	local heroExpPro = heroFrame:getChildByName("LoadingBar_exp")
	local heroLv = heroFrame:getChildByName("Label_lv")
	local vipBtn = heroHead:getChildByName("Image_vip")
	local vipLabel = vipBtn:getChildByName("Label_lv")
	local powerLabel = infoNode:getChildByName("ImageView_powerBg"):getChildByName("BitmapLabel_num")
	
	self.heroHeadLight = nil
	self.heroHead = heroHead
	self:heroHeadIsLight()

	
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==heroHead then
				local state=player.hero.getBaseInfo().state
				-- 正常
				if state == 0 then
					require "ui/hero/hero"
					local ui  = UI_hero.new(player.hero)
					self:addUI(ui)
				-- 被关押
				elseif state == 1 then
					require "ui/hero/heroBeCaught"
					local ui  = UI_heroBeCaught.new(player.hero)
					self:addUI(ui)
				-- 已死亡（可复活）
				elseif state == 2 then
					--进入墓地
					local building=game.curScene:getBuildingBySid(1021)
					building:onClicked()
				-- 已死亡（不可复活）
				elseif state == 3 then
					-- 前往招贤馆
					local function gotoHeroRoom()
						local building=game.curScene:getBuildingBySid(1022)
						building:onClicked()
					end	
					require("ui/msgBox/msgBox")
					local msgBox = UI_msgBox.new(hp.lang.getStrByID(2518), 
						hp.lang.getStrByID(2519),hp.lang.getStrByID(2520),
						nil,gotoHeroRoom)
					self:addModalUI(msgBox)
				end
			elseif sender==vipBtn then
				require "ui/vip/vip"
				local ui  = UI_vip.new()
				self:addUI(ui)
			end
		end
	end
	heroHead:addTouchEventListener(onBtnTouched)
	vipBtn:addTouchEventListener(onBtnTouched)

	local heroCurState = -1
	local function setHeroState()
		local heroInfo = player.hero.getBaseInfo()
		if heroCurState==heroInfo.state then
			if heroCurState == 2 then
				--可复活倒计时
				heroTime:setString(hp.datetime.strTime1(heroInfo.reliveLeftTime))
			end
			return
		end
		heroCurState = heroInfo.state
		-- 正常
		if heroCurState == 0 then
			heroState:setVisible(false)
			heroTime:setVisible(false)
			heroHead:setColor(normalColor)
		-- 被关押
		elseif heroCurState == 1 then
			heroState:setVisible(true)
			heroTime:setVisible(false)
			heroState:loadTexture(config.dirUI.common .. "hero_head_prison.png")
			heroHead:setColor(normalColor)
		-- 已死亡（可复活）
		elseif heroCurState == 2 then
			heroState:setVisible(false)
			heroTime:setVisible(true)
			--可复活倒计时
			heroTime:setString(hp.datetime.strTime1(heroInfo.reliveLeftTime))
			heroHead:setColor(normalColor)
		-- 已死亡（不可复活）
		elseif heroCurState == 3 then
			heroState:setVisible(true)
			heroTime:setVisible(false)
			heroState:loadTexture(config.dirUI.common .. "tombstone.png")
			heroHead:setColor(grayColor)
		end
	end

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
		vipLabel:setString(player.vipStatus.getLv())
	end
	local function setVipState()
		if player.vipStatus.isActive() then
			vipBtn:loadTexture(config.dirUI.common .. "main_vip_btn.png")
		else
			vipBtn:loadTexture(config.dirUI.common .. "main_vip_btn_inactive.png")
		end
	end
	powerLabel:setScaleX(powerLabel:getScaleX()*0.9)
	powerLabel:setScaleY(powerLabel:getScaleY()*1.2)
	local function setPower()
		powerLabel:setString(player.getPower())
	end
	local function setHeadIcon()
		heroHead:loadTexture(config.dirUI.heroHeadpic .. player.hero.getBaseInfo().sid..".png")
	end
	setHeroState()
	setHeroLv()
	setVipLv()
	setVipState()
	setPower()
	setHeadIcon()
	self.setHeroState = setHeroState
	self.setVipState = setVipState
	self.setVipLv = setVipLv
	self.setHeroLv = setHeroLv
	self.setPower = setPower
	self.setHeadIcon = setHeadIcon
	
	-- 资源
	-- gold
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
			local ui = UI_resourceItem.new(sender:getTag())
			self:addUI(ui)
		end
	end
	rockItem:addTouchEventListener(onResItemTouched)
	woodItem:addTouchEventListener(onResItemTouched)
	mineItem:addTouchEventListener(onResItemTouched)
	foodItem:addTouchEventListener(onResItemTouched)
	silverItem:addTouchEventListener(onResItemTouched)

	local function onGoldTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/goldShop/goldShop"
			local ui = UI_goldShop.new()
			self:addUI(ui)
		end
	end
	goldItem:addTouchEventListener(onGoldTouched)


	-- registMsg
	self:registMsg(hp.MSG.RESOURCE_CHANGED)
	self:registMsg(hp.MSG.VIP)
	self:registMsg(hp.MSG.LV_CHANGED)
	self:registMsg(hp.MSG.EXP_CHANGED)
	self:registMsg(hp.MSG.POWER_CHANGED)
	self:registMsg(hp.MSG.HERO_INFO_CHANGE)
	self:registMsg(hp.MSG.SKILL_CHANGED)
end

-- onMsg
function UI_mainHeaderInfo:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED then
		if paramInfo_.name=="gold" then
			self.goldNode:setString(hp.common.changeNumUnit1(paramInfo_.num,100000))
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
	elseif msg_==hp.MSG.LV_CHANGED then
		self.setHeroLv()
		self:heroHeadIsLight()
	elseif msg_==hp.MSG.EXP_CHANGED then
		self.setHeroLv()
	elseif msg_==hp.MSG.POWER_CHANGED then
		self.setPower()
	elseif msg_==hp.MSG.HERO_INFO_CHANGE then
		self.setHeadIcon()
		self:heroHeadIsLight()
		self.setHeroState()
	elseif msg_==hp.MSG.SKILL_CHANGED then
		self:heroHeadIsLight()
	end
end

function UI_mainHeaderInfo:heartbeat(dt)
	self.setHeroState()
end

function UI_mainHeaderInfo:heroHeadIsLight()
	local lv = player.getLv()
	local pointCount = 0
	for i,v in ipairs(game.data.heroLv) do
		pointCount = pointCount+v.dit
		if v.level==lv then
			break
		end
	end

	local pointUsed = 0
	local skillList = player.hero.getSkillList()
	for k,v in pairs(skillList) do
		pointUsed = pointUsed+v
	end
	
	local state=player.hero.getBaseInfo().state
	
	if (pointCount - pointUsed > 0) and state == 0 then
		if self.heroHeadLight == nil then
			self.heroHeadLight = hp.uiEffect.innerGlow(self.heroHead, 1)
		end
	else
		if self.heroHeadLight ~= nil then
			self.heroHead:removeChild(self.heroHeadLight)
			self.heroHeadLight = nil
		end
	end 
end
