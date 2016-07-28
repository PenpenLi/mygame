--
-- ui/union/unionMain.lua
-- 公会主界面
--===================================
require "ui/fullScreenFrame"

UI_unionMain = class("UI_unionMain", UI)

local noticeRollOffset = 20

-- 项目列表 1-商店 2-留言 3-资源帮助 4-捐兵 5-帮助 6-成员 7-公会战 8-统计 9-管理
local loadItemList = {1,3,4,5,6,7,8,9,10}
local imageList = {"alliance_25.png", "alliance_26.png", "alliance_27.png", "alliance_28.png", 
		"alliance_29.png", "alliance_30.png", "alliance_31.png", "alliance_32.png", "alliance_33.png",
		"quest_24.png"}
local nameIDList = {1817, 1818, 1819, 1820, 1821, 1822, 1823, 1824, 1825, 5078}
local numList = {"", "comment", "", "", "help", "", "unionWar", "", "", "gift"}

--init
function UI_unionMain:init()
	-- data
	-- ===============================

	self.uiNumber = {}
	self.uiWar = nil
	self.uiDefense = nil
	self.isNoticeRoll = false

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(1800))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)	

	hp.uiHelper.uiAdaption(self.uiItem)
	hp.uiHelper.uiAdaption(self.uiRallyWar)
	hp.uiHelper.uiAdaption(self.uiFight)
	hp.uiHelper.uiAdaption(self.uiRallyDefense)

	self:refreshShow()

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	player.getAlliance():prepareData(dirtyType.BASEINFO, "UI_unionMain")
	player.getAlliance():prepareData(dirtyType.VARIABLENUM, "UI_unionMain")
	player.getAlliance():prepareData(dirtyType.MEMBER, "UI_unionMain")
end

function UI_unionMain:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionMain.json")
	local content_ = self.wigetRoot:getChildByName("Panel_30036")

	-- 公会基本信息
	-- 会长
	content_:getChildByName("Label_30050"):setString(hp.lang.getStrByID(1812))
	self.leaderName = content_:getChildByName("Label_30050_Copy0")

	-- 公会力量
	content_:getChildByName("Label_30050_Copy2"):setString(hp.lang.getStrByID(1813))
	self.power = content_:getChildByName("Label_30050_Copy1")

	-- 成员数量
	content_:getChildByName("Label_30050_Copy4"):setString(hp.lang.getStrByID(1814))
	self.memberNum = content_:getChildByName("Label_30050_Copy3")

	-- 工会图标
	self.unionIcon = content_:getChildByName("ImageView_30056")

	-- 公会名
	self.unionName = content_:getChildByName("Label_30058")

	-- 公会留言
	self.msgParent = content_:getChildByName("ImageView_30059")
	self.unionMessage = self.msgParent:getChildByName("Label_30060")
	self.msgParent:removeChild(self.unionMessage)

	self.rollLabel = hp.uiHelper.bindRollLabel(self.unionMessage, content_, self.msgParent)


	-- 礼包
	self.giftImage = content_:getChildByName("ImageView_30061")
	self.giftImage:addTouchEventListener(self.onGiftTouched)
	-- 礼包等级
	self.giftLevel = content_:getChildByName("Label_30124")

	content_:getChildByName("Label_30125"):setString(hp.lang.getStrByID(1815))

	content_:getChildByName("Label_30125_Copy0"):setString(hp.lang.getStrByID(1816))

	-- 群发邮件
	self.wigetRoot:getChildByName("Panel_30035"):getChildByName("ImageView_30039"):addTouchEventListener(self.onSendMailTouched)

	self.uiNumber["applicant"] = content_:getChildByName("ImageView_30146_0")

	-- 功能
	self.listView = self.wigetRoot:getChildByName("ListView_30128")
	self.uiItem = self.listView:getChildByName("Panel_30134"):clone()
	self.uiItem:retain()
	self.uiRallyDefense = self.listView:getChildByName("Panel_30129_Copy0")
	self.uiRallyDefense:retain()
	self.uiRallyWar = self.listView:getChildByName("Panel_30129")
	self.uiRallyWar:retain()
	self.uiFight = self.listView:getChildByName("Panel_30129_0")
	self.uiFight:retain()
	self.listView:removeAllItems()
end

function UI_unionMain:refreshShow()
	-- 演练在第一个
	local item_ = self.uiFight:clone()
	self.listView:pushBackCustomItem(item_)
	item_:addTouchEventListener(self.onUnionFightTouched)
	for i, v in ipairs(loadItemList) do
		local item_ = self.uiItem:clone()
		local content_ = item_:getChildByName("Panel_30144")
		local image_ = content_:getChildByName("ImageView_30145")
		image_:loadTexture(config.dirUI.common..imageList[v])
		content_:getChildByName("Label_30148"):setString(hp.lang.getStrByID(nameIDList[v]))
		local num_ = image_:getChildByName("ImageView_30146")
		if numList[v] ~= "" then
			self.uiNumber[numList[v]] = num_
		end
		item_:setTag(v)
		item_:addTouchEventListener(self.onItemTouched)
		self.listView:pushBackCustomItem(item_)
	end
end

