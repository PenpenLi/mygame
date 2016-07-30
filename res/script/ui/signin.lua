--
-- ui/signin.lua
-- 签到页面
--===================================

--
-- 22, 7 (sid(每日签到), id(连续登陆))
--===================================
require "ui/fullScreenFrame"

UI_signin = class("UI_signin", UI)

local info
local progressTbl = {0, 20, 40, 60, 80, 100}

function UI_signin:init()

	self.widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "sign.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(11001), "title1")
	uiFrame:setTopShadePosY(888)

	self:addChildUI(uiFrame)
	self:addCCNode(self.widget)

	info = player.signinMgr.getData()

	self:initTouchEvent()
	self:initUI()
end

function UI_signin:initTouchEvent()
	local function onCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end
	self.onCloseTouched = onCloseTouched

	local function onSignInTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if info.isSign then
				self:close()
			else
				local function onBaseInfoResponse(status, response, tag)
					if status ~= 200 then
						return
					end

					local data = hp.httpParse(response)
					if data.result == 0 then
						local signinGift = data.sid
						local loginGift = data.id
						if signinGift ~= 0 then
							if self.light then
								self.light:setVisible(false)
							end
							if self.light2 then
								self.light2:setVisible(false)
							end
							
							self.items[info.day]:getChildByName("Image_state"):setVisible(true)
							self.label_close:setString(hp.lang.getStrByID(11006))
							info.signinDay = info.signinDay + 1
							info.isSign = true
							self:setProgress()

							Scene.showMsg({5001, hp.gameDataLoader.getInfoBySid("item", signinGift).name, 1})
						end
						if loginGift ~= 0 then
							Scene.showMsg({5002, hp.gameDataLoader.getInfoBySid("item", loginGift).name, 1})
						end
						hp.msgCenter.sendMsg(hp.MSG.SIGN_IN)
					end
				end
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 22
				oper.type = 7
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)
			end
		end
	end
	self.onSignInTouched = onSignInTouched
end

function UI_signin:initUI()

	local list = self.widget:getChildByName("ListView_root")
	list:setClippingType(1)
	local root = list:getItem(0)

	-- content
	local content = root:getChildByName("Panel_content")

	-- content:getChildByName("BitmapLabel_title"):setString(hp.lang.getStrByID(11001))
	content:getChildByName("Label_text"):setString(hp.lang.getStrByID(11007))
	content:getChildByName("Label_tips"):setString(hp.lang.getStrByID(11009))

	-- close
	-- content:getChildByName("Image_close"):addTouchEventListener(self.onCloseTouched)

	-- sign in or close
	local label_close = content:getChildByName("Label_close")
	self.label_close = label_close
	local image_close = content:getChildByName("Image_close2")
	self.image_close = image_close
	if info.isSign then
		label_close:setString(hp.lang.getStrByID(11006))
		image_close:addTouchEventListener(self.onCloseTouched)
	else
		label_close:setString(hp.lang.getStrByID(11010))
		image_close:addTouchEventListener(self.onSignInTouched)
	end

	-- sign in content
	local signin_content = root:getChildByName("Panel_content2")
	
	local items = signin_content:getChildren()
	self.items = items
	local rewards = hp.gameDataLoader.getTable("daily")
	local rewards2 = hp.gameDataLoader.getTable("daily_s")

	-- set data
	for i, item in ipairs(items) do
		-- max day of month
		if i <= info.max then
			-- new
			if i >= info.startTime and i <= info.endTime then
				local id
				if i < 7 then
					id = i + 7 - info.endTime
				else
					id = i - info.startTime + 1
				end
				item:getChildByName("Image_reward"):loadTexture(string.format("%s%d.png", config.dirUI.item, rewards2[id].sid))
				item:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11011))
				item:getChildByName("Label_desc"):setColor(cc.c3b(60, 223, 16))
			else
				item:getChildByName("Image_reward"):loadTexture(string.format("%s%d.png", config.dirUI.item, rewards[i].sid))
				item:getChildByName("Label_desc"):setString(i)
			end
			-- get rewards info
			if i <= info.day then
				if i ~= info.day then
					item:getChildByName("Image_state"):setVisible(true)

					local isGet = false
					for j,v in ipairs(info.signinInfo) do
						if i == v then
							isGet = true
						end
					end
					if not isGet then
						item:getChildByName("Image_state"):loadTexture(config.dirUI.common .. "wrong.png")
					end
				elseif info.isSign then
					item:getChildByName("Image_state"):setVisible(true)
				else
					require "ui/common/effect"
					self.light = inLight(item:getVirtualRenderer(), 3)
					item:addChild(self.light)
				end
			end
		else
			item:setVisible(false)
		end
	end

	-- login content
	local login_content = root:getChildByName("Panel_content3")
	self.login_content = login_content

	login_content:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(11003), 2))
	login_content:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(11003), 3))
	login_content:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(11003), 4))
	login_content:getChildByName("Label_4"):setString(string.format(hp.lang.getStrByID(11003), 5))
	login_content:getChildByName("Label_5"):setString(string.format(hp.lang.getStrByID(11003), 6))
	login_content:getChildByName("Label_6"):setString(hp.lang.getStrByID(11008))

	-- sign in progress
	local login_frame = root:getChildByName("Panel_frame2")
	self.progress = login_frame:getChildByName("ProgressBar_day")

	local boxTbl = {}
	boxTbl[1] = login_content:getChildByName("Image_box1")
	boxTbl[2] = login_content:getChildByName("Image_box2")
	boxTbl[3] = login_content:getChildByName("Image_box3")
	boxTbl[4] = login_content:getChildByName("Image_box4")
	boxTbl[5] = login_content:getChildByName("Image_box5")
	boxTbl[6] = login_content:getChildByName("Image_box6")
	self.boxTbl = boxTbl
	self:setProgress()
end

function UI_signin:setProgress()
	if info.signinDay > 6 then
		self.progress:setPercent(progressTbl[6])
		if info.isSign then
			self.boxTbl[6]:loadTexture(config.dirUI.common .. "signIn_box_open.png")
		else
			require "ui/common/effect"
			self.light2 = outLight2(config.dirUI.common.."copy_7.png")
			self.light2:setScale(self.boxTbl[6]:getScale())
			self.light2:setPosition(self.boxTbl[6]:getPosition())
			self.login_content:addChild(self.light2)
		end
	elseif (info.signinDay > 0 and not info.isSign) or info.signinDay > 1 then
		local signin_pro = info.signinDay

		if info.isSign then
			signin_pro = signin_pro - 1
			self.boxTbl[signin_pro]:loadTexture(config.dirUI.common .. "signIn_box_open.png")
		else
			require "ui/common/effect"
			self.light2 = outLight2(config.dirUI.common.."copy_7.png")
			self.light2:setScale(self.boxTbl[signin_pro]:getScale())
			self.light2:setPosition(self.boxTbl[signin_pro]:getPosition())
			self.login_content:addChild(self.light2)
		end

		for i = signin_pro - 1, 1, -1 do
			self.boxTbl[i]:loadTexture(config.dirUI.common .. "signIn_box_open.png")
		end

		self.progress:setPercent(progressTbl[signin_pro])
	else

	end
end