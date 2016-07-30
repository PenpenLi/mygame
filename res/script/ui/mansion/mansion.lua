--
-- ui/mansion/mansion.lua
-- 府邸内部界面
--===================================

UI_mansion = class("UI_mansion", UI)

-- 初始化
function UI_mansion:init()
	-- ui
	-- =======================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mansionUi.json")

	-- addCCNode
	-- =======================
	self:addCCNode(wigetRoot)

	-- 获取控件
	local panel_content = wigetRoot:getChildByName("Panel_content")
	local panel_zhg = panel_content:getChildByName("Panel_ZhuGong")
	local panel_cx = panel_content:getChildByName("Panel_ChengXiang")
	local panel_jj = panel_content:getChildByName("Panel_JiangJun")
	local panel_lg = panel_content:getChildByName("Panel_LiGuan")
	local panel_zg = panel_content:getChildByName("Panel_ZongGuan")
	local panel_sz = panel_content:getChildByName("Panel_ShiZhe")
	local panel_ch = panel_content:getChildByName("Panel_ChiHou")

	-- 创建人物
	require "ui/mansion/minister"
	local zhg = Minister.new(self, panel_zhg, "zhg")
	local cx = Minister.new(self, panel_cx, "cx")
	local jj = Minister.new(self, panel_jj, "jj")
	local lg = Minister.new(self, panel_lg, "lg")
	local zg = Minister.new(self, panel_zg, "zg")
	local sz = Minister.new(self, panel_sz, "sz")
	local ch = Minister.new(self, panel_ch, "ch")

	-- 人物panel表
	self.panelTab = {panel_zhg, panel_cx, panel_jj, panel_lg, panel_zg, panel_sz, panel_ch}

	-- 人物表
	self.personTab = {zhg, cx, jj, lg, zg, sz, ch}
	
	-- 初始化对话框（弃用）
	-- self:initDialog(panel_content)
	
	-- 初始化主公的唠叨
	self:initChatter(panel_zhg)

	-- 按键事件
	local function onPersonTouched(sender, eventType)
		local person = self.personTab[sender:getTag()]
		if eventType == TOUCH_EVENT_BEGAN then
			person.character:setColor(hp.uiHelper.btnImgPressedColor)
		elseif eventType == TOUCH_EVENT_MOVED then
			if self:isRange(sender:getTouchMovePos(), sender) then
				person.character:setColor(hp.uiHelper.btnImgPressedColor)
			else
				person.character:setColor(hp.uiHelper.btnImgNormalColor)
			end
		elseif eventType == TOUCH_EVENT_ENDED then
			person.character:setColor(hp.uiHelper.btnImgNormalColor)
			person:openMenu()
			player.guide.stepEx({2003, 4002})
		else
			person.character:setColor(hp.uiHelper.btnImgNormalColor)
		end
	end

	-- 注册监听
	panel_zhg:addTouchEventListener(onPersonTouched)
	panel_cx:addTouchEventListener(onPersonTouched)
	panel_jj:addTouchEventListener(onPersonTouched)
	panel_lg:addTouchEventListener(onPersonTouched)
	panel_zg:addTouchEventListener(onPersonTouched)
	panel_sz:addTouchEventListener(onPersonTouched)
	panel_ch:addTouchEventListener(onPersonTouched)

	-- 注册消息
	-- 礼官
	player.getAlliance():prepareData(dirtyType.UNIONGIFT, "UI_mansion")
	self:registMsg(hp.MSG.ONLINE_GIFT)
	self:registMsg(hp.MSG.UNION_RECEIVE_GIFT)
	self:registMsg(hp.MSG.UPGRADEGIFT_GET)
	self:registMsg(hp.MSG.SIGN_IN)
	self:registMsg(hp.MSG.NOVICE_GIFT)
	-- 丞相
	self:registMsg(hp.MSG.CD_STARTED)
	self:registMsg(hp.MSG.CD_FINISHED)
	self:registMsg(hp.MSG.MISSION_DAILY_START)
	self:registMsg(hp.MSG.MISSION_DAILY_REFRESH)
	self:registMsg(hp.MSG.MISSION_DAILY_COMPLETE)
	self:registMsg(hp.MSG.MISSION_DAILY_COLLECTED)
	self:registMsg(hp.MSG.PM_CHECK_CHANGE)
	self:registMsg(hp.MSG.MARCH_MANAGER)
	self:registMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	self:registMsg(hp.MSG.VIP)
	-- 将军
	self:registMsg(hp.MSG.SKILL_CHANGED)
	self:registMsg(hp.MSG.LV_CHANGED)
	self:registMsg(hp.MSG.HERO_INFO_CHANGE)
	-- 斥候
	self:registMsg(hp.MSG.MAIL_CHANGED)
	-- 使者
	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	-- 进行新手引导绑定
	-- =========================================
	self:registMsg(hp.MSG.GUIDE_STEP)
	local function bindGuideUI( step )
		if step==2003 or step==4002 then
			player.guide.bind2Node(step, panel_cx, onPersonTouched)
		elseif step==3001 then
			self:close()
		end
	end
	self.bindGuideUI = bindGuideUI
