-- ╔══════════════════════════════════════════════════════════╗
-- ║                   223HUB  v8.0                          ║
-- ║      SCRIPT FEITO POR BRUNO223J E TY                    ║
-- ║      DISCORD: .223j  |  frty2017                        ║
-- ╚══════════════════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Workspace        = game:GetService("Workspace")
local Chat             = game:GetService("Chat")
local TeleportService  = game:GetService("TeleportService")
local StarterGui       = game:GetService("StarterGui")

local UIS   = UserInputService
local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam   = Workspace.CurrentCamera

-- ============================================================
-- CLEANUP: destrói execuções anteriores
-- ============================================================
if _G._223TYHUB_Cleanup then pcall(_G._223TYHUB_Cleanup) end
local _connections = {}
local function AddConn(c) _connections[#_connections+1]=c; return c end

_G._223TYHUB_Cleanup = function()
    for _,c in ipairs(_connections) do pcall(function() c:Disconnect() end) end
    _connections = {}
    if CoreGui:FindFirstChild("223TYHUB") then CoreGui:FindFirstChild("223TYHUB"):Destroy() end
    -- limpa drawings
    if _G._223_ESPO then
        for p,d in pairs(_G._223_ESPO) do
            for _,v in pairs(d) do
                if type(v)=="table" then for _,l in pairs(v) do pcall(function() l:Remove() end) end
                else pcall(function() v:Remove() end) end
            end
        end
        _G._223_ESPO = {}
    end
    if _G._223_FOVC then pcall(function() _G._223_FOVC:Remove() end) end
end

-- ============================================================
-- CONFIG
-- ============================================================
local Cfg = {
    ESP = {
        Enabled=false, BoxESP=true, FillBox=false, NameESP=true,
        HealthBar=true, Tracers=false, Distance=true, WallCheck=false,
        TeamCheck=false, HeldTool=false,
        MaxDistance=500, TrackList={},
        BoxColor=Color3.fromRGB(200,40,40),
        FillColor=Color3.fromRGB(200,40,40),
        NameColor=Color3.fromRGB(255,255,255),
        TracerColor=Color3.fromRGB(200,40,40),
        DistColor=Color3.fromRGB(180,180,180),
        HpColor=Color3.fromRGB(0,220,80),
        HpBgColor=Color3.fromRGB(50,0,0),
        ToolColor=Color3.fromRGB(255,200,50),
    },
    Xray = {
        Enabled=false, BoxESP=true, FillBox=false, NameESP=true,
        HealthBar=true, Tracers=false, Distance=true, TeamCheck=false,
        Skeleton=false, MaxDistance=1000,
        BoxColor=Color3.fromRGB(0,160,255),
        FillColor=Color3.fromRGB(0,120,220),
        NameColor=Color3.fromRGB(180,220,255),
        TracerColor=Color3.fromRGB(0,160,255),
        DistColor=Color3.fromRGB(150,200,255),
        HpColor=Color3.fromRGB(0,200,255),
        HpBgColor=Color3.fromRGB(0,30,60),
        SkelColor=Color3.fromRGB(0,200,255),
    },
    Aim = {
        Aimbot=false, SilentAim=false, WallCheck=false, TeamCheck=false,
        Prediction=false, PredStr=1,
        NoRecoil=false, NoSpread=false,
        FOV=120, ShowFOV=true, UseFOV=true,
        AimPart="Head", Smoothness=15,
        AimKey=Enum.KeyCode.E, AimKeyName="E",
        SAChance=100, InfAmmo=false,
        Blacklist={},
    },
    Trigger = { Enabled=false, TeamCheck=false, Delay=100 },
    Misc = {
        Fly=false, FlySpeed=50, FlyBoost=false,
        Noclip=false,
        Speed=false, WalkSpeed=25, SpeedMethod="WalkSpeed",
        AntiAFK=false,
        HitboxExtender=false, HitboxSize=8,
        JumpMod=false, JumpPower=80, JumpMethod="JumpPower",
        InfJump=false, AntiRag=false,
        FreeCam=false, FCamSpeed=1,
        BoomboxID="",
        DupeToolName="",
        ClickTp=false,
        SpinBot=false,
    },
    Troll = {
        Target="",
        ChatSpam=false, SpamMsg="223HUB", SpamDelay=1,
        Rainbow=false, RainbowSpeed=0.05,
        SoundID="",
        LoopKill=false,
        SpinSpeed=10,
        Invisible=false,
        GiantScale=5, TinyScale=0.3,
        FakeTag="[ADMIN]",
    },
    Settings = {
        ToggleKey=Enum.KeyCode.Semicolon, ToggleKeyName=";",
        ESPKey=Enum.KeyCode.F2,           ESPKeyName="F2",
        AimbotKey=Enum.KeyCode.F3,        AimbotKeyName="F3",
        SilentKey=Enum.KeyCode.F4,        SilentKeyName="F4",
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
local SDIR = "223TYHUB_Configs/"
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
             Trigger=SafeSer(Cfg.Trigger),Misc=SafeSer(Cfg.Misc),Settings=SafeSer(Cfg.Settings)}
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
    mg(Cfg.Trigger,t.Trigger); mg(Cfg.Misc,t.Misc); mg(Cfg.Settings,t.Settings)
    local function TK(n) return (n and pcall(function() return Enum.KeyCode[n] end) and Enum.KeyCode[n]) or Enum.KeyCode.Unknown end
    Cfg.Aim.AimKey=TK(Cfg.Aim.AimKeyName)
    Cfg.Settings.ToggleKey=TK(Cfg.Settings.ToggleKeyName)
    Cfg.Settings.ESPKey=TK(Cfg.Settings.ESPKeyName)
    Cfg.Settings.AimbotKey=TK(Cfg.Settings.AimbotKeyName)
    Cfg.Settings.SilentKey=TK(Cfg.Settings.SilentKeyName)
    Cfg.Settings.FlyKey=TK(Cfg.Settings.FlyKeyName)
    Cfg.Settings.NoclipKey=TK(Cfg.Settings.NoclipKeyName)
    Cfg.Settings.SpeedKey=TK(Cfg.Settings.SpeedKeyName)
    Cfg.Settings.XrayKey=TK(Cfg.Settings.XrayKeyName)
    Cfg.Settings.FreeCamKey=TK(Cfg.Settings.FreeCamKeyName)
end

local function SaveCfg(name)
    if not rawget(_G,"writefile") and not writefile then return false,"writefile indisponível" end
    EnsDir()
    local f=SDIR..name:gsub("[^%w_%-]","_")..".json"
    local ok,e=pcall(writefile,f,SerCfg())
    return ok, ok and f or tostring(e)
end

local function LoadCfg(name)
    if not rawget(_G,"readfile") and not readfile then return false,"readfile indisponível" end
    local f=SDIR..name:gsub("[^%w_%-]","_")..".json"
    if rawget(_G,"isfile") and not isfile(f) then return false,"Não encontrado: "..f end
    local ok,data=pcall(readfile,f); if not ok then return false,"Erro ao ler" end
    local ok2,t=pcall(function() return HttpService:JSONDecode(data) end)
    if not ok2 then return false,"JSON inválido" end
    ApplySave(t); return true,f
end

local function ListCfgs()
    if not rawget(_G,"listfiles") and not listfiles then return {} end
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
    if not rawget(_G,"delfile") and not delfile then return false end
    pcall(delfile, SDIR..name:gsub("[^%w_%-]","_")..".json"); return true
end

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function W2S(pos)
    local ok,sp,vis = pcall(function() return Cam:WorldToViewportPoint(pos) end)
    if not ok then return Vector2.new(0,0), false end
    return Vector2.new(sp.X,sp.Y), vis and sp.Z > 0
end

local function GetBounds(char)
    local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local t,v1=W2S(hrp.Position+Vector3.new(0,3.3,0))
    local b,v2=W2S(hrp.Position-Vector3.new(0,2.8,0))
    if not v1 and not v2 then return nil end
    local h=math.max(math.abs(b.Y-t.Y),1)
    local w=h*0.55
    return t.X-w/2, t.Y, w, h
end

local function GetDist(char)
    local a=char and char:FindFirstChild("HumanoidRootPart")
    local myc=LP.Character
    local b=myc and myc:FindFirstChild("HumanoidRootPart")
    if not a or not b then return nil end
    return math.floor((a.Position-b.Position).Magnitude)
end

local function GetHP(char)
    local h=char and char:FindFirstChildOfClass("Humanoid")
    if not h then return 0,100 end
    return math.max(0,h.Health), math.max(1,h.MaxHealth)
end

local function IsVisible(char)
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local myc=LP.Character
    local mine=myc and myc:FindFirstChild("HumanoidRootPart")
    if not hrp or not mine then return false end
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
    local ex={}
    local function addParts(c) for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then ex[#ex+1]=v end end end
    addParts(myc); addParts(char)
    rp.FilterDescendantsInstances=ex
    local dir=hrp.Position-mine.Position
    local result=Workspace:Raycast(mine.Position,dir,rp)
    return result==nil
end

local function SameTeam(p)
    if not p or p==LP then return false end
    local mt=LP.Team; local pt=p.Team
    if not mt or not pt then return false end
    return mt==pt
end

local function IsValidTarget(p)
    if p==LP then return false end
    if Cfg.Aim.Blacklist[p.Name] then return false end
    if Cfg.Aim.TeamCheck and SameTeam(p) then return false end
    local c=p.Character; if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid")
    return h and h.Health>0
end

local function GetHeldTool(char)
    if not char then return nil end
    for _,v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then return v.Name end
    end
    return nil
end

local function ClosestTarget()
    local vs=Cam.ViewportSize
    local sc=Vector2.new(vs.X/2,vs.Y/2)
    local best,bestD=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(p) then continue end
        local c=p.Character
        local part=c:FindFirstChild(Cfg.Aim.AimPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        if Cfg.Aim.WallCheck and not IsVisible(c) then continue end
        local sp,on=W2S(part.Position); if not on then continue end
        local d=(sp-sc).Magnitude
        local inFOV = not Cfg.Aim.UseFOV or (d < Cfg.Aim.FOV)
        if inFOV and d<bestD then bestD=d; best=p end
    end
    return best
end

local function GetPlayerByName(name)
    if not name or name=="" then return nil end
    local q=name:lower()
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(q,1,true) or p.DisplayName:lower():find(q,1,true) then return p end
    end
    return nil
end

-- ============================================================
-- ESP OBJECTS
-- ============================================================
local ESPO = {}; _G._223_ESPO = ESPO

local BONES_R15={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local BONES_R6={
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function NewDraw(t,props)
    local d=Drawing.new(t)
    for k,v in pairs(props) do d[k]=v end
    return d
end

local function MakeESP(p)
    if p==LP or ESPO[p] then return end
    local d={}
    -- ESP normal
    d.Box      = NewDraw("Square",{Filled=false,Color=Cfg.ESP.BoxColor,Transparency=0,Thickness=1.5,Visible=false})
    d.Fill     = NewDraw("Square",{Filled=true, Color=Cfg.ESP.FillColor,Transparency=0.7,Thickness=0,Visible=false})
    d.Name     = NewDraw("Text",  {Size=13,Color=Cfg.ESP.NameColor,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.Dist     = NewDraw("Text",  {Size=11,Color=Cfg.ESP.DistColor,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.HPBg     = NewDraw("Square",{Filled=true, Color=Cfg.ESP.HpBgColor,Transparency=0,Thickness=0,Visible=false})
    d.HPFill   = NewDraw("Square",{Filled=true, Color=Cfg.ESP.HpColor,Transparency=0,Thickness=0,Visible=false})
    d.HPText   = NewDraw("Text",  {Size=10,Color=Color3.new(1,1,1),Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.Tracer   = NewDraw("Line",  {Thickness=1.2,Color=Cfg.ESP.TracerColor,Transparency=0,Visible=false})
    d.ToolText = NewDraw("Text",  {Size=11,Color=Cfg.ESP.ToolColor,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    -- Xray
    d.XBox     = NewDraw("Square",{Filled=false,Color=Cfg.Xray.BoxColor,Transparency=0,Thickness=1.5,Visible=false})
    d.XFill    = NewDraw("Square",{Filled=true, Color=Cfg.Xray.FillColor,Transparency=0.7,Thickness=0,Visible=false})
    d.XName    = NewDraw("Text",  {Size=13,Color=Cfg.Xray.NameColor,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.XDist    = NewDraw("Text",  {Size=11,Color=Cfg.Xray.DistColor,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.XHPBg    = NewDraw("Square",{Filled=true, Color=Cfg.Xray.HpBgColor,Transparency=0,Thickness=0,Visible=false})
    d.XHPFill  = NewDraw("Square",{Filled=true, Color=Cfg.Xray.HpColor,Transparency=0,Thickness=0,Visible=false})
    d.XTracer  = NewDraw("Line",  {Thickness=1.2,Color=Cfg.Xray.TracerColor,Transparency=0,Visible=false})
    -- Skeleton
    d.Skel={}
    for i=1,14 do d.Skel[i]=NewDraw("Line",{Thickness=1,Color=Cfg.Xray.SkelColor,Transparency=0,Visible=false}) end
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

local function HideESP(d)
    d.Box.Visible=false; d.Fill.Visible=false; d.Name.Visible=false
    d.Dist.Visible=false; d.HPBg.Visible=false; d.HPFill.Visible=false
    d.HPText.Visible=false; d.Tracer.Visible=false; d.ToolText.Visible=false
    d.XBox.Visible=false; d.XFill.Visible=false; d.XName.Visible=false
    d.XDist.Visible=false; d.XHPBg.Visible=false; d.XHPFill.Visible=false
    d.XTracer.Visible=false
    for _,l in pairs(d.Skel) do l.Visible=false end
end

-- FOV circle
local FOVC = NewDraw("Circle",{Thickness=1.5,Color=Color3.fromRGB(220,50,50),Filled=false,NumSides=64,Transparency=0,Visible=false})
_G._223_FOVC = FOVC

-- ============================================================
-- SILENT AIM
-- ============================================================
local _SAHooked = false
local function HookSA()
    if _SAHooked then return end
    _SAHooked = true
    local ok,mt = pcall(getrawmetatable, Mouse)
    if not ok or not mt then _SAHooked=false; return end
    local orig = mt.__index
    local bok = pcall(setreadonly, mt, false)
    if not bok then _SAHooked=false; return end
    mt.__index = newcclosure and newcclosure(function(self,k)
        if Cfg.Aim.SilentAim and math.random(1,100)<=Cfg.Aim.SAChance then
            local t=ClosestTarget()
            if t and t.Character then
                local pt=t.Character:FindFirstChild(Cfg.Aim.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
                if pt then
                    if k=="Hit" then return CFrame.new(pt.Position) end
                    if k=="Target" then return pt end
                end
            end
        end
        return orig(self,k)
    end) or function(self,k)
        if Cfg.Aim.SilentAim and math.random(1,100)<=Cfg.Aim.SAChance then
            local t=ClosestTarget()
            if t and t.Character then
                local pt=t.Character:FindFirstChild(Cfg.Aim.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
                if pt then
                    if k=="Hit" then return CFrame.new(pt.Position) end
                    if k=="Target" then return pt end
                end
            end
        end
        return orig(self,k)
    end
    setreadonly(mt, true)
end

-- ============================================================
-- NO RECOIL — via camera CFrame correction cada frame
-- ============================================================
local _recoilConn=nil
local function StartNoRecoil()
    if _recoilConn then return end
    local lastCF = Cam.CFrame
    _recoilConn = AddConn(RunService.RenderStepped:Connect(function()
        if not Cfg.Aim.NoRecoil then lastCF=Cam.CFrame; return end
        -- Zera valores de recoil em tools
        local char=LP.Character; if not char then lastCF=Cam.CFrame; return end
        for _,tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _,v in ipairs(tool:GetDescendants()) do
                    local nm=v.Name:lower()
                    if nm:find("recoil") or nm:find("kickback") then
                        pcall(function()
                            if v:IsA("Vector3Value") then v.Value=Vector3.zero
                            elseif v:IsA("NumberValue") then v.Value=0
                            elseif v:IsA("CFrameValue") then v.Value=CFrame.identity end
                        end)
                    end
                end
            end
        end
        lastCF=Cam.CFrame
    end))
end

-- ============================================================
-- INFINITE AMMO — abrangente: busca em todo o backpack/char
-- ============================================================
local _ammoConn=nil
local function StartInfAmmo()
    if _ammoConn then return end
    _ammoConn = AddConn(RunService.Heartbeat:Connect(function()
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
                                if (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Value<9999 then
                                    v.Value=9999
                                end
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
AddConn(RunService.Heartbeat:Connect(function()
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
    _flyConn=AddConn(RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.Fly then return end
        if not _bv or not _bv.Parent then return end
        local cf=Cam.CFrame; local vel=Vector3.zero
        local spd=Cfg.Misc.FlySpeed*(Cfg.Misc.FlyBoost and 3 or 1)
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel+=cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel-=cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel-=cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel+=cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel+=Vector3.new(0,spd,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel-=Vector3.new(0,spd*0.6,0) end
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
-- Referencia curta a UIS


-- ============================================================
-- NOCLIP
-- ============================================================
local _ncConn=nil
local function EnableNoclip()
    if _ncConn then return end
    _ncConn=AddConn(RunService.Stepped:Connect(function()
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
    if not Cfg.Misc.Speed then hum.WalkSpeed=16; return end
    hum.WalkSpeed = Cfg.Misc.WalkSpeed
end

local function ApplyJump()
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if not Cfg.Misc.JumpMod then hum.JumpPower=50; return end
    if Cfg.Misc.JumpMethod=="JumpPower" then hum.JumpPower=Cfg.Misc.JumpPower
    else hum.UseJumpPower=true; hum.JumpHeight=Cfg.Misc.JumpPower*0.4 end
end

AddConn(UserInputService.JumpRequest:Connect(function()
    if not Cfg.Misc.InfJump then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end))

-- ============================================================
-- ANTI AFK
-- ============================================================
local function StartAntiAFK()
    local VIM=game:GetService("VirtualInputManager")
    LP.Idled:Connect(function()
        if not Cfg.Misc.AntiAFK then return end
        pcall(function() VIM:SendKeyEvent(true,Enum.KeyCode.ButtonL3,false,game) end)
        task.wait(0.5)
        pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode.ButtonL3,false,game) end)
    end)
end

-- ============================================================
-- ANTI RAGDOLL
-- ============================================================
AddConn(RunService.Heartbeat:Connect(function()
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
local function SetHitbox(p,on)
    if p==LP then return end
    if _hbConns[p] then _hbConns[p]:Disconnect(); _hbConns[p]=nil end
    local function apply(char)
        if not on then return end
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Size=Vector3.new(Cfg.Misc.HitboxSize,Cfg.Misc.HitboxSize,Cfg.Misc.HitboxSize)
                v.LocalTransparencyModifier=0.6
            end
        end
    end
    if p.Character then apply(p.Character) end
    _hbConns[p]=p.CharacterAdded:Connect(apply)
end
local function ResetHitbox(p)
    if _hbConns[p] then _hbConns[p]:Disconnect(); _hbConns[p]=nil end
    local char=p.Character; if not char then return end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.Size=Vector3.new(2,2,1); v.LocalTransparencyModifier=0 end
    end
end
local function RefreshHitboxes()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            if Cfg.Misc.HitboxExtender then SetHitbox(p,true) else ResetHitbox(p) end
        end
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
    _fcConn=AddConn(RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.FreeCam then return end
        local spd=Cfg.Misc.FCamSpeed*0.6; local mv=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv+=Cam.CFrame.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv-=Cam.CFrame.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv-=Cam.CFrame.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv+=Cam.CFrame.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.E) then mv+=Vector3.new(0,spd,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then mv-=Vector3.new(0,spd,0) end
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
-- BOOMBOX
-- ============================================================
local _boom=nil
local function PlayBoom(id)
    if _boom then pcall(function() _boom:Destroy() end); _boom=nil end
    if not id or id=="" then return end
    _boom=Instance.new("Sound"); _boom.SoundId="rbxassetid://"..tostring(id):gsub("%D","")
    _boom.Volume=1; _boom.Looped=true; _boom.Name="_223Boom"; _boom.Parent=Workspace
    _boom:Play()
end
local function StopBoom() if _boom then pcall(function() _boom:Stop(); _boom:Destroy() end); _boom=nil end end

-- ============================================================
-- CLICK TELEPORT
-- ============================================================
local _ctConn=nil
local function StartClickTp()
    if _ctConn then return end
    _ctConn=AddConn(Mouse.Button1Down:Connect(function()
        if not Cfg.Misc.ClickTp then return end
        local char=LP.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hit=Mouse.Hit; if not hit then return end
        hrp.CFrame=CFrame.new(hit.Position+Vector3.new(0,3,0))
    end))
end

-- ============================================================
-- TOOL FUNCTIONS
-- ============================================================
local function GrabNearestTool()
    local char=LP.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local best,bestD=nil,math.huge
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and not v:IsDescendantOf(Players) then
            local p=v:FindFirstChildOfClass("BasePart") or v:FindFirstChildWhichIsA("BasePart")
            if p then
                local d=(p.Position-hrp.Position).Magnitude
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
    local char=LP.Character
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and not v:IsDescendantOf(Players) then
            out[#out+1]={name=v.Name, tool=v}
        end
    end
    -- Tools em outros chars
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character; if not c then continue end
        for _,v in ipairs(c:GetChildren()) do
            if v:IsA("Tool") then out[#out+1]={name=v.Name.." ("..p.Name..")", tool=v} end
        end
    end
    return out
end

local function GrabTool(toolObj)
    local bp=LP:FindFirstChild("Backpack"); if not bp then return false end
    pcall(function() toolObj.Parent=bp end)
    return true
end

local function DupeTool()
    local name=Cfg.Misc.DupeToolName:lower():gsub("%s+",""); if name=="" then return end
    local bp=LP:FindFirstChild("Backpack"); local char=LP.Character; local tool
    if bp then for _,v in ipairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(name,1,true) then tool=v; break end end end
    if not tool and char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(name,1,true) then tool=v; break end end end
    if tool and bp then tool:Clone().Parent=bp end
end

-- ============================================================
-- REJOIN / SERVER HOP / CHAT LOG
-- ============================================================
local _chatLog = {}
local function StartChatLog()
    Players.PlayerAdded:Connect(function(p)
        p.Chatted:Connect(function(msg)
            local entry = {player=p.Name, msg=msg, time=os.date("%H:%M:%S")}
            table.insert(_chatLog,1,entry)
            if #_chatLog>100 then table.remove(_chatLog) end
        end)
    end)
    for _,p in ipairs(Players:GetPlayers()) do
        p.Chatted:Connect(function(msg)
            local entry={player=p.Name,msg=msg,time=os.date("%H:%M:%S")}
            table.insert(_chatLog,1,entry)
            if #_chatLog>100 then table.remove(_chatLog) end
        end)
    end
end

local function Rejoin()
    local ok,err=pcall(function()
        TeleportService:Teleport(game.PlaceId, LP)
    end)
    if not ok then
        -- fallback
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end)
    end
end

local function ServerHop()
    local ok,servers=pcall(function()
        local url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local resp=HttpService:GetAsync(url)
        return HttpService:JSONDecode(resp)
    end)
    if not ok or not servers or not servers.data then
        -- fallback sem HTTP
        pcall(function() TeleportService:Teleport(game.PlaceId,LP) end)
        return
    end
    for _,s in ipairs(servers.data) do
        if s.id ~= game.JobId and s.playing < s.maxPlayers then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
            end)
            return
        end
    end
    -- nenhum server diferente: teleporta mesmo assim
    pcall(function() TeleportService:Teleport(game.PlaceId,LP) end)
end

-- ============================================================
-- TROLL
-- ============================================================
local _frozen={}
local function TrollFling(name)
    local p=GetPlayerByName(name); if not p then return "❌ Player não encontrado" end
    local char=p.Character; if not char then return "❌ Sem personagem" end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return "❌ Sem HRP" end
    local bv=Instance.new("BodyVelocity",hrp)
    bv.Velocity=Vector3.new(math.random(-300,300),500,math.random(-300,300))
    bv.MaxForce=Vector3.new(1e7,1e7,1e7)
    game:GetService("Debris"):AddItem(bv,0.15)
    return "✓ Flung: "..p.Name
end

local function TrollFreeze(name)
    local p=GetPlayerByName(name); if not p then return "❌ Não encontrado" end
    local char=p.Character; if not char then return "❌ Sem personagem" end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return "❌ Sem Humanoid" end
    if _frozen[p] then
        hum.WalkSpeed=16; hum.JumpPower=50; _frozen[p]=nil; return "✓ Unfrozen: "..p.Name
    else
        hum.WalkSpeed=0; hum.JumpPower=0; _frozen[p]=true; return "✓ Frozen: "..p.Name
    end
end

local _sitConn=nil
local function TrollSit(name)
    local p=GetPlayerByName(name); if not p then return "❌ Não encontrado" end
    if _sitConn then _sitConn:Disconnect(); _sitConn=nil; return "✓ Sit parado" end
    _sitConn=RunService.Heartbeat:Connect(function()
        local c=p.Character; if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid"); if not h then return end
        h.Sit=true
    end)
    return "✓ Sit loop: "..p.Name
end

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
        if p:IsA("BasePart") or p:IsA("Accessory") then
            pcall(function() p.LocalTransparencyModifier = on and 1 or 0 end)
        end
    end
end

local function TrollScale(sv)
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local ok,desc=pcall(function() return hum:GetAppliedDescription() end)
    if not ok or not desc then desc=Instance.new("HumanoidDescription") end
    desc.HeightScale=sv; desc.WidthScale=sv; desc.DepthScale=sv
    desc.HeadScale=sv; desc.ProportionScale=1; desc.BodyTypeScale=0
    pcall(function() hum:ApplyDescription(desc) end)
end

local function TrollTpToMe(name)
    local p=GetPlayerByName(name); if not p then return "❌ Não encontrado" end
    local myc=LP.Character; if not myc then return "❌ Sem personagem" end
    local mHRP=myc:FindFirstChild("HumanoidRootPart"); if not mHRP then return "❌ Sem HRP" end
    local tc=p.Character; if not tc then return "❌ Alvo sem personagem" end
    local tHRP=tc:FindFirstChild("HumanoidRootPart"); if not tHRP then return "❌ Alvo sem HRP" end
    tHRP.CFrame=mHRP.CFrame*CFrame.new(2,0,0)
    return "✓ Teleportado: "..p.Name
end

local function TrollFakeAdmin(msg)
    local full=Cfg.Troll.FakeTag.." "..msg
    -- Tenta múltiplos caminhos de chat
    pcall(function()
        local rs=game:GetService("ReplicatedStorage")
        local ev=rs:FindFirstChild("DefaultChatSystemChatEvents")
        if ev then local req=ev:FindFirstChild("SayMessageRequest"); if req then req:FireServer(full,"All") end end
    end)
    pcall(function()
        Chat:Chat(LP.Character and LP.Character:FindFirstChild("Head"),full,Enum.ChatColor.Red)
    end)
    -- TextChatService (novo sistema)
    pcall(function()
        local tcs=game:GetService("TextChatService")
        local chan=tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
        if chan then chan:SendAsync(full) end
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
            -- TextChatService fallback
            pcall(function()
                local tcs=game:GetService("TextChatService")
                local chan=tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
                if chan then chan:SendAsync(Cfg.Troll.SpamMsg) end
            end)
            task.wait(math.max(0.5,Cfg.Troll.SpamDelay))
        end
        _spamThread=nil
    end)
end
local function StopSpam() Cfg.Troll.ChatSpam=false end

local _rainThread=nil
local function EnableRainbow(on)
    if _rainThread then task.cancel(_rainThread); _rainThread=nil end
    if not on then return end
    local hue=0
    _rainThread=task.spawn(function()
        while Cfg.Troll.Rainbow do
            hue=(hue+Cfg.Troll.RainbowSpeed)%1
            local col=Color3.fromHSV(hue,1,1)
            local char=LP.Character; if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then pcall(function() p.Color=col end) end
                end
            end
            task.wait(0.05)
        end
    end)
end

local _sndSpam=nil
local function StartSoundSpam(id)
    if _sndSpam then pcall(function() _sndSpam:Destroy() end); _sndSpam=nil end
    if not id or id=="" then return end
    _sndSpam=Instance.new("Sound"); _sndSpam.SoundId="rbxassetid://"..id:gsub("%D","")
    _sndSpam.Volume=5; _sndSpam.Looped=true; _sndSpam.Name="_223Troll"; _sndSpam.Parent=Workspace; _sndSpam:Play()
end
local function StopSoundSpam() if _sndSpam then pcall(function() _sndSpam:Stop(); _sndSpam:Destroy() end); _sndSpam=nil end end

local _lkThread=nil
local function StartLoopKill(name)
    if _lkThread then task.cancel(_lkThread); _lkThread=nil end
    if not name or name=="" then return end
    _lkThread=task.spawn(function()
        while Cfg.Troll.LoopKill do
            local p=GetPlayerByName(name)
            if p then
                local char=p.Character
                if char then
                    local h=char:FindFirstChildOfClass("Humanoid")
                    if h then pcall(function() h.Health=0 end) end
                end
            end
            task.wait(1)
        end
    end)
end

local _removedLimbs={}
local function TrollLimbs(name)
    local p=GetPlayerByName(name); if not p then return "❌ Não encontrado" end
    local char=p.Character; if not char then return "❌ Sem personagem" end
    if _removedLimbs[p] then
        for _,part in ipairs(_removedLimbs[p]) do pcall(function() part.LocalTransparencyModifier=0 end) end
        _removedLimbs[p]=nil; return "✓ Limbs restaurados"
    end
    local names={"Left Arm","Right Arm","Left Leg","Right Leg","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftHand","RightHand","LeftFoot","RightFoot"}
    local set={}; for _,n in ipairs(names) do set[n]=true end
    _removedLimbs[p]={}
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and set[v.Name] then
            pcall(function() v.LocalTransparencyModifier=1 end)
            table.insert(_removedLimbs[p],v)
        end
    end
    return "✓ Limbs removidos"
end

local function TrollUnanchor(name)
    local p=GetPlayerByName(name)
    local pos
    if p and p.Character then
        local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then pos=hrp.Position end
    end
    if not pos then
        local myc=LP.Character; if myc then local hrp=myc:FindFirstChild("HumanoidRootPart"); if hrp then pos=hrp.Position end end
    end
    if not pos then return "❌ Sem posição" end
    local cnt=0
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Anchored and not Players:GetPlayerFromCharacter(v.Parent) then
            if (v.Position-pos).Magnitude<80 then v.Anchored=false; cnt+=1 end
        end
    end
    return "✓ Desancorando "..cnt.." partes"
end

-- ============================================================
-- MAIN RENDER LOOP
-- ============================================================
AddConn(RunService.RenderStepped:Connect(function()
    local vs=Cam.ViewportSize
    local sc=Vector2.new(vs.X/2,vs.Y/2)

    -- FOV
    FOVC.Position=sc; FOVC.Radius=Cfg.Aim.FOV
    FOVC.Visible=Cfg.Aim.ShowFOV and (Cfg.Aim.Aimbot or Cfg.Aim.SilentAim)

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
        if not c then HideESP(d); continue end
        local hrp=c:FindFirstChild("HumanoidRootPart")
        if not hrp then HideESP(d); continue end
        local dist=GetDist(c) or math.huge

        -- calcula bounds UMA vez
        local bx,by,bw,bh=GetBounds(c)

        -- ── ESP NORMAL ──
        local showESP = Cfg.ESP.Enabled
            and dist <= Cfg.ESP.MaxDistance
            and (not Cfg.ESP.TeamCheck or not SameTeam(player))
            and (not Cfg.ESP.TrackList or not next(Cfg.ESP.TrackList) or Cfg.ESP.TrackList[player.Name])
            and (not Cfg.ESP.WallCheck or IsVisible(c))

        if showESP and bx then
            local x,y,w,h=bx,by,bw,bh
            -- Box
            if Cfg.ESP.BoxESP then
                d.Box.Position=Vector2.new(x,y); d.Box.Size=Vector2.new(w,h); d.Box.Color=Cfg.ESP.BoxColor; d.Box.Visible=true
            else d.Box.Visible=false end
            -- Fill
            if Cfg.ESP.FillBox then
                d.Fill.Position=Vector2.new(x,y); d.Fill.Size=Vector2.new(w,h); d.Fill.Color=Cfg.ESP.FillColor; d.Fill.Visible=true
            else d.Fill.Visible=false end
            -- Name
            if Cfg.ESP.NameESP then
                d.Name.Position=Vector2.new(x+w/2,y-16); d.Name.Text=player.DisplayName; d.Name.Color=Cfg.ESP.NameColor; d.Name.Visible=true
            else d.Name.Visible=false end
            -- Distance
            if Cfg.ESP.Distance then
                d.Dist.Position=Vector2.new(x+w/2,y+h+2); d.Dist.Text=math.floor(dist).."m"; d.Dist.Color=Cfg.ESP.DistColor; d.Dist.Visible=true
            else d.Dist.Visible=false end
            -- Health Bar (à esquerda do box)
            if Cfg.ESP.HealthBar then
                local hp,mhp=GetHP(c); local r=math.clamp(hp/mhp,0,1)
                d.HPBg.Position=Vector2.new(x-8,y); d.HPBg.Size=Vector2.new(4,h); d.HPBg.Color=Cfg.ESP.HpBgColor; d.HPBg.Visible=true
                local g=math.clamp(2*r,0,1); local rv=math.clamp(2*(1-r),0,1)
                d.HPFill.Color=Color3.new(rv,g,0.05)
                d.HPFill.Position=Vector2.new(x-8,y+h*(1-r)); d.HPFill.Size=Vector2.new(4,h*r); d.HPFill.Visible=true
                d.HPText.Position=Vector2.new(x-12,y+h/2-5); d.HPText.Text=math.floor(hp); d.HPText.Visible=true
            else d.HPBg.Visible=false; d.HPFill.Visible=false; d.HPText.Visible=false end
            -- Tracer
            if Cfg.ESP.Tracers then
                d.Tracer.From=Vector2.new(vs.X/2,vs.Y); d.Tracer.To=Vector2.new(x+w/2,y+h); d.Tracer.Color=Cfg.ESP.TracerColor; d.Tracer.Visible=true
            else d.Tracer.Visible=false end
            -- Held Tool
            if Cfg.ESP.HeldTool then
                local tn=GetHeldTool(c)
                if tn then
                    d.ToolText.Position=Vector2.new(x+w/2,y-28); d.ToolText.Text="🔧 "..tn; d.ToolText.Color=Cfg.ESP.ToolColor; d.ToolText.Visible=true
                else d.ToolText.Visible=false end
            else d.ToolText.Visible=false end
        else
            d.Box.Visible=false; d.Fill.Visible=false; d.Name.Visible=false
            d.Dist.Visible=false; d.HPBg.Visible=false; d.HPFill.Visible=false
            d.HPText.Visible=false; d.Tracer.Visible=false; d.ToolText.Visible=false
        end

        -- ── XRAY ──
        local showXray = Cfg.Xray.Enabled
            and dist <= Cfg.Xray.MaxDistance
            and (not Cfg.Xray.TeamCheck or not SameTeam(player))

        if showXray and bx then
            local x,y,w,h=bx,by,bw,bh
            if Cfg.Xray.BoxESP then
                d.XBox.Position=Vector2.new(x,y); d.XBox.Size=Vector2.new(w,h); d.XBox.Color=Cfg.Xray.BoxColor; d.XBox.Visible=true
            else d.XBox.Visible=false end
            if Cfg.Xray.FillBox then
                d.XFill.Position=Vector2.new(x,y); d.XFill.Size=Vector2.new(w,h); d.XFill.Color=Cfg.Xray.FillColor; d.XFill.Visible=true
            else d.XFill.Visible=false end
            if Cfg.Xray.NameESP then
                d.XName.Position=Vector2.new(x+w/2,y-16); d.XName.Text="["..player.DisplayName.."]"; d.XName.Color=Cfg.Xray.NameColor; d.XName.Visible=true
            else d.XName.Visible=false end
            if Cfg.Xray.Distance then
                d.XDist.Position=Vector2.new(x+w/2,y+h+2); d.XDist.Text=math.floor(dist).."m"; d.XDist.Color=Cfg.Xray.DistColor; d.XDist.Visible=true
            else d.XDist.Visible=false end
            if Cfg.Xray.HealthBar then
                local hp,mhp=GetHP(c); local r=math.clamp(hp/mhp,0,1)
                d.XHPBg.Position=Vector2.new(x+w+3,y); d.XHPBg.Size=Vector2.new(4,h); d.XHPBg.Color=Cfg.Xray.HpBgColor; d.XHPBg.Visible=true
                d.XHPFill.Color=Cfg.Xray.HpColor
                d.XHPFill.Position=Vector2.new(x+w+3,y+h*(1-r)); d.XHPFill.Size=Vector2.new(4,h*r); d.XHPFill.Visible=true
            else d.XHPBg.Visible=false; d.XHPFill.Visible=false end
            if Cfg.Xray.Tracers then
                d.XTracer.From=Vector2.new(vs.X/2,vs.Y); d.XTracer.To=Vector2.new(x+w/2,y+h); d.XTracer.Color=Cfg.Xray.TracerColor; d.XTracer.Visible=true
            else d.XTracer.Visible=false end
            -- Skeleton
            if Cfg.Xray.Skeleton then
                local isR6=c:FindFirstChild("Torso")~=nil
                local bones=isR6 and BONES_R6 or BONES_R15
                for i,pair in ipairs(bones) do
                    local l=d.Skel[i]; if not l then continue end
                    local p1=c:FindFirstChild(pair[1]); local p2=c:FindFirstChild(pair[2])
                    if p1 and p2 then
                        local s1,ok1=W2S(p1.Position); local s2,ok2=W2S(p2.Position)
                        if ok1 or ok2 then l.From=s1; l.To=s2; l.Color=Cfg.Xray.SkelColor; l.Visible=true
                        else l.Visible=false end
                    else l.Visible=false end
                end
                for i=#bones+1,14 do if d.Skel[i] then d.Skel[i].Visible=false end end
            else for _,l in pairs(d.Skel) do l.Visible=false end end
        else
            d.XBox.Visible=false; d.XFill.Visible=false; d.XName.Visible=false
            d.XDist.Visible=false; d.XHPBg.Visible=false; d.XHPFill.Visible=false; d.XTracer.Visible=false
            for _,l in pairs(d.Skel) do l.Visible=false end
        end
    end
end))

-- Inicializa ESP e eventos
for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(function(p) MakeESP(p); if Cfg.Misc.HitboxExtender then SetHitbox(p,true) end end)
Players.PlayerRemoving:Connect(function(p)
    KillESP(p); _hbConns[p]=nil; _frozen[p]=nil; _removedLimbs[p]=nil
end)
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed(); ApplyJump()
    if Cfg.Misc.Fly    then EnableFly()    end
    if Cfg.Misc.Noclip then EnableNoclip() end
end)

StartAntiAFK(); StartNoRecoil(); StartInfAmmo(); StartClickTp(); StartChatLog()

-- ============================================================
-- KEYBIND HANDLER
-- ============================================================
local GuiVisible=true
local _CBs={} -- RefreshCBs
local function TR(k) if _CBs[k] then _CBs[k]() end end

AddConn(UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
    local kc=inp.KeyCode
    if     kc==Cfg.Settings.ToggleKey  then GuiVisible=not GuiVisible; if _G._223HUB_Win then _G._223HUB_Win.Visible=GuiVisible end
    elseif kc==Cfg.Settings.ESPKey     then Cfg.ESP.Enabled=not Cfg.ESP.Enabled; TR("ESP")
    elseif kc==Cfg.Settings.AimbotKey  then Cfg.Aim.Aimbot=not Cfg.Aim.Aimbot; TR("Aim")
    elseif kc==Cfg.Settings.SilentKey  then Cfg.Aim.SilentAim=not Cfg.Aim.SilentAim; if Cfg.Aim.SilentAim then HookSA() end; TR("SA")
    elseif kc==Cfg.Settings.FlyKey     then Cfg.Misc.Fly=not Cfg.Misc.Fly; if Cfg.Misc.Fly then EnableFly() else DisableFly() end; TR("Fly")
    elseif kc==Cfg.Settings.NoclipKey  then Cfg.Misc.Noclip=not Cfg.Misc.Noclip; if Cfg.Misc.Noclip then EnableNoclip() else DisableNoclip() end; TR("NC")
    elseif kc==Cfg.Settings.SpeedKey   then Cfg.Misc.Speed=not Cfg.Misc.Speed; ApplySpeed(); TR("Speed")
    elseif kc==Cfg.Settings.XrayKey    then Cfg.Xray.Enabled=not Cfg.Xray.Enabled; TR("Xray")
    elseif kc==Cfg.Settings.FreeCamKey then Cfg.Misc.FreeCam=not Cfg.Misc.FreeCam; if Cfg.Misc.FreeCam then EnableFreeCam() else DisableFreeCam() end; TR("FC")
    end
end))

-- ============================================================
-- ██████ GUI ██████
-- ============================================================
if CoreGui:FindFirstChild("223TYHUB") then CoreGui:FindFirstChild("223TYHUB"):Destroy() end
local SG=Instance.new("ScreenGui")
SG.Name="223TYHUB"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset=true; SG.Parent=CoreGui

local C={
    bg0=Color3.fromRGB(7,7,10), bg1=Color3.fromRGB(12,12,16), bg2=Color3.fromRGB(18,18,22),
    bg3=Color3.fromRGB(26,26,31), bg4=Color3.fromRGB(34,34,40),
    red=Color3.fromRGB(165,20,20), redH=Color3.fromRGB(210,45,45), pink=Color3.fromRGB(200,55,70),
    blue=Color3.fromRGB(30,100,210), blueH=Color3.fromRGB(50,130,240),
    purple=Color3.fromRGB(115,28,195), purpleH=Color3.fromRGB(145,58,225),
    green=Color3.fromRGB(50,180,75), orange=Color3.fromRGB(220,130,40),
    gold=Color3.fromRGB(215,175,38), wht=Color3.fromRGB(255,255,255),
    text=Color3.fromRGB(208,208,213), dim=Color3.fromRGB(90,90,100), sep=Color3.fromRGB(28,28,34),
}
local FB=Enum.Font.GothamBold; local FM=Enum.Font.Gotham; local FC=Enum.Font.Code

-- ============================================================
-- LOADING SCREEN
-- ============================================================
local LF=Instance.new("Frame",SG)
LF.Size=UDim2.new(0,920,0,520); LF.Position=UDim2.new(0.5,-460,0.5,-260)
LF.BackgroundColor3=C.bg0; LF.BorderSizePixel=0; LF.ZIndex=200
Instance.new("UICorner",LF).CornerRadius=UDim.new(0,6)
local LS=Instance.new("UIStroke",LF); LS.Color=C.red; LS.Thickness=1.5

local function TLine(p,bot)
    local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,2)
    f.Position=bot and UDim2.new(0,0,1,-2) or UDim2.new(0,0,0,0)
    f.BackgroundColor3=C.red; f.BorderSizePixel=0
end
TLine(LF,false); TLine(LF,true)

local LC=Instance.new("Frame",LF); LC.Size=UDim2.new(0,420,0,180); LC.Position=UDim2.new(0.5,-210,0.5,-135); LC.BackgroundTransparency=1
local function LBL(p,t,sz,col,y,fn) local l=Instance.new("TextLabel",p); l.Text=t; l.Size=UDim2.new(1,0,0,sz); l.Position=UDim2.new(0,0,0,y); l.BackgroundTransparency=1; l.TextColor3=col; l.Font=fn or FB; l.TextSize=sz; l.TextXAlignment=Enum.TextXAlignment.Center; return l end
LBL(LC,"◈",50,C.red,0)
LBL(LC,"223HUB",42,C.wht,52)
LBL(LC,"HUB BY REVOLUCIONARI'US GROUP",14,C.dim,98,FM)
LBL(LC,"SCRIPT FEITO POR BRUNO223J AND TY  ·  DISCORD: .223j | frty2017",11,C.gold,116,FM)
LBL(LC,"v8.0  ·  Public Beta",10,C.red,132,FC)

local BC=Instance.new("Frame",LF); BC.Size=UDim2.new(0,360,0,5); BC.Position=UDim2.new(0.5,-180,0.5,68); BC.BackgroundColor3=C.bg4; BC.BorderSizePixel=0; Instance.new("UICorner",BC).CornerRadius=UDim.new(1,0)
local BF=Instance.new("Frame",BC); BF.Size=UDim2.new(0,0,1,0); BF.BackgroundColor3=C.red; BF.BorderSizePixel=0; Instance.new("UICorner",BF).CornerRadius=UDim.new(1,0)
local LST=Instance.new("TextLabel",LF); LST.Size=UDim2.new(0,360,0,16); LST.Position=UDim2.new(0.5,-180,0.5,80); LST.BackgroundTransparency=1; LST.TextColor3=C.dim; LST.Font=FC; LST.TextSize=10; LST.TextXAlignment=Enum.TextXAlignment.Center; LST.Text="Inicializando..."

local LSTEPS={{0.1,"Verificando ambiente..."},{0.25,"Carregando ESP & Xray..."},{0.4,"Inicializando Aimbot..."},{0.55,"Configurando Misc & Troll..."},{0.7,"Aplicando keybinds..."},{0.85,"Carregando saves..."},{0.95,"Finalizando..."},{1.0,"Bem-vindo, "..LP.Name.."!"}}
local LTIME=4
task.spawn(function()
    local st=tick()
    while true do
        local p=math.min((tick()-st)/LTIME,1)
        BF.Size=UDim2.new(p,0,1,0)
        for i=#LSTEPS,1,-1 do if p>=LSTEPS[i][1]-0.01 then LST.Text=LSTEPS[i][2]; break end end
        if p>=1 then break end; task.wait(0.03)
    end
end)
task.wait(LTIME+0.2)
TweenService:Create(LF,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{BackgroundTransparency=1}):Play()
for _,v in ipairs(LF:GetDescendants()) do
    if v:IsA("TextLabel") then TweenService:Create(v,TweenInfo.new(0.4),{TextTransparency=1}):Play()
    elseif v:IsA("Frame") then TweenService:Create(v,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play() end
end
task.wait(0.6); LF:Destroy()

-- ============================================================
-- JANELA PRINCIPAL
-- ============================================================
local Win=Instance.new("Frame",SG)
Win.Name="Win"; Win.Size=UDim2.new(0,920,0,520); Win.Position=UDim2.new(0.5,-460,0.5,-260)
Win.BackgroundColor3=C.bg0; Win.BorderSizePixel=0; Win.Active=true; Win.Draggable=true
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",Win).Color=C.red
_G._223HUB_Win=Win

-- Topbar
local TB=Instance.new("Frame",Win); TB.Size=UDim2.new(1,0,0,38); TB.BackgroundColor3=C.bg1; TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,6)
Instance.new("Frame",TB).Size=UDim2.new(1,0,0,6); -- fix cantos

-- Logo
local LG=Instance.new("Frame",TB); LG.Size=UDim2.new(0,216,1,0); LG.BackgroundTransparency=1
local _=Instance.new("TextLabel",LG); _.Text="◈"; _.Size=UDim2.new(0,30,1,0); _.Position=UDim2.new(0,8,0,0); _.BackgroundTransparency=1; _.TextColor3=C.red; _.Font=FB; _.TextSize=20
local _=Instance.new("TextLabel",LG); _.Text="223HUB"; _.Size=UDim2.new(1,-40,0,22); _.Position=UDim2.new(0,36,0,5); _.BackgroundTransparency=1; _.TextColor3=C.wht; _.Font=FB; _.TextSize=15; _.TextXAlignment=Enum.TextXAlignment.Left
local _=Instance.new("TextLabel",LG); _.Text="BRUNO223J & TY · .223j | frty2017"; _.Size=UDim2.new(1,-40,0,12); _.Position=UDim2.new(0,36,0,22); _.BackgroundTransparency=1; _.TextColor3=C.gold; _.Font=FM; _.TextSize=9; _.TextXAlignment=Enum.TextXAlignment.Left
local _=Instance.new("Frame",TB); _.Size=UDim2.new(0,1,0.55,0); _.Position=UDim2.new(0,214,0.22,0); _.BackgroundColor3=C.sep; _.BorderSizePixel=0

-- Minimize
local MinB=Instance.new("TextButton",TB); MinB.Text="—"; MinB.Size=UDim2.new(0,28,0,22); MinB.Position=UDim2.new(1,-33,0.5,-11); MinB.BackgroundColor3=C.bg4; MinB.TextColor3=C.dim; MinB.Font=FB; MinB.TextSize=13; MinB.BorderSizePixel=0; Instance.new("UICorner",MinB).CornerRadius=UDim.new(0,4)
MinB.MouseButton1Click:Connect(function() GuiVisible=not GuiVisible; Win.Visible=GuiVisible end)

-- Red accent
local _=Instance.new("Frame",Win); _.Size=UDim2.new(1,0,0,1); _.Position=UDim2.new(0,0,0,38); _.BackgroundColor3=C.red; _.BorderSizePixel=0

-- Tabs area
local TA=Instance.new("Frame",TB); TA.Size=UDim2.new(1,-258,1,0); TA.Position=UDim2.new(0,218,0,0); TA.BackgroundTransparency=1
local TALL=Instance.new("UIListLayout",TA); TALL.FillDirection=Enum.FillDirection.Horizontal; TALL.VerticalAlignment=Enum.VerticalAlignment.Center; TALL.Padding=UDim.new(0,1)

-- Content
local CF=Instance.new("Frame",Win); CF.Size=UDim2.new(1,-16,1,-52); CF.Position=UDim2.new(0,8,0,48); CF.BackgroundTransparency=1; CF.BorderSizePixel=0

-- ============================================================
-- UI COMPONENTS
-- ============================================================
local function Panel(parent,title,x,y,w,h,ac)
    local f=Instance.new("Frame",parent); f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h); f.BackgroundColor3=C.bg2; f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",f).Color=C.sep
    local ph=Instance.new("Frame",f); ph.Size=UDim2.new(1,0,0,28); ph.BackgroundColor3=C.bg1; ph.BorderSizePixel=0; Instance.new("UICorner",ph).CornerRadius=UDim.new(0,5)
    Instance.new("Frame",ph).Size=UDim2.new(1,0,0,6) -- fix cantos
    local acc=Instance.new("Frame",ph); acc.Size=UDim2.new(0,3,0.6,0); acc.Position=UDim2.new(0,6,0.2,0); acc.BackgroundColor3=ac or C.red; acc.BorderSizePixel=0; Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
    local tl=Instance.new("TextLabel",ph); tl.Text=title; tl.Size=UDim2.new(1,-20,1,0); tl.Position=UDim2.new(0,14,0,0); tl.BackgroundTransparency=1; tl.TextColor3=C.text; tl.Font=FB; tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left
    local sc=Instance.new("ScrollingFrame",f); sc.Size=UDim2.new(1,-12,1,-34); sc.Position=UDim2.new(0,6,0,30); sc.BackgroundTransparency=1; sc.BorderSizePixel=0; sc.ScrollBarThickness=3; sc.ScrollBarImageColor3=ac or C.red; sc.CanvasSize=UDim2.new(0,0,0,0); sc.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local ll=Instance.new("UIListLayout",sc); ll.Padding=UDim.new(0,3); ll.SortOrder=Enum.SortOrder.LayoutOrder
    return sc
end

local function Toggle(parent,label,order,getV,setV,cbKey,ac)
    local col=ac or C.pink
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,26); f.BackgroundColor3=C.bg3; f.BorderSizePixel=0; f.LayoutOrder=order
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
    local chk=Instance.new("Frame",f); chk.Size=UDim2.new(0,16,0,16); chk.Position=UDim2.new(0,7,0.5,-8); chk.BackgroundColor3=C.bg4; chk.BorderSizePixel=0; Instance.new("UICorner",chk).CornerRadius=UDim.new(0,4)
    local cS=Instance.new("UIStroke",chk); cS.Color=C.sep; cS.Thickness=1
    local ck=Instance.new("TextLabel",chk); ck.Text="✓"; ck.Size=UDim2.new(1,0,1,0); ck.BackgroundTransparency=1; ck.TextColor3=col; ck.Font=FB; ck.TextSize=13; ck.Visible=getV()
    local lb=Instance.new("TextLabel",f); lb.Text=label; lb.Size=UDim2.new(1,-36,1,0); lb.Position=UDim2.new(0,30,0,0); lb.BackgroundTransparency=1; lb.TextColor3=C.text; lb.Font=FM; lb.TextSize=12; lb.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    local function ref()
        local v=getV(); ck.Visible=v
        chk.BackgroundColor3=v and Color3.fromRGB(28,8,28) or C.bg4
        cS.Color=v and col or C.sep
        f.BackgroundColor3=v and Color3.fromRGB(18,6,18) or C.bg3
    end
    if cbKey then _CBs[cbKey]=ref end
    btn.MouseButton1Click:Connect(function() setV(not getV()); ref() end)
    btn.MouseEnter:Connect(function() if not getV() then f.BackgroundColor3=C.bg4 end end)
    btn.MouseLeave:Connect(function() if not getV() then f.BackgroundColor3=C.bg3 end end)
    ref()
end

local _drag=nil
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _drag=nil end end)
UserInputService.InputChanged:Connect(function(i)
    if _drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local s=_drag; local r=math.clamp((i.Position.X-s.bar.AbsolutePosition.X)/s.bar.AbsoluteSize.X,0,1)
        local v=math.floor(s.mn+r*(s.mx-s.mn))
        s.fill.Size=UDim2.new(r,0,1,0); s.vl.Text=v.." / "..s.mx; s.cb(v)
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
    local ds={bar=bar,fill=fill,vl=vl,mn=mn,mx=mx,cb=function(v) cur=v; cb(v) end}
    local ib=Instance.new("TextButton",bar); ib.Size=UDim2.new(1,0,1,0); ib.BackgroundTransparency=1; ib.Text=""
    ib.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _drag=ds end end)
    bm.MouseButton1Click:Connect(function() cur=math.max(mn,cur-1); fill.Size=UDim2.new((cur-mn)/(mx-mn),0,1,0); vl.Text=cur.." / "..mx; cb(cur) end)
    bp.MouseButton1Click:Connect(function() cur=math.min(mx,cur+1); fill.Size=UDim2.new((cur-mn)/(mx-mn),0,1,0); vl.Text=cur.." / "..mx; cb(cur) end)
end

local function Sel(parent,lbl,opts,def,order,cb)
    local idx=1; for i,v in ipairs(opts) do if v==def then idx=i end end
    local lf=Instance.new("Frame",parent); lf.Size=UDim2.new(1,0,0,13); lf.BackgroundTransparency=1; lf.LayoutOrder=order
    Instance.new("TextLabel",lf).Text=lbl; local ll=lf:FindFirstChildOfClass("TextLabel"); ll.Size=UDim2.new(1,0,1,0); ll.BackgroundTransparency=1; ll.TextColor3=C.dim; ll.Font=FM; ll.TextSize=10; ll.TextXAlignment=Enum.TextXAlignment.Left
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
        local cn; cn=UserInputService.InputBegan:Connect(function(inp,gp)
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
    local function US() local n=0; for _ in pairs(data) do n+=1 end; sl.Text=n==0 and "Vazio — todos incluídos" or n.." na lista" end
    local function Rb()
        for _,c in ipairs(ls:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
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

-- ============================================================
-- TABS
-- ============================================================
local _pages={}; local _curTab=nil
local function MakeTab(name,order,col)
    local btn=Instance.new("TextButton",TA); btn.Text=name:upper(); btn.Size=UDim2.new(0,78,0,38); btn.BackgroundTransparency=1; btn.TextColor3=C.dim; btn.Font=FB; btn.TextSize=11; btn.BorderSizePixel=0; btn.LayoutOrder=order
    local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(0.75,0,0,2); ul.Position=UDim2.new(0.125,0,1,-2); ul.BackgroundColor3=col or C.redH; ul.BorderSizePixel=0; ul.Visible=false
    local pg=Instance.new("Frame",CF); pg.Size=UDim2.new(1,0,1,0); pg.BackgroundTransparency=1; pg.Visible=false
    _pages[name]={btn=btn,ul=ul,pg=pg}
    btn.MouseButton1Click:Connect(function()
        if _curTab then _pages[_curTab].btn.TextColor3=C.dim; _pages[_curTab].ul.Visible=false; _pages[_curTab].pg.Visible=false end
        _curTab=name; btn.TextColor3=C.wht; ul.Visible=true; pg.Visible=true
    end)
    return pg
end

local PMain   =MakeTab("Main",    1)
local PVis    =MakeTab("Visuals", 2)
local PXray   =MakeTab("Xray",    3,C.blueH)
local PMisc   =MakeTab("Misc",    4)
local PTroll  =MakeTab("Troll",   5,C.purpleH)
local PSettings=MakeTab("Settings",6)
_pages["Main"].btn.TextColor3=C.wht; _pages["Main"].ul.Visible=true; _pages["Main"].pg.Visible=true; _curTab="Main"

-- ============================================================
-- PAGE: MAIN — Aimbot | FOV | TriggerBot
-- ============================================================
local AimP  =Panel(PMain,"Aimbot",       0,  0,435,468)
local FovP  =Panel(PMain,"FOV Circle",   443,0,435,215)
local TrigP =Panel(PMain,"TriggerBot",   443,223,435,175)

Toggle(AimP,"Aimbot",                0,function() return Cfg.Aim.Aimbot    end,function(v) Cfg.Aim.Aimbot=v    end,"Aim")
Toggle(AimP,"Wall Check",            1,function() return Cfg.Aim.WallCheck end,function(v) Cfg.Aim.WallCheck=v end)
Toggle(AimP,"Team Check",            2,function() return Cfg.Aim.TeamCheck end,function(v) Cfg.Aim.TeamCheck=v end)
Toggle(AimP,"Prediction",            3,function() return Cfg.Aim.Prediction end,function(v) Cfg.Aim.Prediction=v end)
Slider(AimP,"Prediction Strength",1,10,1,4,function(v) Cfg.Aim.PredStr=v end)
Sel(AimP,"Target Part",{"Head","HumanoidRootPart","Torso","LeftLowerArm","RightLowerArm"},"Head",7,function(v) Cfg.Aim.AimPart=v end)
Slider(AimP,"Smoothness",1,100,15,10,function(v) Cfg.Aim.Smoothness=v end)
Sep(AimP,13); SL(AimP,"AUXÍLIOS DE MIRA",14)
Toggle(AimP,"Silent Aim",           15,function() return Cfg.Aim.SilentAim end,function(v) Cfg.Aim.SilentAim=v; if v then HookSA() end end,"SA")
Slider(AimP,"Silent Aim Chance (%)",1,100,100,17,function(v) Cfg.Aim.SAChance=v end)
Toggle(AimP,"No Recoil",            20,function() return Cfg.Aim.NoRecoil   end,function(v) Cfg.Aim.NoRecoil=v   end)
Toggle(AimP,"No Spread",            21,function() return Cfg.Aim.NoSpread   end,function(v) Cfg.Aim.NoSpread=v   end)
Toggle(AimP,"Infinite Ammo",        22,function() return Cfg.Aim.InfAmmo    end,function(v) Cfg.Aim.InfAmmo=v    end)
KB(AimP,"Aim Key (segurar)",24,function() return Cfg.Aim.AimKeyName end,function(k,n) Cfg.Aim.AimKey=k; Cfg.Aim.AimKeyName=n end)
PLWidget(AimP,26,"LISTA DE EXCLUSÃO (MIRA)",Cfg.Aim.Blacklist)

Toggle(FovP,"Use FOV",  0,function() return Cfg.Aim.UseFOV  end,function(v) Cfg.Aim.UseFOV=v end)
Toggle(FovP,"Show FOV", 1,function() return Cfg.Aim.ShowFOV end,function(v) Cfg.Aim.ShowFOV=v end)
Slider(FovP,"FOV Size",10,800,120,3,function(v) Cfg.Aim.FOV=v; FOVC.Radius=v end)
Slider(FovP,"FOV Thickness",1,5,2,6,function(v) FOVC.Thickness=v end)

Toggle(TrigP,"TriggerBot",          0,function() return Cfg.Trigger.Enabled   end,function(v) Cfg.Trigger.Enabled=v   end)
Toggle(TrigP,"Team Check",          1,function() return Cfg.Trigger.TeamCheck end,function(v) Cfg.Trigger.TeamCheck=v end)
Slider(TrigP,"Delay (ms)",0,2000,100,2,function(v) Cfg.Trigger.Delay=v end)

-- ============================================================
-- PAGE: VISUALS — ESP
-- ============================================================
local EspP  =Panel(PVis,"ESP",          0,  0,435,468)
local TrackP=Panel(PVis,"Track Player", 443,0,435,468)

-- ESP Enable badge
do
    local er=Instance.new("Frame",EspP); er.Size=UDim2.new(1,0,0,28); er.BackgroundColor3=Color3.fromRGB(26,7,7); er.BorderSizePixel=0; er.LayoutOrder=0; Instance.new("UICorner",er).CornerRadius=UDim.new(0,4)
    local ec=Instance.new("Frame",er); ec.Size=UDim2.new(0,16,0,16); ec.Position=UDim2.new(0,7,0.5,-8); ec.BackgroundColor3=C.bg4; ec.BorderSizePixel=0; Instance.new("UICorner",ec).CornerRadius=UDim.new(0,4)
    local eS=Instance.new("UIStroke",ec); eS.Color=C.sep; eS.Thickness=1
    local eTk=Instance.new("TextLabel",ec); eTk.Text="✓"; eTk.Size=UDim2.new(1,0,1,0); eTk.BackgroundTransparency=1; eTk.TextColor3=C.pink; eTk.Font=FB; eTk.TextSize=13; eTk.Visible=Cfg.ESP.Enabled
    local eL=Instance.new("TextLabel",er); eL.Text="ESP Enabled"; eL.Size=UDim2.new(1,-56,1,0); eL.Position=UDim2.new(0,30,0,0); eL.BackgroundTransparency=1; eL.TextColor3=C.wht; eL.Font=FB; eL.TextSize=13; eL.TextXAlignment=Enum.TextXAlignment.Left
    local eBg=Instance.new("TextLabel",er); eBg.Text="ESP"; eBg.Size=UDim2.new(0,32,0,16); eBg.Position=UDim2.new(1,-36,0.5,-8); eBg.BackgroundColor3=C.red; eBg.TextColor3=C.wht; eBg.Font=FB; eBg.TextSize=10; eBg.BorderSizePixel=0; Instance.new("UICorner",eBg).CornerRadius=UDim.new(0,4)
    local eBtn=Instance.new("TextButton",er); eBtn.Size=UDim2.new(1,0,1,0); eBtn.BackgroundTransparency=1; eBtn.Text=""
    local function ref()
        eTk.Visible=Cfg.ESP.Enabled
        ec.BackgroundColor3=Cfg.ESP.Enabled and Color3.fromRGB(38,7,7) or C.bg4
        eS.Color=Cfg.ESP.Enabled and C.red or C.sep
        er.BackgroundColor3=Cfg.ESP.Enabled and Color3.fromRGB(38,9,9) or Color3.fromRGB(26,7,7)
    end
    _CBs["ESP"]=ref; eBtn.MouseButton1Click:Connect(function() Cfg.ESP.Enabled=not Cfg.ESP.Enabled; ref() end)
end
Toggle(EspP,"Box ESP",       1,function() return Cfg.ESP.BoxESP    end,function(v) Cfg.ESP.BoxESP=v    end)
Toggle(EspP,"Fill Box",      2,function() return Cfg.ESP.FillBox   end,function(v) Cfg.ESP.FillBox=v   end)
Toggle(EspP,"Name ESP",      3,function() return Cfg.ESP.NameESP   end,function(v) Cfg.ESP.NameESP=v   end)
Toggle(EspP,"Health Bar",    4,function() return Cfg.ESP.HealthBar end,function(v) Cfg.ESP.HealthBar=v end)
Toggle(EspP,"Tracers",       5,function() return Cfg.ESP.Tracers   end,function(v) Cfg.ESP.Tracers=v   end)
Toggle(EspP,"Distance",      6,function() return Cfg.ESP.Distance  end,function(v) Cfg.ESP.Distance=v  end)
Toggle(EspP,"Wall Check",    7,function() return Cfg.ESP.WallCheck end,function(v) Cfg.ESP.WallCheck=v end)
Toggle(EspP,"Team Check",    8,function() return Cfg.ESP.TeamCheck end,function(v) Cfg.ESP.TeamCheck=v end)
Toggle(EspP,"Item na Mão",   9,function() return Cfg.ESP.HeldTool  end,function(v) Cfg.ESP.HeldTool=v  end)
Slider(EspP,"Max Distance",50,2000,500,10,function(v) Cfg.ESP.MaxDistance=v end)

-- Track Player
do
    local rbESP=PLWidget(TrackP,0,"JOGADORES RASTREADOS",Cfg.ESP.TrackList)
    Sep(TrackP,6); SL(TrackP,"SERVIDOR (Track/Untrack)",7)
    local onlS=Instance.new("ScrollingFrame",TrackP); onlS.Size=UDim2.new(1,0,0,160); onlS.BackgroundColor3=C.bg4; onlS.BorderSizePixel=0; onlS.LayoutOrder=8
    Instance.new("UICorner",onlS).CornerRadius=UDim.new(0,4); onlS.ScrollBarThickness=2; onlS.ScrollBarImageColor3=C.red; onlS.CanvasSize=UDim2.new(0,0,0,0); onlS.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local onlLL=Instance.new("UIListLayout",onlS); onlLL.Padding=UDim.new(0,2)
    local onlPad=Instance.new("UIPadding",onlS); onlPad.PaddingLeft=UDim.new(0,4); onlPad.PaddingTop=UDim.new(0,4); onlPad.PaddingRight=UDim.new(0,4)
    local function RefOnline()
        for _,c in ipairs(onlS:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local row=Instance.new("Frame",onlS); row.Size=UDim2.new(1,0,0,26); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
            local pN=Instance.new("TextLabel",row); pN.Text=p.Name; pN.Size=UDim2.new(1,-58,1,0); pN.Position=UDim2.new(0,6,0,0); pN.BackgroundTransparency=1; pN.TextColor3=C.text; pN.Font=FM; pN.TextSize=11; pN.TextXAlignment=Enum.TextXAlignment.Left
            local tB=Instance.new("TextButton",row); tB.Size=UDim2.new(0,50,0,18); tB.Position=UDim2.new(1,-53,0.5,-9)
            tB.BackgroundColor3=Cfg.ESP.TrackList[p.Name] and C.red or C.bg4
            tB.Text=Cfg.ESP.TrackList[p.Name] and "Untrack" or "Track"
            tB.TextColor3=C.wht; tB.Font=FB; tB.TextSize=9; tB.BorderSizePixel=0; Instance.new("UICorner",tB).CornerRadius=UDim.new(0,3)
            local cap=p
            tB.MouseButton1Click:Connect(function()
                if Cfg.ESP.TrackList[cap.Name] then Cfg.ESP.TrackList[cap.Name]=nil; tB.BackgroundColor3=C.bg4; tB.Text="Track"
                else Cfg.ESP.TrackList[cap.Name]=true; tB.BackgroundColor3=C.red; tB.Text="Untrack" end
                rbESP()
            end)
        end
    end
    Btn(TrackP,"↺ Atualizar Lista",9,RefOnline); RefOnline()
end

-- ============================================================
-- PAGE: XRAY
-- ============================================================
local XrayP=Panel(PXray,"Xray (Ver através de paredes)",0,0,435,468,C.blue)
local SkelP=Panel(PXray,"Skeleton",443,0,435,280,C.blue)

do
    local er=Instance.new("Frame",XrayP); er.Size=UDim2.new(1,0,0,28); er.BackgroundColor3=Color3.fromRGB(7,15,34); er.BorderSizePixel=0; er.LayoutOrder=0; Instance.new("UICorner",er).CornerRadius=UDim.new(0,4)
    local ec=Instance.new("Frame",er); ec.Size=UDim2.new(0,16,0,16); ec.Position=UDim2.new(0,7,0.5,-8); ec.BackgroundColor3=C.bg4; ec.BorderSizePixel=0; Instance.new("UICorner",ec).CornerRadius=UDim.new(0,4)
    local eS=Instance.new("UIStroke",ec); eS.Color=C.sep; eS.Thickness=1
    local eTk=Instance.new("TextLabel",ec); eTk.Text="✓"; eTk.Size=UDim2.new(1,0,1,0); eTk.BackgroundTransparency=1; eTk.TextColor3=C.blueH; eTk.Font=FB; eTk.TextSize=13; eTk.Visible=Cfg.Xray.Enabled
    local eL=Instance.new("TextLabel",er); eL.Text="Xray Enabled"; eL.Size=UDim2.new(1,-60,1,0); eL.Position=UDim2.new(0,30,0,0); eL.BackgroundTransparency=1; eL.TextColor3=C.blueH; eL.Font=FB; eL.TextSize=13; eL.TextXAlignment=Enum.TextXAlignment.Left
    local eBg=Instance.new("TextLabel",er); eBg.Text="XRAY"; eBg.Size=UDim2.new(0,40,0,16); eBg.Position=UDim2.new(1,-44,0.5,-8); eBg.BackgroundColor3=C.blue; eBg.TextColor3=C.wht; eBg.Font=FB; eBg.TextSize=9; eBg.BorderSizePixel=0; Instance.new("UICorner",eBg).CornerRadius=UDim.new(0,4)
    local eBtn=Instance.new("TextButton",er); eBtn.Size=UDim2.new(1,0,1,0); eBtn.BackgroundTransparency=1; eBtn.Text=""
    local function ref() eTk.Visible=Cfg.Xray.Enabled; ec.BackgroundColor3=Cfg.Xray.Enabled and Color3.fromRGB(7,15,50) or C.bg4; eS.Color=Cfg.Xray.Enabled and C.blue or C.sep end
    _CBs["Xray"]=ref; eBtn.MouseButton1Click:Connect(function() Cfg.Xray.Enabled=not Cfg.Xray.Enabled; ref() end)
end
Toggle(XrayP,"Box ESP",    1,function() return Cfg.Xray.BoxESP    end,function(v) Cfg.Xray.BoxESP=v    end,nil,C.blueH)
Toggle(XrayP,"Fill Box",   2,function() return Cfg.Xray.FillBox   end,function(v) Cfg.Xray.FillBox=v   end,nil,C.blueH)
Toggle(XrayP,"Name ESP",   3,function() return Cfg.Xray.NameESP   end,function(v) Cfg.Xray.NameESP=v   end,nil,C.blueH)
Toggle(XrayP,"Health Bar", 4,function() return Cfg.Xray.HealthBar end,function(v) Cfg.Xray.HealthBar=v end,nil,C.blueH)
Toggle(XrayP,"Tracers",    5,function() return Cfg.Xray.Tracers   end,function(v) Cfg.Xray.Tracers=v   end,nil,C.blueH)
Toggle(XrayP,"Distance",   6,function() return Cfg.Xray.Distance  end,function(v) Cfg.Xray.Distance=v  end,nil,C.blueH)
Toggle(XrayP,"Team Check", 7,function() return Cfg.Xray.TeamCheck end,function(v) Cfg.Xray.TeamCheck=v end,nil,C.blueH)
Slider(XrayP,"Max Distance",50,5000,1000,8,function(v) Cfg.Xray.MaxDistance=v end)
Toggle(SkelP,"Skeleton",   0,function() return Cfg.Xray.Skeleton  end,function(v) Cfg.Xray.Skeleton=v  end,nil,C.blueH)

-- ============================================================
-- PAGE: MISC
-- ============================================================
local MovP =Panel(PMisc,"Movimento & Física",  0,  0,435,468)
local UtilP=Panel(PMisc,"Utilidades & Server", 443,0,435,468)

SL(MovP,"VOAR",0)
Toggle(MovP,"Fly",           1,function() return Cfg.Misc.Fly      end,function(v) Cfg.Misc.Fly=v;    if v then EnableFly()    else DisableFly()    end end,"Fly")
Toggle(MovP,"Fly Boost (3x)",2,function() return Cfg.Misc.FlyBoost end,function(v) Cfg.Misc.FlyBoost=v end)
Slider(MovP,"Fly Speed",1,500,50,3,function(v) Cfg.Misc.FlySpeed=v end)
Sep(MovP,5); SL(MovP,"MOVIMENTO",6)
Toggle(MovP,"Noclip",        7,function() return Cfg.Misc.Noclip   end,function(v) Cfg.Misc.Noclip=v; if v then EnableNoclip() else DisableNoclip() end end,"NC")
Toggle(MovP,"Speed Hack",    9,function() return Cfg.Misc.Speed    end,function(v) Cfg.Misc.Speed=v;  ApplySpeed() end,"Speed")
Sel(MovP,"Speed Method",{"WalkSpeed","BodyVelocity"},"WalkSpeed",10,function(v) Cfg.Misc.SpeedMethod=v; ApplySpeed() end)
Slider(MovP,"Walk Speed",1,1000,25,12,function(v) Cfg.Misc.WalkSpeed=v; if Cfg.Misc.Speed then ApplySpeed() end end)
Sep(MovP,15); SL(MovP,"PULO",16)
Toggle(MovP,"Jump Modifier", 17,function() return Cfg.Misc.JumpMod  end,function(v) Cfg.Misc.JumpMod=v; ApplyJump() end)
Toggle(MovP,"Infinite Jump", 18,function() return Cfg.Misc.InfJump  end,function(v) Cfg.Misc.InfJump=v end)
Sel(MovP,"Jump Method",{"JumpPower","UseJumpPower"},"JumpPower",19,function(v) Cfg.Misc.JumpMethod=v; ApplyJump() end)
Slider(MovP,"Jump Power",1,500,80,21,function(v) Cfg.Misc.JumpPower=v; if Cfg.Misc.JumpMod then ApplyJump() end end)
Sep(MovP,23); SL(MovP,"OUTROS",24)
Toggle(MovP,"Anti Ragdoll",  25,function() return Cfg.Misc.AntiRag  end,function(v) Cfg.Misc.AntiRag=v  end)
Sep(MovP,26); SL(MovP,"TELEPORTE",27)
Toggle(MovP,"Click Teleport",28,function() return Cfg.Misc.ClickTp  end,function(v) Cfg.Misc.ClickTp=v  end)
do local f=Instance.new("Frame",MovP); f.Size=UDim2.new(1,0,0,14); f.BackgroundTransparency=1; f.LayoutOrder=29; local l=Instance.new("TextLabel",f); l.Text="Clique no chão para teletransportar"; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left end

-- Utilidades
SL(UtilP,"GERAL",0)
Toggle(UtilP,"Anti-AFK",        1,function() return Cfg.Misc.AntiAFK        end,function(v) Cfg.Misc.AntiAFK=v        end)
Toggle(UtilP,"Hitbox Extender", 3,function() return Cfg.Misc.HitboxExtender end,function(v) Cfg.Misc.HitboxExtender=v; RefreshHitboxes() end)
Slider(UtilP,"Hitbox Size",1,80,8,5,function(v) Cfg.Misc.HitboxSize=v; if Cfg.Misc.HitboxExtender then RefreshHitboxes() end end)
Sep(UtilP,7); SL(UtilP,"CÂMERA LIVRE",8)
Toggle(UtilP,"FreeCam",         9,function() return Cfg.Misc.FreeCam end,function(v) Cfg.Misc.FreeCam=v; if v then EnableFreeCam() else DisableFreeCam() end end,"FC")
Slider(UtilP,"FreeCam Speed",1,30,1,10,function(v) Cfg.Misc.FCamSpeed=v end)
do local f=Instance.new("Frame",UtilP); f.Size=UDim2.new(1,0,0,14); f.BackgroundTransparency=1; f.LayoutOrder=12; local l=Instance.new("TextLabel",f); l.Text="WASD/E/Q · FreeCam"; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left end
Sep(UtilP,13); SL(UtilP,"TOOLS DO MAPA",14)
do
    local gs=StatusLbl(UtilP,15)
    -- Lista de tools no mapa
    local toolListH=Instance.new("Frame",UtilP); toolListH.Size=UDim2.new(1,0,0,100); toolListH.BackgroundColor3=C.bg4; toolListH.BorderSizePixel=0; toolListH.LayoutOrder=16; Instance.new("UICorner",toolListH).CornerRadius=UDim.new(0,4)
    local toolListS=Instance.new("ScrollingFrame",toolListH); toolListS.Size=UDim2.new(1,-8,1,-8); toolListS.Position=UDim2.new(0,4,0,4); toolListS.BackgroundTransparency=1; toolListS.BorderSizePixel=0; toolListS.ScrollBarThickness=2; toolListS.ScrollBarImageColor3=C.red; toolListS.CanvasSize=UDim2.new(0,0,0,0); toolListS.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",toolListS).Padding=UDim.new(0,2)
    local function RefreshToolList()
        for _,c in ipairs(toolListS:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        local tools=GetMapTools()
        if #tools==0 then local el=Instance.new("TextLabel",toolListS); el.Text="(nenhuma tool no mapa)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left; return end
        for _,entry in ipairs(tools) do
            local row=Instance.new("Frame",toolListS); row.Size=UDim2.new(1,0,0,24); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
            local nl=Instance.new("TextLabel",row); nl.Text="🔧 "..entry.name; nl.Size=UDim2.new(1,-58,1,0); nl.Position=UDim2.new(0,6,0,0); nl.BackgroundTransparency=1; nl.TextColor3=C.text; nl.Font=FM; nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left
            local gb=Instance.new("TextButton",row); gb.Text="Pegar"; gb.Size=UDim2.new(0,50,0,18); gb.Position=UDim2.new(1,-53,0.5,-9); gb.BackgroundColor3=C.red; gb.TextColor3=C.wht; gb.Font=FB; gb.TextSize=10; gb.BorderSizePixel=0; Instance.new("UICorner",gb).CornerRadius=UDim.new(0,3)
            local cap=entry.tool
            gb.MouseButton1Click:Connect(function()
                local ok=GrabTool(cap)
                gs(ok and "✓ Pegou: "..entry.name or "❌ Falhou",ok and C.green or C.redH)
            end)
        end
    end
    Btn(UtilP,"🔧 Pegar Mais Próxima",17,function()
        local n=GrabNearestTool(); gs(n and "✓ Pegou: "..n or "❌ Nenhuma tool",n and C.green or C.redH)
    end,Color3.fromRGB(20,50,20))
    Btn(UtilP,"↺ Listar Tools do Mapa",18,RefreshToolList,Color3.fromRGB(12,35,55))
end
Sep(UtilP,19); SL(UtilP,"BOOMBOX",20)
do
    local bbBox=IFld(UtilP,"ID da Música...",21,function(v) Cfg.Misc.BoomboxID=v end)
    local bbSF=Instance.new("Frame",UtilP); bbSF.Size=UDim2.new(1,0,0,14); bbSF.BackgroundTransparency=1; bbSF.LayoutOrder=23
    local bbSL=Instance.new("TextLabel",bbSF); bbSL.Text="Parado"; bbSL.Size=UDim2.new(1,0,1,0); bbSL.BackgroundTransparency=1; bbSL.TextColor3=C.dim; bbSL.Font=FM; bbSL.TextSize=10; bbSL.TextXAlignment=Enum.TextXAlignment.Left
    local prf=Instance.new("Frame",UtilP); prf.Size=UDim2.new(1,0,0,28); prf.BackgroundTransparency=1; prf.LayoutOrder=24
    local prLL=Instance.new("UIListLayout",prf); prLL.FillDirection=Enum.FillDirection.Horizontal; prLL.Padding=UDim.new(0,4)
    local pBtn=Instance.new("TextButton",prf); pBtn.Text="▶ Tocar"; pBtn.Size=UDim2.new(0.5,-2,1,0); pBtn.BackgroundColor3=Color3.fromRGB(14,52,14); pBtn.TextColor3=C.green; pBtn.Font=FB; pBtn.TextSize=12; pBtn.BorderSizePixel=0; Instance.new("UICorner",pBtn).CornerRadius=UDim.new(0,4)
    local sBtn=Instance.new("TextButton",prf); sBtn.Text="■ Parar"; sBtn.Size=UDim2.new(0.5,-2,1,0); sBtn.BackgroundColor3=Color3.fromRGB(52,10,10); sBtn.TextColor3=C.redH; sBtn.Font=FB; sBtn.TextSize=12; sBtn.BorderSizePixel=0; Instance.new("UICorner",sBtn).CornerRadius=UDim.new(0,4)
    pBtn.MouseButton1Click:Connect(function()
        local id=Cfg.Misc.BoomboxID~="" and Cfg.Misc.BoomboxID or bbBox.Text
        if id~="" then PlayBoom(id); bbSL.Text="▶ "..id; bbSL.TextColor3=C.green else bbSL.Text="❌ ID inválido"; bbSL.TextColor3=C.redH end
    end)
    sBtn.MouseButton1Click:Connect(function() StopBoom(); bbSL.Text="Parado"; bbSL.TextColor3=C.dim end)
end
Sep(UtilP,25); SL(UtilP,"TOOL DUPLICATOR",26)
do
    IFld(UtilP,"Nome da Tool...",27,function(v) Cfg.Misc.DupeToolName=v end)
    Btn(UtilP,"Duplicar Tool",29,DupeTool)
end
Sep(UtilP,31); SL(UtilP,"SERVER",32)
Btn(UtilP,"🔄 Rejoin Server",33,function() Rejoin() end,Color3.fromRGB(10,10,55),C.blueH)
Btn(UtilP,"🌐 Server Hop",35,function() ServerHop() end,Color3.fromRGB(10,40,10),C.green)

-- ============================================================
-- PAGE: TROLL
-- ============================================================
local Tr1=Panel(PTroll,"Trollagem - Alvo",      0,  0,435,468,C.purple)
local Tr2=Panel(PTroll,"Trollagem - Pessoal",443,0,435,468,C.purple)

SL(Tr1,"JOGADOR ALVO",0,C.purpleH)
local ttBox=IFld(Tr1,"Username do alvo...",1,function(v) Cfg.Troll.Target=v end)
local ts=StatusLbl(Tr1,3)
Sep(Tr1,4); SL(Tr1,"AÇÕES NO ALVO",5,C.purpleH)

Btn(Tr1,"💥 Fling",            6,function() ts(TrollFling(Cfg.Troll.Target),C.purpleH) end,Color3.fromRGB(58,8,58))
Btn(Tr1,"❄️ Freeze/Unfreeze", 8,function() ts(TrollFreeze(Cfg.Troll.Target),C.blueH)  end,Color3.fromRGB(12,18,58))
Btn(Tr1,"🪑 Sit Loop/Parar", 10,function() ts(TrollSit(Cfg.Troll.Target),C.purpleH)   end,Color3.fromRGB(38,8,58))
Btn(Tr1,"📦 Tp Para Mim",    12,function() ts(TrollTpToMe(Cfg.Troll.Target),C.green)   end,Color3.fromRGB(12,52,12))
Btn(Tr1,"💀 Loop Kill ON/OFF",14,function()
    Cfg.Troll.LoopKill=not Cfg.Troll.LoopKill
    if Cfg.Troll.LoopKill then StartLoopKill(Cfg.Troll.Target); ts("✓ Loop Kill: "..Cfg.Troll.Target,C.redH)
    else ts("✓ Loop Kill parado",C.dim) end
end,Color3.fromRGB(52,6,6))
Btn(Tr1,"✂️ Remove Limbs",   16,function() ts(TrollLimbs(Cfg.Troll.Target),C.orange)  end,Color3.fromRGB(48,28,4))
Btn(Tr1,"💣 Unanchor Mapa",  18,function() ts(TrollUnanchor(Cfg.Troll.Target),C.orange)end,Color3.fromRGB(48,22,4))
Sep(Tr1,20); SL(Tr1,"FAKE ADMIN",21,C.purpleH)
IFld(Tr1,"Tag (ex: [ADMIN])",22,function(v) Cfg.Troll.FakeTag=v end)
local fkMsgBox=IFld(Tr1,"Mensagem...",24,function() end)
Btn(Tr1,"📢 Enviar Fake Admin Msg",26,function()
    TrollFakeAdmin(fkMsgBox.Text~="" and fkMsgBox.Text or "223HUB"); ts("✓ Mensagem enviada",C.purpleH)
end,Color3.fromRGB(48,8,78))

SL(Tr2,"PESSOAL",0,C.purpleH)
Toggle(Tr2,"Spin/Spinbot",  1,function() return Cfg.Misc.SpinBot    end,function(v) Cfg.Misc.SpinBot=v; TrollSpin(v) end,nil,C.purpleH)
Slider(Tr2,"Spin Speed",1,50,10,3,function(v) Cfg.Troll.SpinSpeed=v; if Cfg.Misc.SpinBot then TrollSpin(true) end end)
Toggle(Tr2,"Invisible",     6,function() return Cfg.Troll.Invisible  end,function(v) Cfg.Troll.Invisible=v; TrollInvis(v) end,nil,C.purpleH)
Sep(Tr2,8); SL(Tr2,"TAMANHO",9,C.purpleH)
Btn(Tr2,"🔷 Giant",10,function() TrollScale(Cfg.Troll.GiantScale) end,Color3.fromRGB(18,38,78))
Btn(Tr2,"🔸 Tiny", 12,function() TrollScale(Cfg.Troll.TinyScale)  end,Color3.fromRGB(38,18,78))
Btn(Tr2,"↺ Normal",14,function() TrollScale(1) end,C.bg4,C.text)
Slider(Tr2,"Giant Scale",2,20,5,15,function(v) Cfg.Troll.GiantScale=v end)
Slider(Tr2,"Tiny Scale",1,10,3,17,function(v) Cfg.Troll.TinyScale=v/10 end)
Sep(Tr2,19); SL(Tr2,"RAINBOW",20,C.purpleH)
Toggle(Tr2,"Rainbow Armor", 21,function() return Cfg.Troll.Rainbow  end,function(v) Cfg.Troll.Rainbow=v; EnableRainbow(v) end,nil,C.purpleH)
Slider(Tr2,"Rainbow Speed",1,20,5,23,function(v) Cfg.Troll.RainbowSpeed=v*0.01 end)
Sep(Tr2,25); SL(Tr2,"CHAT SPAM",26,C.purpleH)
IFld(Tr2,"Mensagem do spam...",27,function(v) Cfg.Troll.SpamMsg=v end)
Slider(Tr2,"Delay (s)",1,30,1,29,function(v) Cfg.Troll.SpamDelay=v end)
Toggle(Tr2,"Chat Spammer",  31,function() return Cfg.Troll.ChatSpam end,function(v) Cfg.Troll.ChatSpam=v; if v then StartSpam() else StopSpam() end end,nil,C.purpleH)
Sep(Tr2,33); SL(Tr2,"SOUND SPAM",34,C.purpleH)
local sndBox=IFld(Tr2,"ID do som...",35,function(v) Cfg.Troll.SoundID=v end)
local sndSF=Instance.new("Frame",Tr2); sndSF.Size=UDim2.new(1,0,0,14); sndSF.BackgroundTransparency=1; sndSF.LayoutOrder=37
local sndSL=Instance.new("TextLabel",sndSF); sndSL.Text="Parado"; sndSL.Size=UDim2.new(1,0,1,0); sndSL.BackgroundTransparency=1; sndSL.TextColor3=C.dim; sndSL.Font=FM; sndSL.TextSize=10; sndSL.TextXAlignment=Enum.TextXAlignment.Left
local sndRow=Instance.new("Frame",Tr2); sndRow.Size=UDim2.new(1,0,0,28); sndRow.BackgroundTransparency=1; sndRow.LayoutOrder=38
local sLL=Instance.new("UIListLayout",sndRow); sLL.FillDirection=Enum.FillDirection.Horizontal; sLL.Padding=UDim.new(0,4)
local sPlay=Instance.new("TextButton",sndRow); sPlay.Text="▶ Tocar"; sPlay.Size=UDim2.new(0.5,-2,1,0); sPlay.BackgroundColor3=Color3.fromRGB(38,6,58); sPlay.TextColor3=C.purpleH; sPlay.Font=FB; sPlay.TextSize=12; sPlay.BorderSizePixel=0; Instance.new("UICorner",sPlay).CornerRadius=UDim.new(0,4)
local sStop=Instance.new("TextButton",sndRow); sStop.Text="■ Parar"; sStop.Size=UDim2.new(0.5,-2,1,0); sStop.BackgroundColor3=Color3.fromRGB(52,10,10); sStop.TextColor3=C.redH; sStop.Font=FB; sStop.TextSize=12; sStop.BorderSizePixel=0; Instance.new("UICorner",sStop).CornerRadius=UDim.new(0,4)
sPlay.MouseButton1Click:Connect(function()
    local id=Cfg.Troll.SoundID~="" and Cfg.Troll.SoundID or sndBox.Text
    if id~="" then StartSoundSpam(id); sndSL.Text="▶ "..id; sndSL.TextColor3=C.purpleH else sndSL.Text="❌ ID inválido"; sndSL.TextColor3=C.redH end
end)
sStop.MouseButton1Click:Connect(function() StopSoundSpam(); sndSL.Text="Parado"; sndSL.TextColor3=C.dim end)

-- ============================================================
-- PAGE: SETTINGS
-- ============================================================
local KbdP =Panel(PSettings,"Teclas de Atalho",          0,  0,435,468)
local CfgP =Panel(PSettings,"Configurações & Saves",   443,0,290,468)
local LogP =Panel(PSettings,"Chat Log",                737,0,175,468)

-- Keybinds
KB(KbdP,"Toggle GUI",         0,function() return Cfg.Settings.ToggleKeyName  end,function(k,n) Cfg.Settings.ToggleKey=k;  Cfg.Settings.ToggleKeyName=n  end)
KB(KbdP,"ESP On/Off",         2,function() return Cfg.Settings.ESPKeyName     end,function(k,n) Cfg.Settings.ESPKey=k;     Cfg.Settings.ESPKeyName=n     end)
KB(KbdP,"Aimbot On/Off",      4,function() return Cfg.Settings.AimbotKeyName  end,function(k,n) Cfg.Settings.AimbotKey=k;  Cfg.Settings.AimbotKeyName=n  end)
KB(KbdP,"Silent Aim On/Off",  6,function() return Cfg.Settings.SilentKeyName  end,function(k,n) Cfg.Settings.SilentKey=k;  Cfg.Settings.SilentKeyName=n  end)
KB(KbdP,"Fly On/Off",         8,function() return Cfg.Settings.FlyKeyName     end,function(k,n) Cfg.Settings.FlyKey=k;     Cfg.Settings.FlyKeyName=n     end)
KB(KbdP,"Noclip On/Off",     10,function() return Cfg.Settings.NoclipKeyName  end,function(k,n) Cfg.Settings.NoclipKey=k;  Cfg.Settings.NoclipKeyName=n  end)
KB(KbdP,"Speed Hack On/Off", 12,function() return Cfg.Settings.SpeedKeyName   end,function(k,n) Cfg.Settings.SpeedKey=k;   Cfg.Settings.SpeedKeyName=n   end)
KB(KbdP,"Xray On/Off",       14,function() return Cfg.Settings.XrayKeyName    end,function(k,n) Cfg.Settings.XrayKey=k;    Cfg.Settings.XrayKeyName=n    end)
KB(KbdP,"FreeCam On/Off",    16,function() return Cfg.Settings.FreeCamKeyName end,function(k,n) Cfg.Settings.FreeCamKey=k; Cfg.Settings.FreeCamKeyName=n end)
KB(KbdP,"Aim Key (segurar)", 18,function() return Cfg.Aim.AimKeyName          end,function(k,n) Cfg.Aim.AimKey=k;          Cfg.Aim.AimKeyName=n           end)
Sep(KbdP,20)
do local f=Instance.new("Frame",KbdP); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=21; local l=Instance.new("TextLabel",f); l.Text="Clique no badge [TECLA] e pressione uma tecla para remapear."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true end

-- Saves
SL(CfgP,"SAVES PERSONALIZADOS",0)
local svSt=StatusLbl(CfgP,1)
local svNameBox=IFld(CfgP,"Nome do save...",2,function() end)
local function GSN() return svNameBox and svNameBox.Text~="" and svNameBox.Text or "default" end

Btn(CfgP,"💾 Salvar Config",   4,function()
    local ok,info=SaveCfg(GSN()); if ok then svSt("✓ Salvo: "..info,C.green) else svSt("❌ "..tostring(info),C.redH) end
end,Color3.fromRGB(10,50,10))
Btn(CfgP,"📂 Carregar Config",  6,function()
    local ok,info=LoadCfg(GSN()); if ok then svSt("✓ Carregado",C.green) else svSt("❌ "..tostring(info),C.redH) end
end,Color3.fromRGB(20,34,8))
Btn(CfgP,"🗑 Deletar Config",   8,function()
    local ok=DelCfg(GSN()); svSt(ok and "✓ Deletado" or "❌ delfile indisponível",ok and C.orange or C.redH)
end,Color3.fromRGB(46,10,4))

Sep(CfgP,10); SL(CfgP,"SAVES DISPONÍVEIS",11)
local svLH=Instance.new("Frame",CfgP); svLH.Size=UDim2.new(1,0,0,100); svLH.BackgroundColor3=C.bg4; svLH.BorderSizePixel=0; svLH.LayoutOrder=12; Instance.new("UICorner",svLH).CornerRadius=UDim.new(0,4)
local svLS=Instance.new("ScrollingFrame",svLH); svLS.Size=UDim2.new(1,-8,1,-8); svLS.Position=UDim2.new(0,4,0,4); svLS.BackgroundTransparency=1; svLS.BorderSizePixel=0; svLS.ScrollBarThickness=2; svLS.ScrollBarImageColor3=C.red; svLS.CanvasSize=UDim2.new(0,0,0,0); svLS.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",svLS).Padding=UDim.new(0,2)
local function RefSaves()
    for _,c in ipairs(svLS:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    local fs=ListCfgs()
    if #fs==0 then local el=Instance.new("TextLabel",svLS); el.Text="(nenhum save)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left; return end
    for _,name in ipairs(fs) do
        local row=Instance.new("Frame",svLS); row.Size=UDim2.new(1,0,0,22); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
        local nl=Instance.new("TextLabel",row); nl.Text="📄 "..name; nl.Size=UDim2.new(1,-52,1,0); nl.Position=UDim2.new(0,6,0,0); nl.BackgroundTransparency=1; nl.TextColor3=C.text; nl.Font=FM; nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left
        local lb=Instance.new("TextButton",row); lb.Text="Load"; lb.Size=UDim2.new(0,36,0,16); lb.Position=UDim2.new(1,-40,0.5,-8); lb.BackgroundColor3=C.red; lb.TextColor3=C.wht; lb.Font=FB; lb.TextSize=9; lb.BorderSizePixel=0; Instance.new("UICorner",lb).CornerRadius=UDim.new(0,3)
        local cap=name; lb.MouseButton1Click:Connect(function()
            local ok,info=LoadCfg(cap); svSt(ok and "✓ "..cap.." carregado" or "❌ "..tostring(info),ok and C.green or C.redH)
        end)
    end
end
Btn(CfgP,"↺ Atualizar Saves",13,RefSaves); RefSaves()

Sep(CfgP,15); SL(CfgP,"RESET",16)
Btn(CfgP,"🗑 Resetar para Padrão",17,function()
    for k in pairs({BoxESP=0,FillBox=0,NameESP=0,HealthBar=0,Tracers=0,Distance=0,WallCheck=0,Enabled=0,TeamCheck=0,HeldTool=0}) do Cfg.ESP[k]=false end
    Cfg.ESP.MaxDistance=500; Cfg.ESP.TrackList={}
    Cfg.Xray.Enabled=false; Cfg.Xray.Skeleton=false; Cfg.Xray.TeamCheck=false
    for k in pairs({Aimbot=0,SilentAim=0,WallCheck=0,TeamCheck=0,Prediction=0,NoRecoil=0,NoSpread=0,InfAmmo=0,ShowFOV=0}) do Cfg.Aim[k]=false end
    Cfg.Aim.AimKey=Enum.KeyCode.E; Cfg.Aim.AimKeyName="E"; Cfg.Aim.Blacklist={}; Cfg.Aim.FOV=120
    Cfg.Trigger.Enabled=false; Cfg.Trigger.TeamCheck=false; Cfg.Trigger.Delay=100
    for k in pairs({Fly=0,FlyBoost=0,Noclip=0,Speed=0,AntiAFK=0,HitboxExtender=0,JumpMod=0,InfJump=0,AntiRag=0,FreeCam=0,ClickTp=0,SpinBot=0}) do Cfg.Misc[k]=false end
    svSt("✓ Resetado",C.orange)
end,Color3.fromRGB(46,10,4))

Sep(CfgP,19); SL(CfgP,"CRÉDITOS",20)
IL(CfgP,"SCRIPT POR BRUNO223J AND TY",21,C.gold)
IL(CfgP,"DISCORD: .223j  |  frty2017",22,C.gold)
IL(CfgP,"HUB BY REVOLUCIONARI'US GROUP",23,C.wht)
IL(CfgP,"v8.0 · Toggle: [;] · Arrastável",24,C.dim)

Sep(CfgP,25); SL(CfgP,"REMOVER SCRIPT",26,C.red)
Btn(CfgP,"🗑 Remover Script (Desligar Tudo)",27,function()
    -- desliga tudo antes de destruir
    Cfg.Aim.Aimbot=false; Cfg.Aim.SilentAim=false; Cfg.ESP.Enabled=false; Cfg.Xray.Enabled=false
    Cfg.Misc.Fly=false; Cfg.Misc.Noclip=false; Cfg.Misc.Speed=false; Cfg.Misc.FreeCam=false
    Cfg.Troll.ChatSpam=false; Cfg.Troll.Rainbow=false; Cfg.Troll.LoopKill=false
    DisableFly(); DisableNoclip(); DisableFreeCam()
    StopBoom(); StopSoundSpam()
    if _spinBG then pcall(function() _spinBG:Destroy() end) end
    if _sitConn then _sitConn:Disconnect() end
    -- Remove todas as drawings
    for p,_ in pairs(ESPO) do KillESP(p) end
    pcall(function() FOVC:Remove() end)
    -- Restaura speed/jump
    local char=LP.Character; if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=16; hum.JumpPower=50; hum.PlatformStand=false end
    end
    -- Destrói GUI
    task.wait(0.1)
    if SG and SG.Parent then SG:Destroy() end
    print("[223HUB v8.0] Script removido.")
end,Color3.fromRGB(80,8,8),C.redH)

-- Chat Log
SL(LogP,"CHAT LOG (últimas msgs)",0,C.gold)
local clScroll=Instance.new("ScrollingFrame",LogP); clScroll.Size=UDim2.new(1,0,0,380); clScroll.BackgroundColor3=C.bg4; clScroll.BorderSizePixel=0; clScroll.LayoutOrder=1
Instance.new("UICorner",clScroll).CornerRadius=UDim.new(0,4); clScroll.ScrollBarThickness=2; clScroll.ScrollBarImageColor3=C.gold; clScroll.CanvasSize=UDim2.new(0,0,0,0); clScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local clLL=Instance.new("UIListLayout",clScroll); clLL.Padding=UDim.new(0,2)
local clPad=Instance.new("UIPadding",clScroll); clPad.PaddingLeft=UDim.new(0,4); clPad.PaddingTop=UDim.new(0,4); clPad.PaddingRight=UDim.new(0,4)

local function RefreshLog()
    for _,c in ipairs(clScroll:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
    for i=1,math.min(#_chatLog,50) do
        local entry=_chatLog[i]
        local row=Instance.new("Frame",clScroll); row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
        local nl=Instance.new("TextLabel",row); nl.Size=UDim2.new(1,0,0,14); nl.Position=UDim2.new(0,4,0,2); nl.BackgroundTransparency=1; nl.TextColor3=C.gold; nl.Font=FB; nl.TextSize=10; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Text=entry.player.." ["..entry.time.."]"
        local ml=Instance.new("TextLabel",row); ml.Size=UDim2.new(1,0,0,14); ml.Position=UDim2.new(0,4,0,16); ml.BackgroundTransparency=1; ml.TextColor3=C.text; ml.Font=FM; ml.TextSize=10; ml.TextXAlignment=Enum.TextXAlignment.Left; ml.Text=entry.msg; ml.TextTruncate=Enum.TextTruncate.AtEnd
    end
    if #_chatLog==0 then local el=Instance.new("TextLabel",clScroll); el.Text="(sem mensagens)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left end
end
Btn(LogP,"↺ Atualizar Log",2,RefreshLog,C.bg4,C.gold)
RefreshLog()

-- Auto-refresh chat log a cada 5s quando aba Settings estiver aberta
task.spawn(function()
    while true do
        task.wait(5)
        if _curTab=="Settings" then pcall(RefreshLog) end
    end
end)

print("[223HUB v8.0] ✓ | BRUNO223J & TY | .223j | frty2017 | Toggle=[;]")
