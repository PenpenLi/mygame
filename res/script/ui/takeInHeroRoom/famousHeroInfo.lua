--
-- ui/takeInHeroRoom/famousHeroInfo.lua
-- 武将信息
--===================================
require "ui/fullScreenFrame"


UI_famousHeroInfo = class("UI_famousHeroInfo", UI)


--init
function UI_famousHeroInfo:init(heroInfo_,param)
	-- data
	-- ===============================
	local heroInfo=heroInfo_
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new(true)
	--uiFrame:setTitle(hp.lang.getStrByID(2500))
	uiFrame:setTitle("")
	uiFrame:hideTopShade()

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "famousHeroInfo.json")
	local positionPanel = widgetRoot:getChildByName("Panel_position")
	local adampt = widgetRoot:getChildByName("Panel_adampt")
	local skillPanel = widgetRoot:getChildByName("Panel_skill")
	local skillInfoFramePanel = widgetRoot:getChildByName("Panel_skillInfo_frame")
	local skillInfoPanel = widgetRoot:getChildByName("Panel_skillInfo")
	skillInfoFramePanel:setVisible(false)
	skillInfoPanel:setVisible(false)
	if param ~= nil then
		positionPanel:getChildByName("Label_position"):setString(param)
	else
		positionPanel:setVisible(false)
	end
	local attrsListView=skillInfoPanel:getChildByName("Image_info"):getChildByName("ListView_attrs")
	local attrDemo=attrsListView:getChildByName("Label_attr")
	self.attrDemo=attrDemo
	attrDemo:retain()


	local skillDemo = widgetRoot:getChildByName("Panel_skill_demo")
	
	--header
	local headerFrame = adampt:getChildByName("ImageView_Frame")

	-- 整体大背景
	if heroInfo.sex == 1 then
		local bg=widgetRoot:getChildByName("Panel_bg"):getChildByName("ImageView_background")
		bg:loadTexture(config.dirUI.common .."ui_hero_back1.png")
	end

	local heroIcon = widgetRoot:getChildByName("ListView_hero"):getItem(0):getChildByName("Panel_cont"):getChildByName("ImageView_hero")
	heroIcon:loadTexture(config.dirUI.hero .. heroInfo.sid..".png")

	headerFrame:getChildByName("Label_name"):setString(string.format(hp.lang.getStrByID(6019), heroInfo.name))
	headerFrame:getChildByName("Label_land"):setString(string.format(hp.lang.getStrByID(6020), hp.lang.getStrByID(heroInfo.land)))
	

	--点击技能图标
	function onBtnSkillIconTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			skillInfoFramePanel:setVisible(true)
			skillInfoPanel:setVisible(true)
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
	function setSkillIcon()
		--skillPanel:removeAllItems()
		local skillSize = skillDemo:getSize()
		local skillWidth = skillSize.width
		for k,v in pairs(heroInfo.flair) do
			if v>0 then
				local specialSkill=hp.gameDataLoader.getInfoBySid("spSkill", v)
				if specialSkill ~= nil then
					local node=skillDemo:clone()
					node:setTag(heroInfo.flairLv[k])
					node:setPosition((k-1)*(skillWidth+20)+5, 0)
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
	function onBtnCloseSkillTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			skillInfoFramePanel:setVisible(false)
			skillInfoPanel:setVisible(false)
		end
	end
	
	skillInfoFramePanel:getChildByName("ImageView_base"):getChildByName("ImageView_close"):addTouchEventListener(onBtnCloseSkillTouched)


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)
end

--onRemove
function UI_famousHeroInfo:onRemove()
	-- must release
	self.attrDemo:release()
	self.super.onRemove(self)
end