--
-- file: obj/cdBox.lua
-- desc: cd队列
--================================================
-- BUILD(1)建筑类型,DONATE(2)捐赠类,ABILITY(3)科技类,BRANCH(4)士兵训练类,TRAP(5)陷阱训练,EQUIP(6)装备制造,
-- VIP(7)vip状态激活,PEACE(8)和平盾状态,FORBIDVIEW(9)-禁止查看状态,KILLHERO(10)-杀死一个英雄
-- DAILYTASK(11)日常任务, LEAGUETASK(12)联盟任务, VIPTASK(13)vip任务,REMEDY(14)-复活士兵
-- INDUCE(15) 招降

-- cdBox obj
cdBox = {}


-- cd类型
cdBox.CDTYPE = 
{
	BUILD = 1, --建筑
	DONATE = 2, --捐赠
	RESEARCH = 3, --科技
	BRANCH = 4, --士兵训练
	TRAP = 5, --陷阱训练
	EQUIP = 6, --装备锻造
	VIP = 7, --vip状态激活
	PEACE = 8, --和平盾状态
	FORBIDVIEW = 9, --禁止查看状态
	KILLHERO = 10, --杀死一个英雄
	DAILYTASK = 11, --日常任务
	LEAGUETASK = 12, --联盟任务
	VIPTASK = 13,--vip任务
	REMEDY = 14,--治疗伤兵
	INDUCE = 15,--招降英雄
}


--
-- private datas
---------------------------------
local cdBoxData = {}

local cdIconList = 
{
	"cd_icon_build.png",   --1
	"cd_icon_build.png",   --2
	"cd_icon_research.png", --3
	"cd_icon_branch.png", --4
	"cd_icon_trap.png", --5
	"cd_icon_equip.png", --6
	"cd_icon_build.png", --7
	"cd_icon_build.png", --8
	"cd_icon_build.png", --9
	"cd_icon_build.png", --10
	"cd_icon_dailytask.png", --11
	"cd_icon_leaguetask.png", --12
	"cd_icon_viptask.png", --13
	"cd_icon_remedy.png", --14
	"cd_icon_build.png", --15
}


--
-- private functions
---------------------------------
local handleCDFinish


--
-- public functions
---------------------------------

-- init
function cdBox.init()
	for k, v in pairs(cdBox.CDTYPE) do
		cdBoxData[v] = {}
		cdBoxData[v].cd = 0
		cdBoxData[v].helped = false
	end
end

-- initCD
function cdBox.initCD(cdData_)
	if cdData_~=nil then
		for i=1, #cdData_, 3 do
			local cdValue = cdData_[i+1];
			cdBoxData[cdData_[i]].cd = cdValue
			cdBoxData[cdData_[i]].left_cd = cdData_[i+1]
			cdBoxData[cdData_[i]].total_cd = cdData_[i+1]
		end
	end
end

-- initCDInfo
function cdBox.initCDInfo(cdType_, infoData_)
	if infoData_==nil then
		return
	end

	local cdInfo = cdBoxData[cdType_]
	cdInfo.helped = false

	if cdType_==cdBox.CDTYPE.BUILD then
	--1---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总cd
		cdInfo.type = infoData_[3] --类型：建造or升级or拆除
		cdInfo.bsid = infoData_[4] --所在地块sid
		cdInfo.btype = infoData_[5] --所在地块类型：城内or城外

	elseif cdType_==cdBox.CDTYPE.DONATE then
	--2---------------------------------

	elseif cdType_==cdBox.CDTYPE.RESEARCH then
	--3---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总cd

	elseif cdType_==cdBox.CDTYPE.BRANCH then
	--4---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总cd
		cdInfo.type = infoData_[3] --兵种
		cdInfo.number = infoData_[4] --造兵数量

	elseif cdType_==cdBox.CDTYPE.TRAP then
	--5---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总cd
		cdInfo.sid = infoData_[3] --城防类型sid
		cdInfo.number = infoData_[4] --个数

	elseif cdType_==cdBox.CDTYPE.EQUIP then
	--6---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总计cd
		cdInfo.equip = infoData_[3] --锻造装备sid
		cdInfo.id = infoData_[4] --锻造装备id
		cdInfo.level = infoData_[5] --锻造装备等级
		cdInfo.materials = infoData_[6] --锻造材料列表

	elseif cdType_==cdBox.CDTYPE.VIP then
	--7---------------------------------

	elseif cdType_==cdBox.CDTYPE.PEACE then
	--8---------------------------------

	elseif cdType_==cdBox.CDTYPE.FORBIDVIEW then
	--9---------------------------------

	elseif cdType_==cdBox.CDTYPE.KILLHERO then
	--10---------------------------------
	elseif cdType_==cdBox.CDTYPE.DAILYTASK then
	--11---------------------------------		
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
	elseif cdType_==cdBox.CDTYPE.LEAGUETASK then
	--12---------------------------------
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
	elseif cdType_==cdBox.CDTYPE.VIPTASK then
	--13---------------------------------
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
	elseif cdType_==cdBox.CDTYPE.REMEDY then
	--14---------------------------------
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
		cdInfo.soldier = {}
		for i = 1, player.getSoldierType() do
			cdInfo.soldier[i] = infoData_[2 + i]
		end
	end

	hp.msgCenter.sendMsg(hp.MSG.CD_STARTED, {cdType=cdType_, cdInfo=cdInfo})
end

-- synData
function cdBox.synData(data_)
	if data_~=nil then
		for i=1, #data_, 3 do
			cdBox.setCD(data_[i], data_[i+2])
		end
	end
end

-- initCDInfo
function cdBox.initCDHelpInfo(data_)
	if data_~=nil then
		for i,v in ipairs(data_) do
			local cdInfo = cdBoxData[v]
			cdInfo.helped = true
		end
	end
