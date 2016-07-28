--
-- ui/union/itemStarred.lua
-- 求购的道具查看
--===================================
require "ui/frame/popFrame"

UI_itemStarred = class("UI_itemStarred", UI)

--init
function UI_itemStarred:init(shop_)
	-- data
	-- ===============================
	self.shop = shop_
	self.item = hp.gameDataLoader.getInfoBySid("item", self.shop[1])

	-- call back

	-- ui
	self:initUI()

	local popFrame_ = UI_popFrame.new(self.widgetRoot, hp.lang.getStrByID(5067))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame_)
	self:addCCNode(self.widgetRoot)

	self:updateInfo()
end

function UI_itemStarred:updateInfo()
	local content_ = self.widgetRoot:getChildByName("Panel_214_1_0")
	
	if table.getn(self.shop[3]) == 0 then
		content_:getChildByName("Label_3"):setVisible(true)
		content_:getChildByName("Label_5_0"):setVisible(false)
	else
		content_:getChildByName("Label_3"):setVisible(false)
		content_:getChildByName("Label_5_0"):setVisible(true)
		local name_ = ""
		for i, v in ipairs(self.shop[3]) do
			if i == 1 then
				name_ = v
			else
				name_ = name_..","..v
			end
		end
		content_:getChildByName("Label_5_0"):setString(name_)
	end

end

function UI_itemStarred:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "itemStarred.json")
	local content_ = self.widgetRoot:getChildByName("Panel_214_1_0")

	-- 图片
	content_:getChildByName("Image_66_0"):getChildByName("Image_67"):loadTexture(string.format("%s%s.png", config.dirUI.item, tostring(self.shop[1])))
	-- 名称
	content_:getChildByName("Label_219"):setString(self.item.name)
	-- 描述
	content_:getChildByName("Label_219_1"):setString(self.item.desc)

	content_:getChildByName("Label_3"):setString(hp.lang.getStrByID(5065))

	content_:getChildByName("Label_219_0"):setString(hp.lang.getStrByID(5066))	
end