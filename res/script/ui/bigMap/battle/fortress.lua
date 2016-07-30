--
-- ui/bigMap/battle/fortress.lua
-- 要塞 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_fortress = class("UI_fortress", UI)

--init
function UI_fortress:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================
	self:initUI()
	local name_ = hp.lang.getStrByID(5302)
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5356), tileInfo_.position, hp.lang.getStrByID(5356))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	self:registMsg(hp.MSG.KING_BATTLE)

	-- call back
	local function OnAttackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function onConfirm1Touched()
				require "ui/march/march"
				UI_march.openMarchUI(self, {x=255,y=511,kx=tileInfo_.position.kx,ky=tileInfo_.position.ky}, globalData.MARCH_TYPE.ATTACK_FORTRESS)
				self:close()
			end

			local info_ = player.fortressMgr.getFortressInfo()
			local belong_ = globalData.getArmyBelong(info_.occupierID, info_.occupierUnionID)
			if belong_ == globalData.ARMY_BELONG.ENEMY then
				if player.getNewGuyGuard() ~= 0 then
					require "ui/common/msgBoxRedBack"
					local ui_ = UI_msgBoxRedBack.new(hp.lang.getStrByID(5143), hp.lang.getStrByID(5144), hp.lang.getStrByID(1209),
						hp.lang.getStrByID(2412), onConfirm1Touched)
					self:addModalUI(ui_)
				else
					onConfirm1Touched()
				end
			else
				require "ui/common/successBox"
				local box_ = UI_successBox.new(hp.lang.getStrByID(5451), hp.lang.getStrByID(5452), nil)
				self:addModalUI(box_)
				return
			end
		end
	end

	local function onRallyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			if player.getAlliance():getUnionID() == 0 then				
				require "ui/common/successBox"
				local ui_ = UI_successBox.new(hp.lang.getStrByID(1259), hp.lang.getStrByID(1258))
				self:addModalUI(ui_)
			else
				local info_ = player.fortressMgr.getFortressInfo()
				local belong_ = globalData.getArmyBelong(info_.occupierID, info_.occupierUnionID)
				if belong_ == globalData.ARMY_BELONG.ENEMY then					
					local buildLv = player.buildingMgr.getBuildingMaxLvBySid(1013)
					if buildLv<=0 then
						require "ui/common/noBuildingNotice"
						local ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(1257), 1013, 1, hp.lang.getStrByID(1259))
						self:addModalUI(ui_)
					else
						local function onConfirm1Touched()
							require "ui/bigMap/war/rally"
							local ui_ = UI_rally.new({x=255,y=511,kx=self.tileInfo.position.kx,ky=self.tileInfo.position.ky}, globalData.MARCH_TYPE.RALLY_FORTRESS)
							self:addModalUI(ui_)
						end

						if player.getNewGuyGuard() ~= 0 then
							require "ui/common/msgBoxRedBack"
							local ui_ = UI_msgBoxRedBack.new(hp.lang.getStrByID(5143), hp.lang.getStrByID(5144), hp.lang.getStrByID(1209),
								hp.lang.getStrByID(2412), onConfirm1Touched)
							self:addModalUI(ui_)
						else
							onConfirm1Touched()
						end
					end
				else
					require "ui/common/successBox"
					local box_ = UI_successBox.new(hp.lang.getStrByID(5451), hp.lang.getStrByID(5452), nil)
					self:addModalUI(box_)
					return
				end
			end
		end
	end

	local function onScoutTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local info_ = player.fortressMgr.getFortressInfo()
			local belong_ = globalData.getArmyBelong(info_.occupierID, info_.occupierUnionID)
			if belong_ == globalData.ARMY_BELONG.ENEMY then
				if player.researchMgr.getResearchLv(110) > 0 then
					require "ui/bigMap/war/scout"
					local ui_ = UI_scout.new(tileInfo_.position, hp.lang.getStrByID(5356))
					self:addModalUI(ui_)
				else
					require "ui/common/successBox"
					local box_ = UI_successBox.new(hp.lang.getStrByID(5192), hp.lang.getStrByID(5193), nil)
					self:addModalUI(box_)
				end
			else
				require "ui/common/successBox"
				local box_ = UI_successBox.new(hp.lang.getStrByID(5454), hp.lang.getStrByID(5452), nil)
				self:addModalUI(box_)
				return
			end
		end
	end

	local function onMiracleTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local tick_ = os.clock()
			require "ui/bigMap/battle/UIFortressMgr"
			local ui_ = UI_fortressMgr.new()
			self:addUI(ui_)
			self:close()
			player.clockEnd("onMiracleTouched", tick_, 0.3)
		end
	end

	local function onInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/battle/fortressInfo"
			local box_ = UI_fortressInfo.new()
			self:addModalUI(box_)
		end
	end
	self.attack:addTouchEventListener(OnAttackTouched)
	self.rally:addTouchEventListener(onRallyTouched)
	self.scout:addTouchEventListener(onScoutTouched)
	self.holly:addTouchEventListener(onMiracleTouched)
	self.information:addTouchEventListener(onInfoTouched)

	player.fortressMgr.subscribeData("UI_fortress")

	-- 初始显示
	self:initShow()