end

-- 接收消息
function UI_mansion:onMsg(msg_, param_)
	-- 新手引导
	if msg_==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(param_)
	-- 礼官
	elseif msg_ == hp.MSG.ONLINE_GIFT or
		msg_ == hp.MSG.UNION_DATA_PREPARED and param_ == dirtyType.UNIONGIFT or
		msg_ == hp.MSG.UNION_RECEIVE_GIFT or
		msg_ == hp.MSG.SIGN_IN or
		msg_ == hp.MSG.UPGRADEGIFT_GET or
		msg_ == hp.MSG.NOVICE_GIFT then
		self.personTab[4]:setLight(player.mansionMgr.protocolOfficerMgr.isLight())
	-- 将军
	elseif msg_ == hp.MSG.SKILL_CHANGED or
			msg_ == hp.MSG.LV_CHANGED or
			msg_ == hp.MSG.HERO_INFO_CHANGE then	
		self.personTab[3]:setLight(player.mansionMgr.generaMgr.isLight())
	-- 使者
	elseif msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.VARIABLENUM and player.getAlliance():getUnionHomePageInfo().param.change.unionWar then
			player.postmanAndEnvoyMgr.setEnvoyIsClick(false)
		end
		self.personTab[6]:setLight(player.postmanAndEnvoyMgr.getEnvoyIsLightOnMsg())
		self.personTab[2]:setLight(player.mansionMgr.primeMinisterMgr.isLight())
	-- 斥候
	elseif msg_ == hp.MSG.MAIL_CHANGED then
		self.personTab[7]:setLight(player.postmanAndEnvoyMgr.getPostmanIsLightOnMsg())
	-- 丞相
	elseif msg_ == hp.MSG.CD_STARTED or 
			msg_ == hp.MSG.CD_FINISHED or 
			msg_ == hp.MSG.MISSION_DAILY_START or 
			msg_ == hp.MSG.MISSION_DAILY_REFRESH or 
			msg_ == hp.MSG.MISSION_DAILY_COMPLETE or 
			msg_ == hp.MSG.MISSION_DAILY_COLLECTED or 
			msg_ == hp.MSG.PM_CHECK_CHANGE or
			msg_ == hp.MSG.MARCH_MANAGER or
			msg_ == hp.MSG.MARCH_ARMY_NUM_CHANGE then
		self.personTab[2]:setLight(player.mansionMgr.primeMinisterMgr.isLight())
	else
		cclog_("mansion lost msg")
	end
end

-- 是否在按钮范围内
function UI_mansion:isRange(pos, btn)
	if pos.x > btn:getPositionX() and pos.x < btn:getPositionX() + btn:getSize().width and
			pos.y > btn:getPositionY() and pos.y < btn:getPositionY() + btn:getSize().height then
		return true
	end
	return false
end

-- 获取对话内容
local function getChatterBySid(sid)
	for i, chatter in ipairs(game.data.mansionTalk) do
		if sid == chatter.id then
			return chatter.str
		end
	end
	return nil
end

-- 主公的唠叨
function UI_mansion:initChatter(content)

	self.chatter = content:getChildByName("Label_text")
	self.chatterBg = content:getChildByName("Image_talk")

	-- 获取字符串
	local str
	while true do
		local random = math.floor(os.clock() * 1000 % 22 + 101)
		str = getChatterBySid(random)
		if str ~= nil then
			break
		end
	end

	self.chatter:setString(str)

	self.chatterTime = 0
end

