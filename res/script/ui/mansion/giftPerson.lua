--
-- ui/mansion/giftPerson.lua
-- 礼官展示页面
--===================================

-- 1.联盟礼包 2.签到 3.7天 4.在线 5.府邸升级

require "ui/fullScreenFrame"
require "ui/mansion/giftItem/unionGiftItem"
require "ui/mansion/giftItem/signGiftItem"
require "ui/mansion/giftItem/noviceGiftItem"
require "ui/mansion/giftItem/onlineGiftItem"
require "ui/mansion/giftItem/upgradeGiftItem"

UI_giftPerson = class("UI_giftPerson", UI)

-- 初始化
function UI_giftPerson:init()
	self:initUI()
end

-- 初始化界面
function UI_giftPerson:initUI()
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "giftUi.json")
	
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(8121))
	uiFrame:setTopShadePosY(888)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	-- sid tbl
	self.sidTbl = {}
	-- item tbl
	self.itemTbl = {}

	-- item
	self.list = wigetRoot:getChildByName("ListView_giftList")
	self.unionGiftItem = self.list:getItem(0):clone()
	self.unionGiftItem:retain()
	self.signGiftItem = self.list:getItem(1):clone()
	self.signGiftItem:retain()
	self.noviceGiftItem = self.list:getItem(2):clone()
	self.noviceGiftItem:retain()
	self.onlineGiftItem = self.list:getItem(3):clone()
	self.onlineGiftItem:retain()
	self.upgradeGiftItem = self.list:getItem(4):clone()
	self.upgradeGiftItem:retain()
	self.list:removeAllItems()

	self.unionGiftNum = 0
	self:setUnionGift()

	player.getAlliance():prepareData(dirtyType.UNIONGIFT, "UI_giftPerson")
	-- 注册联盟礼包消息
	self:registMsg(hp.MSG.UNION_DATA_PREPARED)
	-- 注册签到奖励消息
	self:registMsg(hp.MSG.SIGN_IN)
	-- 注册在线礼包消息
	self:registMsg(hp.MSG.ONLINE_GIFT)
	-- 注册升级礼包消息
	self:registMsg(hp.MSG.UPGRADEGIFT_GET)
	-- 注册新手礼包消息
	self:registMsg(hp.MSG.NOVICE_GIFT)

	self:setOtherGift()
end

-- 联盟礼包
function UI_giftPerson:setUnionGift()

	local unionGift = player.getAlliance():getUnionGift()

	for i,gift in ipairs(unionGift) do
		if gift ~= nil and gift.state == 1 and gift.endTime > player.getServerTime() then
			if self.sidTbl[gift.id] == nil then
				-- 插入
				local unionGiftItem = UnionGiftItem.new(self.unionGiftItem:clone(), gift, self)
				self.list:insertCustomItem(unionGiftItem.item, 0)
				-- 记录
				self.unionGiftNum = self.unionGiftNum + 1
				self.sidTbl[gift.id] = 1
				table.insert(self.itemTbl, 1, unionGiftItem)
			end
		end
	end 
end

-- 其他礼包
function UI_giftPerson:setOtherGift()
	-- 清除
	for i = self.unionGiftNum, #self.list:getItems() do
		self.list:removeItem(self.unionGiftNum)
	end

	-- 签到奖励
	self.signGift = SignGiftItem.new(self.signGiftItem, self)
	-- 新手奖励
	self.noviceGift = NoviceGiftItem.new(self.noviceGiftItem, self)
	-- 在线礼包
	self.onlineGift = OnlineGiftItem.new(self.onlineGiftItem, self)
	-- 升级礼包
	local upgradeGiftItem_ = self.upgradeGiftItem:clone()
	self.upgradeGift = UpgradeGiftItem.new(upgradeGiftItem_, self.list, self)

	local giftTbl = {}
	table.insert(giftTbl, self.signGift)
	table.insert(giftTbl, self.noviceGift)
	table.insert(giftTbl, self.onlineGift)
	table.insert(giftTbl, self.upgradeGift)

	-- 刷新
	for priority = 1, 3 do
		for i,v in ipairs(giftTbl) do
			if v.priority == priority then
				self.list:pushBackCustomItem(v.item)
			end
		end
	end
end

-- 接收消息
function UI_giftPerson:onMsg(msg, parm)
	if msg == hp.MSG.UNION_DATA_PREPARED then
		if parm == dirtyType.UNIONGIFT then
			self:setUnionGift()
		end
	else
		self:setOtherGift()
	end
end

-- 心跳
function UI_giftPerson:heartbeat(dt)
	for i,item in ipairs(self.itemTbl) do
		item:heartbeat(dt)
	end
	self.onlineGift:heartbeat(dt)
end

-- 移除
function UI_giftPerson:onRemove()
	self.super.onRemove(self)

	player.getAlliance():unPrepareData(dirtyType.UNIONGIFT, "UI_giftPerson")
	self.unionGiftItem:release()
	self.signGiftItem:release()
	self.noviceGiftItem:release()
	self.onlineGiftItem:release()
	self.upgradeGiftItem:release()
end