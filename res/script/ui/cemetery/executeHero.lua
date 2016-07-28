--
-- ui/cemetery/executeHero.lua
-- 处决的英雄
--===================================
require "ui/UI"

UI_executeHero = class("UI_executeHero", UI)


--init
function UI_executeHero:init()
	
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "executeHero.json")
	self:addCCNode(wigetRoot)

	ListView_hero = wigetRoot:getChildByName("ListView_hero")
	
	
	--hp.lang.getStrByID(5147) - 无

	--get hero info
	local heroList = {}
	heroList[1] = {}
	heroList[1].time = 560
	heroList[1].sid = 2009
	heroList[1].Lv = 10
	heroList[1].manager = "fghfg"
	heroList[1].executeTime = "2014/7/5 22:32"
	heroList[1].union = "235"

	heroList[2] = {}
	heroList[2].time = 943
	heroList[2].sid = 3005
	heroList[2].Lv = 18
	heroList[2].manager = "asdd"
	heroList[2].executeTime = "2014/7/5 22:32"
	heroList[2].union = "235"

	heroList[3] = {}
	heroList[3].time = 567
	heroList[3].sid = 3002
	heroList[3].Lv = 48
	heroList[3].manager = "ewq"
	heroList[3].executeTime = "2014/7/5 22:32"
	heroList[3].union = "235"

	heroList[4] = {}
	heroList[4].time = 943
	heroList[4].sid = 3005
	heroList[4].Lv = 18
	heroList[4].manager = "asdd"
	heroList[4].executeTime = "2014/7/5 22:32"
	heroList[4].union = "235"

	heroList[5] = {}
	heroList[5].time = 567
	heroList[5].sid = 3002
	heroList[5].Lv = 48
	heroList[5].manager = "ewq"
	heroList[5].executeTime = "2014/7/5 22:32"
	heroList[5].union = "235"


	--设置模板
	ListView_hero:setItemModel(ListView_hero:getItem(0))
	ListView_hero:removeItem(0)

	
	if #heroList == 0 then
		wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_Null"):setString(hp.lang.getStrByID(7937))
	end

	for i,v in ipairs(heroList) do
		
		ListView_hero:pushBackDefaultItem()
		local item = ListView_hero:getItem(i-1)
		
		local itemCont = item:getChildByName("Panel_cont")
		
		itemCont:getChildByName("Label_heroName"):setString( hp.lang.getStrByID(7619) .. hp.gameDataLoader.getInfoBySid("hero",v.sid).name)
		itemCont:getChildByName("Label_heroLv"):setString(hp.lang.getStrByID(7620) .. v.Lv)
		itemCont:getChildByName("Label_manager"):setString(string.format( hp.lang.getStrByID(1903) , v.manager))
		itemCont:getChildByName("Label_union"):setString(string.format( hp.lang.getStrByID(3626) , v.union))
		itemCont:getChildByName("Label_executeTime"):setString(hp.lang.getStrByID(7935) .. v.executeTime)
		itemCont:getChildByName("img_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. v.sid .. ".png")
		
	end
	
	
end

