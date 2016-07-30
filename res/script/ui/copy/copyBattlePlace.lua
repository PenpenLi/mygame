--
-- ui/copy/copyBattlePlace.lua
-- 副本信息 
--===================================
require "ui/fullScreenFrame"

UI_copyBattlePlace = class("UI_copyBattlePlace", UI)

local TEXTBIAS = -60
local STARBIASUP = 75
local STARBIASUPBIAS = 20
local STARINTERVAL = 0
local FIGHT_INTERVER = 0.1
local GIFT_IMAGE = {"copy_14.png", "copy_14.png", "copy_11.png"}
local LOCATE_TYPE = {MOVETO=1,SCROLLTO=2}

--init
function UI_copyBattlePlace:init(groupInfo_)
	-- data
	-- ===============================
	self.curObjImg = nil
	-- 攻击图标数量
	self.attackIconNum = 0

	self.groupInfo = groupInfo_
	cclog_("groupInfo_",groupInfo_)
	-- 副本展示信息
	self.groupShow = hp.gameDataLoader.getInfoBySid("groupShow", self.groupInfo.id)
	self.uiStage = {}

	-- ui data
	self.objectCont = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	-- 创建战场
	self:createBattlePlace()

	self.uiFrame = UI_fullScreenFrame.new(true)
	self.uiFrame:setTopShadePosY(888)
	self.uiFrame:setTitle(groupInfo_.info.title)

	-- addCCNode
	-- ===============================
	self:addChildUI(self.uiFrame)
	self:addCCNode(self.wigetRoot)

	-- 滚动区域设置
	local size_ = self.image:getSize()
	size_.height = size_.height * hp.uiHelper.RA_scaleY
	size_.width = size_.width * hp.uiHelper.RA_scaleX
	self.scrollView:setInnerContainerSize(size_)

	self:registMsg(hp.MSG.COPY_NOTIFY)
	self:registMsg(hp.MSG.SOLDIER_NUM_CHANGE)

	-- 初始显示
	self:initShow()
	-- 定位
	self:locateCurCopy(LOCATE_TYPE.MOVETO)

	self:createAttackIcon()

	-- 和新手指引界面绑定
	self:registMsg(hp.MSG.GUIDE_STEP)
	local function bindGuideUI(step)
		if step==7005 then
			player.guide.bind2Node(step, self.curObjImg, self.onObjectTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
end

function UI_copyBattlePlace:initCallBack()
	local function onObjectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/copy/copyInfo"
			ui_ = UI_copyInfo.new(self.groupInfo.copies[sender:getTag()])
			self:addModalUI(ui_)
			player.guide.stepEx({7005})
		end
	end

	local function onGetRewardTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()
			if self.groupInfo.gift[tag_] == 1 then
				self:showLoading(player.copyManager.httpReqGetTreasure(self.groupInfo.id, tag_), sender)
			end
		end
	end

	local function onEnergyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/item/energyItem"
			local ui = UI_energyItem.new()
			self:addUI(ui)
		end
	end

	self.onObjectTouched = onObjectTouched
	self.onGetRewardTouched = onGetRewardTouched
	self.onEnergyTouched = onEnergyTouched
end

function UI_copyBattlePlace:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "copyBattleSpace.json")
	local content = self.wigetRoot:getChildByName("Panel_3")

	self.scrollView = self.wigetRoot:getChildByName("ScrollView_6")
	self.item = self.scrollView:getChildByName("Panel_9"):clone()
	self.item:retain()
	self.scrollMap = self.scrollView:getChildByName("Panel_9"):getChildByName("Panel_11")

	-- 体力
	self.energyImg = content:getChildByName("Image_167")
	self.energyImg:addTouchEventListener(self.onEnergyTouched)	
	self.uiEnerge = self.energyImg:getChildByName("Label_169")

	-- 驻军战力
	self.uiPower = content:getChildByName("Label_18")

	-- -- 宝箱
	-- self.gift = content:getChildByName("Image_170")
	-- self.gift:addTouchEventListener(self.onGetRewardTouched)
	-- self.starTotal = content:getChildByName("Image_171"):getChildByName("Label_172")
	-- -- 发光	
	-- local x_, y_ = self.gift:getPosition()
	-- self.light = outLight2(config.dirUI.common.."copy_7.png")
	-- self.light:setPosition(x_, y_)
	-- content:addChild(self.light, 0)
	-- self.light:setVisible(false)

	self.touchHintBg = self.wigetRoot:getChildByName("Panel_48")
	self.touchHint = self.wigetRoot:getChildByName("Panel_52"):getChildByName("Label_4")
	self.touchHint:setString(hp.lang.getStrByID(5379))

	-- 进度条
	self.uiLoadingBar = content:getChildByName("ImageView_1644"):clone()
	self.uiLoadingBar:setVisible(true)
	self.uiLoadingBar:retain()	
