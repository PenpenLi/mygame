--
-- ui/union/manage/unionChangeName.lua
-- 公会修改名称
--===================================
require "ui/fullScreenFrame"

UI_unionChangeName = class("UI_unionChangeName", UI)

local maxLen = 12
local minWordNum = 3

--init
function UI_unionChangeName:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5137))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_unionChangeName:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionChangeName.json")
	self.listView = self.wigetRoot:getChildByName("ListView_29885")
	self.item1 = self.listView:getItem(0):getChildByName("Panel_29900")
	self.item1:getChildByName("Label_29901"):setString(hp.lang.getStrByID(5057))
	self.item1:getChildByName("Label_29921"):setString(hp.lang.getStrByID(5058))
	self.item1:getChildByName("Label_7"):setString(player.getAlliance():getBaseInfo().name)

	self.item2 = self.listView:getItem(1):getChildByName("Panel_29900")
	self.item2:getChildByName("Label_29963"):setString(hp.lang.getStrByID(5059))
	self.item2:getChildByName("Label_5"):setString(string.format(hp.lang.getStrByID(5060), maxLen))
	self.item2:getChildByName("Label_5_0"):setString(string.format(hp.lang.getStrByID(5061), minWordNum))
	self.inputText = self.item2:getChildByName("Label_29944")
	self.inputText:setString(player.getAlliance():getBaseInfo().name)
	hp.uiHelper.labelBind2EditBox(self.inputText)

	self.item3 = self.listView:getItem(2):getChildByName("Panel_29900")
	self.item3:getChildByName("Label_29901"):setString(hp.lang.getStrByID(5062))
	self.item3:getChildByName("Label_29921"):setString(hp.lang.getStrByID(5058))
	local confirm_ = self.item3:getChildByName("ImageView_29964")
	confirm_:getChildByName("Label_29965"):setString(hp.lang.getStrByID(1209))
	confirm_:addTouchEventListener(self.onConfirmTouched)
end

function UI_unionChangeName:initCallBack()
	local function onConfirmResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			player.getAlliance():changeName(self.inputText:getString())
			require "ui/common/successBox"
			local box_ = UI_successBox.new("修改成功!")
			self:addModalUI(box_)
			self.item1:getChildByName("Label_7"):setString(player.getAlliance():getBaseInfo().name)
		end
	end

	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function changeUnionName()
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 16
				oper.type = 7
				oper.name = self.inputText:getString()
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onConfirmResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			end

			if player.getItemNum(20354) == 0 then
				require "ui/common/buyAndUseItemPop"
				ui_ = UI_buyAndUseItem.new(20354, 1, changeUnionName)
				self:addModalUI(ui_)
			else
				changeUnionName()
			end
		end
	end

	self.onConfirmTouched = onConfirmTouched
end