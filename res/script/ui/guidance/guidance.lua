--
-- ui/guidance/guidance.lua
-- 引导展示页面
--===================================
require "ui/fullScreenFrame"
require "ui/common/effect"

UI_Guidance = class("UI_Guidance", UI)


--init
function UI_Guidance:init()
	-- ui
	-- ===============================
	local wiget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "guidance.json")
	
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(11501), "title1")
	uiFrame:setTopShadePosY(888)

	-- set data
	local content = wiget:getChildByName("Panel_content")
	-- desc
	content:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11502))
	
	-- affairs
	local affairsBtn = content:getChildByName("Image_affairsBtn")
	affairsBtn:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11503))
	self:setHint(affairsBtn, player.mansionMgr.primeMinisterMgr.affairsStatus())
	self.affairsBtn = affairsBtn

	-- army
	local armyBtn = content:getChildByName("Image_armyBtn")
	armyBtn:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11504))
	self:setHint(armyBtn, player.mansionMgr.primeMinisterMgr.armyStatus())
	self.armyBtn = armyBtn
	
	-- mission
	local missionBtn = content:getChildByName("Image_missionBtn")
	missionBtn:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11505))
	self:setHint(missionBtn, player.mansionMgr.primeMinisterMgr.missionStatus())
	self.missionBtn = missionBtn	
	-- energy
	local energyBtn = content:getChildByName("Image_energyBtn")
	energyBtn:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11506))
	self:setHint(energyBtn, player.mansionMgr.primeMinisterMgr.energyStatus())
	self.energyBtn = energyBtn

	-- kingAct
	local kingActBtn = content:getChildByName("Image_kingActBtn")
	kingActBtn:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11507))
	self:setHint(kingActBtn, player.mansionMgr.primeMinisterMgr.kingdomActStatus())
	self.kingActBtn = kingActBtn

	-- 获取府邸等级
	local mansionLevel = player.buildingMgr.getBuildingMaxLvBySid(1001)
	if mansionLevel < 8 then
		kingActBtn:setVisible(false)
	end

	-- button touch
	local function onButtonTouch(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)

		if eventType == TOUCH_EVENT_ENDED then
			-- switch
			if sender == affairsBtn then
				require "ui/guidance/affairs"
				local ui = UI_Affairs.new()
				self:addUI(ui)

				player.guide.stepEx({2007, 40051})
			elseif sender == armyBtn then
				require "ui/guidance/army"
				local ui = UI_Army.new()
				self:addUI(ui)
			elseif sender == missionBtn then
				require "ui/guidance/mission"
				local ui = UI_Mission.new()
				self:addUI(ui)
			elseif sender == energyBtn then
				require "ui/guidance/energy"
				local ui = UI_Energy.new()
				self:addUI(ui)
			elseif sender == kingActBtn then
				require "ui/guidance/kingdomAct"
				local ui = UI_KingdomAct.new()
				self:addUI(ui)
			end
		end
	end
	-- set listener
	affairsBtn:addTouchEventListener(onButtonTouch)
	armyBtn:addTouchEventListener(onButtonTouch)
	missionBtn:addTouchEventListener(onButtonTouch)
	energyBtn:addTouchEventListener(onButtonTouch)
	kingActBtn:addTouchEventListener(onButtonTouch)

	-- regist msg
	self:registMsg(hp.MSG.CD_STARTED)
	self:registMsg(hp.MSG.CD_FINISHED)
	self:registMsg(hp.MSG.MISSION_DAILY_COLLECTED)
	self:registMsg(hp.MSG.MISSION_DAILY_REFRESH)
	self:registMsg(hp.MSG.UNION_DATA_PREPARED)
	self:registMsg(hp.MSG.PM_CHECK_CHANGE)
	self:registMsg(hp.MSG.MARCH_MANAGER)
	self:registMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	self:registMsg(hp.MSG.KING_BATTLE)
	self:registMsg(hp.MSG.COPY_NOTIFY)
	self:registMsg(hp.MSG.UNION_HELP_INFO_CHANGE)
	self:registMsg(hp.MSG.HOSPITAL_HEAL_FINISH)
	self:registMsg(hp.MSG.FAMOUS_HERO_NUM_CHANGE)
	self:registMsg(hp.MSG.MISSION_DAILY_QUICKFINISH)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wiget)


	-- 和新手指引界面绑定
	-- ======================
	local function bindGuideUI(step)
		if step==2007 or step==40051 then --指向内政
			player.guide.bind2Node(step, affairsBtn, onButtonTouch)
		end
	end
	self.bindGuideUI = bindGuideUI
	self:registMsg(hp.MSG.GUIDE_STEP)
