--
-- ui/anguoss.lua
-- 城内信息
--===================================
require "ui/UI"

UI_famousHeroAuctionInputBox = class("UI_famousHeroAuctionInputBox", UI)


--init
function UI_famousHeroAuctionInputBox:init(sid)
	-- data
	
	local heroInfo = hp.gameDataLoader.getInfoBySid("hero", sid)
	
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "famousHeroAuctionInputBox.json")
	self:addCCNode(wigetRoot)
	
	local panelCont = wigetRoot:getChildByName("Panel_cont")
	local editLabel = panelCont:getChildByName("img_editbox"):getChildByName("Label_edit")
	
	--大标题
	panelCont:getChildByName("Labe_title"):setString(string.format(hp.lang.getStrByID(6037), heroInfo.name))
	
	--拼接3段不同颜色文字
	local acutionTitle1 = panelCont:getChildByName("Label_acutionTitle1")
	acutionTitle1:setString(hp.lang.getStrByID(6038))
	acutionTitle1:getChildByName("Label_acutionTitle2"):setString(string.format("%d",heroInfo.lowPrice))
	acutionTitle1:getChildByName("Label_acutionTitle3"):setString(hp.lang.getStrByID(6018))
	
	--简介
	panelCont:getChildByName("Label_intro"):setString(string.format(hp.lang.getStrByID(6039)))


	panelCont:getChildByName("btn_cancel"):getChildByName("Label_cancel"):setString(hp.lang.getStrByID(2412))
	
	--按钮初始化不可用
	local btn_ok = panelCont:getChildByName("btn_ok")
	btn_ok:getChildByName("Label_ok"):setString(hp.lang.getStrByID(1506))
	btn_ok:setTouchEnabled(false)

	
	--ok按钮回调设置
	local ctr = hp.uiHelper.labelBind2EditBox(editLabel)
	
	local function editOnChangedFun()

		if tonumber(ctr.getString()) < 0 then
			btn_ok:loadTexture(config.dirUI.common .. "button_gray.png")
			btn_ok:setTouchEnabled(false)
		else	
		
			if tonumber(ctr.getString()) > player.getResource("gold") then
				ctr.setString("" .. player.getResource("gold") )
			end
			
			btn_ok:loadTexture(config.dirUI.common .. "button_green.png")
			btn_ok:setTouchEnabled(true)
		end
	end

	ctr.setOnChangedHandle(editOnChangedFun)
	ctr.editbox:setInputMode(2)
	
	
	
	
	
	
	local function btn_cancel_callback(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end


	
	
	
	
	require "ui/msgBox/msgBox"
	local msgbox = nil
	
	local msgTips = hp.lang.getStrByID(6034)
	local msgIs = hp.lang.getStrByID(6035)
	local msgNo = hp.lang.getStrByID(6036)
	
	
	
	
	
	--当钱超过 直接购买的价格时			
	--直接购买回调
	local function onBuyHeroHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--竞价成功
				
				msgbox = UI_msgBox.new(msgTips,hp.lang.getStrByID(6040),msgIs)
				self:addModalUI(msgbox)
				
				--通知刷新
				hp.msgCenter.sendMsg(hp.MSG.FAMOUS_HERO_LIST_UPDATE)
				
			end
			
		end
	end


	local function onBuyHero( price )
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 15
		oper.type = 6
		oper.sid = sid
		oper.price = price
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onBuyHeroHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end


	
	
	
			
	-- 竞拍回调 
	local function onAuctionHeroHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--竞价成功
				msgbox = UI_msgBox.new(msgTips,string.format(hp.lang.getStrByID(6041),heroInfo.name),msgIs)
				self:addModalUI(msgbox)
				
				
				--通知刷新
				hp.msgCenter.sendMsg(hp.MSG.FAMOUS_HERO_LIST_UPDATE)
				--cclog_("竞价完成 刷新 传递 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
			end
			
		end
	end
	
	
	local function onAuctionHero( price )
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 15
		oper.type = 5
		oper.sid = sid
		oper.price = price
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onAuctionHeroHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end
	
	
	
	
	
	
	
	
	local function btn_ok_callback(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			local curPri = tonumber(ctr.getString())
			
			--确认
			local function affirm()
				--用小于等于直接购买的价格 发送数据
				if curPri > heroInfo.highPrice then 
					
					curPri = heroInfo.highPrice
					onBuyHero(curPri)
				
				else
				
					onAuctionHero(curPri)
					
				end
				--cclog_("use " .. curPri .. " price buy .....................................!!!!!!!")
				
			end
			
			
			--竞拍 二次确认
			local function twiceAffirm()
				msgbox = UI_msgBox.new(msgTips,hp.lang.getStrByID(6030),msgIs,msgNo,affirm)
				self:addModalUI(msgbox)
			end
			
			
			
			
			
			if curPri > heroInfo.highPrice then
			--超过直接获取的价格
				msgbox = UI_msgBox.new(msgTips,string.format(hp.lang.getStrByID(6029),heroInfo.highPrice),msgIs,msgNo,twiceAffirm)
				self:addModalUI(msgbox)
			
			--金额大于等于竞拍底价
			elseif curPri >= heroInfo.lowPrice then
				--当前已有英雄
				if	player.hero.isValid() then
					msgbox = UI_msgBox.new(msgTips,string.format(hp.lang.getStrByID(6026),curPri,heroInfo.name),msgIs,msgNo,twiceAffirm)
					self:addModalUI(msgbox)
				else
				--当前没有英雄
					msgbox = UI_msgBox.new(msgTips,string.format(hp.lang.getStrByID(6027),curPri,heroInfo.name),msgIs,msgNo,twiceAffirm)
					self:addModalUI(msgbox)
					
				end
				
			elseif curPri < heroInfo.lowPrice then
				--低于最低竞拍价格
				--UI_msgBox.showCommonMsg(self, 1)
				require("ui/msgBox/msgBox")
					local msgBox = UI_msgBox.new(hp.lang.getStrByID(1191), hp.lang.getStrByID(6047))
				self:addModalUI(msgBox)
				return
			end




			
			
			self:close()
		end
	end





	panelCont:getChildByName("btn_cancel"):addTouchEventListener(btn_cancel_callback)

	panelCont:getChildByName("btn_ok"):addTouchEventListener(btn_ok_callback)


end