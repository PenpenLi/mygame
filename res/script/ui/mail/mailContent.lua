--
-- ui/mail/mailContent.lua
-- 邮件内容
--===================================


UI_mailContent = class("UI_mailContent", UI)


--init
function UI_mailContent:init(mailType_, mailIndex_)
	-- data
	-- ===============================
	local mailQueue = hp.mailCenter.getMailQueue(mailType_)
	local mailNum = #mailQueue
	local mailIndex = mailIndex_

	self.mailType = mailType_
	self.mailInfo = nil

	self.currentUi = nil
	
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:setTitle(hp.lang.getStrByID(9001))
	local contFrame = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mailContent.json")
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(contFrame)
	
	
	
	local titlePanel = contFrame:getChildByName("Panel_title")
	local upBtn = titlePanel:getChildByName("ImageView_pageUp")
	local upIcon = upBtn:getChildByName("ImageView_up")
	local downBtn = titlePanel:getChildByName("ImageView_pageDown")
	local downIcon = downBtn:getChildByName("ImageView_down")
	local function pageOnTouched(sender, eventType)
		if sender==upBtn then
			if mailIndex<=1 then
				return
			else
				hp.uiHelper.btnImgTouched(upIcon, eventType)
			end
		elseif sender==downBtn then
			if mailIndex>=mailNum then
				return
			else
				hp.uiHelper.btnImgTouched(downIcon, eventType)
			end
		end
		hp.uiHelper.btnImgTouched(sender, eventType)

		if eventType==TOUCH_EVENT_ENDED then
			if sender==upBtn then
				self.readMail(mailIndex-1)
			else
				self.readMail(mailIndex+1)
			end
		end
	end
	upBtn:addTouchEventListener(pageOnTouched)
	downBtn:addTouchEventListener(pageOnTouched)

	-- 邮件内容列表
	local mailInfoList = contFrame:getChildByName("ListView_mailInfoList")
	self.mailInfoList = mailInfoList
	local mailCont = mailInfoList:getChildByName("Panel_mailCont"):getChildByName("Panel_cont"):getChildByName("Label_cont")
	-- delete
	local deleteBtn = mailInfoList:getChildByName("Panel_delete"):getChildByName("Panel_cont"):getChildByName("ImageView_delete")
	local function delateOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			hp.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	deleteBtn:addTouchEventListener(delateOnTouched)

	-- 读取邮件内容
	local headPanel = contFrame:getChildByName("Panel_header")
	local mailTitle = headPanel:getChildByName("Label_title")
	local mailTime = headPanel:getChildByName("Label_time")
	local mailSaved = headPanel:getChildByName("ImageView_save")
	local mailSavedImg = mailSaved:getChildByName("ImageView_star")
	local normalColor = cc.c3b(255, 255, 255)
	local disableColor = cc.c3b(128, 128, 128)
	local function readMail(index_)
		mailIndex = index_
		mailQueue = hp.mailCenter.getMailQueue(mailType_)
		hp.mailCenter.readMail(mailType_, mailIndex)
		local mailInfo = mailQueue[mailIndex]
		self.mailInfo = mailInfo
		mailNum = #mailQueue

		if mailIndex<=1 then
			upBtn:setColor(disableColor)
			upIcon:setColor(disableColor)
		else
			upBtn:setColor(normalColor)
			upIcon:setColor(normalColor)
		end
		if mailIndex>=mailNum then
			downBtn:setColor(disableColor)
			downIcon:setColor(disableColor)
		else
			downBtn:setColor(normalColor)
			downIcon:setColor(normalColor)
		end


		local index_ = string.find(mailInfo.title,"|")
		local mailTitle_ = mailInfo.title

		if index_ ~= nil then
			mailTitle_ = string.gsub(mailTitle_,"|","\n")
		end

		mailTitle:setString(mailTitle_)
		mailTime:setString(os.date("%c", mailInfo.datetime))
		if mailType_==3 then
			mailSavedImg:setVisible(true)
		else
			mailSavedImg:setVisible(false)
		end

		--
		mailCont:setString(self:getMailCont(mailInfo,mailType_,mailIndex))
	end

	readMail(mailIndex_)
	self.readMail = readMail


	-- registMsg
	self:registMsg(hp.MSG.MAIL_CHANGED)
