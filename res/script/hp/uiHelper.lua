--
-- file: hp/uiHelper.lua
-- desc: ui特殊处理
--===================================


hp.uiHelper = {}


hp.uiHelper.RA_scaleX = 1   --x自适应缩放比例
hp.uiHelper.RA_scaleY = 1   --y自适应缩放比例
hp.uiHelper.RA_scale = 1    -- 自适应缩放比例(取x,y缩放比例的最小)
hp.uiHelper.RA_scaleMax = 1 -- 自适应最大缩放比例(取x, y缩放比例的最大)

-- init
-- 初始化
-------------------------------------------
function hp.uiHelper.init()
	hp.uiHelper.RA_scaleX = game.visibleSize.width/config.resSize.width
	hp.uiHelper.RA_scaleY = game.visibleSize.height/config.resSize.height
	if hp.uiHelper.RA_scaleX<hp.uiHelper.RA_scaleY then
		hp.uiHelper.RA_scale = hp.uiHelper.RA_scaleX
		hp.uiHelper.RA_scaleMax = hp.uiHelper.RA_scaleY
	else
		hp.uiHelper.RA_scale = hp.uiHelper.RA_scaleY
		hp.uiHelper.RA_scaleMax = hp.uiHelper.RA_scaleX
	end

	-- 按钮填充颜色
	hp.uiHelper.btnImgNormalColor = cc.c3b(255, 255, 255)
	hp.uiHelper.btnImgPressedColor = cc.c3b(192, 168, 168)
end

-- uiAdaption
-- ui分辨率自适应
-------------------------------------------
function hp.uiHelper.uiAdaption(uiRootNode_)
	local nodes = uiRootNode_:getChildren()
	local x, y = uiRootNode_:getPosition()
	local sz = uiRootNode_:getSize()
	uiRootNode_:setPosition(x*hp.uiHelper.RA_scaleX, y*hp.uiHelper.RA_scaleY)
	sz.width = sz.width*hp.uiHelper.RA_scaleX
	sz.height = sz.height*hp.uiHelper.RA_scaleY
	uiRootNode_:setSize(sz)
	for i, v in ipairs(nodes) do
		x, y = v:getPosition()
		sz = v:getSize()
		v:setPosition(x*hp.uiHelper.RA_scaleX, y*hp.uiHelper.RA_scaleY)
		sz.width = sz.width*hp.uiHelper.RA_scaleX
		sz.height = sz.height*hp.uiHelper.RA_scaleY
		v:setSize(sz)

		local tag = v:getTag()
		if tag==-99 then
		--框架
			hp.uiHelper.uiFrameAdaption(v)
		elseif tag==-999 then
		-- listview、pageview等
			hp.uiHelper.uiListAdaption(v)
		elseif tag==-998 then
		-- scroll
			hp.uiHelper.uiScrollAdaption(v)
		else
			hp.uiHelper.uiContentAdaption(v)
		end
	end
end

-- uiFrameAdaption
-- 框架分辨率自适应
-------------------------------------------
function hp.uiHelper.uiFrameAdaption(uiNode_)
	local nodes = uiNode_:getChildren()
	for i, v in ipairs(nodes) do
		local x, y = v:getPosition()
		local scaleX = v:getScaleX()
		local scaleY = v:getScaleY()
		v:setPosition(x*hp.uiHelper.RA_scaleX, y*hp.uiHelper.RA_scaleY)

		local tag = v:getTag()
		if tag==-91 then
		-- 水平方向拉伸
			v:setScaleX(scaleX*hp.uiHelper.RA_scaleX)
			v:setScaleY(scaleY*hp.uiHelper.RA_scale)
		elseif tag==-92 then
		-- 垂直方向拉伸
			v:setScaleX(scaleX*hp.uiHelper.RA_scale)
			v:setScaleY(scaleY*hp.uiHelper.RA_scaleY)
		elseif tag==-93 then
		-- 四角不做拉伸
			v:setScale(scaleX*hp.uiHelper.RA_scale)
		-- 旋转后的水平方向拉伸
		elseif tag==-94 then
			v:setScaleX(scaleX*hp.uiHelper.RA_scale)
			v:setScaleY(scaleY*hp.uiHelper.RA_scaleX)
		elseif tag==-99 then
		-- 等比例最大拉伸
			v:setScale(scaleY*hp.uiHelper.RA_scaleMax)
		else
			v:setScaleX(scaleX*hp.uiHelper.RA_scaleX)
			v:setScaleY(scaleY*hp.uiHelper.RA_scaleY)
		end
	end
