if love._os=='Web' then
    local _read=love.filesystem.read
    local _getinfo=love.filesystem.getInfo
    love.filesystem[('read')]=function(name,size)
        if _getinfo(name) then return _read(name,size) end
    end
end

function love.conf(t)
    local mobile=love._os=='Android' or love._os=='iOS'

    t.identity='rero_chess' -- Saving folder
    t.externalstorage=true -- Use external storage on Android
    t.version="11.5"
    t.gammacorrect=false
    t.appendidentity=true -- Search files in source then in save directory
    t.accelerometerjoystick=false -- Accelerometer=joystick on ios/android
    if t.audio then
        t.audio.mic=false
        t.audio.mixwithsystem=true
    end

    local M=t.modules
    M.window,M.system,M.event,M.thread=true,true,true,true
    M.timer,M.math,M.data=true,true,true
    M.video,M.audio,M.sound=true,true,true
    M.graphics,M.font,M.image=true,true,true
    M.mouse,M.touch,M.keyboard,M.joystick=true,true,true,true
    M.physics=false

    local W=t.window
    W.vsync=0 -- Unlimited FPS
    W.msaa=4 -- Multi-sampled antialiasing
    W.depth=0 -- Bits/samp of depth buffer
    W.stencil=1 -- Bits/samp of stencil buffer
    W.display=1 -- Monitor ID
    W.highdpi=true -- High-dpi mode for the window on a Retina display
    W.x,W.y=nil,nil
    W.borderless=mobile
    W.resizable=not mobile
    W.fullscreentype=mobile and 'exclusive' or 'desktop' -- Fullscreen type
    W.width,W.height=1250,750
    W.minwidth,W.minheight=160,100
    W.title=require'version'.appName..'  '..require'version'.appVer

    if love._os=='Linux' and love.filesystem.getInfo('assets/image/icon.png') then
        W.icon='assets/image/icon.png'
    end
end
