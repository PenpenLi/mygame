--
-- player.lua
--
--================================================
require "obj/soldier"
require "obj/cdBox"
require "obj/alliance/alliance"
require "playerData/globalData"

player = player or {}


-- private variables
------------------------------------
local userDefault = {}
local playerData = {}
local bookMarks = nil
local alliance = nil
local h_p_key = nil

local isLogined = false -- 是否登录
local dataMgrs = {} --外部数据管理模块
local dataMgrsFile = {}--外部模块对应的文件

-- private functions
------------------------------------
local function initUserDefault()
	local udef = cc.UserDefault:getInstance()
	math.randomseed(os.time())
	local randId = string.format("t%d%d", math.random(999), math.random(999))
	userDefault.uid = udef:getStringForKey("uid", randId)
	userDefault.pwd = udef:getStringForKey("pwd", "pwd123")
	userDefault.name = udef:getStringForKey("name", randId)
	userDefault.param = udef:getStringForKey("param", "aaa")
	--userDefault.serverID = udef:getIntegerForKey("serverID", 0)
	userDefault.musicVolume = udef:getIntegerForKey("musicVol", 50)
	userDefault.effectVolume = udef:getIntegerForKey("effectVol", 50)
	userDefault.gatherGoldHint = udef:getIntegerForKey("gatherGoldHint", 0)

	player.flushUserDefualt()
end


local function loadDataMgr(mgrFile)
	local mgr = require(mgrFile)
	mgr.create()
	table.insert(dataMgrs, mgr)
	table.insert(dataMgrsFile, mgrFile)

	cclog("----loadDataMgr : %s", mgrFile)
	return mgr
end


-- public functions
-- ================================
-- create
-- 加载相关模块
-------------------
function player.create()
	initUserDefault()

	dataMgrs = {}
	dataMgrsFile = {}

	player.dataMgrDemo         = loadDataMgr("dataMgr/dataMgrDemo")

	-- 服务器信息
	player.serverMgr           = loadDataMgr("dataMgr/serverMgr")
	-- 玩家状态
	player.stateMgr            = loadDataMgr("dataMgr/stateMgr")
	-- 新手指引
	player.guide               = loadDataMgr("dataMgr/guide")
	-- VIP
	player.vipStatus           = loadDataMgr("dataMgr/vipStatus")
	-- 资源
	player.resourceMgr         = loadDataMgr("dataMgr/resourceMgr")
	-- 好友
	player.friendMgr           = loadDataMgr("dataMgr/friendMgr")
	-- 聊天信息
	player.chatRoom            = loadDataMgr("dataMgr/chatRoom")
	-- 邮件管理
	player.mailCenter          = loadDataMgr("dataMgr/mailCenter")
	-- 建筑
	player.buildingMgr         = loadDataMgr("dataMgr/buildingMgr")
	-- 道具
	player.itemBag             = loadDataMgr("dataMgr/itemBag")
	-- 装备
	player.equipBag            = loadDataMgr("dataMgr/equipBag")
	-- 英雄
	player.hero                = loadDataMgr("dataMgr/hero")
	-- 科技
	player.researchMgr         = loadDataMgr("dataMgr/researchMgr")
	-- 关押英雄
	player.takeInHeroMgr       = loadDataMgr("dataMgr/takeInHeroMgr")

	-- 陷阱
	player.trapManager         = loadDataMgr("dataMgr/trapManager")
	-- 士兵
	player.soldierManager      = loadDataMgr("dataMgr/soldierManager")
	-- 任务
	player.questManager        = loadDataMgr("dataMgr/questManager")
	-- 副本
	player.copyManager         = loadDataMgr("dataMgr/copyManager")
	-- 商城
	player.goldShopMgr         = loadDataMgr("dataMgr/goldShopMgr")
	-- 行军
	player.marchMgr            = loadDataMgr("dataMgr/marchMgr")
	-- 加成
	player.bufManager      	   = loadDataMgr("dataMgr/bufManager/bufManager")
	-- 建筑加成
	player.buildBufManager     = loadDataMgr("dataMgr/bufManager/buildBufManager")
	-- 头衔
	player.titleBufManager     = loadDataMgr("dataMgr/bufManager/titleBufManager")
	-- 要塞
	player.fortressMgr  	   = loadDataMgr("dataMgr/battle/fortressMgr")	
	-- 单人活动
	player.soloActivityMgr     = loadDataMgr("dataMgr/activity/soloActivityMgr")
	-- 联盟活动
	player.unionActivityMgr    = loadDataMgr("dataMgr/activity/unionActivityMgr")
	-- 王国活动
	player.kingdomActivityMgr  = loadDataMgr("dataMgr/activity/kingdomActivityMgr")
	-- 丞相勾选表
	player.checkedPMTbl        = loadDataMgr("dataMgr/checkedPMTbl")
	-- 府邸升级礼包
	player.mansionUpgradeGift  = loadDataMgr("dataMgr/mansionUpgradeGift")
	-- 在线礼包
	player.onlineGift		   = loadDataMgr("dataMgr/onlineGift")
	-- 使者信使管理器
	player.postmanAndEnvoyMgr  = loadDataMgr("dataMgr/postmanAndEnvoyMgr")
	-- 签到管理器
	player.signinMgr		   = loadDataMgr("dataMgr/signinMgr")
	-- 新手奖励管理器
	player.noviceGiftMgr	   = loadDataMgr("dataMgr/noviceGiftMgr")
	-- 精英BOSS活动管理器
	player.bossActivityMgr	   = loadDataMgr("dataMgr/activity/bossActivityMgr")
	-- 府邸管理器
	player.mansionMgr		   = loadDataMgr("dataMgr/mansionMgr/mansionMgr")
	-- 推送配置管理
	player.pushConfigMgr	   = loadDataMgr("dataMgr/pushConfigMgr")

	-- helper
	player.helper = require("playerData/helper")
	player.helper.init()
	-- 公会网络消息处理
	player.unionHttpHelper = require("obj/alliance/unionHttpHelper")
	player.unionHttpHelper.init()
	-- 快速建造功能
	player.quicklyMgr = require("playerData/quickly")
	player.quicklyMgr.init()
