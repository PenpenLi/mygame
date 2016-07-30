--
-- ui/mail/mailContent.lua
-- 邮件内容
--===================================


UI_mailContent = class("UI_mailContent", UI)


--init
function UI_mailContent:init(mailType_, mailIndex_)
	-- data
	-- ===============================
	local mailQueue = player.mailCenter.getMailQueue(mailType_)
	local mailNum = #mailQueue
	local mailIndex = mailIndex_

	self.mailType = mailType_
	self.mailInfo = nil

	self.currentUi = nil
	
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:setTitle(hp.lang.getStrByID(9001))
	uiFrame:setTopShadePosY(770)
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
			player.mailCenter.deleteMail(mailType_, {mailIndex})
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
		mailQueue = player.mailCenter.getMailQueue(mailType_)
		player.mailCenter.readMail(mailType_, mailIndex)
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
	self.mailInfoList:setVisible(false)
	if self.currentUi~=nil then
		self:removeChildUI(self.currentUi)
		self.currentUi = nil
	end
	if mailInfo.type==7 then
	-- 占领
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
				content = content .. string.format("%s:%d", player.soldierManager.getTypeName(i), v)
				Info.soldTp[i]	=	player.soldierManager.getTypeName(i)
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
		-- 战报邮件
		if self.currentUi == nil then
			require "ui/mail/battleMail.lua"
			local uiFrame = UI_battleMail.new(mailInfo, mailType_, mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
	elseif mailInfo.type==3 then
		-- 采集
		if self.currentUi == nil then
			require "ui/mail/marchMail.lua"
			local uiFrame = UI_marchMail.new(mailInfo, mailType_, mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
		
	elseif mailInfo.type == 9 then
		--攻打Boss

		-- self.mailInfoList:setVisible(false)
		-- local annex = mailInfo.annex
		-- content = mailInfo.content .. "\n\n"
		
		-- local Info = {}
		-- Info.content = mailInfo.content
		-- Info.resArr = annex[3]
		-- Info.bossSid = annex[4]
		
		-- Info.attHealth = 100 * annex[8]/annex[5]
		-- Info.remainHealth = 100 * annex[6]/annex[5]
		
		if self.currentUi == nil then
			require "ui/mail/attackBossMail.lua"
			local uiFrame = UI_attackBossMail.new(mailInfo, mailType_, mailIndex)
			self:addChildUI(uiFrame)
			self.currentUi = uiFrame
		end
	elseif mailInfo.type == 8 then	
	--装备制造		
	--[42,8,0,"null","装备制造|遁甲天书","你成功制造了遁甲天书。",[[40024,8,3,[0,0,0]]],1404787773,1]
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
		content = mailInfo.content .. "\n\n"
		
		local Info = {}
		Info.heroIconSid = mailInfo.annex[1]
		Info.content = content
		Info.sendName = mailInfo.sendName
		Info.sendId = mailInfo.sendId

		if mailInfo.annex[2] == "" then
			Info.heroName = mailInfo.sendName
		else
			Info.heroName = hp.lang.getStrByID(21) .. mailInfo.annex[2] .. hp.lang.getStrByID(22) .. mailInfo.sendName
		end

		if self.currentUi == nil then
			require "ui/mail/normalMail.lua"
			local uiFrame = UI_normalMail.new(Info,mailType_,mailIndex,self)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end


	elseif mailInfo.type == 0 then	
	--联盟邮件
	--[27,0,0,"null","联盟解散","你所在的联盟被联盟解散了。",[],1404824115,0]
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

		
	elseif mailInfo.type == 5 then	
	--侦察邮件
	--[30,10,0,"null","被侦察通知","主公请注意，yangyang对你进行了侦查。",[],1405314688,0]
		content = mailInfo.content .. "\n\n"
			
		if self.currentUi == nil then
			require "ui/mail/scoutMail.lua"
			local uiFrame = UI_scoutMail.new(mailInfo,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
		
	
	elseif mailInfo.type == 10 then	
	--被侦察邮件
	--[30,10,0,"null","被侦察通知","主公请注意，yangyang对你进行了侦查。",[],1405314688,0]
		mailInfo.content = hp.lang.getStrByID(7955)
		content = mailInfo.content
			
		if self.currentUi == nil then
			require "ui/mail/beScoutedMail.lua"
			local uiFrame = UI_beScoutedMail.new(mailInfo,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
		
	elseif mailInfo.type == 11 then	
	--战争预警
	--[31,11,0,"null","战争预警","主公请注意，有人向你发起战争",[1,"","","",0,"",[],[],"",0,[]],1405321851,0]
		content = mailInfo.content .. "\n\n"
			
		if self.currentUi == nil then
			require "ui/mail/alarmMail.lua"
			local uiFrame = UI_alarmMail.new(mailInfo,mailType_,mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
		
	elseif mailInfo.type == 12 then	
	--联盟捐赠
		content = mailInfo.content .. "\n\n"
			
		if self.currentUi == nil then
			require "ui/mail/donateMail.lua"
			local uiFrame = UI_donateMail.new(mailInfo)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
	elseif mailInfo.type == 19 or mailInfo.type == 20 then
	-- 活动积分 & 活动奖励	
		content = mailInfo.content .. "\n\n"
			
		if self.currentUi == nil then
			require "ui/mail/rewardsMail.lua"
			local uiFrame = UI_rewardsMail.new(mailInfo, mailType_, mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
	elseif mailInfo.type == 21 or mailInfo.type == 22 or mailInfo.type == 23 or mailInfo.type == 24 then
	-- 获得国王 & 获得称号 & 失去国王 & 失去称号
		content = mailInfo.content .. "\n\n"
			
		if self.currentUi == nil then
			require "ui/mail/crownMail.lua"
			local uiFrame = UI_crownMail.new(mailInfo, mailType_, mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
	elseif mailInfo.type == 25 then
	-- GM邮件
		content = mailInfo.content .. "\n\n"

		if self.currentUi == nil then
			require "ui/mail/GMMail.lua"
			local uiFrame = UI_GMMail.new(mailInfo, mailType_, mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
	elseif mailInfo.type == 26 or mailInfo.type == 27 then
	-- 联盟活动邮件，（积分、排名）
		content = mailInfo.content .. "\n\n"

		if self.currentUi == nil then
			require "ui/mail/unionActMail.lua"
			local uiFrame = UI_unionActMail.new(mailInfo, mailType_, mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
	elseif mailInfo.type == 28 then
		-- 要塞集火撤军
		content = mailInfo.content .. "\n\n"

		if self.currentUi == nil then
			require "ui/mail/retreatMail.lua"
			local uiFrame = UI_retreatMail.new(mailInfo, mailType_, mailIndex)
			self:addChildUI(uiFrame)
			
			self.currentUi = uiFrame
		end
	else
		self.mailInfoList:setVisible(true)
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
				local mailQueue = player.mailCenter.getMailQueue(self.mailType)
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