end

-- uiScrollAdaption
-- 框架分辨率自适应
-------------------------------------------
function hp.uiHelper.uiScrollAdaption(uiScrollItem_)
	local inner_ = uiScrollItem_:getInnerContainer()
	local nodes = inner_:getChildren()
	for i, v in ipairs(nodes) do
		hp.uiHelper.uiAdaption(v)
	end
end

-- uiListAdaption
-- 框架分辨率自适应
-------------------------------------------
function hp.uiHelper.uiListAdaption(uilistItem_)
	local nodes = uilistItem_:getChildren()
	for i, v in ipairs(nodes) do
		hp.uiHelper.uiAdaption(v)
	end
end

-- uiContentAdaption
-- 内容分辨率自适应
-------------------------------------------
function hp.uiHelper.uiContentAdaption(uiNode_)
	local nodes = uiNode_:getChildren()
	for i, v in ipairs(nodes) do
		local x, y = v:getPosition()
		v:setPosition(x*hp.uiHelper.RA_scaleX, y*hp.uiHelper.RA_scaleY)
		if tolua.type(v)=="ccui.Text" and v:isIgnoreContentAdaptWithSize()==false then
		-- 指定了宽高的文本
			-- local sz = v:getTextAreaSize()
			-- local fontSize = v:getFontSize()
			-- sz.width = sz.width*hp.uiHelper.RA_scaleX
			-- sz.height = sz.height*hp.uiHelper.RA_scaleY
			-- v:setSize(sz)
			-- v:setTextAreaSize(sz)
			-- v:setFontSize(math.ceil(fontSize*hp.uiHelper.RA_scale))
			
			local scaleX = v:getScaleX()
			local scaleY = v:getScaleY()
			v:setScaleX(scaleX*hp.uiHelper.RA_scaleX)
			v:setScaleY(scaleY*hp.uiHelper.RA_scale)
		else
			local scaleX = v:getScaleX()
			local scaleY = v:getScaleY()
			v:setScaleX(scaleX*hp.uiHelper.RA_scale)
			v:setScaleY(scaleY*hp.uiHelper.RA_scale)
		end
	end
end

-- btnImgTouched
-- 按钮功能的图片触摸处理
-------------------------------------------
function hp.uiHelper.btnImgTouched(btn_imgNode_, touchType_)
	if touchType_==TOUCH_EVENT_BEGAN then
		btn_imgNode_:setColor(hp.uiHelper.btnImgPressedColor)
	elseif touchType_==TOUCH_EVENT_MOVED then
		if btn_imgNode_:hitTest(btn_imgNode_:getTouchMovePos())==true then
			btn_imgNode_:setColor(hp.uiHelper.btnImgPressedColor)
		else
			btn_imgNode_:setColor(hp.uiHelper.btnImgNormalColor)
		end
	elseif touchType_==TOUCH_EVENT_ENDED then
		cc.SimpleAudioEngine:getInstance():playEffect("sound/button.mp3")
		btn_imgNode_:setColor(hp.uiHelper.btnImgNormalColor)
	else
		btn_imgNode_:setColor(hp.uiHelper.btnImgNormalColor)
	end
end


