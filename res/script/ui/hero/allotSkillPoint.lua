--
-- ui/hero/allotSkillPoint.lua
-- 科研信息界面
--===================================
require "ui/frame/popFrame"


UI_allotSkillPoint = class("UI_allotSkillPoint", UI)


--init
function UI_allotSkillPoint:init(parent_, skillNode_, hero_, skillId_)
	-- data
	-- ===============================
	local skillInfo = hp.gameDataLoader.getInfoBySid("skill", skillId_)
	local skillLv = 0
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "skillInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, skillInfo.name)


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)


	local contNode = wigetRoot:getChildByName("Panel_cont")
	local btnUp = contNode:getChildByName("ImageView_up")
	contNode:getChildByName("Label_desc"):setString(skillInfo.note)
	btnUp:getChildByName("Label_text"):setString(hp.lang.getStrByID(9203))
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnUp then
				parent_.allotSkillPoint1(skillNode_, 1)
			end
		end
	end
	btnUp:addTouchEventListener(onBtnTouched)

	local function refreshInfo()
		skillLv = hero_.getSkillLv(skillId_)

		local imgNode = contNode:getChildByName("ImageView_research")
		imgNode:loadTexture(config.dirUI.skill .. skillId_ .. ".png")
		imgNode:getChildByName("progress"):setPercent(skillLv*100/skillInfo.maxLv)
		imgNode:getChildByName("desc"):setString(string.format("%d/%d", skillLv, skillInfo.maxLv))

		local curNode = contNode:getChildByName("Image_curLv")
		local nextNode = contNode:getChildByName("Image_nextLv")
		local curNode1 = contNode:getChildByName("Image_curLv1")

		if skillLv>=skillInfo.maxLv then
			--等级已最大，无法再升级
			curNode:setVisible(false)
			nextNode:setVisible(false)
			curNode1:setVisible(true)
			curNode1:getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(9201), skillInfo.value1[skillLv]/100))
			curNode1:getChildByName("Label_fn"):setString(hp.lang.getStrByID(9106))
		else
			curNode1:setVisible(false)
			if skillLv==0 then
				curNode:getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(9201), 0))
			else
				curNode:getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(9201), skillInfo.value1[skillLv]/100))
			end
			nextNode:getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(9202), skillInfo.value1[skillLv+1]/100))
		end

		if skillLv>=skillInfo.maxLv or parent_.pointRemain<=0 or parent_.skillIsLock(skillInfo) then
			btnUp:loadTexture(config.dirUI.common .. "button_gray.png")
			btnUp:setTouchEnabled(false)
		end
		if parent_.skillIsLock(skillInfo) then
			imgNode:getChildByName("lock"):setVisible(true)
		end
	end
	refreshInfo()
	self.refreshInfo = refreshInfo
end
