-- ╔══════════════════════════════════════════════════════════╗
-- ║                    223HUB  v7.0                          ║
-- ║      SCRIPT FEITO POR BRUNO223J E TY                     ║
-- ║  DISCORD: .223j frty2017                                 ║
-- ╚══════════════════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Workspace        = game:GetService("Workspace")
local Chat             = game:GetService("Chat")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = Workspace.CurrentCamera

-- ============================================================
-- CONFIG
-- ============================================================

local Cfg = {
    ESP = {
        Enabled=false, BoxESP=false, FillBox=false, NameESP=false,
        HealthBar=false, Tracers=false, Distance=false, WallCheck=false,
        MaxDistance=500, TrackList={},
        BoxColor=Color3.fromRGB(200,40,40), FillColor=Color3.fromRGB(200,40,40),
        NameColor=Color3.fromRGB(255,255,255), TracerColor=Color3.fromRGB(200,40,40),
        DistanceColor=Color3.fromRGB(200,200,200),
        HealthBarColor=Color3.fromRGB(0,220,80), HealthBarBgColor=Color3.fromRGB(50,0,0),
    },
    Xray = {
        Enabled=false, BoxESP=false, FillBox=false, NameESP=false,
        HealthBar=false, Tracers=false, Distance=false,
        BoxColor=Color3.fromRGB(0,160,255), FillColor=Color3.fromRGB(0,120,220),
        NameColor=Color3.fromRGB(180,220,255), TracerColor=Color3.fromRGB(0,160,255),
        DistanceColor=Color3.fromRGB(150,200,255),
        HealthBarColor=Color3.fromRGB(0,200,255), HealthBarBgColor=Color3.fromRGB(0,30,60),
        SkeletonColor=Color3.fromRGB(0,200,255), Skeleton=false, MaxDistance=1000,
    },
    Aim = {
        Aimbot=false, SilentAim=false, WallCheck=false,
        Prediction=false, PredStrength=1,
        NoRecoil=false, NoSpread=false,
        FOV=90, ShowFOV=false, UseFOV=false,
        AimPart="Head", LockMode="First Person",
        Smoothness=20, AimKey=Enum.KeyCode.E, AimKeyName="E",
        SilentAimChance=100, InfiniteAmmo=false, Blacklist={},
    },
    TriggerBot = { Enabled=false, TeamCheck=false, Delay=0 },
    Misc = {
        Fly=false, FlySpeed=50, FlyBoost=false,
        Noclip=false, Speed=false, WalkSpeed=16, SpeedMethod="WalkSpeed",
        AntiAFK=false, HitboxExtender=false, HitboxSize=8,
        JumpModifier=false, JumpPower=50, JumpMethod="JumpPower",
        InfiniteJump=false, AntiRagdoll=false,
        FreeCam=false, FreeCamSpeed=1,
        Boombox=false, BoomboxID="",
        DupeToolName="",
        ClickTeleport=false,
        GrabTool=false,
    },
    Troll = {
        TargetPlayer="",
        ChatSpam=false, ChatSpamMsg="223HUB", ChatSpamDelay=1,
        Rainbow=false, RainbowSpeed=0.05,
        SoundSpam=false, SoundSpamID="",
        LoopKill=false, LoopKillTarget="",
        SpinBot=false, SpinSpeed=10,
        Invisible=false,
        GiantScale=5, TinyScale=0.3,
        FakeTag="[ADMIN]",
    },
    Settings = {
        ToggleKey=Enum.KeyCode.Semicolon, ToggleKeyName=";",
        ESPKey=Enum.KeyCode.F2,           ESPKeyName="F2",
        AimbotToggleKey=Enum.KeyCode.F3,  AimbotToggleKeyName="F3",
        SilentKey=Enum.KeyCode.F4,        SilentKeyName="F4",
        FlyKey=Enum.KeyCode.F5,           FlyKeyName="F5",
        NoclipKey=Enum.KeyCode.F6,        NoclipKeyName="F6",
        SpeedKey=Enum.KeyCode.F7,         SpeedKeyName="F7",
        XrayKey=Enum.KeyCode.F8,          XrayKeyName="F8",
        FreeCamKey=Enum.KeyCode.F9,       FreeCamKeyName="F9",
    },
}

-- ============================================================
-- SAVE / LOAD (com nome personalizado)
-- ============================================================

local SAVE_DIR = "223TYHUB_Configs/"

local function EnsureDir()
    pcall(function()
        if not isfolder(SAVE_DIR) then makefolder(SAVE_DIR) end
    end)
end

local function SafeSerialize(t)
    local out = {}
    for k,v in pairs(t) do
        if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then out[k]=v
        elseif type(v)=="table" then out[k]=SafeSerialize(v) end
    end
    return out
end

local function SerializeCfg()
    local t={
        ESP=SafeSerialize(Cfg.ESP), Xray=SafeSerialize(Cfg.Xray),
        Aim=SafeSerialize(Cfg.Aim), TriggerBot=SafeSerialize(Cfg.TriggerBot),
        Misc=SafeSerialize(Cfg.Misc), Settings=SafeSerialize(Cfg.Settings),
    }
    t.Aim.AimKeyName=Cfg.Aim.AimKeyName
    for k,v in pairs(Cfg.Settings) do if type(v)=="string" then t.Settings[k]=v end end
    return HttpService:JSONEncode(t)
end

local function ApplySavedCfg(t)
    if not t then return end
    local function merge(dst,src)
        if not src then return end
        for k,v in pairs(src) do
            if type(v)=="table" then if type(dst[k])=="table" then merge(dst[k],v) end
            elseif dst[k]~=nil then dst[k]=v end
        end
    end
    merge(Cfg.ESP,t.ESP); merge(Cfg.Xray,t.Xray); merge(Cfg.Aim,t.Aim)
    merge(Cfg.TriggerBot,t.TriggerBot); merge(Cfg.Misc,t.Misc); merge(Cfg.Settings,t.Settings)
    local function TryKey(n) return (n and Enum.KeyCode[n]) or Enum.KeyCode.Unknown end
    Cfg.Aim.AimKey=TryKey(Cfg.Aim.AimKeyName)
    Cfg.Settings.ToggleKey=TryKey(Cfg.Settings.ToggleKeyName)
    Cfg.Settings.ESPKey=TryKey(Cfg.Settings.ESPKeyName)
    Cfg.Settings.AimbotToggleKey=TryKey(Cfg.Settings.AimbotToggleKeyName)
    Cfg.Settings.SilentKey=TryKey(Cfg.Settings.SilentKeyName)
    Cfg.Settings.FlyKey=TryKey(Cfg.Settings.FlyKeyName)
    Cfg.Settings.NoclipKey=TryKey(Cfg.Settings.NoclipKeyName)
    Cfg.Settings.SpeedKey=TryKey(Cfg.Settings.SpeedKeyName)
    Cfg.Settings.XrayKey=TryKey(Cfg.Settings.XrayKeyName)
    Cfg.Settings.FreeCamKey=TryKey(Cfg.Settings.FreeCamKeyName)
end

local function SaveConfig(name)
    if not writefile then return false, "writefile não suportado" end
    EnsureDir()
    local fname = SAVE_DIR..name:gsub("[^%w_%-]","_")..".json"
    local ok,err = pcall(function() writefile(fname, SerializeCfg()) end)
    return ok, ok and fname or tostring(err)
end

local function LoadConfig(name)
    if not readfile then return false, "readfile não suportado" end
    local fname = SAVE_DIR..name:gsub("[^%w_%-]","_")..".json"
    if isfile and not isfile(fname) then return false, "Arquivo não encontrado: "..fname end
    local ok,data = pcall(function() return readfile(fname) end)
    if not ok then return false, "Erro ao ler: "..tostring(data) end
    local ok2,t = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok2 then return false, "JSON inválido" end
    ApplySavedCfg(t)
    return true, fname
end

local function ListConfigs()
    if not listfiles then return {} end
    EnsureDir()
    local files = {}
    local ok,list = pcall(function() return listfiles(SAVE_DIR) end)
    if not ok then return {} end
    for _,f in ipairs(list) do
        local name = f:match("([^/\\]+)%.json$")
        if name then table.insert(files, name) end
    end
    return files
end

local function DeleteConfig(name)
    if not delfile then return false end
    local fname = SAVE_DIR..name:gsub("[^%w_%-]","_")..".json"
    pcall(function() delfile(fname) end)
    return true
end

-- ============================================================
-- UTILITÁRIOS
-- ============================================================

local function W2S(pos)
    local sp,vis=Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X,sp.Y),vis
end

local function GetBounds(char)
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local ts,v1=W2S(hrp.Position+Vector3.new(0,3.3,0))
    local bs,v2=W2S(hrp.Position-Vector3.new(0,2.8,0))
    if not v1 and not v2 then return nil end
    local h=math.abs(bs.Y-ts.Y); local w=h*0.55
    return ts.X-w/2,ts.Y,w,h
end

local function GetDist(char)
    local a=char:FindFirstChild("HumanoidRootPart")
    local b=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not a or not b then return nil end
    return math.floor((a.Position-b.Position).Magnitude)
end

local function GetHP(char)
    local h=char:FindFirstChildOfClass("Humanoid")
    return h and h.Health or 0, h and h.MaxHealth or 100
end

