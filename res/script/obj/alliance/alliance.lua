--
-- obj/alliance/alliance.lua
-- 工会
--================================================
require "obj/alliance/member"

Alliance = class("Alliance")

local ISDIRTY = false
local TODAYUP = 10000
local HELPONCE = 100
local REQUESTINTERVAL = 10 -- 定时请求

local interval_ = 0

local function band(num_, des_)
	local dNum_ = {}
	local dDes_ = {}
	local dResult_ = {}

	local temp_ = num_
	while temp_ > 0 do
		table.insert(dNum_, temp_%2)
		temp_ = math.floor(temp_/2)
	end

	local temp_ = des_
	while temp_ > 0 do
		table.insert(dDes_, temp_%2)
		temp_ = math.floor(temp_/2)
	end

	local len_ = table.getn(dNum_)
	if len_ < table.getn(dDes_) then
		len_ = table.getn(dDes_)
	end

	for i=1,len_ do
		local t_ = 0
		if (dNum_[i] == 1) and (dDes_[i] == 1) then
			t_ = 1
			return 1
		end
		-- table.insert(dResult_, t_)
	end
	return 0
end

state = 
{
	JOIN = 1,	-- 是否收人验证
}

dirtyType = 
{
	BASEINFO = 1, -- 基本数据
	MEMBER = 2, -- 成员
	ATTACK = 3, 
	DEFENSE = 4,
	HELP = 5,
	SMALFIGHT = 6,
	BIGFIGHT = 7,
	VARIABLENUM = 8,
	FIGHTBASEINFO = 9,
	UNIONGIFT = 10,
}

local requestTypeMap = 
{
	19,	-- 公会基本信息
	20,	-- 公会成员
	27,	-- 公会战
	28,	-- 公会防守
	40,	-- 公会帮助
	42,	-- 小型作战
	48,	-- 大型作战
	51, -- 可变数字信息
	49,	-- 战斗的基本信息
	53,	-- 公会礼包
}

local totalRank = 5

--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function Alliance:ctor()
	-- 工会id
	self.unionID = 0

	-- 个人公会信息
	self.myUnionInfoBase = {}

	-- 工会基本信息
	self.baseInfo = {}

	-- 工会战
	self.rallyWar = {}

	self.rallyDefense = {}

	-- 公会首页(推送)
	self.unionHomePageData = {}

	-- 工会成员
	self.members = {} -- {{rank1},{rank2},{rank3},{rank4},{rank5}}

	-- 帮助信息
	self.unionHelp = {}

	-- 团队作战
	self.smallFight = {}

	self.mySmallFightBase = nil

	self.bigFight = nil

	-- 公会礼包
	self.unionGift = {}

	-- 定时刷新
	local list_ = {3,4,5,6,7,9,10}
	self.freshTimer = {}
	for i, v in ipairs(list_) do	
		self.freshTimer[v] = 0
	end
	-- 数据请求锁定,请求还未返回，忽略下个请求
	self.requestLock = {}

	-- 引用计数
	self.reference = {}
	-- 数据有效性
	self.dirty = {}
	for i, v in pairs(dirtyType) do
		self.dirty[v] = true
		self.requestLock[v] = false
		self.reference[v] = {}
	end
end

-- 离开公会，所有数据不可用
function Alliance:leaveUnion()
	for i, v in pairs(dirtyType) do
		self.dirty[v] = true
		self.reference[v] = {}
	end
end

function Alliance:firstRequestData()
	if self.unionID == 0 then
		return
	end	
	
	local function onBaseInfoResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:updateData(data, dirtyType.BASEINFO)
			self:updateData(data, dirtyType.MEMBER)
			self:updateData(data, dirtyType.VARIABLENUM)
			-- self:updateBaseInfo(data.league)
			-- self:updateMember(data.member)
			-- self:updateUnionHomePageInfo(data.leagueNum)	
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 50
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function Alliance:init(info_)
	-- 公会id
	if info_.league ~= nil then
		self.unionID = info_.league
		self:updateMyUnionInfoBase(info_)
	end

	self:setFightRestCount(info_)
end

