--
-- ui/common/noBuildingNotice.lua
-- 缺少建筑
--===================================
require "ui/frame/popFrame"

UI_noBuildingNotice = class("UI_noBuildingNotice", UI)

--init
function UI_noBuildingNotice:init(text_, buildingID_, level_, title_, callBack_)
	-- data
	-- ===============================
	self.text = text_
	self.callBack = callBack_
	self.build = buildingID_
	self.lv = level_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = nil
	if title_ ~= nil then
		popFrame = UI_popFrame.new(self.wigetRoot, title_)
	else
		popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1191))
	end
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_noBuildingNotice:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "noBuildingNotice.json")
	local content_ = self.wigetRoot:getChildByName("Panel_2")

	content_:getChildByName("Label_4"):setString(self.text)

	local okButton = content_:getChildByName("Image_5")
	okButton:getChildByName("Label_6"):setString(hp.lang.getStrByID(5200))
	okButton:addTouchEventListener(self.onOKTouched)

	-- 图片
	local buildInfo_ = hp.gameDataLoader.getTable("upgrade")
	for i, v in ipairs(buildInfo_) do
		if v.buildSid == self.build and v.level == self.lv then
			content_:getChildByName("Image_3"):loadTexture(config.dirUI.building..v.img)
		end
	end
end

function UI_noBuildingNotice:initCallBack()
	local function onOKTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.callBack ~= nil then
				self.callBack()
			end
			self:close()
		end
	end

	self.onOKTouched = onOKTouched
end