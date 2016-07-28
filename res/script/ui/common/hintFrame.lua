--
-- ui/common/hintFrame.lua
-- 信息提示框
--===================================
require "ui/UI"

UI_hintFrame = class("UI_hintFrame", UI)

local SPACING = 5
local widgetName = {"Image_6", "Image_20", "Label_7", "Label_7_0"}

--init
function UI_hintFrame:init()
	-- data
	-- ===============================

	-- ui
	-- ===============================
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "hintFrame.json")
	self.content = self.wigetRoot:getChildByName("Panel_4")

	-- addCCNode
	-- ===============================

	hp.uiHelper.uiAdaption(self.wigetRoot)
	self.x, self.y = self.wigetRoot:getPosition()
	local back_ = self.wigetRoot:getChildByName("Panel_2")

	self.component = {}
	for i = 1, 9 do
		self.component[i] = back_:getChildByName(tostring(i))
	end	

	for i, v in ipairs(widgetName) do
		self.component[i + 9] = self.content:getChildByName(v)
	end

	self.opacity = {}
	for i, v in ipairs(self.component) do
		self.opacity[i] = v:getOpacity()
	end
end

function UI_hintFrame:setInfo(param_)
	print(param_[1])
	local hintInfo_ = hp.gameDataLoader.getInfoBySid("hintFrame", param_[1])
	if hintInfo_ == nil then
		return false
	else
		print("what is the matter")
	end

	if hintInfo_.image ~= nil then
		self.component[10]:setVisible(true)
		self.component[11]:setVisible(true)
		self.component[11]:loadTexture(hintInfo_.image)
	else
		self.component[10]:setVisible(false)
		self.component[11]:setVisible(false)
	end
	self.component[12]:setString(hintInfo_.title)
	table.remove(param_, 1)
	self.component[13]:setString(string.format(hintInfo_.text, unpack(param_)))
	return true
end

function UI_hintFrame:pop(callBack_)
	print("popHintFrame")
	local x_, y_ = self.wigetRoot:getPosition()
	local trigOver_ = false
	-- call back
	local function onActionOver()
		if trigOver_ == true then
			print("not possible")
			return
		end
		trigOver_ = true
		self.wigetRoot:setVisible(false)
		self.wigetRoot:stopAllActions()
		for i, v in ipairs(self.component) do
			v:stopAllActions()
		end
		if callBack_ ~= nil then
			callBack_()
		end
	end

	local function playerAnimation()
		local delay_ = cc.DelayTime:create(2)
		local fadeOut_ = cc.FadeOut:create(1)
		for i, v in ipairs(self.component) do
			v:runAction(cc.Sequence:create(delay_:clone(), fadeOut_:clone(), cc.CallFunc:create(onActionOver)))
		end
	end

	self.wigetRoot:setVisible(true)
	-- 透明度还原
	for i, v in ipairs(self.component) do
		v:setOpacity(self.opacity[i])
	end
	-- 位置还原
	self.wigetRoot:setPosition(self.x, self.y)
	playerAnimation()
end

function UI_hintFrame:moveUp(pos_)
	local x_, y_ = self.wigetRoot:getPosition()
	local sz_ = self.wigetRoot:getSize()
	local newY_ = sz_.height + SPACING + y_
	self.wigetRoot:runAction(cc.MoveTo:create(1, cc.p(x_, newY_)))
end