end

function UI_copyBattlePlace:createBattlePlace()
	-- 创建图片
	local image_ = ccui.ImageView:create(config.dirUI.copyBack..self.groupShow.image)
	self.image = image_
	image_:setAnchorPoint(cc.p(0, 0))

	-- 添加图片
	self.scrollView:getChildByName("Panel_9"):getChildByName("Panel_10"):addChild(image_)

	-- 创建关卡
	local function createStage(copyInfo_)
		local layer_ = ccui.Layout:create()
		layer_:setName(tostring(copyInfo_.id))
		self.objectCont[copyInfo_.id] = layer_
		-- 关卡
		local image_ = ccui.ImageView:create(config.dirUI.copy..copyInfo_.info.image)
		image_:setName("object")
		image_:setTouchEnabled(true)
		layer_:addChild(image_)
		-- 关卡点击
		image_:setTag(copyInfo_.id)
		image_:addTouchEventListener(self.onObjectTouched)

		-- 星星
		local star_ = ccui.ImageView:create(config.dirUI.common.."copy_13.png")
		local size_ = star_:getSize()
		star_:setPosition(-size_.width - STARINTERVAL, STARBIASUP - STARBIASUPBIAS)
		star_:setTouchEnabled(false)
		star_:setName("star1")
		layer_:addChild(star_)

		local star_ = ccui.ImageView:create(config.dirUI.common.."copy_13.png")
		star_:setPosition(0, STARBIASUP)
		star_:setTouchEnabled(false)
		star_:setName("star2")
		layer_:addChild(star_)

		local star_ = ccui.ImageView:create(config.dirUI.common.."copy_13.png")
		star_:setPosition(size_.width + STARINTERVAL, STARBIASUP - STARBIASUPBIAS)
		star_:setTouchEnabled(false)
		star_:setName("star3")
		layer_:addChild(star_)

		-- 名称底框
		local nameBg_ = cc.Sprite:create(config.dirUI.map .. "name_bg.png")
		nameBg_:setPosition(0, TEXTBIAS)
		-- 名称
		local name_ = ccui.Text:create("", "font/main.ttf", 24)
		name_:setFontSize(24)
		name_:setColor(cc.c3b(255, 255, 255))
		name_:setName("name")		
		-- 名称
		name_:setString(copyInfo_.info.name)
		nameBg_:addChild(name_)
		layer_:addChild(nameBg_)

		nameBg_:setTextureRect(cc.rect(0, 0, name_:getSize().width+20, 28))
		name_:setPosition(nameBg_:getContentSize().width/2, nameBg_:getContentSize().height/2)	

		-- 战力进度条
		local loadingBar_ = self.uiLoadingBar:clone()
		loadingBar_:setPosition(0, STARBIASUP / 3)
		local loading_ = loadingBar_:getChildByName("LoadingBar_1640")
		local power_ = copyInfo_.remainPower
		if power_ == -1 then
			power_ = copyInfo_.power
		end
		local per_ = power_ / copyInfo_.power * 100
		loading_:setPercent(per_)
		loading_:getChildByName("Label_28"):setString(string.format("%.1f%%", per_))
		layer_:addChild(loadingBar_)
		if copyInfo_.attackTimes == 0 then
			loadingBar_:setVisible(false)
		end

		return layer_
	end

	-- 添加关卡信息
	for k, v in pairs(self.groupInfo.copies) do
		-- 关卡数
		local stage_ = k - self.groupInfo.id * 100
		local ssss = "stage"..stage_
		cclog_("ssssssssssssssss",k, self.groupInfo.id, ssss)
		local pos_ = self.groupShow["stage"..stage_]
		local content_ = createStage(v)

		self.scrollMap:addChild(content_)
		content_:setPosition(pos_[1], pos_[2])
		self.uiStage[k] = content_
	end

	-- 初始化连线
	-- for k, v in pairs(self.groupInfo.copies) do
	-- 	for i, w in ipairs(v.info.nextSid) do
	-- 		if w ~= -1 then
	-- 			local startX_, startY_ = self.objectCont[k]:getPosition()
	-- 			local endX_, endY_ = self.objectCont[w]:getPosition()

	-- 			-- 创建箭头
	-- 			local arrow_ = ccui.ImageView:create(config.dirUI.root.."arrow.png")
	-- 			arrow_:setName(k.."t"..w)
	-- 			arrow_:setTouchEnabled(false)

	-- 			-- 添加
	-- 			self.scrollMap:addChild(arrow_)

	-- 			-- 位置设置
	-- 			arrow_:setPosition((startX_ + endX_) / 2, (startY_ + endY_) / 2)

	-- 			-- 设置角度
	-- 			local vector_ = {endX_ - startX_, endY_ - startY_}
	-- 			-- 大小
	-- 			local angle_ = math.deg(math.acos((vector_[1] / math.sqrt(math.pow(vector_[1], 2) + math.pow(vector_[2], 2)))))
	-- 			-- 方向
	-- 			if vector_[2] > 0 then
	-- 				angle_ = -angle_
	-- 			end
				
	-- 			arrow_:setRotation(angle_)
	-- 			arrow_:setVisible(false)
	-- 		end
	-- 	end
	-- end