local function IsVisible(char)
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local mine=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not mine then return false end
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
    local ex={}
    local function ap(c) for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then ex[#ex+1]=v end end end
    if LocalPlayer.Character then ap(LocalPlayer.Character) end; ap(char)
    rp.FilterDescendantsInstances=ex
    return Workspace:Raycast(mine.Position,hrp.Position-mine.Position,rp)==nil
end

local function ESPShouldShow(player)
    if next(Cfg.ESP.TrackList)==nil then return true end
    return Cfg.ESP.TrackList[player.Name]==true
end

local function AimIsBlacklisted(player)
    return Cfg.Aim.Blacklist[player.Name]==true
end

local function ClosestInFOV()
    local vc=Camera.ViewportSize; local sc=Vector2.new(vc.X/2,vc.Y/2)
    local best,bestD=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end
        if AimIsBlacklisted(p) then continue end
        local c=p.Character; if not c then continue end
        local part=c:FindFirstChild(Cfg.Aim.AimPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local hum=c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        if Cfg.Aim.WallCheck and not IsVisible(c) then continue end
        local sp,on=W2S(part.Position); if not on then continue end
        local d=(sp-sc).Magnitude
        if d<Cfg.Aim.FOV and d<bestD then bestD=d; best=p end
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

local BONES = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local BONES_R6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Left Arm","Left Leg"},
    {"Torso","Right Arm"},{"Right Arm","Right Leg"},{"Torso","Left Leg"},{"Torso","Right Leg"},
}

-- ============================================================
-- ESP OBJECTS
-- ============================================================

local ESPO={}
local function MakeESP(p)
    if p==LocalPlayer then return end
    local d={}
    local function sq(filled,color,alpha)
        local s=Drawing.new("Square"); s.Filled=filled; s.Color=color or Color3.new(1,1,1)
        s.Transparency=alpha or 1; s.Thickness=1.5; s.Visible=false; return s
    end
    local function tx(sz,col)
        local t=Drawing.new("Text"); t.Size=sz; t.Color=col or Color3.new(1,1,1)
        t.Outline=true; t.OutlineColor=Color3.new(0,0,0); t.Center=true; t.Visible=false; return t
    end
    d.Box=sq(false,Cfg.ESP.BoxColor); d.Fill=sq(true,Cfg.ESP.FillColor,0.35)
    d.Name=tx(13,Cfg.ESP.NameColor); d.Dist=tx(11,Cfg.ESP.DistanceColor)
    d.HPBg=sq(true,Cfg.ESP.HealthBarBgColor); d.HPFill=sq(true,Cfg.ESP.HealthBarColor)
    d.Tracer=Drawing.new("Line"); d.Tracer.Thickness=1; d.Tracer.Color=Cfg.ESP.TracerColor; d.Tracer.Visible=false
    d.HealthText=tx(10,Color3.fromRGB(255,255,255))
    d.XBox=sq(false,Cfg.Xray.BoxColor); d.XFill=sq(true,Cfg.Xray.FillColor,0.25)
    d.XName=tx(13,Cfg.Xray.NameColor); d.XDist=tx(11,Cfg.Xray.DistanceColor)
    d.XHPBg=sq(true,Cfg.Xray.HealthBarBgColor); d.XHPFill=sq(true,Cfg.Xray.HealthBarColor)
    d.XTracer=Drawing.new("Line"); d.XTracer.Thickness=1; d.XTracer.Color=Cfg.Xray.TracerColor; d.XTracer.Visible=false
    d.SkelLines={}
    for i=1,14 do local l=Drawing.new("Line"); l.Thickness=1; l.Color=Cfg.Xray.SkeletonColor; l.Visible=false; d.SkelLines[i]=l end
    ESPO[p]=d
end
local function KillESP(p)
    if ESPO[p] then
        for _,v in pairs(ESPO[p]) do
            if type(v)=="table" then for _,l in pairs(v) do pcall(function() l:Remove() end) end
            else pcall(function() v:Remove() end) end
        end
        ESPO[p]=nil
    end
end
local function HideAll(d)
    for _,v in pairs(d) do
        if type(v)=="table" then for _,l in pairs(v) do if l.Visible~=nil then l.Visible=false end end
        elseif v.Visible~=nil then v.Visible=false end
    end
end

local FOVC=Drawing.new("Circle")
FOVC.Thickness=1.5; FOVC.Color=Color3.fromRGB(200,40,40); FOVC.Filled=false; FOVC.NumSides=80; FOVC.Visible=false; FOVC.Transparency=0.7

-- ============================================================
-- SILENT AIM
-- ============================================================

local SAHooked=false
local function HookSilentAim()
    if SAHooked then return end; SAHooked=true
    local mt=getrawmetatable and getrawmetatable(Mouse); if not mt then return end
    local old=mt.__index
    setreadonly(mt,false)
    mt.__index=function(self,k)
        if Cfg.Aim.SilentAim and math.random(1,100)<=Cfg.Aim.SilentAimChance then
            local t=ClosestInFOV()
            if t and t.Character then
                local pt=t.Character:FindFirstChild(Cfg.Aim.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
                if pt then
                    if k=="Hit" then return CFrame.new(pt.Position) end
                    if k=="Target" then return pt end
                end
            end
        end
        return old(self,k)
    end
    setreadonly(mt,true)
end

local NoRecoilConn=nil
local function EnableNoRecoil()
    if NoRecoilConn then return end
    NoRecoilConn=RunService.RenderStepped:Connect(function()
        if not Cfg.Aim.NoRecoil then return end
        local char=LocalPlayer.Character; if not char then return end
        for _,tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _,v in ipairs(tool:GetDescendants()) do
                    if v.Name:lower():find("recoil") or v.Name:lower():find("kickback") then
                        pcall(function()
                            if v:IsA("Vector3Value") then v.Value=Vector3.zero
                            elseif v:IsA("NumberValue") then v.Value=0 end
                        end)
                    end
                end
            end
        end
    end)
end

local InfiniteAmmoConn=nil
local function EnableInfiniteAmmo()
    if InfiniteAmmoConn then return end
    InfiniteAmmoConn=RunService.Heartbeat:Connect(function()
        if not Cfg.Aim.InfiniteAmmo then return end
        local char=LocalPlayer.Character; if not char then return end
        for _,tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _,v in ipairs(tool:GetDescendants()) do
                    pcall(function()
                        if v.Name:lower():find("ammo") or v.Name:lower():find("clip") or v.Name:lower():find("bullets") then
                            if (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Value<999 then v.Value=999 end
                        end
                    end)
                end
            end
        end
    end)
end

local TBLast=0
RunService.Heartbeat:Connect(function()
    if not Cfg.TriggerBot.Enabled then return end
    if tick()-TBLast<Cfg.TriggerBot.Delay/1000 then return end
    local target=Mouse.Target; if not target then return end
    local char=target:FindFirstAncestorOfClass("Model"); if not char then return end
    local player=Players:GetPlayerFromCharacter(char)
    if not player or player==LocalPlayer then return end
    if AimIsBlacklisted(player) then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then return end
    TBLast=tick()
    local vms=game:GetService("VirtualInputManager")
    if vms then vms:SendMouseButtonEvent(0,0,0,true,game,0); task.wait(0.05); vms:SendMouseButtonEvent(0,0,0,false,game,0) end
end)

-- ============================================================
-- MISC: FLY / NOCLIP / SPEED / JUMP
-- ============================================================

local FlyConn,BodyVel,BodyGyr=nil,nil,nil
local function EnableFly()
    if FlyConn then return end
    local char=LocalPlayer.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.PlatformStand=true
    BodyVel=Instance.new("BodyVelocity"); BodyVel.Velocity=Vector3.zero; BodyVel.MaxForce=Vector3.new(1e5,1e5,1e5); BodyVel.Parent=hrp
    BodyGyr=Instance.new("BodyGyro"); BodyGyr.MaxTorque=Vector3.new(1e5,1e5,1e5); BodyGyr.P=1e4; BodyGyr.Parent=hrp
    FlyConn=RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.Fly then return end
        local cf=Camera.CFrame; local vel=Vector3.zero
        local spd=Cfg.Misc.FlySpeed*(Cfg.Misc.FlyBoost and 3 or 1)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel=vel+Vector3.new(0,spd,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel=vel-Vector3.new(0,spd*0.5,0) end
        BodyVel.Velocity=vel; BodyGyr.CFrame=cf
    end)
end
local function DisableFly()
    if FlyConn then FlyConn:Disconnect(); FlyConn=nil end
    if BodyVel then BodyVel:Destroy(); BodyVel=nil end
    if BodyGyr then BodyGyr:Destroy(); BodyGyr=nil end
    local char=LocalPlayer.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
end

local NoclipConn=nil
local function EnableNoclip()
    if NoclipConn then return end
    NoclipConn=RunService.Stepped:Connect(function()
        if not Cfg.Misc.Noclip then return end
        local char=LocalPlayer.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end)
end
local function DisableNoclip()
    if NoclipConn then NoclipConn:Disconnect(); NoclipConn=nil end
    local char=LocalPlayer.Character; if not char then return end
    for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
end

local function ApplySpeed()
    local char=LocalPlayer.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if not Cfg.Misc.Speed then hum.WalkSpeed=16; return end
    if Cfg.Misc.SpeedMethod=="WalkSpeed" then hum.WalkSpeed=Cfg.Misc.WalkSpeed
    elseif Cfg.Misc.SpeedMethod=="BodyVelocity" then
        hum.WalkSpeed=16
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local bv=hrp:FindFirstChild("_223SpeedBV") or Instance.new("BodyVelocity",hrp)
        bv.Name="_223SpeedBV"; bv.MaxForce=Vector3.new(1e4,0,1e4); bv.Velocity=Vector3.zero
    end
end

local function ApplyJump()
    local char=LocalPlayer.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if not Cfg.Misc.JumpModifier then hum.JumpPower=50; return end
    if Cfg.Misc.JumpMethod=="JumpPower" then hum.JumpPower=Cfg.Misc.JumpPower
    elseif Cfg.Misc.JumpMethod=="UseJumpPower" then hum.UseJumpPower=true; hum.JumpHeight=Cfg.Misc.JumpPower*0.4 end
end

UserInputService.JumpRequest:Connect(function()
    if Cfg.Misc.InfiniteJump then
        local char=LocalPlayer.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function EnableAntiAFK()
    local VIM=game:GetService("VirtualInputManager")
    LocalPlayer.Idled:Connect(function()
        if Cfg.Misc.AntiAFK then
            VIM:SendKeyEvent(true,Enum.KeyCode.ButtonL3,false,game); task.wait(0.5)
            VIM:SendKeyEvent(false,Enum.KeyCode.ButtonL3,false,game)
        end
    end)
end

local HitboxConns={}
local function ApplyHitbox(p)
    if p==LocalPlayer then return end
    local function onChar(char)
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and Cfg.Misc.HitboxExtender then
                v.Size=Vector3.new(Cfg.Misc.HitboxSize,Cfg.Misc.HitboxSize,Cfg.Misc.HitboxSize); v.Transparency=0.85
            end
        end
    end
    if p.Character then onChar(p.Character) end
    HitboxConns[p]=p.CharacterAdded:Connect(onChar)
end
local function RemoveHitbox(p)
    if HitboxConns[p] then HitboxConns[p]:Disconnect(); HitboxConns[p]=nil end
    local char=p.Character; if not char then return end
    for _,v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.Size=Vector3.new(2,2,1); v.Transparency=0 end end
end
local function RefreshHitboxes()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer then if Cfg.Misc.HitboxExtender then ApplyHitbox(p) else RemoveHitbox(p) end end
    end
end

local function DuplicateTool()
    local name=Cfg.Misc.DupeToolName:lower():gsub("%s+",""); if name=="" then return end
    local bp=LocalPlayer:FindFirstChild("Backpack"); local char=LocalPlayer.Character; local tool=nil
    if bp then for _,v in ipairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(name,1,true) then tool=v; break end end end
    if not tool and char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(name,1,true) then tool=v; break end end end
    if tool and bp then tool:Clone().Parent=bp end
end

-- Grab tool from map
local function GrabToolFromMap()
    local char=LocalPlayer.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local closest,closestDist=nil,math.huge
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and not v:IsDescendantOf(Players) then
            local part=v:FindFirstChildOfClass("BasePart")
            if part then
                local dist=(part.Position-hrp.Position).Magnitude
                if dist<closestDist then closestDist=dist; closest=v end
            end
        end
    end
    if closest then
        local bp=LocalPlayer:FindFirstChild("Backpack")
        if bp then closest.Parent=bp; return closest.Name end
    end
    return nil
end

-- Click Teleport
local ClickTeleportConn=nil
local function EnableClickTeleport()
    if ClickTeleportConn then return end
    ClickTeleportConn=Mouse.Button1Down:Connect(function()
        if not Cfg.Misc.ClickTeleport then return end
        local char=LocalPlayer.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hit=Mouse.Hit
        if hit then hrp.CFrame=CFrame.new(hit.Position+Vector3.new(0,3,0)) end
    end)
end
local function DisableClickTeleport()
    if ClickTeleportConn then ClickTeleportConn:Disconnect(); ClickTeleportConn=nil end
end

local BoomboxSound=nil
local function PlayBoombox(id)
    if BoomboxSound then BoomboxSound:Destroy(); BoomboxSound=nil end
    if not id or id=="" then return end
    local sound=Instance.new("Sound")
    sound.SoundId="rbxassetid://"..tostring(id):gsub("%D","")
    sound.Volume=1; sound.Looped=true; sound.Name="_223HUB_Boombox"; sound.Parent=Workspace
    sound:Play(); BoomboxSound=sound
end
local function StopBoombox()
    if BoomboxSound then BoomboxSound:Stop(); BoomboxSound:Destroy(); BoomboxSound=nil end
end

local FreeCamPart=nil; local FreeCamConn=nil
local function EnableFreeCam()
    if FreeCamConn then return end
    FreeCamPart=Instance.new("Part"); FreeCamPart.Anchored=true; FreeCamPart.CanCollide=false
    FreeCamPart.Transparency=1; FreeCamPart.Size=Vector3.new(0.1,0.1,0.1)
    FreeCamPart.CFrame=Camera.CFrame; FreeCamPart.Parent=Workspace
    Camera.CameraSubject=FreeCamPart; Camera.CameraType=Enum.CameraType.Scriptable
    FreeCamConn=RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.FreeCam then return end
        local spd=Cfg.Misc.FreeCamSpeed*0.5; local move=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move=move+Camera.CFrame.LookVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move=move-Camera.CFrame.LookVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move=move-Camera.CFrame.RightVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move=move+Camera.CFrame.RightVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then move=move+Vector3.new(0,spd,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move=move-Vector3.new(0,spd,0) end
        FreeCamPart.CFrame=FreeCamPart.CFrame+move; Camera.CFrame=Camera.CFrame+move
    end)
end
local function DisableFreeCam()
    if FreeCamConn then FreeCamConn:Disconnect(); FreeCamConn=nil end
    if FreeCamPart then FreeCamPart:Destroy(); FreeCamPart=nil end
    Camera.CameraType=Enum.CameraType.Custom
    local char=LocalPlayer.Character
    if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then Camera.CameraSubject=hum end end
end

RunService.Heartbeat:Connect(function()
    if not Cfg.Misc.AntiRagdoll then return end
    local char=LocalPlayer.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if hum:GetState()==Enum.HumanoidStateType.Ragdoll or hum:GetState()==Enum.HumanoidStateType.FallingDown then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then pcall(function() v.Enabled=false end) end
    end
end)

-- ============================================================
-- TROLL FUNCTIONS
-- ============================================================

-- Fling
local function TrollFling(playerName)
    local target=GetPlayerByName(playerName); if not target then return "Player não encontrado" end
    local char=target.Character; if not char then return "Sem personagem" end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return "Sem HRP" end
    local myChar=LocalPlayer.Character; if not myChar then return end
    local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local bv=Instance.new("BodyVelocity",hrp)
    bv.Velocity=Vector3.new(math.random(-200,200),300,math.random(-200,200))
    bv.MaxForce=Vector3.new(1e6,1e6,1e6)
    game:GetService("Debris"):AddItem(bv,0.2)
    return "Flung: "..target.Name
end

-- Freeze
local FrozenPlayers={}
local function TrollFreeze(playerName)
    local target=GetPlayerByName(playerName); if not target then return "Player não encontrado" end
    local char=target.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if FrozenPlayers[target] then
        hum.WalkSpeed=16; hum.JumpPower=50; FrozenPlayers[target]=nil
        return "Unfrozen: "..target.Name
    else
        hum.WalkSpeed=0; hum.JumpPower=0; FrozenPlayers[target]=true
        return "Frozen: "..target.Name
    end
end

-- Sit
local SitConn=nil
local function TrollSit(playerName)
    local target=GetPlayerByName(playerName); if not target then return "Player não encontrado" end
    if SitConn then SitConn:Disconnect(); SitConn=nil; return "Unsit ativado" end
    SitConn=RunService.Heartbeat:Connect(function()
        local char=target.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        hum.Sit=not hum.Sit
        task.wait(0.3)
    end)
    return "Sit loop: "..target.Name
end

-- Spin
local SpinConn=nil; local SpinBG=nil
local function TrollSpin(on)
    local char=LocalPlayer.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if SpinConn then SpinConn:Disconnect(); SpinConn=nil end
    if SpinBG then SpinBG:Destroy(); SpinBG=nil end
    if not on then return end
    SpinBG=Instance.new("BodyAngularVelocity",hrp)
    SpinBG.AngularVelocity=Vector3.new(0,Cfg.Troll.SpinSpeed*10,0)
    SpinBG.MaxTorque=Vector3.new(0,1e6,0)
    SpinBG.P=1e5
end

-- Invisible
local function TrollInvisible(on)
    local char=LocalPlayer.Character; if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            p.Transparency=on and 1 or 0
        end
    end
end

-- Scale: Giant / Tiny / Reset
local function TrollScale(scaleVal)
    local char=LocalPlayer.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local desc=hum:FindFirstChildOfClass("HumanoidDescription") or Instance.new("HumanoidDescription")
    desc.BodyTypeScale=1; desc.HeadScale=1; desc.HeightScale=scaleVal; desc.ProportionScale=scaleVal; desc.WidthScale=scaleVal; desc.DepthScale=scaleVal
    hum:ApplyDescription(desc)
end

-- Teleport player to me
local function TrollTeleportToMe(playerName)
    local target=GetPlayerByName(playerName); if not target then return "Player não encontrado" end
    local myChar=LocalPlayer.Character; if not myChar then return end
    local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local tChar=target.Character; if not tChar then return "Sem personagem" end
    local tHRP=tChar:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
    tHRP.CFrame=myHRP.CFrame+Vector3.new(2,0,0)
    return "Teleportado: "..target.Name
end

-- Fake Admin tag in chat
local function TrollFakeAdmin(msg)
    local tag=Cfg.Troll.FakeTag
    local fullMsg=tag.." "..msg
    pcall(function() game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(fullMsg,"All") end)
    pcall(function() Chat:Chat(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head"),fullMsg,Enum.ChatColor.Red) end)
end

-- Chat Spam
local ChatSpamConn=nil
local function StartChatSpam()
    if ChatSpamConn then return end
    ChatSpamConn=task.spawn(function()
        while Cfg.Troll.ChatSpam do
            pcall(function()
                game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(Cfg.Troll.ChatSpamMsg,"All")
            end)
            task.wait(math.max(0.5,Cfg.Troll.ChatSpamDelay))
        end
        ChatSpamConn=nil
    end)
end
local function StopChatSpam() Cfg.Troll.ChatSpam=false end

-- Rainbow
local RainbowConn=nil
local function EnableRainbow(on)
    if RainbowConn then task.cancel(RainbowConn); RainbowConn=nil end
    if not on then
        local char=LocalPlayer.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.BrickColor=BrickColor.new("Bright red") end) end end
        return
    end
    local hue=0
    RainbowConn=task.spawn(function()
        while Cfg.Troll.Rainbow do
            hue=(hue+Cfg.Troll.RainbowSpeed)%1
            local color=Color3.fromHSV(hue,1,1)
            local char=LocalPlayer.Character; if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then pcall(function() p.Color=color end) end
                end
            end
            task.wait(0.05)
        end
    end)
end

-- Sound Spam
local SoundSpamSound=nil
local function StartSoundSpam(id)
    if SoundSpamSound then SoundSpamSound:Destroy(); SoundSpamSound=nil end
    if not id or id=="" then return end
    local s=Instance.new("Sound"); s.SoundId="rbxassetid://"..id:gsub("%D","")
    s.Volume=5; s.Looped=true; s.Name="_223Troll_Sound"; s.Parent=Workspace; s:Play()
    SoundSpamSound=s
end
local function StopSoundSpam()
    if SoundSpamSound then SoundSpamSound:Stop(); SoundSpamSound:Destroy(); SoundSpamSound=nil end
end

-- Loop Kill
local LoopKillConn=nil
local function StartLoopKill(playerName)
    if LoopKillConn then LoopKillConn:Disconnect(); LoopKillConn=nil end
    if not playerName or playerName=="" then return end
    LoopKillConn=Players.PlayerAdded:Connect(function() end) -- placeholder anchor
    local function tryKill()
        local target=GetPlayerByName(playerName); if not target then return end
        local char=target.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        hum.Health=0
    end
    task.spawn(function()
        while Cfg.Troll.LoopKill do
            tryKill(); task.wait(1)
        end
    end)
end

-- Remove Limbs (visual)
local RemovedLimbs={}
local function TrollRemoveLimbs(playerName)
    local target=GetPlayerByName(playerName); if not target then return "Player não encontrado" end
    local char=target.Character; if not char then return end
    if RemovedLimbs[target] then
        for _,p in ipairs(RemovedLimbs[target]) do pcall(function() p.Transparency=0 end) end
        RemovedLimbs[target]=nil; return "Limbs restaurados: "..target.Name
    end
    local limbs={"Left Arm","Right Arm","Left Leg","Right Leg","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg"}
    RemovedLimbs[target]={}
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            for _,limb in ipairs(limbs) do
                if v.Name==limb then v.Transparency=1; table.insert(RemovedLimbs[target],v) end
            end
        end
    end
    return "Limbs removidos: "..target.Name
end

-- Unanchor parts near player
local function TrollUnanchorMap(playerName)
    local target=GetPlayerByName(playerName)
    local pos
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        pos=target.Character.HumanoidRootPart.Position
    else
        local myChar=LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then pos=myChar.HumanoidRootPart.Position end
    end
    if not pos then return "Sem posição" end
    local count=0
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not Players:GetPlayerFromCharacter(v.Parent) and v.Anchored then
            if (v.Position-pos).Magnitude<60 then
                v.Anchored=false; count=count+1
            end
        end
    end
    return "Desancorando "..count.." partes"
end

-- ============================================================
-- MAIN LOOP (ESP + Xray + Aimbot)
-- ============================================================

RunService.RenderStepped:Connect(function()
    local vs=Camera.ViewportSize
    FOVC.Position=Vector2.new(vs.X/2,vs.Y/2); FOVC.Radius=Cfg.Aim.FOV
    FOVC.Visible=Cfg.Aim.ShowFOV and (Cfg.Aim.UseFOV or Cfg.Aim.Aimbot or Cfg.Aim.SilentAim)

    if Cfg.Aim.Aimbot and UserInputService:IsKeyDown(Cfg.Aim.AimKey) then
        local t=ClosestInFOV()
        if t and t.Character then
            local pt=t.Character:FindFirstChild(Cfg.Aim.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
            if pt then
                local pos=pt.Position
                if Cfg.Aim.Prediction then
                    local hrp=t.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then pos=pos+hrp.AssemblyLinearVelocity*(Cfg.Aim.PredStrength*0.05) end
                end
                Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,pos),math.clamp(Cfg.Aim.Smoothness/100*0.3,0.01,1))
            end
        end
    end

    for player,d in pairs(ESPO) do
        if not player or not player.Parent then KillESP(player); continue end
        local c=player.Character; if not c then HideAll(d); continue end
        local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then HideAll(d); continue end
        local dist=GetDist(c)

        local espOk=Cfg.ESP.Enabled and ESPShouldShow(player) and dist and dist<=Cfg.ESP.MaxDistance
        if espOk and (not Cfg.ESP.WallCheck or IsVisible(c)) then
            local x,y,w,h=GetBounds(c)
            if x then
                if Cfg.ESP.BoxESP then d.Box.Position=Vector2.new(x,y);d.Box.Size=Vector2.new(w,h);d.Box.Color=Cfg.ESP.BoxColor;d.Box.Visible=true else d.Box.Visible=false end
                if Cfg.ESP.FillBox then d.Fill.Position=Vector2.new(x,y);d.Fill.Size=Vector2.new(w,h);d.Fill.Color=Cfg.ESP.FillColor;d.Fill.Visible=true else d.Fill.Visible=false end
                if Cfg.ESP.NameESP then d.Name.Position=Vector2.new(x+w/2,y-14);d.Name.Text=player.DisplayName;d.Name.Color=Cfg.ESP.NameColor;d.Name.Visible=true else d.Name.Visible=false end
                if Cfg.ESP.Distance then d.Dist.Position=Vector2.new(x+w/2,y+h+2);d.Dist.Text=dist.."m";d.Dist.Color=Cfg.ESP.DistanceColor;d.Dist.Visible=true else d.Dist.Visible=false end
                if Cfg.ESP.HealthBar then
                    local hp,mhp=GetHP(c); local r=math.clamp(hp/mhp,0,1)
                    d.HPBg.Position=Vector2.new(x-7,y);d.HPBg.Size=Vector2.new(4,h);d.HPBg.Color=Cfg.ESP.HealthBarBgColor;d.HPBg.Visible=true
                    d.HPFill.Color=Color3.new(math.clamp(2*(1-r),0,1),math.clamp(2*r,0,1),0.05)
                    d.HPFill.Position=Vector2.new(x-7,y+h-h*r);d.HPFill.Size=Vector2.new(4,h*r);d.HPFill.Visible=true
                    d.HealthText.Position=Vector2.new(x-9,y+h/2-5);d.HealthText.Text=math.floor(hp);d.HealthText.Visible=true
                else d.HPBg.Visible=false;d.HPFill.Visible=false;d.HealthText.Visible=false end
                if Cfg.ESP.Tracers then d.Tracer.From=Vector2.new(vs.X/2,vs.Y);d.Tracer.To=Vector2.new(x+w/2,y+h);d.Tracer.Color=Cfg.ESP.TracerColor;d.Tracer.Visible=true else d.Tracer.Visible=false end
            else d.Box.Visible=false;d.Fill.Visible=false;d.Name.Visible=false;d.Dist.Visible=false;d.HPBg.Visible=false;d.HPFill.Visible=false;d.Tracer.Visible=false;d.HealthText.Visible=false end
        else d.Box.Visible=false;d.Fill.Visible=false;d.Name.Visible=false;d.Dist.Visible=false;d.HPBg.Visible=false;d.HPFill.Visible=false;d.Tracer.Visible=false;d.HealthText.Visible=false end

        local xrayOk=Cfg.Xray.Enabled and dist and dist<=Cfg.Xray.MaxDistance
        if xrayOk then
            local x,y,w,h=GetBounds(c)
            if x then
                if Cfg.Xray.BoxESP then d.XBox.Position=Vector2.new(x,y);d.XBox.Size=Vector2.new(w,h);d.XBox.Color=Cfg.Xray.BoxColor;d.XBox.Visible=true else d.XBox.Visible=false end
                if Cfg.Xray.FillBox then d.XFill.Position=Vector2.new(x,y);d.XFill.Size=Vector2.new(w,h);d.XFill.Color=Cfg.Xray.FillColor;d.XFill.Visible=true else d.XFill.Visible=false end
                if Cfg.Xray.NameESP then d.XName.Position=Vector2.new(x+w/2,y-14);d.XName.Text="["..player.DisplayName.."]";d.XName.Color=Cfg.Xray.NameColor;d.XName.Visible=true else d.XName.Visible=false end
                if Cfg.Xray.Distance then d.XDist.Position=Vector2.new(x+w/2,y+h+2);d.XDist.Text=dist.."m";d.XDist.Color=Cfg.Xray.DistanceColor;d.XDist.Visible=true else d.XDist.Visible=false end
                if Cfg.Xray.HealthBar then
                    local hp,mhp=GetHP(c); local r=math.clamp(hp/mhp,0,1)
                    d.XHPBg.Position=Vector2.new(x+w+2,y);d.XHPBg.Size=Vector2.new(4,h);d.XHPBg.Color=Cfg.Xray.HealthBarBgColor;d.XHPBg.Visible=true
                    d.XHPFill.Color=Cfg.Xray.HealthBarColor; d.XHPFill.Position=Vector2.new(x+w+2,y+h-h*r);d.XHPFill.Size=Vector2.new(4,h*r);d.XHPFill.Visible=true
                else d.XHPBg.Visible=false;d.XHPFill.Visible=false end
                if Cfg.Xray.Tracers then d.XTracer.From=Vector2.new(vs.X/2,vs.Y);d.XTracer.To=Vector2.new(x+w/2,y+h);d.XTracer.Color=Cfg.Xray.TracerColor;d.XTracer.Visible=true else d.XTracer.Visible=false end
            else d.XBox.Visible=false;d.XFill.Visible=false;d.XName.Visible=false;d.XDist.Visible=false;d.XHPBg.Visible=false;d.XHPFill.Visible=false;d.XTracer.Visible=false end
            if Cfg.Xray.Skeleton then
                local boneSet=BONES
                if c:FindFirstChild("Torso") then boneSet=BONES_R6 end
                for i,pair in ipairs(boneSet) do
                    local l=d.SkelLines[i]; if not l then continue end
                    local p1=c:FindFirstChild(pair[1]); local p2=c:FindFirstChild(pair[2])
                    if p1 and p2 then
                        local s1,v1=W2S(p1.Position); local s2,v2=W2S(p2.Position)
                        if v1 or v2 then l.From=s1;l.To=s2;l.Color=Cfg.Xray.SkeletonColor;l.Visible=true else l.Visible=false end
                    else l.Visible=false end
                end
                for i=#boneSet+1,14 do if d.SkelLines[i] then d.SkelLines[i].Visible=false end end
            else for _,l in pairs(d.SkelLines) do l.Visible=false end end
        else
            d.XBox.Visible=false;d.XFill.Visible=false;d.XName.Visible=false;d.XDist.Visible=false;d.XHPBg.Visible=false;d.XHPFill.Visible=false;d.XTracer.Visible=false
            for _,l in pairs(d.SkelLines) do l.Visible=false end
        end
    end
end)

for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(MakeESP)
Players.PlayerRemoving:Connect(KillESP)
Players.PlayerAdded:Connect(function(p) if Cfg.Misc.HitboxExtender then ApplyHitbox(p) end end)
Players.PlayerRemoving:Connect(function(p) HitboxConns[p]=nil end)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5); ApplySpeed(); ApplyJump()
    if Cfg.Misc.Fly then EnableFly() end
    if Cfg.Misc.Noclip then EnableNoclip() end
end)
EnableAntiAFK(); EnableNoRecoil(); EnableInfiniteAmmo()
EnableClickTeleport()

-- ============================================================
-- KEYBIND HANDLER
-- ============================================================

local GuiVisible=true
local RefreshCBs={}
local function TR(n) if RefreshCBs[n] then RefreshCBs[n]() end end

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    local kc=input.KeyCode
    if kc==Cfg.Settings.ToggleKey then
        GuiVisible=not GuiVisible; if _G._223HUB_Win then _G._223HUB_Win.Visible=GuiVisible end
    elseif kc==Cfg.Settings.ESPKey then Cfg.ESP.Enabled=not Cfg.ESP.Enabled; TR("ESPEnabled")
    elseif kc==Cfg.Settings.AimbotToggleKey then Cfg.Aim.Aimbot=not Cfg.Aim.Aimbot; TR("Aimbot")
    elseif kc==Cfg.Settings.SilentKey then Cfg.Aim.SilentAim=not Cfg.Aim.SilentAim; if Cfg.Aim.SilentAim then HookSilentAim() end; TR("SilentAim")
    elseif kc==Cfg.Settings.FlyKey then Cfg.Misc.Fly=not Cfg.Misc.Fly; if Cfg.Misc.Fly then EnableFly() else DisableFly() end; TR("Fly")
    elseif kc==Cfg.Settings.NoclipKey then Cfg.Misc.Noclip=not Cfg.Misc.Noclip; if Cfg.Misc.Noclip then EnableNoclip() else DisableNoclip() end; TR("Noclip")
    elseif kc==Cfg.Settings.SpeedKey then Cfg.Misc.Speed=not Cfg.Misc.Speed; ApplySpeed(); TR("Speed")
    elseif kc==Cfg.Settings.XrayKey then Cfg.Xray.Enabled=not Cfg.Xray.Enabled; TR("Xray")
    elseif kc==Cfg.Settings.FreeCamKey then Cfg.Misc.FreeCam=not Cfg.Misc.FreeCam; if Cfg.Misc.FreeCam then EnableFreeCam() else DisableFreeCam() end; TR("FreeCam")
    end
end)

-- ============================================================
-- ██████████████  GUI  ██████████████
-- ============================================================

if CoreGui:FindFirstChild("223TYHUB") then CoreGui:FindFirstChild("223TYHUB"):Destroy() end
local SG=Instance.new("ScreenGui"); SG.Name="223TYHUB"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=CoreGui

local C={
    bg0=Color3.fromRGB(7,7,9), bg1=Color3.fromRGB(12,12,14), bg2=Color3.fromRGB(17,17,20),
    bg3=Color3.fromRGB(25,25,29), bg4=Color3.fromRGB(32,32,38),
    red=Color3.fromRGB(170,20,20), redH=Color3.fromRGB(215,45,45), pink=Color3.fromRGB(205,55,70),
    blue=Color3.fromRGB(30,100,210), blueH=Color3.fromRGB(50,130,240),
    purple=Color3.fromRGB(120,30,200), purpleH=Color3.fromRGB(150,60,230),
    text=Color3.fromRGB(210,210,215), dim=Color3.fromRGB(95,95,105), wht=Color3.fromRGB(255,255,255),
    sep=Color3.fromRGB(28,28,33), green=Color3.fromRGB(55,185,80), orange=Color3.fromRGB(225,135,40),
    gold=Color3.fromRGB(220,180,40), yellow=Color3.fromRGB(230,210,40),
}
local F=Enum.Font.Code; local FB=Enum.Font.GothamBold; local FM=Enum.Font.Gotham

-- ============================================================
-- LOADING SCREEN  (mesmo tamanho do hub: 920×520)
-- ============================================================

local LoadF=Instance.new("Frame",SG)
LoadF.Size=UDim2.new(0,920,0,520)
LoadF.Position=UDim2.new(0.5,-460,0.5,-260)
LoadF.BackgroundColor3=C.bg0; LoadF.BorderSizePixel=0; LoadF.ZIndex=100
Instance.new("UICorner",LoadF).CornerRadius=UDim.new(0,5)
local wSL=Instance.new("UIStroke",LoadF); wSL.Color=C.red; wSL.Thickness=1.2

local topLine=Instance.new("Frame",LoadF); topLine.Size=UDim2.new(1,0,0,2); topLine.BackgroundColor3=C.red; topLine.BorderSizePixel=0
local botLine=Instance.new("Frame",LoadF); botLine.Size=UDim2.new(1,0,0,2); botLine.Position=UDim2.new(0,0,1,-2); botLine.BackgroundColor3=C.red; botLine.BorderSizePixel=0

local logoCont=Instance.new("Frame",LoadF)
logoCont.Size=UDim2.new(0,400,0,170); logoCont.Position=UDim2.new(0.5,-200,0.5,-130); logoCont.BackgroundTransparency=1

local bigIc=Instance.new("TextLabel",logoCont)
bigIc.Text="◈"; bigIc.Size=UDim2.new(1,0,0,52); bigIc.BackgroundTransparency=1
bigIc.TextColor3=C.red; bigIc.Font=FB; bigIc.TextSize=46; bigIc.TextXAlignment=Enum.TextXAlignment.Center

local loadTitle=Instance.new("TextLabel",logoCont)
loadTitle.Text="223HUB"; loadTitle.Size=UDim2.new(1,0,0,42); loadTitle.Position=UDim2.new(0,0,0,50)
loadTitle.BackgroundTransparency=1; loadTitle.TextColor3=C.wht; loadTitle.Font=FB; loadTitle.TextSize=40; loadTitle.TextXAlignment=Enum.TextXAlignment.Center

local loadSub=Instance.new("TextLabel",logoCont)
loadSub.Text="HUB BY REVOLUCIONARI'US GROUP"; loadSub.Size=UDim2.new(1,0,0,20); loadSub.Position=UDim2.new(0,0,0,94)
loadSub.BackgroundTransparency=1; loadSub.TextColor3=C.dim; loadSub.Font=FM; loadSub.TextSize=14; loadSub.TextXAlignment=Enum.TextXAlignment.Center

local loadDev=Instance.new("TextLabel",logoCont)
loadDev.Text="SCRIPT FEITO POR BRUNO223J AND TY  ·  DISCORD: .223j | frty2017"
loadDev.Size=UDim2.new(1,0,0,14); loadDev.Position=UDim2.new(0,0,0,118)
loadDev.BackgroundTransparency=1; loadDev.TextColor3=C.gold; loadDev.Font=FM; loadDev.TextSize=11; loadDev.TextXAlignment=Enum.TextXAlignment.Center

local loadVer=Instance.new("TextLabel",logoCont)
loadVer.Text="v7.0  ·  Public Beta"; loadVer.Size=UDim2.new(1,0,0,12); loadVer.Position=UDim2.new(0,0,0,136)
loadVer.BackgroundTransparency=1; loadVer.TextColor3=C.red; loadVer.Font=F; loadVer.TextSize=10; loadVer.TextXAlignment=Enum.TextXAlignment.Center

local barCont=Instance.new("Frame",LoadF)
barCont.Size=UDim2.new(0,340,0,5); barCont.Position=UDim2.new(0.5,-170,0.5,66); barCont.BackgroundColor3=C.bg4; barCont.BorderSizePixel=0
Instance.new("UICorner",barCont).CornerRadius=UDim.new(1,0)
local barFill=Instance.new("Frame",barCont)
barFill.Size=UDim2.new(0,0,1,0); barFill.BackgroundColor3=C.red; barFill.BorderSizePixel=0
Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)
local barGlow=Instance.new("Frame",barCont)
barGlow.Size=UDim2.new(0,0,3,0); barGlow.Position=UDim2.new(0,0,-1,0); barGlow.BackgroundColor3=C.redH; barGlow.BackgroundTransparency=0.6; barGlow.BorderSizePixel=0
Instance.new("UICorner",barGlow).CornerRadius=UDim.new(1,0)

