--
-- ui/takeInHeroRoom/noremalHero.lua
-- 普通英雄
--===================================
require "ui/UI"

UI_noremalHero = class("UI_noremalHero", UI)


--init
function UI_noremalHero:init(bInfo)
	-- data

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "noremalHero.json")
	self:addCCNode(wigetRoot)

	local cont = wigetRoot:getChildByName("Panel_cont")
	local btn_getHero = cont:getChildByName("btn_getHero")
	local btn_moreInfo = cont:getChildByName("btn_moreInfo")
	      
	local Label_info = cont:getChildByName("Label_info")
	local Label_tips = cont:getChildByName("Label_tips")
	
	
	--多语言匹配
	btn_moreInfo:getChildByName("Label_moreInfo"):setString(hp.lang.getStrByID(6005))
	btn_getHero:getChildByName("Label_getHero"):setString(hp.lang.getStrByID(6004))
	Label_tips:setString(hp.lang.getStrByID(6008))
	
	--招募新英雄按钮闪光
	require "ui/common/effect.lua"
	local light = nil
	self.light = light
	self.light = inLight(btn_getHero:getVirtualRenderer(),1)
	btn_getHero:addChild(self.light)
	
	--若当前已有英雄 按钮变灰
	local function checkHeroIsValid()
		if not player.hero.isValid() then
			Label_info:setString(hp.lang.getStrByID(6006))
			btn_getHero:loadTexture(config.dirUI.common .. "button_green.png")
			btn_getHero:setTouchEnabled(true)
			self.light:setVisible(true)
		else
			Label_info:setString(hp.lang.getStrByID(6007))
			btn_getHero:loadTexture(config.dirUI.common .. "button_gray.png")
			btn_getHero:setTouchEnabled(false)
			self.light:setVisible(false)
		end
	end
	
	self.checkHeroIsValid = checkHeroIsValid
	self.checkHeroIsValid()
	
	-- 获取英雄 网络请求回调
	local function onGetHeroHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				require "ui/msgBox/msgBox"
				self:addModalUI(UI_msgBox.new(hp.lang.getStrByID(6034),hp.lang.getStrByID(6040),
					hp.lang.getStrByID(1209)))
			end
		end
	end
	
	-- 获取英雄 网络请求
	local function onGetHero()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 15
		oper.type = 1
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onGetHeroHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end
	
	
	--回调函数
	
	local function btn_getHero_callback(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			onGetHero()
			
		end
	end
	
	
	local function btn_moreInfo_callback(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/takeInHeroRoom/moreInfo"
			local moreInfoBox = UI_moreInfoBox.new(bInfo)
			self:addModalUI(moreInfoBox)
		end
	end
	
	
	btn_getHero:addTouchEventListener(btn_getHero_callback)
	btn_moreInfo:addTouchEventListener(btn_moreInfo_callback)
	
	
	self:registMsg(hp.MSG.HERO_INFO_CHANGE)

end



function UI_noremalHero:onMsg(msg_, param_)
	if msg_==hp.MSG.HERO_INFO_CHANGE then
		self.checkHeroIsValid()
	end
end
