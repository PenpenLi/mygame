--
-- ui/common/promotionInfo.lua
-- 促销信息
--===================================
require "ui/UI"


UI_promotionInfo = class("UI_promotionInfo", UI)


--init
function UI_promotionInfo:init()
	self.layer:setLocalZOrder(999)
	-- data
	-- ===============================
		
	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "promotionInfo.json")

	local widgetRoot1 = widgetRoot:clone()

	self.data = {}
	local res = player.goldShopMgr.getShopItem()
	for i,v in ipairs(res) do
		for j,v2 in ipairs(v) do
			self.data[#self.data + 1] = v2.info
		end
	end
	self.length = table.getn(self.data)


	--resetInfo()
	-- addCCNode
	-- ===============================data.recharge
	self:addCCNode(widgetRoot)
	self:addCCNode(widgetRoot1)

	widgetRoot1:setPosition(game.visibleSize.width,0)

	self.showIndex = 1
	self.showNexTime = 100

	local function setWidgetRootInfo( wr ,index)
		-- body
		-- body
		--self.showIndex = self.showIndex+1
		if index > self.length then
			index = 1
		end


		cclog("----------showindex:"..self.showIndex.."-------count:"..self.length)
		for i, rechargeinfo in ipairs(self.data) do

			if index == i then

				wr:getChildByName("Panel_frame"):getChildByName("Image_bg"):loadTexture(config.dirUI.common..rechargeinfo.bg_pic)

				wr:getChildByName("Panel_cont"):getChildByName("Image_gold"):loadTexture(config.dirUI.common..rechargeinfo.icon_pic)

				wr:getChildByName("Panel_cont"):getChildByName("Label_title"):setString(rechargeinfo.name)

				wr:getChildByName("Panel_cont"):getChildByName("Label_desc"):setString(rechargeinfo.desc)

				wr:getChildByName("Panel_cont"):getChildByName("Image_get"):getChildByName("Label_time"):setString(rechargeinfo.money)

				wr:getChildByName("Panel_cont"):getChildByName("Image_get"):setTag(rechargeinfo.sid)
				wr:getChildByName("Panel_frame"):getChildByName("Image_bg"):setTag(rechargeinfo.sid)

				self.showNexTime = rechargeinfo.showTime
			end
		end



	end
	


	local function resetInfo( )
		self.showIndex = self.showIndex+1
		if self.showIndex > self.length then
			self.showIndex = 1
		end

		if self.showIndex%2 == 0 then

			


			self.setWidgetRootInfo(widgetRoot1,self.showIndex)

			widgetRoot1:setPosition(game.visibleSize.width,0)
			local mvTo = cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(0, 0)))
			widgetRoot1:stopAllActions()
			widgetRoot1:runAction(mvTo)

			widgetRoot:runAction( cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(-game.visibleSize.width, 0))) )
		else
			self.setWidgetRootInfo(widgetRoot,self.showIndex)

			widgetRoot:setPosition(game.visibleSize.width,0)
			local mvTo = cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(0, 0)))
			widgetRoot:stopAllActions()
			widgetRoot:runAction(mvTo)

			widgetRoot1:runAction( cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(-game.visibleSize.width, 0))) )
		end

	end

	self.resetInfo = resetInfo
	self.setWidgetRootInfo = setWidgetRootInfo

	setWidgetRootInfo(widgetRoot,self.showIndex)

	--
	local btnInfo = widgetRoot:getChildByName("Panel_frame"):getChildByName("Image_bg")
	local btnBuy = widgetRoot:getChildByName("Panel_cont"):getChildByName("Image_get")

	local btnInfo1 = widgetRoot1:getChildByName("Panel_frame"):getChildByName("Image_bg")
	local btnBuy1 = widgetRoot1:getChildByName("Panel_cont"):getChildByName("Image_get")

	local function gotoShop(sid_)
		local index = 3
		if sid_ > 300 then
			index = 1
		elseif sid_ > 200 then
			index = 2
		end
		require "ui/goldShop/goldShop"
		local ui = UI_goldShop.new(index)
		self:addUI(ui)
	end

	local function buy(sid_)
		player.goldShopMgr.buyItem(sid_)
	end

	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local sid = sender:getTag()
			if sender==btnInfo then
				gotoShop(sid)
			elseif sender==btnBuy then
				cclog_("buy item sid: " .. sid)
				buy(sid)
			elseif sender==btnInfo1 then
				gotoShop(sid)
			elseif sender==btnBuy1 then
				cclog_("buy item sid: " .. sid)
				buy(sid)
			end
		end
	end
	btnInfo:addTouchEventListener(onBtnTouched)
	btnBuy:addTouchEventListener(onBtnTouched)
	btnInfo1:addTouchEventListener(onBtnTouched)
	btnBuy1:addTouchEventListener(onBtnTouched)




end

-- heartbeat
function UI_promotionInfo:heartbeat(dt)
	self.showNexTime = self.showNexTime-dt

	--cclog("-------------------------showtime:"..self.showNexTime.."------dt:"..dt)
	if self.showNexTime <= 0 then
		self.resetInfo()
		--cclog("-------------------------reset")
	end

	
end
