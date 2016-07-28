--
-- ui/quest/dailyInfo.lua
-- 日常信息
--===================================
require "ui/frame/popFrame"


UI_dailyInfo = class("UI_dailyInfo", UI)

local textID = {1420, 1421, 1422, 1423, 1424, 1425}
local imageList = {"quest_16.png", "quest_15.png", "quest_14.png", "quest_13.png", "quest_11.png", "quest_12.png"}
local nameList = {"", "0", "1", "2", "3", "4"}
local questTypeImage = {"quest_27.png", "quest_28.png", "quest_29.png"}
local questTypeName = {1401,1402,1403}
local questDesID = {{1417,1418,1419},{1436,1437,1438},{1439,1440,1441}}

--init
function UI_dailyInfo:init(type_)
	-- data
	-- ===============================
	self.type = type_

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(questTypeName[self.type]))


	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_dailyInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "dailyInfo.json")
	local content = self.wigetRoot:getChildByName("Panel_22943")

	content:getChildByName("Label_22946"):setString(hp.lang.getStrByID(questDesID[self.type][1]))

	for i, v in ipairs(nameList) do
		content:getChildByName("ImageView_22947_Copy"..v):loadTexture(config.dirUI.common..imageList[i])
		content:getChildByName("Label_22948_Copy"..v):setString(hp.lang.getStrByID(textID[i]))
	end

	content:getChildByName("Label_22969"):setString(hp.lang.getStrByID(questDesID[self.type][2]))
	content:getChildByName("Label_22970"):setString(hp.lang.getStrByID(questDesID[self.type][3]))

	-- 图片
	content:getChildByName("ImageView_22944"):getChildByName("ImageView_22945"):loadTexture(config.dirUI.common..questTypeImage[self.type])
end