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

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "cityInfo.json")

	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)

	local contPanel = widgetRoot:getChildByName("Panel_cont")

	-- 礼物
	--====================
	local onlineBoxBg = contPanel:getChildByName("Image_online_bg")
	local cdBg = onlineBoxBg:getChildByName("Image_cdBg")
	local cdLabel = cdBg:getChildByName("Label_text")
	local onlineBox = onlineBoxBg:getChildByName("Image_icon")
	cdLabel:setString(hp.lang.getStrByID(3806))

	-- 礼物动画
	local function setOnlineBoxAnim()
		if player.mansionMgr.protocolOfficerMgr.isLight() then
			if #onlineBox:getChildren()==0 then
				local ani = hp.sequenceAniHelper.createAnimSprite("cityMap", "ringRun", 36, 0.1)
				ani:setPosition(32, 28)
				onlineBox:addChild(ani)
			end
		else
			onlineBox:removeAllChildren()
		end
	end
	setOnlineBoxAnim()
	self.setOnlineBoxAnim = setOnlineBoxAnim

	local function onOnlineBoxTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mansion/giftPerson"
			local ui = UI_giftPerson.new()
			self:addUI(ui)
		end
	end
	onlineBox:addTouchEventListener(onOnlineBoxTouched)

	-- 点将
	-- ===================
	local getHeroBg = contPanel:getChildByName("Image_hero_bg")
	local getHeroLabel = getHeroBg:getChildByName("Label_text")
	local heroIcon = getHeroBg:getChildByName("Image_icon")
	local function setGetHeroInfo()
		if player.takeInHeroMgr.getHeroNum() > 0 then
		-- 有名将可以招募
			getHeroBg:setVisible(true)
			getHeroLabel:setString(hp.lang.getStrByID(2042))

			local ani = hp.sequenceAniHelper.createAnimSprite("cityMap", "ringRun", 36, 0.1)
			ani:setPosition(32, 28)
			heroIcon:addChild(ani)

			local function onOnlineBoxTouched(sender, eventType)
				hp.uiHelper.btnImgTouched(sender, eventType)
				if eventType==TOUCH_EVENT_ENDED then
					player.buildingMgr.getBuildingObjBySid(1022):onClicked()
				end
			end
			heroIcon:addTouchEventListener(onOnlineBoxTouched)
		else
			getHeroBg:setVisible(false)
			heroIcon:removeAllChildren()
		end
	end
	setGetHeroInfo()
	self.setGetHeroInfo = setGetHeroInfo

	-- 免费钻石
	--====================
	local freeGoldBg_= contPanel:getChildByName("Image_freeGold_bg")
	freeGoldBg_:setVisible(false)
	local function freeGoldPop()
		if player.getFristLeague() == 0 then
			freeGoldBg_:setVisible(true)
			local diamond_ = freeGoldBg_:getChildByName("Image_icon")
			local label_ = freeGoldBg_:getChildByName("Label_text")
			label_:setString(hp.lang.getStrByID(2041))

			local ani = hp.sequenceAniHelper.createAnimSprite("cityMap", "ringRun", 36, 0.1)
			ani:setPosition(44, 32)
			freeGoldBg_:addChild(ani)

			local function onOperTouched(sender, eventType)
				hp.uiHelper.btnImgTouched(sender, eventType)
				if eventType==TOUCH_EVENT_ENDED then
					require "ui/guide/joinUnion"
					local ui_ = UI_unionJoinDiamond.new()
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
			local ui_ = UI_unionFightMain.new()
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
			local ui_ = UI_unionHelp.new()
			self:addUI(ui_)
		end
	end
	local unionhelp = contPanel:getChildByName("Image_6_0")
	local unionHelpText = unionhelp:getChildByName("Image_9"):getChildByName("Label_10")
	unionhelp:getChildByName("Image_7"):addTouchEventListener(onHelpTouched)


	local function updateHelpIcon()
		local info_ = player.getAlliance():getUnionHomePageInfo()
		cclog_("info_.helpinfo_.helpinfo_.helpinfo_.helpinfo_.helpinfo_.helpinfo_.helpinfo_.help",info_.help)
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
		do return end 	-- 敬请期待
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

	-- 增益管理器
	local bufTouch_ = contPanel:getChildByName("Image_22")
	local bufImage_ = bufTouch_:getChildByName("Image_28")
	local function onBufMgrTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/buf/bufManagerUI"
			local ui_ = UI_bufManagerUI.new()
			self:addUI(ui_)
		end
	end
	bufTouch_:addTouchEventListener(onBufMgrTouched)

	local function updateBufState()
		for i, v in ipairs(hp.gameDataLoader.getTable("uiBufManager")) do
			if v. position == 0 then
				if player.bufManager.getAttrAddn(v.attrID) ~= 0 then
					bufImage_:loadTexture(config.dirUI.common.."buff_2.png")
					return
				end
			elseif v.position == 1 then
				if cdBox.getCD(v.cdType) > 0 then
					bufImage_:loadTexture(config.dirUI.common.."buff_2.png")
					return
				end
			elseif v.position == 2 then
				if player.bufManager.getSpAddnBySpID(v.attrID) ~= 0 then
					bufImage_:loadTexture(config.dirUI.common.."buff_2.png")
					return
				end
			end
		end

		bufImage_:loadTexture(config.dirUI.common.."buff_1.png")
	end
	self.updateBufState = updateBufState
	updateBufState()

	-- 活动按钮
	--====================
	self.activityBtn = contPanel:getChildByName("Image_61")
	-- 默认不显示
	if player.soloActivityMgr.getActivity() == nil and
	    player.unionActivityMgr.getActivity() == nil and
	    player.kingdomActivityMgr.getActivity() == nil and
	    player.bossActivityMgr.getActivity() == nil then
		self.activityBtn:setVisible(false)
	end

	self.activityIcon = self.activityBtn:getChildByName("Image_62")
	self.activityTime = self.activityBtn:getChildByName("Label_18_0")
	self.activityDesc = self.activityBtn:getChildByName("Label_18")
	self.resetTime = 5

	-- 设置活动动画
	local function updateActivityInfo()
		local activityInfo = {}
		local activityIconUrl = {}
		local flag = 1
		self.activityIcon:stopAllActions()

		local soloActivity = player.soloActivityMgr.getActivity()
		local unionActivity = player.unionActivityMgr.getActivity()
		local kingdomActivity = player.kingdomActivityMgr.getActivity()
		local bossActivity = player.bossActivityMgr.getActivity()

		local status_ = globalData.ACTIVITY_STATUS

		if soloActivity and soloActivity.status ~= status_.CLOSE then
			table.insert(activityInfo, soloActivity)
			activityIconUrl[#activityIconUrl+1] = "activity_5.png"
		end

		if unionActivity and unionActivity.status ~= status_.CLOSE then
			table.insert(activityInfo, unionActivity)
			activityIconUrl[#activityIconUrl+1] = "activity_21.png"
		end

		if kingdomActivity and kingdomActivity.status ~= status_.CLOSE then
			table.insert(activityInfo, kingdomActivity)
			activityIconUrl[#activityIconUrl+1] = "activity_22.png"
		end

		if bossActivity and bossActivity.status ~= status_.CLOSE then
			table.insert(activityInfo, bossActivity)
			activityIconUrl[#activityIconUrl+1] = "activity_23.png"
		end
		-- 活动状态全部不正确
		if #activityInfo == 0 then
			self.activityBtn:setVisible(false)
			return
		elseif not self.activityBtn:isVisible() then
			self.activityBtn:setVisible(true)
		end
		local function reset()
			local activity = activityInfo[flag]
			-- 更换图标
			self.activityIcon:loadTexture(config.dirUI.common .. activityIconUrl[flag])
			-- 更换信息
			if activity.status == status_.OPEN then
				self.activityDesc:setString(hp.lang.getStrByID(5354))

				if activity ~= bossActivity then
					self.time = activity.endTime - player.getServerTime()
				else
					local remainingTime = activity.endTime - player.getServerTime()
					if remainingTime > player.bossActivityMgr.getTime() then
						self.time = player.bossActivityMgr.getTime()
						self.activityDesc:setString(hp.lang.getStrByID(11618))
					else
						self.time = activity.endTime - player.getServerTime()
					end
				end
			else
				self.activityDesc:setString(hp.lang.getStrByID(5375))
				self.time = activity.beginTime - player.getServerTime()
			end
			flag = flag % (#activityInfo) + 1
		end
		reset()

		local a1 = cc.FadeIn:create(1)
		local a2 = cc.DelayTime:create(2)
		local a3 = cc.FadeOut:create(1)
		local a4 = cc.CallFunc:create(reset)
		local a = cc.RepeatForever:create(cc.Sequence:create(a1, a2, a3, a4))
		
		self.activityIcon:runAction(a)
	end
	updateActivityInfo()
	
	self.updateActivityInfo = updateActivityInfo
	-- 活动计时
	local function onActivityHeartBeat(dt_)
		if self.time == nil or self.time < 0 then
			self.activityTime:setString(hp.lang.getStrByID(11183))
			self.resetTime = self.resetTime - dt_
			if self.resetTime <= 0 then
				self.resetTime = 5
				self.updateActivityInfo()
			end
		else
			self.activityTime:setString(hp.datetime.strTime(self.time))
			self.time = self.time - dt_
		end
	end
	self.onActivityHeartBeat = onActivityHeartBeat
	-- 任务点击
	local function onActivityTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/activity/activityMain"
			local ui_ = UI_activityMain.new()
			self:addUI(ui_)
		end
	end
	self.activityBtn:addTouchEventListener(onActivityTouched)

	-- 主界面主线任务
	--====================
	local questDetailBtn_ = contPanel:getChildByName("Image_2")
	local questDetailShadow = widgetRoot:getChildByName("Panel_frame"):getChildByName("Image_11")
	local getMainReward_ = contPanel:getChildByName("Image_2_0")
	getMainReward_:getChildByName("Label_3"):setString(hp.lang.getStrByID(1413))
	--领取按钮闪光
	hp.uiEffect.innerGlow(getMainReward_, 1)

	local function updateMainQuest()
		local main_ = player.questManager.getMainQuestInfo()

		if main_ == nil then
			contPanel:getChildByName("Label_12"):setVisible(false)
			contPanel:getChildByName("Image_2"):setVisible(false)
			widgetRoot:getChildByName("Panel_frame"):getChildByName("Image_11"):setVisible(false)
			getMainReward_:setVisible(false)
		else
			contPanel:getChildByName("Label_12"):setVisible(true)
			contPanel:getChildByName("Image_2"):setVisible(true)
			widgetRoot:getChildByName("Panel_frame"):getChildByName("Image_11"):setVisible(true)

			local info_ = hp.gameDataLoader.getInfoBySid("quests", main_.id)

			if info_ ~= nil then
				contPanel:getChildByName("Label_12"):setString(info_.text)
			end

			-- 未领取奖励
			getMainReward_:setVisible(main_.reward)
		end
	end

	local function onQuestDetailTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/quest/empireQuest"
			local ui_ = UI_empireQuest.new()
			self:addUI(ui_)
		end
	end		

	local function onGetRewardTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local rewardID_ = player.questManager.getMainReward()
			if rewardID_ ~= nil then
				self:showLoading(player.questManager.httpReqCollectEmpireReward(rewardID_), sender)
				player.guide.stepEx({3001})
			end
		end
	end

	local function mainQuestFinish()
		local ani = hp.sequenceAniHelper.createFinishQuestAni()
		contPanel:addChild(ani)
		local size_ = contPanel:getSize()
		local x_, y_ = questDetailBtn_:getPosition()
		ani:setPosition(size_.width/2, y_)
	end
	
	self.mainQuestFinish = mainQuestFinish
	getMainReward_:addTouchEventListener(onGetRewardTouched)
	questDetailBtn_:getChildByName("Label_3"):setString(hp.lang.getStrByID(1407))
	questDetailBtn_:addTouchEventListener(onQuestDetailTouched)
	questDetailShadow:addTouchEventListener(onQuestDetailTouched)

	self.updateMainQuest = updateMainQuest
	updateMainQuest()

	-- 主界面支线任务
	--====================
	local branchQuestDetailBtn_ = contPanel:getChildByName("Image_2_1")
	local getBranchReward_ = contPanel:getChildByName("Image_2_0_0")
	getBranchReward_:getChildByName("Label_3"):setString(hp.lang.getStrByID(1413))
	--领取按钮闪光
	hp.uiEffect.innerGlow(getBranchReward_, 1)

	local function updateBranchQuest()
		local main_ = player.questManager.getBranchReward()[1]
		cclog_("main_------------------------------------------------------------",main_)

		if main_ == nil then
			contPanel:getChildByName("Label_12_0"):setVisible(false)
			widgetRoot:getChildByName("Panel_frame"):getChildByName("Image_11_0"):setVisible(false)
			getBranchReward_:setVisible(false)
		else
			contPanel:getChildByName("Label_12_0"):setVisible(true)
			widgetRoot:getChildByName("Panel_frame"):getChildByName("Image_11_0"):setVisible(true)

			local info_ = hp.gameDataLoader.getInfoBySid("quests", main_)

			if info_ ~= nil then
				contPanel:getChildByName("Label_12_0"):setString(info_.text)
			end

			-- 未领取奖励
			getBranchReward_:setVisible(true)
		end
	end

	local function onGetBranchRewardTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local rewardID_ = player.questManager.getBranchReward()[1]
			if rewardID_ ~= nil then
				self:showLoading(player.questManager.httpReqCollectEmpireReward(rewardID_), sender)
				player.guide.stepEx({3001})
			end
		end
	end

	local function branchQuestFinish()
		local ani = hp.sequenceAniHelper.createFinishQuestAni()
		contPanel:addChild(ani)
		local size_ = contPanel:getSize()
		local x_, y_ = branchQuestDetailBtn_:getPosition()
		ani:setPosition(size_.width/2, y_)
	end
	
	self.branchQuestFinish = branchQuestFinish
	getBranchReward_:addTouchEventListener(onGetBranchRewardTouched)
	branchQuestDetailBtn_:getChildByName("Label_3"):setString(hp.lang.getStrByID(1407))
	branchQuestDetailBtn_:addTouchEventListener(onQuestDetailTouched)

	self.updateBranchQuest = updateBranchQuest
	updateBranchQuest()

	--促销信息
	local promotionPos = contPanel:getChildByName("Image_promotionPos")
	local promotionAnim = hp.sequenceAniHelper.createAnimSprite("common", "promotion", 30, 0.1, 3)
	local promotionSz = promotionPos:getSize()
	promotionAnim:setPosition(promotionSz.width/2, promotionSz.height/2)
	promotionPos:addChild(promotionAnim)
	local function onPromotionTouched(sender, eventType)	
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/goldShop/goldShop"
			local ui = UI_goldShop.new()
			self:addUI(ui)
		end
	end
	promotionPos:addTouchEventListener(onPromotionTouched)

	-- registMsg
	player.getAlliance():prepareData(dirtyType.UNIONGIFT, "UI_cityInfo")
	self:registMsg(hp.MSG.UNION_RECEIVE_GIFT)
	self:registMsg(hp.MSG.UPGRADEGIFT_GET)
	self:registMsg(hp.MSG.SIGN_IN)
	self:registMsg(hp.MSG.NOVICE_GIFT)
	self:registMsg(hp.MSG.ONLINE_GIFT)
	self:registMsg(hp.MSG.UNION_JOIN_SUCCESS)
	self:registMsg(hp.MSG.GUIDE_OVER)
	self:registMsg(hp.MSG.UNION_DATA_PREPARED)
	self:registMsg(hp.MSG.MISSION_REFRESH)
	self:registMsg(hp.MSG.HERO_LV_UP)
	self:registMsg(hp.MSG.MISSION_COLLECT)
	self:registMsg(hp.MSG.MISSION_COMPLETE)
	self:registMsg(hp.MSG.BUF_NOTITY)
	self:registMsg(hp.MSG.CD_CHANGED)
	self:registMsg(hp.MSG.SOLO_ACTIVITY)
	self:registMsg(hp.MSG.UNION_ACTIVITY)
	self:registMsg(hp.MSG.KINGDOM_ACTIVITY)
	self:registMsg(hp.MSG.UNION_NOTIFY)
	self:registMsg(hp.MSG.FAMOUS_HERO_NUM_CHANGE)
	self:registMsg(hp.MSG.BOSS_ACTIVITY)

	-- 进行新手引导绑定
	-- =========================================
	self:registMsg(hp.MSG.GUIDE_STEP)
	local function bindGuideUI( step )
		if step==3001 then
		-- 建造农田任务奖励
			player.guide.bind2Node(step, getMainReward_, onGetRewardTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
end

-- onMsg
function UI_cityInfo:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(paramInfo_)
	elseif msg_==hp.MSG.ONLINE_GIFT or msg_== hp.MSG.UNION_RECEIVE_GIFT or
			msg_== hp.MSG.UPGRADEGIFT_GET or msg_== hp.MSG.SIGN_IN or
			msg_== hp.MSG.NOVICE_GIFT then
		self.setOnlineBoxAnim()
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
		elseif paramInfo_ == dirtyType.UNIONGIFT then
			self.setOnlineBoxAnim()
		end
	elseif msg_ == hp.MSG.MISSION_REFRESH then
		if paramInfo_ == 1 then
			self.updateMainQuest()
		elseif paramInfo_ == 3 then
			self.updateBranchQuest()
		end
	elseif msg_ == hp.MSG.HERO_LV_UP then
		require "ui/hero/heroLevelup"
		local ui  = UI_heroLevelup.new()
		self:addModalUI(ui)
	elseif msg_ == hp.MSG.MISSION_COLLECT then
		local questInfo_ = hp.gameDataLoader.getInfoBySid("quests", paramInfo_)
		if questInfo_.type == 1 then
			self.updateMainQuest()
		else
			self.updateBranchQuest()
		end
	elseif msg_ == hp.MSG.MISSION_COMPLETE then
		if paramInfo_ == 1 then
			self.mainQuestFinish()
		elseif paramInfo_ == 2 then
			self.branchQuestFinish()
		end
	elseif msg_ == hp.MSG.BUF_NOTITY then
		if paramInfo_.msgType == 1 then
			self.updateBufState()
		end
	elseif msg_ == hp.MSG.CD_CHANGED then
		if paramInfo_.cdType == cdBox.CDTYPE.PEACE or
			paramInfo_.cdType == cdBox.CDTYPE.FORBIDVIEW then
			self.updateBufState()
		end
	elseif msg_ == hp.MSG.SOLO_ACTIVITY then
		if paramInfo_.msgType == 3 or
		   paramInfo_.msgType == 4 or
		   paramInfo_.msgType == 5 then
			self.updateActivityInfo()
		end
	elseif msg_ == hp.MSG.UNION_ACTIVITY then
		if paramInfo_ == 1 or
		   paramInfo_ == 5 or
		   paramInfo_ == 6 then
			self.updateActivityInfo()
		 end
	elseif msg_ == hp.MSG.KINGDOM_ACTIVITY then
		if paramInfo_ == 1 or
		   paramInfo_ == 3 or
		   paramInfo_ == 4 then
			self.updateActivityInfo()
		 end
	elseif msg_ == hp.MSG.BOSS_ACTIVITY then
		self.updateActivityInfo()
	elseif msg_ == hp.MSG.UNION_NOTIFY then
		if paramInfo_.msgType == 2 then
			self.updateHelpIcon()
		end
	elseif msg_ == hp.MSG.FAMOUS_HERO_NUM_CHANGE then
		self.setGetHeroInfo()
	end	
end


function UI_cityInfo:heartbeat(dt)
	self.onActivityHeartBeat(dt)
end