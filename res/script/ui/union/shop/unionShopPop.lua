--
-- ui/union/unionShopPop.lua
-- 公会商店弹出界面
--===================================
require "ui/frame/popFrame"

UI_unionShopPop = class("UI_unionShopPop", UI)

--init
function UI_unionShopPop:init(sid_, subtype_, num_)
	-- data
	-- ===============================
	self.sid = sid_
	self.type = subtype_
	self.num = num_
	if num_ == nil then
		self.num = 9999
	end
	self.item = hp.gameDataLoader.getInfoBySid("item", self.sid)
	self.percent = 0
	self.maxItemNumber = self:calcMaxNumber()
	self.getNumber = 0

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
end

function UI_unionShopPop:initCallBack()
	local function updateInfo()
		self.totalCost:setString(tostring(self.getNumber * self.item.societySale))
		self.number:setString(tostring(self.getNumber))
		if self.getNumber == 0 then
			self.getBtn:setTouchEnabled(false)
			self.getBtn:loadTexture(config.dirUI.common.."button_gray1.png")
			self.percent = 0
			self.slider:setPercent(self.percent)
		else
			self.getBtn:setTouchEnabled(true)
			self.getBtn:loadTexture(config.dirUI.common.."button_green1.png")
		end
	end

	local function onPlusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			if self.getNumber < self.maxItemNumber then
				self.getNumber = self.getNumber + 1
				self.percent = hp.common.round(self.getNumber / self.maxItemNumber * 100)
				self.slider:setPercent(self.percent)
				updateInfo()
			end
		end
	end

	local function onMinusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			if self.getNumber > 0 then
				self.getNumber = self.getNumber - 1
				self.percent = hp.common.round(self.getNumber / self.maxItemNumber * 100)
				self.slider:setPercent(self.percent)
				updateInfo()
			end
		end
	end

	local function onGetResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
		end
	end

	local function onGetTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 13
			oper.type = 1
			oper.sid = self.sid
			oper.num = self.getNumber
			oper.subtype = self.type
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onGetResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onSliderPercentChange(sender, eventType)
		local per = sender:getPercent()
		if self.percent == per then
			return
		end
		self.percent = per
		-- update train number
		self.getNumber = hp.common.round(self.maxItemNumber * per / 100)
		updateInfo()
	end

	self.onPlusTouched = onPlusTouched
	self.onGetTouched = onGetTouched
	self.onMinusTouched = onMinusTouched
	self.onSliderPercentChange = onSliderPercentChange
end

function UI_unionShopPop:changeItem(sid_, subtype_, num_)
	if sid_ == self.sid then
		return
	end
	self.sid = sid_
	self.type = subtype_
	self.num = num_
	if num_ == nil then
		self.num = 9999
	end
	print(self.sid, self.type)

	self.item = hp.gameDataLoader.getInfoBySid("item", self.sid)
	self:refreshShow()
end

function UI_unionShopPop:refreshShow()
	local content_ = self.widgetRoot:getChildByName("Panel_214_1_0")

	-- 图片
	content_:getChildByName("Image_66_0"):getChildByName("Image_67"):loadTexture(string.format("%s%s.png", config.dirUI.item, tostring(self.sid)))
	-- 名称
	content_:getChildByName("Label_219"):setString(self.item.name)
	-- 描述
	content_:getChildByName("Label_219_1"):setString(self.item.desc)
	-- 拥有
	content_:getChildByName("Label_219_0"):setString(string.format(hp.lang.getStrByID(1181), self.num))
end

function UI_unionShopPop:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShopPop.json")
	local content_ = self.widgetRoot:getChildByName("Panel_214_1_0")

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
end

function UI_unionShopPop:calcMaxNumber()
	local num_ = 0
	num_ = math.floor(player.getAlliance():getFunds() / self.item.societySale)
	return num_
end

function UI_unionShopPop:close()
	self.super.close(self)
end