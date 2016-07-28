--
-- ui/common/goldCostConfirm.lua
-- 金币消耗弹出框
--===================================
require "ui/frame/popFrame"

UI_goldCostConfirm = class("UI_goldCostConfirm", UI)

--init
function UI_goldCostConfirm:init(desc_, num_, item_, callBack_)
	-- data
	-- ===============================
	self.item = item_
	self.desc = desc_
	self.num = num_
	self.callBack = callBack_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1191))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_goldCostConfirm:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "goldCostConfirm.json")
	local content_ = self.wigetRoot:getChildByName("Panel_10")

	-- 描述
	content_:getChildByName("Label_11"):setString(self.desc)
	-- 道具
	content_:getChildByName("Label_11_0"):setString(self.item.desc)
	content_:getChildByName("Label_11_0_0"):setString(self.item.name)
	local image_ = content_:getChildByName("ImageView_29941_0_0")

	-- 拥有
	image_:getChildByName("Label_11_0_1"):setString(player.getItemNum(self.item.sid))
	-- 道具图片
	image_:getChildByName("ImageView_29942"):loadTexture(string.format("%s%d.png", config.dirUI.item, self.item.sid))

	content_:getChildByName("Image_16_1"):addTouchEventListener(self.onCancelTouched)
	content_:getChildByName("Image_16_1"):getChildByName("Label_17"):setString(hp.lang.getStrByID(2412))

	local okBtn_ = content_:getChildByName("Image_16_0")
	okBtn_:addTouchEventListener(self.onOKTouched)
	okBtn_:getChildByName("Label_17"):setString(hp.lang.getStrByID(1209))
	okBtn_:getChildByName("ImageView_gold_0_0_0_0"):getChildByName("Label_goldCost"):setString(tostring(self.item.sale * self.num))
end

function UI_goldCostConfirm:initCallBack()
	local function onOKTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.callBack ~= nil then
				self.callBack()
			end
			self:close()
		end
	end

	local function onCancelTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	self.onOKTouched = onOKTouched
	self.onCancelTouched = onCancelTouched
end