-- 同步网络数据
function Alliance:synNetInfo(info_)
	if info_ == nil then
		return
	end

	if info_.league == 1 then
		self.dirty[dirtyType.BASEINFO] = true
		self:requestData(dirtyType.BASEINFO)
	end
	if info_.member == 1 then
		self.dirty[dirtyType.MEMBER] = true
		self:requestData(dirtyType.MEMBER)	-- 立即请求
	end
	if info_.leagueNum ~= nil then
		self:updateData(info_, dirtyType.VARIABLENUM)
	end
	-- elseif info_.league == 1 then
	-- 	self.dirty[dirtyType.ATTACK] = true
	-- elseif info_.league == 1 then
	-- 	self.dirty[dirtyType.DEFENSE] = true
	-- elseif info_.league == 1 then
	-- 	self.dirty[dirtyType.HELP] = true
	-- elseif info_.league == 1 then
	-- 	self.dirty[dirtyType.SMALFIGHT] = true
	-- elseif info_.league == 1 then
	-- 	self.dirty[dirtyType.BIGFIGHT] = true
	-- end
	if info_.leagueId ~= nil then
		self.unionID = info_.leagueId
	end
end

function Alliance:updateData(info_, type_)
	if type_ == dirtyType.BASEINFO then
		self:updateBaseInfo(info_.league)
	elseif type_ == dirtyType.MEMBER then
		self:updateMember(info_.member)
	elseif type_ == dirtyType.ATTACK then
		self:updateRallyWar(info_)
	elseif type_ == dirtyType.DEFENSE then
		self:updateRallyDefense(info_)
	elseif type_ == dirtyType.HELP then
		self:updateHelpInfo(info_.help)
	elseif type_ == dirtyType.SMALFIGHT then
		self:updateSmallFight(info_.skirmish)
	elseif type_ == dirtyType.BIGFIGHT then
		self:updateBigFight(info_.battle)
	elseif type_ == dirtyType.VARIABLENUM then
		self:updateUnionHomePageInfo(info_.leagueNum)
	elseif type_ == dirtyType.FIGHTBASEINFO then
		self:updateFightBase(info_)
	elseif type_ == dirtyType.UNIONGIFT then
		self:updateUnionGift(info_.leagueGift)
	end
	hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, type_)
end

-- 准备数据，没有则请求，然后发通知
function Alliance:prepareData(type_, name_)
	if self.dirty[type_] == true then
		self:requestData(type_)
	else
		print("prepareData",type_,name_)
		hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, type_)
	end

	if self.reference[type_][name_] == nil then
		self.reference[type_][name_] = 1
	end
end

function Alliance:unPrepareData(type_, name_)
	if self.reference[type_][name_] ~= nil then
		self.reference[type_][name_] = nil
	end
end

-- 判断是否进行数据更新
function Alliance:tryRequestData(type_)
	local ref_ = hp.common.getTableTotalNum(self.reference[type_])
	if ref_ > 0 then
		self:requestData(type_)
	elseif ref_ < 0 then
		print("error,error,error,error,error", type_)
	end
end

function Alliance:requestData(type_)
	local function onBaseInfoResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:updateData(data, type_)
		end
		self.requestLock[type_] = false
	end

	if self.requestLock[type_] == true then
		return
	end
	self.requestLock[type_] = true

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = requestTypeMap[type_]	
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function Alliance:getUnionID()
	return self.unionID
end

function Alliance:setUnionID(id_)
	self.unionID = id_
end

function Alliance:getFunds()
	return self.baseInfo.funds
end

-- 个人公会信息
function Alliance:updateMyUnionInfoBase(info_)
	self.myUnionInfoBase.contribute = info_.leagueCost
	self.myUnionInfoBase.todayContri = info_.dayLeagueCost
	self.myUnionInfoBase.todayUp = TODAYUP
end

function Alliance:getMyUnionInfoBase()
	return self.myUnionInfoBase
end

-- 公会首页基础信息
function Alliance:updateUnionHomePageInfo(info_)
	self.unionHomePageData.help = info_[4]
	self.unionHomePageData.war = info_[2]
	self.unionHomePageData.defense = info_[1]
	self.unionHomePageData.applicant = info_[3]
	self.unionHomePageData.gift = info_[5]
	self.unionHomePageData.unionWar = self.unionHomePageData.war + self.unionHomePageData.defense
	self.unionHomePageData.joinAble = info_[6]
	self.dirty[dirtyType.VARIABLENUM] = ISDIRTY
end

function Alliance:setFightRestCount(info_)
	if info_.skirmJ ~= nil then
		self.unionHomePageData.joinTimes = info_.skirmJ
	else
		self.unionHomePageData.joinTimes = 0
	end

	if info_.skirmC ~= nil then
		self.unionHomePageData.createTimes = info_.skirmC
	else
		self.unionHomePageData.createTimes = 0
	end

	if info_.battle == nil then
		self.unionHomePageData.battle = 0
	else
		self.unionHomePageData.battle = 1
	end
