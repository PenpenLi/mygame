--
-- ui/mansion/giftItem/signGiftItem.lua
-- 签到奖励
--===================================

-- 类
--===================================
SignGiftItem = class("SignGiftItem")

-- 初始化
function SignGiftItem:ctor(item_, parent_)
	self.item = item_
	self.parent = parent_
	self:initTouchEvent()
	self:initUI()
end

-- 初始化事件
function SignGiftItem:initTouchEvent()
	-- 签到
	local function signin(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/signin"
			local ui = UI_signin.new()
			self.parent:addUI(ui)
		end
	end
	self.signin = signin
end

-- 初始化UI
function SignGiftItem:initUI()
	local content_sign = self.item:getChildByName("Panel_content")
	content_sign:getChildByName("Label_title"):setString(hp.lang.getStrByID(11001))
	content_sign:getChildByName("Label_timeTitle"):setString(hp.lang.getStrByID(11002))
	content_sign:getChildByName("Label_time"):setString(string.format(hp.lang.getStrByID(11003), player.signinMgr.getData().signinDay))

	local sign_btn = content_sign:getChildByName("Image_getBtn")
	if player.signinMgr.isSign() then
		sign_btn:getChildByName("Label_info"):setString(hp.lang.getStrByID(11005))
		self.priority = 3
	else
		sign_btn:getChildByName("Label_info"):setString(hp.lang.getStrByID(11004))
		self.priority = 1
	end
	sign_btn:addTouchEventListener(self.signin)

	self.sign_timeLabel = content_sign:getChildByName("Label_time")
	self.sign_btnText = sign_btn:getChildByName("Label_info")
end