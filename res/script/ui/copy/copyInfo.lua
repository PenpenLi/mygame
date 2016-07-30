--
-- ui/copy/copyInfo.lua
-- 副本信息 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_copyInfo = class("UI_copyInfo", UI)

--init
function UI_copyInfo:init(copyInfo_)
	-- data
	-- ===============================
	self.copyInfo = copyInfo_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()
	
	local popFrame = UI_popFrame.new(self.wigetRoot, self.copyInfo.info.name)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- 和新手指引界面绑定
	self:registMsg(hp.MSG.GUIDE_STEP)
	local function bindGuideUI(step)
		if step==7006 then
			player.guide.bind2Node(step, self.startBtn, self.onStartBattleTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
end

function UI_copyInfo:onMsg(msg_, param_)
	if msg_==hp.MSG.GUIDE_STEP then
	-- 新手指引
		self.bindGuideUI(param_)
	end
end

function UI_copyInfo:initCallBack()
	local function onStartBattleTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.copyInfo.open == false then
				require "ui/common/successBox"
				local box_ = UI_successBox.new(hp.lang.getStrByID(5224), hp.lang.getStrByID(5225), nil)
	  			self:addModalUI(box_)
	  		elseif (self.copyInfo.limited ~= -1) and (self.copyInfo.limited == self.copyInfo.times) then
	  			require "ui/common/successBox"
				local box_ = UI_successBox.new(hp.lang.getStrByID(5227), hp.lang.getStrByID(5228), nil)
	  			self:addModalUI(box_)
	  		elseif self.copyInfo.info.bodyForce > player.getEnerge() then
	  			local function goShop()
					require "ui/item/energyItem"
					local ui = UI_energyItem.new()
					self:addUI(ui)
					self:close()
				end
				require("ui/msgBox/msgBox")
				local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(7909),
					hp.lang.getStrByID(10807), hp.lang.getStrByID(2412), goShop)
				self:addModalUI(msgbox)
	  		else
	  			local function onHttpResponse(status, response, tag)
					if status~=200 then
						return
					end

					local data = hp.httpParse(response)
					if data.result ~= nil and data.result == 0 then
						data.id = self.copyInfo.id
			  			self:close()
						require "ui/battle/battle"
						local ui = UI_battle.new(self.copyInfo.groupID, data, function(attack_, defense_, battleUI_) player.copyManager.handleFightResult(data, attack_, defense_, battleUI_) end)
						self:addModalUI(ui)
						-- player.copyManager.handleFightResult(data)
						--player.guide.stepEx({7006})
						player.guide.finishCurStep()
					end	
				end

				local oper = {}
				local cmdData={operation={}}
				oper.channel = 21
				oper.type = 2
				oper.id = math.floor(self.copyInfo.id/100)
				oper.sid = self.copyInfo.id
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)
	  		end
		end
	end

	self.onStartBattleTouched = onStartBattleTouched
end