end

function UI_copyBattlePlace:updateTreasure()
	do return end
	if self.groupInfo ~= nil then
		local index_ = player.copyManager.getCurGiftIndex(self.groupInfo)
		local state_ = self.groupInfo.gift[index_]
		self.gift:setTag(index_)
		self.light:setVisible(false)

		if state_ ~= 1 then
			self.gift:setTouchEnabled(false)
		else
			self.gift:setTouchEnabled(true)
		end
		self.gift:loadTexture(config.dirUI.common..GIFT_IMAGE[state_ + 1])
		if state_ == 1 then
			self.light:setVisible(true)
		end

		-- 更新星星
		self:updateTopStar()
	else
		cclog_("holly fucking")
	end
end

-- 更新箱子状态
function UI_copyBattlePlace:updateTreasureByIndex(index_)
	do return end
	local state_ = self.groupInfo.gift[index_]
	self.gift[index_]:removeAllChildren()
	if state_ == 0 then
		self.gift[index_]:loadTexture(config.dirUI.common.."copy_22.png")
	elseif state_ == 1 then
		self.gift[index_]:loadTexture(config.dirUI.common.."copy_22.png")
		local shine_ = cc.Sprite:create(config.dirUI.common.."copy_6.png")
		local size_ = self.gift[index_]:getSize()
		self.gift[index_]:addChild(shine_)
		shine_:setPosition(size_.width/2, size_.height/2)
	else
		self.gift[index_]:loadTexture(config.dirUI.common.."copy_23.png")
	end
end

-- 更新顶部星星
function UI_copyBattlePlace:updateTopStar()
	do return end
	-- 星星总数
	local index_ = player.copyManager.getCurGiftIndex(self.groupInfo)
	self.starTotal:setString(self.groupInfo.star.."/"..self.groupInfo.info.giftStar[index_])
end

function UI_copyBattlePlace:initShow()
	for k, v in pairs(self.groupInfo.copies) do
		self:updateStageBySid(k)
	end

	self:updateTreasure()

	self:updateTopStar()

	self:updateBaseInfo()
end