end

function Alliance:changeHomePageInfo(name_, num_)
	self.unionHomePageData[name_] = num_
	hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.VARIABLENUM)
end

function Alliance:getUnionHomePageInfo()
	return self.unionHomePageData
end

-- 公会基本信息
function Alliance:updateBaseInfo(info_)
	local info_ = info_[1]
	self.baseInfo.chairmanID = info_[2]
	self.baseInfo.memNum = info_[3]
	self.baseInfo.name = info_[4]
	self.baseInfo.chairman = info_[5]
	self.baseInfo.icon = info_[6]
	self.baseInfo.message = info_[7]
	self.baseInfo.giftExp = info_[8]
	self.baseInfo.power = info_[9]
	self.baseInfo.kill = info_[10]
	self.baseInfo.joinState = band(info_[11], state.JOIN)
	self.baseInfo.funds = info_[12]
	self:calcGiftLevel()
	self.dirty[dirtyType.BASEINFO] = ISDIRTY
end

function Alliance:calcGiftLevel()
	local temp_ = nil
	for i, v in ipairs(hp.gameDataLoader.getTable("unionGiftlv")) do
		if self.baseInfo.giftExp >= v.exp then
			self.baseInfo.giftLevel = i
			temp_ = v
			if i == table.getn(hp.gameDataLoader.getTable("unionGiftlv")) then
				self.baseInfo.giftCurLvExp = 0
				self.baseInfo.levelUpExp = 0
			end
		else
			self.baseInfo.giftCurLvExp = self.baseInfo.giftExp - temp_.exp
			self.baseInfo.levelUpExp = v.exp - temp_.exp
			return
		end
	end
end

function Alliance:getBaseInfo()
	return self.baseInfo
end

function Alliance:changeName(name_)
	self.baseInfo.name = name_	
	hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.BASEINFO)
end

-- 成员信息
-- 更新成员
function Alliance:updateMember(info_)
	self.members = {{},{},{},{},{}}
	for i, v in ipairs(info_) do
		local member_ = Member.new()
		member_:init(v)
		table.insert(self.members[member_:getRank()], member_)
	end
	self.dirty[dirtyType.MEMBER] = ISDIRTY
end

function Alliance:getMemberByID(id_)
	for i, v in ipairs(self.members) do
		for j, w in ipairs(v) do
			if w:getID() == id_ then
				return w
			end
		end
	end
end

function Alliance:getMembersByRank(rank_)
	return self.members[rank_]
end

function Alliance:getMemberByLocalID(id_)
	for i = 1, totalRank do
		for j, v in ipairs(self.members[i]) do
			if v:getLocalID() == id_ then
				return v
			end
		end
	end
end

function Alliance:getMyUnionInfo()
	for i = 1, totalRank do
		for j, v in ipairs(self.members[i]) do
			if v:getID() == player.getID() then
				return v
			end
		end
	end
end

-- 联攻信息
function Alliance:updateRallyWar(info_)
	self.rallyWar = {}
	if info_ == nil then
		return
	end

	-- 进攻信息
	for i, v in ipairs(info_.league) do
		require "obj/alliance/rallyWar"
		local rallyWar_ = RallyWar.new(v)
		table.insert(self.rallyWar, rallyWar_)
	end
	-- 同时刷新主页数字
	self:updateUnionHomePageInfo(info_.leagueNum)
	self.dirty[dirtyType.ATTACK] = ISDIRTY
end

function Alliance:getRallyWarInfo()
	return self.rallyWar
end

function Alliance:getRallyWarByID(id_)
	for i, v in ipairs(self.rallyWar) do
		if v.id == id_ then
			return v
		end
	end
end

-- 加入进攻
function Alliance:joinAttack(index_, army_)
	for i, v in ipairs(self.rallyWar) do
		if v.id == index_ then
			self.rallyWar[i]:joinWar(army_)
			hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.ATTACK)
			return
		end
	end
end

-- 联防
function  Alliance:updateRallyDefense(info_)
	self.rallyDefense = {}
	if info_ == nil then
		return
	end

	for i, v in ipairs(info_.member) do
		require "obj/alliance/rallyWar"
		local rallyWar_ = RallyWar.new(v)
		table.insert(self.rallyDefense, rallyWar_)
	end
	-- 同时刷新主页数字
	self:updateUnionHomePageInfo(info_.leagueNum)
	self.dirty[dirtyType.DEFENSE] = ISDIRTY
