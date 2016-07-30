--
-- file: obj/hintFrameMgr1.lua
-- desc: 提示信息弹出框
--================================================

-- 全局数据
-- ==================

-- obj
-- ==================
local hintFrameMgr1 = {}
local index = 1

-- 本地数据
-- ==================
hintFrameMgr1.hintFrameInfoList = {}
hintFrameMgr1.popedHintFrame = {}
hintFrameMgr1.hintFrames = {}

local function popNextHintFrame()
	while hintFrameMgr1.hintFrameInfoList[1] ~= nil do
		if table.getn(hintFrameMgr1.hintFrames) > 0 then
			local function popHintFrameOver()
				table.insert(hintFrameMgr1.hintFrames, hintFrameMgr1.popedHintFrame[1])
				table.remove(hintFrameMgr1.popedHintFrame, 1)
				popNextHintFrame()
			end			
			local ui_ = hintFrameMgr1.hintFrames[1]			
			if ui_:setInfo(hintFrameMgr1.hintFrameInfoList[1]) then
				for i, v in ipairs(hintFrameMgr1.popedHintFrame) do
					v:moveUp(pos_)
				end
				ui_:pop(popHintFrameOver)
				table.insert(hintFrameMgr1.popedHintFrame, ui_)
				table.remove(hintFrameMgr1.hintFrames, 1)
			end
			table.remove(hintFrameMgr1.hintFrameInfoList, 1)
		else
			break
		end		
	end	
end

-- 全局方法
-- ==================
function hintFrameMgr1.popHintFrame(param_)
	table.insert(hintFrameMgr1.hintFrameInfoList, param_)
	popNextHintFrame()
end

function hintFrameMgr1.attachHintFrame(uis_)
	hintFrameMgr1.hintFrames = uis_
	hintFrameMgr1.popedHintFrame = {}
end

function hintFrameMgr1.detachHintFrame()
end

return hintFrameMgr1