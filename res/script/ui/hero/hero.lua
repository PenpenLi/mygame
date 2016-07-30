--
-- ui/hero/hero.lua
-- 武将信息
--===================================
require "ui/fullScreenFrame"


UI_hero = class("UI_hero", UI)


--init
function UI_hero:init(hero_)
	-- data
	-- ===============================
	local equipTypes = {2,1,3,4,5,4,4}
	local lv = player.getLv()
	local exp = player.getExp()
	local lvConstInfo = nil

	local heroInfo = hero_.getBaseInfo()
	local constInfo = hero_.getConstInfo()
	local skillList = hero_.getSkillList()

	-- function
	-- ===============================
	local downEquip
	
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:setTitle("")
	uiFrame:hideTopShade()
	--uiFrame:hideBottomShade()

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "hero.json")
	local adampt = widgetRoot:getChildByName("Panel_adampt")
	local heroPanel = widgetRoot:getChildByName("Panel_hero")
	local bagDemo = widgetRoot:getChildByName("Panel_bag"):getChildByName("Image_bg")
	local skillPanel = widgetRoot:getChildByName("Panel_skill")
	local skillInfoPanel = widgetRoot:getChildByName("Panel_skillInfo")
	skillInfoPanel:setVisible(false)
	local attrsListView=skillInfoPanel:getChildByName("Image_info"):getChildByName("ListView_attrs")
	local attrDemo=attrsListView:getChildByName("Label_attr")
	self.attrDemo=attrDemo
	attrDemo:retain()
	local skillInfoFramePanel = widgetRoot:getChildByName("Panel_skillInfo_frame")
	skillInfoFramePanel:setVisible(false)
	--第三个饰品解锁按钮(铁匠铺21级解锁)
	local lockImage=adampt:getChildByName("ImageView_lock")
	-- 点击锁按钮
	local function onLockBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			-- 提示21级铁匠铺解锁
			require("ui/msgBox/msgBox")
			local msgBox = UI_msgBox.new(hp.lang.getStrByID(1191), 
					hp.lang.getStrByID(2915),
					hp.lang.getStrByID(5200))
			self:addModalUI(msgBox)
		end
	end
	
	if player.buildingMgr.getBuildingMaxLvBySid(1011)>=21 then
		lockImage:setVisible(false)
	else
		lockImage:addTouchEventListener(onLockBtnTouched)
	end

	local skillDemo = widgetRoot:getChildByName("Panel_skill_demo")
	
	--header
	local headerFrame = widgetRoot:getChildByName("Panel_head")

	-- 整体大背景
	if constInfo.sex == 1 then
		local bg=widgetRoot:getChildByName("Panel_bg"):getChildByName("ImageView_background")
		bg:loadTexture(config.dirUI.common .."ui_hero_back1.png")
	end

	local heroIcon = widgetRoot:getChildByName("ListView_hero"):getItem(0):getChildByName("Panel_cont"):getChildByName("ImageView_hero")
	heroIcon:loadTexture(config.dirUI.hero .. heroInfo.sid..".png")

	headerFrame:getChildByName("Label_name"):setString(heroInfo.name)
	headerFrame:getChildByName("Label_promote"):setString(hp.lang.getStrByID(2501))
	local heroUpBtn = headerFrame:getChildByName("ImageView_promote")
	local function onUpBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/commonItem")
			local ui = UI_commonItem.new(20100,hp.lang.getStrByID(2508))
			self:addUI(ui)
		end
	end
	heroUpBtn:addTouchEventListener(onUpBtnTouched)

		-- 设置装备信息
	local function setEquipInfo(equipIndex,equip)
		local bagNode = adampt:getChildByName("bagNode_"..equipIndex)
		if bagNode ~= nil then
			adampt:removeChild(bagNode)
		end
		local eqbtn = adampt:getChildByName("ImageView_equip"..equipIndex)
		local equipBg = adampt:getChildByName("ImageView_equip"..equipIndex.."_0")
		equipBg:setVisible(false)
		bagNode = bagDemo:clone()
		local equipNode = bagNode:getChildByName("Panel_equip")
		--if equipIndex%2==0 then
				bagNode:setAnchorPoint(0.5,0.5)
		--end
		bagNode:setPosition(eqbtn:getPosition())
		adampt:addChild(bagNode, 99)
		bagNode:setName("bagNode_"..equipIndex)
		if equipIndex==7 then
			--缩放（第三个饰品栏）
			bagNode:setScale(0.63)
		end
		--local colorBg = bagNode:getChildByName("Image_bg")
		local equipImg = bagNode:getChildByName("Image_equip")
		bagNode:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, equip.lv))
		equipImg:loadTexture(string.format("%s%d.png", config.dirUI.equip, equip.sid))
		equipImg:setTag(equip.id)
		for i,v in ipairs(equip.gems) do
			if v>0 then
				local gemImg = equipNode:getChildByName("Image_gem" .. i)
				gemImg:setVisible(true)
				local gemInfo = hp.gameDataLoader.getInfoBySid("gem", v)
				gemImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, gemInfo.type))
			else
				equipNode:getChildByName("Image_gem" .. i):setVisible(false)
			end
		end
		-- 限时装备隐藏宝石框
		local equipInfo = hp.gameDataLoader.getInfoBySid("equip", equip.sid)
		if equipInfo~=nil and equipInfo.overTime[1]>0 then
			equipNode:getChildByName("Image_gembg1"):setVisible(false)
		end
	end

	-- 刷新装备信息
	local function refreshEquipInfo(equipIndex)
		if equipIndex ~= nil then
			local upEquips = player.equipBag.getEquips_equiped()
			--local eq=player.equipBag.getEquipById(upEquips[equipIndex])
			local eq=upEquips[equipIndex]
			if eq==nil then
				downEquip(equipIndex)
			else
				setEquipInfo(equipIndex,eq)
			end
		end
	end
	-- 前往铁匠铺
	local function gotoSmith()
		local building=player.buildingMgr.getBuildingObjBySid(1011)
		if building ~= nil then
			building:onClicked()
		else
			require "ui/common/noBuildingNotice"
			local ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(2913), 1011, 1)
			self:addModalUI(ui_)
		end
	end

	-- 装备按钮

	local function onEqBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			-- 检查是否有对应类型的装备
			local equipIndex = sender:getTag()
			local equipType = equipTypes[equipIndex]

			local equipBag = player.equipBag
			local equips = equipBag.getEquipsByType(equipType)
			local size = #equips
			if size == 0 then
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(4106), 
					string.format(hp.lang.getStrByID(4107), hp.lang.getStrByID(4100+equipType)),
					hp.lang.getStrByID(2912),nil,gotoSmith
					)
				self:addModalUI(msgBox)
			else
				require "ui/hero/dressEquip"
				local ui  = UI_dressEquip.new(self,equipIndex,equipType)
				self:addUI(ui)
			end
		end
	end

	--穿装备
	local function upEquip(equipIndex,equip)
		setEquipInfo(equipIndex,equip)
	end

	--卸下装备
	function downEquip(equipIndex)
		local bagNode = adampt:getChildByName("bagNode_"..equipIndex)
		if bagNode ~= nil then
			adampt:removeChild(bagNode)
			local equipBg = adampt:getChildByName("ImageView_equip"..equipIndex.."_0")
			equipBg:setVisible(true)
		end
	end

	self.upEquip = upEquip
	self.downEquip = downEquip
	self.refreshEquipInfo = refreshEquipInfo

	local upEquips = player.equipBag.getEquips_equiped()

	for i=1,7  do
		local eqbtn = adampt:getChildByName("ImageView_equip"..i)
		eqbtn:addTouchEventListener(onEqBtnTouched)
		if upEquips[i]~=nil then
			--setEquipInfo(i,player.equipBag.getEquipById(upEquips[i]))
			setEquipInfo(i, upEquips[i])
		end
	end

	require "ui/common/effect.lua"
	local light = nil
	self.light = light
	
	
	-- 功能按钮
	local btnsNode = widgetRoot:getChildByName("Panel_bottom"):getChildByName("ImageView_middle")
	local btnHero = btnsNode:getChildByName("ImageView_hero")
	local btnPoint = btnsNode:getChildByName("ImageView_skillPoint")
	self.light = inLight(btnPoint:getVirtualRenderer(),1)
	btnPoint:addChild(self.light)
	local btnHide = headerFrame:getChildByName("ImageView_hide")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnPoint then
				require "ui/hero/skillTree"
				local ui  = UI_skillTree.new(hero_)
				self:addUI(ui)
			elseif sender==btnHero then
				require "ui/hero/heroBoosts"
				local ui  = UI_heroBoosts.new()
				self:addUI(ui)
			elseif sender==btnHide then
				if adampt:isVisible() then
					adampt:setVisible(false)
					btnHide:getChildByName("Label_hide"):setString(hp.lang.getStrByID(2509))
				else
					adampt:setVisible(true)
					btnHide:getChildByName("Label_hide"):setString(hp.lang.getStrByID(2507))
				end
			end
		end
	end
	btnHero:addTouchEventListener(onBtnTouched)
	btnHero:getChildByName("Label_name"):setString(hp.lang.getStrByID(2502))
	btnPoint:addTouchEventListener(onBtnTouched)
	btnHide:addTouchEventListener(onBtnTouched)
	btnHide:getChildByName("Label_hide"):setString(hp.lang.getStrByID(2507))

	local function setSkillPointNum()
		local pointNum = hero_.getSkillPoint()
		if pointNum > 0 then
			self.light:setVisible(true)
		else
			self.light:setVisible(false)
		end
		
		btnPoint:getChildByName("Label_skillPoint"):setString(string.format(hp.lang.getStrByID(2503), pointNum))
	end
	local function reflushExp()
		exp = player.getExp()
		headerFrame:getChildByName("Label_exp"):setString(string.format("%d/%d", exp, lvConstInfo.exp))
		headerFrame:getChildByName("LoadingBar_LoadingBar"):setPercent(exp*100/lvConstInfo.exp)
	end
	local function reflushLv()
		lv = player.getLv()
		headerFrame:getChildByName("Label_level"):setString(lv)
		for i,v in ipairs(game.data.heroLv) do
			if v.level==lv then
				lvConstInfo = v
				break
			end
		end
		setSkillPointNum()
		reflushExp()
	end
	reflushLv()
	self.reflushLv = reflushLv
	self.reflushExp = reflushExp
	self.setSkillPointNum = setSkillPointNum

	--显示/隐藏技能栏
	local function onBtnSkillVisibleTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if skillPanel:isVisible() then
				skillPanel:setVisible(false)
				--图片旋转
				heroPanel:getChildByName("ImageView_skill_arrow"):setScaleX(-1)
			else
				skillPanel:setVisible(true)
				--图片旋转
				heroPanel:getChildByName("ImageView_skill_arrow"):setScaleX(1)
			end
			
		end
	end

	if constInfo.type == 1 then
		heroPanel:getChildByName("ImageView_skill"):setVisible(false)
		heroPanel:getChildByName("ImageView_skill_arrow"):setVisible(false)
	else
		heroPanel:getChildByName("ImageView_skill"):addTouchEventListener(onBtnSkillVisibleTouched)
	end



	--点击技能图标
	local function onBtnSkillIconTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			skillInfoPanel:setVisible(true)
			skillInfoFramePanel:setVisible(true)
			local specialSkill=hp.gameDataLoader.getInfoBySid("spSkill", sender:getTag())
			skillInfoPanel:getChildByName("Image_info"):getChildByName("Image_icon"):loadTexture(config.dirUI.spSkill .. specialSkill.img)
			skillInfoPanel:getChildByName("Image_info"):getChildByName("Label_name"):setString(specialSkill.name)
			skillInfoPanel:getChildByName("Image_info"):getChildByName("Label_des"):setString(specialSkill.desc)
			attrsListView:removeAllItems()
			if specialSkill.type1>0 then
				local attrNode=self.attrDemo:clone()
				local att=hp.gameDataLoader.getInfoBySid("attr", specialSkill.type1)
				if att ~= nil then
					local value=(specialSkill.value1/100).."%"
					if specialSkill.type1==130 then
						value=specialSkill.value1
					end
					attrNode:setString(att.desc.."    +"..value)
					attrsListView:pushBackCustomItem(attrNode)
				end
			end
			if specialSkill.type2>0 then
				local attrNode=self.attrDemo:clone()
				local att=hp.gameDataLoader.getInfoBySid("attr", specialSkill.type2)
				if att ~= nil then
					local value=(specialSkill.value2/100).."%"
					if specialSkill.type2==130 then
						value=specialSkill.value2
					end
					attrNode:setString(att.desc.."    +"..value)
					attrsListView:pushBackCustomItem(attrNode)
				end
			end
			if specialSkill.type3>0 then
				local attrNode=self.attrDemo:clone()
				local att=hp.gameDataLoader.getInfoBySid("attr", specialSkill.type3)
				if att ~= nil then
					local value=(specialSkill.value3/100).."%"
					if specialSkill.type3==130 then
						value=specialSkill.value3
					end
					attrNode:setString(att.desc.."    +"..value)
					attrsListView:pushBackCustomItem(attrNode)
				end
			end
			local openLv=sender:getParent():getTag()
			skillInfoPanel:getChildByName("Image_info"):getChildByName("Label_open"):setString(string.format(hp.lang.getStrByID(6042), openLv))
		end
	end

	-- 设置技能显示图标
	local function setSkillIcon()
		--skillPanel:removeAllItems()
		local skillSize = skillDemo:getSize()
		local skillWidth = skillSize.width
		for k,v in pairs(constInfo.flair) do
			if v>0 then
				local specialSkill=hp.gameDataLoader.getInfoBySid("spSkill", v)
				if specialSkill ~= nil then
					local node=skillDemo:clone()
					node:setTag(constInfo.flairLv[k])
					node:setPosition((k-1)*(skillWidth+2)+5, 0)
					node:getChildByName("Image_skill"):setTag(specialSkill.sid)
					node:getChildByName("Image_skill"):loadTexture(config.dirUI.spSkill .. specialSkill.img)
					node:getChildByName("Image_skill"):addTouchEventListener(onBtnSkillIconTouched)
					skillPanel:addChild(node)
				end
			end
		end
	end
	setSkillIcon()

	--关闭技能信息显示
	local function onBtnCloseSkillTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			skillInfoPanel:setVisible(false)
			skillInfoFramePanel:setVisible(false)
		end
	end
	skillInfoFramePanel:getChildByName("ImageView_base"):getChildByName("ImageView_close"):addTouchEventListener(onBtnCloseSkillTouched)


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)


	self:registMsg(hp.MSG.SKILL_CHANGED)
	self:registMsg(hp.MSG.LV_CHANGED)
	self:registMsg(hp.MSG.EXP_CHANGED)
end

function UI_hero:onMsg(msg_, param_)
	if msg_==hp.MSG.SKILL_CHANGED then
		self.setSkillPointNum()
	elseif msg_==hp.MSG.LV_CHANGED then
		self.reflushLv()
	elseif msg_==hp.MSG.EXP_CHANGED then
		self.reflushExp()
	end
end

--onRemove
function UI_hero:onRemove()
	-- must release
	self.attrDemo:release()
	self.super.onRemove(self)
end