end

function Alliance:getRallyDefenseInfo()
	return self.rallyDefense
end

function Alliance:getRallyDefenseByFellowID(id_)
	for i, v in ipairs(self.rallyDefense) do
		if v.fellowID == id_ then
			return v
		end
	end
end

-- 加入防御
function Alliance:joinDefense(index_, army_)
	for i, v in ipairs(self.rallyDefense) do
		if v.fellowID == index_ then
			self.rallyDefense[i]:joinWar(army_)
			hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.DEFENSE)
			return
		end
	end
end

-- 作战基本信息
function Alliance:updateFightBase(info_)
	self.mySmallFightBase = Alliance.parseSmallFight(info_.skirmish[1])
	self.bigFight = self.parseBigFight(info_.battle)
	self.dirty[dirtyType.FIGHTBASEINFO] = ISDIRTY
end

-- 我的小型公会作战基本信息
function Alliance:getMySmallFightBase()
	return self.mySmallFightBase
end

-- 小型作战
function Alliance:updateSmallFight(info_)
	self.smallFight = {}
	if info_ == nil then
		return
	end

	for i, v in ipairs(info_) do
		local fightInfo_ = Alliance.parseSmallFight(v)
		table.insert(self.smallFight, fightInfo_)
	end
	self.dirty[dirtyType.SMALFIGHT] = ISDIRTY
	self:sortSmallFight()
end

-- 排序小型作战
function Alliance:sortSmallFight()
	local function changePosition(a, b)
		print("a,b",a,b)
		local x, y = a, b
		for i = a, table.getn(self.smallFight) do
			if self.smallFight[i].state == 2 then
				x = i
				break
			end
		end

		for i = b, 1 do
			if self.smallFight[i].state == 1 then
				y = i
				break
			end
		end

		if x >= y then
			return false, x, y
		else
			local temp_ = self.smallFight[x]
			self.smallFight[x] = self.smallFight[y]
			self.smallFight[y] = temp_
			return true, x, y
		end
	end
	
	local x_, y_ = 1, table.getn(self.smallFight)
	local ret_ = true
	if y_ <= 1 then
		return
	end

	repeat
		ret_, x_, y_ = changePosition(x_, y_)
		x_ = x_ + 1
		y_ = y_ - 1
		if x_ >= y_ then
			break
		end
	until ret_ == false

	for i, v in ipairs(self.smallFight) do
		if v.myFight == 1 then
			local temp_ = self.smallFight[i]
			table.remove(self.smallFight, i)
			table.insert(self.smallFight, 1, temp_)
			break
		end
	end
end

function Alliance:getSmallFight()
	return self.smallFight
end

function Alliance:getSmallFightByID(id_)
	for i, v in ipairs(self.smallFight) do
		if v.members[1] == id_ then
			return v, i
		end
	end
end

function Alliance:insertSmallFight(fight_)
	table.insert(self.smallFight, 1, fight_)
end

function Alliance:removeSmallFight(id_)
	for i, v in ipairs(self.smallFight) do
		if v.members[1] == id_ then
			table.remove(self.smallFight, i)
			hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.SMALFIGHT)
			return
		end
	end
end

function Alliance:playerJoinInSmallFight(id_, memID_)
	local fight_ = self:getSmallFightByID(id_)
	local member_ = self:getMemberByID(memID_)
	table.insert(fight_.members, memID_)
	fight_.power = fight_.power + member_:getPower()
	if table.getn(fight_.members) == fight_.info.num then
		fight_.state = 2
		fight_.myFight = 1
		fight_.endTime = fight_.info.time + player.getServerTime()
	end
	self:sortSmallFight()
	hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.SMALFIGHT)
end

function Alliance:playerLeaveSmallFight(id_, memID_)
	if id_ == memID_ then
		player.getAlliance():removeSmallFight(id_)
	else
		local fight_ = self:getSmallFightByID(id_)
		local member_ = self:getMemberByID(memID_)
		for i, v in ipairs(fight_.members) do
			if v == memID_ then
				table.remove(fight_.members, i)
			end
		end
		fight_.power = fight_.power - member_:getPower()
		hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.SMALFIGHT)
	end
end

