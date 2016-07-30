--
-- ui/vip/vip.lua
-- vip界面
--===================================
require "ui/fullScreenFrame"


UI_vip = class("UI_vip", UI)


--init
function UI_vip:init()
	-- data
	-- ===============================
	local vipStatus = player.vipStatus

	local function getVIPInfoByLv( lv )
		for i, vipInfo in ipairs(game.data.vip) do
			if lv==vipInfo.level then
				return vipInfo
			end
		end

		return nil
	end

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle("VIP")
	uiFrame:setBgImg(config.dirUI.common .. "frame_bg1.png")
	uiFrame:setTopShadePosY(888)
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "vip.json")


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	--
	-- ===============================
	local listView = wigetRoot:getChildByName("ListView_vip")
	listView:setClippingType(1)
	local listInfoNode = listView:getChildByName("Panel_info")
	-- head
	local headFrame = listInfoNode:getChildByName("Panel_headFrame")
	local headCont = listInfoNode:getChildByName("Panel_headCont")
	headCont:getChildByName("Label_desc"):setString(hp.lang.getStrByID(3701))
	local lvPos = {}
	for i,v in ipairs(game.data.vip) do
		if v.level>0 then
			local pNode = headCont:getChildByTag(v.level)
			local pTmp = 1
			lvPos[v.level], pTmp = pNode:getPosition()
			pNode:getChildByName("Label_num"):setString("(" .. v.points .. ")")
		end
	end
	local function setProgress()
		local curPointNode = headCont:getChildByName("Image_p")
		local processNode = headFrame:getChildByName("ProgressBar_vip")

		local curLv = vipStatus.getLv()
		local curPoints = vipStatus.getPoints()
		local curVIPInfo = getVIPInfoByLv(curLv)
		local nextVIPInfo = getVIPInfoByLv(curLv+1)
		local curPos = lvPos[curLv]
		if nextVIPInfo~=nil then
			curPos = curPos+(lvPos[curLv+1]-lvPos[curLv])*(curPoints-curVIPInfo.points)/(nextVIPInfo.points-curVIPInfo.points)
		end

		local px,py = curPointNode:getPosition()
		curPointNode:setPosition(curPos, py)
		processNode:setPercent((curPos-lvPos[1])*100/(lvPos[10]-lvPos[1]))
		curPointNode:getChildByName("Label_num"):setString("(" .. curPoints .. ")")
	end
	setProgress()

	--vip view
	local viewNode = listInfoNode:getChildByName("Panel_vipView")
	-- 获取积分、激活VIP
	local getBtn = viewNode:getChildByName("Image_getPoints")
	local activeBtn = viewNode:getChildByName("Image_vipOn")
	
	--激活VIP按钮闪光
	local light = inLight(activeBtn:getVirtualRenderer(),1)
	activeBtn:addChild(light)
	
	local function checkVipActive()
		if player.vipStatus.isActive() then
			light:setVisible(false)
		else
			light:setVisible(true)
		end
	end
	self.checkVipActive = checkVipActive
	checkVipActive()
	
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==activeBtn then
				require("ui/item/commonItem")
				local ui = UI_commonItem.new(20000, hp.lang.getStrByID(3703))
				self:addUI(ui)
			elseif sender==getBtn then
				require("ui/item/commonItem")
				local ui = UI_commonItem.new(20050, hp.lang.getStrByID(3715))
				self:addUI(ui)
			end
		end
	end
	getBtn:addTouchEventListener(onBtnTouched)
	getBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(3702))
	activeBtn:addTouchEventListener(onBtnTouched)
	activeBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(3703))
	viewNode:getChildByName("Label_desc"):setString(hp.lang.getStrByID(3704))
	-- VIP图标
	local function onVipIconTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/vip/vipDetails"
			local ui  = UI_vipDetails.new(sender:getTag())
			self:addUI(ui)
		end
	end
	local function setVIPIcon()
		for i=1, 10 do
			local vipImg = viewNode:getChildByTag(i)
			vipImg:addTouchEventListener(onVipIconTouched)

			if vipStatus.getLv()>=i then
				vipImg:getChildByName("Image_lock"):setVisible(false)
			end
		end
	end
	setVIPIcon()
	--属性
	local attrNode = listInfoNode:getChildByName("Panel_attrCont")
	attrNode:getChildByName("Image_vip"):getChildByName("Label_text"):setString(hp.lang.getStrByID(3705))
	attrNode:getChildByName("Label_timeN"):setString(hp.lang.getStrByID(3706))
	attrNode:getChildByName("Label_lvN"):setString(hp.lang.getStrByID(3707))
	attrNode:getChildByName("Label_pointN"):setString(hp.lang.getStrByID(3708))
	attrNode:getChildByName("Label_pointN_r"):setString(hp.lang.getStrByID(3709))
	attrNode:getChildByName("Label_streakN"):setString(hp.lang.getStrByID(3710))
	local timeLabel = attrNode:getChildByName("Label_time")
	local lvLable = attrNode:getChildByName("Label_lv")
	local ptLable = attrNode:getChildByName("Label_point")
	local ptrLable = attrNode:getChildByName("Label_point_r")
	local streakLabel = attrNode:getChildByName("Label_streak")
	function setAttrTime()
		timeLabel:setString(hp.datetime.strTime(vipStatus.getCD()))
	end
	function setAttrPoint()
		local curLv = vipStatus.getLv()
		local curPoints = vipStatus.getPoints()
		lvLable:setString(curLv)
		ptLable:setString(string.format(hp.lang.getStrByID(3711), curPoints))
		ptrLable:setString(string.format(hp.lang.getStrByID(3711), 100+vipStatus.getStreakDay()*10))
	end
	setAttrTime()
	setAttrPoint()
	streakLabel:setString(string.format(hp.lang.getStrByID(3712), vipStatus.getStreakDay()))

	-- 描述
	local descNode = listInfoNode:getChildByName("Panel_desc")
	descNode:getChildByName("Label_desc1"):setString(hp.lang.getStrByID(3713))
	descNode:getChildByName("Label_desc2"):setString(hp.lang.getStrByID(3714))


	self.setProgress = setProgress
	self.setAttrPoint = setAttrPoint
	self.setAttrTime = setAttrTime
	self.setVIPIcon = setVIPIcon

	self:registMsg(hp.MSG.VIP)
end

-- onMsg
function UI_vip:onMsg(msg_, param_)
	if msg_==hp.MSG.VIP then
		if param_==1 or param_==2 then
			self.setProgress()
			self.setAttrPoint()
			self.setVIPIcon()
			self.checkVipActive()
		end
	end
end

-- heartbeat
function UI_vip:heartbeat(dt)
	self.setAttrTime()
end