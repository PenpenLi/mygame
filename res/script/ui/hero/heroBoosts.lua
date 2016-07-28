--
-- ui/hero/heroBoosts.lua
-- 英雄更多信息
--===================================
require "ui/UI"
require "ui/frame/popFrame"


UI_heroBoosts = class("UI_heroBoosts", UI)


local attrList = 
{
	{1,21,11,31,2,22,12,32,3,23,13,33,51,52},
	{43,41,42,44,110,47,301,302,45},
	{107,106,109,102,103,104,105,101,111}
}
--init
function UI_heroBoosts:init()
	-- data
	-- ===============================
	-- ui
	-- ===============================

	-- 初始化界面
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(2502))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_heroBoosts:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "heroBoosts.json")

	local listView = self.wigetRoot:getChildByName("ListView_info")

	-- 英雄攻击力
	self.wigetRoot:getChildByName("Panel_head"):getChildByName("Label_power"):setString(string.format(hp.lang.getStrByID(2032),player.getPower()))


	local function adjustHeight(parent_, panelList_, listView_, num_)
		local deltaHeight = 31 * num_
		local size_ = parent_:getSize()
		size_.height = size_.height + deltaHeight
		parent_:setSize(size_)

		for i,v in ipairs(panelList_) do
			for i,v in ipairs(v:getChildren()) do
				local x_, y_ = v:getPosition()
				v:setPosition(x_, y_ + deltaHeight)
			end
		end
		size_ = listView_:getSize()
		size_.height = size_.height + deltaHeight
		listView_:setSize(size_)
	end

	-- 兵种增益
	local panel_info1 = listView:getChildByName("Panel_info1")
	local panel_bg1 = panel_info1:getChildByName("Panel_bg")
	local listView_items1 = panel_info1:getChildByName("ListView_items")
	local infoDemo = listView_items1:getChildByName("Panel_demo")
	local panelTitle1 = panel_info1:getChildByName("Panel_title")
	panelTitle1:getChildByName("Label_title"):setString(hp.lang.getStrByID(2504))
	-- 全军增益
	local panel_info2 = listView:getChildByName("Panel_info2")
	local panel_bg2 = panel_info2:getChildByName("Panel_bg")
	local listView_items2 = panel_info2:getChildByName("ListView_items")
	local panelTitle2 = panel_info2:getChildByName("Panel_title")
	panelTitle2:getChildByName("Label_title"):setString(hp.lang.getStrByID(2505))
	-- 经济增益
	local panel_info3 = listView:getChildByName("Panel_info3")
	local panel_bg3 = panel_info3:getChildByName("Panel_bg")
	local listView_items3 = panel_info3:getChildByName("ListView_items")
	local panelTitle3 = panel_info3:getChildByName("Panel_title")
	panelTitle3:getChildByName("Label_title"):setString(hp.lang.getStrByID(2506))


	listView_items1:removeLastItem()
	listView_items2:removeLastItem()
	listView_items3:removeLastItem()

	for i, v in ipairs(attrList[1]) do
		local cloneInfo = infoDemo:clone()
		local attr = hp.gameDataLoader.getInfoBySid("attr", v)
		if attr ~= nil then
			local value = 0
			cloneInfo:getChildByName("Panel_text"):getChildByName("Label_name"):setString(attr.desc)
			cloneInfo:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
			listView_items1:pushBackCustomItem(cloneInfo)
		end
	end
	for i, v in ipairs(attrList[2]) do
		local cloneInfo = infoDemo:clone()
		local attr = hp.gameDataLoader.getInfoBySid("attr", v)
		if attr ~= nil then
			local value = 0
			cloneInfo:getChildByName("Panel_text"):getChildByName("Label_name"):setString(attr.desc)
			cloneInfo:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
			listView_items2:pushBackCustomItem(cloneInfo)
		end
	end
	for i, v in ipairs(attrList[3]) do
		local cloneInfo = infoDemo:clone()
		local attr = hp.gameDataLoader.getInfoBySid("attr", v)
		if attr ~= nil then
			local value = 0
			cloneInfo:getChildByName("Panel_text"):getChildByName("Label_name"):setString(attr.desc)
			cloneInfo:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
			listView_items3:pushBackCustomItem(cloneInfo)
		end
	end
	adjustHeight(panel_info1, {panel_bg1, panelTitle1}, listView_items1, #attrList[1])
	adjustHeight(panel_info2, {panel_bg2, panelTitle2}, listView_items2, #attrList[2])
	adjustHeight(panel_info3, {panel_bg3, panelTitle3}, listView_items3, #attrList[3])

end