local loadStat=Instance.new("TextLabel",LoadF)
loadStat.Size=UDim2.new(0,340,0,16); loadStat.Position=UDim2.new(0.5,-170,0.5,78)
loadStat.BackgroundTransparency=1; loadStat.TextColor3=C.dim; loadStat.Font=F; loadStat.TextSize=10
loadStat.TextXAlignment=Enum.TextXAlignment.Center; loadStat.Text="Inicializando..."

local LOAD_TIME=5
local loadSteps={{0.12,"Verificando ambiente..."},{0.28,"Carregando ESP & Xray..."},{0.45,"Inicializando Aimbot..."},{0.60,"Configurando Misc & Troll..."},{0.75,"Aplicando keybinds..."},{0.88,"Carregando saves..."},{0.96,"Finalizando..."},{1.00,"Bem-vindo, "..LocalPlayer.Name.."!"}}

task.spawn(function()
    local st=tick()
    while true do
        local prog=math.min((tick()-st)/LOAD_TIME,1)
        barFill.Size=UDim2.new(prog,0,1,0); barGlow.Size=UDim2.new(prog,0,3,0)
        for i=#loadSteps,1,-1 do if prog>=loadSteps[i][1]-0.01 then loadStat.Text=loadSteps[i][2]; break end end
        if prog>=1 then break end; task.wait(0.04)
    end
end)