-- 大型作战
function Alliance:updateBigFight(info_)
	self.bigFight = self.parseBigFight(info_)
	self.dirty[dirtyType.BIGFIGHT] = ISDIRTY
end

function Alliance:getBigFight()
	return self.bigFight
end

function Alliance:insertBigFight(fight_)
	self.bigFight = fight_
end

function Alliance:playerJoininBigFight(memID_)
	local member_ = self:getMemberByID(memID_)
	table.insert(self.bigFight.members, memID_)
	self.bigFight.power = self.bigFight.power + member_:getPower()
	hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.BIGFIGHT)
end

-- 帮助
function Alliance:updateHelpInfo(info_)
	self.unionHelp = {}
	if info_ == nil then
		return
	end

	-- 自己的帮助
	for i, v in ipairs(info_) do
		local help_ = Alliance.parseHelp(v)
		if help_.id == player.getID() then
			table.insert(self.unionHelp, 1, help_)
		else	
			table.insert(self.unionHelp, help_)
		end
	end
	self.dirty[dirtyType.HELP] = ISDIRTY
end

function Alliance:getHelpInfo()
	return self.unionHelp
end

function Alliance.requestHelp(cdType_, sucCallBack_, failCallBack_)
	local function onHelpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			Scene.showMsg({1016})
			if sucCallBack_ ~= nil then
				sucCallBack_(cdType_)
			end
		elseif failCallBack_ ~= nil then
			failCallBack_()
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 31
	oper.cd = cdType_
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHelpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

-- 公会礼包
-- =========================
function Alliance:updateUnionGift(info_)
	self.unionGift = {}
	if info_ == nil then
		return
	end

	for i, v in ipairs(info_) do
		local gift_ = Alliance:parseUnionGift(v)
		self.unionGift[gift_.id] = gift_
	end
end

function Alliance:getUnionGift()
	return self.unionGift
end

function Alliance:receiveGift(id_)
	local giftInfo_ = hp.gameDataLoader.getInfoBySid("unionGift", self.unionGift[id_].sid)
	self.baseInfo.giftExp = giftInfo_.exp + self.baseInfo.giftExp
	self:calcGiftLevel()
	self.unionGift[id_] = nil
	self:changeHomePageInfo("gift", self.unionHomePageData.gift - 1)
	hp.msgCenter.sendMsg(hp.MSG.UNION_RECEIVE_GIFT, id_)
end

-- 一些事件响应
function Alliance:helpOneMember(index_)
	self.baseInfo.funds = self.baseInfo.funds + HELPONCE
	self.myUnionInfoBase.todayContri = self.myUnionInfoBase.todayContri + HELPONCE
	if self.myUnionInfoBase.todayContri > TODAYUP then
		self.myUnionInfoBase.todayContri = TODAYUP
	end
	table.remove(self.unionHelp, index_)
	self.unionHomePageData.help = self.unionHomePageData.help - 1
	hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.HELP)
	hp.msgCenter.sendMsg(hp.MSG.UNION_HELP_INFO_CHANGE)
	hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.VARIABLENUM)
end

function Alliance:helpAll(info_)
	self.baseInfo.funds = self.baseInfo.funds + info_.count
	self.myUnionInfoBase.todayContri = self.myUnionInfoBase.todayContri + info_.count
	hp.msgCenter.sendMsg(hp.MSG.UNION_HELP_INFO_CHANGE)
	self:updateData({help=info_.help}, dirtyType.HELP)
end

-- 数据解析
-- ===========================
function Alliance.parseUnionInfo(info_)
	local union_ = {}
	union_.id = info_[1]	-- 工会id
	union_.number = info_[3]	-- 成员数量
	union_.chairMan = info_[5]	-- 会长
	union_.notice = info_[7]	-- 公告
	union_.icon = info_[6]	-- 图标
	union_.name = info_[4]	-- 名称
	union_.giftLevel = info_[8]	-- 礼包等级
	union_.power = info_[9]	-- 战力
	union_.kill = info_[10]		-- 杀敌
	union_.join = band(info_[11], state.JOIN) -- 开启验证
	return union_
end

function Alliance.parsePlayerInfo(info_)
	local player_ = {}
	player_.id = string.format("%.0f", info_[1])	-- 玩家id
	player_.rank = info_[2]
	player_.name = info_[3]
	player_.position = {x=info_[4], y=info_[5]}
	player_.icon = info_[6]	-- 图标
	player_.sign = info_[7]
	player_.kill = info_[8]
	return player_
end

