--
-- file: obj/hintFrameMgr.lua
-- desc: 提示信息弹出框
--================================================

-- 全局数据
-- ==================

-- obj
-- ==================
local hintFrameMgr = {}
local index = 1

-- 本地数据
-- ==================
hintFrameMgr.hintFrameInfoList = {}
hintFrameMgr.popedHintFrame = {}
hintFrameMgr.hintFrames = {}

local function popNextHintFrame()
	while hintFrameMgr.hintFrameInfoList[1] ~= nil do
		if table.getn(hintFrameMgr.hintFrames) > 0 then
			local function popHintFrameOver()
				table.insert(hintFrameMgr.hintFrames, hintFrameMgr.popedHintFrame[1])
				table.remove(hintFrameMgr.popedHintFrame, 1)
				popNextHintFrame()
			end			
			local ui_ = hintFrameMgr.hintFrames[1]			
			if ui_:setInfo(hintFrameMgr.hintFrameInfoList[1]) then
				for i, v in ipairs(hintFrameMgr.popedHintFrame) do
					v:moveUp(pos_)
				end
				ui_:pop(popHintFrameOver)
				table.insert(hintFrameMgr.popedHintFrame, ui_)
				table.remove(hintFrameMgr.hintFrames, 1)
			end
			table.remove(hintFrameMgr.hintFrameInfoList, 1)
		else
			break
		end		
	end	
end

-- 全局方法
-- ==================
function hintFrameMgr.popHintFrame(param_)
	table.insert(hintFrameMgr.hintFrameInfoList, param_)
	popNextHintFrame()
end

function hintFrameMgr.attachHintFrame(uis_)
	hintFrameMgr.hintFrames = uis_
	hintFrameMgr.popedHintFrame = {}
end

function hintFrameMgr.detachHintFrame()
end

return hintFrameMgr