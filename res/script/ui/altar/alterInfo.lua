--
-- ui/altar/altarInfo.lua
-- 祭坛更多信息
--===================================
require "ui/UI"
require "ui/frame/popFrame"


UI_altarInfo = class("UI_altarInfo", UI)


--init
function UI_altarInfo:init(building_)
	-- data
	-- ===============================
	self.building = building_
	local bInfo = building_.bInfo
	-- ui
	-- ===============================

	-- 初始化界面
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, building_.bInfo.name)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_altarInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "altarInfo.json")

	local listView = self.wigetRoot:getChildByName("ListView_info")

	-- 描述
	self.wigetRoot:getChildByName("Panel_head"):getChildByName("Label_desc"):setString(self.building.bInfo.desc)


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

	-- 祭坛信息
	local Panel_info = listView:getChildByName("Panel_info")
	local Panel_bg = Panel_info:getChildByName("Panel_bg")
	local ListView_items = Panel_info:getChildByName("ListView_items")
	local oneBuildInfo = ListView_items:getChildByName("Panel_demo")
	local PanelTitle = Panel_info:getChildByName("Panel_title")
	--PanelContent:getChildByName("Label_title"):setString(hp.lang.getStrByID(1104))
	--local panelTemp = ListView_items:getChildByName("Panel_temp"):getChildByName("Panel_text")
	--panelTemp:getChildByName("Label_level"):setString(hp.lang.getStrByID(1105))
	ListView_items:removeLastItem()

	local altarInfos = game.data.altar
	local totalLevel = table.getn(altarInfos)
	for i = 1, totalLevel do
		local cloneInfo = oneBuildInfo:clone()
		local level = game.data.altar[i].level
		cloneInfo:getChildByName("Panel_text"):getChildByName("Label_level"):setString(level)
		cloneInfo:getChildByName("Panel_text"):getChildByName("Label_att"):setString(altarInfos[i].attackRate.."%")
		cloneInfo:getChildByName("Panel_text"):getChildByName("Label_def"):setString(altarInfos[i].defanceRate.."%")
		cloneInfo:getChildByName("Panel_text"):getChildByName("Label_life"):setString(altarInfos[i].lifeRate.."%")
		cloneInfo:getChildByName("Panel_text"):getChildByName("Label_speed"):setString(altarInfos[i].speedRate.."%")
		ListView_items:pushBackCustomItem(cloneInfo)
		-- 当前选中效果
		if self.building.build.lv == level then
			local bgImage = ccui.ImageView:create()
			bgImage:loadTexture(config.dirUI.common.."ui_barrack_current.png")
			bgImage:setPosition(cc.p(320, 15))			
			cloneInfo:getChildByName("Panel_bg"):addChild(bgImage)
		end
	end
	adjustHeight(Panel_info, {Panel_bg, PanelTitle}, ListView_items, totalLevel)

end
