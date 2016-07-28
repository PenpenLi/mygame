--
-- ui/cemetery/sacrificeHero.lua
-- 牺牲的英雄
--===================================
require "ui/UI"

UI_sacrificeHero = class("UI_sacrificeHero", UI)


--init
function UI_sacrificeHero:init(bInfo)
	
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "sacrificeHero.json")
	self:addCCNode(wigetRoot)

	ListView_hero = wigetRoot:getChildByName("ListView_hero")
	
	
	--表头设置
	ListView_hero:getChildByName("Panel_head"):getChildByName("Panel_cont"):
		getChildByName("Label_tips"):setString(bInfo.desc)



	local btnResurgence = wigetRoot:getChildByName("Panel_cont"):getChildByName("btn_resurgence")
	btnResurgence:getChildByName("Label_resurgence"):setString(hp.lang.getStrByID(7931))

	local hasResurgenceNum = player.getItemNum(20601)

	
	
	local ResurgenceCont = wigetRoot:getChildByName("Panel_cont_0")
	ResurgenceCont:getChildByName("Label_medic"):setString(hp.lang.getStrByID(7932))
	ResurgenceCont:getChildByName("Label_medicSum"):setString("1")

	local LabelhasResurgenceNum = ResurgenceCont:getChildByName("Label_medicHasNum")
	

	LabelhasResurgenceNum:setString(hasResurgenceNum)

	if hasResurgenceNum == 0 then
		LabelhasResurgenceNum:setColor(cc.c3b(255,0,0))
	end


	local selectedIndex = 1


	--get hero info
	local heroList = {}
	heroList[1] = {}
	heroList[1].time = 560
	heroList[1].sid = 2009
	heroList[1].Lv = 10

	heroList[2] = {}
	heroList[2].time = 943
	heroList[2].sid = 3005
	heroList[2].Lv = 18

	heroList[3] = {}
	heroList[3].time = 567
	heroList[3].sid = 3002
	heroList[3].Lv = 48


	local itemCont = ListView_hero:getChildByName("Panel_item"):getChildByName("Panel_cont")
	

	--设置模板
	ListView_hero:setItemModel(ListView_hero:getItem(1))
	ListView_hero:removeItem(1)
	
	
	if #heroList == 0 then
		local ResurgenceCont = wigetRoot:getChildByName("Panel_cont_0"):getChildByName("Label_Null"):setString(hp.lang.getStrByID(7936))
	end

	local function selectItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			local item = ListView_hero:getItem(selectedIndex)
			item:getChildByName("Panel_fram"):getChildByName("Image_framBg"):setVisible(false)

			selectedIndex = sender:getTag()
			item = ListView_hero:getItem(selectedIndex)
			item:getChildByName("Panel_fram"):getChildByName("Image_framBg"):setVisible(true)

		end
	end



	for i,v in ipairs(heroList) do
		
		ListView_hero:pushBackDefaultItem()
		local item = ListView_hero:getItem(i)
		item:setTag(i)
		local itemCont = item:getChildByName("Panel_cont")
		
		itemCont:getChildByName("Label_heroName"):setString( hp.lang.getStrByID(7619) .. hp.gameDataLoader.getInfoBySid("hero",v.sid).name)
		itemCont:getChildByName("Label_heroLv"):setString(hp.lang.getStrByID(7620) .. v.Lv)
		itemCont:getChildByName("Label_heroIntro"):setString(hp.gameDataLoader.getInfoBySid("hero",v.sid).desc)
		itemCont:getChildByName("Label_time"):setString(hp.datetime.strTime(v.time))
		itemCont:getChildByName("img_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. v.sid .. ".png")
		if i == selectedIndex then
			item:getChildByName("Panel_fram"):getChildByName("Image_framBg"):setVisible(true)
		end

		item:addTouchEventListener( selectItemOnTouched )
	end
	
	

	require "ui/msgBox/msgBox"
	local msgbox = nil
	local msgTips = hp.lang.getStrByID(6034)
	local msgIs = hp.lang.getStrByID(6035)
	local msgNo = hp.lang.getStrByID(6036)




	function ResurgenceHero(  )
		print("has ResurgenceHero!!!!!!!!!!!!!!!!!!!!!!!")
	end

	--竞拍 二次确认
	local function twiceAffirm()
		local tipsStr = string.format( hp.lang.getStrByID(7934),hp.gameDataLoader.getInfoBySid("hero",heroList[selectedIndex].sid).name) 
		msgbox = UI_msgBox.new(msgTips,tipsStr,msgIs,msgNo,ResurgenceHero)
		self:addModalUI(msgbox)
	end

	--确认
	local function affirm()
		local tipsStr = string.format( hp.lang.getStrByID(7933),hp.gameDataLoader.getInfoBySid("hero",heroList[selectedIndex].sid).name) 
		msgbox = UI_msgBox.new(msgTips,tipsStr,msgIs,msgNo,twiceAffirm)
		self:addModalUI(msgbox)
	end

	--btnResurgence
	local function btnResurgenceMemuItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			if hasResurgenceNum > 0 then
				affirm()
			else

			end
		end
	end
	
	btnResurgence:addTouchEventListener( btnResurgenceMemuItemOnTouched )



	
	local function timeCallback(dt)

		for i,v in ipairs(heroList) do

			local item = ListView_hero:getItem(i)
			local itemCont = item:getChildByName("Panel_cont")

			v.time = v.time - dt
			itemCont:getChildByName("Label_time"):setString(hp.datetime.strTime(v.time))

		end
	
	end
	self.timeCallback = timeCallback
	

end



function UI_sacrificeHero:heartbeat(dt)
	self.timeCallback(dt)
end



	


	