end

-- 设置提示
function UI_Guidance:setHint(object, num)
	local hint = object:getChildByName("Image_num")
	local isShow = num > 0
	hint:setVisible(isShow)
	if isShow then
		hint:getChildByName("Label_num"):setString(num)
	end
end

function UI_Guidance:onMsg(msg, parm)
	if msg == hp.MSG.CD_STARTED or msg == hp.MSG.CD_FINISHED then
		if parm.cdType == cdBox.CDTYPE.BUILD or 
			parm.cdType == cdBox.CDTYPE.RESEARCH or 
			parm.cdType == cdBox.CDTYPE.TRAP then
			-- 内政
			self:setHint(self.affairsBtn, player.mansionMgr.primeMinisterMgr.affairsStatus())
		elseif parm.cdType == cdBox.CDTYPE.BRANCH or parm.cdType == cdBox.CDTYPE.REMEDY then
			-- 军队
			self:setHint(self.armyBtn, player.mansionMgr.primeMinisterMgr.armyStatus())
		elseif parm.cdType == cdBox.CDTYPE.DAILYTASK or
				parm.cdType == cdBox.CDTYPE.LEAGUETASK or
				parm.cdType == cdBox.CDTYPE.VIP or parm.cdType == cdBox.CDTYPE.VIPTASK then
			-- 任务
			self:setHint(self.missionBtn, player.mansionMgr.primeMinisterMgr.missionStatus())
		end
	elseif msg == hp.MSG.MARCH_MANAGER or msg == hp.MSG.MARCH_ARMY_NUM_CHANGE then
		-- 军队
		self:setHint(self.armyBtn, player.mansionMgr.primeMinisterMgr.armyStatus())
	elseif msg == hp.MSG.MISSION_DAILY_REFRESH or 
			msg == hp.MSG.MISSION_DAILY_COLLECTED or 
			msg == hp.MSG.MISSION_DAILY_QUICKFINISH then
		-- 任务
		self:setHint(self.missionBtn, player.mansionMgr.primeMinisterMgr.missionStatus())
	elseif msg == hp.MSG.COPY_NOTIFY then
		-- 体力
		self:setHint(self.energyBtn, player.mansionMgr.primeMinisterMgr.energyStatus())
	elseif msg == hp.MSG.KING_BATTLE then
		-- 国王争夺战
		self:setHint(self.kingActBtn, player.mansionMgr.primeMinisterMgr.kingdomActStatus())
	elseif msg == hp.MSG.PM_CHECK_CHANGE then
		-- 勾选
		if parm == 9 or parm == 11 or parm == 13 then
			self:setHint(self.affairsBtn, player.mansionMgr.primeMinisterMgr.affairsStatus())
		elseif parm == 4 or parm == 10 or parm == 12 then
			self:setHint(self.armyBtn, player.mansionMgr.primeMinisterMgr.armyStatus())
		elseif parm == 5 or parm == 6 or parm == 7 then
			self:setHint(self.missionBtn, player.mansionMgr.primeMinisterMgr.missionStatus())
		elseif parm == 8 or parm == 14 then
			self:setHint(self.energyBtn, player.mansionMgr.primeMinisterMgr.energyStatus())
		elseif parm == 2 then
			self:setHint(self.kingActBtn, player.mansionMgr.primeMinisterMgr.kingdomActStatus())
		end
	elseif msg==hp.MSG.GUIDE_STEP then
	-- 新手指引
		self.bindGuideUI(parm)
	end
end