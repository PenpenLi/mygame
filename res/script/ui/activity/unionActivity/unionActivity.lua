--
-- ui/activity/unionActivity/unionActivity.lua
-- 联盟活动
--=============================================

require "ui/fullScreenFrame"
require "ui/activity/unionActivity/rewards"
require "ui/activity/unionActivity/taget"
require "ui/activity/unionActivity/member"
require "ui/activity/unionActivity/ranking"
require "ui/activity/unionActivity/history"

UI_unionActivity = class("UI_unionActivity", UI)

local activity_info
local member_info
local history_info

local uiTbl  = {
	UI_target,
	UI_rewards,
	UI_ranking,
	UI_member,
	UI_history,
}

function UI_unionActivity:init(info_)
	activity_info = info_

	self:registMsg(hp.MSG.UNION_ACTIVITY)

	self:initUI()
end

function UI_unionActivity:initTouchEvent()
	-- 切换界面
	local function changePage(sender, eventType)
		if sender ~= self.currentPage then

			if eventType==TOUCH_EVENT_BEGAN then
				sender:setColor(self.selectedColor)
				sender:getChildByName("Label_text"):setColor(self.selectedColor)
			elseif eventType==TOUCH_EVENT_MOVED then
				if sender:hitTest(sender:getTouchMovePos())==true then
					sender:setColor(self.selectedColor)
					sender:getChildByName("Label_text"):setColor(self.selectedColor)
				else
					sender:setColor(self.unSelectedColor)
					sender:getChildByName("Label_text"):setColor(self.unSelectedColor)
				end
			elseif eventType == TOUCH_EVENT_ENDED then
				self.currentPage:setColor(self.unSelectedColor)
				self.currentPage:setScale(self.unSelectedScale)
				self.currentPage:getChildByName("Label_text"):setColor(self.unSelectedColor)

				sender:setColor(self.selectedColor)
				sender:setScale(self.selectedScale)
				sender:getChildByName("Label_text"):setColor(self.selectedColor)
				self.currentPage = sender
				self.currentPageFlag = not self.currentPageFlag

				-- 活动界面
				if self.currentPageFlag then
					self:removeChildUI(self.ui_history)
					self:switchTag(self.flag)

					if activity_info.status == UNION_ACTIVITY_STATUS.OPEN then
						self.uiFrame:setTopShadePosY(775)
						self.panel_tagFrame:setVisible(true)
						self.panel_tagContent:setVisible(true)
					end
				-- 历史记录
				else
					player.unionActivityMgr.updateHistory(self)
				end
			end
		end
	end
	self.changePage = changePage

	-- 切换标签
	local function changeTag(sender, eventType)
		if sender ~= self.currentTag[1] then

			if eventType==TOUCH_EVENT_BEGAN then
				sender:setColor(self.unCheckedColor)
			elseif eventType==TOUCH_EVENT_MOVED then
				if sender:hitTest(sender:getTouchMovePos())==true then
					sender:setColor(self.unCheckedColor)
				else
					sender:setColor(self.checkedColor)
				end
			elseif eventType == TOUCH_EVENT_ENDED then
				sender:setColor(self.checkedColor)
				self.currentTag[2]:setVisible(false)
				self.currentTag[3]:setColor(self.unCheckedColor)

				if sender == self.tag_target[1] then
					self.currentTag = self.tag_target
					self:switchTag(1)
				elseif sender == self.tag_rewards[1] then
					self.currentTag = self.tag_rewards
					self:switchTag(2)
				elseif sender == self.tag_ranking[1] then
					self.currentTag = self.tag_ranking
					self:switchTag(3)
				elseif sender == self.tag_member[1] then
					player.unionActivityMgr.updateMember(self)
					self.currentTag = self.tag_member
				end
				self.currentTag[2]:setVisible(true)
				self.currentTag[3]:setColor(self.checkedColor)
			end
		end
	end
	self.changeTag = changeTag
end