function Alliance.parseHelp(info_)
	local help_ = {}
	help_.id = info_[1]
	help_.name = info_[2]
	help_.type = info_[3]
	help_.number = info_[4]
	help_.total = info_[5]
	help_.time = info_[6]
	help_.param = {info_[7], info_[8]}
	return help_
end

function Alliance.parseShopItem(info_)
	local item_ = {}
	item_.id = 1
	item_.number = 3
	return item_
end

function Alliance.parseSmallFight(info_)
	if info_ == nil then
		return nil
	end
	local fight_ = {}
	fight_.id = info_[1]
	fight_.info = hp.gameDataLoader.getInfoBySid("smallFight", info_[1])
	if info_[2] == 0 then
		fight_.state = 1 -- 还没有开始
	else
		fight_.state = 2 -- 已经开始
	end
	fight_.endTime = info_[2]
	fight_.members = info_[3]	
	
	fight_.myFight = 0
	fight_.power = 0
	-- 战斗力
	for i, v in ipairs(fight_.members) do
		local member_ = player.getAlliance():getMemberByID(v)
		fight_.power = fight_.power + member_:getPower()
		if member_:getID() == player.getID() then
			fight_.myFight = 1 -- 1-我的 0-别人的战斗
		end
	end

	return fight_
end

function Alliance.parseBigFight(info_)
	if info_[1] == nil then
		return nil
	end
	local fight_ = {}
	fight_.id = info_[1]
	fight_.info = hp.gameDataLoader.getInfoBySid("bigFight", info_[1])
	fight_.endTime = info_[2]
	fight_.members = info_[3]
	-- 战斗力
	fight_.power = 0
	for i, v in ipairs(fight_.members) do
		local member_ = player.getAlliance():getMemberByID(v)
		fight_.power = fight_.power + member_:getPower()
	end
	return fight_
end

function Alliance:parseUnionGift(info_)
	gift_ = {}
	gift_.id = info_[1]
	gift_.sid = info_[2]
	gift_.endTime = info_[3]
	return gift_
end

-- 心跳处理
-- ===========================
function Alliance:heartBeat(dt_)
	self:requestDataHeartBeat(dt_)
	self:rallyWarHeartBeat(dt_)
	self:rallyDefenseHeartBeat(dt_)
	self:smallFightHeartBeat(dt_)
	self:fightBaseHeartBeat(dt_)
end

function Alliance:rallyWarHeartBeat(dt_)
	for i, v in ipairs(self.rallyWar) do
		if v.lastTime < player.getServerTime() then
			table.remove(self.rallyWar, i)
			hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.ATTACK)
		end
	end
end

function Alliance:rallyDefenseHeartBeat(dt_)
	for i, v in ipairs(self.rallyDefense) do
		if v.lastTime < player.getServerTime() then
			table.remove(self.rallyDefense, i)
			hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.DEFENSE)
		end
	end
end

function Alliance:smallFightHeartBeat(dt_)
	for i, v in ipairs(self.smallFight) do
		if v.state == 2 then
			if v.endTime < player.getServerTime() then
				table.remove(self.smallFight, i)
				hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.SMALFIGHT)
			end
		end
	end
end

function Alliance:fightBaseHeartBeat(dt_)
	local dirty_ = false
	if self.mySmallFightBase ~= nil then
		if self.mySmallFightBase.state == 2 then
			if v.endTime < player.getServerTime() then
				self.mySmallFightBase = nil
				dirty_ = true
			end
		end
	end

	if self.bigFight ~= nil then
		if self.bigFight.endTime < player.getServerTime() then
			self.bigFight = nil
			dirty_ = true
		end
	end

	if dirty_ == true then
		hp.msgCenter.sendMsg(hp.MSG.UNION_DATA_PREPARED, dirtyType.FIGHTBASEINFO)
	end
end

function Alliance:requestDataHeartBeat(dt_)
	interval_ = interval_ + dt_
	if interval_ < 1 then
		return
	end

	for i, v in pairs(self.freshTimer) do
		local ref_ = hp.common.getTableTotalNum(self.reference[i])
		if ref_ > 0 then
			if v + interval_ > REQUESTINTERVAL then
				self:requestData(i)
				self.freshTimer[i] = 0
			else
				self.freshTimer[i] = self.freshTimer[i] + interval_
			end
		else
			self.freshTimer[i] = 0
			-- 一旦离开界面，数据dirty置为true
			self.dirty[i] = true
		end
	end
	interval_ = 0
end