--
-- ui/activity/kingdomActivity/kingdomActivity.lua
-- 王国活动
--=============================================

require "ui/fullScreenFrame"
require "ui/activity/kingdomActivity/explain"
require "ui/activity/kingdomActivity/personTarget"
require "ui/activity/kingdomActivity/unionTarget"
require "ui/activity/kingdomActivity/kingdomTarget"
require "ui/activity/kingdomActivity/history"

UI_kingdomActivity = class("UI_kingdomActivity", UI)

-- ui 表
local uiTbl  = {
	UI_explain,
	UI_personTarget,
	UI_unionTarget,
	UI_kingdomTarget,
	UI_history,
}

-- 初始化
function UI_kingdomActivity:init()
	
	-- 注册王国事件消息
	self:registMsg(hp.MSG.KINGDOM_ACTIVITY)

	self:initTouchEvent()
	self:initUI()
end

-- 初始化按键事件
function UI_kingdomActivity:initTouchEvent()
	-- 设置外观
	local function setFace(sender, color, scale)
		sender:setColor(color)
		sender:getChildByName("Label_text"):setColor(color)
		if scale then
			sender:setScale(scale)
		end
	end
	-- 切换页
	local function onChangePageTouched(sender, eventType)
		if self.page_flag ~= sender then
			if eventType==TOUCH_EVENT_BEGAN then
				setFace(sender, self.page_selectedColor)
			elseif eventType==TOUCH_EVENT_MOVED then
				if sender:hitTest(sender:getTouchMovePos()) then
					setFace(sender, self.page_selectedColor)
				else
					setFace(sender, self.page_unSelectedColor)
				end
			elseif eventType == TOUCH_EVENT_ENDED then
				setFace(sender, self.page_selectedColor, self.page_selectedScale)
				setFace(self.page_flag, self.page_unSelectedColor, self.page_unSelectedScale)
				self.page_flag = sender

				if sender == self.btn_activity then
					local activity = player.kingdomActivityMgr.getActivity()

					if activity and activity.status == KINGDOM_ACTIVITY_STATUS.OPEN then
						self.panel_tagContent:setVisible(true)
						self.panel_tagFrame:setVisible(true)
						self.uiFrame:setTopShadePosY(775)
					end

					self:switchTag(self.index)
				else
					-- 更新历史活动
					player.kingdomActivityMgr.updateHistory(self)
				end
			end
		end
	end
	self.onChangePageTouched = onChangePageTouched
	-- 切换标签
	local function onChangeTagTouched(sender, eventType)
		if self.tag_flag[1] ~= sender then
			if eventType==TOUCH_EVENT_BEGAN then
				sender:setColor(self.tag_selectColor)
			elseif eventType==TOUCH_EVENT_MOVED then
				if sender:hitTest(sender:getTouchMovePos()) then
					sender:setColor(self.tag_selectColor)
				else
					sender:setColor(self.tag_unSelectColor)
				end
			elseif eventType == TOUCH_EVENT_ENDED then
				sender:setColor(self.tag_unSelectColor)
				self.tag_flag[2]:setVisible(false)
				self.tag_flag[3]:setColor(self.tag_selectColor)

				local temp
				if sender == self.explain[1] then
					temp = self.explain
					self:switchTag(1)
				elseif sender == self.personTarget[1] then
					temp = self.personTarget
					self:switchTag(2)
				elseif sender == self.unionTarget[1] then
					temp = self.unionTarget
					self:switchTag(3)
				elseif sender == self.kingdomTarget[1] then
					temp = self.kingdomTarget
					self:switchTag(4)
				end
				temp[2]:setVisible(true)
				temp[3]:setColor(self.tag_unSelectColor)
				self.tag_flag = temp
			end
		end
	end
	self.onChangeTagTouched = onChangeTagTouched
end