function UI_unionActivity:initUI()

	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActivityInfo.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(775)
	uiFrame:setTitle(hp.lang.getStrByID(5659), "title1")
	self.uiFrame = uiFrame

	self:addChildUI(uiFrame)
	self:addCCNode(widget)

	-- 初始事件监听
	self:initTouchEvent()

	-- 页面
	local panel_navContent = widget:getChildByName("Panel_navContent")

	local activity_btn = panel_navContent:getChildByName("Image_activity")
	activity_btn:getChildByName("Label_text"):setString(hp.lang.getStrByID(5601))
	self.selectedColor = activity_btn:getColor()
	self.selectedScale = activity_btn:getScale()
	activity_btn:addTouchEventListener(self.changePage)

	local history_btn = panel_navContent:getChildByName("Image_history")
	history_btn:getChildByName("Label_text"):setString(hp.lang.getStrByID(5602))
	self.unSelectedColor = history_btn:getColor()
	self.unSelectedScale = history_btn:getScale()
	history_btn:addTouchEventListener(self.changePage)

	self.currentPage = activity_btn
	self.currentPageFlag = true

	-- 记录标签位置
	self.flag = 1
	self.currentUI = uiTbl[self.flag].new(activity_info, 1)
	self:addChildUI(self.currentUI)

	if activity_info.status == UNION_ACTIVITY_STATUS.OPEN then
		-- 标签
		local panel_tagFrame = widget:getChildByName("Panel_tagFrame")
		local panel_tagContent = widget:getChildByName("Panel_tagContent")
		self.panel_tagFrame = panel_tagFrame
		self.panel_tagContent = panel_tagContent

		local tag_target = {}
		tag_target[1] = panel_tagFrame:getChildByName("Image_target")
		tag_target[2] = panel_tagFrame:getChildByName("Image_selected1")
		tag_target[3] = panel_tagContent:getChildByName("Label_target")
		tag_target[1]:addTouchEventListener(self.changeTag)
		tag_target[3]:setString(hp.lang.getStrByID(5603))
		self.tag_target = tag_target

		local tag_rewards = {}
		tag_rewards[1] = panel_tagFrame:getChildByName("Image_rewards")
		tag_rewards[2] = panel_tagFrame:getChildByName("Image_selected2")
		tag_rewards[3] = panel_tagContent:getChildByName("Label_rewards")
		tag_rewards[1]:addTouchEventListener(self.changeTag)
		tag_rewards[3]:setString(hp.lang.getStrByID(5604))
		self.tag_rewards = tag_rewards

		local tag_ranking = {}
		tag_ranking[1] = panel_tagFrame:getChildByName("Image_ranking")
		tag_ranking[2] = panel_tagFrame:getChildByName("Image_selected3")
		tag_ranking[3] = panel_tagContent:getChildByName("Label_ranking")
		tag_ranking[1]:addTouchEventListener(self.changeTag)
		tag_ranking[3]:setString(hp.lang.getStrByID(5605))
		self.tag_ranking = tag_ranking

		local tag_member = {}
		tag_member[1] = panel_tagFrame:getChildByName("Image_member")
		tag_member[2] = panel_tagFrame:getChildByName("Image_selected4")
		tag_member[3] = panel_tagContent:getChildByName("Label_member")
		tag_member[1]:addTouchEventListener(self.changeTag)
		tag_member[3]:setString(hp.lang.getStrByID(5606))
		self.tag_member = tag_member

		self.checkedColor = self.tag_target[3]:getColor()
		self.unCheckedColor = self.tag_rewards[3]:getColor()
		self.currentTag = self.tag_target
	else
		self.uiFrame:setTopShadePosY(820)
		local panel_tagContent = widget:getChildByName("Panel_tagContent")
		local panel_tagFrame = widget:getChildByName("Panel_tagFrame")
		panel_tagContent:setVisible(false)
		panel_tagFrame:setVisible(false)
	end
end

function UI_unionActivity:switchTag(flag_)
	if self.currentUI then
		self:removeChildUI(self.currentUI)
	end
	activity_info = player.unionActivityMgr.getActivity()
	self.currentUI = uiTbl[flag_].new(activity_info)
	self:addChildUI(self.currentUI)
	self.flag = flag_
end

function UI_unionActivity:onRemove()
	UNION_ACTIVITY_PAGE = 0
	self.super.onRemove(self)
end

function UI_unionActivity:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_ACTIVITY then
		if param_ == 2 then
			self:switchTag(4)
		elseif param_ == 3 then
			self:removeChildUI(self.currentUI)
			self.currentUI = nil

			activity_info = player.unionActivityMgr.getActivity()

			self.ui_history = uiTbl[5].new(activity_info)
			self:addChildUI(self.ui_history)

			if activity_info.status == UNION_ACTIVITY_STATUS.OPEN then
				self.uiFrame:setTopShadePosY(820)
				self.panel_tagFrame:setVisible(false)
				self.panel_tagContent:setVisible(false)
			end
		end
	end
end