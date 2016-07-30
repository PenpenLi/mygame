--
-- ui/buildingHeader.lua
-- 架构 - 全屏ui
--===================================
require "ui/UI"


UI_buildingHeader = class("UI_buildingHeader", UI)


--init
function UI_buildingHeader:init(building_)
	self.layer:setLocalZOrder(999)
	-- data
	-- ===============================
	local b = building_.build
	local bInfo = building_.bInfo
	local imgPath = building_.imgPath

	if bInfo.showtype==1 then
		imgPath = config.dirUI.building .. "fudi_icon.png"
	elseif bInfo.showtype==15 then
		imgPath = config.dirUI.building .. "wall_icon.png"
	end
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "buildingHeader.json")
	local cont = wigetRoot:getChildByName("Panel_cont")
	local btnRemove = cont:getChildByName("ImageView_remove")
	local btnUpgrade = cont:getChildByName("ImageView_upgrade")
	-- 建筑图片
	if bInfo.showtype==1 or bInfo.showtype==15 then
		cont:getChildByName("ImageView_build"):setScale(0.8)
	end
	cont:getChildByName("ImageView_build"):loadTexture(imgPath)
	-- 等级进度
	local progressBg = cont:getChildByName("ImageView_progressBg")
	progressBg:getChildByName("LoadingBar_progress"):setPercent((b.lv*100)/bInfo.maxLv)
	progressBg:getChildByName("Label_progress"):setString(string.format("%d/%d", b.lv, bInfo.maxLv))

	-- 按钮处理
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnUpgrade then
				if b.lv>=bInfo.maxLv then
					-- 等级已最高
					return
				end
				require "ui/build_upgrade"
				local ui  = UI_buildUpgrade.new({type=0, building=building_})
				self:addUI(ui)
				self.parent:moveOut(2, 0.2, 2)
				ui:moveIn(2, 0.2)
				player.guide.stepEx({3003})
			elseif sender==btnRemove then
				require "ui/destory"
				local ui  = UI_destory.new(building_)
				self:addModalUI(ui)
			end
		end
	end

	-- 能否拆除
	if bInfo.isPerish==0 then
		btnRemove:loadTexture(config.dirUI.common .. "button_gray.png")
	else
		btnRemove:addTouchEventListener(onBtnTouched)
	end

	-- 能否升级
	if bInfo.maxLv<=b.lv then
		btnUpgrade:loadTexture(config.dirUI.common .. "button_gray.png")
	else
		btnUpgrade:addTouchEventListener(onBtnTouched)
	end

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end