-- 输入框控件
--===========================================================
-- createEditboxCtrl
-- 创建一个editboxCtrl
function hp.uiHelper.createEditboxCtrl(label_, editbox_, passwdFlag_)
	local editboxCtrl = {}
	editboxCtrl.label = label_
	editboxCtrl.editbox = editbox_
	editboxCtrl.passwdFlag = passwdFlag_
	editboxCtrl.onChanged = nil
	editboxCtrl.maxLen = 0
	editboxCtrl.defText = ""

	-- 设置显示文本
	function editboxCtrl.setLabelString(str)
		if editboxCtrl.passwdFlag then
			editboxCtrl.label:setString(string.rep("*", string.len(str)))
		else
			if game.application:getTargetPlatform()==cc.PLATFORM_OS_IPHONE 
				or game.application:getTargetPlatform()==cc.PLATFORM_OS_IPAD then
			-- iphone & ipad消除不可见字符
				str = string.gsub(str, "\xe2\x80\x86", "")
			end
			editboxCtrl.label:setString(str)
		end
	end
	-- 设置输入框文本
	function editboxCtrl.setStringForShow(str)
		if editboxCtrl.maxLen>0 then
			str = hp.common.utf8_strSub(str, editboxCtrl.maxLen)
		end
		editboxCtrl.setLabelString(str)
	end
	-- 设置输入框文本
	function editboxCtrl.setString(str)
		if editboxCtrl.maxLen>0 then
			str = hp.common.utf8_strSub(str, editboxCtrl.maxLen)
		end
		editboxCtrl.editbox:setText(str)
		if str == "" then
			editboxCtrl.setLabelString(editboxCtrl.defText)
		else
			editboxCtrl.setLabelString(str)
		end

		if editboxCtrl.onChanged~=nil then
			editboxCtrl.onChanged(str)
		end
	end
	-- 获取输入框文本
	function editboxCtrl.getString()
		return editboxCtrl.editbox:getText()
	end
	-- 设置最大文本长度
	function editboxCtrl.setMaxLength(len)
		editboxCtrl.maxLen = len
		editboxCtrl.editbox:setMaxLength(len)
	end
	-- 设置文本变化回调
	function editboxCtrl.setOnChangedHandle(onChangedFun)
		editboxCtrl.onChanged = onChangedFun
	end
	-- 设置默认文本
	function editboxCtrl.setDefaultText(defText_)
		editboxCtrl.defText = defText_
		if editboxCtrl.editbox:getText() == "" then
			editboxCtrl.setLabelString(editboxCtrl.defText)
		end		
	end
	return editboxCtrl
end

-- labelBind2EditBox
-- 将文本框绑定到一个编辑框
-- @label_: 需要绑定的label_
-- @passwdFlag_: 是否为密码
-- @onChanged_: 文本改变时的回调
-- @maxLen_: 为本最大长度
-- 返回：一个editboxCtrl
-------------------------------------------
function hp.uiHelper.labelBind2EditBox(label_, passwdFlag_)
	local editBox = cc.EditBox:create(cc.size(0, 0), cc.Scale9Sprite:create())
	if passwdFlag_ then
		editBox:setInputFlag(0)
		editBox:setInputMode(6)
	end
	editBox:setVisible(false)
 	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
	label_:addChild(editBox)

	local editboxCtrl = hp.uiHelper.createEditboxCtrl(label_, editBox, passwdFlag_)

	--label点击，编辑框响应编辑功能--弹出键盘
	local function onLabelTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			editBox:sendActionsForControlEvents(32)
		end
	end
	label_:setTouchEnabled(true)
	label_:addTouchEventListener(onLabelTouched)

	-- 编辑框编辑事件
	local function editBoxTextEventHandle(strEventName, pSender)
		if strEventName == "changed" then
		-- 刷新显示
			editboxCtrl.setStringForShow(editBox:getText())
		elseif strEventName == "ended" then
		-- 设置内容
			editboxCtrl.setString(editBox:getText())
		end
	end
	editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)

	return editboxCtrl
end

