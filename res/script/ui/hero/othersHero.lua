--
-- ui/hero/othersHero.lua
-- 武将信息
--===================================
require "ui/fullScreenFrame"


UI_othersHero = class("UI_othersHero", UI)

local heroInfo
local equipInfo
local lv

-- init
function UI_othersHero:init(heroInfo_, equipInfo_, lv_)

	heroInfo = heroInfo_
	equipInfo = equipInfo_
	lv = lv_

	self:initTouchEvent()
	self:initUI()
end

function UI_othersHero:initTouchEvent()
	-- 开启关闭技能栏
	local function onSkillsTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local isVisible = self.panel_skills:isVisible()

			local arrow = self.panel_hero:getChildByName("ImageView_skill_arrow")
			if isVisible then
				arrow:setScaleX(1)
				self.panel_skillInfo:setVisible(false)
				self.frame_skillInfo:setVisible(false)
			else
				arrow:setScaleX(-1)
			end

			self.panel_skills:setVisible(not isVisible)
		end
	end
	self.onSkillsTouched = onSkillsTouched

	-- 查看技能属性
	local function onShowSkillInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then

			local skill_info = hp.gameDataLoader.getInfoBySid("spSkill", sender:getTag())

			local content = self.panel_skillInfo:getChildByName("Image_info")
			content:getChildByName("Image_icon"):loadTexture(config.dirUI.spSkill .. skill_info.img)
			content:getChildByName("Label_name"):setString(skill_info.name)
			content:getChildByName("Label_des"):setString(skill_info.desc)
			content:getChildByName("Label_open"):setString(string.format(hp.lang.getStrByID(6042), sender:getParent():getTag()))
			
			local skill_infoTbl = {}
			if skill_info.type1 ~= -1 then
				local info = hp.gameDataLoader.getInfoBySid("attr", skill_info.type1).desc .. "+" .. skill_info.value1/100 .. "%"
				table.insert(skill_infoTbl, info)
			end
			if skill_info.type2 ~= -1 then
				local info = hp.gameDataLoader.getInfoBySid("attr", skill_info.type2).desc .. "+" .. skill_info.value2/100 .. "%"
				table.insert(skill_infoTbl, info)
			end
			if skill_info.type3 ~= -1 then
				local info = hp.gameDataLoader.getInfoBySid("attr", skill_info.type3).desc .. "+" .. skill_info.value3/100 .. "%"
				table.insert(skill_infoTbl, info)
			end

			local skill_list = content:getChildByName("ListView_attrs")
			local baseItem = skill_list:getItem(0):clone()

			for i = 2, #skill_list:getItems() do
				skill_list:removeItem(1)
			end

			for i,v in ipairs(skill_infoTbl) do
				local item
				if i == 1 then
					item = skill_list:getItem(0)
				elseif i == #skill_infoTbl then
					item = baseItem
					skill_list:pushBackCustomItem(item)
				else
					item = baseItem:clone()
					skill_list:pushBackCustomItem(item)
				end
				item:setString(v)
			end

			self.panel_skillInfo:setVisible(true)
			self.frame_skillInfo:setVisible(true)
		end
	end
	self.onShowSkillInfoTouched = onShowSkillInfoTouched

	-- 关闭技能属性
	local function onCloseSkillInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self.panel_skillInfo:setVisible(false)
			self.frame_skillInfo:setVisible(false)
		end
	end
	self.onCloseSkillInfoTouched = onCloseSkillInfoTouched

	-- 查看装备
	local function onEquipTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/hero/othersEquip"
			local ui = UI_othersEquip.new(equipInfo[sender:getTag()])
			self:addModalUI(ui)
		end 
	end
	self.onEquipTouched = onEquipTouched

	-- 打开关闭装备栏
	local function onEquipSwitchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local isVisible = self.equipViewTbl[1]:isVisible()
			for i,v in ipairs(self.equipViewTbl) do
				if i % 2 == 0 then
					if #self.equipViewTbl[i-1]:getChildren() == 0 then
						v:setVisible(not isVisible)
					end
				else
					v:setVisible(not isVisible)
				end
			end
		end 
	end
	self.onEquipSwitchTouched = onEquipSwitchTouched
end

