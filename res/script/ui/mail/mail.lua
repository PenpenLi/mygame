--
-- ui/mail/mail.lua
-- 邮件主界面
--===================================
require "ui/fullScreenFrame"


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
	uiFrame:setTitle(hp.lang.getStrByID(9001))

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
	local btnCancel = operPanel:getChildByName("ImageView_cancel")
	local btnClose = operPanel:getChildByName("ImageView_close")
	operPanel:getChildByName("Label_checkAll"):setString(hp.lang.getStrByID(9007))
	operPanel:getChildByName("Label_delete"):setString(hp.lang.getStrByID(1848))
	operPanel:getChildByName("Label_cancel"):setString(hp.lang.getStrByID(2412))
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
				hp.mailCenter.deleteMail(self.curMailType, selectedMail)
			elseif sender==btnCancel then
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
	btnCancel:addTouchEventListener(operOnTouched)
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
			hp.mailCenter.loadMail(self.curMailType)
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
				hp.mailCenter.unsaveMail(sender:getTag())
			else
				hp.mailCenter.saveMail(self.curMailType, sender:getTag())
			end
		end
	end

	local readColor = cc.c3b(160, 160, 160)
	local unreadColor = cc.c3b(33, 0, 0)
	-- 设置邮件显示内容
	local function setMailItemInfo( itemNode, index, mailInfo, first )
		itemNode:setVisible(true)
		local itemCont = itemNode:getChildByName("Panel_cont")
		local titleNode = itemCont:getChildByName("Label_title")
		local descNode = itemCont:getChildByName("Label_desc")
		local timeNode = itemCont:getChildByName("Label_time")
		itemCont:setTag(index)
		itemCont:addTouchEventListener(mailItemOnTouched)
		if mailInfo.state==0 then
			titleNode:setColor(unreadColor)
			descNode:setColor(unreadColor)
			--timeNode:setColor(unreadColor)
		else
			titleNode:setColor(readColor)
			descNode:setColor(readColor)
			--timeNode:setColor(readColor)
		end

		local index_ = string.find(mailInfo.title,"|")
		local mailTitle = mailInfo.title

		if index_ ~= nil then
			mailTitle = string.gsub(mailTitle,"|","\n")
		end

		titleNode:setString(mailTitle)
		descNode:setString(hp.common.utf8_strSub(mailInfo.content, 40))
		timeNode:setString(os.date("%c", mailInfo.datetime))
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
		mailQueue = hp.mailCenter.getMailQueue(self.curMailType)
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

		if hp.mailCenter.isLoadFinished(self.curMailType) and hp.mailCenter.haveNewer(self.curMailType)==false then
		-- 如果没有更新的，并且邮件已经加载完成
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
	local colorSelected = cc.c3b(255, 255, 255)
	local colorNormal = cc.c3b(217, 206, 190)
	local function setSelectedTab(tab_)
		if tabSelected~=nil then
			tabSelected:setScale(0.9*hp.uiHelper.RA_scale)
			tabSelected:setColor(colorNormal)
		end


		tabSelected = tab_
		tabSelected:setScale(hp.uiHelper.RA_scale)
		tabSelected:setColor(colorSelected)
		self.curMailType = tabSelected:getTag()

		-- 加载邮件
		loadMailList()
		if #mailQueue==0 then
		-- 如果队列为空，或者有更新的邮件
			hp.mailCenter.loadMail(self.curMailType)
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
	local function setUnreadInfo(mailType_)
		local numNode = nil
		local unreadNum = hp.mailCenter.getUnreadMailNum(mailType_)
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
	self:addCCNode(widgetRoot)


	setSelectedTab(mailTab)

	-- registMsg
	self:registMsg(hp.MSG.MAIL_CHANGED)
end


-- onMsg
function UI_mail:onMsg(msg_, parm_)
	if msg_==hp.MSG.MAIL_CHANGED then
		local msgType = parm_.type

		if msgType==4 then
			if parm_.mailType==self.curMailType then
				local mailQueue = hp.mailCenter.getMailQueue(self.curMailType)
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
