--
-- ui/mail/unionActMail.lua
-- 奖励邮件
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_unionActMail = class("UI_unionActMail", UI)

function UI_unionActMail:init(mailInfo, mailType, mailIndex)

	-- data
	-- [3,26,0,"null","个人活动|积分奖励","",[1412215800000,1412217600000,5000,4001]
	-- [4,27,0,"null","个人活动|排名奖励","",[1412337600000,1412339400000,0,7001]
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActMail.json")

	-- 控件
	local listviewRoot = wigetRoot:getChildByName("ListView_root")
	local panel_head = listviewRoot:getChildByName("Panel_head")
	local panel_desc = listviewRoot:getChildByName("Panel_desc")
	local panel_rewards = listviewRoot:getChildByName("Panel_rewards")
	local panel_oper = listviewRoot:getChildByName("Panel_oper")

	local title_head = panel_head:getChildByName("Panel_content"):getChildByName("Label_info")

	local content_desc = panel_desc:getChildByName("Panel_content")
	content_desc:getChildByName("Label_title"):setString(hp.lang.getStrByID(10907))
	content_desc:getChildByName("Label_info2"):setString(hp.lang.getStrByID(10905))
	
	local beginTime = os.date("%Y/%m/%d", mailInfo.annex[1] / 1000)
	local endTime = os.date("%Y/%m/%d", mailInfo.annex[2] / 1000)
	content_desc:getChildByName("Label_time"):setString(beginTime .. " - " .. endTime)

	local content_rewards = panel_rewards:getChildByName("Panel_content")
	content_rewards:getChildByName("Label_title"):setString(hp.lang.getStrByID(10906))

	local info = hp.gameDataLoader.getInfoBySid("unionGift" , mailInfo.annex[4])
	content_rewards:getChildByName("Image_icon"):loadTexture(config.dirUI.unionGift .. info.type .. ".png")
	content_rewards:getChildByName("Label_type"):setString(info.name)

	if mailInfo.type == 26 then
		title_head:setString(hp.lang.getStrByID(10901))
		content_desc:getChildByName("Label_info1"):setString(hp.lang.getStrByID(10903))
		content_desc:getChildByName("Label_score"):setString(mailInfo.annex[3])
	elseif mailInfo.type == 27 then
		title_head:setString(hp.lang.getStrByID(10902))
		content_desc:getChildByName("Label_info1"):setString(hp.lang.getStrByID(10904))
		content_desc:getChildByName("Label_score"):setString(mailInfo.annex[3]+1)
	end

	local function deleteMail(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType, {mailIndex})
		end
	end
	panel_oper:getChildByName("Panel_content"):getChildByName("Image_delete"):addTouchEventListener(deleteMail)
	panel_oper:getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(1221))

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end