function UI_othersHero:initUI()

	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:setTitle("")
	uiFrame:hideTopShade()
	
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "hero.json")

	-- "hero":[4004,"马超",0,0,[],3,"4004",[],0]
	-- 		sid 名字 状态 行军id id 图片 关押者信息 武将死亡后剩余复活时间

	-- 武将数据
	local heroBaseInfo = hp.gameDataLoader.getInfoBySid("hero", heroInfo[1])

	-- 无用信息
	-- =========================
	widget:getChildByName("Panel_bottom"):setVisible(false)

	-- 头部信息
	-- =========================
	local head_panel = widget:getChildByName("Panel_head")
	head_panel:getChildByName("Label_name"):setString(heroInfo[2])
	head_panel:getChildByName("ImageView_promote"):setVisible(false)
	head_panel:getChildByName("Label_promote"):setVisible(false)
	head_panel:getChildByName("ImageView_LoadingBar_bg"):setVisible(false)
	head_panel:getChildByName("LoadingBar_LoadingBar"):setVisible(false)
	head_panel:getChildByName("ImageView_highLight"):setVisible(false)
	head_panel:getChildByName("Label_level"):setString(lv)
	head_panel:getChildByName("Label_exp"):setVisible(false)
	head_panel:getChildByName("ImageView_hide"):addTouchEventListener(self.onEquipSwitchTouched)

	-- 背景
	-- =========================
	if heroBaseInfo.sex == 1 then
		widget:getChildByName("Panel_bg"):getChildByName("ImageView_background"):loadTexture(config.dirUI.common .."ui_hero_back1.png")
	end

	-- 武将图片 465 799
	-- =========================
	widget:getChildByName("ListView_hero"):getItem(0):getChildByName("Panel_cont"):getChildByName("ImageView_hero"):loadTexture(config.dirUI.hero .. heroInfo[1] .. ".png")

	-- 技能框
	-- =========================
	if heroInfo[1] ~= 1001 and heroInfo[1] ~= 1002 then

		local panel_skills = widget:getChildByName("Panel_skill")
		local width = panel_skills:getSize().width
		-- 技能列表
		for i,v in ipairs(heroBaseInfo.flair) do
			local skill_info = hp.gameDataLoader.getInfoBySid("spSkill", v)
			local panel_skill = widget:getChildByName("Panel_skill_demo"):clone()
			panel_skill:setTag(heroBaseInfo.flairLv[i])
			local image_skill = panel_skill:getChildByName("Image_skill")
			image_skill:loadTexture(config.dirUI.spSkill .. skill_info.img)
			image_skill:setTag(v)
			image_skill:addTouchEventListener(self.onShowSkillInfoTouched)
			panel_skills:addChild(panel_skill)
			panel_skill:setPosition(width / 4 * (i - 1), 0)
		end
		self.panel_skills = panel_skills
		self.panel_hero = widget:getChildByName("Panel_hero")
		self.panel_hero:getChildByName("ImageView_skill_arrow"):setScaleX(-1)
		self.panel_hero:getChildByName("ImageView_skill"):addTouchEventListener(self.onSkillsTouched)
	else
		-- 非名将
		widget:getChildByName("Panel_hero"):setVisible(false)
		widget:getChildByName("Panel_skill"):setVisible(false)
		widget:getChildByName("Panel_skillInfo"):setVisible(false)
		widget:getChildByName("Panel_skillInfo_frame"):setVisible(false)
	end

	self.panel_skillInfo = widget:getChildByName("Panel_skillInfo")
	self.frame_skillInfo = widget:getChildByName("Panel_skillInfo_frame")
	self.panel_skillInfo:setVisible(false)
	self.frame_skillInfo:setVisible(false)
	self.frame_skillInfo:getChildByName("ImageView_base"):getChildByName("ImageView_close"):addTouchEventListener(self.onCloseSkillInfoTouched)

	-- "equipN":[ [20002,2,2,[114,154,124]],[10003,1,3,[115,165,124]],[],[],[],[],[] ]
	--		sid, id, lv, (宝石) ......

	-- 装备栏
	-- =========================
	local panel_adampt = widget:getChildByName("Panel_adampt")

	local panel_helmet = panel_adampt:getChildByName("ImageView_equip1")
	local no_helmet = panel_adampt:getChildByName("ImageView_equip1_0")
	local panel_weapon = panel_adampt:getChildByName("ImageView_equip2")
	local no_weapon = panel_adampt:getChildByName("ImageView_equip2_0")
	local panel_armour = panel_adampt:getChildByName("ImageView_equip3")
	local no_armour = panel_adampt:getChildByName("ImageView_equip3_0")
	local panel_jewelry1 = panel_adampt:getChildByName("ImageView_equip4")
	local no_jewelry1 = panel_adampt:getChildByName("ImageView_equip4_0")
	local panel_shoe = panel_adampt:getChildByName("ImageView_equip5")
	local no_shoe = panel_adampt:getChildByName("ImageView_equip5_0")
	local panel_jewelry2 = panel_adampt:getChildByName("ImageView_equip6")
	local no_jewelry2 = panel_adampt:getChildByName("ImageView_equip6_0")
	local panel_jewelry3 = panel_adampt:getChildByName("ImageView_equip7")
	local no_jewelry3 = panel_adampt:getChildByName("ImageView_equip7_0")
	local lock = panel_adampt:getChildByName("ImageView_lock")
	local baseEquipModel = widget:getChildByName("Panel_bag"):clone()

	self.equipViewTbl = {}
	table.insert(self.equipViewTbl, panel_helmet)
	table.insert(self.equipViewTbl, no_helmet)
	table.insert(self.equipViewTbl, panel_weapon)
	table.insert(self.equipViewTbl, no_weapon)
	table.insert(self.equipViewTbl, panel_armour)
	table.insert(self.equipViewTbl, no_armour)
	table.insert(self.equipViewTbl, panel_jewelry1)
	table.insert(self.equipViewTbl, no_jewelry1)
	table.insert(self.equipViewTbl, panel_shoe)
	table.insert(self.equipViewTbl, no_shoe)
	table.insert(self.equipViewTbl, panel_jewelry2)
	table.insert(self.equipViewTbl, no_jewelry2)

	for i,v in ipairs(equipInfo) do
		-- 非空数组
		if #v ~= 0 then
			local equip_info = hp.gameDataLoader.getInfoBySid("equip", v[1])
			local equip_info2 = v[4]
			local equip_model = baseEquipModel:clone()
			equip_model:setPosition(1, 0)

			if equip_info.type == 1 then
				no_weapon:setVisible(false)
				panel_weapon:addChild(equip_model)
			elseif equip_info.type == 2 then
				no_helmet:setVisible(false)
				panel_helmet:addChild(equip_model)
			elseif equip_info.type == 3 then
				no_armour:setVisible(false)
				panel_armour:addChild(equip_model)
			elseif equip_info.type == 4 then
				if i == 4 then
					no_jewelry1:setVisible(false)
					panel_jewelry1:addChild(equip_model)
				elseif i == 6 then
					no_jewelry2:setVisible(false)
					panel_jewelry2:addChild(equip_model)
				elseif i == 7 then
					no_jewelry3:setVisible(false)
					lock:setVisible(false)
					panel_jewelry3:addChild(equip_model)
					equip_model:setScale(1.25)
				end
			elseif equip_info.type == 5 then
				no_shoe:setVisible(false)
				panel_shoe:addChild(equip_model)
			end

			local bg = equip_model:getChildByName("Image_bg")
			bg:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, v[3]+1))
			bg:getChildByName("Image_equip"):loadTexture(config.dirUI.equip .. v[1] .. ".png")
			local gem = bg:getChildByName("Panel_equip")

			gem:getChildByName("Image_gem1"):setVisible(false)
			gem:getChildByName("Image_gem2"):setVisible(false)
			gem:getChildByName("Image_gem3"):setVisible(false)

			for j = 1, #equip_info2 do
				if equip_info2[j] > 0 then
					local gem_info = hp.gameDataLoader.getInfoBySid("gem", equip_info2[j])
					gem:getChildByName("Image_gem" .. j):loadTexture(config.dirUI.gem .. gem_info.type .. ".png")
					gem:getChildByName("Image_gem" .. j):setVisible(true)
				end
			end

			equip_model:getParent():setTag(i)
			equip_model:getParent():addTouchEventListener(self.onEquipTouched)
		end
	end

	self:addChildUI(uiFrame)
	self:addCCNode(widget)
end