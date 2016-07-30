--
-- ui/mail/beScoutedMail.lua
-- 被侦察
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_beScoutedMail = class("UI_beScoutedMail", UI)


--init
function UI_beScoutedMail:init(mailInfo,mailType_,mailIndex)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "beScoutedMail.json")
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	
	--[["","y2"],[]]

	local annex = mailInfo.annex
	local Info = {}

	if annex[1] ~= nil and #annex[1] > 0 then
		if annex[1][1]  ~= "" then
			Info.name = hp.lang.getStrByID(21) .. annex[1][1] .. hp.lang.getStrByID(22) .. annex[1][2]
		else 
			Info.name = annex[1][2]
		end
	else
		Info.name = hp.lang.getStrByID(7956)
	end

	if annex[2] ~= nil and #annex[2] > 0 then
		
		Info.pos = "K:" .. hp.gameDataLoader.getInfoBySid("serverList", annex[2][1]).name .. " X:" .. annex[2][2] .. " Y:" .. annex[2][3]
		
	else
		Info.pos = hp.lang.getStrByID(7956)
	end


	--head
	Panel_item:getChildByName("Panel_cont"):getChildByName("Label_succeed"):setString(hp.lang.getStrByID(7951))
	
	local panelLabelCont = Panel_item:getChildByName("Panel_cont_0")
	
	panelLabelCont:getChildByName("Label_info1"):setString(hp.lang.getStrByID(7952))

	panelLabelCont:getChildByName("Label_info2"):setString(hp.lang.getStrByID(7953))
	panelLabelCont:getChildByName("Label_info2_1"):setString(Info.name)

	panelLabelCont:getChildByName("Label_info3"):setString(hp.lang.getStrByID(7954))
	panelLabelCont:getChildByName("Label_info3_1"):setString(Info.pos)

	local width = panelLabelCont:getChildByName("Label_info3_1"):getSize().width
	local image_line = panelLabelCont:getChildByName("Image_line")
	local size = image_line:getSize()
	size.width = width
	image_line:setSize(size)

	--goto
	local function goto(sender, eventType)
		if game.curScene.mapLevel == 2 then
			self:closeAll()
    		game.curScene:gotoPosition(cc.p(annex[2][2], annex[2][3]), "", annex[2][1])
    	else
    		self:close()
			require("scene/kingdomMap")
			local map = kingdomMap.new()
			map:enter()
			map:gotoPosition(cc.p(annex[2][2], annex[2][3]), "", annex[2][1])
		end
	end
	panelLabelCont:getChildByName("Label_info3_1"):addTouchEventListener(goto)

	--del
	Panel_item:getChildByName("Panel_delCont"):getChildByName("Label_delete"):setString( hp.lang.getStrByID(1221))
		
	local delBtn = Panel_item:getChildByName("Panel_delCont"):getChildByName("ImageView_delete")
	local function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	
	delBtn:addTouchEventListener(delBtnOnTouched)
	
	
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