function hp.uiHelper.listViewLoadHelper(listView_, addItemCallBack_, itemHeight_, loadNumOnce_)
	local listViewHelper_ = {}
	listViewHelper_.listView = listView_
	listViewHelper_.callBack = addItemCallBack_
	listViewHelper_.loadNumOnce = loadNumOnce_
	listViewHelper_.finish = false
	listViewHelper_.curIndex = 1
	listViewHelper_.stop = false
	listViewHelper_.itemHeight = itemHeight_

	local function loadItems(num_)
		for i = 1, num_ do
			item_ = addItemCallBack_(listViewHelper_.curIndex)
			if item_ == nil then
				listViewHelper_.finish = true
				break
			else
				listView_:pushBackCustomItem(item_)
				listViewHelper_.curIndex = listViewHelper_.curIndex + 1
			end
		end
	end

	local function onListViewScroll(sender, eventType)
		if eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then
			if listViewHelper_.stop == true then
				return
			end

			if listViewHelper_.finish == false then
				loadItems(loadNumOnce_)
			end
		end
	end

	-- 计算每屏显示个数
	local function calcNumPerScreen()
		local totalHeight_ = listViewHelper_.listView:getSize().height
		local heightPerItem_ = listViewHelper_.itemHeight + listViewHelper_.listView:getItemsMargin()
		if heightPerItem_ == 0 then
			return 0
		end
		return math.ceil(totalHeight_/heightPerItem_)
	end

	function listViewHelper_.stopHelper()
		listViewHelper_.stop = true
	end

	function listViewHelper_.initShow(num_)
		local oneScreenNum_ = 0
		if num_ == nil then
			oneScreenNum_ = calcNumPerScreen()
		else
			oneScreenNum_ = num_
		end
		cclog_("+++oneScreenNum_",oneScreenNum_)
		listViewHelper_.stop = false
		listViewHelper_.finish_ = false
		listViewHelper_.curIndex = 1
		loadItems(oneScreenNum_ + loadNumOnce_)
	end

	listView_:addEventListenerScrollView(onListViewScroll)
	return listViewHelper_
end

function hp.uiHelper.bindRollLabel(label_, parent_, mask_)
	local size_ = mask_:getSize()
	size_.width = size_.width
	-- drawNode
	local node_ = cc.DrawNode:create()
	local points_ = {cc.p(10,0),cc.p(size_.width - 10,0),cc.p(size_.width - 10,size_.height),cc.p(10,size_.height)}
	node_:drawPolygon(points_,4,{255,255,255,255},2,{255,255,255,255})
	-- clipper
	local msgClipper = cc.ClippingNode:create()
	msgClipper:setStencil(node_)
	msgClipper:setAnchorPoint(cc.p(0, 0))
	msgClipper:addChild(label_)
	-- 位置设置
	local x_, y_ = mask_:getPosition()
	msgClipper:setPosition(x_, y_ - size_.height / 2)
	label_:setPosition(0, size_.height / 2)	
	parent_:addChild(msgClipper)

	local rollLabel_ = {}
	rollLabel_.msgClipper = msgClipper
	rollLabel_.label = label_
	rollLabel_.interval = 0
	rollLabel_.isRollEnabled = true
	local x_, y_ = label_:getPosition()
	rollLabel_.p = {x=size_.width, y=y_}
	label_:setPosition(rollLabel_.p.x, rollLabel_.p.y)

	local function roll()
		local size1_ = label_:getSize()
		local size_ = mask_:getSize()
		if rollLabel_.p.x + size1_.width <= 0 then
			rollLabel_.p.x = size_.width
		else
			rollLabel_.p.x = rollLabel_.p.x - hp.uiHelper.RA_scaleX
		end
		label_:setPosition(rollLabel_.p.x, rollLabel_.p.y)
	end

	-- schedule
	local function tickCallBack()
		if rollLabel_.isRollEnabled == false then
			return
		end

		roll()
	end
	msgClipper:scheduleUpdateWithPriorityLua(tickCallBack, 0.1)

	return rollLabel_
end