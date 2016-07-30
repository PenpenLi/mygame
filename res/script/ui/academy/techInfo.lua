--
-- ui/academy/techInfo.lua
-- 科技信息
--===================================
require "ui/UI"
require "ui/frame/popFrame"


UI_techInfo = class("UI_techInfo", UI)

local specialID = 110

--init
function UI_techInfo:init(sid_)
	-- data
	-- ===============================
	self.sid = sid_
	-- self.maxLv = researchMgr.getResearchMaxLv(sid_)
	-- self.researchInfo = researchMgr.getResearchNextLvInfo(sid_)
	self.baseInfo = hp.gameDataLoader.getInfoBySid("research", sid_*100+1)

	-- ui
	-- ===============================

	-- 初始化界面
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, self.baseInfo.name)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_techInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "technology.json")

	local listView = self.wigetRoot:getChildByName("ListView_4")

	local desc_ = listView:getChildByName("Panel_5_1")
	desc_:getChildByName("Panel_7"):getChildByName("Label_9"):setString(hp.lang.getStrByID(5501))
	local title_ = listView:getChildByName("Panel_5")
	local content_ = title_:getChildByName("Panel_7")
	content_:getChildByName("Label_9"):setString(hp.lang.getStrByID(1039))
	content_:getChildByName("Label_10"):setString(hp.lang.getStrByID(5409))
	self.uiItem1 = listView:getChildByName("Panel_5_0_1"):clone()
	listView:removeLastItem()
	self.uiItem1:retain()
	self.uiItem = listView:getChildByName("Panel_5_0"):clone()
	listView:removeLastItem()
	self.uiItem:retain()

	local info_ = self.baseInfo
	local index_ = 1
	local level_ = player.researchMgr.getResearchLv(self.sid)
	while info_ ~= nil do
		local item_ = nil
		if self.sid == specialID then
			item_ = self.uiItem1:clone()
		else
			item_ = self.uiItem:clone()
		end
		if level_ == info_.level then
			item_:getChildByName("Panel_6"):getChildByName("Image_23"):setVisible(true)
		else
			if index_%2 == 0 then
				item_:getChildByName("Panel_6"):getChildByName("Image_8"):setVisible(true)
			end
		end
		
		listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_7")
		content_:getChildByName("Label_9"):setString(info_.level)
		content_:getChildByName("Label_10"):setString(info_.desc)
		index_ = index_ + 1
		info_ = hp.gameDataLoader.getInfoBySid("research", self.sid*100+index_)
	end
end

function UI_techInfo:onRemove()
	self.uiItem:release()
	self.uiItem1:release()
	self.super.onRemove(self)
end