end


function UI_mailContent:getMailCont(mailInfo,mailType_,mailIndex)
	local content = ""
	self.mailInfoList:setVisible(true)
	if self.currentUi~=nil then
		self:removeChildUI(self.currentUi)
		self.currentUi = nil
	end
	if mailInfo.type==7 then
	-- 占领
		self.mailInfoList:setVisible(false)
		
		local annex = mailInfo.annex
		local field = game.data.fieldFunc[annex[7]]
		
		local Info = {}
		
		content = content .. string.format("你成功占领了%s!\n\n", field.name)
		content = content .. string.format("从: %s(K:%d X:%d Y:%d)\n", annex[1], annex[2], annex[3], annex[4])
		content = content .. string.format("到: %s(K:%d X:%d Y:%d)\n", field.name, annex[2], annex[5], annex[6])
		content = content .. "\n军队\n"

		Info.from = annex[1]
		Info.to	=	field.name
		
		Info.fromK = annex[2]
		Info.fromX = annex[3]
		Info.fromY = annex[4]
		
		Info.toK = annex[2]
		Info.toX = annex[5]
		Info.toY = annex[6]
		
		Info.soldTp = {"","","",""}
		Info.soldNum = {0,0,0,0}
		for i,v in ipairs(annex[8]) do
			if v>0 then
				content = content .. string.format("%s:%d", player.getTypeName(i), v)
				Info.soldTp[i]	=	player.getTypeName(i)
				Info.soldNum[i] =	v
			end
		end
		
		
		
		
		
		if self.currentUi == nil then
			require "ui/mail/occupyMail.lua"
			local uiFrame = UI_occupyMail.new(Info,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
		
		
		
		
	elseif mailInfo.type==4 then
		self.mailInfoList:setVisible(false)
	-- 战争
		local annex = mailInfo.annex
		local att = annex[7]
		local def = annex[8]
		local atter = att
		local defer = def
		local Info = {}
		
		
		
		--0 atter succeed
		--1 defer succeed
		
		if att[1]==player.getName() then
			-- 是攻击方
			
			Info.meisAtt = 1
			
			if annex[1]==0 then
				--战斗胜利
				content = content .. "战斗胜利！\n\n"
				Info.meisSucceed = 1
				
			else
				content = content .. "战斗失败！\n\n"
				Info.isSucceed = 0
			end
			content = content .. "获取资源\n"
			content = content .. string.format("银币:%d, 粮草:%d, 木材:%d, 石头:%d, 矿石:%d", 
										annex[2], annex[3], annex[4], annex[5], annex[6])
			
		else
			-- 是被攻击方
			
			Info.meisAtt = 0
			
			if annex[1]==1 then
				--战斗胜利
				content = content .. "战斗胜利！\n\n"
				Info.meisSucceed = 1
			else
				content = content .. "战斗失败！\n\n"
				Info.meisSucceed = 0
			end
			content = content .. "损失资源\n"
			content = content .. string.format("银币:-%d, 粮草:-%d, 木材:-%d, 石头:-%d, 矿石:-%d", 
										annex[2], annex[3], annex[4], annex[5], annex[6])
			
			
		end
		
		
		
		
		Info.silver = annex[2]
		Info.food	= annex[3]
		Info.wood	= annex[4]
		Info.stone	= annex[5]
		Info.ore    = annex[6]
		
		

		
		-- content = content .. string.format("\n\n己军：%s(K:%d X:%d Y:%d)\n", atter[1], atter[4], atter[5], atter[6])
		-- content = content .. string.format("战力:-%d\n", atter[7])
		-- content = content .. string.format("损失兵力和陷阱:%d\n", atter[8][1]+atter[8][2]+atter[8][3]+atter[8][4]+atter[10][3])
		-- content = content .. string.format("伤兵:%d\n", atter[10][3])

		-- content = content .. string.format("\n\n敌军：%s(K:%d X:%d Y:%d)\n", defer[1], defer[4], defer[5], defer[6])
		-- content = content .. string.format("战力:-%d\n", defer[7])
		-- content = content .. string.format("损失兵力和陷阱:%d\n", defer[8][1]+defer[8][2]+defer[8][3]+defer[8][4]+defer[10][3])
		-- content = content .. string.format("伤兵:%d\n", defer[10][3])
		
		
		--(union)name
		
		if atter[3] ~= "" then
			Info.atterUnionName = "(" .. atter[3] .. ")" .. atter[1]
		else
			Info.atterUnionName = atter[1]
		end
		
		Info.atterCityName	= ""
		Info.atterIcon = config.dirUI.headPic .. atter[2]
		Info.atterPosK	= atter[5]
		Info.atterPosX	= atter[6]
		Info.atterPosY	= atter[7]
		
		
		--
		Info.atterLostPower	= atter[8]
		
		
		--四个兵种损失数量和
		Info.atterLostAll	= atter[9][1]+atter[9][2]+atter[9][3]+atter[9][4]
		
		
		Info.atterSoldCount = atter[11][1]
		Info.atterInjure	= atter[11][2]
		Info.atterdie	= Info.atterLostAll
		Info.atterSurv	= atter[11][1] - Info.atterLostAll - atter[11][2]
		
		if #atter[12] > 0 then
			--hero
			Info.atterHeroName = atter[12][1]
			Info.atterHeroLv = atter[12][2]
			Info.atterHeroXP = atter[12][3]
		else
			Info.atterHeroName = ""
			
		end
		
		
		--(union)name
		
		if defer[3] ~= "" then
			Info.deferUnionName = "(" .. defer[3] .. ")" .. defer[1]
		else
			Info.deferUnionName = defer[1]
		end
		
		Info.deferCityName	= ""
		Info.deferIcon = config.dirUI.headPic .. defer[2]
		Info.deferPosK	= defer[5]
		Info.deferPosX	= defer[6]
		Info.deferPosY	= defer[7]
		
		
		--
		Info.deferLostPower	= defer[8]
		
		
		local trapLostCount = 0
		
		--trap
		
		if #defer[10] > 0 then 
			for i,v in ipairs(defer[10]) do
				if i % 2 == 0 then 
					trapLostCount = trapLostCount + v
				end
			end
		end
		
		
		
		--四个兵种损失数量和
		Info.deferLostAll	= defer[9][1]+defer[9][2]+defer[9][3]+defer[9][4] + trapLostCount
		
		
		Info.deferSoldCount = defer[11][1]
		Info.deferInjure	= defer[11][2]
		Info.deferdie	= defer[9][1]+defer[9][2]+defer[9][3]+defer[9][4]
		Info.deferSurv	= defer[11][1] - Info.deferdie - defer[11][2]
		
	
		--trap
		Info.trapCount = defer[11][3]
		Info.trapDestroy = trapLostCount
		Info.trapSurv = defer[11][3] - trapLostCount
		
		
		
		if #defer[12] > 0 then
			--hero
			Info.deferHeroName = defer[12][1]
			Info.deferHeroLv = defer[12][2]
			Info.deferHeroXP = defer[12][3]
		else
			Info.deferHeroName = ""
			
		end


-- [1,0,0,0,0,0,
-- ["yangyang","1002","",140806207832065,1,305,805,8980,[2990,600,300,300,0,0,0,0],[],[4190,0,0],["南宫瑶",2,0],[],[],[]],
-- ["yangyan1","1002","",140806207832066,1,305,807,4510,[768,320,317,300,0,0,0,0],[10001,0],[1905,200,2401],["顾幽琴",1,0],[],[],[]]],1404894569,0]


		-- suv|kill
		Info.details = {}
		Info.details.atterName = Info.atterUnionName
		Info.details.atterSolds = {	atter[9][5],defer[9][1],
									atter[9][6],defer[9][2],
									atter[9][7],defer[9][3],
									atter[9][8],defer[9][4]}
									
		Info.details.atterkillCount = Info.deferdie
		Info.details.atterDestroyTraps = trapLostCount
		
		Info.details.deferName = Info.deferUnionName
		Info.details.deferSolds = {	defer[9][5],atter[9][1],
									defer[9][6],atter[9][2],
									defer[9][7],atter[9][3],
									defer[9][8],atter[9][4]}
		Info.details.deferkillCount = Info.atterdie
		
		
		
		if self.currentUi == nil then
			require "ui/mail/battleMail.lua"
			local uiFrame = UI_battleMail.new(Info,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
		
		
	elseif mailInfo.type==3 then
		-- 采集
		self.mailInfoList:setVisible(false)
		local annex = mailInfo.annex
		content = mailInfo.content .. "\n\n"
		content = content .. string.format("获取资源:%d\n", annex[2])
		content = content .. string.format("获取材料:%d\n", annex[3])
		
		
		local Info = {}
		
		
		Info.content = mailInfo.content
		Info.resTp	= annex[1]
		Info.resNum	= annex[2]
		
		Info.materials	= annex[3]
		
		
		
		if self.currentUi == nil then
			require "ui/mail/marchMail.lua"
			local uiFrame = UI_marchMail.new(Info,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
		


	elseif mailInfo.type == 9 then
		--攻打Boss

		self.mailInfoList:setVisible(false)
		local annex = mailInfo.annex
		content = mailInfo.content .. "\n\n"
		
		local Info = {}
		
		
		Info.content = mailInfo.content
		Info.resArr = annex[3]
		Info.bossSid = annex[4]

		
		
		Info.attHealth = 100 * annex[8]/annex[5]
		Info.remainHealth = 100 * annex[6]/annex[5]
		
		if self.currentUi == nil then
			require "ui/mail/attackBossMail.lua"
			local uiFrame = UI_attackBossMail.new(Info,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end

		
	elseif mailInfo.type == 8 then	
	--装备制造		
	--[42,8,0,"null","装备制造|遁甲天书","你成功制造了遁甲天书。",[[40024,8,3,[0,0,0]]],1404787773,1]
		
		self.mailInfoList:setVisible(false)
		local annex = mailInfo.annex
		content = mailInfo.content .. "\n\n"
			
		local Info = {}
		Info.equipSid = annex[1][1]
		Info.content = content
		Info.quality = annex[1][3] + 1
		Info.equipId = annex[1][2]
		if self.currentUi == nil then
			require "ui/mail/equipMail.lua"
			local uiFrame = UI_equipMail.new(Info,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
			



	elseif mailInfo.type == 2 then	
	--普通邮件（带坐标）
	--[16,2,140806207832066,"yangyan1","而听歌聊天了台湾而","水电费戈杜兰特略伦特来听歌的聊天",["1002",""],1404895451,0]],

		self.mailInfoList:setVisible(false)
		content = mailInfo.content .. "\n\n"
		
		local Info = {}
		Info.heroIconSid = mailInfo.annex[1]
		Info.content = content
		Info.sendName = mailInfo.sendName

		if mailInfo.annex[2] == "" then
			Info.heroName = mailInfo.sendName
		else
			Info.heroName = "(" .. mailInfo.annex[2] .. ")" .. mailInfo.sendName
		end

		
			
		if self.currentUi == nil then
			require "ui/mail/normalMail.lua"
			local uiFrame = UI_normalMail.new(Info,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end


	elseif mailInfo.type == 0 then	
	--联盟邮件
	--[27,0,0,"null","联盟解散","你所在的联盟被联盟解散了。",[],1404824115,0]

		self.mailInfoList:setVisible(false)
		content = mailInfo.content .. "\n\n"
			
		local Info = {}
		Info.heroIconSid = -1
		Info.content = content
		Info.heroName = hp.lang.getStrByID(7923)
		Info.isSystem = 1
		

		if self.currentUi == nil then
			require "ui/mail/normalMail.lua"
			local uiFrame = UI_normalMail.new(Info,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end


		
	else
		content = mailInfo.content
	end

	return content
end

-- onMsg
function UI_mailContent:onMsg(msg_, parm_)
	if msg_==hp.MSG.MAIL_CHANGED then
		local msgType = parm_.type

		if msgType==5 then
		-- 邮件列表发生变化
			if parm_.mailType==self.mailType then
				local mailQueue = hp.mailCenter.getMailQueue(self.mailType)
				for i, v in ipairs(mailQueue) do
					if v.id == self.mailInfo.id then
						self.readMail(i)
						return
					end
				end
				self:close()
			end
		end
	end
end