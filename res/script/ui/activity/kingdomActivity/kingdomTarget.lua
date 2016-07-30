--
-- ui/activity/kindomActivity/kingdomTarget.lua
-- 王国目标
--=============================================

UI_kingdomTarget = class("UI_kingdomTarget", UI)

-- 初始化
function UI_kingdomTarget:init()
	self:initUI()
end

-- 初始化UI
function UI_kingdomTarget:initUI()
	-- ui
	-- ===========
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "kingdomAct_kingTarget.json")
	-- add ui
	-- ===========
	self:addCCNode(widget)

	-- 设置静态数据
	local list = widget:getChildByName("ListView_root")
	local content_info1 = list:getItem(0):getChildByName("Panel_content")
	local content_info2 = list:getItem(1):getChildByName("Panel_content")

	content_info1:getChildByName("Label_title"):setString(hp.lang.getStrByID(11147))
	content_info1:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11148))

	content_info2:getChildByName("Label_title"):setString(hp.lang.getStrByID(11149))
	content_info2:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11150))
end