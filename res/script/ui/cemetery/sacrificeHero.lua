--
-- ui/cemetery/sacrificeHero.lua
-- 牺牲的英雄
--===================================

-- 复活英雄
-- channel = 25
-- @type = 2
--===================================

require "ui/UI"

UI_sacrificeHero = class("UI_sacrificeHero", UI)


-- init
function UI_sacrificeHero:init(bInfo)
	-- ui
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "sacrificeHero.json")
	self:addCCNode(wigetRoot)
	
	-- 标题设置
	wigetRoot:getChildByName("Panel_headCont"):getChildByName("Label_tips"):setString(bInfo.desc)
	-- 按钮设置
	local btnResurgence = wigetRoot:getChildByName("Panel_resurgence"):getChildByName("btn_resurgence")
	btnResurgence:getChildByName("Label_resurgence"):setString(hp.lang.getStrByID(7931))
	-- 回魂丹信息设置
	local ResurgenceCont = wigetRoot:getChildByName("Panel_infoCont")
	self.medicInfo = ResurgenceCont:getChildByName("Label_medic")
	-- 获取回魂丹数量
	local hasResurgenceNum = player.getItemNum(20601)
	-- 回魂丹信息
	local medicInfoStr = hp.lang.getStrByID(7932) .. " " .. hasResurgenceNum .. "/1"
	self.medicInfo:setString(medicInfoStr)

	self.itemCont = wigetRoot:getChildByName("Panel_heroCont")

	-- 重置数据
	local function resetInfo()
		-- 武将信息
		local heroInfo = player.hero.getBaseInfo()
		-- 武将可以复活
		if heroInfo.state == 2 then
			-- 显示
			self.itemCont:setVisible(true)
			wigetRoot:getChildByName("Panel_heroFrame"):setVisible(true)
			-- 武将信息
			self.time = heroInfo.reliveLeftTime
			local sid = heroInfo.sid
			local lv = player.getLv()
			-- 名字
			self.itemCont:getChildByName("Label_name"):setString(hp.lang.getStrByID(7619))
			self.itemCont:getChildByName("Label_heroName"):setString(hp.gameDataLoader.getInfoBySid("hero",sid).name)
			-- 等级
			self.itemCont:getChildByName("Label_lv"):setString(hp.lang.getStrByID(7620))
			self.itemCont:getChildByName("Label_heroLv"):setString(lv)
			self.itemCont:getChildByName("Label_heroIntro"):setString(hp.gameDataLoader.getInfoBySid("hero",sid).desc)
			self.itemCont:getChildByName("Label_time"):setString(hp.datetime.strTime(self.time))
			self.itemCont:getChildByName("img_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. sid .. ".png")
		-- 没有武将可以复活
		else
			-- 隐藏
			self.itemCont:setVisible(false)
			wigetRoot:getChildByName("Panel_heroFrame"):setVisible(false)
			-- 提示无英雄可复活
			wigetRoot:getChildByName("Panel_infoCont"):getChildByName("Label_Null"):setString(hp.lang.getStrByID(7936))
		end
	end
	resetInfo()
	self.resetInfo = resetInfo
	
	require "ui/msgBox/msgBox"
	local msgbox = nil
	local msgTips = hp.lang.getStrByID(6034)
	local msgIs = hp.lang.getStrByID(6035)
	local msgNo = hp.lang.getStrByID(6036)

	-- 复活英雄
	function ResurgenceHero()
		local function onBaseInfoResponse(status, response, tag)
			-- 服务器正常连接
			if status == 200 then
				local res = hp.httpParse(response)
				-- 成功
				if res.result ~= nil and res.result == 0 then
					-- 扣道具
					player.expendItem(20601, 1)
				end
				return
			else
				return
			end
		end
		-- 准备请求
		local cmdData = {operation = {}}
		local oper = {}
		oper.channel = 25
		oper.type = 2
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
		-- 发送请求
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		-- 等待相应
		self:showLoading(cmdSender, sender)
	end

	-- 再次确认（过时）
	local function twiceAffirm()
		local tipsStr = string.format( hp.lang.getStrByID(7934),hp.gameDataLoader.getInfoBySid("hero", player.hero.getBaseInfo().sid).name) 
		msgbox = UI_msgBox.new(msgTips, tipsStr, msgIs, msgNo, ResurgenceHero)
		self:addModalUI(msgbox)
	end

	-- 确认
	local function affirm()
		local tipsStr = string.format( hp.lang.getStrByID(7933),hp.gameDataLoader.getInfoBySid("hero", player.hero.getBaseInfo().sid).name) 
		msgbox = UI_msgBox.new(msgTips,tipsStr,msgIs,msgNo,ResurgenceHero)
		self:addModalUI(msgbox)
	end

	-- 复活事件
	local function btnResurgenceMemuItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.itemCont:isVisible() then
				local num = player.getItemNum(20601)
				if num ~= nil and num > 0 then
					affirm()
				-- 回魂丹不足
				else
					-- 提示购买
					local function buyItem()
						require("ui/item/commonItem")
						local ui = UI_commonItem.new(20601, hp.lang.getStrByID(2839))
						self:addUI(ui)
					end
					local msgBox = UI_msgBox.new(hp.lang.getStrByID(4012), hp.lang.getStrByID(7938), hp.lang.getStrByID(1209),
					hp.lang.getStrByID(2412), buyItem)
					self:addModalUI(msgBox)
				end
			end
		end
	end
	btnResurgence:addTouchEventListener(btnResurgenceMemuItemOnTouched)

	-- 注册消息
	self:registMsg(hp.MSG.HERO_INFO_CHANGE)
	self:registMsg(hp.MSG.ITEM_CHANGED)

	-- 心跳回调
	local function timeCallback(dt)
		if self.itemCont:isVisible() then
			-- 时间递减
			self.time = self.time - dt
			if self.time < 0 then
				self.time = 0
			end
			self.itemCont:getChildByName("Label_time"):setString(hp.datetime.strTime(self.time))
		end
	end
	self.timeCallback = timeCallback
end

-- 接收消息
function UI_sacrificeHero:onMsg(msg, param)
	-- 武将状态改变
	if msg == hp.MSG.HERO_INFO_CHANGE then
		-- 重设信息
		self.resetInfo()
	-- 回魂丹数量改变
	elseif msg == hp.MSG.ITEM_CHANGED and param.sid == 20601 then
		-- 重设信息
		self.medicInfo:setString(hp.lang.getStrByID(7932) .. " " .. param.num .. "/1")
	end
end

-- 心跳
function UI_sacrificeHero:heartbeat(dt)
	self.timeCallback(dt)
end