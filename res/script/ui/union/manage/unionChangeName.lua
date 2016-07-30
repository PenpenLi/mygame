--
-- ui/union/manage/unionChangeName.lua
-- 公会修改名称
--===================================
require "ui/fullScreenFrame"

UI_unionChangeName = class("UI_unionChangeName", UI)

local minWordNum = 3
local NAME_LEN = 8

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
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(888)
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
	self.item2:getChildByName("Label_5_0"):setString(string.format(hp.lang.getStrByID(5061), minWordNum))
	local label_ = self.item2:getChildByName("Label_29944")	
	label_:setString(player.getAlliance():getBaseInfo().name)
	self.inputText = hp.uiHelper.labelBind2EditBox(label_)
	self.inputText.setMaxLength(NAME_LEN)

	self.item3 = self.listView:getItem(2):getChildByName("Panel_29900")
	self.item3:getChildByName("Label_29901"):setString(hp.lang.getStrByID(5062))
	self.item3:getChildByName("Label_29921"):setString(hp.lang.getStrByID(5058))
	local confirm_ = self.item3:getChildByName("ImageView_29964")
	confirm_:getChildByName("Label_29965"):setString(hp.lang.getStrByID(1209))
	confirm_:addTouchEventListener(self.onConfirmTouched)
end

function UI_unionChangeName:initCallBack()
	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function changeUnionName(gold_)
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 16
				oper.type = 7
				oper.name = self.inputText:getString()
				oper.gold = gold_
				local tag_ = 1
				if gold_ == 0 then
					tag_ = 2
				end
				cmdData.operation[1] = oper

				local function onConfirmResponse(status, response, tag)
					if status ~= 200 then
						return
					end

					local data = hp.httpParse(response)
					if data.result == 0 then
						player.getAlliance():changeName(self.inputText:getString())
						self.item1:getChildByName("Label_7"):setString(player.getAlliance():getBaseInfo().name)
						if tag == 1 then
							player.expendResource("gold", oper.gold)
						elseif tag == 2 then
							player.expendItem(20354, 1)
						end
						Scene.showMsg({1023})
					end
				end

				local cmdSender = hp.httpCmdSender.new(onConfirmResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
				self:showLoading(cmdSender, sender)
			end

			if self.inputText:getString() == "" then
				require "ui/common/successBox"
				local box_ = UI_successBox.new(hp.lang.getStrByID(5312), hp.lang.getStrByID(5313))
				self:addModalUI(box_)
			else
				require "ui/common/buyAndUseItemPop"
				local ui_ = UI_buyAndUseItem.new(20354, 1, changeUnionName)
				self:addModalUI(ui_)
			end
		end
	end

	self.onConfirmTouched = onConfirmTouched
end