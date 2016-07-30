--
-- ui/common/playerInfo.lua
-- 建筑缺省界面
--===================================
require "ui/fullScreenFrame"

UI_playerInfo = class("UI_playerInfo", UI)

--init
function UI_playerInfo:init(playerid, ksid, kx, ky)
	-- data
	-- ===============================
	local friendMgr = player.friendMgr
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(10301))
	uiFrame:setTopShadePosY(474)

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "playerInfo.json")

	--文字更改
	wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_BattleNumber"):setString(hp.lang.getStrByID(10303))
	wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_KillNumber"):setString(hp.lang.getStrByID(10304))
	wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_VIP"):setString(hp.lang.getStrByID(10305))
	wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_Contribute"):setString(hp.lang.getStrByID(10306))
	wigetRoot:getChildByName("Panel_MiddleBtn"):getChildByName("Label_MuDiWrd"):setString(hp.lang.getStrByID(10307))
	wigetRoot:getChildByName("Panel_MiddleBtn"):getChildByName("Label_HeroWrd"):setString(hp.lang.getStrByID(10308))
	wigetRoot:getChildByName("Panel_MiddleBtn"):getChildByName("Label_LiuYanWrd"):setString(hp.lang.getStrByID(10309))
	wigetRoot:getChildByName("Panel_MiddleBtn"):getChildByName("Label_MenuWrd"):setString(hp.lang.getStrByID(10310))


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)


	--处理listview
	local listView = wigetRoot:getChildByName("ListView_Battle")
	local x0 = listView:getItem(0)
	local x1 = listView:getItem(1)
	local x2 = listView:getItem(2)
	local x1Flag = false
	local x2Flag = false
	

	local x1Tmp = nil
	local x2Tmp = nil
	local n = 0
	for i,v in ipairs(game.data.playerBattleInfo) do

		if 1 == v.type then
			if x1Flag then
				x1Tmp = x1:clone()
				listView:pushBackCustomItem(x1Tmp)

			else
				x1Flag = true
				x1Tmp = x1
			end
			x1Tmp:getChildByName("Panel_Frame"):getChildByName("Label_words"):setString(v.info)
			n = 0
		else
			if x2Flag then
				x2Tmp = x2:clone()
				listView:pushBackCustomItem(x2Tmp)
			else
				x2Flag = true
				x2Tmp = x2
			end

			x2Tmp:getChildByName("Panel_cont"):getChildByName("Label_desc"):setString(v.info..":")
			--黑白条间隔处理
			if n % 2 == 0 then
				x2Tmp:getChildByName("Panel_frame"):setVisible(false)
			else
				x2Tmp:getChildByName("Panel_frame"):setVisible(true)
			end
			n = n+1
		end
	end

	--
	local function showInfo(titleStrId, infoStrId)
		require("ui/msgBox/msgBox")
		local msgBox = UI_msgBox.new(hp.lang.getStrByID(titleStrId), 
			hp.lang.getStrByID(infoStrId), 
			hp.lang.getStrByID(1209)
			)
		self:addModalUI(msgBox)
	end
	self.showInfo = showInfo


	local name = ""

	--发送请求
	local function sendFriendsQuest(  )
		-- body
		if table.getn(friendMgr.getFriends())>=friendMgr.getMaxSize() then
				--好友已满
			showInfo(3615, 3616)
			return
		end
		friendMgr.sendInvite(name)
	end

	

	--按钮处理
	local btnMudi = wigetRoot:getChildByName("Panel_MiddleBtn"):getChildByName("Image_MuDiBtn")
	local btnHero = wigetRoot:getChildByName("Panel_MiddleBtn"):getChildByName("Image_HeroBtn")
	local btnLiuYan = wigetRoot:getChildByName("Panel_MiddleBtn"):getChildByName("Image_LiuYanBtn")
	local btnMenu = wigetRoot:getChildByName("Panel_MiddleBtn"):getChildByName("Image_MenuBtn")

	local btnUnion = wigetRoot:getChildByName("Panel_cont"):getChildByName("Image_BtnUnion")
	
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnMudi then
				cclog("Mudi")
				--墓地
				require "ui/cemetery/cemeteryOtherPlayer.lua"
				local ui = UI_cemeteryOtherPlayer.new(playerid)
				self:addUI(ui)
			elseif sender==btnHero then
				local function onHttpResponse(status, response, tag)
					if status==200 then
						local data = hp.httpParse(response)
						if data.result~=nil and data.result==0 then
							require "ui/hero/othersHero"
							local ui = UI_othersHero.new(data.hero, data.equipN, data.lv)
							self:addUI(ui)
						end
					end
				end
				--发送消息
				local cmdData={}
				cmdData.type = 6
				cmdData.id = playerid
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld, nil, nil, self.url)
				self:showLoading(cmdSender)

			elseif sender==btnLiuYan then
				cclog("LiuYan")
				require "ui/mail/writeMail"
				local ui  = UI_writeMail.new(name)
				self:addUI(ui)
			elseif sender==btnMenu then
				cclog("Menu")
				
				--好友请求窗口
				require("ui/msgBox/msgBox")
				local msgBoxFriendsQest = UI_msgBox.new(hp.lang.getStrByID(3603), 
						hp.lang.getStrByID(3628),
						hp.lang.getStrByID(1209),
						hp.lang.getStrByID(2412),
						sendFriendsQuest
						)
				self:addModalUI(msgBoxFriendsQest)

			elseif sender==btnUnion then
				cclog("Union")

				require "ui/union/manage/unionInfo"
				local ui = UI_unionInfo.new(self.unionId, self.url)
				self:addUI(ui)
			end
		end
	end
	btnMudi:addTouchEventListener(onBtnTouched)
	btnHero:addTouchEventListener(onBtnTouched)
	btnLiuYan:addTouchEventListener(onBtnTouched)
	btnMenu:addTouchEventListener(onBtnTouched)

	-- 网络请求回调
	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				-- 联盟ID
				if data.id == nil or data.id == 0 then
					btnUnion:loadTexture(config.dirUI.common .. "button_gray.png")
				else
					btnUnion:addTouchEventListener(onBtnTouched)
					self.unionId = data.id
				end

				local pc0 = wigetRoot:getChildByName("Panel_cont")

				if data.city[2] == "" then
					pc0:getChildByName("Label_PlayerName"):setString(data.city[1])
					local x,y = pc0:getChildByName("Label_PlayerName"):getPosition()
					pc0:getChildByName("Label_PlayerName"):setPosition(x-30,y)
				else
					pc0:getChildByName("Label_PlayerName"):setString(hp.lang.getStrByID(21)..data.city[2]..hp.lang.getStrByID(22)..data.city[1])
				end
				name = data.city[1]

				--联盟小图标
				local unionRank_ = nil
				if data.city[3]~=0 then
					unionRank_ = hp.gameDataLoader.getInfoBySid("unionRank", data.city[3])
				end
				if unionRank_ ~= nil then
					pc0:getChildByName("Image_UnionIcon"):loadTexture(config.dirUI.common..unionRank_.image)
				else
					--pc0:getChildByName("Label_PlayerName"):setPosition()
					pc0:getChildByName("Image_UnionIcon"):setVisible(false)
				end
				

				--pc0:getChildByName("Label_PlayerName"):setString(data.city[1])
				pc0:getChildByName("Label_UnionName"):setString(hp.lang.getStrByID(10302)..data.city[8])
				pc0:getChildByName("Label_BattleValue"):setString(""..data.city[4])
				pc0:getChildByName("Label_KillValue"):setString(""..data.city[5])

				pc0:getChildByName("Image_Head"):loadTexture(config.dirUI.heroHeadpic .. data.city[6] .. ".png")

				pc0:getChildByName("Label_VIPValue"):setString(""..data.city[7])
				pc0:getChildByName("Label_ContributeValue"):setString(""..data.city[10])

				if data.city[9] == 0 then
					--不是国王的特殊处理
					listView:removeItem(0)
					wigetRoot:getChildByName("Panel_cont"):setPosition(0,20*hp.uiHelper.RA_scaleY)
				else
					 
					local titleInfo = hp.gameDataLoader.getInfoBySid("kingTitle", data.city[9])

					wigetRoot:getChildByName("Panel_frame"):getChildByName("ImageView_bg"):setVisible(true)
					wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_title"):setVisible(true)
					wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_title"):setString(titleInfo.name)

					x0:getChildByName("Panel_Contents"):getChildByName("Image_UnionIconLeft"):loadTexture(config.dirUI.title .. data.city[9] .. ".png")
					x0:getChildByName("Panel_Contents"):getChildByName("Image_UnionIconRight"):loadTexture(config.dirUI.title .. data.city[9] .. ".png")
					x0:getChildByName("Panel_Contents"):getChildByName("Label_Title"):setString(titleInfo.name)

					local desc = ""
					for i,v in ipairs(titleInfo.attrs) do
						local attInfo = hp.gameDataLoader.getInfoBySid("attr", v)
						if titleInfo.value[i] > 0 then
							desc = " " .. desc .. attInfo.desc .. " +" .. titleInfo.value[i]/100 .. "% "
						else
							desc = " " .. desc .. attInfo.desc .. " " .. titleInfo.value[i]/100 .. "% "
						end
						if i % 2 == 0 and i ~= #titleInfo.attrs then
							desc = desc .. "\n"
						end
					end

					x0:getChildByName("Panel_Contents"):getChildByName("Label_Contents"):setString(desc)
				end
			 
				---制表
				local index = 11
				local battleCount = (data.city[index][1]+data.city[index][3]+data.city[index][2]+data.city[index][4])
				local dieCount = data.city[index][8]
				local shenlv = 0
				local killBDieCount = 0
				if battleCount > 0 then
					shenlv = (data.city[index][1]+data.city[index][3])*100/battleCount
				end
				if dieCount > 0 then
					killBDieCount = data.city[index][6]*100/dieCount
				end
				killBDieCount = string.format("%.2f%%",killBDieCount)
				shenlv = string.format("%.2f%%",shenlv)
				local datamap = {
								data.city[index][1]+data.city[index][3],data.city[index][2]+data.city[index][4],data.city[index][1],data.city[index][2],data.city[index][3],data.city[index][4],
									shenlv,
									data.city[index][5],data.city[index][6],data.city[index][7],data.city[index][8],data.city[index][9],
									killBDieCount,
									data.city[index][10],data.city[index][11],data.city[index][12],data.city[index][13],data.city[index][14],data.city[index][15],data.city[index][16],
									data.city[index][17],data.city[index][18],data.city[index][19],data.city[index][20],data.city[index][21],data.city[index][22],data.city[index][23],
									data.city[index][24],data.city[index][25],data.city[index][26],data.city[index][27]}


				local num = 1
				for i,v in ipairs(game.data.playerBattleInfo) do

					if listView:getItem(i) ~= nil and listView:getItem(i):getTag() == 3 then
						--cclog("-------------data:"..datamap[num].."------i:"..num)
						--cclog("---------tag-"..listView:getItem(i):getTag())
						--listView:getItem(i):getChildByName("Panel_cont"):getChildByName("Label_desc"):setString(v.info..": ")
						listView:getItem(i):getChildByName("Panel_cont"):getChildByName("Label_num"):setString(""..datamap[num])
						num = num+1
					end

				--data.city[1][]   

				--[LUA-cclog_] Http response: {"result":0,"city":["y5","",574,4000,"1002",0,0,[0,0,0,0,0,4000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]}
				end
			end
		end
	end

	local url=nil
	if kx and ky then
		local server = player.serverMgr.getServerByPos(kx, ky)
		if server then
			url = server.url
		end
	elseif ksid then
		local server = player.serverMgr.getServerBySid(ksid)
		if server then
			url = server.url
		end
	end
	self.url = url
	--发送消息
	local cmdData={}
	cmdData.type = 5
	cmdData.id = playerid
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld, nil, nil, url)
	self:showLoading(cmdSender)

	-- registMsg
	self:registMsg(hp.MSG.FRIEND_MGR)
end



-- onMsg
function UI_playerInfo:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.FRIEND_MGR then
		if paramInfo_.oper==3 then
			if paramInfo_.rst==0 then
			--成功
				self.showInfo(3619, 3620)
			elseif paramInfo_.rst==14 then
			-- 查无此人
				self.showInfo(3615, 3618)
			end
		end
	end
end