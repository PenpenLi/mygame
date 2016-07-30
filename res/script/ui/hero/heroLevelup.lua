--
-- ui/hero/heroLevelup.lua
-- 英雄升级界面
--===================================
--require "ui/fullScreenFrame"

UI_heroLevelup = class("UI_heroLevelup", UI)

--init
function UI_heroLevelup:init()
	-- data
	-- ===============================

	-- ui
	-- ===============================

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "heroLevelup.json")

	-- ===============================
	self:addCCNode(widgetRoot)
	
	local heroInfo = player.hero.getBaseInfo()
	local skillList = player.hero.getSkillList()

	local infoPanel = widgetRoot:getChildByName("Panel_info"):getChildByName("ImageView_bg")
	local okBtn = infoPanel:getChildByName("ImageView_ok")
	local skillpointBtn = infoPanel:getChildByName("ImageView_skillpoint")
	
	require "ui/common/effect.lua"
	local light = inLight(skillpointBtn:getVirtualRenderer(),1)
	skillpointBtn:addChild(light)
	
	
	--infoPanel:getChildByName("Label_title"):setString(hp.lang.getStrByID(2510))
	infoPanel:getChildByName("Label_name"):setString(heroInfo.name)
	infoPanel:getChildByName("ListView_hero"):getChildByName("Panel_hero"):getChildByName("Image_hero"):loadTexture(config.dirUI.hero .. heroInfo.sid..".png")

	infoPanel:getChildByName("Label_lev"):setString(string.format(hp.lang.getStrByID(4008),player.getLv()))

	infoPanel:getChildByName("Label_0"):setString(hp.lang.getStrByID(5043))
	infoPanel:getChildByName("Label_1"):setString(hp.lang.getStrByID(2511))

	local pointCount = 0
	local pointUsed = 0

	for i,v in ipairs(game.data.heroLv) do
		pointCount = pointCount+v.dit
		if v.level==player.getLv() then
			infoPanel:getChildByName("Label_power"):setString("+"..v.point)
			infoPanel:getChildByName("Label_skillpoints"):setString("+"..v.dit)
			break
		end
	end
	for k,v in pairs(skillList) do
		pointUsed = pointUsed+v
	end
	skillpointBtn:getChildByName("Label_name"):setString(string.format(hp.lang.getStrByID(2503),pointCount-pointUsed))
	
	--按钮点击
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==okBtn then
				self:close()
			elseif sender==skillpointBtn then
				self:close()
				require "ui/hero/skillTree"
				local ui  = UI_skillTree.new(player.hero)
				self:addUI(ui)
			end	
		end
	end
	
	okBtn:addTouchEventListener(onBtnTouched)
	skillpointBtn:addTouchEventListener(onBtnTouched)
end