-- 对话框
function UI_mansion:initDialog(content)
	-- 获取控件
	self.panel_dialog = content:getChildByName("Panel_dialog")
	self.dialog_bg = self.panel_dialog:getChildByName("Image_bg")
	self.dialog_text = self.panel_dialog:getChildByName("Label_text")
	-- 对话内容表
	self.textTab = {
		game.data.mansionTalk[2].str,
		game.data.mansionTalk[3].str,
		game.data.mansionTalk[4].str,
		game.data.mansionTalk[5].str,
		game.data.mansionTalk[6].str,
		game.data.mansionTalk[7].str,
	}
	-- 对话框位置表
	self.posTab = {
		-- 丞相
		cc.p(
			self.panelTab.cx:getPositionX() + self.panelTab.cx:getSize().width * hp.uiHelper.RA_scale * 0.75,
			self.panelTab.cx:getPositionY() + self.panelTab.cx:getSize().height * hp.uiHelper.RA_scale * 2 / 3
		),
		-- 将军
		cc.p(
			self.panelTab.jj:getPositionX() - self.panel_dialog:getSize().width * hp.uiHelper.RA_scale * 0.95,
			self.panelTab.jj:getPositionY() + self.panelTab.jj:getSize().height * hp.uiHelper.RA_scale * 2 / 3
		),
		-- 礼官
		cc.p(
			self.panelTab.lg:getPositionX() + self.panelTab.lg:getSize().width * hp.uiHelper.RA_scale * 0.9, 
			self.panelTab.lg:getPositionY() + self.panelTab.lg:getSize().height * hp.uiHelper.RA_scale * 4 / 5
		),
		-- 总管
		cc.p(
			self.panelTab.zg:getPositionX() - self.panel_dialog:getSize().width * hp.uiHelper.RA_scale * 0.9, 
			self.panelTab.zg:getPositionY() + self.panelTab.zg:getSize().height * hp.uiHelper.RA_scale * 4 / 5
		),
		-- 使者
		cc.p(
			self.panelTab.sz:getPositionX() + self.panelTab.sz:getSize().width * hp.uiHelper.RA_scale * 0.9, 
			self.panelTab.sz:getPositionY() + self.panelTab.sz:getSize().height * hp.uiHelper.RA_scale * 5 / 6
		),
		-- 斥候
		cc.p(
			self.panelTab.ch:getPositionX() - self.panel_dialog:getSize().width * hp.uiHelper.RA_scale * 0.9, 
			self.panelTab.ch:getPositionY() + self.panelTab.ch:getSize().height * hp.uiHelper.RA_scale * 5 / 6
		),
	}
	-- 对话框当前位置
	self.cur = 0
	-- 记录时间
	self.time = 99
	-- 对话框开启
	self.isDialogShow = true
end

-- 心跳
function UI_mansion:heartbeat(dt)
	-- 已开启对话框，以及时间足够
	-- if self.isDialogShow and self.time >= 2 then
	-- 	-- 下一次对话
	-- 	self.cur = self.cur % 6 + 1
	-- 	-- 是否发光
	-- 	if self.personTab[self.cur + 1]:isLight() then
	-- 		-- 设置可见
	-- 		self.panel_dialog:setVisible(true)
	-- 		-- 时间清零
	-- 		self.time = 0
	-- 		-- 设置位置
	-- 		self.panel_dialog:setPosition(self.posTab[self.cur])
	-- 		-- 设置内容
	-- 		self.dialog_text:setString(self.textTab[self.cur])
	-- 		-- 设置翻转（双数序号为右边人物）
	-- 		if self.cur % 2 == 0 then
	-- 			self.dialog_bg:setFlippedX(true)
	-- 			self.dialog_text:setPositionX(self.dialog_bg:getSize().width * 0.525)
	-- 		else
	-- 			self.dialog_bg:setFlippedX(false)
	-- 			self.dialog_text:setPositionX(self.dialog_bg:getSize().width * 0.575)
	-- 		end
	-- 	else
	-- 		-- 不可见
	-- 		self.panel_dialog:setVisible(false)
	-- 	end
	-- end
	-- -- 时间递增
	-- self.time = self.time + dt


	-- 提示泡泡
	for i = 2, #self.personTab do
		if i ~= 5 then
			if self.personTab[i]:isLight() then
				self.panelTab[i]:getChildByName("Image_talk"):setVisible(true)
			else
				self.panelTab[i]:getChildByName("Image_talk"):setVisible(false)
			end
		end
	end

	-- 唠叨存在时间
	if self.chatterTime ~= nil then
		self.chatterTime = self.chatterTime + dt
		if self.chatterTime >= 5 then
			-- 唠叨时间结束
			self.chatterTime = nil
			self.chatter:setVisible(false)
			self.chatterBg:setVisible(false)
		end
	end
end

-- onRemove
function UI_mansion:onRemove()
	self.super.onRemove(self)

	player.getAlliance():unPrepareData(dirtyType.UNIONGIFT, "UI_mansion")
end