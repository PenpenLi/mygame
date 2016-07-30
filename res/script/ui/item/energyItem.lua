--
-- ui/item/energyItem.lua
-- 体力道具使用页面
--===================================

require "ui/fullScreenFrame"

UI_energyItem = class("UI_energyItem", UI)

local wigetRoot
local base_item

-- init
function UI_energyItem:init()
	-- ui
	-- ===============================
	wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "useEnergyItem.json")

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(10806), "title1")
	uiFrame:setTopShadePosY(760)

	self:registMsg(hp.MSG.COPY_NOTIFY)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	base_item = wigetRoot:getChildByName("ListView_items"):getItem(0):clone()
	base_item:retain()

	self:initTouchEvent()
	self:initUI()
end

function UI_energyItem:initTouchEvent()
	-- 使用道具
	local function useItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function onBuyItemHttpResponse(status, response, tag)
				if status==200 then
					local data = hp.httpParse(response)
					if data.result~=nil and data.result==0 then
						player.expendItem(sender:getTag(), 1)
						Scene.showMsg({3000, hp.gameDataLoader.getInfoBySid("item", sender:getTag()).name, 1})
						self:initUI()
					end
				end
			end
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 14
			oper.type = 1
			oper.sid = sender:getTag()
			oper.gold = 0
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 2)
			self:showLoading(cmdSender, sender)
		end
	end
	self.useItemTouched = useItemTouched

	-- 跳转至商城
	local function gotoShop(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/goldShop/goldShop"
			local ui = UI_goldShop.new(1)
			self:addUI(ui)
		end
	end
	self.gotoShop = gotoShop
end

function UI_energyItem:initUI()

	local content_title = wigetRoot:getChildByName("Panel_content")

	content_title:getChildByName("Label_text1"):setString(hp.lang.getStrByID(10801))
	content_title:getChildByName("Label_text2"):setString(hp.lang.getStrByID(10802))

	local energy = player.getEnerge()
	energyText = content_title:getChildByName("Label_text"):setString(energy .. "/100")
	energyProgress = content_title:getChildByName("ProgressBar_energy"):setPercent(energy)

	local itemInfo = {}
	local num = 0
	for i = 21401, 21405 do
		local info = {}
		info.sid = i
		info.num = player.getItemNum(i)
		num = num + info.num
		itemInfo[#itemInfo + 1] = info
	end

	local list = wigetRoot:getChildByName("ListView_items")
	list:removeAllItems()

	if num == 0 then
		list:setVisible(false)
		local noItem = wigetRoot:getChildByName("Panel_noItem")
		noItem:setVisible(true)
		noItem:getChildByName("Label_text"):setString(hp.lang.getStrByID(10808))
		noItem:getChildByName("Label_text2"):setString(hp.lang.getStrByID(10809))
		noItem:getChildByName("Image_btn"):addTouchEventListener(self.gotoShop)
	else
		-- insert list
		for i,v in ipairs(itemInfo) do
			if v.num > 0 then
				local info = hp.gameDataLoader.getInfoBySid("item", v.sid)

				local temp_item = base_item:clone()
				local temp_content = temp_item:getChildByName("Panel_content")
				temp_content:getChildByName("Image_btn"):setTag(v.sid)

				temp_content:getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.item, v.sid))
				temp_content:getChildByName("Image_btn"):addTouchEventListener(self.useItemTouched)
				temp_content:getChildByName("Label_count"):setString(string.format(hp.lang.getStrByID(10804), v.num))
				temp_content:getChildByName("Label_name"):setString(info.name)
				temp_content:getChildByName("Label_desc"):setString(info.desc)
				temp_content:getChildByName("Label_btnText"):setString(hp.lang.getStrByID(10805))

				list:pushBackCustomItem(temp_item)
			end
		end
	end
end

function UI_energyItem:onMsg(msg_, param_)
	if msg_ == hp.MSG.COPY_NOTIFY then
		self:initUI()
	end
end

function UI_energyItem:onRemove()
	base_item:release()

	self.super.onRemove(self)
end