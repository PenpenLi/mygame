--
-- file: dataMgr/guide.lua
-- desc: 新手指引
--================================================
require "ui/guide/guideDlg"
require "ui/guide/guideOper"
require "ui/guide/noviceGift"


-- 对象
-- ================================
-- ********************************
local guide = {}


-- 私有数据
-- ================================
-- ********************************
local guideIndex = 1
local guideStep = 0
local guideInfo = nil
local finishFlag = false
local getGiftFlag = false

local guideUI = nil


-- 私有函数
-- ================================
-- ********************************
-- checkGuideInfo
-- 检查当前指引是否可以进行
local function checkCurGuide()
	-- if guideInfo.step==2005 or guideInfo.step==3005 or guideInfo.step==7005 then
	-- 	if cdBox.getCD(cdBox.CDTYPE.BUILD)<=0 then
	-- 		return false
	-- 	end
	-- end

	return true
end


local function onHttpResponse(status, response, tag)
	if status==200 then
		local data = hp.httpParse(response)
		if data.result~=nil and data.result==0 then
		end
	end
end
-- 
-- 向服务器发送引导成功
local function httpStep(step)
	local cmdData={operation={}}
	local oper = {}
	oper.channel = 20
	oper.type = 1
	oper.sid = step
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)

	-- 记录到本地
	cc.UserDefault:getInstance():setIntegerForKey("guideStep", step)
	cc.UserDefault:getInstance():flush()
end


-- startCurGuide
-- 开始当前指引、展示指引界面
local function startCurGuide()
	if guideInfo.type==1 then
		guideUI = UI_guideDlg.new(guideInfo)
	else
		guideUI = UI_guideOper.new(guideInfo)
	end
	game.curScene:addModalUI(guideUI, 100)

	-- 发消息通知
	hp.msgCenter.sendMsg(hp.MSG.GUIDE_STEP, guideInfo.step)
end

-- finishCurGuide
-- 完成当前指引、关闭指引界面
local function finishCurGuide()
	if guideUI~=nil then
		game.curScene:removeModalUI(guideUI)
		guideUI = nil
	end

	if guideInfo~=nil and guideInfo.setpFinish~=-1 then
		httpStep(guideInfo.setpFinish)
	end
end


-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function guide.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function guide.init()
	guideStep = cc.UserDefault:getInstance():getIntegerForKey("guideStep", 0)
	guideIndex = 1
	finishFlag = false
	getGiftFlag = false
	guideInfo = game.data.guide[guideIndex]
end

-- initData
-- 使用玩家登陆数据进行初始化
function guide.initData(data_)
	local stepData = data_.guide
	local giftData = data_.nAward

	local step = guideStep
	stepData = stepData or 0
	if stepData==0 or stepData>guideStep then
		step = stepData
	end
	if giftData and giftData>=1 then
		getGiftFlag = true
		finishFlag = true
		return
	end
	
	if step==0 then
		return
	end

	for i, v in ipairs(game.data.guide) do
		if step==v.step then
			guideIndex = i+1
			guideInfo = game.data.guide[guideIndex]
			
			if guideInfo==nil then
				finishFlag = true
			end
			return
		end
	end

	finishFlag = true
	return
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function guide.syncData(data_)
	-- body
end

-- heartbeat
-- 心跳操作
function guide.heartbeat(dt_)
	-- body
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

-- isFinished
-- 新手指引是否已经完成
function guide.isFinished()
	return finishFlag
end

-- run
-- 运行引导
function guide.run()
	if finishFlag or guideInfo==nil then
	-- 指引已完成
		guide.checkGetGift()
		return
	end

	if guideInfo.step<2010 and player.buildingMgr.getBuildingNumBySid(1002)>0 then
	-- 已经建造了农田，跳过
		guide.initData({guide=3001})
	end

	if guideInfo.step<4008 and player.buildingMgr.getBuildingNumBySid(1009)>0 then
	-- 已经建造了农田，跳过
		guide.initData({guide=4008})
	end

	if guideInfo.step==6001 then
	-- 训练士兵，判断训练是否结束
		if cdBox.getCD(cdBox.CDTYPE.BRANCH)>0 then
			game.curScene:removeAllModalUI()
			game.curScene:removeAllUI()
			game.curScene:getBuildingBySid(1009):onClicked()
		else
			 guide.initData({guide=6001})
		end
	end

	if checkCurGuide() then
	-- 如果当前指引可以进行，显示指引界面
		startCurGuide()
	else
	-- 如果当前指引不可以进行，完成当前指引，进入指引的下一步
		finishCurGuide()
		guide.step(guideInfo.step)
	end
end

-- step
-- 导航进入下一步
function guide.step(step_)
	if finishFlag or guideInfo==nil then
		return -1
	end
	
	if step_~=guideInfo.step then
		return 0
	end

	-- 
	finishCurGuide()

	-- 选取下一步指引
	for i=guideIndex+1, #game.data.guide do
		guideIndex = i
		guideInfo = game.data.guide[guideIndex]

		if checkCurGuide() then
			startCurGuide()
			return guideInfo.step
		else
			finishCurGuide()
		end
	end

	finishFlag = true
	guideInfo = nil
	guide.checkGetGift()
	hp.msgCenter.sendMsg(hp.MSG.GUIDE_OVER)
	return -1
end

-- stepEx
-- 当前指引步骤如果在steps_表中，进入下一步, 
function guide.stepEx(steps_)
	if finishFlag or guideInfo==nil then
		return -1
	end
	for i, v in ipairs(steps_) do
		if v==guideInfo.step then
			return guide.step(v)
		end
	end

	return false
end

-- pause
-- 暂停引导
function guide.finishCurStep()
	if finishFlag or guideInfo==nil then
		return false
	end

	finishCurGuide()
end

-- bind2Node
-- 把引导和一个节点绑定
function guide.bind2Node(step_, ccNode_, nodeTouchedFun_)
	if finishFlag or guideInfo==nil or step_~=guideInfo.step then
		return false
	end

	if guideUI~=nil then
		guideUI:onBind2Node(ccNode_, nodeTouchedFun_)
		return true
	end

	return false
end

-- bind2Node111
-- 把引导和一个节点绑定
function guide.bind2Node111(step_, ccNode_, nodeTouchedFun_)
	-- if finishFlag or guideInfo==nil or step_~=guideInfo.step then
	-- 	return false
	-- end

	-- if guideUI~=nil then
	-- 	guideUI:onBind2Node(ccNode_, nodeTouchedFun_)
	-- 	return true
	-- end

	return false
end


-- bind2NodeEx
-- 把引导和一个节点绑定, 只要当前指引步骤在steps_表中就进行绑定
function guide.bind2NodeEx(steps_, ccNode_, nodeTouchedFun_)
	if finishFlag or guideInfo==nil then
		return false
	end

	for i, v in ipairs(steps_) do
		if v==guideInfo.step then
			return guide.bind2Node(v, ccNode_, nodeTouchedFun_)
		end
	end

	return false
end

--
function guide.getUI()
	return guideUI
end

-- 检查领取新手奖励
-- checkGetGift
function guide.checkGetGift()
	if finishFlag and not getGiftFlag then
	-- 如果完成指引，但没有领取奖励，弹出领取新手奖励界面
		guideUI = UI_noviceGift.new()
		game.curScene:addModalUI(guideUI, 100)
	end
end

-- 获取奖励
-- getGift
function guide.getGift()
	getGiftFlag = true
end

return guide