--
-- ui/bigMap/rally.lua
-- 集结军队
--===================================
require "ui/UI"


UI_rally = class("UI_rally", UI)


--init
function UI_rally:init(tileInfo_)
	-- data
	-- ===============================
	self.timeSecond = {300, 900, 1800, 3600, 28800}
	self.timeID = {1320, 1321, 1322, 1323, 1324}
	self.checkID = nil
	self.chooseID = 1
	self.tileInfo = tileInfo_

	-- uidata
	self.check = {}

	-- ui
	-- ===============================
	self:initCallBack()

	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1319))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	self:updateShow(self.chooseID)
end

function UI_rally:initCallBack()
	local function onSetTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			self:closeAll()
			print("marchmarch+++++++++++++")
			require "ui/march/march"
			print(self.chooseID)
			UI_march.openMarchUI(self, self.tileInfo.position, 7, self.chooseID)
		end
	end

	local function onCheckTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			self.chooseID = sender:getTag()
			self:updateShow(sender:getTag())
		end
	end

	self.onSetTouched = onSetTouched
	self.onCheckTouched = onCheckTouched
end

function UI_rally:updateShow(id_)
	for i, v in ipairs(self.check) do
		if i == id_ + 1 then
			self.check[i]:setVisible(true)
		else
			self.check[i]:setVisible(false)
		end
	end
end

function UI_rally:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "rally.json")
	local content = self.wigetRoot:getChildByName("Panel_23500")

	content:getChildByName("Label_23497"):setString(hp.lang.getStrByID(5084))

	local nameList_ = {"", "_Copy0", "_Copy1", "_Copy2", "_Copy3"}
	
	for i, v in ipairs(nameList_) do
		local container_ = content:getChildByName("Panel_23504"..nameList_[i])
		local btn_ = container_:getChildByName("ImageView_23498")
		btn_:setTag(i - 1)
		btn_:addTouchEventListener(self.onCheckTouched)
		self.check[i] = btn_:getChildByName("ImageView_23505")		
		container_:getChildByName("Label_23501"):setString(hp.lang.getStrByID(self.timeID[i]))
	end

	local setButton = content:getChildByName("ImageView_23522")
	setButton:addTouchEventListener(self.onSetTouched)
	setButton:getChildByName("Label_23523"):setString(hp.lang.getStrByID(1325))
end