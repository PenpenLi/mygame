--
-- ui/mail/attackBossMail.lua
-- 主建筑更多信息
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_attackBossMail = class("UI_attackBossMail", UI)


--init
function UI_attackBossMail:init(Info,mailType_,mailIndex)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "attackBossMail.json")
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	

	local bossName = hp.gameDataLoader.getInfoBySid("boss", Info.bossSid ).name


	--head
	Panel_item:getChildByName("Panel_cont"):getChildByName("Label_succeed"):setString(string.format( hp.lang.getStrByID(7901),bossName))
	
	Panel_item:getChildByName("Panel_cont_0"):getChildByName("Label_info"):setString(Info.content)
	
	
	local img = hp.gameDataLoader.getInfoBySid("boss", Info.bossSid).headPic

	local Panel_cont_1 = Panel_item:getChildByName("Panel_cont_1")
	Panel_cont_1:getChildByName("Label_bossName"):setString(bossName)
	Panel_cont_1:getChildByName("Image_boss"):loadTexture(config.dirUI.bossHead .. img)
	
	
	local Panel_cont_2 = Panel_item:getChildByName("Panel_cont_2")
	Panel_cont_2:getChildByName("Label_health"):setString( hp.lang.getStrByID(7902))
	Panel_cont_2:getChildByName("Label_attPer"):setString(Info.attHealth .. "%")
	
	
	
	local Panel_framBar = Panel_item:getChildByName("Panel_framBar")
	Panel_framBar:getChildByName("Label_HealthProcess"):setString(Info.remainHealth .. "%")
	
	local ProgressBar_health = Panel_framBar:getChildByName("ProgressBar_health")
	

	ProgressBar_health:setPercent( Info.remainHealth )
	
	local Panel_AddframBg = Panel_item:getChildByName("Panel_AddframBg")
	local Panel_Addcont = Panel_item:getChildByName("Panel_Addcont")

	if #Info.resArr > 0 then

		local resTp = 0
		local resNum = 0
		for i,v in ipairs(Info.resArr) do
			if v>0 then
				resTp = i
				resNum = v
				break
			end
		end

		local img = hp.gameDataLoader.getInfoBySid("resInfo", resTp).image
		local resName = hp.gameDataLoader.getInfoBySid("resInfo", resTp).name
		Panel_Addcont:getChildByName("Image_res"):loadTexture(config.dirUI.common .. img)
		Panel_Addcont:getChildByName("Label_res"):setString(resName)
		Panel_Addcont:getChildByName("Label_resNum"):setString("+" .. resNum)

	else
		Panel_AddframBg:setVisible(false)
		Panel_Addcont:setVisible(false)
	end



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
