--
-- ui/mainBuilding/mainBuildingProfile.lua
-- 主城信息一览
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_mainBuildingProfile = class("UI_mainBuildingProfile", UI)

local titleID_ = {5240, 5278, 5239}

--init
function UI_mainBuildingProfile:init(building_, tab_)
	-- data
	-- ===============================
	self.building = building_
	self.tab = tab_

	-- ui data
	self.uiTab = {}
	self.label = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(building_.bInfo.name)
	uiFrame:setTopShadePosY(666)
	local uiHeader = UI_buildingHeader.new(building_)
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)

	self.sizeSelected = self.uiTab[3]:getScale()
	self.sizeUnselected = self.uiTab[1]:getScale()
	
	self:tabPage(self.tab)
end

function UI_mainBuildingProfile:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainBuildingProfile.json")

	local content_ = self.wigetRoot:getChildByName("Panel_headCont")
	for i = 1, 3 do
		self.uiTab[i] = content_:getChildByName("ImageView_"..i)
		self.label[i] = content_:getChildByName("Label_"..i)
		self.label[i]:setString(hp.lang.getStrByID(titleID_[i]))
		self.uiTab[i]:setTag(i)
		self.uiTab[i]:addTouchEventListener(self.onTabTouched)
	end
	self.colorSelected = self.label[3]:getColor()
	self.colorUnselected = self.label[1]:getColor()

	self.listView = self.wigetRoot:getChildByName("ListView_info")
	self.item1 = self.listView:getChildByName("Panel_5_0_1"):clone()
	self.item1:retain()
	self.item2 = self.listView:getChildByName("Panel_5_1_2"):clone()
	self.item2:retain()
	self.listView:removeAllItems()
end

function UI_mainBuildingProfile:tabPage(id_)
	if self.id == id_ then
		return
	end
	self.id = id_

	local scale_ = {self.sizeUnselected, self.sizeUnselected}	
	local color_ = {self.colorUnselected, self.colorUnselected}
	scale_[id_-1] = self.sizeSelected
	color_[id_-1] = self.colorSelected

	for i = 2, 3 do
		self.uiTab[i]:setColor(color_[i-1])
		self.uiTab[i]:setScale(scale_[i-1])
		self.label[i]:setColor(color_[i-1])
		self.label[i]:setScale(scale_[i-1])
	end

	if id_ == 3 then
		self:refreshPage3()
	elseif id_ == 2 then
		self:refreshPage2()
	elseif id_ == 1 then
		require "ui/mainBuilding"
		ui_ = UI_mainBuilding.new(self.building)
		self:addUI(ui_)
		self:close()
	end
end

function UI_mainBuildingProfile:refreshPage2()
	self.listView:removeAllItems()
	self.listView:refreshView()

	local bufShowTable_ = hp.gameDataLoader.getTable("bufShow")

	for i, v in ipairs(bufShowTable_) do
		-- 标题
		local title_ = self.item1:clone()
		title_:getChildByName("Panel_36"):getChildByName("Label_37"):setString(v.name)
		self.listView:pushBackCustomItem(title_)

		-- 内容
		local index_ = 1
		for j, w in ipairs(v.attrs) do
			local info_ = hp.gameDataLoader.getInfoBySid("attr", w)

			local item_ = self.item2:clone()
			self.listView:pushBackCustomItem(item_)
			local content_ = item_:getChildByName("Panel_39_0")
			if index_%2 == 1 then
				item_:getChildByName("Panel_39"):setVisible(true)
			end

			-- 名称
			content_:getChildByName("Label_43"):setString(info_.desc)

			-- 加成
			local add_ = player.helper.getAttrAddn(w) / 100
			if add_ < 0 then
				add_ = 0
			end
			content_:getChildByName("Label_43_1"):setString(add_.."%")
			index_ = index_ + 1
		end
	end
end

function UI_mainBuildingProfile:refreshPage3()
	self.listView:removeAllItems()
	self.listView:refreshView()

	local function fillBuildInfo(info_, index_)
		if info_ == nil then
			return
		end

		-- 排序
		local function compare(e1, e2)
			if e1.lv > e2.lv then
				return true
			end

			return false
		end

		table.sort(info_, compare)

		for i, v in pairs(info_) do
			local item_ = self.item2:clone()
			self.listView:pushBackCustomItem(item_)
			local content_ = item_:getChildByName("Panel_39_0")
			if index_%2 == 1 then
				item_:getChildByName("Panel_39"):setVisible(true)
			end

			local info_ = hp.gameDataLoader.getInfoBySid("building", v.sid)
			-- 名称
			content_:getChildByName("Label_43"):setString(info_.name)

			-- 等级
			content_:getChildByName("Label_43_1"):setString(v.lv)
			index_ = index_ + 1
		end
		return index_
	end

	-- 城内建筑
	-- 标题
	local title_ = self.item1:clone()
	title_:getChildByName("Panel_36"):getChildByName("Label_37"):setString(hp.lang.getStrByID(2301))
	self.listView:pushBackCustomItem(title_)

	-- 标题
	local item_ = self.item2:clone()
	self.listView:pushBackCustomItem(item_)
	local content_ = item_:getChildByName("Panel_39_0")
	content_:getChildByName("Label_43"):setString(hp.lang.getStrByID(5241))
	content_:getChildByName("Label_43_1"):setString(hp.lang.getStrByID(5242))

	local ruralInfo_ = hp.gameDataLoader.getTable("building")
	local index_ = 1
	for i, v in ipairs(ruralInfo_) do
		if v.type == 1 then
			local rural_ = player.buildingMgr.getBuildingsBySid(v.sid)
			index_ = fillBuildInfo(rural_, index_)
		end
	end

	-- 城外建筑
	-- 标题
	local title_ = self.item1:clone()
	title_:getChildByName("Panel_36"):getChildByName("Label_37"):setString(hp.lang.getStrByID(2302))
	self.listView:pushBackCustomItem(title_)

	-- 标题
	local item_ = self.item2:clone()
	self.listView:pushBackCustomItem(item_)
	local content_ = item_:getChildByName("Panel_39_0")
	content_:getChildByName("Label_43"):setString(hp.lang.getStrByID(5241))
	content_:getChildByName("Label_43_1"):setString(hp.lang.getStrByID(5242))

	local ruralInfo_ = hp.gameDataLoader.getTable("building")
	local index_ = 1
	for i, v in ipairs(ruralInfo_) do
		if v.type == 2 then
			local urban_ = player.buildingMgr.getBuildingsBySid(v.sid)
			index_ = fillBuildInfo(urban_, index_)
		end
	end
end

function UI_mainBuildingProfile:initCallBack()
	local function onTabTouched(sender, eventType)
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorSelected)
			self.label[sender:getTag()]:setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorSelected)
				self.label[sender:getTag()]:setColor(self.colorSelected)
			else
				sender:setColor(self.colorUnselected)
				self.label[sender:getTag()]:setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			self:tabPage(sender:getTag())
		end
	end

	self.onTabTouched = onTabTouched
end

function UI_mainBuildingProfile:onMsg(msg_, param_)
end

function UI_mainBuildingProfile:onRemove()
	self.item1:release()
	self.item2:release()
	self.super.onRemove(self)
end