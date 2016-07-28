--
-- file: playerData/prisonMgr.lua
-- desc: 监狱管理员
--================================================

-- channel=12 监狱英雄操作网络请求
-- @type=1: 获取英雄列表
-- @type=2: 释放英雄
-- @type=3: 处决英雄
-- @type=4: 招降英雄
------------------------------------------------------------------------------------


-- obj
-- =======================
local prisonMgr = {}


-- private data
-- =======================
local heroList = {} --被关押的英雄列表
local killCD = {cd=0}
local induceCD = 0

local cmdSender = nil
local curOper = nil

local localID = 1


-- private functions
------------------------------------
-- decodeHeroData
local function decodeHeroData(data_)
	local heroInfo = {}
	heroInfo.localID = localID
	localID = localID+1

	heroInfo.name = data_[1]
	heroInfo.ownerName = data_[2]
	heroInfo.unionName = data_[3]
	heroInfo.ownerID = data_[4]
	heroInfo.id = data_[5]
	heroInfo.sid = data_[6]
	heroInfo.lv = data_[7]
	heroInfo.leaveTime = data_[8]
	heroInfo.tatoalLoyalty = data_[9]
	heroInfo.loyalty = data_[10]
	return heroInfo
end

-- decodeKillCD
local function decodeKillCD(data_)
	killCD.cd = data_[1]
	killCD.total_cd = data_[2]
	killCD.ownerID = data_[3]
	killCD.id = data_[4]
end

-- onHttpResponse
local function onHttpResponse(status, response)
	local oper = curOper
	curOper = nil

	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result==nil or data.result~=0 then
		--网络出错
		return
	end

	if oper.type==1 then
	-- 获取英雄列表
		heroList = {}
		for i,v in ipairs(data.impri) do
			table.insert(heroList, decodeHeroData(v))
		end
		if data.cd~=nil then
			decodeKillCD(data.cd)
		end
		if data.surrender_cd~=nil then
			induceCD = data.surrender_cd
		else
			induceCD = 0
		end
		hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=1})
	elseif oper.type==2 then
	-- 释放英雄
		local heroInfo = nil
		for i, v in ipairs(heroList) do
			if oper.id==v.ownerID and oper.sid==v.id then
				heroInfo = v
				table.remove(heroList, i)
				hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=2, hero=heroInfo})
				return
			end
		end
	elseif oper.type==3 then
	-- 处决英雄
		for i, v in ipairs(heroList) do
			if oper.id==v.ownerID and oper.sid==v.id then
				killCD.cd = data.cd
				killCD.total_cd = data.cd
				killCD.ownerID = v.ownerID
				killCD.id = v.id
				hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=3, cd=killCD})
				return
			end
		end
	elseif oper.type==4 then
	-- 招降一个英雄
		if data.state==0 then
		-- 招降成功
			local heroInfo = nil
			for i, v in ipairs(heroList) do 
				if oper.id==v.ownerID and oper.sid==v.id then
					heroInfo = v
					table.remove(heroList, i)
					hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=2, hero=heroInfo})
				end
			end
		else
			hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=4, hero=heroInfo})
		end

		hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=5})
	end
end

-- sendHttpCmd
local function sendHttpCmd(oper)
	if curOper~=nil then
		-- 当前操作未完成
		return false
	end

	local cmdData={operation={}}
	oper.channel = 12
	cmdData.operation[1] = oper
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	curOper = oper

	return true
end

-- public function
-- =======================
-- init
function prisonMgr.init()
	cmdSender = hp.httpCmdSender.new(onHttpResponse)
end

-- getHeros
function prisonMgr.getHeros()
	return heroList
end

-- getHeroByLocalID
function prisonMgr.getHeroByLocalID(localID_)
	for i,v in ipairs(heroList) do
		if localID_==v.localID then
			return v
		end
	end

	return nil
end

-- getKillCD
function prisonMgr.getKillCD()
	return killCD
end

-- getInduceCD
function prisonMgr.getInduceCD()
	return induceCD
end

-- heartbeat
function prisonMgr.heartbeat(dt)
	if killCD.cd>0 then
		if killCD.cd>dt then
			killCD.cd = killCD.cd - dt
		else
			killCD.cd = 0
			-- 处决英雄后将英雄移除
			for i,heroInfo in ipairs(heroList) do
				if heroInfo.ownerID==killCD.ownerID and heroInfo.id==killCD.id then
					table.remove(heroList, i)
					hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=2, hero=heroInfo})
					hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=3, cd=killCD})
					break
				end
			end
		end
	end

	if induceCD>0 then
		if induceCD>dt then
			induceCD = induceCD - dt
		else
			induceCD = 0
			hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=5})
		end
	end

	for i, heroInfo in ipairs(heroList) do
		if heroInfo.leaveTime>0 then
			if heroInfo.leaveTime>dt then
				heroInfo.leaveTime = heroInfo.leaveTime - dt
			else
			-- 离开时间到，移除英雄
				heroInfo.leaveTime = 0
				table.remove(heroList, i)
				hp.msgCenter.sendMsg(hp.MSG.PRISON_MGR, {type=2, hero=heroInfo})
				break
			end
		end
	end
end

-- 网络请求相关
-------------------------------------
-- getHero
-- 获取英雄列表
function prisonMgr.getHero()
	local oper = {}
	oper.type = 1
	return sendHttpCmd(oper)
end

-- freeHero
-- 释放英雄
function prisonMgr.freeHero(localID_)
	local heroInfo = prisonMgr.getHeroByLocalID(localID_)
	local oper = {}
	oper.type = 2
	oper.id = heroInfo.ownerID
	oper.sid = heroInfo.id
	return sendHttpCmd(oper)
end

-- killHero
-- 处决英雄
function prisonMgr.killHero(localID_)
	local heroInfo = prisonMgr.getHeroByLocalID(localID_)
	local oper = {}
	oper.type = 3
	oper.id = heroInfo.ownerID
	oper.sid = heroInfo.id
	return sendHttpCmd(oper)
end

-- induceHero
-- 招降英雄
function prisonMgr.induceHero(localID_)
	local heroInfo = prisonMgr.getHeroByLocalID(localID_)
	local oper = {}
	oper.type = 4
	oper.id = heroInfo.ownerID
	oper.sid = heroInfo.id
	return sendHttpCmd(oper)
end

return prisonMgr
