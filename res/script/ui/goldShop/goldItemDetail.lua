--
-- ui/goldShop/goldItemDetail.lua
-- 单人活动
--===================================
require "ui/frame/popFrame"

UI_goldItemDetail = class("UI_goldItemDetail", UI)

local interval = 0

--init
function UI_goldItemDetail:init(sid_)
	-- data
	-- ===============================
	cclog_("sid_",sid_)
	self.info = player.goldShopMgr.getItemInfo(sid_)

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, self.info.name)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item)

	self:initShow()
end

function UI_goldItemDetail:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "diamondItemDetail.json")
	local content_ = self.wigetRoot:getChildByName("Panel_2")
	-- 充值
	local charge_ = content_:getChildByName("Image_22")
	charge_:getChildByName("Label_23"):setString(hp.lang.getStrByID(5480))
	charge_:addTouchEventListener(self.onChargeTouched)

	self.listView = self.wigetRoot:getChildByName("ListView_64")
	self.item = self.listView:getChildByName("Panel_140"):clone()
	self.item:retain()
	self.listView:removeAllItems()
end

function UI_goldItemDetail:initCallBack()
	-- 立即充值
	local function onChargeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			cclog_("charge", self.info.sid)
			player.goldShopMgr.buyItem(self.info.sid)
		end
	end

	self.onChargeTouched = onChargeTouched
end

function UI_goldItemDetail:initShow()
	-- 金币
	local item_ = self.item:clone()
	self.listView:pushBackCustomItem(item_)	
	content_ = item_:getChildByName("Panel_142")
	local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", 1)
	-- 图标
	content_:getChildByName("Image_146"):loadTexture(config.dirUI.common.."gold2.png")
	-- 名称
	content_:getChildByName("Label_147"):setString(self.info.gold..resInfo_.name)
	-- 数量
	content_:getChildByName("Label_147_0"):setString(1)

	-- 道具
	for i, v in ipairs(self.info.propId) do
		local item_ = self.item:clone()
		self.listView:pushBackCustomItem(item_)		

		-- 阴影
		if i%2 == 1 then
			item_:getChildByName("Panel_141"):getChildByName("Image_143"):setVisible(true)
		end

		content_ = item_:getChildByName("Panel_142")
		local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", v)
		if itemInfo_ ~= nil then
			-- 图标
			content_:getChildByName("Image_146"):loadTexture(config.dirUI.item..v..".png")
			-- 名称
			content_:getChildByName("Label_147"):setString(itemInfo_.name)
			-- 数量
			content_:getChildByName("Label_147_0"):setString(self.info.propNum[i])
		end
	end
end

function UI_goldItemDetail:onRemove()
	self.item:release()
	self.super.onRemove(self)
end