end

function UI_fortress:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fortress.json")
	local content = self.wigetRoot:getChildByName("Panel_13785_Copy0")

	-- 头像
	self.image = content:getChildByName("ImageView_13786")
	local kx_ = self.tileInfo.position.kx
	local ky_ = self.tileInfo.position.ky
	local kInfo = player.serverMgr.getServerByPos(kx_, ky_)
	self.image:loadTexture(config.dirUI.fortress..kInfo.img)

	-- 描述
	self.name = content:getChildByName("Label_13787_Copy0")
	self.kingdom = content:getChildByName("Label_13787")
	self.occupier = content:getChildByName("Label_13787_Copy1")
	self.occupyTime = content:getChildByName("Label_13787_Copy2")

	local btnContent = content:getChildByName("Panel_13929")
	-- 信息
	self.information = btnContent:getChildByName("ImageView_13796_Copy0")
	self.information:getChildByName("Label_13798"):setString(hp.lang.getStrByID(5154))

	-- 侦察
	self.scout = btnContent:getChildByName("ImageView_13796_Copy1")
	self.scout:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1313))

	-- 工会战
	self.rally = btnContent:getChildByName("ImageView_13796")
	self.rally:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1314))

	-- 进攻
	self.attack = btnContent:getChildByName("ImageView_13797")
	self.attack:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1026))

	-- 奇迹圣地
	self.desc = btnContent:getChildByName("Label_13844")	
	self.holly = btnContent:getChildByName("ImageView_13793")
	self.holly:getChildByName("Label_13795"):setString(hp.lang.getStrByID(5358))
end

function UI_fortress:setInfo(info_)
	local table_ = {__index=function() return 0 end}
	setmetatable(info_, table_)

	local_battleInfo = {}
	local_battleInfo.startTime = info_[1]
	local_battleInfo.endTime = info_[2]
	local_battleInfo.totalTime = local_battleInfo.endTime - local_battleInfo.startTime

	if local_battleInfo.startTime > player.getServerTime() then
		local_battleInfo.open = globalData.OPEN_STATUS.NOT_OPEN
	elseif local_battleInfo.endTime > player.getServerTime() then
		local_battleInfo.open = globalData.OPEN_STATUS.OPEN
	else
		local_battleInfo.open = globalData.OPEN_STATUS.CLOSE
	end
	
	local unionInfo_ = info_[3]
	setmetatable(unionInfo_, table_)

	local_battleInfo.unionID = unionInfo_[1]
	local_battleInfo.unionName = unionInfo_[2]
	local_battleInfo.pid = unionInfo_[3]
	local_battleInfo.king = unionInfo_[4]
	local_battleInfo.cityName = "成都"
	local_battleInfo.position = {x=unionInfo_[5],y=unionInfo_[6]}
	local_battleInfo.image = unionInfo_[7]
	local_battleInfo.sign = unionInfo_[8]
	local_battleInfo.level = unionInfo_[9]
	local_battleInfo.title = {}
	local_battleInfo.occupier = info_[4]
	local_battleInfo.occupierID = info_[5]
	local_battleInfo.occupierUnionID = info_[8]
	
	local titleList_ = {}
	for i, v in ipairs(info_[6]) do
		titleList_[v[1]] = v
	end
	local_battleInfo.occupierTime = info_[7]

	for i, v in ipairs(hp.gameDataLoader.getTable("kingTitle")) do
		if v.sid ~= 3001 then
			local title_ = {}
			title_.info = v
			title_.sid = v.sid
			local tmp_ = titleList_[v.sid]
			title_.granted = false		
			if tmp_ ~= nil then
				title_.pid = tmp_[2]
				title_.playerName = tmp_[3]
				title_.granted = true
			end
			table.insert(local_battleInfo.title, title_)
		end
	end

	return local_battleInfo
end

function UI_fortress:initShow()
	-- 请求数据
	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				-- 占领了
				local info_ = self:setInfo(data.king)
				self.info = info_
				-- 国王
				if info_.pid ~= 0 then
					self.name:setString(hp.lang.getStrByID(5359).."："..hp.lang.getStrByID(21)..info_.unionName..hp.lang.getStrByID(22)..info_.king)
					self.kingdom:setString(hp.lang.getStrByID(5494)..": "..player.serverMgr.getCountryByPos(self.tileInfo.position))
				else
					self.name:setString(hp.lang.getStrByID(5359).."："..hp.lang.getStrByID(5147))
					-- self.kingdom:setString(hp.lang.getStrByID(5494).."："..hp.lang.getStrByID(5147))
					self.kingdom:setString(hp.lang.getStrByID(5494)..": "..player.serverMgr.getCountryByPos(self.tileInfo.position))
				end

				-- 占领者
				if info_.occupierID ~= 0 then
					self.occupier:setString(string.format(hp.lang.getStrByID(5380), info_.occupier))
				else	
					self.occupier:setString(string.format(hp.lang.getStrByID(5380), hp.lang.getStrByID(5147)))
				end	

				self:updateInfo()
				self:tickUpdate()
			end
		end
	end
	-- url
	local url = nil
	local pos = self.tileInfo.position
	local server = player.serverMgr.getServerByPos(pos.kx, pos.ky)
	if server then
		url = server.url
	end

	-- 发送消息
	local cmdData={}
	cmdData.type = 11
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld, nil, nil, url)
	self:showLoading(cmdSender)
