--
-- ui/famousHeroListDetail.lua
-- 名将榜信息
--===================================
require "ui/UI"

UI_famousHeroListDetail = class("UI_famousHeroListDetail", UI)


--init
function UI_famousHeroListDetail:init(land_)
	-- data
	-- 国家
	local land=0
	local index=0
	local isMax=false
	local lineNum = 4
	local heros = clone(game.data.hero)

	-- function
	local getHeroList

	if land_~=nil then
		land=land_
	end
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "famousHeroListDetail.json")
	self:addCCNode(wigetRoot)

	local ListView_hero = wigetRoot:getChildByName("ListView_hero")
	local lineDemo = ListView_hero:getChildByName("Panel_item"):clone()
	local demo = wigetRoot:getChildByName("Panel_hero")
	local demoSize = demo:getSize()
	self.lineDemo = lineDemo
	lineDemo:retain()

	--demo:retain()
	--self.demo = demo
	local headCont = wigetRoot:getChildByName("Panel_head"):getChildByName("Panel_cont")

	--headCont:getChildByName("Label_tips"):setString(hp.lang.getStrByID(6009))
	--headCont:getChildByName("Label_hero"):setString(hp.lang.getStrByID(6011))
	headCont:getChildByName("Label_belong"):setString(hp.lang.getStrByID(land)..hp.lang.getStrByID(6011))
	--headCont:getChildByName("Label_master"):setString(hp.lang.getStrByID(6013))

	-- listView监听
	-- local countScroll = 0
	-- local function onScrollEvent(t1, t2, t3)
	-- 	if t2==ccui.ScrollviewEventType.scrollToBottom then
	-- 		if countScroll % 3 == 0 then
	-- 			getHeroList()
	-- 		end
	-- 		countScroll = countScroll + 1
	-- 	end
	-- end
	-- ListView_hero:addEventListenerScrollView(onScrollEvent)

	ListView_hero:removeAllItems()
	
	--英雄详情
	local function detailCallBack(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local heroInfo = hp.gameDataLoader.getInfoBySid("hero", sender:getTag())
			if heroInfo ~= nil then
				local hmn=sender:getChildByName("Label_heroMasterName"):getString()
				if hmn==nil or hmn=="" then
					require "ui/takeInHeroRoom/famousHeroInfo"
					local ui  = UI_famousHeroInfo.new(heroInfo)
					self:addUI(ui)
				else
					local param=string.format(hp.lang.getStrByID(6044),hmn)
					param=param.."     "..sender:getChildByName("Label_position"):getString()
					require "ui/takeInHeroRoom/famousHeroInfo"
					local ui  = UI_famousHeroInfo.new(heroInfo,param)
					self:addUI(ui)
				end
			end
		end
		
	end

	--显示名将图鉴
	local function showHeroList(data)
		local temp ={}
		local x = 1 
		for i,v in ipairs(heros) do
			if v.land==land and v.sid~=1001 and v.sid~=1002 then
				temp[x]=v
				x=x+1
			end
		end

		local lineNode = nil
		local k = 1
		local demoNode = nil

		--已出世名将
		for i,v in ipairs(data) do
			local sid=v[1]
			local pid=v[2]
			local name=v[3]
			
			local isCatched=false
			if v[4] ~=nil and string.len(v[4]) > 0 then
				name=hp.lang.getStrByID(21)..v[4]..hp.lang.getStrByID(22)..name
			end

			-- if v[5] ~=nil and string.len(v[5]) > 0 then
			-- 	isCatched=true
			-- 	name=v[5]
			-- 	if v[6] ~=nil and string.len(v[6]) > 0 then
			-- 		name=hp.lang.getStrByID(21)..v[6]..hp.lang.getStrByID(22)..name
			-- 	end
			-- end
			local pos=string.format(hp.lang.getStrByID(6045),player.serverMgr.getServerBySid(v[5]).name)

			local linePos = k%lineNum
			local px = 0
			if linePos==0 then
				px = (lineNum-1)*demoSize.width
			else
				px = (linePos-1)*demoSize.width
			end
			if linePos==1 then
				lineNode = lineDemo:clone()
				ListView_hero:pushBackCustomItem(lineNode)
			end
			demoNode = demo:clone()
			demoNode:setPosition(px, 0)
			--设置武将信息
			local heroInfo = hp.gameDataLoader.getInfoBySid("hero", sid)
			demoNode:setTag(sid)
			demoNode:getChildByName("img_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. sid..".png")
			demoNode:getChildByName("Label_heroName"):setColor(cc.c3b(247, 204, 9))
			demoNode:getChildByName("Label_heroName"):setString(heroInfo.name)
			demoNode:getChildByName("Label_heroMasterName"):setString(name)
			demoNode:getChildByName("Label_position"):setString(pos)
			demoNode:addTouchEventListener( detailCallBack )
			lineNode:addChild(demoNode)
			k = k+1
		end

		--未出世名将
		local size=#temp
		local mark= 0
		for i=1, size do
			mark=0
			if data~=nil then
				for j,v in ipairs(data) do
					if v[1]==temp[i].sid then
						mark=1
						break
					end
				end
			end
			if mark==0 then
				local linePos = k%lineNum
				local px = 0
				if linePos==0 then
					px = (lineNum-1)*demoSize.width
				else
					px = (linePos-1)*demoSize.width
				end
				if linePos==1 then
					lineNode = lineDemo:clone()
					ListView_hero:pushBackCustomItem(lineNode)
				end
				demoNode = demo:clone()
				demoNode:setPosition(px, 0)
				--设置武将信息
				demoNode:setTag(temp[i].sid)
				demoNode:getChildByName("img_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. temp[i].sid..".png")
				demoNode:getChildByName("img_heroIcon"):setColor(cc.c3b(51, 46, 46))
				demoNode:getChildByName("Label_heroName"):setString(temp[i].name)
				demoNode:addTouchEventListener( detailCallBack )
				lineNode:addChild(demoNode)
				k = k+1
			end
		end	
	end


	
	--显示名将列表
	local function showHeroList1(data)
		
		--插入列表
		for i,v in ipairs(data) do
			local sid=v[1]
			local pid=v[2]
			local name=v[3]
			
			local isCatched=false
			if v[4] ~=nil and string.len(v[4]) > 0 then
				name=hp.lang.getStrByID(21)..v[4]..hp.lang.getStrByID(22)..name
			end

			if v[5] ~=nil and string.len(v[5]) > 0 then
				isCatched=true
				name=v[5]
				if v[6] ~=nil and string.len(v[6]) > 0 then
					name=hp.lang.getStrByID(21)..v[6]..hp.lang.getStrByID(22)..name
				end
			end
			local pos=string.format(hp.lang.getStrByID(6045),v[7])

			local item = demo:clone()
			ListView_hero:pushBackCustomItem(item)

			local heroInfo = hp.gameDataLoader.getInfoBySid("hero", v[1])
			
			local cont = item:getChildByName("Panel_cont")
			
			cont:getChildByName("img_heroIcon")
			cont:getChildByName("Label_heroName"):setString(heroInfo.name)
			if isCatched then
				--显示红色
				cont:getChildByName("Label_heroMasterName"):setColor(cc.c3b(160, 0, 0))
			end		
			cont:getChildByName("Label_heroMasterName"):setString(name)		
			cont:getChildByName("Label_heroBelong"):setString(hp.lang.getStrByID(heroInfo.land))
			cont:getChildByName("Label_position"):setString(pos)			
			cont:getChildByName("img_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. heroInfo.sid..".png")
			cont:setTag(heroInfo.sid)
			cont:addTouchEventListener( detailCallBack )
		end
		
	end
	
	
	--获取全服名将列表信息
	local function getHeroListHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				-- local len=#data.hero
				-- if len<10 then
				-- 	isMax=true
				-- else
				-- 	index=index+len
				-- end
				
				-- if len>0 then
				-- 	showHeroList(data.hero)
				-- end
				showHeroList(data.hero)
			end
		end
	end
	
	
	--获取名将列表信息 网络请求
	function getHeroList()
		if isMax then
		else
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 15
			oper.type = 7
			oper.loc = land
			oper.index = index
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(getHeroListHttpResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end	
	getHeroList()
	--showHeros()
	--showHeroList()
end


function UI_famousHeroListDetail:onRemove()
	--self.demo:release()
	self.lineDemo:release()
	self.super.onRemove(self)
end