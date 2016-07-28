--
-- ui/academy/researchInfo.lua
-- 科研信息界面
--===================================
require "ui/frame/popFrame"


UI_researchInfo = class("UI_researchInfo", UI)


--init
function UI_researchInfo:init(researchType_, researchId_)
	-- data
	-- ===============================
	local researchMgr = player.researchMgr
	local curInfo = researchMgr.getResearchCurLvInfo(researchId_)
	local nextInfo = researchMgr.getResearchNextLvInfo(researchId_)
	local maxLv = researchMgr.getResearchMaxLv(researchId_)
	local curLv = 1
	if nextInfo~=nil then
		curLv = nextInfo.level - 1
	else
		curLv = maxLv
	end



	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "researchInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, curInfo.name)


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)


	local contNode = wigetRoot:getChildByName("Panel_cont")
	local btnInfo = contNode:getChildByName("ImageView_info")
	local btnUp = contNode:getChildByName("ImageView_up")
	contNode:getChildByName("Label_desc"):setString(curInfo.desc)
	btnInfo:getChildByName("Label_text"):setString(hp.lang.getStrByID(9107))
	btnUp:getChildByName("Label_text"):setString(hp.lang.getStrByID(9108))
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnUp then
				require("ui/academy/research")
				local ui = UI_research.new(researchType_, researchId_)
				self:addUI(ui)
				self:close()
			end
		end
	end
	btnInfo:addTouchEventListener(onBtnTouched)

	local imgNode = contNode:getChildByName("ImageView_research")
	imgNode:loadTexture(config.dirUI.research .. researchId_ .. ".png")
	imgNode:getChildByName("progress"):setPercent(curLv*100/maxLv)
	imgNode:getChildByName("desc"):setString(string.format("%d/%d", curLv, maxLv))

	local curNode = contNode:getChildByName("Image_curLv")
	local nextNode = contNode:getChildByName("Image_nextLv")
	local curNode1 = contNode:getChildByName("Image_curLv1")
	if curInfo.type1<0 then
		curNode:setVisible(false)
		nextNode:setVisible(false)
		curNode1:setVisible(false)
	else
		if nextInfo==nil then
			curNode:setVisible(false)
			nextNode:setVisible(false)
			curNode1:getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(9104), curInfo.value1/100))
			curNode1:getChildByName("Label_fn"):setString(hp.lang.getStrByID(9106))
		else
			curNode1:setVisible(false)
			if curLv==0 then
				curNode:getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(9104), 0))
			else
				curNode:getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(9104), curInfo.value1/100))
			end
			nextNode:getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(9105), nextInfo.value1/100))
		end
	end

	if nextInfo==nil then
	--等级已最大，无法再升级
		btnUp:loadTexture(config.dirUI.common .. "button_gray.png")
	else
		btnUp:addTouchEventListener(onBtnTouched)
	end

end