end

--getCDInfo
function cdBox.getCDInfo(cdType_)
	return cdBoxData[cdType_]
end

--setCDInfo
function cdBox.setCDInfo(cdType_, cdInfo_)
	print("setCDInfo",cdType_)
	cdBoxData[cdType_] = cdInfo_
end

--getCD
function cdBox.getCD(cdType_)
	return cdBoxData[cdType_].cd
end

--setCD
function cdBox.setCD(cdType_, cd_)
	local cdInfo = cdBoxData[cdType_]
	if cdInfo.cd~=0 and cd_==0 then
		cdInfo.cd = cd_
		handleCDFinish(cdType_, cdInfo)
		hp.msgCenter.sendMsg(hp.MSG.CD_FINISHED, {cdType=cdType_, cdInfo=cdInfo})
	else
		cdInfo.cd = cd_
	end
end

--addCD
function cdBox.addCD(cdType_, dt_)
	local cdInfo = cdBoxData[cdType_]
	cdInfo.cd = cdInfo.cd + dt_
end

--speedCD
function cdBox.speedCD(cdType_, dt_)
	local cdInfo = cdBoxData[cdType_]
	if cdInfo.cd~=0 then
		if cdInfo.cd>dt_ then
			cdInfo.cd = cdInfo.cd-dt_
		else
			cdInfo.cd = 0
			handleCDFinish(cdType_, cdInfo)
			hp.msgCenter.sendMsg(hp.MSG.CD_FINISHED, {cdType=cdType_, cdInfo=cdInfo})
		end
	end
end

--cancleCD
function cdBox.cancleCD(cdType_)
	cdBoxData[cdType_].cd = 0
end

-- canSpeed
function cdBox.canSpeed(cdType_)
	if cdType_==cdBox.CDTYPE.BUILD
		or cdType_==cdBox.CDTYPE.RESEARCH
		or cdType_==cdBox.CDTYPE.BRANCH
		or cdType_==cdBox.CDTYPE.TRAP
		or cdType_==cdBox.CDTYPE.EQUIP
		or cdType_==cdBox.CDTYPE.DAILYTASK
		or cdType_==cdBox.CDTYPE.LEAGUETASK
		or cdType_==cdBox.CDTYPE.VIPTASK
		or cdType_==cdBox.CDTYPE.REMEDY then

		return true
	end

	return false
end

-- canFreeSpeed
function cdBox.canFreeSpeed(cdType_)
	if cdType_==cdBox.CDTYPE.BUILD
		or cdType_==cdBox.CDTYPE.RESEARCH then

		return true
	end

	return false
end

-- canHelp
function cdBox.canHelp(cdType_)
	if cdBox.canFreeSpeed(cdType_) then
		if player.getAlliance():getUnionID()~=0 then
			local cdInfo = cdBoxData[cdType_]
			if cdInfo.helped then
				return false
			else
				return true
			end
		end
	end

	return false
end

-- help
function cdBox.help(cdType_)
	local cdInfo = cdBoxData[cdType_]
	cdInfo.helped = true
end

-- getIconFile
function cdBox.getIconFile(cdType_)
	return config.dirUI.common .. cdIconList[cdType_]
end


-- heartbeat
function cdBox.heartbeat(dt)
	for cdType, cdInfo in pairs(cdBoxData) do
		if cdInfo.cd~=0 then
			if cdInfo.cd>dt then
				cdInfo.cd = cdInfo.cd-dt
			else
				cdInfo.cd = 0
				handleCDFinish(cdType, cdInfo)
				hp.msgCenter.sendMsg(hp.MSG.CD_FINISHED, {cdType=cdType, cdInfo=cdInfo})
			end
		end
	end
end


--
-------------------------------------------

-- handleCDFinish
-- cd结束处理
function handleCDFinish(cdType_, cdInfo_)
		if cdType_==cdBox.CDTYPE.BUILD then
	--1---------------------------------

	elseif cdType_==cdBox.CDTYPE.DONATE then
	--2---------------------------------

	elseif cdType_==cdBox.CDTYPE.RESEARCH then
	--3---------------------------------

	elseif cdType_==cdBox.CDTYPE.BRANCH then
	--4---------------------------------
		player.soldierTrainFinish(cdInfo_)

	elseif cdType_==cdBox.CDTYPE.TRAP then
	--5---------------------------------
		player.trapTrainFinish(cdInfo_)

	elseif cdType_==cdBox.CDTYPE.EQUIP then
	--6---------------------------------
		player.equipBag.addEquip({cdInfo_.equip, cdInfo_.id, cdInfo_.level, {0, 0, 0}})

	elseif cdType_==cdBox.CDTYPE.VIP then
	--7---------------------------------

	elseif cdType_==cdBox.CDTYPE.PEACE then
	--8---------------------------------

	elseif cdType_==cdBox.CDTYPE.FORBIDVIEW then
	--9---------------------------------

	elseif cdType_==cdBox.CDTYPE.KILLHERO then
	--10---------------------------------
	elseif cdType_==cdBox.CDTYPE.DAILYTASK then
	--11---------------------------------
		player.dailyTaskFinish(cdType_, cdInfo_)
	elseif cdType_==cdBox.CDTYPE.LEAGUETASK then
	--12---------------------------------
		player.dailyTaskFinish(cdType_, cdInfo_)
	elseif cdType_==cdBox.CDTYPE.VIPTASK then
	--13---------------------------------
		player.dailyTaskFinish(cdType_, cdInfo_)
	elseif cdType_==cdBox.CDTYPE.REMEDY then
	--14---------------------------------
		player.healSoldierFinish(cdInfo_.soldier)
	end
end