function UI_kingdomActivity:initUI()
	-- ui
	-- ===============================
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "kingdomAct.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(775)
	uiFrame:setTitle(hp.lang.getStrByID(11101), "title1")
	self.uiFrame = uiFrame

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widget)

	-- 页
	-- ===============
	local panel_navContent = widget:getChildByName("Panel_navContent")
	local btn_activity = panel_navContent:getChildByName("Image_activity")
	btn_activity:getChildByName("Label_text"):setString(hp.lang.getStrByID(11102))
	btn_activity:addTouchEventListener(self.onChangePageTouched)
	self.btn_activity = btn_activity

	local btn_history = panel_navContent:getChildByName("Image_history")
	btn_history:getChildByName("Label_text"):setString(hp.lang.getStrByID(11103))
	btn_history:addTouchEventListener(self.onChangePageTouched)
	self.btn_history = btn_history

	self.page_selectedColor = btn_activity:getColor()
	self.page_selectedScale = btn_activity:getScale()
	self.page_unSelectedColor = btn_history:getColor()
	self.page_unSelectedScale = btn_history:getScale()
	self.page_flag = btn_activity

	-- 标签
	-- ===============
	local panel_tagContent = widget:getChildByName("Panel_tagContent")
	local panel_tagFrame = widget:getChildByName("Panel_tagFrame")
	self.panel_tagContent = panel_tagContent
	self.panel_tagFrame = panel_tagFrame

	local activity = player.kingdomActivityMgr.getActivity()

	-- 活动开启中...
	if activity and activity.status == KINGDOM_ACTIVITY_STATUS.OPEN then
		self.explain = {}
		self.explain[1] = panel_tagFrame:getChildByName("Image_explain")
		self.explain[2] = panel_tagFrame:getChildByName("Image_selected1")
		self.explain[3] = panel_tagContent:getChildByName("Label_explain")
		self.explain[1]:addTouchEventListener(self.onChangeTagTouched)
		self.explain[3]:setString(hp.lang.getStrByID(11104))

		self.personTarget = {}
		self.personTarget[1] = panel_tagFrame:getChildByName("Image_personTarget")
		self.personTarget[2] = panel_tagFrame:getChildByName("Image_selected2")
		self.personTarget[3] = panel_tagContent:getChildByName("Label_personTarget")
		self.personTarget[1]:addTouchEventListener(self.onChangeTagTouched)
		self.personTarget[3]:setString(hp.lang.getStrByID(11105))

		self.unionTarget = {}
		self.unionTarget[1] = panel_tagFrame:getChildByName("Image_unionTarget")
		self.unionTarget[2] = panel_tagFrame:getChildByName("Image_selected3")
		self.unionTarget[3] = panel_tagContent:getChildByName("Label_unionTarget")
		self.unionTarget[1]:addTouchEventListener(self.onChangeTagTouched)
		self.unionTarget[3]:setString(hp.lang.getStrByID(11106))

		self.kingdomTarget = {}
		self.kingdomTarget[1] = panel_tagFrame:getChildByName("Image_kingdomTarget")
		self.kingdomTarget[2] = panel_tagFrame:getChildByName("Image_selected4")
		self.kingdomTarget[3] = panel_tagContent:getChildByName("Label_kingdomTarget")
		self.kingdomTarget[1]:addTouchEventListener(self.onChangeTagTouched)
		self.kingdomTarget[3]:setString(hp.lang.getStrByID(11107))

		self.tag_selectColor = self.kingdomTarget[3]:getColor()
		self.tag_unSelectColor = self.explain[3]:getColor()

		self.tag_flag = self.explain
	else
		panel_tagContent:setVisible(false)
		panel_tagFrame:setVisible(false)
		self.uiFrame:setTopShadePosY(820)
	end


	-- 默认ui
	-- ===============
	self.index = 0
	self.currentUI = nil
	self:switchTag(1)
end

-- 切换标签
function UI_kingdomActivity:switchTag(index_)
	if self.currentUI then
		self:removeChildUI(self.currentUI)
	end
	self.currentUI = uiTbl[index_].new()
	self:addChildUI(self.currentUI)
	self.index = index_
end

-- 消息接收
function UI_kingdomActivity:onMsg(msg, param)
	if msg == hp.MSG.KINGDOM_ACTIVITY then
		if param == 2 then
			self.panel_tagContent:setVisible(false)
			self.panel_tagFrame:setVisible(false)

			self:removeChildUI(self.currentUI)
			self.currentUI = uiTbl[5].new()
			self:addChildUI(self.currentUI)

			self.uiFrame:setTopShadePosY(820)
		end
	end
end