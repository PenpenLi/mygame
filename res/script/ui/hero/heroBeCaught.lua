--
-- ui/hero/heroBeCaught.lua
-- 武将被抓信息
--===================================
require "ui/fullScreenFrame"


UI_heroBeCaught = class("UI_heroBeCaught", UI)


--init
function UI_heroBeCaught:init(hero_)
	-- data
	-- ===============================
	local lv = player.getLv()
	local exp = player.getExp()
	local lvConstInfo = nil
	local pointCount = 0

	local heroInfo = hero_.getBaseInfo()
	local constInfo = hero_.getConstInfo()
	local caughtInfo = heroInfo.caughtInfo
	
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:setTitle("")
	uiFrame:hideTopShade()

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "heroBeCaught.json")
	local heroPanel = widgetRoot:getChildByName("ListView_hero"):getItem(0):getChildByName("Panel_cont")
	local infoPanel = widgetRoot:getChildByName("Panel_info")

	--header
	local headerFrame = widgetRoot:getChildByName("Panel_head")

	local heroIcon = heroPanel:getChildByName("ImageView_hero")
	heroIcon:loadTexture(config.dirUI.hero .. heroInfo.sid..".png")

	headerFrame:getChildByName("Label_name"):setString(heroInfo.name)
	headerFrame:getChildByName("Label_promote"):setString(hp.lang.getStrByID(2501))

	infoPanel:getChildByName("Label_des"):setString(hp.lang.getStrByID(2517))
	
	
	-- 功能按钮
	local btnsNode = widgetRoot:getChildByName("Panel_bottom"):getChildByName("ImageView_middle")
	local btnMail = btnsNode:getChildByName("ImageView_mail")
	local btnHelp = btnsNode:getChildByName("ImageView_help")

	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnMail then
				require "ui/mail/writeMail"
				local ui  = UI_writeMail.new(caughtInfo[2])
				self:addUI(ui)
			elseif sender==btnHelp then
				require("scene/kingdomMap")
				local map = kingdomMap.new()
				map:enter()
				map:gotoPosition(cc.p(caughtInfo[6],caughtInfo[7]), nil, caughtInfo[5])
			end
		end
	end
	btnMail:addTouchEventListener(onBtnTouched)
	btnMail:getChildByName("Label_name"):setString(hp.lang.getStrByID(2514))
	btnHelp:addTouchEventListener(onBtnTouched)
	btnHelp:getChildByName("Label_name"):setString(hp.lang.getStrByID(2515))

	-- 关押者信息
	local name=caughtInfo[2]
	if string.len(caughtInfo[3])>0 then
		name=hp.lang.getStrByID(21) .. caughtInfo[3] .. hp.lang.getStrByID(22) .. caughtInfo[2]
	end
	infoPanel:getChildByName("Label_name_0"):setString(hp.lang.getStrByID(2512))
	infoPanel:getChildByName("Label_name"):setString(name)
	-- 关押位置
	infoPanel:getChildByName("Label_loc_0"):setString(hp.lang.getStrByID(2513))
	infoPanel:getChildByName("Label_loc"):setString(string.format(hp.lang.getStrByID(2521),caughtInfo[5],caughtInfo[6],caughtInfo[7]))


	local function reflushExp()
		exp = player.getExp()
		headerFrame:getChildByName("Label_exp"):setString(string.format("%d/%d", exp, lvConstInfo.exp))
		headerFrame:getChildByName("LoadingBar_LoadingBar"):setPercent(exp*100/lvConstInfo.exp)
	end
	local function reflushLv()
		lv = player.getLv()
		headerFrame:getChildByName("Label_level"):setString(lv)
		for i,v in ipairs(game.data.heroLv) do
			if v.level==lv then
				lvConstInfo = v
				break
			end
		end
		reflushExp()
	end
	-- 越狱倒计时
	local function reflushCDTime()
		if heroInfo.state == 1 then
			infoPanel:getChildByName("Label_time"):setString(string.format(hp.lang.getStrByID(2516),hp.datetime.strTime(caughtInfo[4])))
			local value=(345600-caughtInfo[4])*100/345600
			infoPanel:getChildByName("ProgressBar_time"):setPercent(value)
		else
			self:closeAll()
		end
	end

	self.reflushLv = reflushLv
	self.reflushExp = reflushExp
	self.reflushCDTime = reflushCDTime
	reflushLv()
	reflushCDTime()

	self:registMsg(hp.MSG.LV_CHANGED)
	self:registMsg(hp.MSG.EXP_CHANGED)
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)

end

function UI_heroBeCaught:onMsg(msg_, param_)
	if msg_==hp.MSG.LV_CHANGED then
		self.reflushLv()
	elseif msg_==hp.MSG.EXP_CHANGED then
		self.reflushExp()
	end
end

function UI_heroBeCaught:heartbeat( dt )
	self.reflushCDTime()
end