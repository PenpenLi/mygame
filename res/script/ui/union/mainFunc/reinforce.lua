--
-- ui/union/reinforce.lua
-- 支援士兵
--===================================
require "ui/frame/popFrame"

UI_reinforce = class("UI_reinforce", UI)

--init
function UI_reinforce:init(id_)
	-- data
	-- ===============================
	self.member = player.getAlliance():getMemberByID(id_)
	self.id = id_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local popFrame = UI_popFrame.new(self.widgetRoot, hp.lang.getStrByID(1820))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.widgetRoot)

	self:requestData()
end

function UI_reinforce:requestData()
	local function onHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.num = data.num
			self.count = data.count
			self.soldierNum:setString(string.format("%d/%d", data.num, data.count))
		end
	end
	
	local cmdData={operation={}}
	local oper = {}
	oper.channel = 6
	oper.type = 11
	oper.id = self.id
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_reinforce:initCallBack()
	local function onReinforceTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local soldierNum_ = self.count - self.num

			local function onConfirm1Touched()
				local function callBack()
					self:close()
				end
				require "ui/march/march"			
				if self.member ~=nil then
					UI_march.openMarchUI(self, self.member:getPosition(), globalData.MARCH_TYPE.REINFORCE, {maxNumber=soldierNum_, armyID=0}, callBack)
				end
			end

			if soldierNum_ == 0 then
				require "ui/common/successBox"
	   			local box_ = UI_successBox.new(hp.lang.getStrByID(5460), hp.lang.getStrByID(5461), nil)
	   			self:addModalUI(box_)
			elseif player.getNewGuyGuard() ~= 0 then
				require "ui/common/msgBoxRedBack"
	   			local ui_ = UI_msgBoxRedBack.new(hp.lang.getStrByID(5143), hp.lang.getStrByID(5144), hp.lang.getStrByID(1209),
	   				hp.lang.getStrByID(2412), onConfirm1Touched)
	   			self:addModalUI(ui_)
	   		else
	   			onConfirm1Touched()
	   		end
		end
	end

	local function onCancelTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	self.onCancelTouched = onCancelTouched
	self.onReinforceTouched = onReinforceTouched
end

function UI_reinforce:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "reinforce.json")
	local content_ = self.widgetRoot:getChildByName("Panel_11")

	content_:getChildByName("Label_6"):setString(hp.lang.getStrByID(1153))
	content_:getChildByName("Label_7"):setString(hp.lang.getStrByID(2412))
	content_:getChildByName("Label_12"):setString(hp.lang.getStrByID(1154))
	content_:getChildByName("Label_12_0"):setString(hp.lang.getStrByID(1155))

	self.soldierNum = content_:getChildByName("Label_16")

	self.widgetRoot:getChildByName("Panel_3"):getChildByName("Image_5"):addTouchEventListener(self.onReinforceTouched)
	self.widgetRoot:getChildByName("Panel_3"):getChildByName("Image_5_0"):addTouchEventListener(self.onCancelTouched)
end