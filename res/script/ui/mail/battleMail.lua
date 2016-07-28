--
-- ui/mail/battleMail.lua
-- 主建筑更多信息
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_battleMail = class("UI_battleMail", UI)


--init
function UI_battleMail:init(Info,mailType_,mailIndex)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "battleMail.json")
	
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	
	--head
	local Panel_cont = Panel_item:getChildByName("Panel_cont")
	
	local strHead = ""
	
	if Info.meisSucceed == 1 then
		strHead = "+"
		Panel_cont:getChildByName("Label_succeed"):setString(hp.lang.getStrByID(7601))
	else
		strHead = "-"
		Panel_cont:getChildByName("Label_succeed"):setString(hp.lang.getStrByID(7602))
	end
	
	
	if Info.meisSucceed == 1 then
		Panel_cont:getChildByName("Label_GetRes"):setString( hp.lang.getStrByID(7604) )
	else
		Panel_cont:getChildByName("Label_GetRes"):setString( hp.lang.getStrByID(7605) )
	end
	
	Panel_cont:getChildByName("Label_ResCount"):setString( hp.lang.getStrByID(7606) )
	
	Panel_cont:getChildByName("Label_stone"):setString( hp.lang.getStrByID(6302) )
	Panel_cont:getChildByName("Label_wood"):setString( hp.lang.getStrByID(6303) )
	Panel_cont:getChildByName("Label_ore"):setString( hp.lang.getStrByID(6304))
	Panel_cont:getChildByName("Label_food"):setString( hp.lang.getStrByID(6305))
	Panel_cont:getChildByName("Label_silver"):setString( hp.lang.getStrByID(7603))
	
	Panel_cont:getChildByName("Label_stoneNum"):setString(strHead .. Info.stone)
	Panel_cont:getChildByName("Label_woodNum"):setString(strHead .. Info.wood)
	Panel_cont:getChildByName("Label_oreNum"):setString(strHead .. Info.ore)
	Panel_cont:getChildByName("Label_foodNum"):setString(strHead .. Info.food)
	Panel_cont:getChildByName("Label_silverNum"):setString(strHead .. Info.silver)
	
	
	
	--def
	local Panel_contL_1 = Panel_item:getChildByName("Panel_contL_1")
	
	Panel_contL_1:getChildByName("Label_nameTittle"):setString( Info.deferUnionName)
	Panel_contL_1:getChildByName("Label_City"):setString( Info.deferCityName)
	Panel_contL_1:getChildByName("Label_Pos"):
		setString( "K:" .. Info.deferPosK .. " x:" .. Info.deferPosX .. " y:" .. Info.deferPosY  )
	Panel_contL_1:getChildByName("Label_power"):setString( hp.lang.getStrByID(7607) .. "-" .. Info.deferLostPower)
	
	--Panel_contL_1:getChildByName("img_heroIcon"):loadTexture(Info.deferUnionName)
	
	
	--att
	local Panel_contR_1 = Panel_item:getChildByName("Panel_contR_1")
	
	Panel_contR_1:getChildByName("Label_nameTittle"):setString( Info.atterUnionName)
	Panel_contR_1:getChildByName("Label_City"):setString( Info.atterCityName)
	Panel_contR_1:getChildByName("Label_Pos"):
		setString( "K:" .. Info.atterPosK .. " x:" .. Info.atterPosX .. " y:" .. Info.atterPosY  )
	Panel_contR_1:getChildByName("Label_power"):setString( hp.lang.getStrByID(7607) .. "-" .. Info.atterLostPower)
	
	--Panel_contR_1:getChildByName("img_heroIcon"):loadTexture(Info.atterUnionName)
	
	
	
	
	--def
	local Panel_contL_1_0 = Panel_item:getChildByName("Panel_contL_1_0")
	
	Panel_contL_1_0:getChildByName("Label_Tittle"):setString( hp.lang.getStrByID(7608))
	Panel_contL_1_0:getChildByName("Label_num"):setString( Info.deferLostAll)
	
	
	--att
	local Panel_contR_1_0 = Panel_item:getChildByName("Panel_contR_1_0")
	
	Panel_contR_1_0:getChildByName("Label_Tittle"):setString( hp.lang.getStrByID(7609))
	Panel_contR_1_0:getChildByName("Label_num"):setString( Info.atterLostAll)
	
	
	
	
	
	
	
	
	local Panel_contL_1_1 = Panel_item:getChildByName("Panel_contL_1_1")
	
	if Info.meisAtt == 1 then
		Panel_contL_1_1:getChildByName("Label_Tittle"):setString( hp.lang.getStrByID(7611))
	else
		Panel_contL_1_1:getChildByName("Label_Tittle"):setString( hp.lang.getStrByID(7610))
	end
	
	--def
	Panel_contL_1_1:getChildByName("Label_sold"):setString( hp.lang.getStrByID(7612))
	Panel_contL_1_1:getChildByName("Label_injure"):setString( hp.lang.getStrByID(7613))
	Panel_contL_1_1:getChildByName("Label_die"):setString( hp.lang.getStrByID(7614))
	Panel_contL_1_1:getChildByName("Label_surv"):setString( hp.lang.getStrByID(7615))
	
	Panel_contL_1_1:getChildByName("Label_soldNum"):setString(  Info.deferSoldCount)
	Panel_contL_1_1:getChildByName("Label_injureNum"):setString( Info.deferInjure )
	Panel_contL_1_1:getChildByName("Label_dieNum"):setString( Info.deferdie)
	Panel_contL_1_1:getChildByName("Label_survNum"):setString( Info.deferSurv)
	
	
	Panel_contL_1_1:getChildByName("Label_trapTittle"):setString( hp.lang.getStrByID(7616))
	
	Panel_contL_1_1:getChildByName("Label_trapCount"):setString( hp.lang.getStrByID(7617))
	Panel_contL_1_1:getChildByName("Label_trapDestroy"):setString( hp.lang.getStrByID(7618))
	Panel_contL_1_1:getChildByName("Label_trapSurv"):setString( hp.lang.getStrByID(7615))
	
	Panel_contL_1_1:getChildByName("Label_trapCountNum"):setString( Info.trapCount)
	Panel_contL_1_1:getChildByName("Label_trapDestroyNum"):setString( Info.trapDestroy)
	Panel_contL_1_1:getChildByName("Label_trapSurvNum"):setString( Info.trapSurv)
	
	
	if Info.deferHeroName ~= "" then
		
		Panel_contL_1_1:getChildByName("Label_heroName"):setString( hp.lang.getStrByID(7619) .. Info.deferHeroName)
		Panel_contL_1_1:getChildByName("Label_heroLevel"):setString( hp.lang.getStrByID(7620) .. Info.deferHeroLv)
		Panel_contL_1_1:getChildByName("Label_heroXP"):setString( hp.lang.getStrByID(7621))
		
		
		Panel_contL_1_1:getChildByName("Label_heroXPNum"):setString( "+" .. Info.deferHeroXP)
		
	else
	
		Panel_contL_1_1:getChildByName("Label_heroName"):setString( hp.lang.getStrByID(7619) .. hp.lang.getStrByID(5147))
		Panel_contL_1_1:getChildByName("Label_heroLevel"):setString( hp.lang.getStrByID(7620) .. hp.lang.getStrByID(5147))
		Panel_contL_1_1:getChildByName("Label_heroXP"):setString( hp.lang.getStrByID(7621))
		
		
		Panel_contL_1_1:getChildByName("Label_heroXPNum"):setString(hp.lang.getStrByID(5147))
		
	
	end
	
	
	--att
	local Panel_contR_1_1 = Panel_item:getChildByName("Panel_contR_1_1")
	
	if Info.meisAtt == 1 then
		Panel_contR_1_1:getChildByName("Label_Tittle"):setString( hp.lang.getStrByID(7610))
	else
		Panel_contR_1_1:getChildByName("Label_Tittle"):setString( hp.lang.getStrByID(7611))
	end
	
	Panel_contR_1_1:getChildByName("Label_sold"):setString( hp.lang.getStrByID(7612))
	Panel_contR_1_1:getChildByName("Label_injure"):setString( hp.lang.getStrByID(7613))
	Panel_contR_1_1:getChildByName("Label_die"):setString( hp.lang.getStrByID(7614))
	Panel_contR_1_1:getChildByName("Label_surv"):setString( hp.lang.getStrByID(7615))
	
	Panel_contR_1_1:getChildByName("Label_soldNum"):setString( Info.atterSoldCount)
	Panel_contR_1_1:getChildByName("Label_injureNum"):setString(Info.atterInjure )
	Panel_contR_1_1:getChildByName("Label_dieNum"):setString( Info.atterdie)
	Panel_contR_1_1:getChildByName("Label_survNum"):setString( Info.atterSurv)
	
	--print(Info.atterHeroName .. "*********************")
	
	if Info.atterHeroName == "" then
		Panel_contR_1_1:getChildByName("Label_heroName"):setString( hp.lang.getStrByID(7619) .. hp.lang.getStrByID(5147))
		Panel_contR_1_1:getChildByName("Label_heroLevel"):setString( hp.lang.getStrByID(7620) .. hp.lang.getStrByID(5147))
		Panel_contR_1_1:getChildByName("Label_heroXP"):setString( hp.lang.getStrByID(7621))
		
		Panel_contR_1_1:getChildByName("Label_heroXPNum"):setString( hp.lang.getStrByID(5147) )
	else
		Panel_contR_1_1:getChildByName("Label_heroName"):setString( hp.lang.getStrByID(7619) .. Info.atterHeroName)
		Panel_contR_1_1:getChildByName("Label_heroLevel"):setString( hp.lang.getStrByID(7620) .. Info.atterHeroLv)
		Panel_contR_1_1:getChildByName("Label_heroXP"):setString( hp.lang.getStrByID(7621))
		
		
		Panel_contR_1_1:getChildByName("Label_heroXPNum"):setString( "+" .. Info.atterHeroXP )
		
	end
	
	
	Panel_item:getChildByName("Panel_detailBtn"):getChildByName("Label_detail"):setString( hp.lang.getStrByID(7622))
		
	local detailBtn = Panel_item:getChildByName("Panel_detailBtn"):getChildByName("Image_detailBtn")
	function detailBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mail/battleDetail.lua"
			local ui_ = UI_battleDetail.new(Info.details)
			self:addModalUI(ui_)
		end
	end
	
	detailBtn:addTouchEventListener(detailBtnOnTouched)
	
	
	
	--del
	Panel_item:getChildByName("Panel_delCont"):getChildByName("Label_delete"):setString( hp.lang.getStrByID(1221))
		
	local delBtn = Panel_item:getChildByName("Panel_delCont"):getChildByName("ImageView_delete")
	function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			hp.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	
	delBtn:addTouchEventListener(delBtnOnTouched)
	
	
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
