--
-- ui/mainBuilding/cityChangeName.lua
-- 主城改名
--===================================
require "ui/fullScreenFrame"

UI_cityChangeName = class("UI_cityChangeName", UI)

local NAME_LEN = 8

--init
function UI_cityChangeName:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5247))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_cityChangeName:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "cityRename.json")

	local content_ = self.wigetRoot:getChildByName("Panel_2")

	-- 提示
	content_:getChildByName("Label_30"):setString(hp.lang.getStrByID(5243))

	-- 字符限制
	content_:getChildByName("Label_31_0"):setString(string.format(hp.lang.getStrByID(5244), NAME_LEN/2, NAME_LEN))

	-- 请输入
	content_:getChildByName("Label_31_0_1"):setString(hp.lang.getStrByID(5245))

	local confirm_ = content_:getChildByName("Image_34")
	confirm_:getChildByName("Label_35"):setString(hp.lang.getStrByID(1209))
	confirm_:addTouchEventListener(self.onConfirmTouched)

	local label_ = content_:getChildByName("Label_31")
	label_:setString(player.getName())
	self.editBox = hp.uiHelper.labelBind2EditBox(label_)
	self.editBox.setMaxLength(NAME_LEN)
end

function UI_cityChangeName:initCallBack()
	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function callBack()
				player.setName(self.editBox.getString())
				hp.msgCenter.sendMsg(hp.MSG.CHANGE_CITYNAME)
				self:close()
			end

			if self.editBox:getString() == "" then
				require "ui/common/successBox"
				local box_ = UI_successBox.new(hp.lang.getStrByID(5312), hp.lang.getStrByID(5313))
				self:addModalUI(box_)
			else
				require "ui/common/buyAndUseItemPop"
				ui_ = UI_buyAndUseItem.new(20351, 1, nil, nil, {param=self.editBox.getString()}, callBack)
				self:addModalUI(ui_)
			end
		end
	end

	self.onConfirmTouched = onConfirmTouched
end

function UI_cityChangeName:onMsg(msg_, param_)
end