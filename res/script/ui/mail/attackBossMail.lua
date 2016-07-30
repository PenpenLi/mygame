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
	
	-- 普通boss
	-- [21157,0,0,[2,1],10403,1200000,1200000,0]		-- 未击杀
	-- [23251,24401,0,[3,24000],10401,600000,0,600000]	-- 击杀
	
	-- 精英boss
	-- [0,0,0,[0,0],20101,12000000,12000000,0,1,14,40]	-- 未击杀
	-- [0,13001,6001,[0,0],20101,12000000,0,1,1,14,40]	-- 击杀

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
	local server = annex[9]
	local x = annex[10]
	local y = annex[11]
	local isEliteBoss = res[1] == 0

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
	if isEliteBoss then
		listRoot:removeItem(1)
	else
		local resInfo = hp.gameDataLoader.getInfoBySid("resInfo", res[1] + 1)
		local panel_res = listRoot:getChildByName("Panel_res")
		local content_res = panel_res:getChildByName("Panel_content")
		content_res:getChildByName("Label_text"):setString(hp.lang.getStrByID(7604))
		content_res:getChildByName("Label_num"):setString(hp.lang.getStrByID(7606))
		content_res:getChildByName("Label_resText"):setString(resInfo.name)
		content_res:getChildByName("Label_resNum"):setString(res[2])
		content_res:getChildByName("Image_icon"):loadTexture(config.dirUI.common .. resInfo.imageBig)
	end

	-- info
	-- ===============================
	local panel_info = listRoot:getChildByName("Panel_info")
	-- bossInfo
	local bossInfo
	if isEliteBoss then
		bossInfo = hp.gameDataLoader.getInfoBySid("newBoss", bossID)
	else
		bossInfo = hp.gameDataLoader.getInfoBySid("boss", bossID)
	end
	local panel_bossInfoContent = panel_info:getChildByName("Panel_bossInfoContent")
	local panel_bossInfoFrame = panel_info:getChildByName("Panel_bossInfoFrame")
	panel_bossInfoContent:getChildByName("Label_title"):setString(hp.lang.getStrByID(7908))
	panel_bossInfoContent:getChildByName("Label_name"):setString(bossInfo.name)
	panel_bossInfoContent:getChildByName("Image_icon"):loadTexture(config.dirUI.bossHead .. bossInfo.headPic)
	local label_pos = panel_bossInfoContent:getChildByName("Label_pos")
	label_pos:setString(string.format(hp.lang.getStrByID(7718), hp.gameDataLoader.getInfoBySid("serverList", server).name, x, y))
	local width = label_pos:getContentSize().width
	local image_line = panel_bossInfoContent:getChildByName("Image_line")
	local size = image_line:getSize()
	size.width = width
	image_line:setSize(size)
	-- bossHp
	local panel_bossHpContent = panel_info:getChildByName("Panel_bossHpContent")
	local panel_bossHpFrame = panel_info:getChildByName("Panel_bossHpFrame")
	panel_bossHpContent:getChildByName("Label_title"):setString(hp.lang.getStrByID(1028))
	panel_bossHpContent:getChildByName("Label_hp"):setString(math.floor(bossHp / bossMaxHp * 100) .. "%")
	panel_bossHpContent:getChildByName("Label_info"):setString(string.format(hp.lang.getStrByID(8025), math.floor(attHp / bossMaxHp * 100)))
	panel_bossHpContent:getChildByName("ProgressBar_hp"):setPercent(bossHp / bossMaxHp * 100)
	-- attRewards
	local panel_rewards1Content = panel_info:getChildByName("Panel_rewards1Content")
	local panel_rewards1Frame = panel_info:getChildByName("Panel_rewards1Frame")
	if isEliteBoss then
		if killRewards ~= 0 then
			local materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", killRewards)
			panel_rewards1Content:getChildByName("Label_title"):setString(hp.lang.getStrByID(8032))
			panel_rewards1Content:getChildByName("Label_info"):setString(materialInfo.name)
			panel_rewards1Content:getChildByName("Image_icon"):loadTexture(config.dirUI.material .. materialInfo.type .. ".png")
		else
			panel_rewards1Content:setVisible(false)
			panel_rewards1Frame:setVisible(false)
		end
	else
		local attRewardsInfo = hp.gameDataLoader.getInfoBySid("item", attRewards)
		panel_rewards1Content:getChildByName("Label_title"):setString(hp.lang.getStrByID(8026))
		panel_rewards1Content:getChildByName("Label_info"):setString(attRewardsInfo.name)
		panel_rewards1Content:getChildByName("Image_icon"):loadTexture(config.dirUI.item .. attRewards .. ".png")
	end
	-- killRewards
	local panel_rewards2Content = panel_info:getChildByName("Panel_rewards2Content")
	local panel_rewards2Frame = panel_info:getChildByName("Panel_rewards2Frame")
	local panel_rewards3Content = panel_info:getChildByName("Panel_rewards3Content")
	local panel_rewards3Frame = panel_info:getChildByName("Panel_rewards3Frame")
	if killRewards == 0 or isEliteBoss then
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
		-- not kill
		if unionRewards == 0 then
			panel_rewards2Content:setVisible(false)
			panel_rewards2Frame:setVisible(false)
		else
			panel_rewards2Content:setPositionY(panel_rewards2Content:getPositionY() - h)
			panel_rewards2Frame:setPositionY(panel_rewards2Frame:getPositionY() - h)

			local unionGiftInfo = hp.gameDataLoader.getInfoBySid("unionGift", unionRewards)
			panel_rewards2Content:getChildByName("Label_title"):setString(hp.lang.getStrByID(8028))
			panel_rewards2Content:getChildByName("Label_info"):setString(unionGiftInfo.name)
			panel_rewards2Content:getChildByName("Image_icon"):loadTexture(config.dirUI.unionGift .. unionGiftInfo.type .. ".png")
		end
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

	-- goto
	-- ===============================
	local function goto(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if game.curScene.mapLevel == 2 then
				self:closeAll()
				game.curScene:gotoPosition(cc.p(x, y), "", server)
			else
				self:close()
				require("scene/kingdomMap")
				local map = kingdomMap.new()
				map:enter()
				map:gotoPosition(cc.p(x, y), "", server)
			end
		end
	end
	label_pos:addTouchEventListener(goto)

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