-- 定位到当前副本
function UI_copyBattlePlace:locateCurCopy(type_)
	local copies_ = player.copyManager.getLastCopyInGroup(self.groupInfo.id)
	local copy_ = copies_[1]

	if copy_ == nil then
		return
	end

	local function getFitViewPos()		
		local stage_ = copy_.id - self.groupInfo.id * 100
		local info_ = self.groupShow["stage"..stage_]
		-- 做一次缩放转化
		showInfo_ = {}
		showInfo_[1] = info_[1] * hp.uiHelper.RA_scaleX
		showInfo_[2] = info_[2] * hp.uiHelper.RA_scaleY
		cclog_("showInfo_",showInfo_[1],showInfo_[2])
		-- 可视尺寸
		local viewSize_ = self.scrollView:getSize()		
		cclog_("viewSize_",viewSize_.width,viewSize_.height)
		-- 滚动范围
		local scrollSize_ = self.scrollView:getInnerContainerSize()
		cclog_("scrollSize_",scrollSize_.width,scrollSize_.height)
		-- 城池尺寸
		local citySize_ = self.uiStage[copy_.id]:getChildByName("object"):getSize()
		cclog_("citySize_",citySize_.width,citySize_.height)
		-- 要显示完全城池的坐标限制
		local limit_ = {x={down={},up={}},y={down={},up={}}}
		table.insert(limit_.x.down, citySize_.width/2 - showInfo_[1])
		table.insert(limit_.y.down, citySize_.height/2 - showInfo_[2])
		table.insert(limit_.x.up, viewSize_.width - showInfo_[1] - citySize_.width/2)
		table.insert(limit_.y.up, viewSize_.height - showInfo_[2] - citySize_.height/2)

		-- 地图不超出范围受限制
		table.insert(limit_.x.down, viewSize_.width - scrollSize_.width)
		table.insert(limit_.y.down, viewSize_.height - scrollSize_.height)
		table.insert(limit_.x.up, 0)
		table.insert(limit_.y.up, 0)

		local xDown_ = hp.common.getMaxNumber(limit_.x.down)
		local xUp_ = hp.common.getMinNumber(limit_.x.up)
		local yDown_ = hp.common.getMaxNumber(limit_.y.down)
		local yUp_ = hp.common.getMinNumber(limit_.y.up)
		cclog_("limit",xDown_,xUp_,yDown_,yUp_)

		-- 取个平均值
		local x_ = (xDown_ + xUp_) / 2
		local y_ = (yDown_ + yUp_) / 2
		return x_, y_
	end

	-- 定位副本
	local x_, y_ = getFitViewPos()
	cclog_("x_,y_",x_,y_)
	local inner_ = self.scrollView:getInnerContainer()

	-- 全部都通关则只处理MOVETO
	cclog_("--locateCurCopycopy_.star", copy_.star)
	inner_:stopAllActions()
	if copy_.star > 0 then
		if type_ == LOCATE_TYPE.MOVETO then
			self.locatePos = {x=x_,y=y_}
			inner_:setPosition(x_, y_)
		end
	else
		if type_ == LOCATE_TYPE.MOVETO then
			-- inner_:runAction(cc.MoveTo:create(0.0, cc.p(x_, y_)))
			self.locatePos = {x=x_,y=y_}
			inner_:setPosition(x_, y_)
		elseif type_ == LOCATE_TYPE.SCROLLTO then
			self.scrollView:setDirection(0)
			local function onActionOver()
				self.scrollView:setDirection(3)
			end

			inner_:runAction(cc.Sequence:create(cc.MoveTo:create(1.0, cc.p(x_, y_)), cc.CallFunc:create(onActionOver)))
		end
		-- 设置箭头
		local x_, y_ = self.uiStage[copy_.id]:getPosition()
		local objImg = self.uiStage[copy_.id]:getChildByName("object")
		local size_ = objImg:getSize()
		self.curObjImg = objImg
		-- self.arrow:setPosition(x_,y_ + size_.height/2)
	end
end