end

-- init
-- 初始化相关模块
-------------------
function player.init()
	-- body
	isLogined = false
	h_p_key = nil

	alliance = Alliance.new()
	hp.msgCenter.init()
	cdBox.init()
	for i, mgr in ipairs(dataMgrs) do
		mgr.init()
	end
end

-- initData
-- 用从服务器返回的数据进行初始化
-------------------
function player.initData(data_)
	playerData = data_

	 --记录数据初始的时间
	playerData.initDataTime_ = data_.systime
	playerData.initDataClock_ = os.time()

	player.initAlliance(playerData)
	cdBox.initCD(playerData)
	for i, mgr in ipairs(dataMgrs) do
		mgr.initData(playerData)
	end
	isLogined = true
end

-- synData
-- 用从服务器返回的数据进行同步
-------------------
function player.synData(data_)
	local data = data_
	--同步系统时间
	if data.systime~=nil then
		--系统时间相差大于config.server.timeout时，重新设置系统时间
		local dt = playerData.systime-data.systime
		if -config.server.timeout<dt or dt>config.server.timeout then
			playerData.initDataTime_ = data.systime
			playerData.initDataClock_ = os.time() --记录数据初始的时间
			playerData.systime = data.systime
			player.heartbeat(dt, true)--此处执行一次心跳
		end
	end

	player.updateAlliance(data)
	cdBox.synData(data)
	for i, mgr in ipairs(dataMgrs) do
		mgr.syncData(data)
	end

	-- 同步战力
	if data.power~=nil then
		player.setPower(data.power)
	end
	--等级
	if data.lv~=nil then
		player.setLv(data.lv)
	end
	--经验
	if data.exp~=nil then
		player.setExp(data.exp)
	end
	-- 同步体力
	if data.jihadL ~= nil then
		playerData.jihadL = data.jihadL
		hp.msgCenter.sendMsg(hp.MSG.COPY_NOTIFY, {msgType = 6})
	end

	-- 处理提示信息
	player.dealHintFrameInfo(data.notice)

end

-- heartbeat
-- player进行心跳
-------------------
function player.heartbeat(dt, flag)
	if not isLogined then
	-- 未登录，不进行心跳
		return
	end

	if flag==nil then
	-- 重新获取系统时间和dt
		local systime = playerData.initDataTime_ + (os.time()-playerData.initDataClock_)
		dt = systime - playerData.systime
		playerData.systime = systime
	end
	if dt==0 then
		return
	end

	alliance:heartBeat(dt)
	cdBox.heartbeat(dt)
	for i, mgr in ipairs(dataMgrs) do
		mgr.heartbeat(dt)
	end
end




-- isLogined
-- 查看玩家是否已经登录
function player.isLogined( )
	return isLogined
end

-- UserDefault
function player.getUserDefault()
	return userDefault
