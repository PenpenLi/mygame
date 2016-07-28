--
-- file: obj/hintFrameMgr.lua
-- desc: 提示信息弹出框
--================================================
require "ui/common/hintFrame"

-- 全局数据
-- ==================

-- obj
-- ==================
hintFrameMgr = {}

-- 本地数据
-- ==================
local hintFrameInfoList = {}
local popedHintFrame = {}
local hintFrames = {}

local function popNextHintFrame()
	print("hintFrameInfoList",table.getn(hintFrameInfoList))
	while hintFrameInfoList[1] ~= nil do
		if table.getn(hintFrames) > 0 then
			local function popHintFrameOver()
				table.insert(hintFrames, popedHintFrame[1])
				table.remove(popedHintFrame, 1)
				popNextHintFrame()
			end			
			ui_ = hintFrames[1]			
			if ui_:setInfo(hintFrameInfoList[1]) then
				for i, v in ipairs(popedHintFrame) do
					v:moveUp(pos_)
				end
				ui_:pop(popHintFrameOver)
				table.insert(popedHintFrame, ui_)
				table.remove(hintFrames, 1)
			end
			table.remove(hintFrameInfoList, 1)
		else
			break
		end		
	end	
end

-- 全局方法
-- ==================
function hintFrameMgr.popHintFrame(param_)
	table.insert(hintFrameInfoList, param_)
	popNextHintFrame()
end

function hintFrameMgr.attachHintFrame(uis_)
	hintFrames = uis_
	popedHintFrame = {}
end

function hintFrameMgr.detachHintFrame()
end