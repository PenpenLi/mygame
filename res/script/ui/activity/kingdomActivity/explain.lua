--
-- ui/activity/kindomActivity/explain.lua
-- 玩法说明
--=============================================

UI_explain = class("UI_explain", UI)

-- 初始化
function UI_explain:init()

	self:initTouchEvent()
	self:initUI()
end

-- 初始按键事件
function UI_explain:initTouchEvent()
	-- 前往敌国要塞
	local function onGotoEnemyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require("scene/kingdomMap")
			local map = kingdomMap.new()
			map:enter()
			map:gotoPosition(cc.p(255, 511), "", self.serverID)
		end
	end
	self.onGotoEnemyTouched = onGotoEnemyTouched
	-- 显示玩法说明详情
	local function onShowExplainTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/activity/kingdomActivity/explain2"
			local ui = UI_explain2.new()
			self:addModalUI(ui)
		end
	end
	self.onShowExplainTouched = onShowExplainTouched
end

-- 初始化UI
function UI_explain:initUI()
	-- ui
	-- ===========
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "kingdomAct_explain.json")

	-- add ui
	-- ===========
	self:addCCNode(widget)

	local list = widget:getChildByName("ListView_root")
	
	local activity = player.kingdomActivityMgr.getActivity()

	-- 活动未开启
	if activity == nil then
		list:setVisible(false)
		widget:getChildByName("Panel_noActivity"):setVisible(true)
		return
	end

	-- 活动数据
	local activity_id = activity.sid
	local serverId = activity.serverID
	local serverid2 = player.serverMgr.getMyServerID()

	self.serverID = serverId

	-- 活动未开启
	if activity.status == KINGDOM_ACTIVITY_STATUS.NOT_OPEN then
		list:setVisible(false)
		local tips = widget:getChildByName("Panel_noActivity")
		tips:setVisible(true)
		tips:getChildByName("Label_text"):setString(hp.lang.getStrByID(11172))
		return
	end

	-- 设置静态数据
	local panel_info1 = list:getItem(0)
	local content_info1 = panel_info1:getChildByName("Panel_content")
	content_info1:getChildByName("Label_title"):setString(hp.lang.getStrByID(11108))
	content_info1:getChildByName("Label_btnText"):setString(hp.lang.getStrByID(11109))
	content_info1:getChildByName("Image_btn"):addTouchEventListener(self.onGotoEnemyTouched)

	content_info1:getChildByName("Label_server1"):setString(hp.gameDataLoader.getInfoBySid("serverList", serverid2).name)
	content_info1:getChildByName("Label_server2"):setString(hp.gameDataLoader.getInfoBySid("serverList", serverId).name)

	local panel_info2 = list:getItem(1)
	local content_info2 = panel_info2:getChildByName("Panel_content")
	content_info2:getChildByName("Label_title"):setString(hp.lang.getStrByID(11104))
	content_info2:getChildByName("Label_info1"):setString(hp.lang.getStrByID(11110))
	content_info2:getChildByName("Label_info2"):setString(hp.lang.getStrByID(11111))
	content_info2:getChildByName("Label_btnText"):setString(hp.lang.getStrByID(11112))
	content_info2:getChildByName("Image_btn"):addTouchEventListener(self.onShowExplainTouched)

	local panel_detail = list:getItem(2)
	local content_detail = panel_detail:getChildByName("Panel_content")
	local frame_detail = panel_detail:getChildByName("Panel_frame")
	content_detail:getChildByName("Label_title"):setString(hp.lang.getStrByID(11113))
	content_detail:getChildByName("Label_info"):setString(hp.lang.getStrByID(11114))
	
	-- 活动内容
	local activity_info = hp.gameDataLoader.getInfoBySid("kingEvent", activity_id)
	-- 11152 Chinese表中，活动内容文字起始
	local target_info = {}
	if activity_info.target1 ~= -1 then
		for i,v in ipairs(activity_info.type1) do
			local target = {}
			target.info = string.format(hp.lang.getStrByID(11152 + activity_info.target1), v)
			target.score = string.format(hp.lang.getStrByID(11152), activity_info.score1[i])
			table.insert(target_info, target)
		end
	end
	if activity_info.target2 ~= -1 then
		for i,v in ipairs(activity_info.type2) do
			local target = {}
			target.info = string.format(hp.lang.getStrByID(11152 + activity_info.target2), v)
			target.score = string.format(hp.lang.getStrByID(11152), activity_info.score2[i])
			table.insert(target_info, target)
		end
	end
	if activity_info.target3 ~= -1 then
		for i,v in ipairs(activity_info.type3) do
			local target = {}
			target.info = string.format(hp.lang.getStrByID(11152 + activity_info.target3), v)
			target.score = string.format(hp.lang.getStrByID(11152), activity_info.score3[i])
			table.insert(target_info, target)
		end
	end

	-- 动态添加
	local list_detail = panel_detail:getChildByName("ListView_detail")
	local baseItem = list_detail:getItem(0):clone()
	local itemHeight = baseItem:getSize().height

	for i,v in ipairs(target_info) do
		local item
		if i == 1 then
			item = list_detail:getItem(0)
		elseif i == #target_info then
			item = baseItem
			list_detail:pushBackCustomItem(item)
		else
			item = baseItem:clone()
			list_detail:pushBackCustomItem(item)
		end
		item:getChildByName("Panel_content"):getChildByName("Label_text1"):setString(v.info)
		item:getChildByName("Panel_content"):getChildByName("Label_text2"):setString(v.score)
	end

	-- 改变大小
	local addHeight = (#list_detail:getItems() - 1) * itemHeight
	local size = list_detail:getSize()
	size.height = size.height + addHeight
	list_detail:setSize(size)
	local size = panel_detail:getSize()
	size.height = size.height + addHeight
	panel_detail:setSize(size)

	content_detail:setPositionY(content_detail:getPositionY() + addHeight)
	frame_detail:setPositionY(frame_detail:getPositionY() + addHeight)
end