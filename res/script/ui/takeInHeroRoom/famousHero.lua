--
-- ui/takeInHeroRoom/famousHero.lua
-- 招贤馆
--===================================
require "ui/UI"

UI_famousHero = class("UI_famousHero", UI)





--init
function UI_famousHero:init(bInfo)
	
	-- data
	--UI英雄列表
	local ListView_hero = nil

	--当前竞拍信息
	local myAuction={price=0}

	--需要动态修改的时间表
	local timeTable = {}

	local UI_famousHeroSelf = nil

	--msgbox传递参数
	local HeroSid = nil
	
	
	self.myAuction = myAuction
	
	UI_famousHeroSelf = self
	
	timeTable = {}
	self.timeTable = timeTable
	
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "famousHero.json")
	self:addCCNode(wigetRoot)

	ListView_hero = wigetRoot:getChildByName("ListView_hero")
	
	
	--表头设置
	ListView_hero:getChildByName("Panel_head"):getChildByName("Panel_cont"):
		getChildByName("Label_tips"):setString(hp.lang.getStrByID(6022))


	local itemCont = ListView_hero:getChildByName("Panel_item"):getChildByName("Panel_cont")
	--表项
	-- itemCont:getChildByName("Label_heroName"):setString(string.format(hp.lang.getStrByID(6019), "zhadsgfdgdafg"))
	-- itemCont:getChildByName("Label_heroBelong"):setString(string.format(hp.lang.getStrByID(6020), "adasdfsdfasdf"))
	-- itemCont:getChildByName("Label_heroIntro"):setString(string.format(hp.lang.getStrByID(6021), "sadfasdfsadfsadf"))
	itemCont:getChildByName("btn_details"):getChildByName("Label_details"):setString(hp.lang.getStrByID(6015))
	
	--按钮
	local fastGet = itemCont:getChildByName("btn_fastGet")
	fastGet:getChildByName("Label_fastGet"):setString(hp.lang.getStrByID(6016))
	--fastGet:getChildByName("Label_gold"):setString(string.format(hp.lang.getStrByID(6023), 10000))
	
	local auction = itemCont:getChildByName("btn_auction")
	auction:getChildByName("Label_auction"):setString(hp.lang.getStrByID(6017))
	--auction:getChildByName("Label_time"):setString("02:32:56")



	local moreInfo = wigetRoot:getChildByName("Panel_cont"):getChildByName("btn_moreInfo")
	moreInfo:getChildByName("Label_moreInfo"):setString(hp.lang.getStrByID(6005))

	local noHeroTip = wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_tip")
	noHeroTip:setString(hp.lang.getStrByID(6046))
	noHeroTip:setVisible(false)
	
	
	
	--moreInfo
	local function moreInfoMemuItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			--cclog_("moreInfoMemuItemOnTouched")
			require "ui/takeInHeroRoom/moreInfo"
			local moreInfoBox = UI_moreInfoBox.new(bInfo)
			self:addModalUI(moreInfoBox)
			
		end
	end
	
	moreInfo:addTouchEventListener( moreInfoMemuItemOnTouched )

	
	--设置模板
	ListView_hero:setItemModel(ListView_hero:getItem(1))
	ListView_hero:removeItem(1)
	
	
	
	
	require "ui/msgBox/msgBox"
	local msgbox = nil
	local msgTips = hp.lang.getStrByID(6034)
	local msgIs = hp.lang.getStrByID(6035)
	local msgNo = hp.lang.getStrByID(6036)

	
					
	-- 网络请求回调 
	--直接购买回调
	local function onBuyHeroHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--竞价成功
				
				msgbox = UI_msgBox.new(msgTips,hp.lang.getStrByID(6040),msgIs)
				UI_famousHeroSelf:addModalUI(msgbox)
				
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
		oper.sid = HeroSid
		oper.price = price
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onBuyHeroHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end

	
	
	--确认
	local function affirm()

		local heroInfo = hp.gameDataLoader.getInfoBySid("hero", HeroSid )
		
		curPri = heroInfo.highPrice
		
		if myAuction.price > 0 then
			curPri = heroInfo.highPrice - myAuction.price
		end
		
		onBuyHero( curPri )
		--cclog_("use " .. curPri .. " price buy .....................................!!!!!!!")
		
	end


	--竞拍 二次确认
	local function twiceAffirm()
		msgbox = UI_msgBox.new(msgTips,hp.lang.getStrByID(6030),msgIs,msgNo,affirm)
		
		UI_famousHeroSelf:addModalUI(msgbox)
	end



	--直接获取按钮和竞拍按钮 回调函数

	local function btn_fastGet_callback(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			
			local heroInfo = hp.gameDataLoader.getInfoBySid("hero", sender:getTag())
			
			--金币不足
			if player.getResource("gold") < heroInfo.highPrice then
			
				UI_msgBox.showCommonMsg(self, 1)
				
			elseif myAuction.price > 0 then
			--已经竞拍此英雄
			
				msgbox = UI_msgBox.new(msgTips,string.format(hp.lang.getStrByID(6033),heroInfo.highPrice - myAuction.price),
										msgIs,msgNo,twiceAffirm)
				HeroSid = heroInfo.sid
				UI_famousHeroSelf:addModalUI(msgbox)
			else
				--正常购买
				msgbox = UI_msgBox.new(msgTips,string.format(hp.lang.getStrByID(6032),heroInfo.highPrice),msgIs,msgNo,twiceAffirm)
				HeroSid = heroInfo.sid
				UI_famousHeroSelf:addModalUI(msgbox)

			end

			
			
		

		end
	end


	local function btn_auction_callback(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
		
			--传送英雄tag
			if sender:getChildByName("Label_auction"):getString()==hp.lang.getStrByID(6048) then
				require "ui/takeInHeroRoom/famousHeroAddAuctionInputBox"
				local inputbox = UI_famousHeroAddAuctionInputBox.new(sender:getTag(),myAuction.price)

				UI_famousHeroSelf:addModalUI(inputbox)
			else
				require "ui/takeInHeroRoom/famousHeroAuctionInputBox"
				local inputbox = UI_famousHeroAuctionInputBox.new(sender:getTag())

				UI_famousHeroSelf:addModalUI(inputbox)
			end
		end
	end


	
	
		
	--设置某些项
	local function setFamousHeroList(dataList)
		
		local item = nil
		
		
		local hasTime = nil
		for i, v in ipairs(dataList) do
			
			if v[1] == myAuction.sid then
				item = ListView_hero:getItem(i)
				hasTime = v[2]
				break
			end
		end
		
		
		do
			if item == nil then
				return 
			end
		end
		
		
		
		
		
		for i, v in ipairs(dataList) do
			local item = ListView_hero:getItem(i)
			
			--所有拍卖按钮变灰 不可点击
			local btn_auction = item:getChildByName("Panel_cont"):getChildByName("btn_auction")
			
			--除此之外的 拍卖按钮 立即获取按钮变灰
			if v[1] ~= myAuction.sid then
				local btn_fastGet = item:getChildByName("Panel_cont"):getChildByName("btn_fastGet")
			
				btn_fastGet:loadTexture(config.dirUI.common .. "button_gray.png")
				btn_fastGet:setEnabled(false)

				--所有拍卖按钮变灰 不可点击
				btn_auction:loadTexture(config.dirUI.common .. "button_gray.png")
				btn_auction:setEnabled(false)
			else
				if myAuction.price > 0 then
					--竞拍过的按钮变为加价
					btn_auction:getChildByName("Label_auction"):setString(hp.lang.getStrByID(6048))
				end
			end
			
		end
		
		
		
		local cont = item:getChildByName("Panel_cont")
		
		--在拍卖中 显示头像框下的信息
		local img_farmBlackBg = cont:getChildByName("img_farmBlackBg")
		
		img_farmBlackBg:getChildByName("Label_inGoldAuction"):
			setString(string.format(hp.lang.getStrByID(6024),myAuction.price))
			
		--显示出来
		img_farmBlackBg:setEnabled(true)
		img_farmBlackBg:setVisible(true)

	end

	-- 查看详细信息
	local function detailCallBack(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local heroInfo = hp.gameDataLoader.getInfoBySid("hero", sender:getTag())
			if heroInfo ~= nil then
				require "ui/takeInHeroRoom/famousHeroInfo"
				local ui  = UI_famousHeroInfo.new(heroInfo)
				self:addUI(ui)
			end
		end
		
	end


	--添加项
	local function addFamousHeroList(listData)
		--从后面删除 只留一个表头
		for i=#self.timeTable, 1, -1  do
			ListView_hero:removeItem(i)
		end
		self.timeTable = {}
		
		if (#listData<=0) then 
			noHeroTip:setVisible(true)
			return
		end

		--遍历 
		for i, v in ipairs(listData) do
			
			local timeNode = {}
			timeNode.time = v[2]
			timeNode.sid = v[1]
			
			local heroInfo = hp.gameDataLoader.getInfoBySid("hero", v[1])
		
			ListView_hero:pushBackDefaultItem()
			item = ListView_hero:getItem(i)
			
			
			
			local cont = item:getChildByName("Panel_cont")
			
			--先将头像下方的UI隐藏
			local img_farmBlackBg = cont:getChildByName("img_farmBlackBg")
			img_farmBlackBg:setEnabled(false)
			img_farmBlackBg:setVisible(false)
			
			--framNode上面也有时间
			timeNode.framNode = img_farmBlackBg:getChildByName("Label_inTimeAuction")
			
			
			--设置每一项的数据
			cont:getChildByName("img_heroIcon"):setTag(heroInfo.sid)
			cont:getChildByName("img_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. heroInfo.sid..".png")
			cont:getChildByName("Label_heroName"):setString(string.format(hp.lang.getStrByID(6019), heroInfo.name))
			cont:getChildByName("Label_heroBelong"):setString(string.format(hp.lang.getStrByID(6020), hp.lang.getStrByID(heroInfo.land)))
			cont:getChildByName("Label_heroIntro"):setString(string.format(hp.lang.getStrByID(6021),heroInfo.desc))
			local btn_auction = cont:getChildByName("btn_auction")
			timeNode.btnNode = btn_auction:getChildByName("Label_time")
			timeNode.btnNode:setString(hp.datetime.strTime(timeNode.time))
			table.insert(self.timeTable, timeNode)

			
			
			--直接获得英雄 按钮
			local fastGet = cont:getChildByName("btn_fastGet")
			fastGet:setTag(heroInfo.sid)
			fastGet:addTouchEventListener(btn_fastGet_callback)
			--直接获得英雄消耗钻石
			fastGet:getChildByName("Label_gold"):setString(heroInfo.highPrice)

			
			btn_auction:setTag(heroInfo.sid)
			btn_auction:addTouchEventListener(btn_auction_callback)
			
			
			--相当于点击了详情
			cont:getChildByName("btn_details"):setTag(heroInfo.sid)
			cont:getChildByName("btn_details"):addTouchEventListener( detailCallBack)
			cont:getChildByName("img_heroIcon"):addTouchEventListener( detailCallBack)
		end
		
		

	end


	
	
		
	--拉取名将列表信息
	local function GetHeroDataList(callBackFunc)
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 15
		oper.type = 4
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(callBackFunc)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		--cclog_("send...................................................ok")
	end

	self.GetHeroDataList = GetHeroDataList
	
		
	--  初始化名将英雄 信息列表
	local function initHeroListHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				
				addFamousHeroList(data.hero)
				
				--已经有在竞拍的英雄
				
				if data.price~=nil then
					myAuction.price = data.price
					myAuction.sid = data.sid
					
					--设置唯一的被竞拍的项
					setFamousHeroList(data.hero)
				else
					myAuction.price = 0
				end
				
			end
		end
	end

	self.initHeroListHttpResponse = initHeroListHttpResponse;
	
	--界面启动
	--初始化英雄列表
	--发送网络获取消息
	GetHeroDataList(initHeroListHttpResponse)

	
	
	
	
	
	
	
	
	
	local function timeCallback(dt)
		if #self.timeTable>0 then
			for i,v in ipairs(self.timeTable) do	
				if (v~=nil and v.btnNode ~= nil and v.time>=0) then
					v.time = v.time - dt
					--cclog_ (v.time .. "sssssssssssssssssssssstime")
					v.btnNode:setString( hp.datetime.strTime(v.time) )
				end
			end
		end
	end
	self.timeCallback = timeCallback
	
	self:registMsg(hp.MSG.FAMOUS_HERO_LIST_UPDATE)
	

end




function UI_famousHero:heartbeat(dt)
	self.timeCallback(dt)
end




-- onMsg
--重新拉取名将列表信息
function UI_famousHero:onMsg(msg_, parm_)
	if msg_ == hp.MSG.FAMOUS_HERO_LIST_UPDATE then
		
		--重新初始化 列表
		self.GetHeroDataList(self.initHeroListHttpResponse)
		
	end
end

function UI_famousHero:onRemove()
	self.super.onRemove(self)
end
	

	


	