function UI_copyBattlePlace:updateStageBySid(sid_)
	-- 星星
	self:updateStar(sid_)

	-- 连线
	self:updateLine(sid_)
end

function UI_copyBattlePlace:updateLine(sid_)
	do
	return
end
	-- 副本信息
	local copyInfo_ = self.groupInfo.copies[sid_]

	local copyCont_ = self.scrollMap:getChildByName(tostring(sid_))

	-- 连线
	-- 打了到打了-实线，打了到没打-虚线，到没有开通的-无线
	for j, w in ipairs(copyInfo_.info.nextSid) do
		if w ~= -1 then
			local arrow_ = self.scrollMap:getChildByName(sid_.."t"..w)
			cclog_(sid_.."t"..w, self.groupInfo.copies[w].open)
			if self.groupInfo.copies[w].open == true then
				arrow_:setVisible(true)
				if self.groupInfo.copies[w].star == 0 then
					arrow_:loadTexture(config.dirUI.root.."arrow.png")
				else
					arrow_:loadTexture(config.dirUI.root.."arrowAct.png")
				end
			else
				-- self.scrollMap:getChildByName(sid_.."t"..w):setVisible(false)
			end
		end
	end
end

function UI_copyBattlePlace:updateStar(sid_)
	-- 副本信息
	local copyInfo_ = self.groupInfo.copies[sid_]

	local copyCont_ = self.scrollMap:getChildByName(tostring(sid_))

	-- 星星
	if copyInfo_.star == 0 then
		for i = 1, 3 do
			copyCont_:getChildByName("star"..i):setVisible(false)
		end
	else
		for i = 1, 3 do
			local star_ = copyCont_:getChildByName("star"..i)
			star_:setVisible(true)
			if i <= copyInfo_.star then				
				star_:loadTexture(config.dirUI.common.."star.png")
			end
		end
	end
end

-- 开启关卡
function UI_copyBattlePlace:openStage(sid_)
	-- 副本信息
	-- local copyInfo_ = self.groupInfo.copies[sid_]

	-- 设置关卡信息
	-- self:updateStageBySid(sid_, false)

	-- -- 设置前置连线
	-- for i, v in ipairs(copyInfo_.info.preSid) do
	-- 	cclog_("preSid",v)
	-- 	self:updateLine(v)
	-- end
end

function UI_copyBattlePlace:finishStage(sid_)
	-- 副本信息
	local copyInfo_ = self.groupInfo.copies[sid_]

	-- 设置前置连线
	for i, v in ipairs(copyInfo_.info.preSid) do
		if v ~= -1 then
			self:updateLine(v)
		end
	end

	-- 更新关卡信息
	self:updateStageBySid(sid_)
end

function UI_copyBattlePlace:updateBaseInfo()
	self.uiEnerge:setString(player.getEnerge().."/"..100)

	self.uiPower:setString(string.format(hp.lang.getStrByID(5232), player.soldierManager.getTotalArmy():getPower()))
end

function UI_copyBattlePlace:updatePower(sid_)
	local copyCont_ = self.scrollMap:getChildByName(tostring(sid_))
	local copyInfo_ = self.groupInfo.copies[sid_]

	if copyCont_ == nil or copyInfo_ == nil then
		return
	end

	local loadCont_ = copyCont_:getChildByName("ImageView_1644")

	local loading_ = loadCont_:getChildByName("LoadingBar_1640")
	local power_ = copyInfo_.remainPower
	if power_ == -1 then
		power_ = copyInfo_.power
	end
	local per_ = power_ / copyInfo_.power * 100
	loading_:setPercent(per_)
	loading_:getChildByName("Label_28"):setString(string.format("%.1f%%", per_))
	if copyInfo_.attackTimes == 0 then
		loadCont_:setVisible(false)
	else
		loadCont_:setVisible(true)
	end
end

