--
-- scene/loading.lua
-- 游戏loading界面(登录或者更新用)
--================================================
require "scene/Scene"


Scene_loading = class("Scene_loading", Scene)

--
-- init
--
function Scene_loading:init(loginInfo_)
	-- 加载json
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "gameLoading.json")
	-- 屏幕适配
	hp.uiHelper.uiAdaption(widget)

	local progressPanel = widget:getChildByName("Panel_progress")
	local progressBg = progressPanel:getChildByName("Image_progressBg")
	local progress = progressBg:getChildByName("ProgressBar_progress")

	local statusInfo = progressPanel:getChildByName("Label_12")
	local versionInfo = progressPanel:getChildByName("Label_version")
	local nextVersion = progressPanel:getChildByName("Label_version_2")


	-- 动画
	require "ui/common/effect"
	local brightTail = brightTail()
	brightTail:setAnchorPoint(cc.p(0.8, 0.25))
	progressBg:getChildByName("Image_10"):addChild(brightTail)

	-- 
	self:addCCNode(widget)

	--
	--==========================================
	-- setLoadingPercent
	-- 设置加载进度
	local loadingPercent = 0
	local progressWidth = progress:getSize().width
	local function setLoadingPercent( percent )
		progress:setPercent(percent)
		brightTail:setPositionX(progressWidth * percent/100)
		loadingPercent = percent
	end
	local function getLoadingPercent()
		return loadingPercent
	end
    self.getLoadingPercent = getLoadingPercent
	self.setLoadingPercent = setLoadingPercent
	setLoadingPercent(0)

    --
    --
    local function enterGame()
        statusInfo:setString(hp.lang.getStrByID(5489))
        self.status = 4
        self.statusChanged = true
        setLoadingPercent(100)
    end
    self.enterGame = enterGame

    --
    -- 开始登录
    local function startLogin()
    	-- 根据登录平台，初始化服务器信息
    	local serverMgr = player.serverMgr
        serverMgr.initBySDKplatform()

        -- 进行服务器登录
        local function onHttpResponse(status, response, tag)
            local data = hp.httpParse(response)
            if data.result == 0 then
                cclog_("login onHttpResponse success", data.haveRole, data.setName)

                if data.serverID ~= nil and data.serverID~=serverMgr.getMyServerID() then
                    -- 登录地址更改
                    serverMgr.setMyServerID(data.serverID)
                    local cmdSender = hp.httpCmdSender.new(onHttpResponse)
                    if data.haveRole == "false" then
                        -- 未创建角色
                        cmdSender:send(hp.httpCmdType.SEND_INTIME, loginInfo_, config.server.cmdCreate)
                    else
                        -- 已创建角色
                        cmdSender:send(hp.httpCmdType.SEND_INTIME, loginInfo_, config.server.cmdLogin)
                    end
                    return
                end

                player.set_h_p_key(data.h_p_key)
                if data.haveRole == "false" then
                    -- 未创建角色
                    local cmdSender = hp.httpCmdSender.new(onHttpResponse)
                    cmdSender:send(hp.httpCmdType.SEND_INTIME, loginInfo_, config.server.cmdCreate)
                    return
                end

                -- 改名一次
                if data.setName ~= nil then
                    require "ui/login/createRole"
                    local ui_ = UI_createRole.new(self, data.setName)
                    game.curScene:addUI(ui_)
                    return
                end

                player.initData(data)
                enterGame()
            else
                -- 失败
                if data.result == -17 then
                    -- 验证失败，需要重新授权
                    cclog_("startLogin, access fail!")
                    game.sdkHelper.logout()
                end
            end
        end

        player.set_h_p_key(nil)
        local cmdSender = hp.httpCmdSender.new(onHttpResponse)
        cmdSender:send(hp.httpCmdType.SEND_INTIME, loginInfo_, config.server.cmdLogin)
    end
    self.startLogin = startLogin


    self.status = 0 -- 0:检查更新 1:开始更新 2:更新完成 3:连接服务器 4:进入游戏
    self.loginFlag = false
    self.statusChanged = true
    self.statusInfo = statusInfo
    self.versionInfo = versionInfo
    self.nextVersion = nextVersion
    --
    gameUpdater.init()
    statusInfo:setString(hp.lang.getStrByID(5484))
    versionInfo:setString(hp.lang.getStrByID(5490)..gameUpdater.getCurVersion())
    if loginInfo_ then
        self.loginFlag = true
    else
    end
end


function Scene_loading:heartbeat(dt_)
    if not self.statusChanged then
    -- 状态没有改变
        if self.status==3 then
            local percent = self.getLoadingPercent()
            if percent<90 then
                percent = percent+2
                self.setLoadingPercent(percent)
            end
        end
        return
    end
    self.statusChanged = false

    if self.status==0 then
    -- 检查更新
        if gameUpdater.checkUpdate() then
        -- 开始更新
            self.status = 1
            self.statusInfo:setString(hp.lang.getStrByID(5486))
        else
        -- 版本已最新，进入服务器
            self.statusInfo:setString(hp.lang.getStrByID(5488))
            self.status = 3
        end
        self.statusChanged = true

        self.setLoadingPercent(10)
        self.versionInfo:setString(hp.lang.getStrByID(5490)..gameUpdater.getCurVersion())
        self.nextVersion:setString(hp.lang.getStrByID(5491)..gameUpdater.getLatestVersion())
        self.nextVersion:setVisible(true)
    elseif self.status==1 then
    -- 开始更新
        local function onUpdate(errCode, status, parm)
            if errCode~=0 or status==2 then
            -- 更新失败 or 版本已最新
                self.statusInfo:setString(hp.lang.getStrByID(5488))
                self.status = 3
                self.statusChanged = true
                return
            end

            if status==4 then
            -- 更新完成
                self.versionInfo:setString(hp.lang.getStrByID(5490)..gameUpdater.getCurVersion())
                self.statusInfo:setString(hp.lang.getStrByID(5487))
                self.status = 2
                self.statusChanged = true
                self.setLoadingPercent(100)
            end

            if status==3 and parm>10 then
                self.setLoadingPercent(parm)
            end
        end
        gameUpdater.run(onUpdate)

    elseif self.status==2 then
    -- 更新完成，重启游戏
        gameUpdater.uninit()
        game.restart()
    elseif self.status==3 then
    -- 开始连接服务器
        gameUpdater.uninit()
        self.startLogin()
    elseif self.status==4 then
    -- 进入游戏
        player.flushUserDefualt()

        require("scene/cityMap")
        local map = cityMap.new()
        map:enter()

        cc.SimpleAudioEngine:getInstance():playMusic("sound/background.mp3", true)

        -- 请求登录公告
        require("ui/common/sysNotice")
        UI_sysNotice.show()
    end
end

