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
	
	--英雄详情
	local function detailCallBack(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/takeInHeroRoom/famousHeroListDetail"
			local ui  = UI_famousHeroListDetail.new(sender:getTag())			
			self:addChildUI(ui)
			wigetRoot:setVisible(false)
		end
	end

	--添加监听
	for i=0,3 do
		local cont=wigetRoot:getChildByName("Panel_item_"..i):getChildByName("Panel_cont")
		cont:addTouchEventListener(detailCallBack)
	end
	
	--获取全服名将数量信息
	local function getHeroNumHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				local nums=data.num
				for k,v in pairs(nums) do
					local cont=wigetRoot:getChildByName("Panel_item_"..(k-1)):getChildByName("Panel_cont")
					cont:getChildByName("Label_num"):setString(string.format(hp.lang.getStrByID(6043),v))
				end
			end
		end
	end
	
	
	--获取名将数量信息 网络请求
	local function getHeroNum()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 15
		oper.type = 8
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(getHeroNumHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end
	getHeroNum()

end
