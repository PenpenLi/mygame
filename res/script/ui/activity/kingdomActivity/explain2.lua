--
-- ui/activity/kingdomActivity/explain2.lua
-- 玩法说明_详细
--=============================================

require "ui/frame/popFrame"
require "ui/UI"

UI_explain2 = class("UI_explain2", UI)

-- 初始化
function UI_explain2:init()
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "kingdomAct_explain2.json")
	local uiFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(11104))
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	-- 设置静态数据
	local list = wigetRoot:getChildByName("ListView_root")
	
	local content_title = list:getItem(0):getChildByName("Panel_content")
	content_title:getChildByName("Label_info"):setString(hp.lang.getStrByID(11115))

	local content_score = list:getItem(1):getChildByName("Panel_content")
	content_score:getChildByName("Label_title"):setString(hp.lang.getStrByID(11116))
	content_score:getChildByName("Label_info"):setString(hp.lang.getStrByID(11117))

	local content_others = list:getItem(2):getChildByName("Panel_content")
	content_others:getChildByName("Label_title"):setString(hp.lang.getStrByID(11118))
	content_others:getChildByName("Label_info"):setString(hp.lang.getStrByID(11119))

	local content_take = list:getItem(3):getChildByName("Panel_content")
	content_take:getChildByName("Label_title"):setString(hp.lang.getStrByID(11120))
	content_take:getChildByName("Label_info"):setString(hp.lang.getStrByID(11121))

	local content_permission = list:getItem(4):getChildByName("Panel_content")
	content_permission:getChildByName("Label_title"):setString(hp.lang.getStrByID(11122))
	content_permission:getChildByName("Label_info"):setString(hp.lang.getStrByID(11123))

	local content_rank = list:getItem(5):getChildByName("Panel_content")
	content_rank:getChildByName("Label_title"):setString(hp.lang.getStrByID(11124))
	content_rank:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11125))
	content_rank:getChildByName("Label_info1"):setString(hp.lang.getStrByID(11126))
	content_rank:getChildByName("Label_info2"):setString(hp.lang.getStrByID(11127))
	content_rank:getChildByName("Label_info3"):setString(hp.lang.getStrByID(11128))

	local content_winner = list:getItem(6):getChildByName("Panel_content")
	content_winner:getChildByName("Label_title"):setString(hp.lang.getStrByID(11129))
	content_winner:getChildByName("Label_info"):setString(hp.lang.getStrByID(11130))
end
