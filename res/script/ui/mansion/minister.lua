--
-- ui/mansion/person/minster.lua
-- 府邸内部 大臣
--================================================

Minister = class("Minister")

-- 构造函数
function Minister:ctor(container, node, sid)
	self.container = container
	self.node = node
	self.sid = sid
	self.isFlash = false
	self:init()
end

-- 初始化
function Minister:init()
	-- 外发光
	if sid ~= "zg" and sid ~= "zhg" then
		require "ui/common/effect.lua"
		self.light = outLight1(self.sid)
		self.node:addChild(self.light)
		-- 是否可见
		if self.sid == "cx" then
			self.isFlash = player.mansionMgr.primeMinisterMgr.isLight()
		elseif self.sid == "jj" then
			self.isFlash = player.mansionMgr.generaMgr.isLight()
		elseif self.sid == "lg" then
			self.isFlash = player.mansionMgr.protocolOfficerMgr.isLight()
		elseif self.sid == "sz" then
			self.isFlash = player.postmanAndEnvoyMgr.getEnvoyIsLightOnInit()
			self.light:setPosition(-4, -3)
		elseif self.sid == "ch" then
			if player.postmanAndEnvoyMgr.isFirst() then
				self.isFlash = player.postmanAndEnvoyMgr.getPostmanIsLightOnInit()
			else
				self.isFlash = player.postmanAndEnvoyMgr.getPostmanIsLightOnMsg()
			end		
		end
		self:setLight(self.isFlash)
	end
	-- 人物
	self.character = hp.sequenceAniHelper.createAnimSprite("fudi", self.sid, 6, 0.2)
	self.character:setAnchorPoint(cc.p(0, 0))
	self.node:addChild(self.character)
	
end

function Minister:setLight(isFlash)
	self.isFlash = isFlash
	self.light:setVisible(self.isFlash)
end

function Minister:isLight()
	return self.isFlash
end

-- 点击后打开菜单
function Minister:openMenu()
	if self.sid == "cx" then
	-- 丞相
		require "ui/mansion/primeminister"
		local ui_ = UI_PrimeMinister.new()
		self.container:addUI(ui_)
	elseif self.sid == "zg" then
	-- 总管
		require "ui/mansion/manager"
		local ui_ = UI_manager.new()
		self.container:addUI(ui_)
	elseif self.sid == "lg" then
	-- 礼官
		require "ui/mansion/giftPerson"
		local ui_ = UI_giftPerson.new()
		self.container:addUI(ui_)
	elseif self.sid == "jj" then
	-- 将军
		local state=player.hero.getBaseInfo().state
		-- 正常
		if state == 0 then
			require "ui/hero/hero"
			local ui  = UI_hero.new(player.hero)
			self.container:addUI(ui)
		-- 被关押
		elseif state == 1 then
			require "ui/hero/heroBeCaught"
			local ui  = UI_heroBeCaught.new(player.hero)
			self.container:addUI(ui)
		-- 已死亡（可复活）
		elseif state == 2 then
			--进入墓地
			local building=player.buildingMgr.getBuildingObjBySid(1021)
			building:onClicked()
		-- 已死亡（不可复活）
		elseif state == 3 then
			-- 前往招贤馆
			local function gotoHeroRoom()
				local building=player.buildingMgr.getBuildingObjBySid(1022)
				building:onClicked()
			end	
			require("ui/msgBox/msgBox")
			local msgBox = UI_msgBox.new(hp.lang.getStrByID(2518), 
				hp.lang.getStrByID(2519),hp.lang.getStrByID(2520),
				nil,gotoHeroRoom)
			self.container:addModalUI(msgBox)
		end
	elseif self.sid == "ch" then
	-- 斥候
		-- 斥候和使者统一管理在 postmanAndEnvoyMgr 中
		player.postmanAndEnvoyMgr.setPostmanIsClick(true)
		player.postmanAndEnvoyMgr.setCurMailNum(player.mailCenter.getAllUnreadMailNum())
		require("ui/mail/mail")
		local ui = UI_mail.new()
		self.container:addUI(ui)
		self:setLight(false)
		player.postmanAndEnvoyMgr.setPostmanIsLight(false)
	elseif self.sid == "sz" then
	-- 使者
		--local Build = player.buildingMgr.getBuildingObjBySid(1013) Build:onClicked()
		local function joinUnion()
			require "ui/union/invite/unionJoin.lua"
			local ui_ = UI_unionJoin.new()
			self.container:addUI(ui_)
		end	
		-- 如果没有加入联盟提示加入联盟，否则进入联盟里面的工会战界面，与使馆存在与否无关
		if player.getAlliance():getUnionID() == 0 then
			require "ui/msgBox/msgBox"
			local msgTips = hp.lang.getStrByID(6034)
			local msgIs = hp.lang.getStrByID(6035)
			local msgNo = hp.lang.getStrByID(6036)
			local msgContent = hp.lang.getStrByID(8179)
			local msgbox = UI_msgBox.new(msgTips,msgContent,msgIs,msgNo,joinUnion)
			self.container:addModalUI(msgbox)
		else
			player.postmanAndEnvoyMgr.setEnvoyIsClick(true)
			player.postmanAndEnvoyMgr.setCurUnionWarNum( self:getUnionWarNum() )
			
			require("ui/union/war/allianceWar.lua")
			local ui = UI_allianceWar.new(1)
			self.container:addUI(ui)
			self:setLight(false)
			player.postmanAndEnvoyMgr.setEnvoyIsLight(false)
		end
		
	else

	end
end

-- 获取联盟战争的数量 联盟战争 + 联盟防守
function Minister:getUnionWarNum()
	warnum = player.getAlliance():getUnionHomePageInfo().unionWar
	if warnum ~= nil then
		return warnum
	else
		return 0
	end
end