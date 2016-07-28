--
-- config.lua
--
--================================================


config = config or {}



-- server
------------------------------------
config.server =
{
	domain = "http://123.57.221.218:8681/",
	timeout = 10,
	
	cmdLogin = "action/login",
	cmdCreate = "action/create",
	cmdOper = "action/operation",
	cmdWorld = "action/world",
	cmdHeartbeat = "action/heartbeat",
}


-- resources size
------------------------------------
config.resSize =
{
	width = 640,
	height = 960
}

-- resources dir
------------------------------------
config.dirUI = 
{
	root        =    "ui/",
	common      =    "ui/common/", --通用资源
	building    =    "ui/building/", --建筑
	map         =    "ui/map/", --地图
	soldier     =    "ui/soldier/", --士兵
	trap		=    "ui/trap/", --陷阱
	skill       =    "ui/skill/", --英雄技能
	spSkill     =    "ui/specialSkill/", --英雄特殊技能
	research    =    "ui/research/", --科研
	item        =    "ui/item/", --道具
	material    =    "ui/material/", --材料
	gem         =    "ui/gem/", --宝石
	equip       =    "ui/equip/", --装备
	hero		=	 "ui/hero/", --英雄
	heroHeadpic =	 "ui/heroHeadpic/", --英雄头像
	icon		=	 "ui/unionIcon/", --工会图标
	headPic     =    "ui/headpic/", --玩家头像
	unionGift	=	 "ui/unionGift/", --联盟礼包
	bossHead	=	 "ui/bossHead/",	-- 世界boss
	animation	=	 "ui/animation/",	-- 动画
}


-- time interval
------------------------------------
config.interval =
{
	--
	gameHeartbeat = 0.2,
	playerHeartbeat = 0.5,
	sceneHeartbeat = 0.2,
	uiHeartbeat = 0.5,
	objHeartbeat = 0.5,
	
	bufferCmdSync = 5.0,

	dataSync = 20.0,	--数据同步
	chatRoomSync = 2.0, --聊天同步
}

config.skipGuid = true;



-- 暗红 #FF240102
-- 红色 #FFDE0408
-- 蓝色 #FF5AE0E8
-- 绿色 #FF0D3B04
-- 黄色 #FFEFF008
