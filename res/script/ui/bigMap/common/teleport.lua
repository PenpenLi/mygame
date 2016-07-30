--
-- ui/bigMap/common/teleport.lua
-- 传送
--===================================
require "ui/frame/popFrame"
require "ui/frame/popFrameRed"


UI_teleport = class("UI_teleport", UI)

--init
function UI_teleport:init(tileInfo_, type_)
	-- data
	-- ===============================
	local ITEM_SID = 20302
	local operType = 1 --1:迁城，2 转服，3 跨服战
	local popFrame = nil
	if type_==1 then
	-- 迁徙
		if player.serverMgr.isMyServer(tileInfo_.position.kx, tileInfo_.position.ky) then
		-- 向同一个国家迁徙
			operType = 1
			if player.getItemNum(20304)>0 and player.buildingMgr.getBuildingMaxLvBySid(1001)>5 then
			-- 新手迁徙令
				ITEM_SID = 20304
			else
			-- 高级迁徙令
				ITEM_SID = 20302
			end
		else
		-- 向别的国家迁徙(跨服战)
			operType = 3
			ITEM_SID = 20302
		end
	elseif type_==2 then
	-- 转服
		operType = 2
		if player.getItemNum(20304)>0 and player.buildingMgr.getBuildingMaxLvBySid(1001)<=5 then
		-- 新手迁徙令
			ITEM_SID = 20304
		else
		-- 跨服迁徙令
			ITEM_SID = 20303
		end
	end
	self.haveNum = player.getItemNum(ITEM_SID)
	self.itemInfo = hp.gameDataLoader.getInfoBySid("item", ITEM_SID)
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================
	-- 初始化界面
	self:initUI()

	local function onBuyItemHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if tag == 1 then
				player.expendResource("gold", self.itemInfo.sale)
			elseif tag == 2 then
				player.expendItem(ITEM_SID, 1)
			end
			if operType==1 then
			-- 迁徙
				player.serverMgr.moveCity(data.x, data.y)
			elseif operType==2 then
			-- 转服
				local serverInfo = player.serverMgr.getServerByPos(tileInfo_.position.kx, tileInfo_.position.ky)
				player.set_h_p_key(data.id)
				player.serverMgr.moveCity(tileInfo_.position.x, tileInfo_.position.y, serverInfo.sid)
				player.kingdomActivityMgr.updateActivity() --重新请求跨服战信息
			elseif operType==3 then
			-- 跨服战迁徙
				-- 心跳已处理转服
				-- local serverInfo = player.serverMgr.getServerByPos(tileInfo_.position.kx, tileInfo_.position.ky)
				-- player.serverMgr.moveCity(tileInfo_.position.x, tileInfo_.position.y, serverInfo.sid, true)
			end

			if game.curScene.mapLevel==2 then
			-- 如果在大地图上，刷新地图上的数据
				game.curScene:objAppearOnMap()
			end
			self:closeAll()
		end
	end


	local function getOperParam()
		local serverInfo = player.serverMgr.getServerByPos(tileInfo_.position.kx, tileInfo_.position.ky)
		local param = 0
		if serverInfo~=nil then
			param = serverInfo.sid*math.pow(2, 20) + tileInfo_.position.x*math.pow(2, 10) + tileInfo_.position.y
		end

		return param
	end

	
	-- 使用道具，向服务器发请求
	-- 购买使用
	local function OnChargeTouched()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 14
		oper.type = 1
		oper.sid = ITEM_SID
		oper.gold = self.itemInfo.sale
		oper.param = getOperParam()
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
		self:showLoading(cmdSender, self.charge)
	end
	-- 使用
	local function onTransportTouched()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 14
		oper.type = 1
		oper.sid = ITEM_SID
		oper.gold = 0
		oper.param = getOperParam()
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 2)
		self:showLoading(cmdSender, self.charge)
	end

	-- 确认使用道具
	local function confTouched()
		if self.haveNum > 0 then
			onTransportTouched()
		else
			OnChargeTouched()
		end
	end

	-- 转服确认
	-- ===========================
	local function confChangeServer()
		require "ui/msgBox/msgBox"
		local condStrID = 0
		if player.getAlliance():getUnionID()~=0 then
		--有联盟
			condStrID = 1231
		elseif player.getMarchMgr().getFieldArmyNum()>0 then
		-- 有行军
			condStrID = 1232
		end
		if condStrID>0 then
			local ui_ = UI_msgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(condStrID), hp.lang.getStrByID(1209))
			self:addModalUI(ui_)
			return
		end
		local function onConfirm1Touched()
			local ui_ = UI_msgBox.new(hp.lang.getStrByID(1227), hp.lang.getStrByID(1230), hp.lang.getStrByID(1227),
			hp.lang.getStrByID(2412), confTouched, nil, "red")
			self:addModalUI(ui_)
		end
		local ui_ = UI_msgBox.new(hp.lang.getStrByID(1227), hp.lang.getStrByID(1229), hp.lang.getStrByID(1227),
			hp.lang.getStrByID(2412), onConfirm1Touched, nil, "red")
		self:addModalUI(ui_)
	end

	-- 迁徙城池确认
	-- ===========================
	local function confTeleport()
		if operType==1 then
			confTouched()
		else
		-- 王国活动，临时迁城
			confTouched()
			-- -- 判断王国活动是否开启
			-- if xxx then
			-- -- 王国活动已开启

			-- 	-- 判断是否王国活动开启的国家
			-- 	if xxxx then
			-- 		--
			-- 		confTouched()
			-- 	else
			-- 	end
			-- else
			-- -- 王国活动还未开启
			-- 	require "ui/msgBox/msgBox"
			-- 	local ui_ = UI_msgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(1233), hp.lang.getStrByID(1209))
			-- 	self:addModalUI(ui_)
			-- end
		end
	end

	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			if type_==1 then
				confTeleport()
			elseif type_==2 then
				confChangeServer()
			end
		end
	end

	if type_==1 then
	-- 迁徙
		popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1200))
		self.askLabel:setString(hp.lang.getStrByID(1211))
		self.charge:getChildByName("Label_7985"):setString(hp.lang.getStrByID(1200))
	elseif type_==2 then
	-- 转服
		popFrame = UI_popFrameRed.new(self.wigetRoot, hp.lang.getStrByID(1227))
		self.askLabel:setString(hp.lang.getStrByID(1228))
		self.charge:getChildByName("Label_7985"):setString(hp.lang.getStrByID(1227))
	end
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)


	self.charge:addTouchEventListener(onBtnTouched)
	if self.haveNum > 0 then
		self.charge:getChildByName("ImageView_gold"):setVisible(false)
	else
		self.charge:getChildByName("Label_7985"):setString(hp.lang.getStrByID(5064))
		self.charge:getChildByName("ImageView_gold"):getChildByName("Label_goldCost"):setString(self.itemInfo.sale)
	end
	self.itemImg:loadTexture(config.dirUI.item .. ITEM_SID .. ".png")
end

function UI_teleport:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "teleport.json")
	local Content = self.wigetRoot:getChildByName("Panel_7978")

	-- 询问
	self.askLabel = Content:getChildByName("Label_7979")
	-- 位置
	Content:getChildByName("Label_7980"):setString(player.serverMgr.formatPosition(self.tileInfo.position))
	-- 描述
	Content:getChildByName("Label_7983"):setString(self.itemInfo.desc)
	-- 拥有
	Content:getChildByName("ImageView_7982"):getChildByName("Label_8066"):setString(string.format(hp.lang.getStrByID(1213), self.haveNum))

	self.charge = Content:getChildByName("ImageView_7984")
	self.itemImg = Content:getChildByName("ImageView_7982"):getChildByName("ImageView_7981")
end