end
function player.getMusicVol()
	return userDefault.musicVolume
end
function player.getEffectVol()
	return userDefault.effectVolume
end
function player.getGatherGoldHint()
	return userDefault.gatherGoldHint
end

function player.setGatherGoldHint(hint_)
	local udef = cc.UserDefault:getInstance()
	userDefault.gatherGoldHint = hint_
	udef:setIntegerForKey("gatherGoldHint", userDefault.gatherGoldHint)
	udef:flush()
end
function player.setMusicVolume(volume_)
	local udef = cc.UserDefault:getInstance()
	userDefault.musicVolume = volume_
	udef:setIntegerForKey("musicVol", userDefault.musicVolume)
	udef:flush()
end
function player.setEffectVolume(volume_)
	local udef = cc.UserDefault:getInstance()
	userDefault.effectVolume = volume_
	udef:setIntegerForKey("effectVol", userDefault.effectVolume)
	udef:flush()
end
function player.flushUserDefualt()
	local udef = cc.UserDefault:getInstance()
	udef:setStringForKey("uid", userDefault.uid)
	udef:setStringForKey("pwd", userDefault.pwd)
	udef:setStringForKey("name", userDefault.name)
	udef:setStringForKey("param", userDefault.param)
	--udef:setIntegerForKey("serverID", userDefault.serverID)
	udef:flush()
end


-- h_p_key 
function player.h_p_key()
	return h_p_key
end
function player.set_h_p_key(h_p_key_)
	h_p_key = h_p_key_
end


-- getServerTime
function player.getServerTime()
	return playerData.systime
end


-- id
function player.getID()
	return playerData.id
end

-- name
function player.getName()
	return playerData.name
end
function player.setName(name_)
	playerData.name = name_
end
-- lv
function player.getLv()
	return playerData.lv
end
function player.setLv(lv_)
	local tempLev=playerData.lv
	playerData.lv = lv_
	hp.msgCenter.sendMsg(hp.MSG.LV_CHANGED, playerData.lv)
	if tempLev<lv_ then
		hp.msgCenter.sendMsg(hp.MSG.HERO_LV_UP, lv_)
	end
end
-- exp
function player.getExp()
	return playerData.exp
end
function player.setExp(exp_)
	playerData.exp = exp_
	hp.msgCenter.sendMsg(hp.MSG.EXP_CHANGED, playerData.exp)
end
function player.addExp(exp_)
	local maxLv = table.getn(game.data.heroLevel)
	local lv = playerData.lv
	if lv==maxLv then
		return
	end

	playerData.exp = playerData.exp + exp_

	for i=lv+1, maxLv do
		local lvInfo = game.data.heroLevel[i]
		if playerData.exp>=lvInfo.exp then
			lv = lv+1
			playerData.exp = playerData.exp-lvInfo.exp
		else
			break
		end
	end
	if lv~=playerData.lv then
		playerData.lv = lv
		hp.msgCenter.sendMsg(hp.MSG.LV_CHANGED, playerData.lv)
		hp.msgCenter.sendMsg(hp.MSG.HERO_LV_UP, playerData.lv)	
		if lv==maxLv then
			playerData.exp = 0
		end
	end
	hp.msgCenter.sendMsg(hp.MSG.EXP_CHANGED, playerData.exp)
end

-- getPower
function player.getPower()
	return playerData.power
end
-- setPower
function player.setPower(power_)
	if playerData.power~=power_ then
		playerData.power = power_
		hp.msgCenter.sendMsg(hp.MSG.POWER_CHANGED, power_)
	end
end
-- getTitle
-- 获取称号
function player.getTitle()
	return playerData.title
end


-- 资源
------------------------------
-- getResourceShow
function player.getResourceShow(res_)
	return player.resourceMgr.getResourceShow(res_)
end
-- getResource
function player.getResource(res_)
	return player.resourceMgr.getResource(res_)
end
-- setResource
function player.setResource(res_, num_)
	player.resourceMgr.setResource(res_, num_)
end
-- addResource
function player.addResource(res_, num_)
	player.resourceMgr.addResource(res_, num_)
end
-- expendResource
function player.expendResource(res_, num_)
	player.resourceMgr.expendResource(res_, num_)
end

-- item
-- 道具
------------------------------
-- getItemList 
-- 获取道具列表
function player.getItemList()
	return player.itemBag.getItemList()
end
-- getItemNum 
-- 获取道具个数
function player.getItemNum(itemSid_)
	return player.itemBag.getItemNum(itemSid_)