function UI_copyInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "copyInfo.json")
	local content = self.wigetRoot:getChildByName("Panel_3")

	-- 描述
	content:getChildByName("Label_5"):setString(self.copyInfo.info.description)

	-- 开始战斗
	self.startBtn = content:getChildByName("Image_16")
	-- 开启状态
	if self.copyInfo.open == true then
		self.startBtn:addTouchEventListener(self.onStartBattleTouched)
		self.startBtn:getChildByName("Label_106"):setString(hp.lang.getStrByID(5455))
		self.startBtn:getChildByName("Label_107"):setString(string.format(hp.lang.getStrByID(5223), self.copyInfo.info.bodyForce))
	else
		self.startBtn:setVisible(false)
		content:getChildByName("Image_78"):setVisible(true)
		content:getChildByName("Image_98_1"):setVisible(true)
		local label_ = content:getChildByName("Label_55_0_1")
		label_:setVisible(true)
		-- 开启条件
		if self.copyInfo.info.preSid[1] ~= -1 then
			local str_ = ""
			for i, v in ipairs(self.copyInfo.info.preSid) do
				local info_ = hp.gameDataLoader.getInfoBySid("instance", v)
				if i == 1 then
					str_ = info_.name
				else
					str_ = str_..","..info_.name
				end
			end
			label_:setString(string.format(hp.lang.getStrByID(5222), str_))
		end
	end

	-- 星级
	if self.copyInfo.star > 0 then
		for i = 1, self.copyInfo.star do
			local star_ = content:getChildByName("star"..i)
			star_:setVisible(true)
			star_:loadTexture(config.dirUI.common.."copy_3.png")
		end
	end

	-- 战力
	content:getChildByName("Label_44"):setString(hp.lang.getStrByID(5043)..":")
	local totalPower = 0
	for i, v in ipairs(self.copyInfo.info.branchNums) do
		if v ~= 0 then
			local solInfo_ = nil
			local point_ = 0
			if i == 5 then
				solInfo_ = hp.gameDataLoader.getInfoBySid("trap", self.copyInfo.info.branchSids[i])
				point_ = solInfo_.point
			else
				solInfo_ = hp.gameDataLoader.getInfoBySid("army", self.copyInfo.info.branchSids[i])
				point_ = solInfo_.addPoint
			end

			-- 战力计算
			local power_ = v * point_
			totalPower = totalPower + power_
		end
	end
	if self.copyInfo.remainPower == -1 then
		content:getChildByName("Label_5_0"):setString(totalPower.."/"..totalPower)
		self.wigetRoot:getChildByName("Panel_1"):getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640"):setPercent(100)
	else
		content:getChildByName("Label_5_0"):setString(self.copyInfo.remainPower.."/"..totalPower)
		local per_ = (self.copyInfo.remainPower/totalPower) * 100
		self.wigetRoot:getChildByName("Panel_1"):getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640"):setPercent(per_)
	end	

	-- 攻打次数
	local uiTimes_ = content:getChildByName("Label_5_0_0")
	if self.copyInfo.attackTimes == 0 then
		uiTimes_:setVisible(false)
	else
		uiTimes_:setString(string.format(hp.lang.getStrByID(5390), self.copyInfo.attackTimes))
	end

	local rewardNum_ = 0
	local image_ = {}
	local label_ = {}
	for i = 1, 3 do
		image_[i] = content:getChildByName("Image_"..i)
		label_[i] = content:getChildByName("Label_"..i)
	end

	-- 资源
	for i, v in ipairs(self.copyInfo.info.res) do
		if v ~= 0 then
			local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
			image_[1]:getChildByName("Image_12"):setVisible(true)
			image_[1]:getChildByName("Image_12"):loadTexture(config.dirUI.common..resInfo_.image)
			label_[1]:setVisible(true)
			label_[1]:setString(resInfo_.name)
			rewardNum_ = 1
			break
		end
	end

	-- 道具
	content:getChildByName("Label_55"):setString(hp.lang.getStrByID(5398))
	content:getChildByName("Label_55_0"):setString(hp.lang.getStrByID(5399))
	content:getChildByName("Label_4"):setString(hp.lang.getStrByID(5400))
	for i, v in ipairs(self.copyInfo.info.gemSids) do
		if v == -1 then
			break
		end

		local item_ = hp.gameDataLoader.getInfoBySid("item", v)
		if item_ ~= nil then
			image_[i+1]:getChildByName("Image_12"):setVisible(true)
			image_[i+1]:getChildByName("Image_12"):loadTexture(config.dirUI.item..v..".png")
			label_[i+1]:setVisible(true)
			label_[i+1]:setString(item_.name)
			rewardNum_ = rewardNum_ + 1
		end
	end

	-- -- 隐藏多余的
	-- for i = rewardNum_+1, 3 do
	-- 	image_[i]:setVisible(false)
	-- 	label_[i]:setVisible(false)
	-- end

	-- -- 调整位置
	-- local x_1, y_1 = image_[1]:getPosition()
	-- local x_2, y_2 = label_[1]:getPosition()
	-- local x_3, y_3 = image_[3]:getPosition()
	-- local delta_ = (x_3 - x_1 + image_[1]:getSize().width*2) / (rewardNum_ + 1)
	-- -- 起点
	-- local x_ = x_1 - image_[1]:getSize().width
	-- if rewardNum_ < 3 then
	-- 	for i = 1, rewardNum_ do
	-- 		cclog_("x_1 + delta_ * i",x_1 + delta_ * i)
	-- 		image_[i]:setPosition(x_ + delta_ * i, y_1)
	-- 		label_[i]:setPosition(x_ + delta_ * i, y_2)
	-- 	end
	-- end
end