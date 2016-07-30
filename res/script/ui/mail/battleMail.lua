--
-- ui/mail/battleMail.lua
-- 战报
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_battleMail = class("UI_battleMail", UI)


--init
function UI_battleMail:init(mailInfo_, mailType_, mailIndex)
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "battleMail.json")
	local listRoot = wigetRoot:getChildByName("ListView_root")

	-- 数据解析
	local info = mailInfo_.annex
	local attWin = info[1] == 0
	local silver = info[2]
	local food = info[3]
	local wood = info[4]
	local stone = info[5]
	local iron = info[6]
	local attInfo = info[7]
	local defInfo = info[8]
	local isWin = true
	local isAtt = true
	local ID = 0
	local K = 0

	-- title panel
	-- ===============================
	local panel_title = listRoot:getChildByName("Panel_title")
	local frame_title = panel_title:getChildByName("Panel_frame")
	local content_title = panel_title:getChildByName("Panel_content")
	local image_bg = frame_title:getChildByName("Image_bg")
	local label_title = content_title:getChildByName("Label_title")

	isAtt = attInfo[4] == player.getID()
	if isAtt then
		ID = defInfo[4]
		K = defInfo[5]
		if not attWin then
			label_title:setString(hp.lang.getStrByID(7602))
			image_bg:loadTexture(config.dirUI.common .. "failedMailHead.png")
			isWin = false
		else
			label_title:setString(hp.lang.getStrByID(7601))
		end
	else
		ID = attInfo[4]
		K = attInfo[5]
		if attWin then
			label_title:setString(hp.lang.getStrByID(7602))
			image_bg:loadTexture(config.dirUI.common .. "failedMailHead.png")
			isWin = false
		else
			label_title:setString(hp.lang.getStrByID(7601))
		end
	end

	-- 胜负，银币，食物，木头，石头，铁
	-- [0,189220,15750,189220,189220,189220,
	
	-- res panel
	-- ===============================
	local panel_res = listRoot:getChildByName("Panel_res")
	local content_res = panel_res:getChildByName("Panel_content")

	content_res:getChildByName("Label_text"):setString(hp.lang.getStrByID(7604))
	content_res:getChildByName("Label_num"):setString(hp.lang.getStrByID(7606))
	content_res:getChildByName("Label_stoneText"):setString(hp.lang.getStrByID(6302))
	content_res:getChildByName("Label_woodText"):setString(hp.lang.getStrByID(6303))
	content_res:getChildByName("Label_ironText"):setString(hp.lang.getStrByID(6304))
	content_res:getChildByName("Label_foodText"):setString(hp.lang.getStrByID(6305))
	content_res:getChildByName("Label_silverText"):setString(hp.lang.getStrByID(6307))

	local label_stoneText = content_res:getChildByName("Label_stoneNum")
	local label_woodText = content_res:getChildByName("Label_woodNum")
	local label_ironText = content_res:getChildByName("Label_ironNum")
	local label_foodText = content_res:getChildByName("Label_foodNum")
	local label_silverText = content_res:getChildByName("Label_silverNum")
	
	local sign = "+"
	if not isWin then
		sign = "-"
		label_stoneText:setColor(cc.c3b(244, 66, 69))
		label_woodText:setColor(cc.c3b(244, 66, 69))
		label_ironText:setColor(cc.c3b(244, 66, 69))
		label_foodText:setColor(cc.c3b(244, 66, 69))
		label_silverText:setColor(cc.c3b(244, 66, 69))
	end
	label_stoneText:setString(sign .. stone)
	label_woodText:setString(sign .. wood)
	label_ironText:setString(sign .. iron)
	label_foodText:setString(sign .. food)
	label_silverText:setString(sign .. silver)

	-- player panel
	-- ===============================
	local panel_player = listRoot:getChildByName("Panel_player")
	local content_attPlayer = panel_player:getChildByName("Panel_attContent")
	local content_defPlayer = panel_player:getChildByName("Panel_defContent")
	-- att player panel
	local attTitle
	if attInfo[3] ~= "" then
		attTitle = string.format(hp.lang.getStrByID(8010), attInfo[3]) .. attInfo[1]
	else
		attTitle = attInfo[1]
	end
	content_attPlayer:getChildByName("Label_title"):setString(attTitle)
	content_attPlayer:getChildByName("Label_pos"):setString("K:" .. hp.gameDataLoader.getInfoBySid("serverList", attInfo[5]).name .. " X:" .. attInfo[6] .. " Y:" .. attInfo[7])
	content_attPlayer:getChildByName("Label_powText"):setString(hp.lang.getStrByID(5119))
	content_attPlayer:getChildByName("Label_power"):setString("-" .. attInfo[8])
	content_attPlayer:getChildByName("Image_icon"):loadTexture(config.dirUI.heroHeadpic .. attInfo[2] .. ".png")
	-- def player panel
	local defTitle
	if defInfo[3] ~= "" then
		defTitle = string.format(hp.lang.getStrByID(8010), defInfo[3]) .. defInfo[1]
	else
		defTitle = defInfo[1]
	end
	content_defPlayer:getChildByName("Label_title"):setString(defTitle)
	content_defPlayer:getChildByName("Label_pos"):setString("K:" .. hp.gameDataLoader.getInfoBySid("serverList", defInfo[5]).name .. " X:" .. defInfo[6] .. " Y:" .. defInfo[7])
	content_defPlayer:getChildByName("Label_powText"):setString(hp.lang.getStrByID(5119))
	content_defPlayer:getChildByName("Label_power"):setString("-" .. defInfo[8])
	content_defPlayer:getChildByName("Image_icon"):loadTexture(config.dirUI.heroHeadpic .. defInfo[2] .. ".png")

	local x, y
	-- pos link
	local function goto(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if game.curScene.mapLevel == 2 then
				self:closeAll()
    			game.curScene:gotoPosition(cc.p(x, y), "", K)
    		else
    			self:close()
				require("scene/kingdomMap")
				local map = kingdomMap.new()
				map:enter()
				map:gotoPosition(cc.p(x, y), "", K)
			end
		end
	end
	local pos, line
	if isAtt then
		pos = content_defPlayer:getChildByName("Label_pos")
		line = content_defPlayer:getChildByName("Image_line")
		content_attPlayer:getChildByName("Image_line"):setVisible(false)
		x = defInfo[6]
		y = defInfo[7]
	else
		pos = content_attPlayer:getChildByName("Label_pos")
		line = content_attPlayer:getChildByName("Image_line")
		content_defPlayer:getChildByName("Image_line"):setVisible(false)
		x = attInfo[6]
		y = attInfo[7]
	end
	pos:addTouchEventListener(goto)
	pos:setColor(cc.c3b(27, 172, 255))

	local width = pos:getContentSize().width
	local size = line:getSize()
	size.width = width
	line:setSize(size)

	-- icon link
	local function popPlayerInfo(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			local ui_ = UI_playerInfo.new(ID, hp.gameDataLoader.getInfoBySid("serverList", K).url)
			self:addUI(ui_)
		end
	end
	if isAtt then
		content_defPlayer:getChildByName("Image_icon"):addTouchEventListener(popPlayerInfo)
	else
		content_attPlayer:getChildByName("Image_icon"):addTouchEventListener(popPlayerInfo)
	end

	-- lost panel
	-- ===============================
	local panel_lost = listRoot:getChildByName("Panel_lost")
	local content_attLost = panel_lost:getChildByName("Panel_attContent")
	local content_defLost = panel_lost:getChildByName("Panel_defContent")
	-- att lost panel
	content_attLost:getChildByName("Label_title"):setString(hp.lang.getStrByID(7609))
	local attLostNum = attInfo[9][1] + attInfo[9][2] + attInfo[9][3] + attInfo[9][4]
	local attSurviveNum = attInfo[9][5] + attInfo[9][6] + attInfo[9][7] + attInfo[9][8]
	content_attLost:getChildByName("Label_lostNum"):setString(attLostNum)
	-- def lost panel
	local trapLost = 0
	for i = 2, #defInfo[10], 2 do
		trapLost = trapLost + defInfo[10][i]
	end
	content_defLost:getChildByName("Label_title"):setString(hp.lang.getStrByID(7608))
	local defLostNum = defInfo[9][1] + defInfo[9][2] + defInfo[9][3] + defInfo[9][4] + trapLost
	local defSurviveNum = defInfo[9][5] + defInfo[9][6] + defInfo[9][7] + defInfo[9][8]
	content_defLost:getChildByName("Label_lostNum"):setString(defLostNum)

	-- panel info
	-- ===============================
	local panel_info = listRoot:getChildByName("Panel_info")
	local content_attInfo = panel_info:getChildByName("Panel_attContent")
	local frame_attInfo = panel_info:getChildByName("Panel_attFrame")
	local content_defInfo = panel_info:getChildByName("Panel_defContent")
	local frame_defInfo = panel_info:getChildByName("Panel_defFrame")
	local content_attInfo1 = panel_info:getChildByName("Panel_attContent1")
	local frame_attInfo1 = panel_info:getChildByName("Panel_attFrame1")
	local content_defInfo1 = panel_info:getChildByName("Panel_defContent1")
	local frame_defInfo1 = panel_info:getChildByName("Panel_defFrame1")
	-- att info panel
	content_attInfo:getChildByName("Label_troopsText"):setString(hp.lang.getStrByID(7612))
	content_attInfo:getChildByName("Label_injuredText"):setString(hp.lang.getStrByID(7613))
	content_attInfo:getChildByName("Label_deadText"):setString(hp.lang.getStrByID(7614))
	content_attInfo:getChildByName("Label_surviveText"):setString(hp.lang.getStrByID(7615))

	content_attInfo:getChildByName("Label_troopsNum"):setString(attInfo[11][1])
	content_attInfo:getChildByName("Label_injuredNum"):setString(attInfo[11][2])
	content_attInfo:getChildByName("Label_deadNum"):setString(attLostNum)
	content_attInfo:getChildByName("Label_surviveNum"):setString(attSurviveNum)

	if #attInfo[12] == 3 then
		content_attInfo:getChildByName("Label_heroName"):setString(hp.lang.getStrByID(7619) .. attInfo[12][1])
		content_attInfo:getChildByName("Label_heroLv"):setString(string.format(hp.lang.getStrByID(2017), attInfo[12][2]))
		content_attInfo:getChildByName("Label_heroExp"):setString(hp.lang.getStrByID(7621))
		content_attInfo:getChildByName("Label_heroExpNum"):setString("+" .. attInfo[12][3])
	else
		content_attInfo:getChildByName("Label_heroName"):setVisible(false)
		content_attInfo:getChildByName("Label_heroLv"):setVisible(false)
		content_attInfo:getChildByName("Label_heroExp"):setVisible(false)
		content_attInfo:getChildByName("Label_heroExpNum"):setVisible(false)
	end

	-- 服务器id，坐标（2），战力，（兵种，损失，剩余），（陷阱），（总兵力，伤兵，陷阱），（武将信息），（总兵力，剩余兵力）

	-- 	["hw1","2001","1103",209525684572366,1001,298,536,63768,
	-- [7971,0,0,0,52029,0,0,0],[],[60000,0,0],["吕布",44,0],[60000,52029]],

	-- ["邰却牧","1001","骆谢燕帮",209525684568606,1001,297,535,83000,
	-- [0,36000,0,0,0,0,0,0],[10004,5500],[36000,0,5500],["尧焘",9,0],[60000,52029]]]

	-- def info panel
	content_defInfo:getChildByName("Label_troopsText"):setString(hp.lang.getStrByID(7612))
	content_defInfo:getChildByName("Label_injuredText"):setString(hp.lang.getStrByID(7613))
	content_defInfo:getChildByName("Label_deadText"):setString(hp.lang.getStrByID(7614))
	content_defInfo:getChildByName("Label_surviveText"):setString(hp.lang.getStrByID(7615))

	content_defInfo:getChildByName("Label_troopsNum"):setString(defInfo[11][1])
	content_defInfo:getChildByName("Label_injuredNum"):setString(defInfo[11][2])
	content_defInfo:getChildByName("Label_deadNum"):setString(defLostNum - trapLost)
	content_defInfo:getChildByName("Label_surviveNum"):setString(defSurviveNum)

	content_defInfo:getChildByName("Label_trapTitle"):setString(hp.lang.getStrByID(7616))
	content_defInfo:getChildByName("Label_trapText"):setString(hp.lang.getStrByID(7617))
	content_defInfo:getChildByName("Label_destroyText"):setString(hp.lang.getStrByID(7618))
	content_defInfo:getChildByName("Label_remainText"):setString(hp.lang.getStrByID(7615))

	content_defInfo:getChildByName("Label_trapNum"):setString(defInfo[11][3])
	content_defInfo:getChildByName("Label_destroyNum"):setString(trapLost)
	content_defInfo:getChildByName("Label_remainNum"):setString(defInfo[11][3] - trapLost)

	if #defInfo[12] == 3 then
		content_defInfo:getChildByName("Label_heroName"):setString(hp.lang.getStrByID(7619) .. defInfo[12][1])
		content_defInfo:getChildByName("Label_heroLv"):setString(string.format(hp.lang.getStrByID(2017), defInfo[12][2]))
		content_defInfo:getChildByName("Label_heroExp"):setString(hp.lang.getStrByID(7621))
		content_defInfo:getChildByName("Label_heroExpNum"):setString("+" .. defInfo[12][3])
	else
		content_defInfo:getChildByName("Label_heroName"):setVisible(false)
		content_defInfo:getChildByName("Label_heroLv"):setVisible(false)
		content_defInfo:getChildByName("Label_heroExp"):setVisible(false)
		content_defInfo:getChildByName("Label_heroExpNum"):setVisible(false)
	end
	-- my info panel
	local panel_myInfo
	local data_myInfo
	if isAtt then
		content_attInfo:getChildByName("Label_title"):setString(hp.lang.getStrByID(7610))
		content_defInfo:getChildByName("Label_title"):setString(hp.lang.getStrByID(7611))
		frame_defInfo1:setVisible(false)
		content_defInfo1:setVisible(false)
		if #attInfo[13] > 0 then
			panel_myInfo = content_attInfo1
			data_myInfo = attInfo[13]
		else
			frame_attInfo1:setVisible(false)
			content_attInfo1:setVisible(false)
		end
	else
		content_attInfo:getChildByName("Label_title"):setString(hp.lang.getStrByID(7611))
		content_defInfo:getChildByName("Label_title"):setString(hp.lang.getStrByID(7610))
		frame_attInfo1:setVisible(false)
		content_attInfo1:setVisible(false)
		if #defInfo[13] > 0 then
			panel_myInfo = content_defInfo1
			data_myInfo = defInfo[13]
		else
			frame_defInfo1:setVisible(false)
			content_defInfo1:setVisible(false)
		end
	end
	if panel_myInfo ~= nil and data_myInfo ~= nil then
		panel_myInfo:getChildByName("Label_title"):setString(hp.lang.getStrByID(7625))
		panel_myInfo:getChildByName("Label_troopsText"):setString(hp.lang.getStrByID(7612))
		panel_myInfo:getChildByName("Label_deadText"):setString(hp.lang.getStrByID(7614))
		panel_myInfo:getChildByName("Label_surviveText"):setString(hp.lang.getStrByID(7615))
		panel_myInfo:getChildByName("Label_troopsNum"):setString(data_myInfo[1])
		panel_myInfo:getChildByName("Label_deadNum"):setString(data_myInfo[1] - data_myInfo[2])
		panel_myInfo:getChildByName("Label_surviveNum"):setString(data_myInfo[2])
	else
		-- 调整布局
		local size = panel_info:getSize()
		size.height = size.height - 150
		panel_info:setSize(size)
		content_attInfo:setPositionY(content_attInfo:getPositionY() - 150)
		frame_attInfo:setPositionY(frame_attInfo:getPositionY() - 150)
		content_defInfo:setPositionY(content_defInfo:getPositionY() - 150)
		frame_defInfo:setPositionY(frame_defInfo:getPositionY() - 150)
	end

	-- panel oper
	-- ===============================
	local panel_oper = listRoot:getChildByName("Panel_oper")
	local content_oper = panel_oper:getChildByName("Panel_content")
	local btn_detail = content_oper:getChildByName("Image_details")
	local btn_playback = content_oper:getChildByName("Image_playback")
	local btn_delete = content_oper:getChildByName("Image_delete")
	-- battle details
	local function detailsBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			-- prepare data
			local details = {}
			details.atterName = attTitle
			details.atterSolds = { attInfo[9][5], attInfo[9][1],
								   attInfo[9][6], attInfo[9][2],
								   attInfo[9][7], attInfo[9][3],
								   attInfo[9][8], attInfo[9][4]}
			details.atterkillCount = defLostNum - trapLost
			details.atterDestroyTraps = trapLost

			details.deferName = defTitle
			details.deferSolds = { defInfo[9][5], defInfo[9][1],
								   defInfo[9][6], defInfo[9][2],
								   defInfo[9][7], defInfo[9][3],
								   defInfo[9][8], defInfo[9][4]}
			details.deferkillCount = attLostNum

			require "ui/mail/battleDetail.lua"
			local ui_ = UI_battleDetail.new(details)
			self:addModalUI(ui_)
		end
	end
	btn_detail:addTouchEventListener(detailsBtnOnTouched)
	content_oper:getChildByName("Label_details"):setString(hp.lang.getStrByID(7622))
	-- playback
	local function playbackBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			-- 防守方没有城防和兵力，未发生战斗
			if defInfo[11][1] == 0 and defInfo[11][3] == 0 then
				require "ui/msgBox/msgBox"
				local ui = UI_msgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(7624), hp.lang.getStrByID(1209))
				self:addModalUI(ui)
				return
			end
			-- 战斗回放
			local function onPlayBattleResponse(status, response, tag)
				self:closeAll()
				if status==200 then
					local data = hp.httpParse(response)
					if data.result~=nil and data.result==0 then
						local function battleEnd(attack_, defense_, battleUI_)
							require "ui/battle/battleResult"
							local uiEnd
							if isWin then
								uiEnd = UI_battleResult.new(1, battleUI_)
							else
								uiEnd = UI_battleResult.new(0, battleUI_)
							end
							self:addModalUI(uiEnd)
						end
						require "ui/battle/battle"
						local ui = UI_battle.new(101, data, battleEnd)
						self:addModalUI(ui)
					end
				end
			end
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 10
			oper.type = 9
			oper.mailtype = mailInfo_.type
			oper.id = mailInfo_.id
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onPlayBattleResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end
	btn_playback:addTouchEventListener(playbackBtnOnTouched)
	content_oper:getChildByName("Label_playback"):setString(hp.lang.getStrByID(7623))
	-- delete mail
	local function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	btn_delete:addTouchEventListener(delBtnOnTouched)
	content_oper:getChildByName("Label_delete"):setString(hp.lang.getStrByID(1221))

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end