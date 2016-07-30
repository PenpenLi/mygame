--
-- ui/activity/unionActivity/histroyReward.lua
-- 联盟活动_历史奖励详情
--=============================================

require "ui/frame/popFrame"
require "ui/UI"

UI_histroyReward = class("UI_histroyReward", UI)


function UI_histroyReward:init(sid, name, rank)
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActivityInfo_historyReward.json")
	local uiFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(5655))
	
	local content = wigetRoot:getChildByName("Panel_content")
	content:getChildByName("Label_title1"):setString(hp.lang.getStrByID(5657))
	content:getChildByName("Label_title2"):setString(name)
	content:getChildByName("Label_title3"):setString(hp.lang.getStrByID(5658))
	content:getChildByName("Label_title4"):setString(string.format(hp.lang.getStrByID(5649), rank))

	local info = hp.gameDataLoader.getInfoBySid("unionGift", sid)
	content:getChildByName("Image_icon"):loadTexture(config.dirUI.unionGift .. info.type .. ".png")
	content:getChildByName("Label_desc"):setString(info.name)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