task.wait(LOAD_TIME+0.3)
TweenService:Create(LoadF,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency=1}):Play()
for _,desc in ipairs(LoadF:GetDescendants()) do
    if desc:IsA("TextLabel") then TweenService:Create(desc,TweenInfo.new(0.4),{TextTransparency=1}):Play()
    elseif desc:IsA("Frame") then TweenService:Create(desc,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play() end
end
task.wait(0.55); LoadF:Destroy()

-- ============================================================
-- JANELA PRINCIPAL
-- ============================================================

local Win=Instance.new("Frame",SG)
Win.Name="Win"; Win.Size=UDim2.new(0,920,0,520); Win.Position=UDim2.new(0.5,-460,0.5,-260)
Win.BackgroundColor3=C.bg0; Win.BorderSizePixel=0; Win.Active=true; Win.Draggable=true
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,5)
local wStroke=Instance.new("UIStroke",Win); wStroke.Color=C.red; wStroke.Thickness=1.2
_G._223HUB_Win=Win

local TB=Instance.new("Frame",Win)
TB.Size=UDim2.new(1,0,0,38); TB.BackgroundColor3=C.bg1; TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,5)
local tbFx=Instance.new("Frame",TB); tbFx.Size=UDim2.new(1,0,0,5); tbFx.Position=UDim2.new(0,0,1,-5); tbFx.BackgroundColor3=C.bg1; tbFx.BorderSizePixel=0
local accentLine=Instance.new("Frame",Win); accentLine.Size=UDim2.new(1,0,0,1); accentLine.Position=UDim2.new(0,0,0,38); accentLine.BackgroundColor3=C.red; accentLine.BorderSizePixel=0

local LF2=Instance.new("Frame",TB); LF2.Size=UDim2.new(0,200,1,0); LF2.BackgroundTransparency=1
local ic2=Instance.new("TextLabel",LF2); ic2.Text="◈"; ic2.Size=UDim2.new(0,30,1,0); ic2.Position=UDim2.new(0,8,0,0); ic2.BackgroundTransparency=1; ic2.TextColor3=C.red; ic2.Font=FB; ic2.TextSize=20
local ln2=Instance.new("TextLabel",LF2); ln2.Text="223HUB"; ln2.Size=UDim2.new(1,-38,0,22); ln2.Position=UDim2.new(0,36,0,5); ln2.BackgroundTransparency=1; ln2.TextColor3=C.wht; ln2.Font=FB; ln2.TextSize=15; ln2.TextXAlignment=Enum.TextXAlignment.Left
local lb2=Instance.new("TextLabel",LF2); lb2.Text="by BRUNO223J · .223j"; lb2.Size=UDim2.new(1,-38,0,12); lb2.Position=UDim2.new(0,36,0,22); lb2.BackgroundTransparency=1; lb2.TextColor3=C.gold; lb2.Font=FM; lb2.TextSize=10; lb2.TextXAlignment=Enum.TextXAlignment.Left
local lsep2=Instance.new("Frame",TB); lsep2.Size=UDim2.new(0,1,0.55,0); lsep2.Position=UDim2.new(0,198,0.22,0); lsep2.BackgroundColor3=C.sep; lsep2.BorderSizePixel=0

local minBtn=Instance.new("TextButton",TB); minBtn.Text="—"; minBtn.Size=UDim2.new(0,28,0,22); minBtn.Position=UDim2.new(1,-34,0.5,-11)
minBtn.BackgroundColor3=C.bg4; minBtn.TextColor3=C.dim; minBtn.Font=FB; minBtn.TextSize=12; minBtn.BorderSizePixel=0
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,3)
minBtn.MouseButton1Click:Connect(function() GuiVisible=not GuiVisible; Win.Visible=GuiVisible end)

local TabsArea=Instance.new("Frame",TB); TabsArea.Size=UDim2.new(1,-240,1,0); TabsArea.Position=UDim2.new(0,204,0,0); TabsArea.BackgroundTransparency=1
local TLL=Instance.new("UIListLayout",TabsArea); TLL.FillDirection=Enum.FillDirection.Horizontal; TLL.VerticalAlignment=Enum.VerticalAlignment.Center; TLL.Padding=UDim.new(0,1)

local ContentF=Instance.new("Frame",Win); ContentF.Size=UDim2.new(1,-16,1,-52); ContentF.Position=UDim2.new(0,8,0,48); ContentF.BackgroundTransparency=1; ContentF.BorderSizePixel=0

-- ============================================================
-- COMPONENT FUNCTIONS
-- ============================================================

local function Panel(parent,title,xOff,yOff,w,h,accentColor)
    local f=Instance.new("Frame",parent); f.Position=UDim2.new(0,xOff,0,yOff); f.Size=UDim2.new(0,w,0,h); f.BackgroundColor3=C.bg2; f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",f).Color=C.sep
    local ph=Instance.new("Frame",f); ph.Size=UDim2.new(1,0,0,28); ph.BackgroundColor3=C.bg1; ph.BorderSizePixel=0
    Instance.new("UICorner",ph).CornerRadius=UDim.new(0,4)
    local phx=Instance.new("Frame",ph); phx.Size=UDim2.new(1,0,0,4); phx.Position=UDim2.new(0,0,1,-4); phx.BackgroundColor3=C.bg1; phx.BorderSizePixel=0
    local pAccent=Instance.new("Frame",ph); pAccent.Size=UDim2.new(0,3,0.6,0); pAccent.Position=UDim2.new(0,6,0.2,0); pAccent.BackgroundColor3=accentColor or C.red; pAccent.BorderSizePixel=0
    Instance.new("UICorner",pAccent).CornerRadius=UDim.new(1,0)
    local pl=Instance.new("TextLabel",ph); pl.Text=title; pl.Size=UDim2.new(1,-20,1,0); pl.Position=UDim2.new(0,14,0,0); pl.BackgroundTransparency=1; pl.TextColor3=C.text; pl.Font=FB; pl.TextSize=12; pl.TextXAlignment=Enum.TextXAlignment.Left
    local body=Instance.new("ScrollingFrame",f); body.Size=UDim2.new(1,-14,1,-36); body.Position=UDim2.new(0,7,0,32); body.BackgroundTransparency=1; body.BorderSizePixel=0; body.ScrollBarThickness=2; body.ScrollBarImageColor3=accentColor or C.red; body.CanvasSize=UDim2.new(0,0,0,0); body.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",body).Padding=UDim.new(0,3)
    return body
end

