--
-- file: playerData/guide.lua
-- desc: 新手指引
--================================================
require "ui/guide/guideDlg"
require "ui/guide/guideOper"

local guide = {}

-- private data
-- ==========================
local guidIndex = 1
local guideInfo = nil
local finishFlag = false

local guideUI = nil

-- private function
-- ==========================
-- checkGuideInfo
-- 检查当前指引是否可以进行
local function checkCurGuide()
	if guideInfo.step==2005 or guideInfo.step==3005 or guideInfo.step==7005 then
		if cdBox.getCD(cdBox.CDTYPE.BUILD)<=0 then
			return false
		end
	end

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

-- public function
-- ==========================
-- init
-- 初始化
function guide.init()
	guidIndex = 1
	finishFlag = false
	guideInfo = game.data.guide[guidIndex]
end

-- initByData
-- 用网络数据初始化
function guide.initByData(data_)
	local step = data_
	if step==0 then
		return
	end

	for i, v in ipairs(game.data.guide) do
		if step==v.step then
			guidIndex = i+1
			guideInfo = game.data.guide[guidIndex]
			if guideInfo==nil then
				finishFlag = true
			end
			return
		end
	end

	finishFlag = true
	return
end

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
		return
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
	for i=guidIndex+1, #game.data.guide do
		guidIndex = i
		guideInfo = game.data.guide[guidIndex]

		if checkCurGuide() then
			startCurGuide()
			return guideInfo.step
		else
			finishCurGuide()
		end
	end

	finishFlag = true
	guideInfo = nil
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

return guide