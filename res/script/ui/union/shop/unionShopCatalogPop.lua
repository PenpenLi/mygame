--
-- ui/union/unionShopCatalogPop.lua
-- 公会商店目录弹出界面
--===================================
require "ui/frame/popFrame"

UI_unionShopCatalogPop = class("UI_unionShopCatalogPop", UI)

--init
function UI_unionShopCatalogPop:init(sid_, closeCallBack_)
	-- data
	-- ===============================
	self.item = hp.gameDataLoader.getInfoBySid("item", sid_)
	self.sid = sid_
	self.percent = 0
	self.maxItemNumber = self:calcMaxNumber()
	self.getNumber = 1
	-- if self.maxItemNumber == 0 then
	-- 	self.getNumber = 0
	-- end
	self.shop = nil
	self.closeCallBack = closeCallBack_

	-- call back
	self:initCallBack()

	-- ui
	self:initUI()
	local popFrame = UI_popFrame.new(self.widgetRoot)
	popFrame:setIsModalUI(false)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.widgetRoot)

	self:refreshShow()
	self:requestData()
end

function UI_unionShopCatalogPop:initCallBack()
	local function updateLocalInfo()
		self.totalCost:setString(tostring(self.getNumber * self.item.societySale))
		self.number:setString(tostring(self.getNumber))
		if self.maxItemNumber == 0 then
			self.getBtn:setTouchEnabled(false)
			self.getBtn:loadTexture(config.dirUI.common.."button_gray1.png")
		else
			self.getBtn:setTouchEnabled(true)
			self.getBtn:loadTexture(config.dirUI.common.."button_blue1.png")
		end
	end

	local function onPlusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			if self.maxItemNumber == 0 then
				return
			end

			if self.getNumber < self.maxItemNumber then
				self.getNumber = self.getNumber + 1
				self.percent = hp.common.round((self.getNumber - 1) / (self.maxItemNumber - 1) * 100)
				self.slider:setPercent(self.percent)
				updateLocalInfo()
			end
		end
	end

	local function onMinusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			if self.maxItemNumber == 0 then
				return
			end
			
			if self.getNumber > 1 then
				self.getNumber = self.getNumber - 1
				self.percent = hp.common.round((self.getNumber - 1) / (self.maxItemNumber - 1) * 100)
				self.slider:setPercent(self.percent)
				updateLocalInfo()
			end
		end
	end

	local function onGetResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			player.getAlliance():addUnionFunds(-self.item.societySale*self.getNumber)
			self:close()
		end
	end

	local function onGetTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 13
			oper.type = 5
			oper.sid = self.sid
			oper.num = self.getNumber
			-- oper.subtype = 
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onGetResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	local function onStarredMemberTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/union/shop/itemStarred"
			ui_ = UI_itemStarred.new(self.shop)
			self:addModalUI(ui_)
		end
	end

	local function onSliderPercentChange(sender, eventType)
		local per = sender:getPercent()		
		if self.percent == per then
			return
		end
		self.percent = per
		-- update train number
		self.getNumber = hp.common.round((self.maxItemNumber - 1) * per / 100) + 1
		updateLocalInfo()
	end

	self.onPlusTouched = onPlusTouched
	self.onGetTouched = onGetTouched
	self.onMinusTouched = onMinusTouched
	self.onStarredMemberTouched = onStarredMemberTouched
	self.onSliderPercentChange = onSliderPercentChange
	self.updateLocalInfo = updateLocalInfo
end

function UI_unionShopCatalogPop:requestData()
	local function onApplicantResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.shop = data.shop
			self:updateInfo(data.shop)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 13
	oper.type = 6
	oper.sid = self.sid
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onApplicantResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionShopCatalogPop:updateInfo(info_)
	local content_ = self.widgetRoot:getChildByName("Panel_214_2")
	-- 拥有
	content_:getChildByName("Label_219_0"):setString(string.format(hp.lang.getStrByID(1181), info_[2]))

	-- 申请数量
	content_:getChildByName("Image_223"):getChildByName("Label_233"):setString(tostring(table.getn(info_[3])))
end

function UI_unionShopCatalogPop:changeItem(sid_)
	if sid_ == self.sid then
		return
	end

	self.sid = sid_
	self.item = hp.gameDataLoader.getInfoBySid("item", sid_)
	self.getNumber = 1
	self.maxItemNumber = self:calcMaxNumber()
	-- if self.maxItemNumber == 0 then
	-- 	self.getNumber = 0
	-- end
	self:refreshShow()
	self:requestData()
end

function UI_unionShopCatalogPop:refreshShow(sid_)
	local content_ = self.widgetRoot:getChildByName("Panel_214_2")

	-- 图片
	content_:getChildByName("Image_66_0"):getChildByName("Image_67"):loadTexture(string.format("%s%s.png", config.dirUI.item, tostring(self.sid)))
	-- 名称
	content_:getChildByName("Label_219"):setString(self.item.name)
	-- 描述
	content_:getChildByName("Label_219_1"):setString(self.item.desc)
	-- 价钱
	self.updateLocalInfo()
	local per_ = 0
	if self.maxItemNumber > 1 then
		per_ = (self.getNumber - 1) / (self.maxItemNumber - 1) * 100
		self.slider:setTouchEnabled(true)
	else
		self.slider:setTouchEnabled(false)
	end
	self.slider:setPercent(hp.common.round(per_))
end

function UI_unionShopCatalogPop:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShopCatalogPop.json")
	local content_ = self.widgetRoot:getChildByName("Panel_214_2")

	-- 购买
	self.getBtn = content_:getChildByName("ImageView_20457_0")
	self.getBtn:addTouchEventListener(self.onGetTouched)
	self.getBtn:getChildByName("Label_20458"):setString(hp.lang.getStrByID(1177))
	-- 图标
	-- 费用
	self.totalCost = self.getBtn:getChildByName("ImageView_20459"):getChildByName("Label_20460")
	self.totalCost:setString("0")
	-- 数量
	self.number = content_:getChildByName('Image_223_0'):getChildByName("Label_233")
	-- 滑动条
	local sliderContainer_ = content_:getChildByName("Panel_4920_0")
	self.slider = sliderContainer_:getChildByName("ImageView_sliderBg"):getChildByName("Slider_produce")
	self.slider:addEventListenerSlider(self.onSliderPercentChange)
	sliderContainer_:getChildByName("ImageView_minus"):addTouchEventListener(self.onMinusTouched)
	sliderContainer_:getChildByName("ImageView_plus"):addTouchEventListener(self.onPlusTouched)

	-- 需要成员
	content_:getChildByName("Image_223"):addTouchEventListener(self.onStarredMemberTouched)
end

function UI_unionShopCatalogPop:calcMaxNumber()
	local num_ = 0
	num_ = math.floor(player.getAlliance():getFunds() / self.item.societySale)
	return num_
end

function UI_unionShopCatalogPop:onRemove()
	self.closeCallBack()
	self.super.onRemove(self)
end