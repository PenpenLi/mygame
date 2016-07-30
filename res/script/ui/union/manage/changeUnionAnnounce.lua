--
-- ui/union/manage/changeUnionAnnounce.lua
-- 公会修改联盟公告
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_changeUnionAnnounce = class("UI_changeUnionAnnounce", UI)

local MAX_LEN = 100

--init
function UI_changeUnionAnnounce:init(announce_, callBack_)
	-- data
	-- ===============================
	self.announce = announce_
	self.callBack = callBack_

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5453))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	local function onCancelTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function callBack()
				self.callBack(self.editText.getString())
				self:close()
			end

			self:showLoading(player.unionHttpHelper.changeUnionAnnounce(self.editText.getString(), callBack), sender)
		end
	end

	local function onEditChangeTouched(sender, eventType)
		local str_ = self.editText.getString()
		local len_ = math.ceil(hp.common.utf8_strLen(str_) / 2)
		self.wordNum:setString(string.format("%d/%d", len_, MAX_LEN))
	end

	self.cancel:addTouchEventListener(onCancelTouched)
	self.confirm:addTouchEventListener(onConfirmTouched)
	self.editText.setOnChangedHandle(onEditChangeTouched)
end

function UI_changeUnionAnnounce:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "changeUnionAnnounce.json")
	local content_ = self.wigetRoot:getChildByName("Panel_3")

	local str_ = self.announce
	local num_ = math.ceil(hp.common.utf8_strLen(str_) / 2)
	local label_ = content_:getChildByName("Label_4_0")
	label_:setString(str_)
	self.editText = hp.uiHelper.labelBind2EditBox(label_)	
	self.editText.setMaxLength(MAX_LEN * 2)
	self.editText.setString(str_)

	self.wordNum = content_:getChildByName("Label_4")
	self.wordNum:setString(string.format("%d/%d", num_, 100))

	self.desc = content_:getChildByName("Label_15")
	self.cancel = content_:getChildByName("Image_9")
	self.cancel:getChildByName("Label_10"):setString(hp.lang.getStrByID(2412))
	self.confirm = content_:getChildByName("Image_9_0")
	self.confirm:getChildByName("Label_10"):setString(hp.lang.getStrByID(1209))
end