end
-- setItemNum 
-- 设置道具个数
function player.setItemNum(itemSid_, num_)
	player.itemBag.setItemNum(itemSid_, num_)
end
-- addItem
-- 添加道具
function player.addItem(itemSid_, num_)
	player.itemBag.addItem(itemSid_, num_)
end
-- expendItem
-- 消耗道具
function player.expendItem(itemSid_, num_)
	player.itemBag.expendItem(itemSid_, num_)
end

-- academy
-----------------------------
function player.getSoldierLevel(type_)
	local begin_ = type_ * globalData.SOLDIER_TYPE
	for i = begin_, begin_ - globalData.SOLDIER_TYPE + 1, -1 do
		if game.data.army[i].unlock == -1 then
			return 1
		elseif player.researchMgr.isTechResearch(game.data.army[i].unlock) then
			return ((i-1) % globalData.SOLDIER_TYPE) + 1
		end
	end
	return 1
end

-- bookMark
-----------------------------
function player.getBookMark()
	return bookMarks
end

function player.parseBookMark(bmList)
	require "obj/bookMark"
	bookMarks = {}
	for i,v in ipairs(bmList) do
		local obj = BookMark.new(v)
		bookMarks[i] = obj
	end
end

function player.addBookMark(info_)
	if bookMarks == nil then
		return
	else
		local obj = BookMark.new(info_)
		table.insert(bookMarks, obj)
	end
end

function player.editBookMark(index_, subType_, name_)
	for i, v in ipairs(bookMarks) do
		if v:getIndex() == index_ then
			v.name = name_
			v.type = subType_
			hp.msgCenter.sendMsg(hp.MSG.BIGMAP_BOOKMARK, {2, index_, v})
			break
		end
	end
end

function player.deleteBookMark(index_)
	if bookMarks == nil then
		return
	else
		for i, v in ipairs(bookMarks) do
			if v:getIndex() == index_ then
				table.remove(bookMarks, i)
				hp.msgCenter.sendMsg(hp.MSG.BIGMAP_BOOKMARK, {1, index_})
				break
			end
		end
	end
end

function player.getBookMarkByIndex(index_)
	for i, v in ipairs(bookMarks) do
		if v:getIndex() == index_ then
			return v
		end
	end
	return nil
end

-- 工会
-- 初始化
function player.initAlliance(info_)
	alliance:init(info_)
	alliance:firstRequestData()
end

function player.getAlliance()
	return alliance
end

function player.updateAlliance(info_)
	alliance:synNetInfo(info_)
end

-- 处理提示信息
function player.dealHintFrameInfo(info_)
	if info_ == nil then
		return
	end

	cclog_("number", table.getn(info_))
	for i, v in ipairs(info_) do
		for j, w in ipairs(v) do
			cclog_(w)
		end

		local param_ = {}
		if v[1] == 6 then
			-- 建筑
			if v[4] == cdBox.CDTYPE.BUILD then
				param_[1] = 6
				local build_ = hp.gameDataLoader.getInfoBySid("building", v[5])
				param_[2] = v[2]
				param_[3] = v[3]
				param_[4] = build_.name
				param_[5] = v[6]
			-- 科研
			elseif v[4] == cdBox.CDTYPE.RESEARCH then
				param_[1] = 13
				local research_ = hp.gameDataLoader.getInfoBySid("research", v[5])
				param_[2] = v[2]
				param_[3] = v[3]
				param_[4] = research_.name
				param_[5] = v[6]
			end
		else
			param_ = v
		end
		Scene.showMsg(param_)
	end
end

function player.getMarchMgr()
	return player.marchMgr
end

function player.getFristLeague()
	return playerData.fristLeague
end

function player.clearFristLeague()
	playerData.fristLeague = 1
end

function player.getNewGuyGuard()
	if cdBox.getCD(cdBox.CDTYPE.PEACE) > 0 then
		return 1
	else
		return 0
	end
end

function player.getEnerge()
	return playerData.jihadL
end

function player.getUnionHttpHelper()
	return player.unionHttpHelper
end

function player.getSupportNum()
	cclog_("playerData.support",playerData.support)
	if playerData.support == nil then
		return 0
	else
		return playerData.support
	end
end

function player.clockEnd(name_, begin_, warnTime_)
	local interval_ = os.clock() - begin_
	cclog_(string.format("==================%s time cost:%f",name_, interval_))
	if warnTime_ ~= nil then
		if interval_ > warnTime_ then
			cclog_("===================time cost too much!!!")
		end
	end
end