end

function UI_fortress:updateInfo()
	-- 描述
	local info_ = self.info
	local status_ = globalData.OPEN_STATUS
	if info_.open == status_.OPEN then
		local time_ = info_.endTime - player.getServerTime()
		cclog_("updateInfo", info_.endTime, player.getServerTime(), time_)
		self.desc:setString(string.format(hp.lang.getStrByID(5383), hp.datetime.strTime(time_)))
		self.scout:loadTexture(config.dirUI.common.."button_blue.png")
		self.scout:setTouchEnabled(true)
		self.attack:loadTexture(config.dirUI.common.."button_blue.png")
		self.attack:setTouchEnabled(true)
		self.rally:loadTexture(config.dirUI.common.."button_blue.png")
		self.rally:setTouchEnabled(true)
	elseif info_.open == status_.CLOSE then
		self.desc:setString(hp.lang.getStrByID(5384))
		self.scout:loadTexture(config.dirUI.common.."button_gray.png")
		self.scout:setTouchEnabled(false)
		self.attack:loadTexture(config.dirUI.common.."button_gray.png")
		self.attack:setTouchEnabled(false)
		self.rally:loadTexture(config.dirUI.common.."button_gray.png")
		self.rally:setTouchEnabled(false)
	elseif info_.open == status_.NOT_OPEN then
		local time_ = info_.startTime - player.getServerTime()
		cclog_("updateInfo", info_.startTime, player.getServerTime(), time_)
		self.desc:setString(string.format(hp.lang.getStrByID(5357), hp.datetime.strTime(info_.startTime - player.getServerTime())))
		self.scout:loadTexture(config.dirUI.common.."button_gray.png")
		self.scout:setTouchEnabled(false)
		self.attack:loadTexture(config.dirUI.common.."button_gray.png")
		self.attack:setTouchEnabled(false)
		self.rally:loadTexture(config.dirUI.common.."button_gray.png")
		self.rally:setTouchEnabled(false)
	end

	if (not player.serverMgr.isMyPosServer(self.tileInfo.position.kx, self.tileInfo.position.ky))
	 or (not player.serverMgr.isMyServer(self.tileInfo.position.kx, self.tileInfo.position.ky)) then
	-- 不同服务器，一下操作不可用
		self.attack:setTouchEnabled(false)
		self.rally:setTouchEnabled(false)
		self.scout:setTouchEnabled(false)
		self.attack:loadTexture(config.dirUI.common .. "button_gray.png")
		self.rally:loadTexture(config.dirUI.common .. "button_gray.png")
		self.scout:loadTexture(config.dirUI.common .. "button_gray.png")
	end
end

function UI_fortress:tickUpdate()
	if self.info == nil then
		return
	end
	local info_ = self.info
	local status_ = globalData.OPEN_STATUS
	if info_.open == status_.OPEN then
		local time_ = info_.endTime - player.getServerTime()
		self.desc:setString(string.format(hp.lang.getStrByID(5383), hp.datetime.strTime(time_)))
	elseif info_.open == status_.NOT_OPEN then
		local time_ = info_.startTime - player.getServerTime()
		self.desc:setString(string.format(hp.lang.getStrByID(5357), hp.datetime.strTime(info_.startTime - player.getServerTime())))
	end

	if info_.occupierTime ~= 0 then
		local time_ = player.getServerTime() - info_.occupierTime
		if time_ < 0 then
			time_ = 0
		end
		self.occupyTime:setString(string.format(hp.lang.getStrByID(5401), hp.datetime.strTime(time_)))
	else
		self.occupyTime:setString(string.format(hp.lang.getStrByID(5401), hp.lang.getStrByID(5147)))
	end
end

function UI_fortress:heartbeat(dt_)
	self:tickUpdate()
end

function UI_fortress:onMsg(msg_, param_)
	if msg_ == hp.MSG.KING_BATTLE then
		if param_.msgType == 3 then
			self:updateInfo()
		elseif param_.msgType == 4 then
			self:updateInfo()
		elseif param_.msgType == 5 then
			self:initShow()
		end
	end
end

function UI_fortress:onRemove()
	player.fortressMgr.unSubscribeData("UI_fortress")
	self.super.onRemove(self)
end