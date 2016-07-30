--
-- ui/mail/writeMail.lua
-- 邮件主界面
--===================================
require "ui/fullScreenFrame"


UI_writeMail = class("UI_writeMail", UI)


--init
function UI_writeMail:init(addr_, title_, cont_, tag_)
	-- data
	-- ===============================


	--
	local function onHttpResponse(status, response, tag)
	end

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:setTitle(hp.lang.getStrByID(9008))
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mailWrite.json")
	local contPanel = widgetRoot:getChildByName("Panel_cont")
	local btnSend = contPanel:getChildByName("ImageView_send")
	contPanel:getChildByName("ImageView_send"):getChildByName("Label_send"):setString(hp.lang.getStrByID(9009))
	local btnAttachment = contPanel:getChildByName("ImageView_attachment")
	local labelAddr = contPanel:getChildByName("Label_addr")
	local editctrlAddr = hp.uiHelper.labelBind2EditBox(labelAddr)
	editctrlAddr.setMaxLength(8)
	local labelTitle = contPanel:getChildByName("Label_title")
	local editctrlTitle = hp.uiHelper.labelBind2EditBox(labelTitle)
	editctrlTitle.setMaxLength(40)
	local labelCont = contPanel:getChildByName("Label_cont")
	local editctrlCont = hp.uiHelper.labelBind2EditBox(labelCont)
	editctrlCont.setMaxLength(400)

	if addr_==nil then
		editctrlAddr.setString("")
	else
		editctrlAddr.setString(addr_)
	end
	if title_==nil then
		editctrlTitle.setString("")
	else
		editctrlTitle.setString(title_)
	end
	if cont_==nil then
		editctrlCont.setString("")
	else
		editctrlCont.setString(cont_)
	end
	-- 联盟群发
	if tag_==1 then
		labelAddr:setTouchEnabled(false)
		editctrlAddr.setString(hp.lang.getStrByID(1815))
	end

	local function onHttpResponse(status, response, tag_)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				Scene.showMsg({2001})
				self:close()
				return
			end

			require "ui/msgBox/msgBox"
			local ui = UI_msgBox.new(hp.lang.getStrByID(9010), hp.lang.getStrByID(9011), hp.lang.getStrByID(1209))
			self:addModalUI(ui)
		end
	end
	local function btnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnSend then
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 10
				if tag_ ~= nil and tag_ == 1 then
					oper.type = 10
				else
					oper.type = 1
				end
				oper.name = editctrlAddr.getString()
				oper.title = editctrlTitle.getString()
				oper.text = editctrlCont.getString()
				cmdData.operation[1] = oper

				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			end
		end
	end
	btnSend:addTouchEventListener(btnOnTouched)
	btnAttachment:addTouchEventListener(btnOnTouched)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)
end

