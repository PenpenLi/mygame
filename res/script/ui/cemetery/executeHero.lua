--
-- ui/cemetery/executeHero.lua
-- 处决的英雄
--===================================

require "ui/UI"

UI_executeHero = class("UI_executeHero", UI)


--init
function UI_executeHero:init(heroList_)
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "executeHero.json")
	self:addCCNode(wigetRoot)

	local ListView_hero = wigetRoot:getChildByName("ListView_hero")

	-- 	[LUA-cclog_] Http response: {"rst":{"kill":[[3001,"曹操","hw2","",2,1409898401],[
	-- 3001,"曹操","hw2","",2,1409898942],[3001,"曹操","hw2","",2,1409899655]],"result"
	-- :0},"heart":{}}

	-- get hero info
	local heroList = {}
	for i,v in ipairs(heroList_) do
		local hero = {}
		hero.sid = v[1]
		hero.name = v[2]
		hero.manager = v[3]
		hero.union = v[4]
		hero.Lv = v[5]
		hero.executeTime = v[6]
		heroList[table.getn(heroList) + 1] = hero
	end

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
		-- 武将名
		itemCont:getChildByName("Label_name"):setString(hp.lang.getStrByID(7619))
		itemCont:getChildByName("Label_heroName"):setString(v.name)
		-- 等级
		itemCont:getChildByName("Label_lv"):setString(hp.lang.getStrByID(7804))
		itemCont:getChildByName("Label_heroLv"):setString(v.Lv)
		-- 主公
		itemCont:getChildByName("Label_mgr"):setString(hp.lang.getStrByID(5099))
		if v.union ~= "" and #v.union > 0 then
			-- 有联盟
			itemCont:getChildByName("Label_manager"):setString(string.format(hp.lang.getStrByID(8010), v.union) .. v.manager)
		else
			-- 没联盟
			itemCont:getChildByName("Label_manager"):setString(v.manager)
		end
		-- 处决时间
		itemCont:getChildByName("Label_executeTime"):setString(hp.lang.getStrByID(7935) .. os.date("%Y-%m-%d %H:%M:%S", v.executeTime))
		-- 图片
		itemCont:getChildByName("img_heroIcon"):loadTexture(config.dirUI.heroHeadpic .. v.sid .. ".png")
	end
end