local function Row(parent,text,order,getV,setV,rKey,accentCol)
    local ac=accentCol or C.red
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,24); f.BackgroundColor3=C.bg3; f.BorderSizePixel=0; f.LayoutOrder=order
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    local chk=Instance.new("Frame",f); chk.Size=UDim2.new(0,15,0,15); chk.Position=UDim2.new(0,7,0.5,-7.5); chk.BackgroundColor3=C.bg4; chk.BorderSizePixel=0
    Instance.new("UICorner",chk).CornerRadius=UDim.new(0,3)
    local cS=Instance.new("UIStroke",chk); cS.Color=C.sep; cS.Thickness=1
    local ck=Instance.new("TextLabel",chk); ck.Text="✓"; ck.Size=UDim2.new(1,0,1,0); ck.BackgroundTransparency=1; ck.TextColor3=ac; ck.Font=FB; ck.TextSize=12; ck.Visible=getV()
    local lbl=Instance.new("TextLabel",f); lbl.Text=text; lbl.Size=UDim2.new(1,-34,1,0); lbl.Position=UDim2.new(0,28,0,0); lbl.BackgroundTransparency=1; lbl.TextColor3=C.text; lbl.Font=FM; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    local function ref()
        local v=getV(); ck.Visible=v
        chk.BackgroundColor3=v and Color3.fromRGB(30,8,30) or C.bg4; cS.Color=v and ac or C.sep
        f.BackgroundColor3=v and Color3.fromRGB(22,8,22) or C.bg3
    end
    if rKey then RefreshCBs[rKey]=ref end
    btn.MouseButton1Click:Connect(function() setV(not getV()); ref() end)
    btn.MouseEnter:Connect(function() if not getV() then f.BackgroundColor3=C.bg4 end end)
    btn.MouseLeave:Connect(function() if not getV() then f.BackgroundColor3=C.bg3 end end)
    ref()
end

local function RowRed(p,t,o,g,s,k) Row(p,t,o,g,s,k,C.pink) end

local AS2=nil
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then AS2=nil end end)
UserInputService.InputChanged:Connect(function(i)
    if AS2 and i.UserInputType==Enum.UserInputType.MouseMovement then
        local s=AS2; local r=math.clamp((i.Position.X-s.bar.AbsolutePosition.X)/s.bar.AbsoluteSize.X,0,1)
        local v=math.floor(s.mn+r*(s.mx-s.mn)); s.fill.Size=UDim2.new(r,0,1,0); s.vl.Text=v.." / "..s.mx; s.cb(v)
    end
end)

local function Slider(parent,label,mn,mx,def,order,cb)
    local cur=def
    local hdr=Instance.new("Frame",parent); hdr.Size=UDim2.new(1,0,0,18); hdr.BackgroundTransparency=1; hdr.LayoutOrder=order
    local hl=Instance.new("TextLabel",hdr); hl.Text=label; hl.Size=UDim2.new(1,-38,1,0); hl.BackgroundTransparency=1; hl.TextColor3=C.dim; hl.Font=FM; hl.TextSize=11; hl.TextXAlignment=Enum.TextXAlignment.Left
    local bm=Instance.new("TextButton",hdr); bm.Text="-"; bm.Size=UDim2.new(0,16,0,16); bm.Position=UDim2.new(1,-32,0.5,-8); bm.BackgroundTransparency=1; bm.TextColor3=C.dim; bm.Font=FB; bm.TextSize=14; bm.BorderSizePixel=0
    local bp=Instance.new("TextButton",hdr); bp.Text="+"; bp.Size=UDim2.new(0,16,0,16); bp.Position=UDim2.new(1,-14,0.5,-8); bp.BackgroundTransparency=1; bp.TextColor3=C.dim; bp.Font=FB; bp.TextSize=14; bp.BorderSizePixel=0
    local br=Instance.new("Frame",parent); br.Size=UDim2.new(1,0,0,18); br.BackgroundTransparency=1; br.LayoutOrder=order+1
    local bar=Instance.new("Frame",br); bar.Size=UDim2.new(1,0,0,18); bar.BackgroundColor3=C.bg4; bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)
    local r0=math.clamp((def-mn)/(mx-mn),0,1)
    local fill=Instance.new("Frame",bar); fill.Size=UDim2.new(r0,0,1,0); fill.BackgroundColor3=C.pink; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,2)
    local vl=Instance.new("TextLabel",bar); vl.Text=def.." / "..mx; vl.Size=UDim2.new(1,0,1,0); vl.BackgroundTransparency=1; vl.TextColor3=C.text; vl.Font=F; vl.TextSize=10; vl.TextXAlignment=Enum.TextXAlignment.Center
    local sd={bar=bar,fill=fill,vl=vl,mn=mn,mx=mx,cb=function(v) cur=v; cb(v) end}
    local cb2=Instance.new("TextButton",bar); cb2.Size=UDim2.new(1,0,1,0); cb2.BackgroundTransparency=1; cb2.Text=""
    cb2.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then AS2=sd end end)
    bm.MouseButton1Click:Connect(function() cur=math.max(mn,cur-1); fill.Size=UDim2.new((cur-mn)/(mx-mn),0,1,0); vl.Text=cur.." / "..mx; cb(cur) end)
    bp.MouseButton1Click:Connect(function() cur=math.min(mx,cur+1); fill.Size=UDim2.new((cur-mn)/(mx-mn),0,1,0); vl.Text=cur.." / "..mx; cb(cur) end)
end

local function Selector(parent,lbl,options,def,order,cb)
    local idx=1; for i,v in ipairs(options) do if v==def then idx=i end end
    local lf=Instance.new("Frame",parent); lf.Size=UDim2.new(1,0,0,13); lf.BackgroundTransparency=1; lf.LayoutOrder=order
    local ll=Instance.new("TextLabel",lf); ll.Text=lbl; ll.Size=UDim2.new(1,0,1,0); ll.BackgroundTransparency=1; ll.TextColor3=C.dim; ll.Font=FM; ll.TextSize=10; ll.TextXAlignment=Enum.TextXAlignment.Left
    local rf=Instance.new("Frame",parent); rf.Size=UDim2.new(1,0,0,24); rf.BackgroundTransparency=1; rf.LayoutOrder=order+1
    local box=Instance.new("Frame",rf); box.Size=UDim2.new(1,0,1,0); box.BackgroundColor3=C.bg3; box.BorderSizePixel=0
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,3); Instance.new("UIStroke",box).Color=C.sep
    local vl=Instance.new("TextLabel",box); vl.Text=options[idx]; vl.Size=UDim2.new(1,-28,1,0); vl.Position=UDim2.new(0,8,0,0); vl.BackgroundTransparency=1; vl.TextColor3=C.text; vl.Font=FM; vl.TextSize=12; vl.TextXAlignment=Enum.TextXAlignment.Left
    local pl=Instance.new("TextButton",box); pl.Text="▸"; pl.Size=UDim2.new(0,24,1,0); pl.Position=UDim2.new(1,-24,0,0); pl.BackgroundColor3=C.bg4; pl.TextColor3=C.text; pl.Font=FB; pl.TextSize=12; pl.BorderSizePixel=0
    Instance.new("UICorner",pl).CornerRadius=UDim.new(0,3)
    pl.MouseButton1Click:Connect(function() idx=idx%#options+1; vl.Text=options[idx]; cb(options[idx]) end)
end

local function KeyBind(parent,label,order,getN,onSet)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,24); f.BackgroundColor3=C.bg3; f.BorderSizePixel=0; f.LayoutOrder=order
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",f); lbl.Text=label; lbl.Size=UDim2.new(1,-78,1,0); lbl.Position=UDim2.new(0,8,0,0); lbl.BackgroundTransparency=1; lbl.TextColor3=C.text; lbl.Font=FM; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local badge=Instance.new("TextButton",f); badge.Size=UDim2.new(0,68,0,18); badge.Position=UDim2.new(1,-72,0.5,-9)
    badge.BackgroundColor3=C.bg4; badge.TextColor3=C.text; badge.Font=F; badge.TextSize=11; badge.BorderSizePixel=0; badge.Text="["..getN().."]"
    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,3); Instance.new("UIStroke",badge).Color=C.sep
    local listening=false
    badge.MouseButton1Click:Connect(function()
        if listening then return end; listening=true; badge.Text="[ ? ]"; badge.TextColor3=C.pink
        local conn; conn=UserInputService.InputBegan:Connect(function(input,gp)
            if gp then return end
            if input.UserInputType==Enum.UserInputType.Keyboard then
                conn:Disconnect(); listening=false
                local name=input.KeyCode.Name; badge.Text="["..name.."]"; badge.TextColor3=C.text
                onSet(input.KeyCode,name)
            end
        end)
    end)
end

local function ActionBtn(parent,text,order,onClick,bgColor,textColor)
    local btn=Instance.new("TextButton",parent); btn.Text=text; btn.Size=UDim2.new(1,0,0,26)
    local bg=bgColor or Color3.fromRGB(35,8,8)
    btn.BackgroundColor3=bg; btn.TextColor3=textColor or C.redH
    btn.Font=FM; btn.TextSize=12; btn.BorderSizePixel=0; btn.LayoutOrder=order
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,3)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3=Color3.fromRGB(math.min(bg.R*255+18,255),math.min(bg.G*255+8,255),math.min(bg.B*255+8,255)) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3=bg end)
    btn.MouseButton1Click:Connect(onClick); return btn
end

local function SepLine(parent,order)
    local s=Instance.new("Frame",parent); s.Size=UDim2.new(1,0,0,1); s.BackgroundColor3=C.sep; s.BorderSizePixel=0; s.LayoutOrder=order
end

local function SectionLbl(parent,text,order,col)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,15); f.BackgroundTransparency=1; f.LayoutOrder=order
    local l=Instance.new("TextLabel",f); l.Text=text; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=col or C.red; l.Font=FB; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left
end

local function InfoLine(parent,text,order,col)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,15); f.BackgroundTransparency=1; f.LayoutOrder=order
    local l=Instance.new("TextLabel",f); l.Text=text; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=col or C.text; l.Font=FM; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left
end

local function InputField(parent,placeholder,order,onChange)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=order
    local box=Instance.new("TextBox",f); box.PlaceholderText=placeholder; box.Text=""
    box.Size=UDim2.new(1,0,1,0); box.BackgroundColor3=C.bg3; box.TextColor3=C.text; box.PlaceholderColor3=C.dim
    box.Font=FM; box.TextSize=12; box.BorderSizePixel=0; box.ClearTextOnFocus=false
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,3); Instance.new("UIStroke",box).Color=C.sep
    Instance.new("UIPadding",box).PaddingLeft=UDim.new(0,6)
    box.FocusLost:Connect(function() onChange(box.Text) end)
    return box
end

-- Status feedback bar
local function StatusBar(parent,order)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,18); f.BackgroundTransparency=1; f.LayoutOrder=order
    local l=Instance.new("TextLabel",f); l.Text=""; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.green; l.Font=FM; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left
    local function show(msg,col) l.Text=msg; l.TextColor3=col or C.green; task.delay(3,function() if l.Text==msg then l.Text="" end end) end
    return show
end

