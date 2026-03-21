-- ╔══════════════════════════════════════════════════════════╗
-- ║                   223HUB  v1.0                           ║
-- ║      SCRIPT FEITO POR BRUNO223J E TY                     ║
-- ║      DISCORD: .223j  |  frty2017                         ║
-- ╚══════════════════════════════════════════════════════════╝

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local CoreGui         = game:GetService("CoreGui")
local TweenService    = game:GetService("TweenService")
local HttpService     = game:GetService("HttpService")
local Workspace       = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam   = Workspace.CurrentCamera

-- ============================================================
-- CLEANUP
-- ============================================================
if _G._223HUB_Kill then pcall(_G._223HUB_Kill) end
local _conns = {}
local function AC(c) _conns[#_conns+1]=c; return c end

_G._223HUB_Kill = function()
    for _,c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
    _conns = {}
    if _G._223HUB_ESPO then
        for _,d in pairs(_G._223HUB_ESPO) do
            for _,v in pairs(d) do
                if type(v)=="table" then for _,l in pairs(v) do pcall(function() l:Remove() end) end
                else pcall(function() v:Remove() end) end
            end
        end
        _G._223HUB_ESPO = {}
    end
    if _G._223HUB_FOVC then pcall(function() _G._223HUB_FOVC:Remove() end); _G._223HUB_FOVC=nil end
    if CoreGui:FindFirstChild("223TYHUB") then CoreGui:FindFirstChild("223TYHUB"):Destroy() end
end

-- ============================================================
-- CONFIG — TODOS COMEÇAM false/desligado
-- ============================================================
local Cfg = {
    ESP = {
        -- tudo false: usuário liga o que quiser
        Enabled=false, Box=false, Fill=false, Names=false,
        HP=false, Tracers=false, Dist=false, WallCheck=false,
        TeamCheck=false, HeldTool=false,
        MaxDist=500, TrackList={},
        BoxColor    = Color3.fromRGB(220,40,40),
        FillColor   = Color3.fromRGB(220,40,40),
        NameColor   = Color3.fromRGB(255,255,255),
        TracerColor = Color3.fromRGB(220,40,40),
        DistColor   = Color3.fromRGB(200,200,200),
        HPColor     = Color3.fromRGB(0,220,80),
        HPBgColor   = Color3.fromRGB(50,0,0),
        ToolColor   = Color3.fromRGB(255,210,50),
    },
    Xray = {
        Enabled=false, Box=false, Fill=false, Names=false,
        HP=false, Tracers=false, Dist=false,
        TeamCheck=false, Skeleton=false, MaxDist=1000,
        BoxColor    = Color3.fromRGB(0,160,255),
        FillColor   = Color3.fromRGB(0,120,220),
        NameColor   = Color3.fromRGB(180,220,255),
        TracerColor = Color3.fromRGB(0,160,255),
        DistColor   = Color3.fromRGB(150,200,255),
        HPColor     = Color3.fromRGB(0,200,255),
        HPBgColor   = Color3.fromRGB(0,30,60),
        SkelColor   = Color3.fromRGB(0,200,255),
    },
    Aim = {
        Aimbot=false, WallCheck=false, TeamCheck=false,
        Prediction=false, PredStr=1,
        NoRecoil=false, InfAmmo=false, FastReload=false,
        FOV=120, ShowFOV=false, UseFOV=false, FOVFollow=false,
        AimPart="Head", Smoothness=15,
        AimKey=Enum.KeyCode.E, AimKeyName="E",
        Blacklist={},
    },
    Trigger = { Enabled=false, TeamCheck=false, Delay=100 },
    Misc = {
        Fly=false, FlySpeed=50, FlyBoost=false,
        Noclip=false,
        Speed=false, WalkSpeed=25,
        AntiAFK=false,
        HitboxExtender=false, HitboxSize=8, HitboxPart="All",
        JumpMod=false, JumpPower=80, JumpMethod="JumpPower",
        InfJump=false, AntiRag=false,
        FreeCam=false, FCamSpeed=1,
        BoomboxID="", DupeToolName="",
        ClickTp=false, SpinBot=false,
    },
    Modes = {
        SpiderMan=false,  -- anda nas paredes
        Aquaman=false,    -- não afoga embaixo d'agua
        NoFallDmg=false,  -- sem dano de queda
    },
    Troll = {
        ChatSpam=false, SpamMsg="223HUB", SpamDelay=1,
        Rainbow=false, RainbowSpeed=0.05,
        SoundID="",
        SpinSpeed=10, Invisible=false,
        GiantScale=5, TinyScale=0.3,
    },
    Settings = {
        ToggleKey=Enum.KeyCode.Semicolon, ToggleKeyName=";",
        ESPKey=Enum.KeyCode.F2,           ESPKeyName="F2",
        AimbotKey=Enum.KeyCode.F3,        AimbotKeyName="F3",
        FlyKey=Enum.KeyCode.F5,           FlyKeyName="F5",
        NoclipKey=Enum.KeyCode.F6,        NoclipKeyName="F6",
        SpeedKey=Enum.KeyCode.F7,         SpeedKeyName="F7",
        XrayKey=Enum.KeyCode.F8,          XrayKeyName="F8",
        FreeCamKey=Enum.KeyCode.F9,       FreeCamKeyName="F9",
    },
}

-- ============================================================
-- SAVES
-- ============================================================
local SDIR="223TYHUB_Configs/"
local function EnsDir() pcall(function() if not isfolder(SDIR) then makefolder(SDIR) end end) end
local function SafeSer(t)
    local o={}
    for k,v in pairs(t) do
        if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then o[k]=v
        elseif type(v)=="table" then o[k]=SafeSer(v) end
    end
    return o
end
local function SerCfg()
    local t={ESP=SafeSer(Cfg.ESP),Xray=SafeSer(Cfg.Xray),Aim=SafeSer(Cfg.Aim),
             Trigger=SafeSer(Cfg.Trigger),Misc=SafeSer(Cfg.Misc),
             Modes=SafeSer(Cfg.Modes),Settings=SafeSer(Cfg.Settings)}
    t.Aim.AimKeyName=Cfg.Aim.AimKeyName
    for k,v in pairs(Cfg.Settings) do if type(v)=="string" then t.Settings[k]=v end end
    return HttpService:JSONEncode(t)
end
local function ApplySave(t)
    if not t then return end
    local function mg(d,s) if not s then return end
        for k,v in pairs(s) do
            if type(v)=="table" then if type(d[k])=="table" then mg(d[k],v) end
            elseif d[k]~=nil then d[k]=v end
        end
    end
    mg(Cfg.ESP,t.ESP); mg(Cfg.Xray,t.Xray); mg(Cfg.Aim,t.Aim)
    mg(Cfg.Trigger,t.Trigger); mg(Cfg.Misc,t.Misc)
    mg(Cfg.Modes,t.Modes); mg(Cfg.Settings,t.Settings)
    local function TK(n)
        if not n then return Enum.KeyCode.Unknown end
        local ok,k=pcall(function() return Enum.KeyCode[n] end)
        return (ok and k) or Enum.KeyCode.Unknown
    end
    Cfg.Aim.AimKey=TK(Cfg.Aim.AimKeyName)
    Cfg.Settings.ToggleKey=TK(Cfg.Settings.ToggleKeyName)
    Cfg.Settings.ESPKey=TK(Cfg.Settings.ESPKeyName)
    Cfg.Settings.AimbotKey=TK(Cfg.Settings.AimbotKeyName)
    Cfg.Settings.FlyKey=TK(Cfg.Settings.FlyKeyName)
    Cfg.Settings.NoclipKey=TK(Cfg.Settings.NoclipKeyName)
    Cfg.Settings.SpeedKey=TK(Cfg.Settings.SpeedKeyName)
    Cfg.Settings.XrayKey=TK(Cfg.Settings.XrayKeyName)
    Cfg.Settings.FreeCamKey=TK(Cfg.Settings.FreeCamKeyName)
end
local function SaveCfg(name)
    if not writefile then return false,"writefile indisponível" end
    EnsDir()
    local fn=SDIR..name:gsub("[^%w_%-]","_")..".json"
    local ok,e=pcall(writefile,fn,SerCfg())
    return ok, ok and fn or tostring(e)
end
local function LoadCfg(name)
    if not readfile then return false,"readfile indisponível" end
    local fn=SDIR..name:gsub("[^%w_%-]","_")..".json"
    if isfile and not isfile(fn) then return false,"Não encontrado" end
    local ok,data=pcall(readfile,fn); if not ok then return false,"Erro ao ler" end
    local ok2,t=pcall(function() return HttpService:JSONDecode(data) end)
    if not ok2 then return false,"JSON inválido" end
    ApplySave(t); return true,fn
end
local function ListCfgs()
    if not listfiles then return {} end
    EnsDir()
    local ok,lst=pcall(listfiles,SDIR)
    if not ok or type(lst)~="table" then return {} end
    local out={}
    for _,f in ipairs(lst) do
        local n=tostring(f):match("([^/\\]+)%.json$")
        if n then out[#out+1]=n end
    end
    return out
end
local function DelCfg(name)
    if not delfile then return false end
    pcall(delfile,SDIR..name:gsub("[^%w_%-]","_")..".json"); return true
end

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function W2S(worldPos)
    local sp, onScreen = Cam:WorldToViewportPoint(worldPos)
    return Vector2.new(sp.X, sp.Y), (sp.Z > 0) and onScreen
end

local function GetBounds(char)
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local topW = hrp.Position + Vector3.new(0, 3.3, 0)
    local botW = hrp.Position - Vector3.new(0, 2.8, 0)
    local topSP, _ = W2S(topW)
    local botSP, _ = W2S(botW)
    local topZ = Cam:WorldToViewportPoint(topW).Z
    local botZ = Cam:WorldToViewportPoint(botW).Z
    if topZ <= 0 and botZ <= 0 then return nil end
    local h = math.abs(botSP.Y - topSP.Y)
    if h < 2 then return nil end
    local w = h * 0.55
    return topSP.X - w/2, topSP.Y, w, h
end

local function GetDist(char)
    local myc = LP.Character
    local a = char and char:FindFirstChild("HumanoidRootPart")
    local b = myc  and myc:FindFirstChild("HumanoidRootPart")
    if not a or not b then return nil end
    return math.floor((a.Position - b.Position).Magnitude)
end

local function GetHP(char)
    local h = char and char:FindFirstChildOfClass("Humanoid")
    if not h then return 0, 100 end
    return math.max(0, h.Health), math.max(1, h.MaxHealth)
end

local function IsVisible(char)
    local myc  = LP.Character
    local mine = myc and myc:FindFirstChild("HumanoidRootPart")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not mine or not hrp then return false end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local ex = {}
    for _,v in ipairs(myc:GetDescendants())  do if v:IsA("BasePart") then ex[#ex+1]=v end end
    for _,v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then ex[#ex+1]=v end end
    rp.FilterDescendantsInstances = ex
    local res = Workspace:Raycast(mine.Position, hrp.Position - mine.Position, rp)
    return res == nil
end

local function SameTeam(p)
    if not p or p == LP then return false end
    local mt=LP.Team; local pt=p.Team
    return mt ~= nil and pt ~= nil and mt == pt
end

local function IsValidTarget(p)
    if p == LP then return false end
    if Cfg.Aim.Blacklist[p.Name] then return false end
    if Cfg.Aim.TeamCheck and SameTeam(p) then return false end
    local c = p.Character; if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0
end

local function GetHeldTool(char)
    if not char then return nil end
    for _,v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then return v.Name end
    end
    return nil
end

local function ClosestTarget()
    local vs = Cam.ViewportSize
    local center = Vector2.new(vs.X/2, vs.Y/2)
    local best, bestD = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(p) then continue end
        local c = p.Character
        local part = c:FindFirstChild(Cfg.Aim.AimPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        if Cfg.Aim.WallCheck and not IsVisible(c) then continue end
        local sp, onScreen = W2S(part.Position)
        if not onScreen then continue end
        local d = (sp - center).Magnitude
        if Cfg.Aim.UseFOV and d > Cfg.Aim.FOV then continue end
        if d < bestD then bestD=d; best=p end
    end
    return best
end

local function GetPlayerByName(name)
    if not name or name=="" then return nil end
    local q = name:lower()
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(q,1,true) or p.DisplayName:lower():find(q,1,true) then return p end
    end
    return nil
end

-- ============================================================
-- ESP OBJECTS
-- ============================================================
local ESPO = {}; _G._223HUB_ESPO = ESPO

local BONES_R15 = {
    {"Head","UpperTorso"},     {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},  {"LeftUpperArm","LeftLowerArm"},  {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},  {"LeftUpperLeg","LeftLowerLeg"},  {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local BONES_R6 = {
    {"Head","Torso"},
    {"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function ND(kind, props)
    local d = Drawing.new(kind)
    for k,v in pairs(props) do d[k]=v end
    return d
end

local function MakeESP(p)
    if p==LP or ESPO[p] then return end
    local d={}
    -- ESP
    d.Box    = ND("Square",{Filled=false,Color=Cfg.ESP.BoxColor,    Transparency=0,  Thickness=1.5,Visible=false})
    d.Fill   = ND("Square",{Filled=true, Color=Cfg.ESP.FillColor,   Transparency=0.65,Thickness=0,Visible=false})
    d.Name   = ND("Text",  {Size=13,Color=Cfg.ESP.NameColor,  Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.Dist   = ND("Text",  {Size=11,Color=Cfg.ESP.DistColor,  Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.HPBg   = ND("Square",{Filled=true, Color=Cfg.ESP.HPBgColor,   Transparency=0,  Thickness=0,Visible=false})
    d.HPFill = ND("Square",{Filled=true, Color=Cfg.ESP.HPColor,     Transparency=0,  Thickness=0,Visible=false})
    d.HPText = ND("Text",  {Size=9, Color=Color3.new(1,1,1),  Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.Tracer = ND("Line",  {Thickness=1.2,Color=Cfg.ESP.TracerColor,Transparency=0,  Visible=false})
    d.Tool   = ND("Text",  {Size=11,Color=Cfg.ESP.ToolColor,  Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    -- Xray
    d.XBox    = ND("Square",{Filled=false,Color=Cfg.Xray.BoxColor,   Transparency=0,  Thickness=1.5,Visible=false})
    d.XFill   = ND("Square",{Filled=true, Color=Cfg.Xray.FillColor,  Transparency=0.65,Thickness=0,Visible=false})
    d.XName   = ND("Text",  {Size=13,Color=Cfg.Xray.NameColor, Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.XDist   = ND("Text",  {Size=11,Color=Cfg.Xray.DistColor, Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.XHPBg   = ND("Square",{Filled=true, Color=Cfg.Xray.HPBgColor,  Transparency=0,  Thickness=0,Visible=false})
    d.XHPFill = ND("Square",{Filled=true, Color=Cfg.Xray.HPColor,    Transparency=0,  Thickness=0,Visible=false})
    d.XTracer = ND("Line",  {Thickness=1.2,Color=Cfg.Xray.TracerColor,Transparency=0, Visible=false})
    -- Skeleton
    d.Skel = {}
    for i=1,14 do d.Skel[i]=ND("Line",{Thickness=1,Color=Cfg.Xray.SkelColor,Transparency=0,Visible=false}) end
    ESPO[p]=d
end

local function KillESP(p)
    local d=ESPO[p]; if not d then return end
    for _,v in pairs(d) do
        if type(v)=="table" then for _,l in pairs(v) do pcall(function() l:Remove() end) end
        else pcall(function() v:Remove() end) end
    end
    ESPO[p]=nil
end

local function HideAll(d)
    for _,v in pairs(d) do
        if type(v)=="table" then for _,l in pairs(v) do if l.Visible~=nil then l.Visible=false end end
        elseif v.Visible~=nil then v.Visible=false end
    end
end

-- FOV
local FOVC = ND("Circle",{Thickness=1.5,Color=Color3.fromRGB(220,50,50),Filled=false,NumSides=64,Transparency=0,Visible=false})
_G._223HUB_FOVC = FOVC

-- ============================================================
-- NO RECOIL / FAST RELOAD / INF AMMO
-- ============================================================
local _nrConn=nil
local function StartNoRecoil()
    if _nrConn then return end
    _nrConn=AC(RunService.RenderStepped:Connect(function()
        if not Cfg.Aim.NoRecoil and not Cfg.Aim.FastReload then return end
        local char=LP.Character; if not char then return end
        for _,tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _,v in ipairs(tool:GetDescendants()) do
                    local nm=v.Name:lower()
                    -- No Recoil: zera valores de recoil/kickback
                    if Cfg.Aim.NoRecoil then
                        if nm:find("recoil") or nm:find("kickback") then
                            pcall(function()
                                if v:IsA("Vector3Value") then v.Value=Vector3.zero
                                elseif v:IsA("NumberValue") then v.Value=0 end
                            end)
                        end
                    end
                    -- Fast Reload: zera tempo de reload/firerate
                    if Cfg.Aim.FastReload then
                        if nm:find("reload") or nm:find("firerate") or nm:find("delay") or nm:find("cooldown") then
                            pcall(function()
                                if v:IsA("NumberValue") and v.Value > 0 then v.Value=0.01 end
                            end)
                        end
                    end
                end
            end
        end
    end))
end

local _iaConn=nil
local function StartInfAmmo()
    if _iaConn then return end
    _iaConn=AC(RunService.Heartbeat:Connect(function()
        if not Cfg.Aim.InfAmmo then return end
        local char=LP.Character; if not char then return end
        local bp=LP:FindFirstChild("Backpack")
        local containers={char}
        if bp then containers[2]=bp end
        for _,cont in ipairs(containers) do
            for _,tool in ipairs(cont:GetChildren()) do
                if tool:IsA("Tool") then
                    for _,v in ipairs(tool:GetDescendants()) do
                        pcall(function()
                            local nm=v.Name:lower()
                            if nm:find("ammo") or nm:find("clip") or nm:find("bullets") or nm:find("mag") or nm:find("reserve") then
                                if (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Value<9999 then v.Value=9999 end
                            end
                        end)
                    end
                end
            end
        end
    end))
end

-- ============================================================
-- TRIGGERBOT
-- ============================================================
local _tbLast=0
AC(RunService.Heartbeat:Connect(function()
    if not Cfg.Trigger.Enabled then return end
    if tick()-_tbLast < Cfg.Trigger.Delay/1000 then return end
    local tgt=Mouse.Target; if not tgt then return end
    local model=tgt:FindFirstAncestorOfClass("Model"); if not model then return end
    local p=Players:GetPlayerFromCharacter(model); if not p then return end
    if not IsValidTarget(p) then return end
    if Cfg.Trigger.TeamCheck and SameTeam(p) then return end
    local h=model:FindFirstChildOfClass("Humanoid"); if not h or h.Health<=0 then return end
    _tbLast=tick()
    local vms=game:GetService("VirtualInputManager")
    if vms then
        pcall(function() vms:SendMouseButtonEvent(0,0,0,true,game,0) end)
        task.wait(0.05)
        pcall(function() vms:SendMouseButtonEvent(0,0,0,false,game,0) end)
    end
end))

-- ============================================================
-- FLY
-- ============================================================
local _flyConn,_bv,_bg=nil,nil,nil
local function EnableFly()
    if _flyConn then return end
    local char=LP.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.PlatformStand=true
    _bv=Instance.new("BodyVelocity"); _bv.MaxForce=Vector3.new(1e5,1e5,1e5); _bv.Velocity=Vector3.zero; _bv.Parent=hrp
    _bg=Instance.new("BodyGyro"); _bg.MaxTorque=Vector3.new(1e5,1e5,1e5); _bg.P=1e4; _bg.Parent=hrp
    _flyConn=AC(RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.Fly then return end
        if not _bv or not _bv.Parent then return end
        local cf=Cam.CFrame; local vel=Vector3.zero
        local spd=Cfg.Misc.FlySpeed*(Cfg.Misc.FlyBoost and 3 or 1)
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then vel=vel+Vector3.new(0,spd,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel=vel-Vector3.new(0,spd*0.6,0) end
        _bv.Velocity=vel; _bg.CFrame=cf
    end))
end
local function DisableFly()
    if _flyConn then _flyConn:Disconnect(); _flyConn=nil end
    if _bv then pcall(function() _bv:Destroy() end); _bv=nil end
    if _bg then pcall(function() _bg:Destroy() end); _bg=nil end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
end

-- ============================================================
-- NOCLIP
-- ============================================================
local _ncConn=nil
local function EnableNoclip()
    if _ncConn then return end
    _ncConn=AC(RunService.Stepped:Connect(function()
        if not Cfg.Misc.Noclip then return end
        local char=LP.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end))
end
local function DisableNoclip()
    if _ncConn then _ncConn:Disconnect(); _ncConn=nil end
    local char=LP.Character; if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=true end
    end
end

-- ============================================================
-- SPEED / JUMP
-- ============================================================
local function ApplySpeed()
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.WalkSpeed=Cfg.Misc.Speed and Cfg.Misc.WalkSpeed or 16
end
local function ApplyJump()
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if not Cfg.Misc.JumpMod then hum.JumpPower=50; return end
    if Cfg.Misc.JumpMethod=="JumpPower" then hum.JumpPower=Cfg.Misc.JumpPower
    else hum.UseJumpPower=true; hum.JumpHeight=Cfg.Misc.JumpPower*0.4 end
end
AC(UIS.JumpRequest:Connect(function()
    if not Cfg.Misc.InfJump then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end))

-- ============================================================
-- ANTI AFK
-- ============================================================
LP.Idled:Connect(function()
    if not Cfg.Misc.AntiAFK then return end
    local vim=game:GetService("VirtualInputManager")
    pcall(function() vim:SendKeyEvent(true,Enum.KeyCode.ButtonL3,false,game) end)
    task.wait(0.5)
    pcall(function() vim:SendKeyEvent(false,Enum.KeyCode.ButtonL3,false,game) end)
end)

-- ============================================================
-- ANTI RAGDOLL
-- ============================================================
AC(RunService.Heartbeat:Connect(function()
    if not Cfg.Misc.AntiRag then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local st=hum:GetState()
    if st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
            pcall(function() v.Enabled=false end)
        end
    end
end))

-- ============================================================
-- HITBOX EXTENDER
-- ============================================================
local _hbConns={}
local HITBOX_PARTS={
    All      ={"Head","Torso","UpperTorso","LowerTorso","HumanoidRootPart","Left Arm","Right Arm","Left Leg","Right Leg","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"},
    Head     ={"Head"},
    Torso    ={"Torso","UpperTorso","LowerTorso"},
    Arms     ={"Left Arm","Right Arm","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand"},
    Legs     ={"Left Leg","Right Leg","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"},
    ["HRP Only"]={"HumanoidRootPart"},
}
local function ApplyHitboxChar(char)
    if not Cfg.Misc.HitboxExtender then return end
    local partSet={}
    for _,n in ipairs(HITBOX_PARTS[Cfg.Misc.HitboxPart] or HITBOX_PARTS["All"]) do partSet[n]=true end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and partSet[v.Name] then
            v.Size=Vector3.new(Cfg.Misc.HitboxSize,Cfg.Misc.HitboxSize,Cfg.Misc.HitboxSize)
            v.LocalTransparencyModifier=0.7
        end
    end
end
local function SetHitbox(p,on)
    if p==LP then return end
    if _hbConns[p] then _hbConns[p]:Disconnect(); _hbConns[p]=nil end
    if on then
        if p.Character then ApplyHitboxChar(p.Character) end
        _hbConns[p]=p.CharacterAdded:Connect(function(c) task.wait(0.5); ApplyHitboxChar(c) end)
    else
        local char=p.Character; if not char then return end
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.Size=Vector3.new(2,2,1); v.LocalTransparencyModifier=0 end
        end
    end
end
local function RefreshHitboxes()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then SetHitbox(p,Cfg.Misc.HitboxExtender) end
    end
end

-- ============================================================
-- FREECAM
-- ============================================================
local _fcPart,_fcConn=nil,nil
local function EnableFreeCam()
    if _fcConn then return end
    _fcPart=Instance.new("Part"); _fcPart.Anchored=true; _fcPart.CanCollide=false
    _fcPart.Transparency=1; _fcPart.Size=Vector3.new(0.1,0.1,0.1)
    _fcPart.CFrame=Cam.CFrame; _fcPart.Parent=Workspace
    Cam.CameraSubject=_fcPart; Cam.CameraType=Enum.CameraType.Scriptable
    _fcConn=AC(RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.FreeCam then return end
        local spd=Cfg.Misc.FCamSpeed*0.6; local mv=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+Cam.CFrame.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-Cam.CFrame.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-Cam.CFrame.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+Cam.CFrame.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.E) then mv=mv+Vector3.new(0,spd,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then mv=mv-Vector3.new(0,spd,0) end
        _fcPart.CFrame=_fcPart.CFrame+mv; Cam.CFrame=Cam.CFrame+mv
    end))
end
local function DisableFreeCam()
    if _fcConn then _fcConn:Disconnect(); _fcConn=nil end
    if _fcPart then pcall(function() _fcPart:Destroy() end); _fcPart=nil end
    Cam.CameraType=Enum.CameraType.Custom
    local char=LP.Character
    if char then local h=char:FindFirstChildOfClass("Humanoid"); if h then Cam.CameraSubject=h end end
end

-- ============================================================
-- MODOS ESPECIAIS
-- ============================================================

-- Spider-Man: anda sobre qualquer superfície
local _spiderConn=nil
local function EnableSpiderMan()
    if _spiderConn then return end
    _spiderConn=AC(RunService.Heartbeat:Connect(function()
        if not Cfg.Modes.SpiderMan then return end
        local char=LP.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        -- Raycast para baixo para detectar paredes laterais e teto
        local dirs={
            Vector3.new(0,-1,0),  -- chão
            Vector3.new(0,1,0),   -- teto
            CFrame.new(Vector3.zero,Cam.CFrame.LookVector).LookVector, -- frente
        }
        local rp=RaycastParams.new()
        rp.FilterType=Enum.RaycastFilterType.Exclude
        local ex={}
        for _,v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then ex[#ex+1]=v end end
        rp.FilterDescendantsInstances=ex
        for _,dir in ipairs(dirs) do
            local res=Workspace:Raycast(hrp.Position,dir*3.5,rp)
            if res then
                -- Cola o personagem na superfície
                local norm=res.Normal
                hum:ChangeState(Enum.HumanoidStateType.Swimming)
                local targetCF=CFrame.new(res.Position+(norm*3),res.Position+(norm*3)+norm)
                hrp.CFrame=hrp.CFrame:Lerp(targetCF,0.2)
                break
            end
        end
    end))
end
local function DisableSpiderMan()
    if _spiderConn then _spiderConn:Disconnect(); _spiderConn=nil end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
end

-- Aquaman: não afoga
local _aquaConn=nil
local function EnableAquaman()
    if _aquaConn then return end
    _aquaConn=AC(RunService.Heartbeat:Connect(function()
        if not Cfg.Modes.Aquaman then return end
        local char=LP.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        -- Mantém estado Swimming funcional e impede afogamento
        if hum:GetState()==Enum.HumanoidStateType.Swimming then
            hum.Health=hum.Health  -- sem queda de HP
        end
        -- Seta capacidade de respiração máxima
        pcall(function()
            local humanoidDesc=char:FindFirstChildOfClass("Humanoid")
            if humanoidDesc then
                -- Remove o efeito de afogamento zerando o "swim" damage
                local swimDmg=hum:FindFirstChild("SwimDamage") or hum:FindFirstChild("OxygenCheck")
                if swimDmg then swimDmg:Disconnect() end
            end
        end)
        -- Abordagem direta: quando submerso, manter HP
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("Script") and v.Name:lower():find("drown") then
                pcall(function() v.Disabled=true end)
            end
        end
        -- Força regeneração quando HP cai por afogamento
        if hum.Health < hum.MaxHealth and hum.Health > 0 then
            -- Pequena correção: mantém HP estável
            hum.Health = math.min(hum.MaxHealth, hum.Health + 0.5)
        end
    end))
end
local function DisableAquaman()
    if _aquaConn then _aquaConn:Disconnect(); _aquaConn=nil end
end

-- No Fall Damage: sem dano de queda
local _nfdConn=nil
local _lastHP=100
local function EnableNoFallDmg()
    if _nfdConn then return end
    _nfdConn=AC(RunService.Heartbeat:Connect(function()
        if not Cfg.Modes.NoFallDmg then return end
        local char=LP.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        -- Monitora queda de HP súbita (típico de fall damage)
        -- Desabilita o FallingDown state
        local st=hum:GetState()
        if st==Enum.HumanoidStateType.Freefall then
            -- Mantém registro do HP antes da queda
            _lastHP=hum.Health
        elseif st==Enum.HumanoidStateType.Landed then
            -- Restaura HP se houve queda brusca
            if hum.Health < _lastHP - 5 then
                hum.Health=_lastHP
            end
        end
        -- Abordagem adicional: desabilita o StepHeight para o estado de queda
        hum.StateChanged:Once(function(old, new)
            if new==Enum.HumanoidStateType.Landed then
                if Cfg.Modes.NoFallDmg then
                    task.delay(0.05, function()
                        local c2=LP.Character; if not c2 then return end
                        local h2=c2:FindFirstChildOfClass("Humanoid"); if not h2 then return end
                        if h2.Health < _lastHP - 5 then h2.Health=_lastHP end
                    end)
                end
            end
        end)
    end))
end
local function DisableNoFallDmg()
    if _nfdConn then _nfdConn:Disconnect(); _nfdConn=nil end
end

-- ============================================================
-- BOOMBOX / CLICK TP / TOOLS / SERVER
-- ============================================================
local _boom=nil
local function PlayBoom(id)
    if _boom then pcall(function() _boom:Destroy() end); _boom=nil end
    if not id or id=="" then return end
    _boom=Instance.new("Sound")
    _boom.SoundId="rbxassetid://"..tostring(id):gsub("%D","")
    _boom.Volume=1; _boom.Looped=true; _boom.Name="_223Boom"; _boom.Parent=Workspace
    _boom:Play()
end
local function StopBoom()
    if _boom then pcall(function() _boom:Stop(); _boom:Destroy() end); _boom=nil end
end

local _ctConn=nil
local function StartClickTp()
    if _ctConn then return end
    _ctConn=AC(Mouse.Button1Down:Connect(function()
        if not Cfg.Misc.ClickTp then return end
        local char=LP.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hit=Mouse.Hit; if not hit then return end
        hrp.CFrame=CFrame.new(hit.Position+Vector3.new(0,3,0))
    end))
end

local function GrabNearestTool()
    local char=LP.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local best,bestD=nil,math.huge
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and not v:IsDescendantOf(Players) then
            local part=v:FindFirstChildOfClass("BasePart")
            if part then
                local d=(part.Position-hrp.Position).Magnitude
                if d<bestD then bestD=d; best=v end
            end
        end
    end
    if best then
        local bp=LP:FindFirstChild("Backpack")
        if bp then best.Parent=bp; return best.Name end
    end
    return nil
end
local function GetMapTools()
    local out={}
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and not v:IsDescendantOf(Players) then
            out[#out+1]={name=v.Name,tool=v}
        end
    end
    return out
end
local function DupeTool()
    local nm=Cfg.Misc.DupeToolName:lower():gsub("%s+",""); if nm=="" then return end
    local bp=LP:FindFirstChild("Backpack"); local char=LP.Character; local tool
    if bp then for _,v in ipairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(nm,1,true) then tool=v; break end end end
    if not tool and char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(nm,1,true) then tool=v; break end end end
    if tool and bp then tool:Clone().Parent=bp end
end

local function Rejoin() pcall(function() TeleportService:Teleport(game.PlaceId,LP) end) end
local function ServerHop()
    local ok,srv=pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and srv and srv.data then
        for _,s in ipairs(srv.data) do
            if s.id~=game.JobId and s.playing<s.maxPlayers then
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,LP) end); return
            end
        end
    end
    pcall(function() TeleportService:Teleport(game.PlaceId,LP) end)
end

-- Chat Log
local _chatLog={}
local function StartChatLog()
    local function hookP(p)
        p.Chatted:Connect(function(msg)
            table.insert(_chatLog,1,{player=p.Name,msg=msg,time=os.date("%H:%M:%S")})
            if #_chatLog>120 then table.remove(_chatLog) end
        end)
    end
    for _,p in ipairs(Players:GetPlayers()) do hookP(p) end
    Players.PlayerAdded:Connect(hookP)
end

-- ============================================================
-- TROLL
-- ============================================================
local _spinBG=nil
local function TrollSpin(on)
    if _spinBG then pcall(function() _spinBG:Destroy() end); _spinBG=nil end
    if not on then return end
    local char=LP.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    _spinBG=Instance.new("BodyAngularVelocity",hrp)
    _spinBG.AngularVelocity=Vector3.new(0,Cfg.Troll.SpinSpeed*10,0)
    _spinBG.MaxTorque=Vector3.new(0,1e7,0); _spinBG.P=1e6
end
local function TrollInvis(on)
    local char=LP.Character; if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            pcall(function() p.LocalTransparencyModifier=on and 1 or 0 end)
        end
    end
end
local function TrollScale(sv)
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local ok,desc=pcall(function() return hum:GetAppliedDescription() end)
    if not ok or not desc then desc=Instance.new("HumanoidDescription") end
    desc.HeightScale=sv; desc.WidthScale=sv; desc.DepthScale=sv; desc.HeadScale=sv
    desc.ProportionScale=1; desc.BodyTypeScale=0
    pcall(function() hum:ApplyDescription(desc) end)
end
local _rainThread=nil
local function EnableRainbow(on)
    if _rainThread then task.cancel(_rainThread); _rainThread=nil end
    if not on then return end
    local hue=0
    _rainThread=task.spawn(function()
        while Cfg.Troll.Rainbow do
            hue=(hue+Cfg.Troll.RainbowSpeed)%1
            local col=Color3.fromHSV(hue,1,1)
            local char=LP.Character
            if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.Color=col end) end end end
            task.wait(0.05)
        end
    end)
end
local _spamThread=nil
local function StartSpam()
    if _spamThread then return end
    _spamThread=task.spawn(function()
        while Cfg.Troll.ChatSpam do
            pcall(function()
                local rs=game:GetService("ReplicatedStorage")
                local ev=rs:FindFirstChild("DefaultChatSystemChatEvents")
                if ev then local req=ev:FindFirstChild("SayMessageRequest"); if req then req:FireServer(Cfg.Troll.SpamMsg,"All") end end
            end)
            pcall(function()
                local tcs=game:GetService("TextChatService")
                local chans=tcs:FindFirstChild("TextChannels")
                if chans then local ch=chans:FindFirstChild("RBXGeneral"); if ch then ch:SendAsync(Cfg.Troll.SpamMsg) end end
            end)
            task.wait(math.max(0.5,Cfg.Troll.SpamDelay))
        end
        _spamThread=nil
    end)
end
local function StopSpam() Cfg.Troll.ChatSpam=false end
local _sndSpam=nil
local function StartSoundSpam(id)
    if _sndSpam then pcall(function() _sndSpam:Destroy() end); _sndSpam=nil end
    if not id or id=="" then return end
    _sndSpam=Instance.new("Sound"); _sndSpam.SoundId="rbxassetid://"..id:gsub("%D","")
    _sndSpam.Volume=5; _sndSpam.Looped=true; _sndSpam.Name="_223Troll"; _sndSpam.Parent=Workspace; _sndSpam:Play()
end
local function StopSoundSpam()
    if _sndSpam then pcall(function() _sndSpam:Stop(); _sndSpam:Destroy() end); _sndSpam=nil end
end

-- ============================================================
-- RENDER LOOP
-- ============================================================
AC(RunService.RenderStepped:Connect(function()
    local vs=Cam.ViewportSize
    local cx,cy=vs.X/2,vs.Y/2

    -- FOV Circle
    FOVC.Position = Cfg.Aim.FOVFollow and Vector2.new(Mouse.X,Mouse.Y) or Vector2.new(cx,cy)
    FOVC.Radius   = Cfg.Aim.FOV
    FOVC.Visible  = Cfg.Aim.ShowFOV

    -- Aimbot
    if Cfg.Aim.Aimbot and UIS:IsKeyDown(Cfg.Aim.AimKey) then
        local t=ClosestTarget()
        if t and t.Character then
            local pt=t.Character:FindFirstChild(Cfg.Aim.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
            if pt then
                local pos=pt.Position
                if Cfg.Aim.Prediction then
                    local hrp=t.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then pos=pos+hrp.AssemblyLinearVelocity*(Cfg.Aim.PredStr*0.05) end
                end
                local alpha=math.clamp((100-Cfg.Aim.Smoothness)/100*0.5+0.02,0.02,1)
                Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,pos),alpha)
            end
        end
    end

    -- ESP
    for player,d in pairs(ESPO) do
        if not player or not player.Parent then KillESP(player); continue end
        local c=player.Character
        if not c then HideAll(d); continue end
        local hrp=c:FindFirstChild("HumanoidRootPart")
        if not hrp then HideAll(d); continue end

        local dist=GetDist(c) or 99999
        local bx,by,bw,bh=GetBounds(c)

        -- ESP NORMAL
        local showESP=Cfg.ESP.Enabled
            and dist<=Cfg.ESP.MaxDist
            and (not Cfg.ESP.TeamCheck or not SameTeam(player))
            and (not next(Cfg.ESP.TrackList) or Cfg.ESP.TrackList[player.Name])
            and (not Cfg.ESP.WallCheck or IsVisible(c))

        if showESP and bx then
            local x,y,w,h=bx,by,bw,bh
            if Cfg.ESP.Box then
                d.Box.Position=Vector2.new(x,y); d.Box.Size=Vector2.new(w,h); d.Box.Color=Cfg.ESP.BoxColor; d.Box.Visible=true
            else d.Box.Visible=false end
            if Cfg.ESP.Fill then
                d.Fill.Position=Vector2.new(x,y); d.Fill.Size=Vector2.new(w,h); d.Fill.Color=Cfg.ESP.FillColor; d.Fill.Visible=true
            else d.Fill.Visible=false end
            if Cfg.ESP.Names then
                d.Name.Position=Vector2.new(x+w/2,y-16); d.Name.Text=player.DisplayName; d.Name.Color=Cfg.ESP.NameColor; d.Name.Visible=true
            else d.Name.Visible=false end
            if Cfg.ESP.Dist then
                d.Dist.Position=Vector2.new(x+w/2,y+h+3); d.Dist.Text=math.floor(dist).."m"; d.Dist.Color=Cfg.ESP.DistColor; d.Dist.Visible=true
            else d.Dist.Visible=false end
            if Cfg.ESP.HP then
                local hp,mhp=GetHP(c); local r=math.clamp(hp/mhp,0,1)
                d.HPBg.Position=Vector2.new(x-8,y); d.HPBg.Size=Vector2.new(4,h); d.HPBg.Color=Cfg.ESP.HPBgColor; d.HPBg.Visible=true
                d.HPFill.Color=Color3.new(math.clamp(2*(1-r),0,1),math.clamp(2*r,0,1),0.05)
                d.HPFill.Position=Vector2.new(x-8,y+h*(1-r)); d.HPFill.Size=Vector2.new(4,h*r); d.HPFill.Visible=true
                d.HPText.Position=Vector2.new(x-13,y+h/2-5); d.HPText.Text=math.floor(hp); d.HPText.Visible=true
            else d.HPBg.Visible=false; d.HPFill.Visible=false; d.HPText.Visible=false end
            if Cfg.ESP.Tracers then
                d.Tracer.From=Vector2.new(cx,vs.Y); d.Tracer.To=Vector2.new(x+w/2,y+h); d.Tracer.Color=Cfg.ESP.TracerColor; d.Tracer.Visible=true
            else d.Tracer.Visible=false end
            if Cfg.ESP.HeldTool then
                local tn=GetHeldTool(c)
                if tn then d.Tool.Position=Vector2.new(x+w/2,y-30); d.Tool.Text="["..tn.."]"; d.Tool.Color=Cfg.ESP.ToolColor; d.Tool.Visible=true
                else d.Tool.Visible=false end
            else d.Tool.Visible=false end
        else
            d.Box.Visible=false; d.Fill.Visible=false; d.Name.Visible=false
            d.Dist.Visible=false; d.HPBg.Visible=false; d.HPFill.Visible=false
            d.HPText.Visible=false; d.Tracer.Visible=false; d.Tool.Visible=false
        end

        -- XRAY
        local showXray=Cfg.Xray.Enabled
            and dist<=Cfg.Xray.MaxDist
            and (not Cfg.Xray.TeamCheck or not SameTeam(player))

        if showXray and bx then
            local x,y,w,h=bx,by,bw,bh
            if Cfg.Xray.Box then
                d.XBox.Position=Vector2.new(x,y); d.XBox.Size=Vector2.new(w,h); d.XBox.Color=Cfg.Xray.BoxColor; d.XBox.Visible=true
            else d.XBox.Visible=false end
            if Cfg.Xray.Fill then
                d.XFill.Position=Vector2.new(x,y); d.XFill.Size=Vector2.new(w,h); d.XFill.Color=Cfg.Xray.FillColor; d.XFill.Visible=true
            else d.XFill.Visible=false end
            if Cfg.Xray.Names then
                d.XName.Position=Vector2.new(x+w/2,y-16); d.XName.Text="["..player.DisplayName.."]"; d.XName.Color=Cfg.Xray.NameColor; d.XName.Visible=true
            else d.XName.Visible=false end
            if Cfg.Xray.Dist then
                d.XDist.Position=Vector2.new(x+w/2,y+h+3); d.XDist.Text=math.floor(dist).."m"; d.XDist.Color=Cfg.Xray.DistColor; d.XDist.Visible=true
            else d.XDist.Visible=false end
            if Cfg.Xray.HP then
                local hp,mhp=GetHP(c); local r=math.clamp(hp/mhp,0,1)
                d.XHPBg.Position=Vector2.new(x+w+4,y); d.XHPBg.Size=Vector2.new(4,h); d.XHPBg.Color=Cfg.Xray.HPBgColor; d.XHPBg.Visible=true
                d.XHPFill.Color=Cfg.Xray.HPColor
                d.XHPFill.Position=Vector2.new(x+w+4,y+h*(1-r)); d.XHPFill.Size=Vector2.new(4,h*r); d.XHPFill.Visible=true
            else d.XHPBg.Visible=false; d.XHPFill.Visible=false end
            if Cfg.Xray.Tracers then
                d.XTracer.From=Vector2.new(cx,vs.Y); d.XTracer.To=Vector2.new(x+w/2,y+h); d.XTracer.Color=Cfg.Xray.TracerColor; d.XTracer.Visible=true
            else d.XTracer.Visible=false end
            -- Skeleton
            if Cfg.Xray.Skeleton then
                local isR6=c:FindFirstChild("Torso")~=nil
                local bones=isR6 and BONES_R6 or BONES_R15
                for bi,pair in ipairs(bones) do
                    local ln=d.Skel[bi]; if not ln then continue end
                    local b1=c:FindFirstChild(pair[1]); local b2=c:FindFirstChild(pair[2])
                    if b1 and b2 then
                        local s1,ok1=W2S(b1.Position); local s2,ok2=W2S(b2.Position)
                        if ok1 or ok2 then ln.From=s1; ln.To=s2; ln.Color=Cfg.Xray.SkelColor; ln.Visible=true
                        else ln.Visible=false end
                    else ln.Visible=false end
                end
                for i=#bones+1,14 do if d.Skel[i] then d.Skel[i].Visible=false end end
            else for _,ln in ipairs(d.Skel) do ln.Visible=false end end
        else
            d.XBox.Visible=false; d.XFill.Visible=false; d.XName.Visible=false
            d.XDist.Visible=false; d.XHPBg.Visible=false; d.XHPFill.Visible=false; d.XTracer.Visible=false
            for _,ln in ipairs(d.Skel) do ln.Visible=false end
        end
    end
end))

-- Init ESP
for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(function(p) MakeESP(p); if Cfg.Misc.HitboxExtender then SetHitbox(p,true) end end)
Players.PlayerRemoving:Connect(function(p) KillESP(p); _hbConns[p]=nil end)
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed(); ApplyJump()
    if Cfg.Misc.Fly    then EnableFly()    end
    if Cfg.Misc.Noclip then EnableNoclip() end
end)

StartNoRecoil(); StartInfAmmo(); StartClickTp(); StartChatLog()
EnableSpiderMan(); EnableAquaman(); EnableNoFallDmg()

-- ============================================================
-- KEYBINDS
-- ============================================================
local _guiVisible=true
local _CBs={}
local function TR(k) if _CBs[k] then _CBs[k]() end end

AC(UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
    local kc=inp.KeyCode
    if     kc==Cfg.Settings.ToggleKey  then _guiVisible=not _guiVisible; if _G._223HUB_Win then _G._223HUB_Win.Visible=_guiVisible end
    elseif kc==Cfg.Settings.ESPKey     then Cfg.ESP.Enabled=not Cfg.ESP.Enabled; TR("ESP")
    elseif kc==Cfg.Settings.AimbotKey  then Cfg.Aim.Aimbot=not Cfg.Aim.Aimbot; TR("Aim")
    elseif kc==Cfg.Settings.FlyKey     then Cfg.Misc.Fly=not Cfg.Misc.Fly; if Cfg.Misc.Fly then EnableFly() else DisableFly() end; TR("Fly")
    elseif kc==Cfg.Settings.NoclipKey  then Cfg.Misc.Noclip=not Cfg.Misc.Noclip; if Cfg.Misc.Noclip then EnableNoclip() else DisableNoclip() end; TR("NC")
    elseif kc==Cfg.Settings.SpeedKey   then Cfg.Misc.Speed=not Cfg.Misc.Speed; ApplySpeed(); TR("Speed")
    elseif kc==Cfg.Settings.XrayKey    then Cfg.Xray.Enabled=not Cfg.Xray.Enabled; TR("Xray")
    elseif kc==Cfg.Settings.FreeCamKey then Cfg.Misc.FreeCam=not Cfg.Misc.FreeCam; if Cfg.Misc.FreeCam then EnableFreeCam() else DisableFreeCam() end; TR("FC")
    end
end))

-- ============================================================
-- GUI
-- ============================================================
if CoreGui:FindFirstChild("223TYHUB") then CoreGui:FindFirstChild("223TYHUB"):Destroy() end
local SG=Instance.new("ScreenGui")
SG.Name="223TYHUB"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset=true; SG.Parent=CoreGui

local C={
    bg0=Color3.fromRGB(7,7,10),   bg1=Color3.fromRGB(12,12,16),  bg2=Color3.fromRGB(18,18,22),
    bg3=Color3.fromRGB(26,26,31), bg4=Color3.fromRGB(34,34,40),
    red=Color3.fromRGB(165,20,20), redH=Color3.fromRGB(210,45,45), pink=Color3.fromRGB(200,55,70),
    blue=Color3.fromRGB(30,100,210), blueH=Color3.fromRGB(50,130,240),
    purple=Color3.fromRGB(115,28,195), purpleH=Color3.fromRGB(145,58,225),
    green=Color3.fromRGB(50,180,75), orange=Color3.fromRGB(220,130,40),
    gold=Color3.fromRGB(215,175,38), wht=Color3.fromRGB(255,255,255),
    text=Color3.fromRGB(208,208,213), dim=Color3.fromRGB(90,90,100), sep=Color3.fromRGB(28,28,34),
    teal=Color3.fromRGB(20,180,160), tealH=Color3.fromRGB(40,210,190),
}
local FB=Enum.Font.GothamBold; local FM=Enum.Font.Gotham; local FC=Enum.Font.Code

-- Loading Screen
local LF=Instance.new("Frame",SG); LF.Size=UDim2.new(0,920,0,520); LF.Position=UDim2.new(0.5,-460,0.5,-260)
LF.BackgroundColor3=C.bg0; LF.BorderSizePixel=0; LF.ZIndex=200
Instance.new("UICorner",LF).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",LF).Color=C.red
local function TLn(p,bot) local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,2); f.Position=bot and UDim2.new(0,0,1,-2) or UDim2.new(0,0,0,0); f.BackgroundColor3=C.red; f.BorderSizePixel=0 end
TLn(LF,false); TLn(LF,true)
local LC=Instance.new("Frame",LF); LC.Size=UDim2.new(0,420,0,180); LC.Position=UDim2.new(0.5,-210,0.5,-135); LC.BackgroundTransparency=1
local function LBL(p,t,sz,col,y,fn) local l=Instance.new("TextLabel",p); l.Text=t; l.Size=UDim2.new(1,0,0,sz); l.Position=UDim2.new(0,0,0,y); l.BackgroundTransparency=1; l.TextColor3=col; l.Font=fn or FB; l.TextSize=sz; l.TextXAlignment=Enum.TextXAlignment.Center end
LBL(LC,"◈",50,C.red,0); LBL(LC,"223HUB",42,C.wht,52); LBL(LC,"HUB BY REVOLUCIONARI'US GROUP",14,C.dim,98,FM)
LBL(LC,"SCRIPT FEITO POR BRUNO223J AND TY  ·  DISCORD: .223j | frty2017",11,C.gold,116,FM)
LBL(LC,"v10.0  ·  Public Beta",10,C.red,132,FC)
local BC=Instance.new("Frame",LF); BC.Size=UDim2.new(0,360,0,5); BC.Position=UDim2.new(0.5,-180,0.5,68); BC.BackgroundColor3=C.bg4; BC.BorderSizePixel=0; Instance.new("UICorner",BC).CornerRadius=UDim.new(1,0)
local BF=Instance.new("Frame",BC); BF.Size=UDim2.new(0,0,1,0); BF.BackgroundColor3=C.red; BF.BorderSizePixel=0; Instance.new("UICorner",BF).CornerRadius=UDim.new(1,0)
local LST=Instance.new("TextLabel",LF); LST.Size=UDim2.new(0,360,0,16); LST.Position=UDim2.new(0.5,-180,0.5,80); LST.BackgroundTransparency=1; LST.TextColor3=C.dim; LST.Font=FC; LST.TextSize=10; LST.TextXAlignment=Enum.TextXAlignment.Center; LST.Text="Inicializando..."
local LSTEPS={{0.1,"Verificando..."},{0.25,"ESP & Xray..."},{0.4,"Aimbot..."},{0.55,"Modos..."},{0.7,"Keybinds..."},{0.85,"Saves..."},{0.95,"Finalizando..."},{1.0,"Bem-vindo, "..LP.Name.."!"}}
task.spawn(function()
    local st=tick()
    while true do
        local pr=math.min((tick()-st)/4,1)
        BF.Size=UDim2.new(pr,0,1,0)
        for i=#LSTEPS,1,-1 do if pr>=LSTEPS[i][1]-0.01 then LST.Text=LSTEPS[i][2]; break end end
        if pr>=1 then break end; task.wait(0.03)
    end
end)
task.wait(4.2)
TweenService:Create(LF,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{BackgroundTransparency=1}):Play()
for _,v in ipairs(LF:GetDescendants()) do
    if v:IsA("TextLabel") then TweenService:Create(v,TweenInfo.new(0.4),{TextTransparency=1}):Play()
    elseif v:IsA("Frame") then TweenService:Create(v,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play() end
end
task.wait(0.55); LF:Destroy()

-- Main Window
local Win=Instance.new("Frame",SG)
Win.Name="Win"; Win.Size=UDim2.new(0,920,0,520); Win.Position=UDim2.new(0.5,-460,0.5,-260)
Win.BackgroundColor3=C.bg0; Win.BorderSizePixel=0; Win.Active=true; Win.Draggable=true
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",Win).Color=C.red
_G._223HUB_Win=Win

local TB=Instance.new("Frame",Win); TB.Size=UDim2.new(1,0,0,38); TB.BackgroundColor3=C.bg1; TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,6)
local _=Instance.new("Frame",TB); _.Size=UDim2.new(1,0,0,6); _.BackgroundColor3=C.bg1; _.Position=UDim2.new(0,0,1,-6); _.BorderSizePixel=0
local _=Instance.new("Frame",Win); _.Size=UDim2.new(1,0,0,1); _.Position=UDim2.new(0,0,0,38); _.BackgroundColor3=C.red; _.BorderSizePixel=0

local LG=Instance.new("Frame",TB); LG.Size=UDim2.new(0,218,1,0); LG.BackgroundTransparency=1
local _=Instance.new("TextLabel",LG); _.Text="◈"; _.Size=UDim2.new(0,30,1,0); _.Position=UDim2.new(0,8,0,0); _.BackgroundTransparency=1; _.TextColor3=C.red; _.Font=FB; _.TextSize=20
local _=Instance.new("TextLabel",LG); _.Text="223HUB"; _.Size=UDim2.new(1,-40,0,22); _.Position=UDim2.new(0,36,0,5); _.BackgroundTransparency=1; _.TextColor3=C.wht; _.Font=FB; _.TextSize=15; _.TextXAlignment=Enum.TextXAlignment.Left
local _=Instance.new("TextLabel",LG); _.Text="BRUNO223J & TY · .223j | frty2017"; _.Size=UDim2.new(1,-40,0,12); _.Position=UDim2.new(0,36,0,22); _.BackgroundTransparency=1; _.TextColor3=C.gold; _.Font=FM; _.TextSize=9; _.TextXAlignment=Enum.TextXAlignment.Left
local _=Instance.new("Frame",TB); _.Size=UDim2.new(0,1,0.55,0); _.Position=UDim2.new(0,216,0.22,0); _.BackgroundColor3=C.sep; _.BorderSizePixel=0

local MinB=Instance.new("TextButton",TB); MinB.Text="—"; MinB.Size=UDim2.new(0,28,0,22); MinB.Position=UDim2.new(1,-33,0.5,-11); MinB.BackgroundColor3=C.bg4; MinB.TextColor3=C.dim; MinB.Font=FB; MinB.TextSize=13; MinB.BorderSizePixel=0; Instance.new("UICorner",MinB).CornerRadius=UDim.new(0,4)
MinB.MouseButton1Click:Connect(function() _guiVisible=not _guiVisible; Win.Visible=_guiVisible end)

local TA=Instance.new("Frame",TB); TA.Size=UDim2.new(1,-258,1,0); TA.Position=UDim2.new(0,220,0,0); TA.BackgroundTransparency=1
local TALL=Instance.new("UIListLayout",TA); TALL.FillDirection=Enum.FillDirection.Horizontal; TALL.VerticalAlignment=Enum.VerticalAlignment.Center; TALL.Padding=UDim.new(0,1)
local CF=Instance.new("Frame",Win); CF.Size=UDim2.new(1,-16,1,-52); CF.Position=UDim2.new(0,8,0,48); CF.BackgroundTransparency=1; CF.BorderSizePixel=0

-- UI Components
local function Panel(parent,title,x,y,w,h,ac)
    local f=Instance.new("Frame",parent); f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h); f.BackgroundColor3=C.bg2; f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",f).Color=C.sep
    local ph=Instance.new("Frame",f); ph.Size=UDim2.new(1,0,0,28); ph.BackgroundColor3=C.bg1; ph.BorderSizePixel=0; Instance.new("UICorner",ph).CornerRadius=UDim.new(0,5)
    local _=Instance.new("Frame",ph); _.Size=UDim2.new(1,0,0,6); _.BackgroundColor3=C.bg1; _.Position=UDim2.new(0,0,1,-6); _.BorderSizePixel=0
    local acc=Instance.new("Frame",ph); acc.Size=UDim2.new(0,3,0.6,0); acc.Position=UDim2.new(0,6,0.2,0); acc.BackgroundColor3=ac or C.red; acc.BorderSizePixel=0; Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
    local tl=Instance.new("TextLabel",ph); tl.Text=title; tl.Size=UDim2.new(1,-20,1,0); tl.Position=UDim2.new(0,14,0,0); tl.BackgroundTransparency=1; tl.TextColor3=C.text; tl.Font=FB; tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left
    local sc=Instance.new("ScrollingFrame",f); sc.Size=UDim2.new(1,-12,1,-32); sc.Position=UDim2.new(0,6,0,30); sc.BackgroundTransparency=1; sc.BorderSizePixel=0; sc.ScrollBarThickness=3; sc.ScrollBarImageColor3=ac or C.red; sc.CanvasSize=UDim2.new(0,0,0,0); sc.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local ll=Instance.new("UIListLayout",sc); ll.Padding=UDim.new(0,3); ll.SortOrder=Enum.SortOrder.LayoutOrder
    return sc
end

local function Toggle(parent,label,order,getV,setV,cbKey,ac)
    local col=ac or C.pink
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,26); f.BackgroundColor3=C.bg3; f.BorderSizePixel=0; f.LayoutOrder=order
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
    local chk=Instance.new("Frame",f); chk.Size=UDim2.new(0,16,0,16); chk.Position=UDim2.new(0,7,0.5,-8); chk.BackgroundColor3=C.bg4; chk.BorderSizePixel=0; Instance.new("UICorner",chk).CornerRadius=UDim.new(0,4)
    local cS=Instance.new("UIStroke",chk); cS.Color=C.sep; cS.Thickness=1
    local ck=Instance.new("TextLabel",chk); ck.Text="✓"; ck.Size=UDim2.new(1,0,1,0); ck.BackgroundTransparency=1; ck.TextColor3=col; ck.Font=FB; ck.TextSize=13
    local lb=Instance.new("TextLabel",f); lb.Text=label; lb.Size=UDim2.new(1,-36,1,0); lb.Position=UDim2.new(0,30,0,0); lb.BackgroundTransparency=1; lb.TextColor3=C.text; lb.Font=FM; lb.TextSize=12; lb.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    local function ref()
        local v=getV()
        ck.Visible=v
        chk.BackgroundColor3=v and Color3.fromRGB(30,8,30) or C.bg4
        cS.Color=v and col or C.sep
        f.BackgroundColor3=v and Color3.fromRGB(20,6,20) or C.bg3
    end
    if cbKey then _CBs[cbKey]=ref end
    btn.MouseButton1Click:Connect(function() setV(not getV()); ref() end)
    btn.MouseEnter:Connect(function() if not getV() then f.BackgroundColor3=C.bg4 end end)
    btn.MouseLeave:Connect(function() if not getV() then f.BackgroundColor3=C.bg3 end end)
    ref()
end

local _drag=nil
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _drag=nil end end)
UIS.InputChanged:Connect(function(i)
    if _drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local s=_drag; local r=math.clamp((i.Position.X-s.bar.AbsolutePosition.X)/s.bar.AbsoluteSize.X,0,1)
        local v=math.floor(s.mn+r*(s.mx-s.mn)); s.fill.Size=UDim2.new(r,0,1,0); s.vl.Text=v.." / "..s.mx; s.cb(v)
    end
end)

local function Slider(parent,label,mn,mx,def,order,cb)
    local cur=def
    local hf=Instance.new("Frame",parent); hf.Size=UDim2.new(1,0,0,16); hf.BackgroundTransparency=1; hf.LayoutOrder=order
    local hl=Instance.new("TextLabel",hf); hl.Text=label; hl.Size=UDim2.new(1,-38,1,0); hl.BackgroundTransparency=1; hl.TextColor3=C.dim; hl.Font=FM; hl.TextSize=11; hl.TextXAlignment=Enum.TextXAlignment.Left
    local bm=Instance.new("TextButton",hf); bm.Text="-"; bm.Size=UDim2.new(0,16,1,0); bm.Position=UDim2.new(1,-34,0,0); bm.BackgroundTransparency=1; bm.TextColor3=C.dim; bm.Font=FB; bm.TextSize=14; bm.BorderSizePixel=0
    local bp=Instance.new("TextButton",hf); bp.Text="+"; bp.Size=UDim2.new(0,16,1,0); bp.Position=UDim2.new(1,-16,0,0); bp.BackgroundTransparency=1; bp.TextColor3=C.dim; bp.Font=FB; bp.TextSize=14; bp.BorderSizePixel=0
    local bf=Instance.new("Frame",parent); bf.Size=UDim2.new(1,0,0,18); bf.BackgroundTransparency=1; bf.LayoutOrder=order+1
    local bar=Instance.new("Frame",bf); bar.Size=UDim2.new(1,0,0,18); bar.BackgroundColor3=C.bg4; bar.BorderSizePixel=0; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local r0=math.clamp((def-mn)/(mx-mn),0,1)
    local fill=Instance.new("Frame",bar); fill.Size=UDim2.new(r0,0,1,0); fill.BackgroundColor3=C.pink; fill.BorderSizePixel=0; Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3)
    local vl=Instance.new("TextLabel",bar); vl.Text=def.." / "..mx; vl.Size=UDim2.new(1,0,1,0); vl.BackgroundTransparency=1; vl.TextColor3=C.text; vl.Font=FC; vl.TextSize=10; vl.TextXAlignment=Enum.TextXAlignment.Center
    local sd={bar=bar,fill=fill,vl=vl,mn=mn,mx=mx,cb=function(v) cur=v; cb(v) end}
    local ib=Instance.new("TextButton",bar); ib.Size=UDim2.new(1,0,1,0); ib.BackgroundTransparency=1; ib.Text=""
    ib.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _drag=sd end end)
    bm.MouseButton1Click:Connect(function() cur=math.max(mn,cur-1); fill.Size=UDim2.new((cur-mn)/(mx-mn),0,1,0); vl.Text=cur.." / "..mx; cb(cur) end)
    bp.MouseButton1Click:Connect(function() cur=math.min(mx,cur+1); fill.Size=UDim2.new((cur-mn)/(mx-mn),0,1,0); vl.Text=cur.." / "..mx; cb(cur) end)
end

local function Sel(parent,lbl,opts,def,order,cb)
    local idx=1; for i,v in ipairs(opts) do if v==def then idx=i end end
    local lf=Instance.new("Frame",parent); lf.Size=UDim2.new(1,0,0,13); lf.BackgroundTransparency=1; lf.LayoutOrder=order
    local ll=Instance.new("TextLabel",lf); ll.Text=lbl; ll.Size=UDim2.new(1,0,1,0); ll.BackgroundTransparency=1; ll.TextColor3=C.dim; ll.Font=FM; ll.TextSize=10; ll.TextXAlignment=Enum.TextXAlignment.Left
    local rf=Instance.new("Frame",parent); rf.Size=UDim2.new(1,0,0,26); rf.BackgroundTransparency=1; rf.LayoutOrder=order+1
    local box=Instance.new("Frame",rf); box.Size=UDim2.new(1,0,1,0); box.BackgroundColor3=C.bg3; box.BorderSizePixel=0; Instance.new("UICorner",box).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",box).Color=C.sep
    local vl=Instance.new("TextLabel",box); vl.Text=opts[idx]; vl.Size=UDim2.new(1,-28,1,0); vl.Position=UDim2.new(0,8,0,0); vl.BackgroundTransparency=1; vl.TextColor3=C.text; vl.Font=FM; vl.TextSize=12; vl.TextXAlignment=Enum.TextXAlignment.Left
    local pl=Instance.new("TextButton",box); pl.Text="▸"; pl.Size=UDim2.new(0,26,1,0); pl.Position=UDim2.new(1,-26,0,0); pl.BackgroundColor3=C.bg4; pl.TextColor3=C.text; pl.Font=FB; pl.TextSize=12; pl.BorderSizePixel=0; Instance.new("UICorner",pl).CornerRadius=UDim.new(0,4)
    pl.MouseButton1Click:Connect(function() idx=idx%#opts+1; vl.Text=opts[idx]; cb(opts[idx]) end)
end

local function KB(parent,label,order,getN,onSet)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,26); f.BackgroundColor3=C.bg3; f.BorderSizePixel=0; f.LayoutOrder=order; Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
    local lb=Instance.new("TextLabel",f); lb.Text=label; lb.Size=UDim2.new(1,-80,1,0); lb.Position=UDim2.new(0,8,0,0); lb.BackgroundTransparency=1; lb.TextColor3=C.text; lb.Font=FM; lb.TextSize=12; lb.TextXAlignment=Enum.TextXAlignment.Left
    local bdg=Instance.new("TextButton",f); bdg.Size=UDim2.new(0,68,0,18); bdg.Position=UDim2.new(1,-72,0.5,-9); bdg.BackgroundColor3=C.bg4; bdg.TextColor3=C.text; bdg.Font=FC; bdg.TextSize=11; bdg.BorderSizePixel=0; bdg.Text="["..getN().."]"
    Instance.new("UICorner",bdg).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",bdg).Color=C.sep
    local listening=false
    bdg.MouseButton1Click:Connect(function()
        if listening then return end; listening=true; bdg.Text="[ ? ]"; bdg.TextColor3=C.pink
        local cn; cn=UIS.InputBegan:Connect(function(inp,gp)
            if gp then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                cn:Disconnect(); listening=false
                bdg.Text="["..inp.KeyCode.Name.."]"; bdg.TextColor3=C.text
                onSet(inp.KeyCode,inp.KeyCode.Name)
            end
        end)
    end)
end

local function Btn(parent,text,order,cb,bg,tc)
    local b=Instance.new("TextButton",parent); b.Text=text; b.Size=UDim2.new(1,0,0,28)
    local bgc=bg or Color3.fromRGB(35,8,8)
    b.BackgroundColor3=bgc; b.TextColor3=tc or C.redH; b.Font=FM; b.TextSize=12; b.BorderSizePixel=0; b.LayoutOrder=order
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    b.MouseEnter:Connect(function() b.BackgroundColor3=Color3.fromRGB(math.min(bgc.R*255+20,255),math.min(bgc.G*255+10,255),math.min(bgc.B*255+10,255)) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3=bgc end)
    b.MouseButton1Click:Connect(cb); return b
end

local function Sep(p,o) local s=Instance.new("Frame",p); s.Size=UDim2.new(1,0,0,1); s.BackgroundColor3=C.sep; s.BorderSizePixel=0; s.LayoutOrder=o end
local function SL(p,t,o,c) local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,15); f.BackgroundTransparency=1; f.LayoutOrder=o; local l=Instance.new("TextLabel",f); l.Text=t; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=c or C.red; l.Font=FB; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left end
local function IL(p,t,o,c) local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,15); f.BackgroundTransparency=1; f.LayoutOrder=o; local l=Instance.new("TextLabel",f); l.Text=t; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=c or C.text; l.Font=FM; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left end
local function IFld(parent,ph,order,onChange)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,28); f.BackgroundTransparency=1; f.LayoutOrder=order
    local bx=Instance.new("TextBox",f); bx.PlaceholderText=ph; bx.Text=""; bx.Size=UDim2.new(1,0,1,0); bx.BackgroundColor3=C.bg3; bx.TextColor3=C.text; bx.PlaceholderColor3=C.dim; bx.Font=FM; bx.TextSize=12; bx.BorderSizePixel=0; bx.ClearTextOnFocus=false
    Instance.new("UICorner",bx).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",bx).Color=C.sep; Instance.new("UIPadding",bx).PaddingLeft=UDim.new(0,7)
    bx.FocusLost:Connect(function() onChange(bx.Text) end); return bx
end
local function StatusLbl(parent,order)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,18); f.BackgroundTransparency=1; f.LayoutOrder=order
    local l=Instance.new("TextLabel",f); l.Text=""; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.green; l.Font=FM; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left
    return function(msg,col) l.Text=msg; l.TextColor3=col or C.green; task.delay(3,function() if l.Text==msg then l.Text="" end end) end
end

local function EnableBadge(parent,order,label,tag,getCfg,setCfg,cbKey,ac)
    local acol=ac or C.red
    local er=Instance.new("Frame",parent); er.Size=UDim2.new(1,0,0,28); er.BackgroundColor3=Color3.fromRGB(22,6,6); er.BorderSizePixel=0; er.LayoutOrder=order; Instance.new("UICorner",er).CornerRadius=UDim.new(0,4)
    local ec=Instance.new("Frame",er); ec.Size=UDim2.new(0,16,0,16); ec.Position=UDim2.new(0,7,0.5,-8); ec.BackgroundColor3=C.bg4; ec.BorderSizePixel=0; Instance.new("UICorner",ec).CornerRadius=UDim.new(0,4)
    local eS=Instance.new("UIStroke",ec); eS.Color=C.sep; eS.Thickness=1
    local eTk=Instance.new("TextLabel",ec); eTk.Text="✓"; eTk.Size=UDim2.new(1,0,1,0); eTk.BackgroundTransparency=1; eTk.TextColor3=acol; eTk.Font=FB; eTk.TextSize=13
    local eL=Instance.new("TextLabel",er); eL.Text=label; eL.Size=UDim2.new(1,-56,1,0); eL.Position=UDim2.new(0,30,0,0); eL.BackgroundTransparency=1; eL.TextColor3=C.wht; eL.Font=FB; eL.TextSize=13; eL.TextXAlignment=Enum.TextXAlignment.Left
    local eBg=Instance.new("TextLabel",er); eBg.Text=tag; eBg.Size=UDim2.new(0,40,0,16); eBg.Position=UDim2.new(1,-44,0.5,-8); eBg.BackgroundColor3=acol; eBg.TextColor3=C.wht; eBg.Font=FB; eBg.TextSize=9; eBg.BorderSizePixel=0; Instance.new("UICorner",eBg).CornerRadius=UDim.new(0,4)
    local eBtn=Instance.new("TextButton",er); eBtn.Size=UDim2.new(1,0,1,0); eBtn.BackgroundTransparency=1; eBtn.Text=""
    local function ref()
        local v=getCfg()
        eTk.Visible=v
        ec.BackgroundColor3=v and Color3.fromRGB(35,7,7) or C.bg4
        eS.Color=v and acol or C.sep
        er.BackgroundColor3=v and Color3.fromRGB(35,9,9) or Color3.fromRGB(22,6,6)
    end
    if cbKey then _CBs[cbKey]=ref end
    eBtn.MouseButton1Click:Connect(function() setCfg(not getCfg()); ref() end)
    ref()
end

local function PLWidget(parent,startOrder,title,data,ac)
    local col=ac or C.red
    Sep(parent,startOrder); SL(parent,title,startOrder+1,col)
    local ar=Instance.new("Frame",parent); ar.Size=UDim2.new(1,0,0,28); ar.BackgroundTransparency=1; ar.LayoutOrder=startOrder+2
    local ab=Instance.new("TextBox",ar); ab.PlaceholderText="Username..."; ab.Text=""; ab.Size=UDim2.new(1,-54,1,0); ab.BackgroundColor3=C.bg3; ab.TextColor3=C.text; ab.PlaceholderColor3=C.dim; ab.Font=FM; ab.TextSize=12; ab.BorderSizePixel=0; ab.ClearTextOnFocus=false
    Instance.new("UICorner",ab).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",ab).Color=C.sep; Instance.new("UIPadding",ab).PaddingLeft=UDim.new(0,7)
    local abtn=Instance.new("TextButton",ar); abtn.Text="+ Add"; abtn.Size=UDim2.new(0,48,1,0); abtn.Position=UDim2.new(1,-48,0,0); abtn.BackgroundColor3=col; abtn.TextColor3=C.wht; abtn.Font=FB; abtn.TextSize=11; abtn.BorderSizePixel=0; Instance.new("UICorner",abtn).CornerRadius=UDim.new(0,4)
    local lh=Instance.new("Frame",parent); lh.Size=UDim2.new(1,0,0,90); lh.BackgroundColor3=C.bg4; lh.BorderSizePixel=0; lh.LayoutOrder=startOrder+3; Instance.new("UICorner",lh).CornerRadius=UDim.new(0,4)
    local ls=Instance.new("ScrollingFrame",lh); ls.Size=UDim2.new(1,-8,1,-8); ls.Position=UDim2.new(0,4,0,4); ls.BackgroundTransparency=1; ls.BorderSizePixel=0; ls.ScrollBarThickness=2; ls.ScrollBarImageColor3=col; ls.CanvasSize=UDim2.new(0,0,0,0); ls.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",ls).Padding=UDim.new(0,2)
    local sf=Instance.new("Frame",parent); sf.Size=UDim2.new(1,0,0,14); sf.BackgroundTransparency=1; sf.LayoutOrder=startOrder+4
    local sl=Instance.new("TextLabel",sf); sl.Size=UDim2.new(1,0,1,0); sl.BackgroundTransparency=1; sl.TextColor3=C.dim; sl.Font=FM; sl.TextSize=10; sl.TextXAlignment=Enum.TextXAlignment.Left
    local function US() local n=0; for _ in pairs(data) do n=n+1 end; sl.Text=n==0 and "Vazio" or n.." na lista" end
    local function Rb()
        for _,ch in ipairs(ls:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end
        local any=false
        for name in pairs(data) do
            any=true
            local row=Instance.new("Frame",ls); row.Size=UDim2.new(1,0,0,20); row.BackgroundTransparency=1
            local nl=Instance.new("TextLabel",row); nl.Text="· "..name; nl.Size=UDim2.new(1,-28,1,0); nl.BackgroundTransparency=1; nl.TextColor3=C.text; nl.Font=FM; nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left
            local rb=Instance.new("TextButton",row); rb.Text="✕"; rb.Size=UDim2.new(0,22,0,16); rb.Position=UDim2.new(1,-22,0.5,-8); rb.BackgroundColor3=Color3.fromRGB(55,10,10); rb.TextColor3=C.redH; rb.Font=FB; rb.TextSize=11; rb.BorderSizePixel=0; Instance.new("UICorner",rb).CornerRadius=UDim.new(0,3)
            local cap=name; rb.MouseButton1Click:Connect(function() data[cap]=nil; row:Destroy(); US() end)
        end
        if not any then local el=Instance.new("TextLabel",ls); el.Text="(vazio)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left end
        US()
    end
    abtn.MouseButton1Click:Connect(function()
        local q=ab.Text:gsub("%s+",""); if q=="" then return end
        local found=q
        for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower()==q:lower() or p.DisplayName:lower()==q:lower() then found=p.Name; break end end
        data[found]=true; ab.Text=""; Rb()
    end)
    Rb(); return Rb
end

-- Tab System
local _pages={}; local _curTab=nil
local function MakeTab(name,order,col)
    local btn=Instance.new("TextButton",TA); btn.Text=name:upper(); btn.Size=UDim2.new(0,74,0,38); btn.BackgroundTransparency=1; btn.TextColor3=C.dim; btn.Font=FB; btn.TextSize=11; btn.BorderSizePixel=0; btn.LayoutOrder=order
    local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(0.75,0,0,2); ul.Position=UDim2.new(0.125,0,1,-2); ul.BackgroundColor3=col or C.redH; ul.BorderSizePixel=0; ul.Visible=false
    local pg=Instance.new("Frame",CF); pg.Size=UDim2.new(1,0,1,0); pg.BackgroundTransparency=1; pg.Visible=false
    _pages[name]={btn=btn,ul=ul,pg=pg}
    btn.MouseButton1Click:Connect(function()
        if _curTab then _pages[_curTab].btn.TextColor3=C.dim; _pages[_curTab].ul.Visible=false; _pages[_curTab].pg.Visible=false end
        _curTab=name; btn.TextColor3=C.wht; ul.Visible=true; pg.Visible=true
    end)
    return pg
end

local PMain    = MakeTab("Main",    1)
local PVis     = MakeTab("Visuals", 2)
local PXray    = MakeTab("Xray",    3, C.blueH)
local PMisc    = MakeTab("Misc",    4)
local PModes   = MakeTab("Modos",   5, C.tealH)
local PTroll   = MakeTab("Troll",   6, C.purpleH)
local PSettings= MakeTab("Settings",7)
_pages["Main"].btn.TextColor3=C.wht; _pages["Main"].ul.Visible=true; _pages["Main"].pg.Visible=true; _curTab="Main"

-- ============================================================
-- PAGE: MAIN — Aimbot | FOV | TriggerBot
-- ============================================================
local AimP = Panel(PMain,"Aimbot",      0,  0,435,468)
local FovP = Panel(PMain,"FOV Circle",443,  0,435,215)
local TrgP = Panel(PMain,"TriggerBot", 443,223,435,175)

Toggle(AimP,"Aimbot",            0,function() return Cfg.Aim.Aimbot     end,function(v) Cfg.Aim.Aimbot=v      end,"Aim")
Toggle(AimP,"Wall Check",        1,function() return Cfg.Aim.WallCheck  end,function(v) Cfg.Aim.WallCheck=v   end)
Toggle(AimP,"Team Check",        2,function() return Cfg.Aim.TeamCheck  end,function(v) Cfg.Aim.TeamCheck=v   end)
Toggle(AimP,"Prediction",        3,function() return Cfg.Aim.Prediction end,function(v) Cfg.Aim.Prediction=v  end)
Slider(AimP,"Prediction Strength",1,10,1,4,function(v) Cfg.Aim.PredStr=v end)
Sel(AimP,"Target Part",{"Head","HumanoidRootPart","Torso","LeftLowerArm","RightLowerArm"},"Head",7,function(v) Cfg.Aim.AimPart=v end)
Slider(AimP,"Smoothness",1,100,15,10,function(v) Cfg.Aim.Smoothness=v end)
Sep(AimP,13); SL(AimP,"AUXÍLIOS DE MIRA",14)
Toggle(AimP,"No Recoil",        15,function() return Cfg.Aim.NoRecoil   end,function(v) Cfg.Aim.NoRecoil=v    end)
Toggle(AimP,"Fast Reload",      16,function() return Cfg.Aim.FastReload end,function(v) Cfg.Aim.FastReload=v  end)
Toggle(AimP,"Infinite Ammo",    17,function() return Cfg.Aim.InfAmmo    end,function(v) Cfg.Aim.InfAmmo=v     end)
KB(AimP,"Aim Key (segurar)",19,function() return Cfg.Aim.AimKeyName end,function(k,n) Cfg.Aim.AimKey=k; Cfg.Aim.AimKeyName=n end)
PLWidget(AimP,21,"LISTA DE EXCLUSÃO",Cfg.Aim.Blacklist)

Toggle(FovP,"Show FOV (sempre visível)",0,function() return Cfg.Aim.ShowFOV   end,function(v) Cfg.Aim.ShowFOV=v   end)
Toggle(FovP,"Usar FOV no Aimbot",       1,function() return Cfg.Aim.UseFOV    end,function(v) Cfg.Aim.UseFOV=v    end)
Toggle(FovP,"FOV Segue o Mouse",        2,function() return Cfg.Aim.FOVFollow end,function(v) Cfg.Aim.FOVFollow=v end)
Slider(FovP,"FOV Size (pixels)",10,800,120,4,function(v) Cfg.Aim.FOV=v end)
Slider(FovP,"FOV Thickness",1,5,2,7,function(v) FOVC.Thickness=v end)

Toggle(TrgP,"TriggerBot",   0,function() return Cfg.Trigger.Enabled   end,function(v) Cfg.Trigger.Enabled=v   end)
Toggle(TrgP,"Team Check",   1,function() return Cfg.Trigger.TeamCheck end,function(v) Cfg.Trigger.TeamCheck=v end)
Slider(TrgP,"Delay (ms)",0,2000,100,3,function(v) Cfg.Trigger.Delay=v end)

-- ============================================================
-- PAGE: VISUALS
-- ============================================================
local EspP  = Panel(PVis,"ESP",         0,  0,435,468)
local TrackP= Panel(PVis,"Track Player",443,0,435,468)

EnableBadge(EspP,0,"ESP Enabled","ESP",function() return Cfg.ESP.Enabled end,function(v) Cfg.ESP.Enabled=v end,"ESP")
Toggle(EspP,"Box ESP",          1,function() return Cfg.ESP.Box       end,function(v) Cfg.ESP.Box=v       end)
Toggle(EspP,"Fill Box",         2,function() return Cfg.ESP.Fill      end,function(v) Cfg.ESP.Fill=v      end)
Toggle(EspP,"Name ESP",         3,function() return Cfg.ESP.Names     end,function(v) Cfg.ESP.Names=v     end)
Toggle(EspP,"Health Bar",       4,function() return Cfg.ESP.HP        end,function(v) Cfg.ESP.HP=v        end)
Toggle(EspP,"Tracers",          5,function() return Cfg.ESP.Tracers   end,function(v) Cfg.ESP.Tracers=v   end)
Toggle(EspP,"Distance",         6,function() return Cfg.ESP.Dist      end,function(v) Cfg.ESP.Dist=v      end)
Toggle(EspP,"Wall Check",       7,function() return Cfg.ESP.WallCheck end,function(v) Cfg.ESP.WallCheck=v end)
Toggle(EspP,"Team Check",       8,function() return Cfg.ESP.TeamCheck end,function(v) Cfg.ESP.TeamCheck=v end)
Toggle(EspP,"Item na Mão",      9,function() return Cfg.ESP.HeldTool  end,function(v) Cfg.ESP.HeldTool=v  end)
Slider(EspP,"Max Distance",50,2000,500,11,function(v) Cfg.ESP.MaxDist=v end)

do
    local rb=PLWidget(TrackP,0,"JOGADORES RASTREADOS",Cfg.ESP.TrackList)
    Sep(TrackP,6); SL(TrackP,"SERVIDOR",7)
    local onlS=Instance.new("ScrollingFrame",TrackP); onlS.Size=UDim2.new(1,0,0,160); onlS.BackgroundColor3=C.bg4; onlS.BorderSizePixel=0; onlS.LayoutOrder=8; Instance.new("UICorner",onlS).CornerRadius=UDim.new(0,4); onlS.ScrollBarThickness=2; onlS.ScrollBarImageColor3=C.red; onlS.CanvasSize=UDim2.new(0,0,0,0); onlS.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",onlS).Padding=UDim.new(0,2)
    local op=Instance.new("UIPadding",onlS); op.PaddingLeft=UDim.new(0,4); op.PaddingTop=UDim.new(0,4); op.PaddingRight=UDim.new(0,4)
    local function RefOnl()
        for _,c in ipairs(onlS:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local row=Instance.new("Frame",onlS); row.Size=UDim2.new(1,0,0,26); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
            local pN=Instance.new("TextLabel",row); pN.Text=p.Name; pN.Size=UDim2.new(1,-58,1,0); pN.Position=UDim2.new(0,6,0,0); pN.BackgroundTransparency=1; pN.TextColor3=C.text; pN.Font=FM; pN.TextSize=11; pN.TextXAlignment=Enum.TextXAlignment.Left
            local tB=Instance.new("TextButton",row); tB.Size=UDim2.new(0,50,0,18); tB.Position=UDim2.new(1,-53,0.5,-9); tB.BackgroundColor3=Cfg.ESP.TrackList[p.Name] and C.red or C.bg4; tB.Text=Cfg.ESP.TrackList[p.Name] and "Untrack" or "Track"; tB.TextColor3=C.wht; tB.Font=FB; tB.TextSize=9; tB.BorderSizePixel=0; Instance.new("UICorner",tB).CornerRadius=UDim.new(0,3)
            local cap=p
            tB.MouseButton1Click:Connect(function()
                if Cfg.ESP.TrackList[cap.Name] then Cfg.ESP.TrackList[cap.Name]=nil; tB.BackgroundColor3=C.bg4; tB.Text="Track"
                else Cfg.ESP.TrackList[cap.Name]=true; tB.BackgroundColor3=C.red; tB.Text="Untrack" end
                rb()
            end)
        end
    end
    Btn(TrackP,"↺ Atualizar Lista",9,RefOnl); RefOnl()
end

-- ============================================================
-- PAGE: XRAY
-- ============================================================
local XrayP=Panel(PXray,"Xray (Wallhack)",0,0,435,468,C.blue)
local SkelP=Panel(PXray,"Skeleton",443,0,435,260,C.blue)

EnableBadge(XrayP,0,"Xray Enabled","XRAY",function() return Cfg.Xray.Enabled end,function(v) Cfg.Xray.Enabled=v end,"Xray",C.blue)
Toggle(XrayP,"Box ESP",    1,function() return Cfg.Xray.Box       end,function(v) Cfg.Xray.Box=v       end,nil,C.blueH)
Toggle(XrayP,"Fill Box",   2,function() return Cfg.Xray.Fill      end,function(v) Cfg.Xray.Fill=v      end,nil,C.blueH)
Toggle(XrayP,"Name ESP",   3,function() return Cfg.Xray.Names     end,function(v) Cfg.Xray.Names=v     end,nil,C.blueH)
Toggle(XrayP,"Health Bar", 4,function() return Cfg.Xray.HP        end,function(v) Cfg.Xray.HP=v        end,nil,C.blueH)
Toggle(XrayP,"Tracers",    5,function() return Cfg.Xray.Tracers   end,function(v) Cfg.Xray.Tracers=v   end,nil,C.blueH)
Toggle(XrayP,"Distance",   6,function() return Cfg.Xray.Dist      end,function(v) Cfg.Xray.Dist=v      end,nil,C.blueH)
Toggle(XrayP,"Team Check", 7,function() return Cfg.Xray.TeamCheck end,function(v) Cfg.Xray.TeamCheck=v end,nil,C.blueH)
Slider(XrayP,"Max Distance",50,5000,1000,9,function(v) Cfg.Xray.MaxDist=v end)
Toggle(SkelP,"Skeleton",   0,function() return Cfg.Xray.Skeleton  end,function(v) Cfg.Xray.Skeleton=v  end,nil,C.blueH)

-- ============================================================
-- PAGE: MISC
-- ============================================================
local MovP  = Panel(PMisc,"Movimento & Física", 0,  0,435,468)
local UtilP = Panel(PMisc,"Utilidades & Server",443,0,435,468)

SL(MovP,"VOAR",0)
Toggle(MovP,"Fly",           1,function() return Cfg.Misc.Fly      end,function(v) Cfg.Misc.Fly=v;    if v then EnableFly()    else DisableFly()    end end,"Fly")
Toggle(MovP,"Fly Boost (3x)",2,function() return Cfg.Misc.FlyBoost end,function(v) Cfg.Misc.FlyBoost=v end)
Slider(MovP,"Fly Speed",1,500,50,3,function(v) Cfg.Misc.FlySpeed=v end)
Sep(MovP,6); SL(MovP,"MOVIMENTO",7)
Toggle(MovP,"Noclip",        8,function() return Cfg.Misc.Noclip   end,function(v) Cfg.Misc.Noclip=v; if v then EnableNoclip() else DisableNoclip() end end,"NC")
Toggle(MovP,"Speed Hack",   10,function() return Cfg.Misc.Speed    end,function(v) Cfg.Misc.Speed=v;  ApplySpeed() end,"Speed")
Slider(MovP,"Walk Speed",1,1000,25,12,function(v) Cfg.Misc.WalkSpeed=v; if Cfg.Misc.Speed then ApplySpeed() end end)
Sep(MovP,15); SL(MovP,"PULO",16)
Toggle(MovP,"Jump Modifier",17,function() return Cfg.Misc.JumpMod  end,function(v) Cfg.Misc.JumpMod=v; ApplyJump() end)
Toggle(MovP,"Infinite Jump",18,function() return Cfg.Misc.InfJump  end,function(v) Cfg.Misc.InfJump=v end)
Sel(MovP,"Jump Method",{"JumpPower","UseJumpPower"},"JumpPower",20,function(v) Cfg.Misc.JumpMethod=v; ApplyJump() end)
Slider(MovP,"Jump Power",1,500,80,22,function(v) Cfg.Misc.JumpPower=v; if Cfg.Misc.JumpMod then ApplyJump() end end)
Sep(MovP,25); SL(MovP,"OUTROS",26)
Toggle(MovP,"Anti Ragdoll", 27,function() return Cfg.Misc.AntiRag  end,function(v) Cfg.Misc.AntiRag=v  end)
Toggle(MovP,"Click Teleport",28,function() return Cfg.Misc.ClickTp end,function(v) Cfg.Misc.ClickTp=v  end)
Toggle(MovP,"Anti-AFK",     29,function() return Cfg.Misc.AntiAFK  end,function(v) Cfg.Misc.AntiAFK=v  end)

SL(UtilP,"HITBOX",0)
Toggle(UtilP,"Hitbox Extender",  1,function() return Cfg.Misc.HitboxExtender end,function(v) Cfg.Misc.HitboxExtender=v; RefreshHitboxes() end)
Slider(UtilP,"Hitbox Size",1,80,8,3,function(v) Cfg.Misc.HitboxSize=v; if Cfg.Misc.HitboxExtender then RefreshHitboxes() end end)
Sel(UtilP,"Parte da Hitbox",{"All","Head","Torso","Arms","Legs","HRP Only"},"All",5,function(v) Cfg.Misc.HitboxPart=v; if Cfg.Misc.HitboxExtender then RefreshHitboxes() end end)
Sep(UtilP,8); SL(UtilP,"CÂMERA LIVRE",9)
Toggle(UtilP,"FreeCam",         10,function() return Cfg.Misc.FreeCam end,function(v) Cfg.Misc.FreeCam=v; if v then EnableFreeCam() else DisableFreeCam() end end,"FC")
Slider(UtilP,"FreeCam Speed",1,30,1,12,function(v) Cfg.Misc.FCamSpeed=v end)
do local f=Instance.new("Frame",UtilP); f.Size=UDim2.new(1,0,0,13); f.BackgroundTransparency=1; f.LayoutOrder=14; local l=Instance.new("TextLabel",f); l.Text="W/A/S/D mover · E subir · Q descer"; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left end
Sep(UtilP,15); SL(UtilP,"TOOLS DO MAPA",16)
do
    local gs=StatusLbl(UtilP,17)
    local tlH=Instance.new("Frame",UtilP); tlH.Size=UDim2.new(1,0,0,100); tlH.BackgroundColor3=C.bg4; tlH.BorderSizePixel=0; tlH.LayoutOrder=18; Instance.new("UICorner",tlH).CornerRadius=UDim.new(0,4)
    local tlS=Instance.new("ScrollingFrame",tlH); tlS.Size=UDim2.new(1,-8,1,-8); tlS.Position=UDim2.new(0,4,0,4); tlS.BackgroundTransparency=1; tlS.BorderSizePixel=0; tlS.ScrollBarThickness=2; tlS.ScrollBarImageColor3=C.red; tlS.CanvasSize=UDim2.new(0,0,0,0); tlS.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",tlS).Padding=UDim.new(0,2)
    local function RefTools()
        for _,c in ipairs(tlS:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        local tools=GetMapTools()
        if #tools==0 then local el=Instance.new("TextLabel",tlS); el.Text="(nenhuma tool no mapa)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left; return end
        for _,entry in ipairs(tools) do
            local row=Instance.new("Frame",tlS); row.Size=UDim2.new(1,0,0,24); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
            local nl=Instance.new("TextLabel",row); nl.Text="🔧 "..entry.name; nl.Size=UDim2.new(1,-60,1,0); nl.Position=UDim2.new(0,6,0,0); nl.BackgroundTransparency=1; nl.TextColor3=C.text; nl.Font=FM; nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left
            local gb=Instance.new("TextButton",row); gb.Text="Pegar"; gb.Size=UDim2.new(0,52,0,18); gb.Position=UDim2.new(1,-55,0.5,-9); gb.BackgroundColor3=C.red; gb.TextColor3=C.wht; gb.Font=FB; gb.TextSize=10; gb.BorderSizePixel=0; Instance.new("UICorner",gb).CornerRadius=UDim.new(0,3)
            local cap=entry.tool
            gb.MouseButton1Click:Connect(function()
                local bp=LP:FindFirstChild("Backpack")
                if bp then pcall(function() cap.Parent=bp end); gs("✓ "..entry.name,C.green) else gs("❌ Falhou",C.redH) end
            end)
        end
    end
    Btn(UtilP,"🔧 Pegar Mais Próxima",19,function()
        local n=GrabNearestTool(); gs(n and "✓ "..n or "❌ Nenhuma",n and C.green or C.redH)
    end,Color3.fromRGB(20,50,20))
    Btn(UtilP,"↺ Listar Tools do Mapa",20,RefTools,Color3.fromRGB(12,35,55),C.blueH)
end
Sep(UtilP,22); SL(UtilP,"BOOMBOX",23)
do
    local bbBox=IFld(UtilP,"ID da Música...",24,function(v) Cfg.Misc.BoomboxID=v end)
    local bsF=Instance.new("Frame",UtilP); bsF.Size=UDim2.new(1,0,0,14); bsF.BackgroundTransparency=1; bsF.LayoutOrder=26; local bsL=Instance.new("TextLabel",bsF); bsL.Text="Parado"; bsL.Size=UDim2.new(1,0,1,0); bsL.BackgroundTransparency=1; bsL.TextColor3=C.dim; bsL.Font=FM; bsL.TextSize=10; bsL.TextXAlignment=Enum.TextXAlignment.Left
    local prf=Instance.new("Frame",UtilP); prf.Size=UDim2.new(1,0,0,28); prf.BackgroundTransparency=1; prf.LayoutOrder=27; local pLL=Instance.new("UIListLayout",prf); pLL.FillDirection=Enum.FillDirection.Horizontal; pLL.Padding=UDim.new(0,4)
    local pBtn=Instance.new("TextButton",prf); pBtn.Text="▶"; pBtn.Size=UDim2.new(0.5,-2,1,0); pBtn.BackgroundColor3=Color3.fromRGB(14,52,14); pBtn.TextColor3=C.green; pBtn.Font=FB; pBtn.TextSize=12; pBtn.BorderSizePixel=0; Instance.new("UICorner",pBtn).CornerRadius=UDim.new(0,4)
    local sBtn=Instance.new("TextButton",prf); sBtn.Text="■ Parar"; sBtn.Size=UDim2.new(0.5,-2,1,0); sBtn.BackgroundColor3=Color3.fromRGB(52,10,10); sBtn.TextColor3=C.redH; sBtn.Font=FB; sBtn.TextSize=12; sBtn.BorderSizePixel=0; Instance.new("UICorner",sBtn).CornerRadius=UDim.new(0,4)
    pBtn.MouseButton1Click:Connect(function() local id=Cfg.Misc.BoomboxID~="" and Cfg.Misc.BoomboxID or bbBox.Text; if id~="" then PlayBoom(id); bsL.Text="▶ "..id; bsL.TextColor3=C.green else bsL.Text="❌"; bsL.TextColor3=C.redH end end)
    sBtn.MouseButton1Click:Connect(function() StopBoom(); bsL.Text="Parado"; bsL.TextColor3=C.dim end)
end
Sep(UtilP,29); SL(UtilP,"TOOL DUPLICATOR",30)
do
    IFld(UtilP,"Nome da Tool...",31,function(v) Cfg.Misc.DupeToolName=v end)
    Btn(UtilP,"Duplicar Tool",33,DupeTool)
end
Sep(UtilP,35); SL(UtilP,"SERVER",36)
Btn(UtilP,"🔄 Rejoin Server",37,Rejoin, Color3.fromRGB(10,10,55),C.blueH)
Btn(UtilP,"🌐 Server Hop",   39,ServerHop, Color3.fromRGB(10,40,10),C.green)

-- ============================================================
-- PAGE: MODOS ESPECIAIS
-- ============================================================
local ModP1=Panel(PModes,"Modos de Movimento",0,0,435,468,C.teal)
local ModP2=Panel(PModes,"Informações",443,0,435,350,C.teal)

SL(ModP1,"MODOS ESPECIAIS",0,C.tealH)
do local f=Instance.new("Frame",ModP1); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=1; local l=Instance.new("TextLabel",f); l.Text="Ative ou desative os modos abaixo. Apenas um modo por vez é recomendado."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left end

Sep(ModP1,2); SL(ModP1,"🕷️  HOMEM ARANHA",3,C.tealH)
Toggle(ModP1,"Modo Homem Aranha",4,
    function() return Cfg.Modes.SpiderMan end,
    function(v) Cfg.Modes.SpiderMan=v end,nil,C.teal)
do local f=Instance.new("Frame",ModP1); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=6; local l=Instance.new("TextLabel",f); l.Text="Permite andar sobre paredes e tetos. Use WASD normalmente."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left end

Sep(ModP1,7); SL(ModP1,"🌊  AQUAMAN",8,C.tealH)
Toggle(ModP1,"Modo Aquaman",9,
    function() return Cfg.Modes.Aquaman end,
    function(v) Cfg.Modes.Aquaman=v end,nil,C.teal)
do local f=Instance.new("Frame",ModP1); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=11; local l=Instance.new("TextLabel",f); l.Text="Impede perda de vida por afogamento. Funciona em água profunda."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left end

Sep(ModP1,12); SL(ModP1,"🪂  ANTIGRAVIDADE / SEM DANO DE QUEDA",13,C.tealH)
Toggle(ModP1,"Anti Queda (No Fall Damage)",14,
    function() return Cfg.Modes.NoFallDmg end,
    function(v) Cfg.Modes.NoFallDmg=v end,nil,C.teal)
do local f=Instance.new("Frame",ModP1); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=16; local l=Instance.new("TextLabel",f); l.Text="Restaura HP perdido por queda. Funciona em modo client-side."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left end

SL(ModP2,"SOBRE OS MODOS",0,C.tealH)
do
    local infos={
        {"🕷️ Homem Aranha","Cola o personagem em superfícies próximas detectadas por Raycast. Funciona em paredes e tetos."},
        {"🌊 Aquaman","Impede afogamento regenerando HP continuamente quando submerso. Não requer admin."},
        {"🪂 Anti Queda","Monitora quedas súbitas de HP e restaura automaticamente. Client-side apenas."},
        {"⚠️ Nota","Esses modos são client-side. Jogos com anti-cheat servidor podem reverter alguns efeitos."},
    }
    local order=1
    for _,info in ipairs(infos) do
        SL(ModP2,info[1],order,C.tealH); order=order+1
        local f=Instance.new("Frame",ModP2); f.Size=UDim2.new(1,0,0,30); f.BackgroundTransparency=1; f.LayoutOrder=order
        local l=Instance.new("TextLabel",f); l.Text=info[2]; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Top
        order=order+2
    end
end

-- ============================================================
-- PAGE: TROLL
-- ============================================================
local Tr1=Panel(PTroll,"Trollagem - Pessoal",   0,  0,435,468,C.purple)
local Tr2=Panel(PTroll,"Chat / Som / Outros",443,0,435,468,C.purple)

SL(Tr1,"APARÊNCIA PESSOAL",0,C.purpleH)
Toggle(Tr1,"Spin/Spinbot",  1,function() return Cfg.Misc.SpinBot    end,function(v) Cfg.Misc.SpinBot=v; TrollSpin(v) end,nil,C.purpleH)
Slider(Tr1,"Spin Speed",1,50,10,3,function(v) Cfg.Troll.SpinSpeed=v; if Cfg.Misc.SpinBot then TrollSpin(true) end end)
Toggle(Tr1,"Invisible",     6,function() return Cfg.Troll.Invisible  end,function(v) Cfg.Troll.Invisible=v; TrollInvis(v) end,nil,C.purpleH)
Sep(Tr1,8); SL(Tr1,"TAMANHO",9,C.purpleH)
Btn(Tr1,"🔷 Giant",10,function() TrollScale(Cfg.Troll.GiantScale) end,Color3.fromRGB(18,38,78),C.blueH)
Btn(Tr1,"🔸 Tiny", 12,function() TrollScale(Cfg.Troll.TinyScale)  end,Color3.fromRGB(38,18,78),C.purpleH)
Btn(Tr1,"↺ Normal",14,function() TrollScale(1) end,C.bg4,C.text)
Slider(Tr1,"Giant Scale",2,20,5,16,function(v) Cfg.Troll.GiantScale=v end)
Slider(Tr1,"Tiny Scale",1,10,3,18,function(v) Cfg.Troll.TinyScale=v/10 end)
Sep(Tr1,20); SL(Tr1,"RAINBOW",21,C.purpleH)
Toggle(Tr1,"Rainbow Armor",22,function() return Cfg.Troll.Rainbow   end,function(v) Cfg.Troll.Rainbow=v; EnableRainbow(v) end,nil,C.purpleH)
Slider(Tr1,"Rainbow Speed",1,20,5,24,function(v) Cfg.Troll.RainbowSpeed=v*0.01 end)

SL(Tr2,"CHAT SPAM",0,C.purpleH)
IFld(Tr2,"Mensagem do spam...",1,function(v) Cfg.Troll.SpamMsg=v end)
Slider(Tr2,"Delay (s)",1,30,1,3,function(v) Cfg.Troll.SpamDelay=v end)
Toggle(Tr2,"Chat Spammer",   5,function() return Cfg.Troll.ChatSpam end,function(v) Cfg.Troll.ChatSpam=v; if v then StartSpam() else StopSpam() end end,nil,C.purpleH)
Sep(Tr2,7); SL(Tr2,"SOUND SPAM",8,C.purpleH)
local sndBox=IFld(Tr2,"ID do som...",9,function(v) Cfg.Troll.SoundID=v end)
local sndSF=Instance.new("Frame",Tr2); sndSF.Size=UDim2.new(1,0,0,14); sndSF.BackgroundTransparency=1; sndSF.LayoutOrder=11; local sndSL=Instance.new("TextLabel",sndSF); sndSL.Text="Parado"; sndSL.Size=UDim2.new(1,0,1,0); sndSL.BackgroundTransparency=1; sndSL.TextColor3=C.dim; sndSL.Font=FM; sndSL.TextSize=10; sndSL.TextXAlignment=Enum.TextXAlignment.Left
local sndRow=Instance.new("Frame",Tr2); sndRow.Size=UDim2.new(1,0,0,28); sndRow.BackgroundTransparency=1; sndRow.LayoutOrder=12; local sndLL=Instance.new("UIListLayout",sndRow); sndLL.FillDirection=Enum.FillDirection.Horizontal; sndLL.Padding=UDim.new(0,4)
local sPlay=Instance.new("TextButton",sndRow); sPlay.Text="▶ Tocar"; sPlay.Size=UDim2.new(0.5,-2,1,0); sPlay.BackgroundColor3=Color3.fromRGB(38,6,58); sPlay.TextColor3=C.purpleH; sPlay.Font=FB; sPlay.TextSize=12; sPlay.BorderSizePixel=0; Instance.new("UICorner",sPlay).CornerRadius=UDim.new(0,4)
local sStop=Instance.new("TextButton",sndRow); sStop.Text="■ Parar"; sStop.Size=UDim2.new(0.5,-2,1,0); sStop.BackgroundColor3=Color3.fromRGB(52,10,10); sStop.TextColor3=C.redH; sStop.Font=FB; sStop.TextSize=12; sStop.BorderSizePixel=0; Instance.new("UICorner",sStop).CornerRadius=UDim.new(0,4)
sPlay.MouseButton1Click:Connect(function()
    local id=Cfg.Troll.SoundID~="" and Cfg.Troll.SoundID or sndBox.Text
    if id~="" then StartSoundSpam(id); sndSL.Text="▶ "..id; sndSL.TextColor3=C.purpleH else sndSL.Text="❌"; sndSL.TextColor3=C.redH end
end)
sStop.MouseButton1Click:Connect(function() StopSoundSpam(); sndSL.Text="Parado"; sndSL.TextColor3=C.dim end)

-- ============================================================
-- PAGE: SETTINGS
-- ============================================================
local KbP   = Panel(PSettings,"Teclas de Atalho",        0,  0,435,468)
local CfgP  = Panel(PSettings,"Configurações & Saves",  443,  0,290,468)
local LogP  = Panel(PSettings,"Chat Log",               737,  0,175,468)

KB(KbP,"Toggle GUI",         0,function() return Cfg.Settings.ToggleKeyName  end,function(k,n) Cfg.Settings.ToggleKey=k;  Cfg.Settings.ToggleKeyName=n  end)
KB(KbP,"ESP On/Off",         2,function() return Cfg.Settings.ESPKeyName     end,function(k,n) Cfg.Settings.ESPKey=k;     Cfg.Settings.ESPKeyName=n     end)
KB(KbP,"Aimbot On/Off",      4,function() return Cfg.Settings.AimbotKeyName  end,function(k,n) Cfg.Settings.AimbotKey=k;  Cfg.Settings.AimbotKeyName=n  end)
KB(KbP,"Fly On/Off",         6,function() return Cfg.Settings.FlyKeyName     end,function(k,n) Cfg.Settings.FlyKey=k;     Cfg.Settings.FlyKeyName=n     end)
KB(KbP,"Noclip On/Off",      8,function() return Cfg.Settings.NoclipKeyName  end,function(k,n) Cfg.Settings.NoclipKey=k;  Cfg.Settings.NoclipKeyName=n  end)
KB(KbP,"Speed Hack On/Off", 10,function() return Cfg.Settings.SpeedKeyName   end,function(k,n) Cfg.Settings.SpeedKey=k;   Cfg.Settings.SpeedKeyName=n   end)
KB(KbP,"Xray On/Off",       12,function() return Cfg.Settings.XrayKeyName    end,function(k,n) Cfg.Settings.XrayKey=k;    Cfg.Settings.XrayKeyName=n    end)
KB(KbP,"FreeCam On/Off",    14,function() return Cfg.Settings.FreeCamKeyName end,function(k,n) Cfg.Settings.FreeCamKey=k; Cfg.Settings.FreeCamKeyName=n end)
KB(KbP,"Aim Key (segurar)", 16,function() return Cfg.Aim.AimKeyName          end,function(k,n) Cfg.Aim.AimKey=k;          Cfg.Aim.AimKeyName=n           end)

SL(CfgP,"SAVES",0)
local svSt=StatusLbl(CfgP,1)
local svBox=IFld(CfgP,"Nome do save...",2,function() end)
local function GSN() return svBox and svBox.Text~="" and svBox.Text or "default" end
Btn(CfgP,"💾 Salvar Config", 4,function() local ok,i=SaveCfg(GSN()); if ok then svSt("✓ "..i,C.green) else svSt("❌ "..tostring(i),C.redH) end end,Color3.fromRGB(10,50,10))
Btn(CfgP,"📂 Carregar Config",6,function() local ok,i=LoadCfg(GSN()); if ok then svSt("✓ Carregado",C.green) else svSt("❌ "..tostring(i),C.redH) end end,Color3.fromRGB(20,34,8))
Btn(CfgP,"🗑 Deletar Config", 8,function() svSt(DelCfg(GSN()) and "✓ Deletado" or "❌ delfile indisponível",C.orange) end,Color3.fromRGB(46,10,4))

Sep(CfgP,10); SL(CfgP,"SAVES DISPONÍVEIS",11)
local svLH=Instance.new("Frame",CfgP); svLH.Size=UDim2.new(1,0,0,100); svLH.BackgroundColor3=C.bg4; svLH.BorderSizePixel=0; svLH.LayoutOrder=12; Instance.new("UICorner",svLH).CornerRadius=UDim.new(0,4)
local svLS=Instance.new("ScrollingFrame",svLH); svLS.Size=UDim2.new(1,-8,1,-8); svLS.Position=UDim2.new(0,4,0,4); svLS.BackgroundTransparency=1; svLS.BorderSizePixel=0; svLS.ScrollBarThickness=2; svLS.ScrollBarImageColor3=C.red; svLS.CanvasSize=UDim2.new(0,0,0,0); svLS.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",svLS).Padding=UDim.new(0,2)
local function RefSaves()
    for _,c in ipairs(svLS:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    local fs=ListCfgs()
    if #fs==0 then local el=Instance.new("TextLabel",svLS); el.Text="(nenhum save)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left; return end
    for _,nm in ipairs(fs) do
        local row=Instance.new("Frame",svLS); row.Size=UDim2.new(1,0,0,22); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
        local nl=Instance.new("TextLabel",row); nl.Text="📄 "..nm; nl.Size=UDim2.new(1,-52,1,0); nl.Position=UDim2.new(0,6,0,0); nl.BackgroundTransparency=1; nl.TextColor3=C.text; nl.Font=FM; nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left
        local lb=Instance.new("TextButton",row); lb.Text="Load"; lb.Size=UDim2.new(0,36,0,16); lb.Position=UDim2.new(1,-40,0.5,-8); lb.BackgroundColor3=C.red; lb.TextColor3=C.wht; lb.Font=FB; lb.TextSize=9; lb.BorderSizePixel=0; Instance.new("UICorner",lb).CornerRadius=UDim.new(0,3)
        local cap=nm; lb.MouseButton1Click:Connect(function() local ok,i=LoadCfg(cap); svSt(ok and "✓ "..cap or "❌ "..tostring(i),ok and C.green or C.redH) end)
    end
end
Btn(CfgP,"↺ Atualizar Saves",13,RefSaves); RefSaves()
Sep(CfgP,15); SL(CfgP,"RESET",16)
Btn(CfgP,"🗑 Resetar Padrão",17,function()
    -- Reset completo para false
    for k in pairs({Box=0,Fill=0,Names=0,HP=0,Tracers=0,Dist=0,WallCheck=0,Enabled=0,TeamCheck=0,HeldTool=0}) do Cfg.ESP[k]=false end
    Cfg.ESP.MaxDist=500; Cfg.ESP.TrackList={}
    for k in pairs({Box=0,Fill=0,Names=0,HP=0,Tracers=0,Dist=0,TeamCheck=0,Enabled=0,Skeleton=0}) do Cfg.Xray[k]=false end
    Cfg.Xray.MaxDist=1000
    for k in pairs({Aimbot=0,WallCheck=0,TeamCheck=0,Prediction=0,NoRecoil=0,InfAmmo=0,FastReload=0,ShowFOV=0,UseFOV=0,FOVFollow=0}) do Cfg.Aim[k]=false end
    Cfg.Aim.AimKey=Enum.KeyCode.E; Cfg.Aim.AimKeyName="E"; Cfg.Aim.Blacklist={}; Cfg.Aim.FOV=120
    Cfg.Trigger.Enabled=false; Cfg.Trigger.TeamCheck=false; Cfg.Trigger.Delay=100
    for k in pairs({Fly=0,FlyBoost=0,Noclip=0,Speed=0,AntiAFK=0,HitboxExtender=0,JumpMod=0,InfJump=0,AntiRag=0,FreeCam=0,ClickTp=0,SpinBot=0}) do Cfg.Misc[k]=false end
    for k in pairs({SpiderMan=0,Aquaman=0,NoFallDmg=0}) do Cfg.Modes[k]=false end
    svSt("✓ Resetado",C.orange)
end,Color3.fromRGB(46,10,4))
Sep(CfgP,19); SL(CfgP,"CRÉDITOS",20)
IL(CfgP,"SCRIPT POR BRUNO223J AND TY",21,C.gold)
IL(CfgP,"DISCORD: .223j  |  frty2017",22,C.gold)
IL(CfgP,"HUB REVOLUCIONARI'US GROUP  v1.0",23,C.wht)
IL(CfgP,"Toggle: [;] · Arrastável pela topbar",24,C.dim)
Sep(CfgP,25); SL(CfgP,"REMOVER SCRIPT",26,C.red)
Btn(CfgP,"🗑 Desligar & Remover Tudo",27,function()
    Cfg.Aim.Aimbot=false; Cfg.ESP.Enabled=false; Cfg.Xray.Enabled=false
    Cfg.Misc.Fly=false; Cfg.Misc.Noclip=false; Cfg.Misc.Speed=false; Cfg.Misc.FreeCam=false
    Cfg.Troll.ChatSpam=false; Cfg.Troll.Rainbow=false; Cfg.Misc.SpinBot=false
    Cfg.Modes.SpiderMan=false; Cfg.Modes.Aquaman=false; Cfg.Modes.NoFallDmg=false
    DisableFly(); DisableNoclip(); DisableFreeCam(); StopBoom(); StopSoundSpam()
    if _spinBG then pcall(function() _spinBG:Destroy() end) end
    for p,_ in pairs(ESPO) do KillESP(p) end
    pcall(function() FOVC:Remove() end)
    local char=LP.Character; if char then
        local h=char:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=16; h.JumpPower=50; h.PlatformStand=false end
    end
    task.wait(0.1); if SG and SG.Parent then SG:Destroy() end
    print("[223HUB v1.0] Removido.")
end,Color3.fromRGB(80,8,8),C.redH)

-- Chat Log
SL(LogP,"CHAT LOG",0,C.gold)
local clS=Instance.new("ScrollingFrame",LogP); clS.Size=UDim2.new(1,0,0,385); clS.BackgroundColor3=C.bg4; clS.BorderSizePixel=0; clS.LayoutOrder=1; Instance.new("UICorner",clS).CornerRadius=UDim.new(0,4); clS.ScrollBarThickness=2; clS.ScrollBarImageColor3=C.gold; clS.CanvasSize=UDim2.new(0,0,0,0); clS.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",clS).Padding=UDim.new(0,2)
local op2=Instance.new("UIPadding",clS); op2.PaddingLeft=UDim.new(0,4); op2.PaddingTop=UDim.new(0,4); op2.PaddingRight=UDim.new(0,4)
local function RefLog()
    for _,c in ipairs(clS:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
    for i=1,math.min(#_chatLog,60) do
        local e=_chatLog[i]
        local row=Instance.new("Frame",clS); row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
        local nl=Instance.new("TextLabel",row); nl.Size=UDim2.new(1,0,0,14); nl.Position=UDim2.new(0,4,0,2); nl.BackgroundTransparency=1; nl.TextColor3=C.gold; nl.Font=FB; nl.TextSize=10; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Text=e.player.." ["..e.time.."]"
        local ml=Instance.new("TextLabel",row); ml.Size=UDim2.new(1,0,0,14); ml.Position=UDim2.new(0,4,0,17); ml.BackgroundTransparency=1; ml.TextColor3=C.text; ml.Font=FM; ml.TextSize=10; ml.TextXAlignment=Enum.TextXAlignment.Left; ml.Text=e.msg; ml.TextTruncate=Enum.TextTruncate.AtEnd
    end
    if #_chatLog==0 then local el=Instance.new("TextLabel",clS); el.Text="(sem msgs)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left end
end
Btn(LogP,"↺ Atualizar",2,RefLog,C.bg4,C.gold); RefLog()
task.spawn(function() while true do task.wait(5); if _curTab=="Settings" then pcall(RefLog) end end end)

print("[223HUB v1.0] ✓ LOADED | BRUNO223J & TY | .223j | frty2017 | Toggle=[;]")