function UI_copyBattlePlace:onMsg(msg_, param_)
	cclog_("msg_", msg_)
	if msg_ == hp.MSG.COPY_NOTIFY then
		if param_.msgType == 1 then
			cclog_("param_", param_.id)
			-- 副本开启
			self:openStage(param_.id)			
		elseif param_.msgType == 2 then
			cclog_("param_", param_.id)
			-- 星级变化
			self:updateTopStar()
			-- self:updateStar(param_.id)
		elseif param_.msgType == 3 then
			cclog_("param_", param_.id)
			self:finishStage(param_.id)
			self:locateCurCopy(LOCATE_TYPE.SCROLLTO)
			self:createAttackIcon()
		elseif param_.msgType == 4 then
			-- 领奖成功
			self:updateTreasure(param_.index)
		elseif param_.msgType == 5 then
			self:updateTreasure(param_.index)
		elseif param_.msgType == 6 then
			self:updateBaseInfo()
		elseif param_.msgType == 7 then
			self:goToNextCopyGroup()
		elseif param_.msgType == 8 then
			self:updatePower(param_.id)
		end
	elseif msg_ == hp.MSG.SOLDIER_NUM_CHANGE then
		if param_ == 1 then
			self:updateBaseInfo()
		end
	elseif msg_==hp.MSG.GUIDE_STEP then
	-- 新手指引
		self.bindGuideUI(param_)
	end
end

function UI_copyBattlePlace:goToNextCopyGroup()
	local groupInfo_ = player.copyManager.getCopyGroup(self.groupInfo.info.nextSid)
	if groupInfo_ == nil then
		return
	end
	self.groupInfo = groupInfo_
	-- 副本展示信息
	self.groupShow = hp.gameDataLoader.getInfoBySid("groupShow", self.groupInfo.id)
	self.uiStage = {}

	-- 副本名称
	self.uiFrame:setTitle(groupInfo_.info.title)
	
	-- ui data
	self.objectCont = {}

	-- 清空
	self.scrollView:removeAllChildren()

	-- 创建新的节点
	local item_ = self.item:clone()
	self.scrollMap = item_:getChildByName("Panel_11")
	self.scrollView:addChild(item_)
	self:createBattlePlace()
	hp.uiHelper.uiAdaption(item_)

	-- 滚动区域设置
	local size_ = self.image:getSize()
	size_.height = size_.height * hp.uiHelper.RA_scaleY
	size_.width = size_.width * hp.uiHelper.RA_scaleX
	self.scrollView:setInnerContainerSize(size_)

	-- 初始显示
	self:initShow()
	-- 定位
	self:locateCurCopy(LOCATE_TYPE.MOVETO)

	self:createAttackIcon()
end

-- 创建进攻图标
function UI_copyBattlePlace:createAttackIcon()
	-- 清空
	for i = 1, self.attackIconNum do
		local child_ = self.scrollMap:getChildByTag(10000+i)
		self.scrollMap:removeChild(child_)
	end

	local copies_ = player.copyManager.getLastCopyInGroup(self.groupInfo.id)
	for i, v in ipairs(copies_) do
		-- 指向箭头
		local arrow = hp.sequenceAniHelper.createAnimSprite("copy", "fightBig", 11, FIGHT_INTERVER)
		-- 缩放
		cclog_("self.scrollMap",hp.uiHelper.RA_scaleX,hp.uiHelper.RA_scaleY)
		arrow:setScale(hp.uiHelper.RA_scale)
		arrow:setTag(10000+i)
		self.scrollMap:addChild(arrow)

		local x_, y_ = self.uiStage[v.id]:getPosition()
		local objImg = self.uiStage[v.id]:getChildByName("object")
		local size_ = objImg:getSize()
		arrow:setPosition(x_,y_ + size_.height * hp.uiHelper.RA_scale/2)
	end
	self.attackIconNum = table.getn(copies_)
end

-- onRemove
function UI_copyBattlePlace:onRemove()
	self.item:release()
	self.uiLoadingBar:release()
	self.super.onRemove(self)
end

function UI_copyBattlePlace:onAdd(parent_)
	self.super.onAdd(self, parent_)
	local inner_ = self.scrollView:getInnerContainer()
	inner_:stopAllActions()
	if self.locatePos == nil then
		return
	end
	inner_:setPosition(self.locatePos.x, self.locatePos.y)
end