-- Player list widget
local function PlayerListWidget(parent,startOrder,sectionTitle,dataTable,accentCol)
    local ac=accentCol or C.red
    SepLine(parent,startOrder); SectionLbl(parent,sectionTitle,startOrder+1,ac)
    local addRow=Instance.new("Frame",parent); addRow.Size=UDim2.new(1,0,0,26); addRow.BackgroundTransparency=1; addRow.LayoutOrder=startOrder+2
    local addBox=Instance.new("TextBox",addRow); addBox.PlaceholderText="Username..."; addBox.Text=""
    addBox.Size=UDim2.new(1,-54,1,0); addBox.BackgroundColor3=C.bg3; addBox.TextColor3=C.text; addBox.PlaceholderColor3=C.dim; addBox.Font=FM; addBox.TextSize=12; addBox.BorderSizePixel=0; addBox.ClearTextOnFocus=false
    Instance.new("UICorner",addBox).CornerRadius=UDim.new(0,3); Instance.new("UIStroke",addBox).Color=C.sep; Instance.new("UIPadding",addBox).PaddingLeft=UDim.new(0,6)
    local addBtn=Instance.new("TextButton",addRow); addBtn.Text="+ Add"; addBtn.Size=UDim2.new(0,48,1,0); addBtn.Position=UDim2.new(1,-48,0,0)
    addBtn.BackgroundColor3=ac; addBtn.TextColor3=C.wht; addBtn.Font=FB; addBtn.TextSize=11; addBtn.BorderSizePixel=0
    Instance.new("UICorner",addBtn).CornerRadius=UDim.new(0,3)
    local listH=Instance.new("Frame",parent); listH.Size=UDim2.new(1,0,0,88); listH.BackgroundColor3=C.bg4; listH.BorderSizePixel=0; listH.LayoutOrder=startOrder+3
    Instance.new("UICorner",listH).CornerRadius=UDim.new(0,3)
    local listS=Instance.new("ScrollingFrame",listH); listS.Size=UDim2.new(1,-8,1,-8); listS.Position=UDim2.new(0,4,0,4); listS.BackgroundTransparency=1; listS.BorderSizePixel=0; listS.ScrollBarThickness=2; listS.ScrollBarImageColor3=ac; listS.CanvasSize=UDim2.new(0,0,0,0); listS.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",listS).Padding=UDim.new(0,2)
    local stF=Instance.new("Frame",parent); stF.Size=UDim2.new(1,0,0,13); stF.BackgroundTransparency=1; stF.LayoutOrder=startOrder+4
    local stL=Instance.new("TextLabel",stF); stL.Size=UDim2.new(1,0,1,0); stL.BackgroundTransparency=1; stL.TextColor3=C.dim; stL.Font=FM; stL.TextSize=10; stL.TextXAlignment=Enum.TextXAlignment.Left
    local function UpdateStatus()
        local count=0; for _ in pairs(dataTable) do count=count+1 end
        stL.Text=count==0 and "Vazio — todos incluídos" or count.." na lista"
    end
    local function Rebuild()
        for _,c in ipairs(listS:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        local any=false
        for name in pairs(dataTable) do
            any=true
            local row=Instance.new("Frame",listS); row.Size=UDim2.new(1,0,0,20); row.BackgroundTransparency=1
            local nL=Instance.new("TextLabel",row); nL.Text="· "..name; nL.Size=UDim2.new(1,-28,1,0); nL.BackgroundTransparency=1; nL.TextColor3=C.text; nL.Font=FM; nL.TextSize=11; nL.TextXAlignment=Enum.TextXAlignment.Left
            local rmB=Instance.new("TextButton",row); rmB.Text="✕"; rmB.Size=UDim2.new(0,22,0,16); rmB.Position=UDim2.new(1,-22,0.5,-8)
            rmB.BackgroundColor3=Color3.fromRGB(55,10,10); rmB.TextColor3=C.redH; rmB.Font=FB; rmB.TextSize=11; rmB.BorderSizePixel=0
            Instance.new("UICorner",rmB).CornerRadius=UDim.new(0,2)
            local capName=name; rmB.MouseButton1Click:Connect(function() dataTable[capName]=nil; row:Destroy(); UpdateStatus() end)
        end
        if not any then local el=Instance.new("TextLabel",listS); el.Text="(vazio)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left end
        UpdateStatus()
    end
    addBtn.MouseButton1Click:Connect(function()
        local q=addBox.Text:gsub("%s+",""); if q=="" then return end
        local found=q; for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower()==q:lower() or p.DisplayName:lower()==q:lower() then found=p.Name; break end end
        dataTable[found]=true; addBox.Text=""; Rebuild()
    end)
    Rebuild(); return Rebuild
end

-- ============================================================
-- TAB SYSTEM
-- ============================================================

local Pages={}; local CurTab=nil
local function MakeTab(name,order,col)
    local btn=Instance.new("TextButton",TabsArea); btn.Text=name:upper(); btn.Size=UDim2.new(0,80,0,38); btn.BackgroundTransparency=1; btn.TextColor3=C.dim; btn.Font=FB; btn.TextSize=11; btn.BorderSizePixel=0; btn.LayoutOrder=order
    local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(0.7,0,0,2); ul.Position=UDim2.new(0.15,0,1,-2); ul.BackgroundColor3=col or C.redH; ul.BorderSizePixel=0; ul.Visible=false
    local page=Instance.new("Frame",ContentF); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.Visible=false
    Pages[name]={btn=btn,ul=ul,page=page}
    btn.MouseButton1Click:Connect(function()
        if CurTab then Pages[CurTab].btn.TextColor3=C.dim; Pages[CurTab].ul.Visible=false; Pages[CurTab].page.Visible=false end
        CurTab=name; btn.TextColor3=C.wht; ul.Visible=true; page.Visible=true
    end)
    return page
end

local MainPage    =MakeTab("Main",    1)
local VisuaisPage =MakeTab("Visuals", 2)
local XrayPage    =MakeTab("Xray",    3, C.blueH)
local MiscPage    =MakeTab("Misc",    4)
local TrollPage   =MakeTab("Troll",   5, C.purpleH)
local SettingsPage=MakeTab("Settings",6)
Pages["Main"].btn.TextColor3=C.wht; Pages["Main"].ul.Visible=true; Pages["Main"].page.Visible=true; CurTab="Main"

-- ============================================================
-- PAGE: MAIN
-- ============================================================

local ABd=Panel(MainPage,"Aimbot",       0,  0,435,468)
local FBd=Panel(MainPage,"FOV Settings", 443,0,435,215)
local TBd=Panel(MainPage,"TriggerBot",   443,223,435,175)

RowRed(ABd,"Aimbot",             0,function() return Cfg.Aim.Aimbot end,      function(v) Cfg.Aim.Aimbot=v end,     "Aimbot")
RowRed(ABd,"Wall Check",         1,function() return Cfg.Aim.WallCheck end,   function(v) Cfg.Aim.WallCheck=v end)
RowRed(ABd,"Prediction",         2,function() return Cfg.Aim.Prediction end,  function(v) Cfg.Aim.Prediction=v end)
Slider(ABd,"Prediction Strength",1,10,1,3,function(v) Cfg.Aim.PredStrength=v end)
Selector(ABd,"Target Part",{"Head","HumanoidRootPart","Torso","LeftLowerArm","RightLowerArm"},"Head",6,function(v) Cfg.Aim.AimPart=v end)
Selector(ABd,"Lock Mode",{"First Person","Third Person","Mouse","Always Lock"},"First Person",8,function(v) Cfg.Aim.LockMode=v end)
Slider(ABd,"Smoothness",1,100,20,10,function(v) Cfg.Aim.Smoothness=v end)
SepLine(ABd,12); SectionLbl(ABd,"AUXILIOS DE MIRA",13)
RowRed(ABd,"Silent Aim",14,function() return Cfg.Aim.SilentAim end,function(v) Cfg.Aim.SilentAim=v; if v then HookSilentAim() end end,"SilentAim")
Slider(ABd,"Silent Aim Chance (%)",1,100,100,15,function(v) Cfg.Aim.SilentAimChance=v end)
RowRed(ABd,"No Recoil", 18,function() return Cfg.Aim.NoRecoil    end,function(v) Cfg.Aim.NoRecoil=v end)
RowRed(ABd,"No Spread", 19,function() return Cfg.Aim.NoSpread    end,function(v) Cfg.Aim.NoSpread=v end)
RowRed(ABd,"Infinite Ammo",20,function() return Cfg.Aim.InfiniteAmmo end,function(v) Cfg.Aim.InfiniteAmmo=v end)
KeyBind(ABd,"Aim Key (segurar)",22,function() return Cfg.Aim.AimKeyName end,function(k,n) Cfg.Aim.AimKey=k; Cfg.Aim.AimKeyName=n end)
PlayerListWidget(ABd,24,"LISTA DE EXCLUSÃO (MIRA)",Cfg.Aim.Blacklist)

RowRed(FBd,"Use FOV", 0,function() return Cfg.Aim.UseFOV  end,function(v) Cfg.Aim.UseFOV=v end)
RowRed(FBd,"Show FOV",1,function() return Cfg.Aim.ShowFOV end,function(v) Cfg.Aim.ShowFOV=v end)
Slider(FBd,"FOV Size",10,800,90,2,function(v) Cfg.Aim.FOV=v; FOVC.Radius=v end)
Slider(FBd,"FOV Thickness",1,5,1,5,function(v) FOVC.Thickness=v end)

RowRed(TBd,"TriggerBot",0,function() return Cfg.TriggerBot.Enabled   end,function(v) Cfg.TriggerBot.Enabled=v end)
RowRed(TBd,"Team Check",1,function() return Cfg.TriggerBot.TeamCheck end,function(v) Cfg.TriggerBot.TeamCheck=v end)
Slider(TBd,"Delay (ms)",0,2000,0,2,function(v) Cfg.TriggerBot.Delay=v end)

-- ============================================================
-- PAGE: VISUALS
-- ============================================================

local EBd=Panel(VisuaisPage,"ESP",0,0,435,468); local TPd=Panel(VisuaisPage,"Track Player",443,0,435,468)

do
    local enR=Instance.new("Frame",EBd); enR.Size=UDim2.new(1,0,0,26); enR.BackgroundColor3=Color3.fromRGB(28,8,8); enR.BorderSizePixel=0; enR.LayoutOrder=0
    Instance.new("UICorner",enR).CornerRadius=UDim.new(0,3)
    local ec=Instance.new("Frame",enR); ec.Size=UDim2.new(0,15,0,15); ec.Position=UDim2.new(0,7,0.5,-7.5); ec.BackgroundColor3=C.bg4; ec.BorderSizePixel=0; Instance.new("UICorner",ec).CornerRadius=UDim.new(0,3)
    local eCS=Instance.new("UIStroke",ec); eCS.Color=C.sep; eCS.Thickness=1
    local eTk=Instance.new("TextLabel",ec); eTk.Text="✓"; eTk.Size=UDim2.new(1,0,1,0); eTk.BackgroundTransparency=1; eTk.TextColor3=C.pink; eTk.Font=FB; eTk.TextSize=12; eTk.Visible=Cfg.ESP.Enabled
    local eL=Instance.new("TextLabel",enR); eL.Text="ESP Enabled"; eL.Size=UDim2.new(1,-56,1,0); eL.Position=UDim2.new(0,28,0,0); eL.BackgroundTransparency=1; eL.TextColor3=C.wht; eL.Font=FB; eL.TextSize=13; eL.TextXAlignment=Enum.TextXAlignment.Left
    local eBg=Instance.new("TextLabel",enR); eBg.Text="ESP"; eBg.Size=UDim2.new(0,30,0,16); eBg.Position=UDim2.new(1,-34,0.5,-8); eBg.BackgroundColor3=C.red; eBg.TextColor3=C.wht; eBg.Font=FB; eBg.TextSize=10; eBg.BorderSizePixel=0; Instance.new("UICorner",eBg).CornerRadius=UDim.new(0,3)
    local eBtn=Instance.new("TextButton",enR); eBtn.Size=UDim2.new(1,0,1,0); eBtn.BackgroundTransparency=1; eBtn.Text=""
    local function refESP()
        eTk.Visible=Cfg.ESP.Enabled; ec.BackgroundColor3=Cfg.ESP.Enabled and Color3.fromRGB(40,8,8) or C.bg4; eCS.Color=Cfg.ESP.Enabled and C.red or C.sep
        enR.BackgroundColor3=Cfg.ESP.Enabled and Color3.fromRGB(40,10,10) or Color3.fromRGB(28,8,8)
    end
    RefreshCBs["ESPEnabled"]=refESP
    eBtn.MouseButton1Click:Connect(function() Cfg.ESP.Enabled=not Cfg.ESP.Enabled; refESP() end)
end
RowRed(EBd,"Box ESP",    1,function() return Cfg.ESP.BoxESP   end,function(v) Cfg.ESP.BoxESP=v end)
RowRed(EBd,"Fill Box",   2,function() return Cfg.ESP.FillBox  end,function(v) Cfg.ESP.FillBox=v end)
RowRed(EBd,"Name ESP",   3,function() return Cfg.ESP.NameESP  end,function(v) Cfg.ESP.NameESP=v end)
RowRed(EBd,"Health Bar", 4,function() return Cfg.ESP.HealthBar end,function(v) Cfg.ESP.HealthBar=v end)
RowRed(EBd,"Tracers",    5,function() return Cfg.ESP.Tracers  end,function(v) Cfg.ESP.Tracers=v end)
RowRed(EBd,"Distance",   6,function() return Cfg.ESP.Distance end,function(v) Cfg.ESP.Distance=v end)
RowRed(EBd,"Wall Check", 7,function() return Cfg.ESP.WallCheck end,function(v) Cfg.ESP.WallCheck=v end)
Slider(EBd,"Max Distance",50,2000,500,8,function(v) Cfg.ESP.MaxDistance=v end)

do
    PlayerListWidget(TPd,0,"JOGADORES RASTREADOS",Cfg.ESP.TrackList)
    SepLine(TPd,6)
    local onlH=Instance.new("Frame",TPd); onlH.Size=UDim2.new(1,0,0,15); onlH.BackgroundTransparency=1; onlH.LayoutOrder=7
    local onlL=Instance.new("TextLabel",onlH); onlL.Text="SERVIDOR"; onlL.Size=UDim2.new(1,0,1,0); onlL.BackgroundTransparency=1; onlL.TextColor3=C.red; onlL.Font=FB; onlL.TextSize=10; onlL.TextXAlignment=Enum.TextXAlignment.Left
    local onlS=Instance.new("ScrollingFrame",TPd); onlS.Size=UDim2.new(1,0,0,150); onlS.BackgroundColor3=C.bg4; onlS.BorderSizePixel=0; onlS.LayoutOrder=8
    Instance.new("UICorner",onlS).CornerRadius=UDim.new(0,3); onlS.ScrollBarThickness=2; onlS.ScrollBarImageColor3=C.red; onlS.CanvasSize=UDim2.new(0,0,0,0); onlS.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",onlS).Padding=UDim.new(0,2)
    Instance.new("UIPadding",onlS).PaddingLeft=UDim.new(0,4); local op2=Instance.new("UIPadding",onlS); op2.PaddingTop=UDim.new(0,4)
    local rebuildESP
    local function RefreshOnline()
        for _,c in ipairs(onlS:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LocalPlayer then continue end
            local row=Instance.new("Frame",onlS); row.Size=UDim2.new(1,0,0,24); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,2)
            local pN=Instance.new("TextLabel",row); pN.Text=p.Name; pN.Size=UDim2.new(1,-56,1,0); pN.Position=UDim2.new(0,6,0,0); pN.BackgroundTransparency=1; pN.TextColor3=C.text; pN.Font=FM; pN.TextSize=11; pN.TextXAlignment=Enum.TextXAlignment.Left
            local tBtn=Instance.new("TextButton",row); tBtn.Size=UDim2.new(0,48,0,18); tBtn.Position=UDim2.new(1,-50,0.5,-9)
            tBtn.BackgroundColor3=Cfg.ESP.TrackList[p.Name] and C.red or C.bg4; tBtn.Text=Cfg.ESP.TrackList[p.Name] and "Untrack" or "Track"
            tBtn.TextColor3=C.wht; tBtn.Font=FB; tBtn.TextSize=9; tBtn.BorderSizePixel=0; Instance.new("UICorner",tBtn).CornerRadius=UDim.new(0,2)
            local capP=p
            tBtn.MouseButton1Click:Connect(function()
                if Cfg.ESP.TrackList[capP.Name] then Cfg.ESP.TrackList[capP.Name]=nil; tBtn.BackgroundColor3=C.bg4; tBtn.Text="Track"
                else Cfg.ESP.TrackList[capP.Name]=true; tBtn.BackgroundColor3=C.red; tBtn.Text="Untrack" end
                if rebuildESP then rebuildESP() end
            end)
        end
    end
    ActionBtn(TPd,"↺ Atualizar Online",9,RefreshOnline); RefreshOnline()
end

-- ============================================================
-- PAGE: XRAY
-- ============================================================

local XBd=Panel(XrayPage,"Xray",0,0,435,468,C.blue); local XBd2=Panel(XrayPage,"Skeleton",443,0,435,300,C.blue)
do
    local enR=Instance.new("Frame",XBd); enR.Size=UDim2.new(1,0,0,26); enR.BackgroundColor3=Color3.fromRGB(8,16,35); enR.BorderSizePixel=0; enR.LayoutOrder=0
    Instance.new("UICorner",enR).CornerRadius=UDim.new(0,3)
    local ec=Instance.new("Frame",enR); ec.Size=UDim2.new(0,15,0,15); ec.Position=UDim2.new(0,7,0.5,-7.5); ec.BackgroundColor3=C.bg4; ec.BorderSizePixel=0; Instance.new("UICorner",ec).CornerRadius=UDim.new(0,3)
    local eCS=Instance.new("UIStroke",ec); eCS.Color=C.sep; eCS.Thickness=1
    local eTk=Instance.new("TextLabel",ec); eTk.Text="✓"; eTk.Size=UDim2.new(1,0,1,0); eTk.BackgroundTransparency=1; eTk.TextColor3=C.blueH; eTk.Font=FB; eTk.TextSize=12; eTk.Visible=Cfg.Xray.Enabled
    local eL=Instance.new("TextLabel",enR); eL.Text="Xray Enabled"; eL.Size=UDim2.new(1,-60,1,0); eL.Position=UDim2.new(0,28,0,0); eL.BackgroundTransparency=1; eL.TextColor3=C.blueH; eL.Font=FB; eL.TextSize=13; eL.TextXAlignment=Enum.TextXAlignment.Left
    local eBg=Instance.new("TextLabel",enR); eBg.Text="XRAY"; eBg.Size=UDim2.new(0,38,0,16); eBg.Position=UDim2.new(1,-42,0.5,-8); eBg.BackgroundColor3=C.blue; eBg.TextColor3=C.wht; eBg.Font=FB; eBg.TextSize=9; eBg.BorderSizePixel=0; Instance.new("UICorner",eBg).CornerRadius=UDim.new(0,3)
    local eBtn=Instance.new("TextButton",enR); eBtn.Size=UDim2.new(1,0,1,0); eBtn.BackgroundTransparency=1; eBtn.Text=""
    local function refX() eTk.Visible=Cfg.Xray.Enabled; ec.BackgroundColor3=Cfg.Xray.Enabled and Color3.fromRGB(8,16,50) or C.bg4; eCS.Color=Cfg.Xray.Enabled and C.blue or C.sep end
    RefreshCBs["Xray"]=refX; eBtn.MouseButton1Click:Connect(function() Cfg.Xray.Enabled=not Cfg.Xray.Enabled; refX() end)
end
Row(XBd,"Box ESP",1,function() return Cfg.Xray.BoxESP end,function(v) Cfg.Xray.BoxESP=v end,nil,C.blueH)
Row(XBd,"Fill Box",2,function() return Cfg.Xray.FillBox end,function(v) Cfg.Xray.FillBox=v end,nil,C.blueH)
Row(XBd,"Name ESP",3,function() return Cfg.Xray.NameESP end,function(v) Cfg.Xray.NameESP=v end,nil,C.blueH)
Row(XBd,"Health Bar",4,function() return Cfg.Xray.HealthBar end,function(v) Cfg.Xray.HealthBar=v end,nil,C.blueH)
Row(XBd,"Tracers",5,function() return Cfg.Xray.Tracers end,function(v) Cfg.Xray.Tracers=v end,nil,C.blueH)
Row(XBd,"Distance",6,function() return Cfg.Xray.Distance end,function(v) Cfg.Xray.Distance=v end,nil,C.blueH)
Slider(XBd,"Max Distance",50,5000,1000,7,function(v) Cfg.Xray.MaxDistance=v end)
Row(XBd2,"Skeleton",0,function() return Cfg.Xray.Skeleton end,function(v) Cfg.Xray.Skeleton=v end,nil,C.blueH)

-- ============================================================
-- PAGE: MISC
-- ============================================================

local MovBd=Panel(MiscPage,"Movimento & Física",0,0,435,468); local UtilBd=Panel(MiscPage,"Utilidades",443,0,435,468)

SectionLbl(MovBd,"VOAR",0)
RowRed(MovBd,"Fly",1,function() return Cfg.Misc.Fly end,function(v) Cfg.Misc.Fly=v; if v then EnableFly() else DisableFly() end end,"Fly")
RowRed(MovBd,"Fly Boost (x3)",2,function() return Cfg.Misc.FlyBoost end,function(v) Cfg.Misc.FlyBoost=v end)
Slider(MovBd,"Fly Speed",1,500,50,3,function(v) Cfg.Misc.FlySpeed=v end)
SepLine(MovBd,5); SectionLbl(MovBd,"MOVIMENTO",6)
RowRed(MovBd,"Noclip",7,function() return Cfg.Misc.Noclip end,function(v) Cfg.Misc.Noclip=v; if v then EnableNoclip() else DisableNoclip() end end,"Noclip")
RowRed(MovBd,"Speed Hack",9,function() return Cfg.Misc.Speed end,function(v) Cfg.Misc.Speed=v; ApplySpeed() end,"Speed")
Selector(MovBd,"Speed Method",{"WalkSpeed","BodyVelocity"},"WalkSpeed",10,function(v) Cfg.Misc.SpeedMethod=v; ApplySpeed() end)
Slider(MovBd,"Walk Speed",1,1000,16,12,function(v) Cfg.Misc.WalkSpeed=v; if Cfg.Misc.Speed then ApplySpeed() end end)
SepLine(MovBd,14); SectionLbl(MovBd,"PULO",15)
RowRed(MovBd,"Jump Modifier",16,function() return Cfg.Misc.JumpModifier end,function(v) Cfg.Misc.JumpModifier=v; ApplyJump() end)
RowRed(MovBd,"Infinite Jump",17,function() return Cfg.Misc.InfiniteJump end,function(v) Cfg.Misc.InfiniteJump=v end)
Selector(MovBd,"Jump Method",{"JumpPower","UseJumpPower"},"JumpPower",18,function(v) Cfg.Misc.JumpMethod=v; ApplyJump() end)
Slider(MovBd,"Jump Power",1,1000,50,20,function(v) Cfg.Misc.JumpPower=v; if Cfg.Misc.JumpModifier then ApplyJump() end end)
SepLine(MovBd,22); SectionLbl(MovBd,"OUTROS",23)
RowRed(MovBd,"Anti Ragdoll",24,function() return Cfg.Misc.AntiRagdoll end,function(v) Cfg.Misc.AntiRagdoll=v end)
SepLine(MovBd,25); SectionLbl(MovBd,"TELEPORTE",26)
RowRed(MovBd,"Click Teleport",27,function() return Cfg.Misc.ClickTeleport end,function(v) Cfg.Misc.ClickTeleport=v end)
do
    local ctNote=Instance.new("Frame",MovBd); ctNote.Size=UDim2.new(1,0,0,14); ctNote.BackgroundTransparency=1; ctNote.LayoutOrder=28
    local ctL=Instance.new("TextLabel",ctNote); ctL.Text="Clique no chão para teletransportar"; ctL.Size=UDim2.new(1,0,1,0); ctL.BackgroundTransparency=1; ctL.TextColor3=C.dim; ctL.Font=FM; ctL.TextSize=10; ctL.TextXAlignment=Enum.TextXAlignment.Left
end

-- Utilidades
SectionLbl(UtilBd,"GERAL",0)
RowRed(UtilBd,"Anti-AFK",1,function() return Cfg.Misc.AntiAFK end,function(v) Cfg.Misc.AntiAFK=v end)
RowRed(UtilBd,"Hitbox Extender",3,function() return Cfg.Misc.HitboxExtender end,function(v) Cfg.Misc.HitboxExtender=v; RefreshHitboxes() end)
Slider(UtilBd,"Hitbox Size",1,80,8,4,function(v) Cfg.Misc.HitboxSize=v; if Cfg.Misc.HitboxExtender then RefreshHitboxes() end end)
SepLine(UtilBd,6); SectionLbl(UtilBd,"CÂMERA LIVRE",7)
RowRed(UtilBd,"FreeCam",8,function() return Cfg.Misc.FreeCam end,function(v) Cfg.Misc.FreeCam=v; if v then EnableFreeCam() else DisableFreeCam() end end,"FreeCam")
Slider(UtilBd,"FreeCam Speed",1,20,1,9,function(v) Cfg.Misc.FreeCamSpeed=v end)
SepLine(UtilBd,11); SectionLbl(UtilBd,"GRAB TOOL DO MAPA",12)
do
    local grabStatus=StatusBar(UtilBd,13)
    ActionBtn(UtilBd,"🧲 Pegar Tool Mais Próxima",14,function()
        local name=GrabToolFromMap()
        if name then grabStatus("✓ Pegou: "..name,C.green) else grabStatus("✗ Nenhuma tool encontrada",C.redH) end
    end,Color3.fromRGB(20,50,20))
end
SepLine(UtilBd,16); SectionLbl(UtilBd,"BOOMBOX",17)
do
    local bbBox=InputField(UtilBd,"ID da Música...",18,function(v) Cfg.Misc.BoomboxID=v end)
    local bbSL_F=Instance.new("Frame",UtilBd); bbSL_F.Size=UDim2.new(1,0,0,14); bbSL_F.BackgroundTransparency=1; bbSL_F.LayoutOrder=20
    local bbSL=Instance.new("TextLabel",bbSL_F); bbSL.Text="Parado"; bbSL.Size=UDim2.new(1,0,1,0); bbSL.BackgroundTransparency=1; bbSL.TextColor3=C.dim; bbSL.Font=FM; bbSL.TextSize=10; bbSL.TextXAlignment=Enum.TextXAlignment.Left
    local playRowF=Instance.new("Frame",UtilBd); playRowF.Size=UDim2.new(1,0,0,26); playRowF.BackgroundTransparency=1; playRowF.LayoutOrder=21
    local pLL=Instance.new("UIListLayout",playRowF); pLL.FillDirection=Enum.FillDirection.Horizontal; pLL.Padding=UDim.new(0,4)
    local playBtn=Instance.new("TextButton",playRowF); playBtn.Text="▶ Tocar"; playBtn.Size=UDim2.new(0.5,-2,1,0); playBtn.BackgroundColor3=Color3.fromRGB(15,55,15); playBtn.TextColor3=C.green; playBtn.Font=FB; playBtn.TextSize=12; playBtn.BorderSizePixel=0; Instance.new("UICorner",playBtn).CornerRadius=UDim.new(0,3)
    local stopBtn=Instance.new("TextButton",playRowF); stopBtn.Text="■ Parar"; stopBtn.Size=UDim2.new(0.5,-2,1,0); stopBtn.BackgroundColor3=Color3.fromRGB(55,15,15); stopBtn.TextColor3=C.redH; stopBtn.Font=FB; stopBtn.TextSize=12; stopBtn.BorderSizePixel=0; Instance.new("UICorner",stopBtn).CornerRadius=UDim.new(0,3)
    playBtn.MouseButton1Click:Connect(function()
        local id=Cfg.Misc.BoomboxID~="" and Cfg.Misc.BoomboxID or bbBox.Text
        if id~="" then PlayBoombox(id); bbSL.Text="▶ Tocando: "..id; bbSL.TextColor3=C.green else bbSL.Text="✗ ID inválido"; bbSL.TextColor3=C.redH end
    end)
    stopBtn.MouseButton1Click:Connect(function() StopBoombox(); bbSL.Text="Parado"; bbSL.TextColor3=C.dim end)
end
SepLine(UtilBd,23); SectionLbl(UtilBd,"TOOL DUPLICATOR",24)
do
    InputField(UtilBd,"Nome da Tool...",25,function(v) Cfg.Misc.DupeToolName=v end)
    ActionBtn(UtilBd,"Duplicar Tool",27,function() DuplicateTool() end)
end

-- ============================================================
-- PAGE: TROLL
-- ============================================================

local Tr1=Panel(TrollPage,"Trollagem - Alvo",0,0,435,468,C.purple)
local Tr2=Panel(TrollPage,"Trollagem - Local",443,0,435,468,C.purple)

-- Target input
SectionLbl(Tr1,"JOGADOR ALVO",0,C.purpleH)
local trollTargetBox=InputField(Tr1,"Username do alvo...",1,function(v) Cfg.Troll.TargetPlayer=v end)

local trollStatus=StatusBar(Tr1,3)

SepLine(Tr1,4); SectionLbl(Tr1,"AÇÕES NO ALVO",5,C.purpleH)

ActionBtn(Tr1,"💥 Fling (Lançar)",6,function()
    local r=TrollFling(Cfg.Troll.TargetPlayer); trollStatus(r or "✓ Flung",C.purple)
end,Color3.fromRGB(60,10,60))

ActionBtn(Tr1,"❄️ Freeze / Unfreeze",8,function()
    local r=TrollFreeze(Cfg.Troll.TargetPlayer); trollStatus(r,C.blueH)
end,Color3.fromRGB(15,20,60))

ActionBtn(Tr1,"🪑 Sit Loop / Parar",10,function()
    local r=TrollSit(Cfg.Troll.TargetPlayer); trollStatus(r,C.purpleH)
end,Color3.fromRGB(40,10,60))

ActionBtn(Tr1,"📦 Teletransportar p/ mim",12,function()
    local r=TrollTeleportToMe(Cfg.Troll.TargetPlayer); trollStatus(r,C.green)
end,Color3.fromRGB(15,55,15))

ActionBtn(Tr1,"💀 Loop Kill ON/OFF",14,function()
    Cfg.Troll.LoopKill=not Cfg.Troll.LoopKill
    if Cfg.Troll.LoopKill then
        Cfg.Troll.LoopKillTarget=Cfg.Troll.TargetPlayer
        StartLoopKill(Cfg.Troll.LoopKillTarget); trollStatus("Loop Kill: "..Cfg.Troll.TargetPlayer,C.redH)
    else trollStatus("Loop Kill parado",C.dim) end
end,Color3.fromRGB(55,8,8))

ActionBtn(Tr1,"✂️ Remove Limbs / Restaurar",16,function()
    local r=TrollRemoveLimbs(Cfg.Troll.TargetPlayer); trollStatus(r,C.orange)
end,Color3.fromRGB(50,30,5))

ActionBtn(Tr1,"💣 Unanchor Mapa (raio 60)",18,function()
    local r=TrollUnanchorMap(Cfg.Troll.TargetPlayer); trollStatus(r,C.orange)
end,Color3.fromRGB(50,25,5))

SepLine(Tr1,20); SectionLbl(Tr1,"FAKE ADMIN",21,C.purpleH)
local fakeTagBox=InputField(Tr1,"Tag (ex: [ADMIN])",22,function(v) Cfg.Troll.FakeTag=v end)
local fakeMsgBox=InputField(Tr1,"Mensagem...",24,function() end)
ActionBtn(Tr1,"📢 Enviar Fake Admin Msg",26,function()
    TrollFakeAdmin(fakeMsgBox.Text~="" and fakeMsgBox.Text or "223HUB")
    trollStatus("Mensagem enviada",C.purpleH)
end,Color3.fromRGB(50,10,80))

-- Tr2: Self trolls
SectionLbl(Tr2,"TROLLAGEM PESSOAL",0,C.purpleH)

Row(Tr2,"Spin / Spinbot",1,function() return Cfg.Misc.SpinBot end,function(v)
    Cfg.Misc=Cfg.Misc or {}; Cfg.Misc.SpinBot=v; TrollSpin(v)
end,nil,C.purpleH)
Slider(Tr2,"Spin Speed",1,50,10,2,function(v) Cfg.Troll.SpinSpeed=v; if Cfg.Misc.SpinBot then TrollSpin(true) end end)

Row(Tr2,"Invisible",5,function() return Cfg.Troll.Invisible end,function(v)
    Cfg.Troll.Invisible=v; TrollInvisible(v)
end,nil,C.purpleH)

SepLine(Tr2,7); SectionLbl(Tr2,"TAMANHO",8,C.purpleH)
ActionBtn(Tr2,"🔷 Giant (x"..Cfg.Troll.GiantScale..")",9,function() TrollScale(Cfg.Troll.GiantScale) end,Color3.fromRGB(20,40,80))
ActionBtn(Tr2,"🔸 Tiny (x"..Cfg.Troll.TinyScale..")",11,function() TrollScale(Cfg.Troll.TinyScale) end,Color3.fromRGB(40,20,80))
ActionBtn(Tr2,"↺ Reset Tamanho",13,function() TrollScale(1) end,Color3.fromRGB(30,30,40))
Slider(Tr2,"Giant Scale",2,20,5,15,function(v) Cfg.Troll.GiantScale=v end)
Slider(Tr2,"Tiny Scale",1,10,3,17,function(v) Cfg.Troll.TinyScale=v/10 end)

SepLine(Tr2,19); SectionLbl(Tr2,"RAINBOW & SOM",20,C.purpleH)
Row(Tr2,"Rainbow Armor",21,function() return Cfg.Troll.Rainbow end,function(v)
    Cfg.Troll.Rainbow=v; EnableRainbow(v)
end,nil,C.purpleH)
Slider(Tr2,"Rainbow Speed",1,20,5,22,function(v) Cfg.Troll.RainbowSpeed=v*0.01 end)

SepLine(Tr2,24); SectionLbl(Tr2,"CHAT SPAM",25,C.purpleH)
local chatMsgBox=InputField(Tr2,"Mensagem do spam...",26,function(v) Cfg.Troll.ChatSpamMsg=v end)
Slider(Tr2,"Delay do Spam (s)",1,30,1,28,function(v) Cfg.Troll.ChatSpamDelay=v end)
Row(Tr2,"Chat Spammer",30,function() return Cfg.Troll.ChatSpam end,function(v)
    Cfg.Troll.ChatSpam=v; if v then StartChatSpam() else StopChatSpam() end
end,nil,C.purpleH)

SepLine(Tr2,32); SectionLbl(Tr2,"SOUND SPAM",33,C.purpleH)
local soundIdBox=InputField(Tr2,"ID do som...",34,function(v) Cfg.Troll.SoundSpamID=v end)
local sndStatF=Instance.new("Frame",Tr2); sndStatF.Size=UDim2.new(1,0,0,14); sndStatF.BackgroundTransparency=1; sndStatF.LayoutOrder=36
local sndStatL=Instance.new("TextLabel",sndStatF); sndStatL.Text="Parado"; sndStatL.Size=UDim2.new(1,0,1,0); sndStatL.BackgroundTransparency=1; sndStatL.TextColor3=C.dim; sndStatL.Font=FM; sndStatL.TextSize=10; sndStatL.TextXAlignment=Enum.TextXAlignment.Left
local sndRow=Instance.new("Frame",Tr2); sndRow.Size=UDim2.new(1,0,0,26); sndRow.BackgroundTransparency=1; sndRow.LayoutOrder=37
local sLL=Instance.new("UIListLayout",sndRow); sLL.FillDirection=Enum.FillDirection.Horizontal; sLL.Padding=UDim.new(0,4)
local sPlay=Instance.new("TextButton",sndRow); sPlay.Text="▶ Tocar"; sPlay.Size=UDim2.new(0.5,-2,1,0); sPlay.BackgroundColor3=Color3.fromRGB(40,8,60); sPlay.TextColor3=C.purpleH; sPlay.Font=FB; sPlay.TextSize=12; sPlay.BorderSizePixel=0; Instance.new("UICorner",sPlay).CornerRadius=UDim.new(0,3)
local sStop=Instance.new("TextButton",sndRow); sStop.Text="■ Parar"; sStop.Size=UDim2.new(0.5,-2,1,0); sStop.BackgroundColor3=Color3.fromRGB(55,15,15); sStop.TextColor3=C.redH; sStop.Font=FB; sStop.TextSize=12; sStop.BorderSizePixel=0; Instance.new("UICorner",sStop).CornerRadius=UDim.new(0,3)
sPlay.MouseButton1Click:Connect(function()
    local id=Cfg.Troll.SoundSpamID~="" and Cfg.Troll.SoundSpamID or soundIdBox.Text
    if id~="" then StartSoundSpam(id); sndStatL.Text="▶ "..id; sndStatL.TextColor3=C.purpleH else sndStatL.Text="✗ ID inválido"; sndStatL.TextColor3=C.redH end
end)
sStop.MouseButton1Click:Connect(function() StopSoundSpam(); sndStatL.Text="Parado"; sndStatL.TextColor3=C.dim end)

-- ============================================================
-- PAGE: SETTINGS (com save nomeado)
-- ============================================================

local KBd=Panel(SettingsPage,"Teclas de Atalho",0,0,435,468)
local CfgBd=Panel(SettingsPage,"Configurações & Saves",443,0,435,468)

KeyBind(KBd,"Toggle GUI",         0,function() return Cfg.Settings.ToggleKeyName end,          function(k,n) Cfg.Settings.ToggleKey=k; Cfg.Settings.ToggleKeyName=n end)
KeyBind(KBd,"ESP On/Off",         2,function() return Cfg.Settings.ESPKeyName end,              function(k,n) Cfg.Settings.ESPKey=k; Cfg.Settings.ESPKeyName=n end)
KeyBind(KBd,"Aimbot On/Off",      4,function() return Cfg.Settings.AimbotToggleKeyName end,     function(k,n) Cfg.Settings.AimbotToggleKey=k; Cfg.Settings.AimbotToggleKeyName=n end)
KeyBind(KBd,"Silent Aim On/Off",  6,function() return Cfg.Settings.SilentKeyName end,           function(k,n) Cfg.Settings.SilentKey=k; Cfg.Settings.SilentKeyName=n end)
KeyBind(KBd,"Fly On/Off",         8,function() return Cfg.Settings.FlyKeyName end,              function(k,n) Cfg.Settings.FlyKey=k; Cfg.Settings.FlyKeyName=n end)
KeyBind(KBd,"Noclip On/Off",     10,function() return Cfg.Settings.NoclipKeyName end,           function(k,n) Cfg.Settings.NoclipKey=k; Cfg.Settings.NoclipKeyName=n end)
KeyBind(KBd,"Speed Hack On/Off", 12,function() return Cfg.Settings.SpeedKeyName end,            function(k,n) Cfg.Settings.SpeedKey=k; Cfg.Settings.SpeedKeyName=n end)
KeyBind(KBd,"Xray On/Off",       14,function() return Cfg.Settings.XrayKeyName end,             function(k,n) Cfg.Settings.XrayKey=k; Cfg.Settings.XrayKeyName=n end)
KeyBind(KBd,"FreeCam On/Off",    16,function() return Cfg.Settings.FreeCamKeyName end,          function(k,n) Cfg.Settings.FreeCamKey=k; Cfg.Settings.FreeCamKeyName=n end)
KeyBind(KBd,"Aim Key (segurar)", 18,function() return Cfg.Aim.AimKeyName end,                   function(k,n) Cfg.Aim.AimKey=k; Cfg.Aim.AimKeyName=n end)

-- Save/Load com nome
SectionLbl(CfgBd,"SAVES PERSONALIZADOS",0)
local saveStatus=StatusBar(CfgBd,1)

local saveNameBox=InputField(CfgBd,"Nome do save (ex: pvp_config)...",2,function() end)

local function GetSaveName()
    return saveNameBox and saveNameBox.Text~="" and saveNameBox.Text or "default"
end

ActionBtn(CfgBd,"💾 Salvar Config",4,function()
    local name=GetSaveName()
    local ok,info=SaveConfig(name)
    if ok then saveStatus("✓ Salvo: "..info,C.green) else saveStatus("✗ "..tostring(info),C.redH) end
end,Color3.fromRGB(12,52,12))

ActionBtn(CfgBd,"📂 Carregar Config",6,function()
    local name=GetSaveName()
    local ok,info=LoadConfig(name)
    if ok then saveStatus("✓ Carregado: "..info,C.green) else saveStatus("✗ "..tostring(info),C.redH) end
end,Color3.fromRGB(22,35,8))

ActionBtn(CfgBd,"🗑 Deletar Config",8,function()
    local name=GetSaveName()
    local ok=DeleteConfig(name)
    if ok then saveStatus("✓ Deletado: "..name,C.orange) else saveStatus("✗ delfile não suportado",C.redH) end
end,Color3.fromRGB(48,12,4))

SepLine(CfgBd,10); SectionLbl(CfgBd,"SAVES DISPONÍVEIS",11)
local saveListHolder=Instance.new("Frame",CfgBd); saveListHolder.Size=UDim2.new(1,0,0,100); saveListHolder.BackgroundColor3=C.bg4; saveListHolder.BorderSizePixel=0; saveListHolder.LayoutOrder=12
Instance.new("UICorner",saveListHolder).CornerRadius=UDim.new(0,3)
local saveListScroll=Instance.new("ScrollingFrame",saveListHolder); saveListScroll.Size=UDim2.new(1,-8,1,-8); saveListScroll.Position=UDim2.new(0,4,0,4); saveListScroll.BackgroundTransparency=1; saveListScroll.BorderSizePixel=0; saveListScroll.ScrollBarThickness=2; saveListScroll.ScrollBarImageColor3=C.red; saveListScroll.CanvasSize=UDim2.new(0,0,0,0); saveListScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",saveListScroll).Padding=UDim.new(0,2)

local function RefreshSaveList()
    for _,c in ipairs(saveListScroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    local files=ListConfigs()
    if #files==0 then
        local el=Instance.new("TextLabel",saveListScroll); el.Text="(nenhum save encontrado)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left
        return
    end
    for _,name in ipairs(files) do
        local row=Instance.new("Frame",saveListScroll); row.Size=UDim2.new(1,0,0,22); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,2)
        local nL=Instance.new("TextLabel",row); nL.Text="📄 "..name; nL.Size=UDim2.new(1,-52,1,0); nL.Position=UDim2.new(0,6,0,0); nL.BackgroundTransparency=1; nL.TextColor3=C.text; nL.Font=FM; nL.TextSize=11; nL.TextXAlignment=Enum.TextXAlignment.Left
        local loadB=Instance.new("TextButton",row); loadB.Text="Load"; loadB.Size=UDim2.new(0,36,0,16); loadB.Position=UDim2.new(1,-40,0.5,-8); loadB.BackgroundColor3=C.red; loadB.TextColor3=C.wht; loadB.Font=FB; loadB.TextSize=9; loadB.BorderSizePixel=0; Instance.new("UICorner",loadB).CornerRadius=UDim.new(0,2)
        local capName=name
        loadB.MouseButton1Click:Connect(function()
            local ok,info=LoadConfig(capName)
            saveStatus(ok and "✓ "..capName.." carregado" or "✗ "..tostring(info), ok and C.green or C.redH)
        end)
    end
end

ActionBtn(CfgBd,"↺ Atualizar Lista de Saves",13,RefreshSaveList)
RefreshSaveList()

SepLine(CfgBd,15); SectionLbl(CfgBd,"RESET",16)
ActionBtn(CfgBd,"🗑 Resetar para Padrão",17,function()
    for k,v in pairs({BoxESP=false,FillBox=false,NameESP=false,HealthBar=false,Tracers=false,Distance=false,WallCheck=false,Enabled=false}) do Cfg.ESP[k]=v end
    Cfg.ESP.MaxDistance=500; Cfg.ESP.TrackList={}
    Cfg.Xray.Enabled=false; Cfg.Xray.Skeleton=false
    for k,v in pairs({Aimbot=false,SilentAim=false,WallCheck=false,Prediction=false,NoRecoil=false,NoSpread=false,InfiniteAmmo=false,FOV=90,ShowFOV=false,Smoothness=20}) do Cfg.Aim[k]=v end
    Cfg.Aim.AimKey=Enum.KeyCode.E; Cfg.Aim.AimKeyName="E"; Cfg.Aim.Blacklist={}
    Cfg.TriggerBot.Enabled=false; Cfg.TriggerBot.Delay=0
    for k,v in pairs({Fly=false,FlyBoost=false,Noclip=false,Speed=false,AntiAFK=false,HitboxExtender=false,JumpModifier=false,InfiniteJump=false,AntiRagdoll=false,FreeCam=false,ClickTeleport=false}) do Cfg.Misc[k]=v end
    saveStatus("✓ Resetado",C.orange)
end,Color3.fromRGB(48,12,4))

SepLine(CfgBd,19); SectionLbl(CfgBd,"CRÉDITOS",20)
InfoLine(CfgBd,"SCRIPT FEITO POR BRUNO223J AND TY",21,C.gold)
InfoLine(CfgBd,"DISCORD: .223j | frty2017",22,C.gold)
InfoLine(CfgBd,"HUB BY REVOLUCIONARI'US GROUP  —  v7.0",23,C.wht)
InfoLine(CfgBd,"Toggle GUI: [ ; ]  |  Arrastável pela topbar",24,C.dim)
InfoLine(CfgBd,"Saves em: "..SAVE_DIR,25,C.dim)

-- ============================================================
print("[223HUB v7.0] ✓ | SCRIPT FEITO POR BRUNO223J AND TY | DISCORD: .223j | frty2017")
