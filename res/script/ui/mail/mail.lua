
--
-- ui/mail/mail.lua
-- 邮件主界面
--===================================
require "ui/fullScreenFrame"
require "ui/common/promotionInfo"


UI_mail = class("UI_mail", UI)


--init
function UI_mail:init()
	-- data
	-- ===============================
	self.curMailType = 1 -- 当前类型
	self.haveItem = false -- 是否有邮件
	local mailQueue = nil -- 邮件队列
	local selectedMail = {} -- 选中的邮件
	local selectAllFlag = false

	local readColor = cc.c3b(146, 146, 146)
	local unreadColor = cc.c3b(255, 181, 85)
	local colorSelected = cc.c3b(122, 108, 96)
	local colorNormal = cc.c3b(245, 241, 223)

	for i=1,4 do
		if player.mailCenter.getUnreadMailNum(i) > 0 then
			self.curMailType = i
			break
		end
	end
	

	
	
	--  
	local function resetSelected(index)
		for i, v in ipairs(selectedMail) do
			if v==index then
				table.remove(selectedMail, i)
				return false
			end
		end

		table.insert(selectedMail, index)
		return true
	end

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:setTopShadePosY(710)
	uiFrame:setTitle(hp.lang.getStrByID(9001))

	local promotionUI = UI_promotionInfo.new()

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mail.json")
	-- title
	local titlePanel = widgetRoot:getChildByName("Panel_title")
	local btnWrite = titlePanel:getChildByName("ImageView_write")
	btnWrite:getChildByName("Label_back"):setString(hp.lang.getStrByID(9008))
	local function writeOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mail/writeMail"
			local ui  = UI_writeMail.new()
			self:addUI(ui)
		end
	end
	btnWrite:addTouchEventListener(writeOnTouched)

	-- header
	local headerPanel = widgetRoot:getChildByName("Panel_header")

	-- operator
	----------------------------
	local operFrame = widgetRoot:getChildByName("Panel_operFrame")
	local operPanel = widgetRoot:getChildByName("Panel_oper")
	local btnSelectAll = operPanel:getChildByName("ImageView_checkBox")
	local btnDelete = operPanel:getChildByName("ImageView_delete")
	local btnHasRead = operPanel:getChildByName("ImageView_cancel")
	local btnClose = operPanel:getChildByName("ImageView_close")
	operPanel:getChildByName("Label_checkAll"):setString(hp.lang.getStrByID(9007))
	operPanel:getChildByName("Label_delete"):setString(hp.lang.getStrByID(1848))
	operPanel:getChildByName("Label_cancel"):setString(hp.lang.getStrByID(9012))
	local function operSetVisible( visible )
		if visible then
			operFrame:setVisible(true)
			operFrame:setPosition(0, 0)
			operPanel:setVisible(true)
			operPanel:setPosition(0, 0)
		else
			operFrame:setVisible(false)
			operFrame:setPosition(-10000, -10000)
			operPanel:setVisible(false)
			operPanel:setPosition(-10000, -10000)
		end
	end

	local setUnreadInfo
	local function selectedHasRead()
		player.mailCenter.readMails(self.curMailType, selectedMail)
		setUnreadInfo(self.curMailType)
	end

	function operOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnSelectAll then
				if selectAllFlag then
					self.unselectAll()
					operSetVisible(false)
				else
					self.selectAll()
					btnSelectAll:getChildByName("ImageView_checked"):setVisible(true)
				end
			elseif sender==btnDelete then
				player.mailCenter.deleteMail(self.curMailType, selectedMail)
			elseif sender==btnHasRead then
				selectedHasRead()
				self.unselectAll()
				operSetVisible(false)
			elseif sender==btnClose then
				self.unselectAll()
				operSetVisible(false)
			end
		end
	end
	btnSelectAll:addTouchEventListener(operOnTouched)
	btnDelete:addTouchEventListener(operOnTouched)
	btnHasRead:addTouchEventListener(operOnTouched)
	btnClose:addTouchEventListener(operOnTouched)


	-- mail list
	-----------------------------
	local mailList = widgetRoot:getChildByName("ListView_mailList")
	local mailItem = mailList:getItem(0)
	local mailMore = mailList:getItem(1)

	-- 点击加载更多
	local moreBtn = mailMore:getChildByName("Panel_cont"):getChildByName("ImageView_loadMore")
	moreBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(9006))
	local function loadMoreOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			player.mailCenter.loadMail(self.curMailType)
		end
	end
	moreBtn:addTouchEventListener(loadMoreOnTouched)
	
	
	-- 邮件点击，弹出邮件内容
	local function mailItemOnTouched(sender, eventType)
		if #mailQueue<=0 then
		-- 无邮件
			return
		end
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mail/mailContent"
			local ui  = UI_mailContent.new(self.curMailType, sender:getTag())
			self:addUI(ui)
		end
	end
	-- 点击选中
	local function chooseOnTouched(sender, eventType)
		if #mailQueue<=0 then
		-- 无邮件
			return
		end
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if resetSelected(sender:getTag()) then
			-- 选中
				sender:getChildByName("ImageView_checked"):setVisible(true)
				if #selectedMail==1 then
					operSetVisible(true)
				end
				if #selectedMail == #mailQueue then
				-- 全选
					selectAllFlag = true
					btnSelectAll:getChildByName("ImageView_checked"):setVisible(true)
				else
					btnSelectAll:getChildByName("ImageView_checked"):setVisible(false)
				end
			else
			-- 取消选中
				sender:getChildByName("ImageView_checked"):setVisible(false)

				if #selectedMail==0 then
					operSetVisible(false)
				end
				if selectAllFlag then
					selectAllFlag = false
					btnSelectAll:getChildByName("ImageView_checked"):setVisible(false)
				end
			end

		end
	end
	-- 点击收藏
	local function saveOnTouched(sender, eventType)
		if #mailQueue<=0 then
		-- 无邮件
			return
		end
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.curMailType==3 then
				player.mailCenter.unsaveMail(sender:getTag())
			else
				player.mailCenter.saveMail(self.curMailType, sender:getTag())
			end
		end
	end

	-- 设置邮件显示内容
	local function setMailItemInfo( itemNode, index, mailInfo, first )
		itemNode:setVisible(true)
		local itemCont = itemNode:getChildByName("Panel_cont")
		local titleNode = itemCont:getChildByName("Image_titleBg"):getChildByName("Label_title")
		local descNode = itemCont:getChildByName("Label_desc")
		local timeNode = itemCont:getChildByName("Label_time")

		itemCont:setTag(index)
		itemCont:addTouchEventListener(mailItemOnTouched)

		if mailInfo.state==0 then
			-- 未读
			titleNode:setColor(unreadColor)
			descNode:setColor(colorNormal)
		else
			-- 已读
			titleNode:setColor(readColor)
			descNode:setColor(readColor)
		end

		local index_ = string.find(mailInfo.title,"|")
		local mailTitle = mailInfo.title

		if index_ ~= nil then
			mailTitle = string.gsub(mailTitle,"|"," ")
		end

		-- 邮件基本信息
		if mailInfo.type == 4 then
			-- 战报邮件
			titleNode:setString(hp.lang.getStrByID(9013))
			descNode:setString(hp.common.utf8_strSub(mailTitle, 40))
		elseif mailInfo.type == 2 then
			local title = ""
			if mailInfo.annex[2] ~= "" and #mailInfo.annex[2] > 0 then
				title = string.format(hp.lang.getStrByID(8010), mailInfo.annex[2])
			end
			titleNode:setString(title .. mailInfo.sendName)
			descNode:setString(hp.common.utf8_strSub(mailTitle, 40))
		elseif mailInfo.type == 19 or mailInfo.type == 20 then
			local str1 = ""
			local str2 = ""
			str1, str2 = hp.common.splitString(mailTitle, " ")
			titleNode:setString(hp.common.utf8_strSub(str1, 30))
			descNode:setString(hp.common.utf8_strSub(str2, 40))
		else
			titleNode:setString(hp.common.utf8_strSub(mailTitle, 30))
			descNode:setString(hp.common.utf8_strSub(mailInfo.content, 40))
		end
		timeNode:setString(os.date("%Y/%m/%d", mailInfo.datetime))
		local checkImg = itemCont:getChildByName("ImageView_checkBox")
		local saveImg = itemCont:getChildByName("ImageView_save")
		checkImg:setTag(index)
		checkImg:addTouchEventListener(chooseOnTouched)
		if first then
			checkImg:getChildByName("ImageView_checked"):setVisible(false)
		end
		saveImg:setTag(index)
		saveImg:addTouchEventListener(saveOnTouched)
		if self.curMailType==3 then
			saveImg:getChildByName("ImageView_checked"):setVisible(true)
		else
			saveImg:getChildByName("ImageView_checked"):setVisible(false)
		end
	end
	-- 根据类型加载邮件
	local function loadMailList()
		operSetVisible(false)
		mailQueue = player.mailCenter.getMailQueue(self.curMailType)
		selectedMail = {}

		local oldItems = mailList:getItems()
		local oldNum = #oldItems - 1
		local num = #mailQueue

		local itemTmp = nil
		for i, v in ipairs(mailQueue) do
			if i>oldNum then
				itemTmp = mailItem:clone()
				mailList:insertCustomItem(itemTmp, i-1)
			else
				itemTmp = oldItems[i]
			end
			setMailItemInfo(itemTmp, i, v, true)
			self.haveItem = true
		end

		for i=oldNum, num+1, -1 do
			if i==1 then
				mailItem:setVisible(false)
				self.haveItem = false
			else
				mailList:removeItem(i-1)
			end
		end
		
		if not player.mailCenter.haveLoaded(self.curMailType) or (player.mailCenter.isLoadFinished(self.curMailType) and player.mailCenter.haveNewer(self.curMailType)==false) then
		-- 如果没有加载过数据 或者 （没有更新的，并且邮件已经加载完成）
			mailMore:setVisible(false)
		else
			mailMore:setVisible(true)
		end
	end

	-- tab
	-------------------------------
	local tabPanel = widgetRoot:getChildByName("Panel_tab")
	local mailTab = tabPanel:getChildByName("ImageView_mail")
	local noticeTab = tabPanel:getChildByName("ImageView_notice")
	local savedTab = tabPanel:getChildByName("ImageView_saved")
	local unionTab = tabPanel:getChildByName("ImageView_union")
	mailTab:getChildByName("Label_name"):setString(hp.lang.getStrByID(9002))
	noticeTab:getChildByName("Label_name"):setString(hp.lang.getStrByID(9003))
	savedTab:getChildByName("Label_name"):setString(hp.lang.getStrByID(9004))
	unionTab:getChildByName("Label_name"):setString(hp.lang.getStrByID(9005))
	local tabSelected = nil

	local function setSelectedTab(tab_)
		-- 取消上一次选择
		if tabSelected~=nil then
			tabSelected:getChildByName("ImageView_icon"):setColor(colorSelected)
			tabSelected:getChildByName("Label_name"):setColor(colorSelected)
			tabSelected:getChildByName("Image_checked"):setVisible(false)

		end
		-- 当前选择
		tabSelected = tab_
		tabSelected:getChildByName("ImageView_icon"):setColor(colorNormal)
		tabSelected:getChildByName("Label_name"):setColor(colorNormal)
		tabSelected:getChildByName("Image_checked"):setVisible(true)

		self.curMailType = tabSelected:getTag()

		-- 加载邮件
		loadMailList()
		if #mailQueue==0 then
		-- 如果队列为空，或者有更新的邮件
			player.mailCenter.loadMail(self.curMailType)
		end
	end
	local function tabOnTouched(sender, eventType)
		if sender==tabSelected then
			return
		end

		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(colorSelected)
			else
				sender:setColor(colorNormal)
			end
		else
			sender:setColor(colorNormal)
		end

		if eventType==TOUCH_EVENT_ENDED then
			setSelectedTab(sender)
		end
	end
	mailTab:addTouchEventListener(tabOnTouched)
	noticeTab:addTouchEventListener(tabOnTouched)
	savedTab:addTouchEventListener(tabOnTouched)
	unionTab:addTouchEventListener(tabOnTouched)
	-- 设置未读个数
	function setUnreadInfo(mailType_)
		local numNode = nil
		local unreadNum = player.mailCenter.getUnreadMailNum(mailType_)
		if mailType_==1 then
			numNode = mailTab:getChildByName("ImageView_num")
		elseif mailType_==2 then
			numNode = noticeTab:getChildByName("ImageView_num")
		elseif mailType_==3 then
			numNode = savedTab:getChildByName("ImageView_num")
		elseif mailType_==4 then
			numNode = unionTab:getChildByName("ImageView_num")
		end
		if unreadNum==0 then
			numNode:setVisible(false)
		else
			numNode:setVisible(true)
			numNode:getChildByName("Label_num"):setString(unreadNum)
		end
	end
	setUnreadInfo(1)
	setUnreadInfo(2)
	setUnreadInfo(3)
	setUnreadInfo(4)

	--
	--===================
	local function selectAll()
		local items = mailList:getItems()
		selectedMail = {}
		selectAllFlag = true
		for i=1, #items-1 do
			local itemCont = items[i]:getChildByName("Panel_cont")
			itemCont:getChildByName("ImageView_checkBox"):getChildByName("ImageView_checked"):setVisible(true)
			selectedMail[i] = itemCont:getTag()
		end
	end
	local function unselectAll()
		for i,v in ipairs(selectedMail) do
			local itemCont = mailList:getItem(v-1):getChildByName("Panel_cont")
			itemCont:getChildByName("ImageView_checkBox"):getChildByName("ImageView_checked"):setVisible(false)
		end

		selectedMail = {}
		selectAllFlag = false
	end

	-- data
	self.mailList = mailList
	self.mailItem = mailItem
	self.mailMore = mailMore
	-- function
	self.setMailItemInfo = setMailItemInfo
	self.operSetVisible = operSetVisible
	self.setUnreadInfo = setUnreadInfo
	self.selectAll = selectAll
	self.unselectAll = unselectAll
	self.loadMailList = loadMailList


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(promotionUI)
	self:addCCNode(widgetRoot)

	
	local tabs_ = {mailTab,noticeTab,savedTab,unionTab}
	
	mailTab:setColor(colorNormal)
	
	setSelectedTab(tabs_[self.curMailType])

	-- registMsg
	self:registMsg(hp.MSG.MAIL_CHANGED)
end


-- onMsg
function UI_mail:onMsg(msg_, parm_)
	if msg_==hp.MSG.MAIL_CHANGED then
		local msgType = parm_.type

		if msgType==4 then
			if parm_.mailType==self.curMailType then
				local mailQueue = player.mailCenter.getMailQueue(self.curMailType)
				self.setMailItemInfo(self.mailList:getItem(parm_.index-1), parm_.index, mailQueue[parm_.index], false)
			end
		elseif msgType==5 then
		-- 邮件列表发生变化
			if parm_.mailType==self.curMailType then
				self.loadMailList()
			end
		elseif msgType==6 then
			-- 未读邮件个数发生变化
			self.setUnreadInfo(parm_.mailType)
		end
	end
end