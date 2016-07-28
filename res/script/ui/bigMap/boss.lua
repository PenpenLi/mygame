--
-- ui/bigMap/boss.lua
-- boss点击弹出界面 
--===================================
require "ui/frame/popFrame"

UI_boss = class("UI_boss", UI)

--init
function UI_boss:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_
	self.bossInfo_ = hp.gameDataLoader.getInfoBySid("boss", tileInfo_.objInfo.sid)

	-- ui
	-- ===============================
	self:initCallBack()

	self:initUI()

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)

	self:updateBoss()
end

function UI_boss:initCallBack()
	local function onAttackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then			
			require "ui/march/march"
			UI_march.openMarchUI(self, self.tileInfo.position, 3)
			self:close()
		end
	end

	local function onInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then			
			require "ui/bigMap/bossInfo"
			ui_ = UI_bossInfo.new(self.bossInfo_)
			self:addModalUI(ui_)
		end
	end

	local function onCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then			
			self:close()
		end
	end

	self.onAttackTouched = onAttackTouched
	self.onInfoTouched = onInfoTouched
	self.onCloseTouched = onCloseTouched
end

function UI_boss:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "boss.json")
	local content = self.wigetRoot:getChildByName("Panel_23471")

	-- 关闭
	content:getChildByName("Image_27"):addTouchEventListener(self.onCloseTouched)

	-- 头像
	self.image = content:getChildByName("Image_26")
	self.image:loadTexture(config.dirUI.bossHead..self.bossInfo_.headPic)

	-- 描述
	content:getChildByName("Label_23452"):setString(self.bossInfo_.name)
	content:getChildByName("Label_23452_Copy0"):setString(hp.lang.getStrByID(1204)..string.format(": K:%s X:%d Y:%d", "2-2", self.tileInfo.position.x, self.tileInfo.position.y))
	self.loadingBar = content:getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640")
	self.loadingText = self.loadingBar:getChildByName("ImageView_1641"):getChildByName("Label_1643")

	-- 进攻
	self.attack = content:getChildByName("ImageView_23464_Copy0")
	self.attack:getChildByName("Label_23466"):setString(hp.lang.getStrByID(1026))
	self.attack:addTouchEventListener(self.onAttackTouched)

	-- 信息
	self.rally = content:getChildByName("ImageView_23464")
	self.rally:getChildByName("Label_23466"):setString(hp.lang.getStrByID(6015))
	self.rally:addTouchEventListener(self.onInfoTouched)

	-- 战力
	content:getChildByName("Image_45"):getChildByName("Label_23452_0"):setString(hp.lang.getStrByID(5119)..self.bossInfo_.power)

	-- 掉落资源
	local uiRes_ = content:getChildByName("Image_46")
	content:getChildByName("Label_23452_0_1"):setString(hp.lang.getStrByID(5118))
	local resInfo_ = {}
	for i, v in ipairs(self.bossInfo_.awards) do
		if v > 0 then
			resInfo_.num = v
			resInfo_.info = hp.gameDataLoader.getInfoBySid("resInfo", i)
		end
	end

	if resInfo_.info ~= nil then
		uiRes_:getChildByName("Image_44"):loadTexture(config.dirUI.common..resInfo_.info.image)
		uiRes_:getChildByName("Label_23452_3"):setString(resInfo_.num)
	end
end

function UI_boss:updateBoss()
	local percent = hp.common.round(self.tileInfo.objInfo.life / self.bossInfo_.maxLife * 100)
	self.loadingBar:setPercent(percent)
	self.loadingText:setString(percent.."%")
end