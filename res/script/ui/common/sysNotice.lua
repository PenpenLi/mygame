--
-- ui/common/sysNotice.lua
-- 消息框
--===================================
require "ui/UI"

UI_sysNotice = class("UI_sysNotice", UI)

--init
function UI_sysNotice:init(data)
	-- data
	local textList = {}
	for i, textData in ipairs(data) do
		local textInfo = {}
		textInfo.fontSize = textData.fontSize or 20
		local fColor = textData.color or {255, 255, 255}
		textInfo.color = cc.c3b(fColor[1], fColor[2], fColor[3])
		textInfo.topMargin = textData.topMargin or 0
		if textData.align=="center" then
			textInfo.align = 1
		elseif textData.align=="right" then
			textInfo.align = 2
		else
			textInfo.align = 0
		end
		textInfo.text = textData.text or ""

		table.insert(textList, textInfo)
	end

	--ui
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "sysNotice.json")

	local textListView = wigetRoot:getChildByName("ListView_noticeText")
	local textItem = textListView:getItem(0):clone()
	textListView:removeAllItems()

	for i, textInfo in ipairs(textList) do
		local item = textItem:clone()
		local textLabel = item:getChildByName("Panel_cont"):getChildByName("Label_text")
		textLabel:setFontSize(textInfo.fontSize)
		textLabel:setColor(textInfo.color)
		textLabel:setTextHorizontalAlignment(textInfo.align)
		textLabel:setString(textInfo.text)

		-- 重新设置坐标和大小
		local lineNum = textLabel:getVirtualRenderer():getStringNumLines()
		local textHeight = (textInfo.fontSize+3) * lineNum

		local textPX, textPY = textLabel:getPosition()
		textLabel:setPosition(textPX, textHeight)
		local textAreaSize = textLabel:getTextAreaSize()
		textAreaSize.height = textHeight+160
		textLabel:setSize(textAreaSize)
		textLabel:setTextAreaSize(textAreaSize)

		local itemSz = item:getSize()
		itemSz.height = textHeight+textInfo.topMargin
		item:setSize(itemSz)

		textListView:pushBackCustomItem(item)
	end

	local closeBtn = wigetRoot:getChildByName("Panel_cont"):getChildByName("Image_ok")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end
	closeBtn:addTouchEventListener(onBtnTouched)


	-- addCCNode
	self:addCCNode(wigetRoot)
end


local noticeURL = "http://1251205422.cdn.myqcloud.com/1251205422/yitongsanguo/notice/notice.txt"
function UI_sysNotice.show()
	local xhr = cc.XMLHttpRequest:new()
	local function onHttpResponse()
		local status = xhr.status
		local response = xhr.response

		if status~=200 then
			return
		end

		cclog("UI_sysNotice === Http Status Code: %d", status)
		cclog("UI_sysNotice === Http response: %s", response)

		--解析json数据
		local dataResponse = json.decode(response, 1)
		xhr:unregisterScriptHandler()

		local ui = UI_sysNotice.new(dataResponse)
		game.curScene:addModalUI(ui, 999)
	end
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr.timeout = -1
	xhr:registerScriptHandler(onHttpResponse)

	xhr:open("GET", noticeURL)
	xhr:send()

	cclog("UI_sysNotice.url === %s", noticeURL)
end
