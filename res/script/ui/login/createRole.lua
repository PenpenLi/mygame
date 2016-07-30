--
-- ui/login/createRole.lua
-- 创建角色
--===================================
require "ui/fullScreenFrame"

UI_createRole = class("UI_createRole", UI)

local roleImageList_ = {"login_9.png", "login_10.png"}
local MAX_LEN = 8

--init
function UI_createRole:init(loadingScene_, name_)
	-- data
	-- ===============================
	self.curTab = 1
	self.loadingScene = loadingScene_
	self.defaultName = name_

	-- ui data
	self.uiSexImg = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:hideTopShade()
	uiFrame:setTitle(hp.lang.getStrByID(5465), "title1")
	uiFrame:setBackEnabled()

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_createRole:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "createRole.json")
	self.roleImg = self.wigetRoot:getChildByName("Panel_23"):getChildByName("Image_21")
	local content_ = self.wigetRoot:getChildByName("Panel_5")

	-- 性别
	self.uiSexImg[1] = content_:getChildByName("Image_7")
	self.uiSexImg[1]:addTouchEventListener(self.onSexTouched)
	self.uiSexImg[1]:getChildByName("BitmapLabel_10"):setString(hp.lang.getStrByID(5466))
	self.uiSexImg[2] = content_:getChildByName("Image_7_0")
	self.uiSexImg[2]:addTouchEventListener(self.onSexTouched)
	self.uiSexImg[2]:getChildByName("BitmapLabel_11"):setString(hp.lang.getStrByID(5467))

	-- 名字
	local nameBg_ = content_:getChildByName("Image_12")
	local name_ = nameBg_:getChildByName("Label_14")
	-- name_:setString(self.defaultName)
	nameBg_:getChildByName("Image_13"):addTouchEventListener(self.onRandomNameTouched)
	self.name = hp.uiHelper.labelBind2EditBox(name_)
	self.name.setString(self.defaultName)
	self.name.setMaxLength(MAX_LEN)

	-- 确定
	local confirm_ = content_:getChildByName("Image_15_0")
	confirm_:addTouchEventListener(self.onConfirmTouched)
	confirm_:getChildByName("Label_16"):setString(hp.lang.getStrByID(1209))

	-- 取消
	local confirm_ = content_:getChildByName("Image_15")
	confirm_:addTouchEventListener(self.onCancelTouched)
	confirm_:getChildByName("Label_16"):setString(hp.lang.getStrByID(2412))
end

-- 随机名字
function UI_createRole:randomName()
	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			self.name.setString(data.name)
		end	
	end

	local oper = {}
	local cmdData={operation={}}
	oper.channel = 22
	oper.type = 6
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	return cmdSender
end

function UI_createRole:initCallBack()
	local function onCancelTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			-- 回到登录界面
			game.sdkHelper.logout()
		end
	end	

	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function onHttpResponse(status, response, tag)
				if status~=200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result ~= nil and data.result == 0 then
					-- self:close()
					player.initData(data)
					self:close()
					self.loadingScene.enterGame()
				end
			end

			local oper = {}
			local cmdData={operation={}}
			oper.channel = 22
			oper.type = 5
			oper.sid = 1000 + self.curTab
			oper.name = self.name.getString()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onHttpResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end	

	local function onRandomNameTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:showLoading(self:randomName(), sender)
		end
	end

	local function onSexTouched(sender, eventType)
		local tag_ = sender:getTag()
		if self.curTab == tag_ then
			return
		end
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			for i = 1, 2 do
				if i == tag_ then
					self.uiSexImg[i]:loadTexture(config.dirUI.common.."login_13.png")
				else
					self.uiSexImg[i]:loadTexture(config.dirUI.common.."login_12.png")
				end
			end
			-- 角色
			self.roleImg:loadTexture(config.dirUI.common..roleImageList_[tag_])
			-- self:randomName()
			self.curTab = tag_
		end
	end

	self.onRandomNameTouched = onRandomNameTouched
	self.onCancelTouched = onCancelTouched
	self.onConfirmTouched = onConfirmTouched
	self.onSexTouched = onSexTouched
end