--
-- ui/anguoss.lua
-- 城内信息
--===================================
require "ui/UI"

UI_famousHeroList = class("UI_famousHeroList", UI)


--init
function UI_famousHeroList:init()
	-- data

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "famousHeroList.json")
	self:addCCNode(wigetRoot)

	local ListView_hero = wigetRoot:getChildByName("ListView_hero")
	local demo = ListView_hero:getChildByName("Panel_item")
	demo:retain()
	self.demo = demo
	local headCont = ListView_hero:getChildByName("Panel_head"):getChildByName("Panel_cont")

	headCont:getChildByName("Label_tips"):setString(hp.lang.getStrByID(6009))
	headCont:getChildByName("Label_head"):setString(hp.lang.getStrByID(6010))
	headCont:getChildByName("Label_hero"):setString(hp.lang.getStrByID(6011))
	headCont:getChildByName("Label_master"):setString(hp.lang.getStrByID(6013))
	headCont:getChildByName("Label_belong"):setString(hp.lang.getStrByID(6014))


	ListView_hero:removeLastItem()
	
	--英雄详情
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
	
	--显示名将列表
	local function showHeroList(data)
		
		--插入列表
		for i,v in ipairs(data) do
			local sid=v[1]
			local pid=v[2]
			local name=v[3]
			local isCatched=false
			if v[4] ~=nil and string.len(v[4]) > 0 then
				name="["..v[4].."]"..name
			end

			if v[5] ~=nil and string.len(v[5]) > 0 then
				isCatched=true
				name=v[5]
				if v[6] ~=nil and string.len(v[6]) > 0 then
					name="["..v[6].."]"..name
				end
			end


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
				showHeroList(data.hero)
			end
		end
	end
	
	
	--获取名将列表信息 网络请求
	local function getHeroList()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 15
		oper.type = 7
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(getHeroListHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end
	

	
	
	


	getHeroList()

end


function UI_famousHeroList:onRemove()
	self.demo:release()

	self.super.onRemove(self)
end