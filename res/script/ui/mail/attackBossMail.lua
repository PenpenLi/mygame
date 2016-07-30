--
-- ui/mail/attackBossMail.lua
-- 攻击boss邮件
--===================================

require "ui/UI"

UI_attackBossMail = class("UI_attackBossMail", UI)


-- init
function UI_attackBossMail:init(mailInfo, mailType_, mailIndex)

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bossMail.json")
	local listRoot = wigetRoot:getChildByName("ListView_root")
	
	-- 攻击物品，击杀物品，联盟礼包，资源（类型，数量），bossId，总血量，剩余血量，攻击血量
	-- [21157,0,0,[2,1],10403,1200000,1200000,0]
	-- [23251,24401,0,[3,24000],10401,600000,0,600000],1414657085,1],

	-- data prepare
	local annex = mailInfo.annex
	local attRewards = annex[1]
	local killRewards = annex[2]
	local unionRewards = annex[3]
	local res = annex[4]
	local bossID = annex[5]
	local bossMaxHp = annex[6]
	local bossHp = annex[7]
	local attHp = annex[8]

	-- title
	-- ===============================
	local panel_title = listRoot:getChildByName("Panel_title")
	local content_title = panel_title:getChildByName("Panel_content")
	if killRewards == 0 then
		content_title:getChildByName("Label_title"):setString(hp.lang.getStrByID(8024))
	else
		content_title:getChildByName("Label_title"):setString(hp.lang.getStrByID(8023))
	end

	-- res
	-- ===============================
	local resInfo = hp.gameDataLoader.getInfoBySid("resInfo", res[1] + 1)
	local panel_res = listRoot:getChildByName("Panel_res")
	local content_res = panel_res:getChildByName("Panel_content")
	content_res:getChildByName("Label_text"):setString(hp.lang.getStrByID(7604))
	content_res:getChildByName("Label_num"):setString(hp.lang.getStrByID(7606))
	content_res:getChildByName("Label_resText"):setString(resInfo.name)
	content_res:getChildByName("Label_resNum"):setString(res[2])
	content_res:getChildByName("Image_icon"):loadTexture(config.dirUI.common .. resInfo.imageBig)

	-- info
	-- ===============================
	local panel_info = listRoot:getChildByName("Panel_info")
	-- bossInfo
	local bossInfo = hp.gameDataLoader.getInfoBySid("boss", bossID)
	local panel_bossInfoContent = panel_info:getChildByName("Panel_bossInfoContent")
	local panel_bossInfoFrame = panel_info:getChildByName("Panel_bossInfoFrame")
	panel_bossInfoContent:getChildByName("Label_title"):setString(hp.lang.getStrByID(7908))
	panel_bossInfoContent:getChildByName("Label_name"):setString(bossInfo.name)
	panel_bossInfoContent:getChildByName("Image_icon"):loadTexture(config.dirUI.bossHead .. bossInfo.headPic)
	-- bossHp
	local panel_bossHpContent = panel_info:getChildByName("Panel_bossHpContent")
	local panel_bossHpFrame = panel_info:getChildByName("Panel_bossHpFrame")
	panel_bossHpContent:getChildByName("Label_title"):setString(hp.lang.getStrByID(1028))
	panel_bossHpContent:getChildByName("Label_hp"):setString(math.floor(bossHp / bossMaxHp * 100) .. "%")
	panel_bossHpContent:getChildByName("Label_info"):setString(string.format(hp.lang.getStrByID(8025), math.floor(attHp / bossMaxHp * 100)))
	panel_bossHpContent:getChildByName("ProgressBar_hp"):setPercent(bossHp / bossMaxHp * 100)
	-- attRewards
	local attRewardsInfo = hp.gameDataLoader.getInfoBySid("item", attRewards)
	local panel_rewards1Content = panel_info:getChildByName("Panel_rewards1Content")
	local panel_rewards1Frame = panel_info:getChildByName("Panel_rewards1Frame")
	panel_rewards1Content:getChildByName("Label_title"):setString(hp.lang.getStrByID(8026))
	panel_rewards1Content:getChildByName("Label_info"):setString(attRewardsInfo.name)
	panel_rewards1Content:getChildByName("Image_icon"):loadTexture(config.dirUI.item .. attRewards .. ".png")
	-- killRewards
	local panel_rewards2Content = panel_info:getChildByName("Panel_rewards2Content")
	local panel_rewards2Frame = panel_info:getChildByName("Panel_rewards2Frame")
	local panel_rewards3Content = panel_info:getChildByName("Panel_rewards3Content")
	local panel_rewards3Frame = panel_info:getChildByName("Panel_rewards3Frame")
	if killRewards == 0 then
		-- not kill
		panel_rewards2Content:setVisible(false)
		panel_rewards2Frame:setVisible(false)
		panel_rewards3Content:setVisible(false)
		panel_rewards3Frame:setVisible(false)
		local size = panel_info:getSize()
		local h = size.height / 3
		size.height = size.height - h
		panel_info:setSize(size)
		panel_bossInfoContent:setPositionY(panel_bossInfoContent:getPositionY() - h)
		panel_bossInfoFrame:setPositionY(panel_bossInfoFrame:getPositionY() - h)
		panel_bossHpContent:setPositionY(panel_bossHpContent:getPositionY() - h)
		panel_bossHpFrame:setPositionY(panel_bossHpFrame:getPositionY() - h)
		panel_rewards1Content:setPositionY(panel_rewards1Content:getPositionY() - h)
		panel_rewards1Frame:setPositionY(panel_rewards1Frame:getPositionY() - h)
	else
		local killRewardsInfo = hp.gameDataLoader.getInfoBySid("item", killRewards)
		panel_rewards2Content:getChildByName("Label_title"):setString(hp.lang.getStrByID(8027))
		panel_rewards2Content:getChildByName("Label_info"):setString(killRewardsInfo.name)
		panel_rewards2Content:getChildByName("Image_icon"):loadTexture(config.dirUI.item .. killRewards .. ".png")
		-- unionRewards
		if unionRewards == 0 then
			panel_rewards3Content:setVisible(false)
			panel_rewards3Frame:setVisible(false)
			local size = panel_info:getSize()
			local h = size.height / 3
			size.height = size.height - h
			panel_info:setSize(size)
			panel_bossInfoContent:setPositionY(panel_bossInfoContent:getPositionY() - h)
			panel_bossInfoFrame:setPositionY(panel_bossInfoFrame:getPositionY() - h)
			panel_bossHpContent:setPositionY(panel_bossHpContent:getPositionY() - h)
			panel_bossHpFrame:setPositionY(panel_bossHpFrame:getPositionY() - h)
			panel_rewards1Content:setPositionY(panel_rewards1Content:getPositionY() - h)
			panel_rewards1Frame:setPositionY(panel_rewards1Frame:getPositionY() - h)
			panel_rewards2Content:setPositionY(panel_rewards2Content:getPositionY() - h)
			panel_rewards2Frame:setPositionY(panel_rewards2Frame:getPositionY() - h)
		else
			local unionRewardsInfo = hp.gameDataLoader.getInfoBySid("unionGift", unionRewards)
			panel_rewards3Content:getChildByName("Label_title"):setString(hp.lang.getStrByID(8028))
			panel_rewards3Content:getChildByName("Label_info"):setString(unionRewardsInfo.name)
			panel_rewards3Content:getChildByName("Image_icon"):loadTexture(config.dirUI.unionGift .. unionRewardsInfo.type .. ".png")
		end
	end

	-- del
	-- ===============================
	local panel_oper = listRoot:getChildByName("Panel_oper")
	local content_oper = panel_oper:getChildByName("Panel_content")
	content_oper:getChildByName("Label_delete"):setString(hp.lang.getStrByID(1221))

	function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	content_oper:getChildByName("Image_delete"):addTouchEventListener(delBtnOnTouched)
	
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