function UI_unionMain:updateInfo()
	local homePageInfo_ = player.getAlliance():getUnionHomePageInfo()
	for i, v in pairs(self.uiNumber) do
		if homePageInfo_[i] ~= 0 and homePageInfo_[i] ~= nil then
			v:getChildByName("Label_30147"):setString(homePageInfo_[i])
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end

	if homePageInfo_.gift > 0 then
		self.giftImage:getChildByName("ImageView_30146_0"):setVisible(true)
		self.giftImage:getChildByName("ImageView_30146_0"):getChildByName("Label_30147"):setString(homePageInfo_.gift)
	else
		self.giftImage:getChildByName("ImageView_30146_0"):setVisible(false)
	end

	if self.uiWar ~= nil then
		self.listView:removeItem(self.uiWar)
		self.uiWar = nil
	end

	if self.uiDefense ~= nil then
		self.listView:removeItem(self.uiDefense)
		self.uiDefense = nil
	end

	if homePageInfo_.defense > 0 then
		self.uiDefense = self.uiRallyDefense:clone()
		self.uiDefense:addTouchEventListener(self.onRallyWarTouched)
		self.listView:insertCustomItem(self.uiDefense, 0)
	end

	if homePageInfo_.war > 0 then
		self.uiWar = self.uiRallyWar:clone()
		self.uiWar:addTouchEventListener(self.onRallyWarTouched)
		self.listView:insertCustomItem(self.uiWar, 0)
	end
end

function UI_unionMain:updateBaseInfoUI()
	local info_ = player.getAlliance():getBaseInfo()
	self.leaderName:setString(info_.chairman)
	self.power:setString(tostring(info_.power))
	self.memberNum:setString(tostring(info_.memNum))
	self.unionIcon:loadTexture(string.format("%s%s.png", config.dirUI.icon, info_.icon))
	self.unionName:setString(info_.name)
	self.unionMessage:setString(info_.message)
	self.giftLevel:setString(string.format(hp.lang.getStrByID(1826), info_.giftLevel))
end

function UI_unionMain:updateMemberAboutUI()
	local member_ = player.getAlliance():getMyUnionInfo()
	if hp.gameDataLoader.getInfoBySid("allienceRank", member_:getRank()).apply == 1 then
		local apply_ = self.wigetRoot:getChildByName("Panel_30035"):getChildByName("ImageView_30039_Copy0")
		apply_:addTouchEventListener(self.onApplyManageTouched)
		apply_:loadTexture(config.dirUI.common.."button_green.png")
		apply_:setTouchEnabled(true)
	else
		self.uiNumber["applicant"]:setVisible(false)
	end
end

function UI_unionMain:initCallBack()
	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()			
			if tag_ == 1 then
				require "ui/union/shop/unionShopMain"
				ui_ = UI_unionShopMain.new()
				self:addUI(ui_)
			elseif tag_ == 6 then
				require "ui/union/member/memberList"
				ui_ = UI_memberList.new()
				self:addUI(ui_)
			elseif tag_ == 7 then
				require "ui/union/war/allianceWar"
				ui_ = UI_allianceWar.new(1)
				self:addUI(ui_)
			elseif tag_ == 3 then
				require "ui/union/mainFunc/unionSourceHelp"
				ui_ = UI_unionSourceHelp.new(1)
				self:addUI(ui_)
			elseif tag_ == 4 then
				require "ui/union/mainFunc/unionSourceHelp"
				ui_ = UI_unionSourceHelp.new(2)
				self:addUI(ui_)
			elseif tag_ == 5 then
				require "ui/union/mainFunc/unionHelp"
				ui_ = UI_unionHelp.new()
				self:addUI(ui_)
			elseif tag_ == 9 then
				require "ui/union/manage/manageAlliance"
				ui_ = UI_manageAlliance.new()
				self:addUI(ui_)
			elseif tag_ == 10 then
				require "ui/union/mainFunc/getUnionGift"
				ui_ = UI_getUnionGift.new()
				self:addUI(ui_)
			end
			print("tag:",sender:getTag())
		end
	end

	local function onApplyManageTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/invite/unionInviteMember"
			ui_ = UI_unionInviteMember.new(2)
			self:addUI(ui_)
		end
	end	

	local function onUnionFightTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/fight/unionFightMain"
			ui_ = UI_unionFightMain.new()
			self:addUI(ui_)
		end
	end	

	local function onRallyWarTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/war/allianceWar"
			ui_ = UI_allianceWar.new(sender:getTag())
			self:addUI(ui_)
		end
	end	

	local function onSendMailTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mail/writeMail"
			ui_ = UI_writeMail.new()
			self:addUI(ui_)
		end
	end

	local function onGiftTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/mainFunc/getUnionGift"
			ui_ = UI_getUnionGift.new()
			self:addUI(ui_)
		end
	end

	self.onItemTouched = onItemTouched
	self.onApplyManageTouched = onApplyManageTouched
	self.onSendMailTouched = onSendMailTouched
	self.onRallyWarTouched = onRallyWarTouched
	self.onGiftTouched = onGiftTouched
	self.onUnionFightTouched = onUnionFightTouched
end

function UI_unionMain:onMsg(msg_, param_)	
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if dirtyType.BASEINFO == param_ then
			self:updateBaseInfoUI()
		elseif dirtyType.MEMBER == param_ then
			self:updateMemberAboutUI()
		elseif dirtyType.VARIABLENUM == param_ then
			self:updateInfo()
		end
	end
end

function UI_unionMain:close()
	player.getAlliance():unPrepareData(dirtyType.BASEINFO, "UI_unionMain")
	player.getAlliance():unPrepareData(dirtyType.VARIABLENUM, "UI_unionMain")
	player.getAlliance():unPrepareData(dirtyType.MEMBER, "UI_unionMain")
	self.uiItem:release()
	self.uiRallyWar:release()
	self.uiRallyDefense:release()
	self.super.close(self)
end

function UI_unionMain:heartbeat(dt_)
	self.rollLabel.labelRoll(dt_)
end