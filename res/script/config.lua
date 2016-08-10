--
-- config.lua
--
--================================================

config = config or {}


config.debug = 2 --0, 1, 2
DEBUG = config.debug;

config.versionCode = 3
config.baseVersion = "1.2"
config.version = "1.2.0"
config.checkUpdate = true --是否检查更新
config.forceUpdate = false --强制更新


-- server
------------------------------------
config.server =
{
	timeout = 10.0,
	
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
	font        =    "ui/font/", --艺术字体
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
	unionGift	=	 "ui/unionGift/", --联盟礼包
	bossHead	=	 "ui/bossHead/",	-- 世界boss
	animation	=	 "ui/animation/",	-- 动画
	animationPng	=	 "ui/animationPng/",	-- 整个图片动画
	copyBack	=	 "ui/copyBack/",	-- 副本背景图
	quest		=	 "ui/quest/",	-- 任务图标
	copy 		=	 "ui/copy/",	-- 副本建筑
	battleBg 	=	 "ui/battleBg/",	-- 副本战斗背景
	particle 	=	 "ui/particle/",	-- 粒子系统
	effect		=    "ui/effect/",		-- 效果
	title		=    "ui/title/",		-- 头衔	
	cityElement =    "ui/cityElement/",	-- 城内的装饰元素
	fortress    =    "ui/fortress/", --要塞图片
	world 		=	 "ui/world/",		-- 世界地图
}


-- time interval
------------------------------------
config.interval =
{
	--
	gameHeartbeat = 0.2,
	playerHeartbeat = 0.5,
	sceneHeartbeat = 0.2,
	uiHeartbeat = 0.2,
	objHeartbeat = 0.5,
	
	bufferCmdSync = 5.0,

	chatRoomSync = 5.0, --聊天同步
}



-- 暗红 #FF240102
-- 红色 #FFDE0408
-- 蓝色 #FF5AE0E8
-- 绿色 #FF0D3B04
-- 黄色 #FFEFF008


-- 白色 #FFF5F1DF
-- 红色 #FFF44242
-- 黄色 #FFFFB555

-- 加灰色 #

-- #FF00FFFF

-- cocos compile -p android -j 4 -m release --ap 19
-- cocos compile -p android -j 4 -m debug --ap 19
