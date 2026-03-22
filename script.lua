-- ╔══════════════════════════════════════════════════════════╗
-- ║            223HUB  v1.0  🔴 RELEASE                     ║
-- ║      SCRIPT FEITO POR BRUNO223J E TY                     ║
-- ║      DISCORD: .223j  |  frty2017                         ║
-- ╚══════════════════════════════════════════════════════════╝

local _KCoreGui = game:GetService("CoreGui")
local _KTween   = game:GetService("TweenService")
local _KHttp    = game:GetService("HttpService")
local _KLP      = game:GetService("Players").LocalPlayer

local KEY_URL       = "https://raw.githubusercontent.com/bruno223j/223HUB/refs/heads/main/keys"
local KEY_SAVE_FILE = "223HUB_keydata.json"
local WEBHOOK_URL   = "https://discord.com/api/webhooks/1485140777989439548/InADJtmaBRCjfiwwWlLyqXznM6PyXA6TBgW_2iazCMNKZ9bahE7xE20bRJenfh4v0QXf"

local function sendLog(key, playerName)
    local json = _KHttp:JSONEncode({ content = "User: "..(playerName or "?").."\nKey: "..(key or "?") })
    pcall(function()
        http_request({ Url=WEBHOOK_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=json })
    end)
end

local VALID_KEYS_RAW = { "223-P-BRUNO223", "223-P-TY2025" }
local KEY_DURATION   = { D=86400, S=604800, M=2592000, P=math.huge }
local KEY_LABEL      = { D="Diária", S="Semanal", M="Mensal", P="Permanente" }

local function NormalizeKey(k) return (k or ""):gsub("%s+",""):upper() end
local function GetKeyType(k) return k and NormalizeKey(k):match("^223%-([DSMP])%-") or nil end

local function SaveKeyData(key, activatedAt)
    if not writefile then return end
    local ok, raw = pcall(function() return _KHttp:JSONEncode({ key=key, activated_at=activatedAt or os.time() }) end)
    if ok then pcall(writefile, KEY_SAVE_FILE, raw) end
end

local function LoadKeyData()
    if not isfile or not readfile then return nil end
    local ok, ex = pcall(isfile, KEY_SAVE_FILE)
    if not ok or not ex then return nil end
    local ok2, raw = pcall(readfile, KEY_SAVE_FILE)
    if not ok2 or not raw or raw=="" then return nil end
    local ok3, data = pcall(function() return _KHttp:JSONDecode(raw) end)
    return ok3 and data or nil
end

local function ClearKeyData()
    if delfile then pcall(delfile, KEY_SAVE_FILE) end
end

local _cachedRemoteKeys = nil
local function FetchRemoteKeys()
    if _cachedRemoteKeys then return _cachedRemoteKeys end
    _cachedRemoteKeys = {}
    local response = nil
    for _, fn in ipairs({
        function() return game:HttpGet(KEY_URL, true) end,
        function() local r=syn.request({Url=KEY_URL,Method="GET"}); return r and r.Body end,
        function() local r=http_request({Url=KEY_URL,Method="GET"}); return r and r.Body end,
        function() local r=request({Url=KEY_URL,Method="GET"}); return r and r.Body end,
    }) do
        if not response then
            local ok, res = pcall(fn)
            if ok and res and #res > 3 then response = res end
        end
    end
    if response then
        for line in response:gmatch("[^\n\r]+") do
            local t = NormalizeKey(line)
            if t ~= "" then _cachedRemoteKeys[t] = true end
        end
    end
    return _cachedRemoteKeys
end

local function KeyExists(key)
    key = NormalizeKey(key)
    if key == "" then return false end
    for _, k in ipairs(VALID_KEYS_RAW) do
        if NormalizeKey(k) == key then return true end
    end
    return FetchRemoteKeys()[key] == true
end

local function CheckKey(key, savedActivatedAt)
    key = NormalizeKey(key)
    if key=="" then return false,"Digite uma key.",nil,nil end
    local ktype = GetKeyType(key)
    if not ktype then return false,"Formato inválido. Use: 223-D/S/M/P-CODIGO",nil,nil end
    if not KeyExists(key) then return false,"Key não encontrada.",nil,nil end
    if KEY_DURATION[ktype] == math.huge then return true,"Acesso Permanente ✓",ktype,os.time() end
    local activatedAt = savedActivatedAt or os.time()
    local expiresAt   = activatedAt + KEY_DURATION[ktype]
    local now         = os.time()
    if now > expiresAt then return false,"Key "..KEY_LABEL[ktype].." expirada. Adquira uma nova.",ktype,nil end
    local rem = expiresAt - now
    local timeStr
    if rem >= 86400 then
        timeStr = math.floor(rem/86400).."d "..math.floor((rem%86400)/3600).."h restantes"
    elseif rem >= 3600 then
        timeStr = math.floor(rem/3600).."h "..math.floor((rem%3600)/60).."m restantes"
    else
        timeStr = math.floor(rem/60).."m restantes"
    end
    return true, KEY_LABEL[ktype].." · "..timeStr, ktype, activatedAt
end

-- ── GUI DA KEY ─────────────────────────────────────────────
if _KCoreGui:FindFirstChild("223HUB_Key") then _KCoreGui:FindFirstChild("223HUB_Key"):Destroy() end

local KSG = Instance.new("ScreenGui")
KSG.Name="223HUB_Key"; KSG.ResetOnSpawn=false; KSG.IgnoreGuiInset=true
KSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; KSG.Parent=_KCoreGui

local KBG = Instance.new("Frame",KSG)
KBG.Size=UDim2.new(1,0,1,0); KBG.BackgroundColor3=Color3.fromRGB(4,4,6); KBG.BorderSizePixel=0

for i=1,8 do
    local ln=Instance.new("Frame",KBG)
    ln.Size=UDim2.new(1,0,0,1); ln.Position=UDim2.new(0,0,i/9,0)
    ln.BackgroundColor3=Color3.fromRGB(165,20,20); ln.BackgroundTransparency=0.88; ln.BorderSizePixel=0
end

local KC = Instance.new("Frame",KBG)
KC.Size=UDim2.new(0,480,0,400); KC.Position=UDim2.new(0.5,-240,0.5,-200)
KC.BackgroundColor3=Color3.fromRGB(10,10,14); KC.BorderSizePixel=0
Instance.new("UICorner",KC).CornerRadius=UDim.new(0,10)
local KCStroke=Instance.new("UIStroke",KC); KCStroke.Color=Color3.fromRGB(165,20,20); KCStroke.Thickness=1.5

local KTop=Instance.new("Frame",KC); KTop.Size=UDim2.new(1,0,0,50); KTop.BackgroundColor3=Color3.fromRGB(14,4,4); KTop.BorderSizePixel=0
Instance.new("UICorner",KTop).CornerRadius=UDim.new(0,10)
local KTopFix=Instance.new("Frame",KTop); KTopFix.Size=UDim2.new(1,0,0.5,0); KTopFix.Position=UDim2.new(0,0,0.5,0); KTopFix.BackgroundColor3=Color3.fromRGB(14,4,4); KTopFix.BorderSizePixel=0
local KTopDiv=Instance.new("Frame",KC); KTopDiv.Size=UDim2.new(1,0,0,1); KTopDiv.Position=UDim2.new(0,0,0,50); KTopDiv.BackgroundColor3=Color3.fromRGB(165,20,20); KTopDiv.BorderSizePixel=0

local KLogo=Instance.new("TextLabel",KTop); KLogo.Text="◈  223HUB  v1.0"
KLogo.Size=UDim2.new(1,0,1,0); KLogo.BackgroundTransparency=1; KLogo.TextColor3=Color3.fromRGB(255,255,255)
KLogo.Font=Enum.Font.GothamBold; KLogo.TextSize=20; KLogo.TextXAlignment=Enum.TextXAlignment.Center

local function KL(parent,text,sz,col,y,font)
    local l=Instance.new("TextLabel",parent)
    l.Text=text; l.Size=UDim2.new(1,-40,0,sz+6); l.Position=UDim2.new(0,20,0,y)
    l.BackgroundTransparency=1; l.TextColor3=col; l.Font=font or Enum.Font.Gotham
    l.TextSize=sz; l.TextXAlignment=Enum.TextXAlignment.Center; l.TextWrapped=true
    return l
end

KL(KC,"🔐",38,Color3.fromRGB(255,255,255),60,Enum.Font.GothamBold)
KL(KC,"VERIFICAÇÃO DE ACESSO",13,Color3.fromRGB(165,20,20),108,Enum.Font.GothamBold)
KL(KC,"Insira sua key para acessar o 223HUB v1.0 RELEASE",11,Color3.fromRGB(75,75,90),128)

local KBadgeRow=Instance.new("Frame",KC); KBadgeRow.Size=UDim2.new(1,-40,0,26); KBadgeRow.Position=UDim2.new(0,20,0,152); KBadgeRow.BackgroundTransparency=1
local KBL=Instance.new("UIListLayout",KBadgeRow); KBL.FillDirection=Enum.FillDirection.Horizontal; KBL.HorizontalAlignment=Enum.HorizontalAlignment.Center; KBL.Padding=UDim.new(0,6)
for _,b in ipairs({{label="DIÁRIA",col=Color3.fromRGB(200,130,20)},{label="SEMANAL",col=Color3.fromRGB(50,140,210)},{label="MENSAL",col=Color3.fromRGB(115,28,195)},{label="PERMANENTE",col=Color3.fromRGB(30,160,70)}}) do
    local bdg=Instance.new("TextLabel",KBadgeRow); bdg.Text=b.label; bdg.Size=UDim2.new(0,0,1,0); bdg.AutomaticSize=Enum.AutomaticSize.X
    bdg.BackgroundColor3=b.col; bdg.BackgroundTransparency=0.7; bdg.TextColor3=b.col
    bdg.Font=Enum.Font.GothamBold; bdg.TextSize=9; bdg.BorderSizePixel=0
    Instance.new("UICorner",bdg).CornerRadius=UDim.new(0,4)
    local pad=Instance.new("UIPadding",bdg); pad.PaddingLeft=UDim.new(0,6); pad.PaddingRight=UDim.new(0,6)
end

local KInputWrap=Instance.new("Frame",KC); KInputWrap.Size=UDim2.new(1,-40,0,44); KInputWrap.Position=UDim2.new(0,20,0,188); KInputWrap.BackgroundColor3=Color3.fromRGB(16,16,20); KInputWrap.BorderSizePixel=0
Instance.new("UICorner",KInputWrap).CornerRadius=UDim.new(0,6)
local KIS=Instance.new("UIStroke",KInputWrap); KIS.Color=Color3.fromRGB(38,38,48); KIS.Thickness=1

local KInput=Instance.new("TextBox",KInputWrap); KInput.Size=UDim2.new(1,-50,1,0); KInput.Position=UDim2.new(0,10,0,0)
KInput.BackgroundTransparency=1; KInput.PlaceholderText="Ex: 223-P-CODIGO ou 223-D-CODIGO"
KInput.PlaceholderColor3=Color3.fromRGB(50,50,65); KInput.Text=""
KInput.TextColor3=Color3.fromRGB(210,210,215); KInput.Font=Enum.Font.Code; KInput.TextSize=13; KInput.ClearTextOnFocus=false

local KClearBtn=Instance.new("TextButton",KInputWrap); KClearBtn.Size=UDim2.new(0,34,0,32); KClearBtn.Position=UDim2.new(1,-38,0,6)
KClearBtn.BackgroundColor3=Color3.fromRGB(26,26,32); KClearBtn.TextColor3=Color3.fromRGB(90,90,105)
KClearBtn.Font=Enum.Font.GothamBold; KClearBtn.TextSize=12; KClearBtn.Text="✕"; KClearBtn.BorderSizePixel=0
Instance.new("UICorner",KClearBtn).CornerRadius=UDim.new(0,4)
KClearBtn.MouseButton1Click:Connect(function() KInput.Text="" end)

local KStatus=Instance.new("TextLabel",KC); KStatus.Size=UDim2.new(1,-40,0,36); KStatus.Position=UDim2.new(0,20,0,238)
KStatus.BackgroundTransparency=1; KStatus.Text=""; KStatus.TextColor3=Color3.fromRGB(210,45,45)
KStatus.Font=Enum.Font.Gotham; KStatus.TextSize=11; KStatus.TextXAlignment=Enum.TextXAlignment.Center; KStatus.TextWrapped=true

local KBtn=Instance.new("TextButton",KC); KBtn.Size=UDim2.new(1,-40,0,44); KBtn.Position=UDim2.new(0,20,0,280)
KBtn.BackgroundColor3=Color3.fromRGB(165,20,20); KBtn.TextColor3=Color3.fromRGB(255,255,255)
KBtn.Font=Enum.Font.GothamBold; KBtn.TextSize=14; KBtn.Text="VERIFICAR KEY"; KBtn.BorderSizePixel=0
Instance.new("UICorner",KBtn).CornerRadius=UDim.new(0,6)
KBtn.MouseEnter:Connect(function() _KTween:Create(KBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(210,45,45)}):Play() end)
KBtn.MouseLeave:Connect(function() _KTween:Create(KBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(165,20,20)}):Play() end)

local KSavedInfo=Instance.new("TextLabel",KC); KSavedInfo.Size=UDim2.new(1,-40,0,16); KSavedInfo.Position=UDim2.new(0,20,0,330)
KSavedInfo.BackgroundTransparency=1; KSavedInfo.Text=""; KSavedInfo.TextColor3=Color3.fromRGB(30,160,70)
KSavedInfo.Font=Enum.Font.Gotham; KSavedInfo.TextSize=10; KSavedInfo.TextXAlignment=Enum.TextXAlignment.Center

local KFooter=Instance.new("TextLabel",KC); KFooter.Size=UDim2.new(1,-40,0,14); KFooter.Position=UDim2.new(0,20,0,350)
KFooter.BackgroundTransparency=1; KFooter.Text="DISCORD: .223j | frty2017  ·  REVOLUCIONARI'US GROUP  ·  v1.0 RELEASE"
KFooter.TextColor3=Color3.fromRGB(40,40,52); KFooter.Font=Enum.Font.Gotham; KFooter.TextSize=9; KFooter.TextXAlignment=Enum.TextXAlignment.Center

KC.BackgroundTransparency=1; KC.Position=UDim2.new(0.5,-240,0.58,-200)
for _,v in ipairs(KC:GetDescendants()) do
    if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then v.TextTransparency=1 end
end
_KTween:Create(KC,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-240,0.5,-200),BackgroundTransparency=0}):Play()
task.delay(0.2,function()
    for _,v in ipairs(KC:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            _KTween:Create(v,TweenInfo.new(0.3),{TextTransparency=0}):Play()
        end
    end
end)

local function SetStatus(msg,col)
    KStatus.Text=msg; KStatus.TextColor3=col or Color3.fromRGB(210,45,45)
end

local function ShakeCard()
    local moves={{-6,0.04},{6,0.04},{-4,0.04},{4,0.04},{-2,0.04},{0,0.04}}
    local function step(i)
        if i>#moves then return end
        _KTween:Create(KC,TweenInfo.new(moves[i][2]),{Position=UDim2.new(0.5,-240+moves[i][1],0.5,-200)}):Play()
        task.delay(moves[i][2]+0.01,function() step(i+1) end)
    end
    step(1)
end

local function OnKeyApproved()
    -- FASE 1: conteúdo do card some
    for _,v in ipairs(KC:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            _KTween:Create(v,TweenInfo.new(0.12),{TextTransparency=1}):Play()
        end
    end
    -- FASE 2: card COMPACTA para barrinha fina vermelha no centro
    task.delay(0.12,function()
        _KTween:Create(KCStroke,TweenInfo.new(0.18),{Transparency=1}):Play()
        _KTween:Create(KBG,TweenInfo.new(0.22),{BackgroundTransparency=1}):Play()
        _KTween:Create(KC,TweenInfo.new(0.30,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
            Size=UDim2.new(0,480,0,5),
            Position=UDim2.new(0.5,-240,0.5,-2),
            BackgroundColor3=Color3.fromRGB(165,20,20),
        }):Play()
    end)
    -- FASE 3: barrinha EXPANDE para tela inteira escura
    task.delay(0.50,function()
        _KTween:Create(KC,TweenInfo.new(0.38,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Size=UDim2.new(1,0,1,0),
            Position=UDim2.new(0,0,0,0),
            BackgroundColor3=Color3.fromRGB(7,7,10),
        }):Play()
    end)
    -- FASE 4: destrói key GUI e inicia o hub normalmente
    task.delay(0.95,function()
        if KSG and KSG.Parent then KSG:Destroy() end
        task.spawn(_223HUB_MAIN)
    end)
end

local function TryKey(key, savedActivatedAt)
    local normKey = NormalizeKey(key or "")
    if normKey=="" then SetStatus("❌ Digite uma key antes de verificar."); return end
    KBtn.Text="⏳ Verificando..."; KBtn.Active=false
    KIS.Color=Color3.fromRGB(38,38,48)
    SetStatus("Buscando no servidor...", Color3.fromRGB(90,90,105))
    task.spawn(function()
        local ok, msg, ktype, activatedAt = CheckKey(normKey, savedActivatedAt)
        KBtn.Active=true; KBtn.Text="VERIFICAR KEY"
        if ok then
            KCStroke.Color=Color3.fromRGB(30,160,70)
            KBtn.BackgroundColor3=Color3.fromRGB(25,130,55)
            KBtn.Text="✓  ACESSO CONCEDIDO"
            SetStatus("✓ "..msg, Color3.fromRGB(30,160,70))
            SaveKeyData(normKey, activatedAt or os.time())
            KSavedInfo.Text="✓ Key salva — login automático na próxima vez"
            task.spawn(function() sendLog(normKey, _KLP.Name) end)
            task.delay(0.8, OnKeyApproved)
        else
            if msg:find("expirada") then ClearKeyData() end
            KIS.Color=Color3.fromRGB(165,20,20)
            SetStatus("❌ "..msg, Color3.fromRGB(210,45,45))
            ShakeCard()
        end
    end)
end

KBtn.MouseButton1Click:Connect(function() TryKey(KInput.Text, nil) end)
KInput.FocusLost:Connect(function(enter) if enter then TryKey(KInput.Text, nil) end end)

task.delay(0.5, function()
    local _savedData = LoadKeyData()
    if _savedData and _savedData.key and _savedData.key~="" then
        local ktype  = GetKeyType(_savedData.key)
        local klabel = (ktype and KEY_LABEL[ktype]) or "?"
        KInput.Text  = _savedData.key
        KSavedInfo.Text = "🔒 Key "..klabel.." salva encontrada, verificando..."
        SetStatus("Verificando key salva...", Color3.fromRGB(90,90,105))
        task.delay(0.4, function()
            TryKey(_savedData.key, _savedData.activated_at)
        end)
    end
end)

-- ============================================================
-- HUB PRINCIPAL
-- ============================================================
function _223HUB_MAIN()

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

if _G._223HUB_Kill then pcall(_G._223HUB_Kill) end
local _conns = {}
local function AC(c) _conns[#_conns+1]=c; return c end

_G._223HUB_Kill = function()
    for _,c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
    _conns={}
    if _G._223HUB_DrawPool then
        for _,d in pairs(_G._223HUB_DrawPool) do pcall(function() d:Remove() end) end
        _G._223HUB_DrawPool={}
    end
    if CoreGui:FindFirstChild("223TYHUB") then CoreGui:FindFirstChild("223TYHUB"):Destroy() end
end
_G._223HUB_DrawPool = _G._223HUB_DrawPool or {}
local DrawPool = _G._223HUB_DrawPool

local Cfg = {
    ESP = {
        Enabled=false, Box=false, Fill=false, Names=false,
        HP=false, Tracers=false, Dist=false, WallCheck=false,
        TeamCheck=false, HeldTool=false,
        MaxDist=500, TrackList={},
        BoxColor=Color3.fromRGB(220,40,40), FillColor=Color3.fromRGB(220,40,40),
        NameColor=Color3.fromRGB(255,255,255), TracerColor=Color3.fromRGB(220,40,40),
        DistColor=Color3.fromRGB(200,200,200), HPColor=Color3.fromRGB(0,220,80),
        HPBgColor=Color3.fromRGB(60,0,0), ToolColor=Color3.fromRGB(255,210,50),
    },
    Xray = {
        Enabled=false, Box=false, Fill=false, Names=false,
        HP=false, Tracers=false, Dist=false,
        TeamCheck=false, Skeleton=false, MaxDist=1000,
        BoxColor=Color3.fromRGB(0,160,255), FillColor=Color3.fromRGB(0,120,220),
        NameColor=Color3.fromRGB(180,220,255), TracerColor=Color3.fromRGB(0,160,255),
        DistColor=Color3.fromRGB(150,200,255), HPColor=Color3.fromRGB(0,200,255),
        HPBgColor=Color3.fromRGB(0,25,55), SkelColor=Color3.fromRGB(0,200,255),
    },
    Aim = {
        Aimbot=false, WallCheck=false, TeamCheck=false,
        Prediction=false, PredStr=3,
        NoRecoil=false, InfAmmo=false,
        FOV=150, ShowFOV=false, UseFOV=false, FOVFollow=false,
        AimPart="Head", Smoothness=8,
        AimKey=Enum.KeyCode.E, AimKeyName="E",
        AimStrength=70, Blacklist={},
    },
    Trigger = { Enabled=false, TeamCheck=false, Delay=80, AutoBot=false,
                ClickControl=false, ClickCount=3,
                OneShot=false, OneShotDelay=3 },
    Misc = {
        Fly=false, FlySpeed=50, FlyBoost=false, Noclip=false,
        Speed=false, WalkSpeed=25, AntiAFK=false,
        HitboxExtender=false, HitboxSize=8, HitboxPart="All",
        JumpMod=false, JumpPower=80, JumpMethod="JumpPower",
        InfJump=false, AntiRag=false, FreeCam=false, FCamSpeed=1,
        DupeToolName="", ClickTp=false, SpinBot=false,
        CrashLag=false, AutoJump=false, ThirdPerson=false, ThirdPersonDist=8,
        AlwaysSprint=false,
    },
    Modes  = { Aquaman=false, NoFallDmg=false },

    Settings = {
        ToggleKey=Enum.KeyCode.Semicolon, ToggleKeyName=";",
        ESPKey=Enum.KeyCode.F2,      ESPKeyName="F2",
        AimbotKey=Enum.KeyCode.F3,   AimbotKeyName="F3",
        FlyKey=Enum.KeyCode.F5,      FlyKeyName="F5",
        NoclipKey=Enum.KeyCode.F6,   NoclipKeyName="F6",
        SpeedKey=Enum.KeyCode.F7,    SpeedKeyName="F7",
        XrayKey=Enum.KeyCode.F8,     XrayKeyName="F8",
        FreeCamKey=Enum.KeyCode.F9,  FreeCamKeyName="F9",
        BypassKey=Enum.KeyCode.F4,   BypassKeyName="F4",
        BypassEnabled=false,
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
    Cfg.Settings.BypassKey=TK(Cfg.Settings.BypassKeyName)
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
    local ok,data=pcall(readfile,fn); if not ok then return false,"Erro" end
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
-- DRAWING HELPER
-- ============================================================
local function ND(kind, props)
    local ok, d = pcall(Drawing.new, kind)
    if not ok or not d then return nil end
    if props then for k,v in pairs(props) do pcall(function() d[k]=v end) end end
    DrawPool[d]=true
    return d
end
local function SafeSet(d, props)
    if not d then return end
    for k,v in pairs(props) do pcall(function() d[k]=v end) end
end
local function SafeHide(d)
    if d then pcall(function() d.Visible=false end) end
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
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local head   = char:FindFirstChild("Head")
    local topPos = head and (head.Position + Vector3.new(0, head.Size.Y/2 + 0.1, 0))
                        or  (hrp.Position + Vector3.new(0, 3.3, 0))
    local botPos = hrp.Position - Vector3.new(0, 3.0, 0)
    local tZ = (Cam:WorldToViewportPoint(topPos)).Z
    local bZ = (Cam:WorldToViewportPoint(botPos)).Z
    if tZ <= 0 and bZ <= 0 then return nil end
    local topSP = W2S(topPos)
    local botSP = W2S(botPos)
    local h = math.abs(botSP.Y - topSP.Y)
    if h < 3 then return nil end
    local w = h * 0.6
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

-- ============================================================
-- WALLCHECK OTIMIZADO
-- RaycastParams com dirty-flag: só reconstrói se o char/myc mudou.
-- Cache de partes separado para não realocar a lista a cada hit.
-- ============================================================
local _rpCache = {}   -- [player] = { char, myc, rp, parts }

local function _BuildRP(char, myc)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local ex = {}
    for _,v in ipairs(myc:GetDescendants())  do if v:IsA("BasePart") then ex[#ex+1]=v end end
    for _,v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then ex[#ex+1]=v end end
    rp.FilterDescendantsInstances = ex
    return rp
end

local function GetRaycastParams(player, char, myc)
    local cached = _rpCache[player]
    if cached and cached.char == char and cached.myc == myc then
        return cached.rp
    end
    local rp = _BuildRP(char, myc)
    _rpCache[player] = { char=char, myc=myc, rp=rp }
    return rp
end

local function IsVisible(player, char)
    local myc  = LP.Character
    local mine = myc and myc:FindFirstChild("HumanoidRootPart")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not mine or not hrp then return false end
    local rp = GetRaycastParams(player, char, myc)
    local res = Workspace:Raycast(mine.Position, hrp.Position - mine.Position, rp)
    return res == nil
end

-- Cache de visibilidade por frame: dois arrays paralelos evitam alocação de tabela
local _visResultCache  = {}   -- [player] = bool
local _visFrameCache   = {}   -- [player] = frameStamp
local _visFrameStamp   = 0

local function IsVisibleCached(player, char)
    local frame = _visFrameStamp
    if _visFrameCache[player] == frame then
        return _visResultCache[player]
    end
    local result = IsVisible(player, char)
    _visResultCache[player] = result
    _visFrameCache[player]  = frame
    return result
end

local function SameTeam(p)
    if not p or p==LP then return false end
    local mt=LP.Team; local pt=p.Team
    return mt~=nil and pt~=nil and mt==pt
end

local function IsValidTarget(p)
    if p==LP then return false end
    if Cfg.Aim.Blacklist[p.Name] then return false end
    if Cfg.Aim.TeamCheck and SameTeam(p) then return false end
    local c=p.Character; if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid")
    return h~=nil and h.Health>0
end

local function GetHeldTool(char)
    if not char then return nil end
    for _,v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then return v.Name end
    end
    return nil
end

-- ============================================================
-- OTIMIZAÇÃO 2: ClosestTarget — usa cache de visibilidade
-- ============================================================
local function ClosestTarget()
    local vs     = Cam.ViewportSize
    local center = Vector2.new(vs.X/2, vs.Y/2)
    local best, bestD = nil, math.huge

    for _,p in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(p) then continue end
        local c    = p.Character
        local part = c:FindFirstChild(Cfg.Aim.AimPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        if Cfg.Aim.WallCheck and not IsVisibleCached(p, c) then continue end

        local sp, onScreen = W2S(part.Position)
        if not onScreen then continue end
        local d = (sp - center).Magnitude
        if Cfg.Aim.UseFOV and d > Cfg.Aim.FOV then continue end
        if d < bestD then bestD=d; best=p end
    end
    return best
end

-- ============================================================
-- ESP OBJECTS
-- ============================================================
local ESPO = {}

local BONES_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local BONES_R6 = {
    {"Head","Torso"},
    {"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}
local MAX_BONES = 14

local function MakeESP(p)
    if p==LP or ESPO[p] then return end
    local d={}
    d.Box    = ND("Square",{Filled=false, Color=Cfg.ESP.BoxColor,    Transparency=0.7, Thickness=1.5, Visible=false})
    d.Fill   = ND("Square",{Filled=true,  Color=Cfg.ESP.FillColor,   Transparency=0.7, Thickness=0,   Visible=false})
    d.Name   = ND("Text",  {Size=14, Color=Cfg.ESP.NameColor,  Outline=true, OutlineColor=Color3.new(0,0,0), Center=true, Visible=false})
    d.Dist   = ND("Text",  {Size=12, Color=Cfg.ESP.DistColor,  Outline=true, OutlineColor=Color3.new(0,0,0), Center=true, Visible=false})
    d.HPBg   = ND("Square",{Filled=true,  Color=Cfg.ESP.HPBgColor,   Transparency=0.7, Thickness=0,   Visible=false})
    d.HPBar  = ND("Square",{Filled=true,  Color=Color3.fromRGB(0,220,80), Transparency=0.7, Thickness=0, Visible=false})
    d.Tracer = ND("Line",  {Thickness=1.5, Color=Cfg.ESP.TracerColor, Transparency=0.7, Visible=false})
    d.Tool   = ND("Text",  {Size=12, Color=Cfg.ESP.ToolColor,  Outline=true, OutlineColor=Color3.new(0,0,0), Center=true, Visible=false})
    d.XBox   = ND("Square",{Filled=false, Color=Cfg.Xray.BoxColor,   Transparency=0.7, Thickness=1.5, Visible=false})
    d.XFill  = ND("Square",{Filled=true,  Color=Cfg.Xray.FillColor,  Transparency=0.7, Thickness=0,   Visible=false})
    d.XName  = ND("Text",  {Size=14, Color=Cfg.Xray.NameColor, Outline=true, OutlineColor=Color3.new(0,0,0), Center=true, Visible=false})
    d.XDist  = ND("Text",  {Size=12, Color=Cfg.Xray.DistColor, Outline=true, OutlineColor=Color3.new(0,0,0), Center=true, Visible=false})
    d.XHPBg  = ND("Square",{Filled=true,  Color=Cfg.Xray.HPBgColor,  Transparency=0.7, Thickness=0,   Visible=false})
    d.XHPBar = ND("Square",{Filled=true,  Color=Cfg.Xray.HPColor,    Transparency=0.7, Thickness=0,   Visible=false})
    d.XTracer= ND("Line",  {Thickness=1.5, Color=Cfg.Xray.TracerColor,Transparency=0.7, Visible=false})
    d.Skel={}
    for i=1,MAX_BONES do
        d.Skel[i] = ND("Line",{Thickness=1.2, Color=Cfg.Xray.SkelColor, Transparency=0.7, Visible=false})
    end
    ESPO[p] = d
end

local function KillESP(p)
    local d = ESPO[p]
    if not d then return end
    local singles = {"Box","Fill","Name","Dist","HPBg","HPBar","Tracer","Tool",
                     "XBox","XFill","XName","XDist","XHPBg","XHPBar","XTracer"}
    for _,k in ipairs(singles) do
        if d[k] then
            pcall(function() d[k].Visible=false; d[k]:Remove() end)
            DrawPool[d[k]] = nil
        end
    end
    if d.Skel then
        for _,ln in ipairs(d.Skel) do
            pcall(function() ln.Visible=false; ln:Remove() end)
            DrawPool[ln]=nil
        end
    end
    _visResultCache[p] = nil
    _visFrameCache[p]  = nil
    _rpCache[p] = nil
    ESPO[p] = nil
end

local function HideESP(d)
    local singles = {"Box","Fill","Name","Dist","HPBg","HPBar","Tracer","Tool",
                     "XBox","XFill","XName","XDist","XHPBg","XHPBar","XTracer"}
    for _,k in ipairs(singles) do SafeHide(d[k]) end
    if d.Skel then for _,ln in ipairs(d.Skel) do SafeHide(ln) end end
end

-- ============================================================
-- FOV CIRCLE
-- OTIMIZAÇÃO: só recalcula quando FOV, posição ou estado mudam
-- ============================================================
local FOV_SEGS = 48
local _fovLines = {}
for i=1,FOV_SEGS do
    local ln = ND("Line",{Thickness=1.5, Color=Color3.fromRGB(220,50,50), Transparency=0.7, Visible=false})
    _fovLines[i] = ln
end

local _fovLastR   = -1
local _fovLastCX  = -1
local _fovLastCY  = -1
local _fovLastVis = nil

-- OTIMIZAÇÃO: pre-calcula ângulos do FOV uma única vez
local _fovCos = {}
local _fovSin = {}
for i=1,FOV_SEGS do
    _fovCos[i] = { math.cos((i-1)/FOV_SEGS * math.pi*2), math.cos(i/FOV_SEGS * math.pi*2) }
    _fovSin[i] = { math.sin((i-1)/FOV_SEGS * math.pi*2), math.sin(i/FOV_SEGS * math.pi*2) }
end

local function UpdateFOVCircle()
    local show = Cfg.Aim.ShowFOV
    local cx, cy
    if Cfg.Aim.FOVFollow then
        local mpos = UIS:GetMouseLocation()
        cx, cy = mpos.X, mpos.Y
    else
        local vs = Cam.ViewportSize
        cx, cy = vs.X/2, vs.Y/2
    end
    local r = Cfg.Aim.FOV

    if show == _fovLastVis and r == _fovLastR and math.abs(cx-_fovLastCX)<0.5 and math.abs(cy-_fovLastCY)<0.5 then
        return
    end
    _fovLastVis=show; _fovLastR=r; _fovLastCX=cx; _fovLastCY=cy

    for i=1, FOV_SEGS do
        local ln = _fovLines[i]
        if not ln then continue end
        pcall(function()
            ln.From    = Vector2.new(cx + _fovCos[i][1]*r, cy + _fovSin[i][1]*r)
            ln.To      = Vector2.new(cx + _fovCos[i][2]*r, cy + _fovSin[i][2]*r)
            ln.Visible = show
        end)
    end
end

-- ============================================================
-- NO RECOIL — cobertura máxima
-- Abordagem 1: zeragem de valores nomeados (sistemas baseados em instâncias)
-- Abordagem 2: intercepta câmera — reseta rotação X entre frames
--              (funciona em jogos que movem a cam diretamente via CFrame)
-- Abordagem 3: intercepta HRP BodyAngularVelocity/BodyGyro de recoil
-- Abordagem 4: zeragem de atributos de recoil no tool/char
-- ============================================================
local _nrConn     = nil
local _nrCamLastY = nil  -- yaw da câmera antes do tiro (para detectar kick vertical)
local _nrCamLastX = nil  -- pitch salvo

-- Keywords de recoil ampliadas
local NR_KEYS = {
    "recoil","kickback","kick","spread","sway","shake","bump","punch",
    "camshake","camkick","cameraoffset","viewkick","viewpunch",
    "weaponkick","gunbob","muzzlekick","kickforce","recoilforce",
}

local function _IsRecoilValue(v)
    local nm = v.Name:lower()
    for _,k in ipairs(NR_KEYS) do
        if nm:find(k,1,true) then return true end
    end
    return false
end

local function _ZeroRecoilValues(obj)
    if not obj then return end
    for _,v in ipairs(obj:GetDescendants()) do
        if _IsRecoilValue(v) then
            pcall(function()
                if     v:IsA("Vector3Value") then v.Value = Vector3.zero
                elseif v:IsA("CFrameValue")  then v.Value = CFrame.identity
                elseif v:IsA("NumberValue")  then v.Value = 0
                elseif v:IsA("IntValue")     then v.Value = 0
                end
            end)
            -- atributos numéricos
            pcall(function()
                if typeof(v:GetAttribute(v.Name)) == "number" then
                    v:SetAttribute(v.Name, 0)
                end
            end)
        end
        -- atributos de recoil diretamente na instância
        pcall(function()
            for attr, val in pairs(v:GetAttributes()) do
                local an = attr:lower()
                for _,k in ipairs(NR_KEYS) do
                    if an:find(k,1,true) then
                        if type(val)=="number" then v:SetAttribute(attr,0)
                        elseif typeof(val)=="Vector3" then v:SetAttribute(attr,Vector3.zero)
                        elseif typeof(val)=="CFrame"  then v:SetAttribute(attr,CFrame.identity)
                        end
                        break
                    end
                end
            end
        end)
    end
end

local function StartWeaponLoop()
    if _nrConn then return end

    -- Salva pitch atual ao começar
    local function saveCamPitch()
        if not Cfg.Aim.NoRecoil then return end
        local cf = Cam.CFrame
        _nrCamLastY = select(2, cf:ToEulerAnglesYXZ())
        _nrCamLastX = math.asin(cf.LookVector.Y)
    end

    _nrConn = AC(RunService.RenderStepped:Connect(function()
        if not Cfg.Aim.NoRecoil then
            _nrCamLastY = nil; _nrCamLastX = nil
            return
        end
        local char = LP.Character; if not char then return end

        -- ── Abordagem 1: valores de instância ──
        for _,tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then _ZeroRecoilValues(tool) end
        end
        -- também no char (alguns jogos colocam o recoil direto no personagem)
        _ZeroRecoilValues(char)

        -- ── Abordagem 2: congelar o kick vertical da câmera ──
        -- Ao atirar, a câmera sobe bruscamente; travamos o pitch
        local cf = Cam.CFrame
        local _,cy,_ = cf:ToEulerAnglesYXZ()
        local pitch = math.asin(math.clamp(cf.LookVector.Y, -1, 1))

        if _nrCamLastY ~= nil then
            -- Se a câmera foi empurrada para cima mais de 0.003 rad em 1 frame = recoil
            local dpitch = pitch - _nrCamLastX
            if dpitch > 0.003 then
                -- cancela o kick: restaura o pitch anterior
                local newCF = CFrame.new(cf.Position)
                             * CFrame.fromEulerAnglesYXZ(_nrCamLastX, cy, 0)
                pcall(function() Cam.CFrame = newCF end)
            end
        end

        _nrCamLastY = cy
        _nrCamLastX = pitch

        -- ── Abordagem 3: remove BodyAngularVelocity/BodyGyro de recoil no HRP ──
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _,v in ipairs(hrp:GetChildren()) do
                if (v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro")) and _IsRecoilValue(v) then
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end))
end

-- ============================================================
-- INFINITE AMMO — cobertura máxima (v2)
-- Estratégia multicamada:
--   1. Instâncias nomeadas (IntValue/NumberValue) com keywords expandidas
--   2. Atributos do Roblox no tool/char (API moderna de atributos)
--   3. TODOS os IntValue/NumberValue com valor baixo (fallback cego)
--   4. Polling agressivo a cada frame para jogos server-authoritative
--   5. Hooks de .Changed + DescendantAdded para cobertura em tempo real
--   6. Scan de ObjectValue/StringValue que apontam para outros objetos
-- ============================================================
local _iaConns    = {}
local _iaCharConn = nil
local _iaBpConn   = nil
local _iaHBConn   = nil
local _iaHBTick   = 0

-- Keywords expandidas (ammo + recarga)
local AMMO_KW = {
    "ammo","clip","bullets","mag","magazine","reserve","rounds","count",
    "ammocount","currentammo","maxammo","totalammo","bulletcount",
    "remainingammo","ammonumber","ammoremaining","ammorounds",
    "cartridge","shell","charge","capacity","fuel","energy","mana",
    "load","loaded","ingun","inmagazine","currentclip","clipsize",
    "firepower","munition","projectile","shot","shots","fires",
    "firecount","shootcount","remaining",
}

-- Verifica se o nome bate com algum keyword de ammo
local function _isAmmoName(nm)
    nm = nm:lower()
    for _,kw in ipairs(AMMO_KW) do
        if nm:find(kw,1,true) then return true end
    end
    return false
end

-- Tenta setar usando todos os métodos disponíveis
local function _ForceSet(v, val)
    pcall(function() v.Value = val end)
    pcall(function() rawset(v,"Value",val) end)
    if setreadonly then pcall(function() setreadonly(v,false); v.Value=val end) end
end

-- Força via atributos Roblox (API moderna — muitos jogos usam isso)
local function _ForceAttribs(inst, val)
    pcall(function()
        for attr, cur in pairs(inst:GetAttributes()) do
            if type(cur)=="number" and _isAmmoName(attr) then
                inst:SetAttribute(attr, val)
            end
        end
    end)
end

-- Scan completo de uma instância e seus descendentes
-- Modo "cego": além das keywords, força qualquer IntValue/NumberValue
-- com valor entre 0 e 500 (heurística de ammo — evita setar HP/score)
local function _ScanAndForce(inst, aggressive)
    if not inst then return end
    for _,v in ipairs(inst:GetDescendants()) do
        pcall(function()
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local nm = v.Name:lower()
                local isAmmo = _isAmmoName(nm)
                -- modo agressivo: também força valores baixos com nomes suspeitos
                local isSuspect = aggressive and v.Value >= 0 and v.Value <= 500
                    and not nm:find("health",1,true) and not nm:find("hp",1,true)
                    and not nm:find("score",1,true) and not nm:find("cash",1,true)
                    and not nm:find("coin",1,true) and not nm:find("point",1,true)
                    and not nm:find("level",1,true) and not nm:find("exp",1,true)
                    and not nm:find("damage",1,true) and not nm:find("speed",1,true)
                if isAmmo or isSuspect then
                    _ForceSet(v, 9999)
                end
            end
        end)
        -- atributos em qualquer descendente
        _ForceAttribs(v, 9999)
    end
    -- atributos na raiz também
    _ForceAttribs(inst, 9999)
end

local function _IsAmmoValue(v)
    if not (v:IsA("IntValue") or v:IsA("NumberValue")) then return false end
    return _isAmmoName(v.Name)
end

local function _HookTool(tool)
    if _iaConns[tool] then return end
    local conns = {}

    -- Força imediato no scan completo (modo agressivo)
    _ScanAndForce(tool, true)

    -- Hook .Changed em todos os valores de ammo
    local function hookVal(v)
        _ForceSet(v, 9999)
        local c = v.Changed:Connect(function(val)
            if Cfg.Aim.InfAmmo and val < 9999 then
                _ForceSet(v, 9999)
            end
        end)
        conns[#conns+1] = c
    end

    for _,v in ipairs(tool:GetDescendants()) do
        if _IsAmmoValue(v) then hookVal(v) end
    end

    -- Observa novos descendentes (jogos que criam valores ao equipar)
    local dc = tool.DescendantAdded:Connect(function(v)
        if not Cfg.Aim.InfAmmo then return end
        task.defer(function()
            if _IsAmmoValue(v) then hookVal(v) end
            -- força atributos no novo descendente
            _ForceAttribs(v, 9999)
        end)
    end)
    conns[#conns+1] = dc

    -- AttributeChanged no próprio tool (jogos que usam atributos)
    local ac2 = tool.AttributeChanged:Connect(function(attr)
        if not Cfg.Aim.InfAmmo then return end
        if _isAmmoName(attr) then
            pcall(function()
                if type(tool:GetAttribute(attr))=="number" then
                    tool:SetAttribute(attr, 9999)
                end
            end)
        end
    end)
    conns[#conns+1] = ac2

    _iaConns[tool] = conns
end

local function _UnhookTool(tool)
    local conns = _iaConns[tool]
    if not conns then return end
    for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    _iaConns[tool] = nil
end

local function _HookChar(char)
    for tool in pairs(_iaConns) do _UnhookTool(tool) end
    if not char then return end
    local bp = LP:FindFirstChild("Backpack")

    local function hookContainer(cont)
        if not cont then return end
        for _,v in ipairs(cont:GetChildren()) do
            if v:IsA("Tool") then _HookTool(v) end
        end
    end
    hookContainer(char)
    hookContainer(bp)

    if _iaCharConn then pcall(function() _iaCharConn:Disconnect() end) end
    _iaCharConn = char.ChildAdded:Connect(function(v)
        if v:IsA("Tool") and Cfg.Aim.InfAmmo then _HookTool(v) end
    end)
    if _iaBpConn then pcall(function() _iaBpConn:Disconnect() end) end
    if bp then
        _iaBpConn = bp.ChildAdded:Connect(function(v)
            if v:IsA("Tool") and Cfg.Aim.InfAmmo then _HookTool(v) end
        end)
    end
end

local function StartInfAmmo()
    AC(LP.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        if Cfg.Aim.InfAmmo then _HookChar(c) end
    end))
    if LP.Character and Cfg.Aim.InfAmmo then _HookChar(LP.Character) end

    -- Polling a cada 3 frames (~0.05s): mais agressivo para cobrir jogos
    -- que resetam ammo server-side continuamente
    _iaHBConn = AC(RunService.Heartbeat:Connect(function()
        if not Cfg.Aim.InfAmmo then return end
        _iaHBTick = _iaHBTick + 1
        if _iaHBTick % 3 ~= 0 then return end
        local char = LP.Character
        local bp   = LP:FindFirstChild("Backpack")
        local conts = {}
        if char then conts[#conts+1] = char end
        if bp   then conts[#conts+1] = bp end
        for _,cont in ipairs(conts) do
            for _,tool in ipairs(cont:GetChildren()) do
                if not tool:IsA("Tool") then continue end
                -- força todos os valores conhecidos + atributos
                for _,v in ipairs(tool:GetDescendants()) do
                    pcall(function()
                        if (v:IsA("IntValue") or v:IsA("NumberValue")) and _isAmmoName(v.Name) and v.Value < 9999 then
                            _ForceSet(v, 9999)
                        end
                    end)
                    _ForceAttribs(v, 9999)
                end
                _ForceAttribs(tool, 9999)
            end
        end
    end))
end

-- ============================================================
-- TRIGGERBOT
-- ClickControl / One-Shot: modos de disparo do TriggerBot
-- ============================================================
local _tbLast      = 0
local _tbFiring    = false  -- evita disparos sobrepostos
local _osShotReady = true   -- One-Shot: libera o próximo disparo
local _osLastTgt   = nil    -- One-Shot: player do último disparo

local function _DoClicks(n)
    if _tbFiring then return end
    _tbFiring = true
    task.spawn(function()
        local vms = game:GetService("VirtualInputManager")
        for i = 1, math.max(1, n) do
            pcall(function() vms:SendMouseButtonEvent(0,0,0,true,game,0) end)
            task.wait(0.05)
            pcall(function() vms:SendMouseButtonEvent(0,0,0,false,game,0) end)
            if i < n then task.wait(0.04) end
        end
        _tbFiring = false
    end)
end

AC(RunService.Heartbeat:Connect(function()
    if not Cfg.Trigger.Enabled then return end
    if tick()-_tbLast < Cfg.Trigger.Delay/1000 then return end
    local tgt=Mouse.Target; if not tgt then return end
    local model=tgt:FindFirstAncestorOfClass("Model"); if not model then return end
    local p=Players:GetPlayerFromCharacter(model); if not p then return end
    if not IsValidTarget(p) then return end
    if Cfg.Trigger.TeamCheck and SameTeam(p) then return end

    -- One-Shot: 1 disparo por lock, depois aguarda delay configurável
    if Cfg.Trigger.OneShot then
        -- Troca de alvo → reseta imediatamente para atirar
        if p ~= _osLastTgt then
            _osShotReady = true
            _osLastTgt   = p
        end
        if not _osShotReady then return end
        _osShotReady = false
        _tbLast = tick()
        local clicks = (Cfg.Trigger.ClickControl and Cfg.Trigger.ClickCount) or 1
        _DoClicks(clicks)
        -- Após o delay, libera próximo tiro no mesmo alvo
        task.delay(Cfg.Trigger.OneShotDelay, function()
            if _osLastTgt == p then _osShotReady = true end
        end)
        return
    end

    _tbLast=tick()
    local clicks = (Cfg.Trigger.ClickControl and Cfg.Trigger.ClickCount) or 1
    _DoClicks(clicks)
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
    _bg=Instance.new("BodyGyro");    _bg.MaxTorque=Vector3.new(1e5,1e5,1e5); _bg.P=1e4; _bg.Parent=hrp
    _flyConn=AC(RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.Fly then return end
        if not _bv or not _bv.Parent then return end
        local cf=Cam.CFrame; local vel=Vector3.zero
        local spd=Cfg.Misc.FlySpeed*(Cfg.Misc.FlyBoost and 3 or 1)
        if UIS:IsKeyDown(Enum.KeyCode.W)         then vel=vel+cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S)         then vel=vel-cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A)         then vel=vel-cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D)         then vel=vel+cf.RightVector*spd end
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
    -- Restaura colisão: BaseParts que deveriam ter colisão de volta
    -- (exclui partes que naturalmente não têm colisão, como HRP em alguns jogos)
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            -- HumanoidRootPart normalmente não tem colisão no Roblox padrão
            if p.Name == "HumanoidRootPart" then
                p.CanCollide = false
            else
                p.CanCollide = true
            end
        end
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
    hum.JumpPower=Cfg.Misc.JumpPower
end
AC(UIS.JumpRequest:Connect(function()
    if not Cfg.Misc.InfJump then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end))

AC(RunService.Heartbeat:Connect(function()
    if not Cfg.Misc.AlwaysSprint then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if hum.MoveDirection.Magnitude > 0 then
        hum.WalkSpeed=math.max(hum.WalkSpeed, Cfg.Misc.Speed and Cfg.Misc.WalkSpeed or 21)
    end
end))

-- ============================================================
-- ANTI AFK / ANTI RAGDOLL
-- ============================================================
LP.Idled:Connect(function()
    if not Cfg.Misc.AntiAFK then return end
    local vim=game:GetService("VirtualInputManager")
    pcall(function() vim:SendKeyEvent(true,Enum.KeyCode.ButtonL3,false,game) end)
    task.wait(0.5)
    pcall(function() vim:SendKeyEvent(false,Enum.KeyCode.ButtonL3,false,game) end)
end)

AC(RunService.Heartbeat:Connect(function()
    if not Cfg.Misc.AntiRag then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local st=hum:GetState()
    if st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end))

-- ============================================================
-- HITBOX EXTENDER
-- OTIMIZAÇÃO: reutiliza tabela pset em vez de criar por chamada
-- ============================================================
local _hbConns={}
local HBP={
    All  ={"Head","Torso","UpperTorso","LowerTorso","HumanoidRootPart","Left Arm","Right Arm","Left Leg","Right Leg","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"},
    Head ={"Head"}, Torso={"Torso","UpperTorso","LowerTorso"},
    Arms ={"Left Arm","Right Arm","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand"},
    Legs ={"Left Leg","Right Leg","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"},
    HRP  ={"HumanoidRootPart"},
}
-- Pré-converte HBP para sets, evita rebuild por chamada
local HBP_SETS = {}
for k, names in pairs(HBP) do
    local s = {}
    for _,n in ipairs(names) do s[n]=true end
    HBP_SETS[k] = s
end

local function ApplyHBChar(char)
    if not Cfg.Misc.HitboxExtender then return end
    local pset = HBP_SETS[Cfg.Misc.HitboxPart] or HBP_SETS["All"]
    local sz   = Cfg.Misc.HitboxSize
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and pset[v.Name] then
            v.Size=Vector3.new(sz,sz,sz)
            v.LocalTransparencyModifier=0.8
        end
    end
end
local function SetHitbox(p,on)
    if p==LP then return end
    if _hbConns[p] then _hbConns[p]:Disconnect(); _hbConns[p]=nil end
    if on then
        if p.Character then ApplyHBChar(p.Character) end
        _hbConns[p]=p.CharacterAdded:Connect(function(c) task.wait(0.5); ApplyHBChar(c) end)
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
-- THIRD PERSON / FREECAM
-- ============================================================
local _tpConn=nil
local _tpMouseConn=nil
local _tpYaw,_tpPitch=0,-0.35   -- ângulos orbit: começa ligeiramente acima e atrás

local function EnableThirdPerson()
    if _tpConn then return end
    -- Desliga FreeCam se estiver ativo (conflitam pelo mouse)
    if Cfg.Misc.FreeCam then
        Cfg.Misc.FreeCam = false
        DisableFreeCam()
    end
    -- Inicializa yaw a partir da direção atual do personagem
    local char0 = LP.Character
    local hrp0  = char0 and char0:FindFirstChild("HumanoidRootPart")
    if hrp0 then
        local _,ry,_ = hrp0.CFrame:ToEulerAnglesYXZ()
        _tpYaw = ry + math.pi  -- começa atrás do personagem
    end

    -- Mouse rotaciona a câmera ao redor do personagem
    _tpMouseConn = UIS.InputChanged:Connect(function(inp)
        if not Cfg.Misc.ThirdPerson then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            local sens = 0.003
            _tpYaw   = _tpYaw   - inp.Delta.X * sens
            _tpPitch = math.clamp(_tpPitch - inp.Delta.Y * sens, -0.9, 0.5)
        end
    end)
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

    _tpConn=AC(RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.ThirdPerson then return end
        local char=LP.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

        local dist = Cfg.Misc.ThirdPersonDist
        -- Ponto-alvo: altura do peito do personagem
        local target = hrp.Position + Vector3.new(0, 1.4, 0)

        -- Posição esférica da câmera ao redor do personagem
        local camX = target.X + dist * math.cos(_tpPitch) * math.sin(_tpYaw)
        local camY = target.Y + dist * math.sin(_tpPitch)
        local camZ = target.Z + dist * math.cos(_tpPitch) * math.cos(_tpYaw)
        local camPos = Vector3.new(camX, camY, camZ)

        -- Raycast para evitar que a câmera atravesse paredes
        local char2 = LP.Character
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local ex = {}
        if char2 then for _,v in ipairs(char2:GetDescendants()) do if v:IsA("BasePart") then ex[#ex+1]=v end end end
        rp.FilterDescendantsInstances = ex
        local ray = Workspace:Raycast(target, camPos-target, rp)
        if ray then
            -- recua a câmera até o ponto de colisão (com margem)
            camPos = ray.Position + (target-camPos).Unit * 0.3
        end

        Cam.CameraType = Enum.CameraType.Scriptable
        Cam.CFrame = CFrame.new(camPos, target)

        -- Rotaciona o personagem na direção horizontal da câmera (para o player andar "pra frente")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            -- só rotaciona o HRP se o player está se movendo
            hrp.CFrame = CFrame.new(hrp.Position) *
                CFrame.fromEulerAnglesYXZ(0, _tpYaw + math.pi, 0)
        end
    end))
end

local function DisableThirdPerson()
    if _tpConn then _tpConn:Disconnect(); _tpConn=nil end
    if _tpMouseConn then _tpMouseConn:Disconnect(); _tpMouseConn=nil end
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    Cam.CameraType = Enum.CameraType.Custom
    local char=LP.Character
    if char then local h=char:FindFirstChildOfClass("Humanoid"); if h then Cam.CameraSubject=h end end
end

local _fcPart,_fcConn=nil,nil
local _fcMouseConn=nil   -- captura mouse para rotação
local _fcYaw,_fcPitch=0,0  -- ângulos da câmera na FreeCam

local function EnableFreeCam()
    if _fcConn then return end
    -- Desliga ThirdPerson se estiver ativo (conflitam pelo mouse)
    if Cfg.Misc.ThirdPerson then
        Cfg.Misc.ThirdPerson = false
        DisableThirdPerson()
    end
    local char=LP.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")

    -- Congela o personagem: PlatformStand impede input de movimento
    if hum then hum.PlatformStand=true end

    _fcPart=Instance.new("Part"); _fcPart.Anchored=true; _fcPart.CanCollide=false
    _fcPart.Transparency=1; _fcPart.Size=Vector3.new(0.1,0.1,0.1)
    _fcPart.CFrame=Cam.CFrame; _fcPart.Parent=Workspace

    -- Inicializa ângulos a partir da câmera atual
    local _,ry,_ = Cam.CFrame:ToEulerAnglesYXZ()
    local rx = math.asin(Cam.CFrame.LookVector.Y)
    _fcYaw   = ry
    _fcPitch = -rx

    Cam.CameraSubject=_fcPart; Cam.CameraType=Enum.CameraType.Scriptable

    -- Captura movimento do mouse para rotação da câmera
    _fcMouseConn = UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            local sens = 0.003
            _fcYaw   = _fcYaw   - inp.Delta.X * sens
            _fcPitch = math.clamp(_fcPitch - inp.Delta.Y * sens, -math.pi/2 + 0.05, math.pi/2 - 0.05)
        end
    end)
    -- Trava o mouse no centro da tela
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

    _fcConn=AC(RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.FreeCam then return end
        local spd = Cfg.Misc.FCamSpeed * 0.6

        -- Reconstrói CFrame a partir dos ângulos acumulados
        local rot = CFrame.fromEulerAnglesYXZ(_fcPitch, _fcYaw, 0)
        local fwd  = rot.LookVector
        local rgt  = rot.RightVector

        local mv = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + fwd  * spd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - fwd  * spd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - rgt  * spd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + rgt  * spd end
        if UIS:IsKeyDown(Enum.KeyCode.E) then mv = mv + Vector3.new(0,spd,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then mv = mv - Vector3.new(0,spd,0) end

        local newPos = _fcPart.Position + mv
        _fcPart.CFrame = CFrame.new(newPos) * rot
        Cam.CFrame = _fcPart.CFrame
    end))
end

local function DisableFreeCam()
    if _fcConn then _fcConn:Disconnect(); _fcConn=nil end
    if _fcMouseConn then _fcMouseConn:Disconnect(); _fcMouseConn=nil end
    if _fcPart then pcall(function() _fcPart:Destroy() end); _fcPart=nil end
    -- Restaura mouse e câmera
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    Cam.CameraType = Enum.CameraType.Custom
    local char=LP.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false end
        local h=char:FindFirstChildOfClass("Humanoid"); if h then Cam.CameraSubject=h end
    end
end

-- ============================================================
-- MODOS ESPECIAIS
-- ============================================================
local _aquaConn=nil
local function EnableAquaman()
    if _aquaConn then return end
    _aquaConn=AC(RunService.Heartbeat:Connect(function()
        if not Cfg.Modes.Aquaman then return end
        local char=LP.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if hum:GetState()==Enum.HumanoidStateType.Swimming then
            if hum.Health<hum.MaxHealth and hum.Health>0 then
                hum.Health=math.min(hum.MaxHealth, hum.Health+1)
            end
        end
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("Script") and (v.Name:lower():find("drown",1,true) or v.Name:lower():find("oxygen",1,true)) then
                pcall(function() v.Disabled=true end)
            end
        end
    end))
end

local _nfdConn=nil
local _lastHP=100
local function EnableNoFallDmg()
    if _nfdConn then return end
    _nfdConn=AC(RunService.Heartbeat:Connect(function()
        if not Cfg.Modes.NoFallDmg then return end
        local char=LP.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local st=hum:GetState()
        if st==Enum.HumanoidStateType.Freefall then
            _lastHP=hum.Health
        elseif st==Enum.HumanoidStateType.Landed then
            if hum.Health < _lastHP-5 then hum.Health=_lastHP end
        end
    end))
end

-- ============================================================
-- CLICK TP / TOOLS / SERVER
-- ============================================================
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

-- ============================================================
-- GRAB TOOL — robusto para jogos com sistemas customizados
-- Tenta 4 métodos em sequência até um funcionar:
--   1. .Parent direto (método padrão)
--   2. Humanoid:EquipTool() — API oficial do Roblox
--   3. FireServer em RemoteEvent de pickup se encontrado no jogo
--   4. Teleporta o char até a tool e usa Humanoid:EquipTool
-- ============================================================
local function _TryGrab(tool)
    if not tool or not tool.Parent then return false end
    local bp   = LP:FindFirstChild("Backpack")
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")

    -- Método 1: parent direto para backpack
    local ok1 = pcall(function() tool.Parent = bp end)
    if ok1 and (tool.Parent == bp or (char and tool.Parent == char)) then return true end

    -- Método 2: EquipTool via Humanoid
    if hum then
        local ok2 = pcall(function() hum:EquipTool(tool) end)
        if ok2 and tool.Parent == char then return true end
    end

    -- Método 3: procura RemoteEvent de "pickup" / "grab" no jogo
    local function findPickupRemote()
        for _,v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local nm = v.Name:lower()
                if nm:find("pickup",1,true) or nm:find("grab",1,true) or nm:find("equip",1,true) or nm:find("collect",1,true) then
                    return v
                end
            end
        end
        return nil
    end
    local remote = findPickupRemote()
    if remote then
        pcall(function() remote:FireServer(tool) end)
        task.wait(0.1)
        if tool.Parent == bp or (char and tool.Parent == char) then return true end
    end

    -- Método 4: teleporta até a tool e tenta novamente
    if hum and char then
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local part = tool:FindFirstChildOfClass("BasePart")
        if hrp and part then
            local origCF = hrp.CFrame
            pcall(function() hrp.CFrame = part.CFrame + Vector3.new(0,3,0) end)
            task.wait(0.08)
            pcall(function() hum:EquipTool(tool) end)
            task.wait(0.08)
            pcall(function() hrp.CFrame = origCF end)
            if tool.Parent == char or tool.Parent == bp then return true end
        end
    end

    return false
end

local function GrabNearestTool()
    local char=LP.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local best,bestD=nil,math.huge
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and not v:IsDescendantOf(Players) then
            local part=v:FindFirstChildOfClass("BasePart")
            if part then
                local dd=(part.Position-hrp.Position).Magnitude
                if dd<bestD then bestD=dd; best=v end
            end
        end
    end
    if not best then return nil end
    local name = best.Name
    local ok = _TryGrab(best)
    return ok and name or nil
end

local function GetMapTools()
    local out={}
    for _,v in ipairs(Workspace:GetDescendants()) do
        -- filtra tools que já estão sendo usadas por outros players
        if v:IsA("Tool") and not v:IsDescendantOf(Players) then
            local part = v:FindFirstChildOfClass("BasePart")
            -- só lista tools que têm uma parte física (estão no mundo, não em scripts)
            if part then
                out[#out+1]={name=v.Name, tool=v, dist=0}
            end
        end
    end
    -- ordena por distância do player
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _,entry in ipairs(out) do
            local part = entry.tool:FindFirstChildOfClass("BasePart")
            entry.dist = part and (part.Position - hrp.Position).Magnitude or math.huge
        end
        table.sort(out, function(a,b) return a.dist < b.dist end)
    end
    return out
end
local function DupeTool()
    local nm=Cfg.Misc.DupeToolName:lower():gsub("%s+",""); if nm=="" then return end
    local bp=LP:FindFirstChild("Backpack"); local char=LP.Character; local tool
    if bp   then for _,v in ipairs(bp:GetChildren())   do if v:IsA("Tool") and v.Name:lower():find(nm,1,true) then tool=v;break end end end
    if not tool and char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(nm,1,true) then tool=v;break end end end
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
-- RENDER LOOP PRINCIPAL
-- OTIMIZAÇÃO: GetBounds calculado UMA vez e reaproveitado;
-- cache de visibilidade; CFrame aimbot pré-calculado
-- ============================================================

AC(RunService.RenderStepped:Connect(function()
    local vs  = Cam.ViewportSize
    local cx  = vs.X/2
    local cy  = vs.Y/2

    -- Incrementa stamp do frame para cache de visibilidade
    _visFrameStamp = _visFrameStamp + 1

    UpdateFOVCircle()

    -- ── Aimbot ──
    if Cfg.Aim.Aimbot and UIS:IsKeyDown(Cfg.Aim.AimKey) then
        local t = ClosestTarget()
        if t and t.Character then
            local part = t.Character:FindFirstChild(Cfg.Aim.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos = part.Position
                if Cfg.Aim.Prediction then
                    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then pos = pos + hrp.AssemblyLinearVelocity * (Cfg.Aim.PredStr * 0.02) end
                end
                local alpha = math.clamp(
                    math.clamp(Cfg.Aim.AimStrength/100,0.01,1) *
                    math.clamp((101-Cfg.Aim.Smoothness)/100,0.01,1),
                    0.005, 1.0)
                Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, pos), alpha)
            end
        end
    end

    -- ── AutoBot ──
    if Cfg.Trigger.AutoBot then
        local t = ClosestTarget()
        if t and t.Character then
            local part = t.Character:FindFirstChild(Cfg.Aim.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos = part.Position
                if Cfg.Aim.Prediction then
                    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then pos = pos + hrp.AssemblyLinearVelocity * (Cfg.Aim.PredStr * 0.02) end
                end
                local alpha = math.clamp(
                    math.clamp(Cfg.Aim.AimStrength/100,0.01,1) *
                    math.clamp((101-Cfg.Aim.Smoothness)/100,0.01,1),
                    0.005, 1.0)
                Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, pos), alpha)
            end
        end
    end

    -- OTIMIZAÇÃO: early-exit se nem ESP nem Xray estão ativos
    if not Cfg.ESP.Enabled and not Cfg.Xray.Enabled then return end

    local vsY = vs.Y

    -- ── ESP / XRAY LOOP ──
    for player, d in pairs(ESPO) do
        if not player or not player.Parent then KillESP(player); continue end

        local c = player.Character
        if not c then HideESP(d); continue end

        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then HideESP(d); continue end

        local dist = GetDist(c) or 99999

        -- OTIMIZAÇÃO: GetBounds calculado UMA vez e compartilhado entre ESP e Xray
        local bx, by, bw, bh = GetBounds(c)

        -- Visibilidade calculada UMA vez via cache
        local visible = (not Cfg.ESP.WallCheck) or IsVisibleCached(player, c)

        -- ── ESP NORMAL ──
        local showESP = Cfg.ESP.Enabled
            and dist <= Cfg.ESP.MaxDist
            and (not Cfg.ESP.TeamCheck  or not SameTeam(player))
            and (not next(Cfg.ESP.TrackList) or Cfg.ESP.TrackList[player.Name])
            and visible

        if showESP and bx then
            local x,y,w,h = bx,by,bw,bh

            if Cfg.ESP.Box and d.Box then
                SafeSet(d.Box,{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=Cfg.ESP.BoxColor,Transparency=0.7,Visible=true})
            else SafeHide(d.Box) end

            if Cfg.ESP.Fill and d.Fill then
                SafeSet(d.Fill,{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=Cfg.ESP.FillColor,Transparency=0.7,Visible=true})
            else SafeHide(d.Fill) end

            if Cfg.ESP.Names and d.Name then
                SafeSet(d.Name,{Position=Vector2.new(x+w/2,y-18),Text=player.DisplayName,Color=Cfg.ESP.NameColor,Visible=true})
            else SafeHide(d.Name) end

            if Cfg.ESP.Dist and d.Dist then
                SafeSet(d.Dist,{Position=Vector2.new(x+w/2,y+h+4),Text=math.floor(dist).."m",Color=Cfg.ESP.DistColor,Visible=true})
            else SafeHide(d.Dist) end

            if Cfg.ESP.HP then
                local hp, mhp = GetHP(c)
                local ratio   = math.clamp(hp/mhp, 0, 1)
                local barH    = h * ratio
                local barY    = y + (h - barH)
                local gr = math.clamp(2*ratio, 0, 1)
                local rd = math.clamp(2*(1-ratio), 0, 1)
                local hpCol = Color3.new(rd, gr, 0.05)
                if d.HPBg  then SafeSet(d.HPBg, {Position=Vector2.new(x-7,y),   Size=Vector2.new(5,h),   Color=Cfg.ESP.HPBgColor,Transparency=0.7,Visible=true}) end
                if d.HPBar then SafeSet(d.HPBar,{Position=Vector2.new(x-7,barY),Size=Vector2.new(5,barH),Color=hpCol,Transparency=0,Visible=true}) end
            else SafeHide(d.HPBg); SafeHide(d.HPBar) end

            if Cfg.ESP.Tracers and d.Tracer then
                SafeSet(d.Tracer,{From=Vector2.new(cx,vsY),To=Vector2.new(x+w/2,y+h),Color=Cfg.ESP.TracerColor,Transparency=0.7,Visible=true})
            else SafeHide(d.Tracer) end

            if Cfg.ESP.HeldTool and d.Tool then
                local tn = GetHeldTool(c)
                if tn then SafeSet(d.Tool,{Position=Vector2.new(x+w/2,y-32),Text="["..tn.."]",Color=Cfg.ESP.ToolColor,Visible=true})
                else SafeHide(d.Tool) end
            else SafeHide(d.Tool) end
        else
            SafeHide(d.Box); SafeHide(d.Fill); SafeHide(d.Name)
            SafeHide(d.Dist); SafeHide(d.HPBg); SafeHide(d.HPBar)
            SafeHide(d.Tracer); SafeHide(d.Tool)
        end

        -- ── XRAY ──
        local showXray = Cfg.Xray.Enabled
            and dist <= Cfg.Xray.MaxDist
            and (not Cfg.Xray.TeamCheck or not SameTeam(player))

        if showXray and bx then
            local x,y,w,h = bx,by,bw,bh

            if Cfg.Xray.Box and d.XBox then
                SafeSet(d.XBox,{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=Cfg.Xray.BoxColor,Transparency=0.7,Visible=true})
            else SafeHide(d.XBox) end

            if Cfg.Xray.Fill and d.XFill then
                SafeSet(d.XFill,{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=Cfg.Xray.FillColor,Transparency=0.7,Visible=true})
            else SafeHide(d.XFill) end

            if Cfg.Xray.Names and d.XName then
                SafeSet(d.XName,{Position=Vector2.new(x+w/2,y-18),Text="["..player.DisplayName.."]",Color=Cfg.Xray.NameColor,Visible=true})
            else SafeHide(d.XName) end

            if Cfg.Xray.Dist and d.XDist then
                SafeSet(d.XDist,{Position=Vector2.new(x+w/2,y+h+4),Text=math.floor(dist).."m",Color=Cfg.Xray.DistColor,Visible=true})
            else SafeHide(d.XDist) end

            if Cfg.Xray.HP then
                local hp,mhp = GetHP(c)
                local ratio  = math.clamp(hp/mhp,0,1)
                local barH   = h*ratio
                local barY   = y+(h-barH)
                if d.XHPBg  then SafeSet(d.XHPBg, {Position=Vector2.new(x+w+5,y),  Size=Vector2.new(5,h),   Color=Cfg.Xray.HPBgColor,Transparency=0.7,Visible=true}) end
                if d.XHPBar then SafeSet(d.XHPBar,{Position=Vector2.new(x+w+5,barY),Size=Vector2.new(5,barH),Color=Cfg.Xray.HPColor,Transparency=0,Visible=true}) end
            else SafeHide(d.XHPBg); SafeHide(d.XHPBar) end

            if Cfg.Xray.Tracers and d.XTracer then
                SafeSet(d.XTracer,{From=Vector2.new(cx,vsY),To=Vector2.new(x+w/2,y+h),Color=Cfg.Xray.TracerColor,Transparency=0.7,Visible=true})
            else SafeHide(d.XTracer) end

            if Cfg.Xray.Skeleton then
                local isR6    = c:FindFirstChild("Torso") ~= nil
                local bones   = isR6 and BONES_R6 or BONES_R15
                local numBones= #bones
                for bi = 1, MAX_BONES do
                    local ln = d.Skel[bi]
                    if not ln then continue end
                    if bi > numBones then SafeHide(ln)
                    else
                        local pair = bones[bi]
                        local p1   = c:FindFirstChild(pair[1])
                        local p2   = c:FindFirstChild(pair[2])
                        if p1 and p2 then
                            local s1, ok1 = W2S(p1.Position)
                            local s2, ok2 = W2S(p2.Position)
                            if ok1 or ok2 then SafeSet(ln,{From=s1,To=s2,Color=Cfg.Xray.SkelColor,Visible=true})
                            else SafeHide(ln) end
                        else SafeHide(ln) end
                    end
                end
            else
                for _,ln in ipairs(d.Skel) do SafeHide(ln) end
            end
        else
            SafeHide(d.XBox); SafeHide(d.XFill); SafeHide(d.XName)
            SafeHide(d.XDist); SafeHide(d.XHPBg); SafeHide(d.XHPBar); SafeHide(d.XTracer)
            for _,ln in ipairs(d.Skel) do SafeHide(ln) end
        end
    end
end))

for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(function(p)
    MakeESP(p)
    if Cfg.Misc.HitboxExtender then SetHitbox(p,true) end
end)
Players.PlayerRemoving:Connect(function(p)
    KillESP(p); _hbConns[p]=nil
end)
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed(); ApplyJump()
    if Cfg.Misc.Fly    then EnableFly()    end
    if Cfg.Misc.Noclip then EnableNoclip() end
end)

StartWeaponLoop(); StartInfAmmo(); StartClickTp(); StartChatLog()
EnableAquaman(); EnableNoFallDmg()

-- ============================================================
-- TELAGEM BYPASS (Panic Key)
-- Esconde/mostra a GUI completa + drawings do ESP/FOV.
-- Quando ativo: GUI some, ESP drawings ficam invisíveis,
-- o jogo parece completamente limpo para quem está vendo a tela.
-- ============================================================
local _bypassActive  = false
local _bypassEspSave = {}   -- salva estado anterior do ESP/Xray ao ativar

local function ApplyBypass(on)
    -- GUI principal
    if Win then Win.Visible = not on end

    -- ESP / Xray drawings
    if on then
        -- salva estados e esconde tudo
        _bypassEspSave.esp  = Cfg.ESP.Enabled
        _bypassEspSave.xray = Cfg.Xray.Enabled
        _bypassEspSave.fov  = Cfg.Aim.ShowFOV
        Cfg.ESP.Enabled   = false
        Cfg.Xray.Enabled  = false
        Cfg.Aim.ShowFOV   = false
        _fovLastVis = nil   -- força update do círculo FOV
        -- esconde todos os drawings imediatamente
        for _, d in pairs(ESPO) do HideESP(d) end
        for _, ln in ipairs(_fovLines) do SafeHide(ln) end
    else
        -- restaura estados anteriores
        Cfg.ESP.Enabled  = _bypassEspSave.esp  or false
        Cfg.Xray.Enabled = _bypassEspSave.xray or false
        Cfg.Aim.ShowFOV  = _bypassEspSave.fov  or false
        _fovLastVis = nil
    end
end

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
    elseif kc==Cfg.Settings.BypassKey and Cfg.Settings.BypassEnabled then
        _bypassActive = not _bypassActive
        ApplyBypass(_bypassActive)
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

local LF=Instance.new("Frame",SG); LF.Size=UDim2.new(0,920,0,520); LF.Position=UDim2.new(0.5,-460,0.5,-260)
LF.BackgroundColor3=C.bg0; LF.BorderSizePixel=0; LF.ZIndex=200
Instance.new("UICorner",LF).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",LF).Color=C.red
local function TLn(p,bot) local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,2); f.Position=bot and UDim2.new(0,0,1,-2) or UDim2.new(0,0,0,0); f.BackgroundColor3=C.red; f.BorderSizePixel=0 end
TLn(LF,false); TLn(LF,true)
local LC=Instance.new("Frame",LF); LC.Size=UDim2.new(0,420,0,170); LC.Position=UDim2.new(0.5,-210,0.5,-130); LC.BackgroundTransparency=1
local function LBL(p,t,sz,col,y,fn) local l=Instance.new("TextLabel",p); l.Text=t; l.Size=UDim2.new(1,0,0,sz); l.Position=UDim2.new(0,0,0,y); l.BackgroundTransparency=1; l.TextColor3=col; l.Font=fn or FB; l.TextSize=sz; l.TextXAlignment=Enum.TextXAlignment.Center end
LBL(LC,"◈",50,C.red,0); LBL(LC,"223HUB",42,C.wht,52); LBL(LC,"HUB BY REVOLUCIONARI'US GROUP",14,C.dim,98,FM)
LBL(LC,"SCRIPT FEITO POR BRUNO223J AND TY  ·  DISCORD: .223j | frty2017",11,C.gold,114,FM)
LBL(LC,"v1.0  ·  🔴 RELEASE",10,C.red,130,FC)
local BC=Instance.new("Frame",LF); BC.Size=UDim2.new(0,360,0,5); BC.Position=UDim2.new(0.5,-180,0.5,62); BC.BackgroundColor3=C.bg4; BC.BorderSizePixel=0; Instance.new("UICorner",BC).CornerRadius=UDim.new(1,0)
local BF=Instance.new("Frame",BC); BF.Size=UDim2.new(0,0,1,0); BF.BackgroundColor3=C.red; BF.BorderSizePixel=0; Instance.new("UICorner",BF).CornerRadius=UDim.new(1,0)
local LST=Instance.new("TextLabel",LF); LST.Size=UDim2.new(0,360,0,16); LST.Position=UDim2.new(0.5,-180,0.5,76); LST.BackgroundTransparency=1; LST.TextColor3=C.dim; LST.Font=FC; LST.TextSize=10; LST.TextXAlignment=Enum.TextXAlignment.Center; LST.Text="Inicializando..."
local LSTEPS={{0.12,"Verificando..."},{0.3,"ESP & Xray..."},{0.45,"Aimbot..."},{0.6,"Modos..."},{0.75,"Keybinds..."},{0.9,"Saves..."},{1.0,"🎉 Bem-vindo, "..LP.Name.."!"}}
task.spawn(function()
    local st=tick()
    while true do
        local pr=math.min((tick()-st)/3.5,1)
        BF.Size=UDim2.new(pr,0,1,0)
        for i=#LSTEPS,1,-1 do if pr>=LSTEPS[i][1]-0.01 then LST.Text=LSTEPS[i][2]; break end end
        if pr>=1 then break end; task.wait(0.03)
    end
end)
task.wait(3.8)
TweenService:Create(LF,TweenInfo.new(0.45,Enum.EasingStyle.Quart),{BackgroundTransparency=1}):Play()
for _,v in ipairs(LF:GetDescendants()) do
    if v:IsA("TextLabel") then TweenService:Create(v,TweenInfo.new(0.35),{TextTransparency=1}):Play()
    elseif v:IsA("Frame") then TweenService:Create(v,TweenInfo.new(0.35),{BackgroundTransparency=1}):Play() end
end
task.wait(0.5); LF:Destroy()

local Win=Instance.new("Frame",SG)
Win.Name="Win"; Win.Size=UDim2.new(0,920,0,520); Win.Position=UDim2.new(0.5,-460,0.5,-260)
Win.BackgroundColor3=C.bg0; Win.BorderSizePixel=0; Win.Active=true; Win.Draggable=true
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",Win).Color=C.red
_G._223HUB_Win=Win

local TB=Instance.new("Frame",Win); TB.Size=UDim2.new(1,0,0,38); TB.BackgroundColor3=C.bg1; TB.BorderSizePixel=0; Instance.new("UICorner",TB).CornerRadius=UDim.new(0,6)
local _=Instance.new("Frame",TB); _.Size=UDim2.new(1,0,0,6); _.BackgroundColor3=C.bg1; _.Position=UDim2.new(0,0,1,-6); _.BorderSizePixel=0
local _=Instance.new("Frame",Win); _.Size=UDim2.new(1,0,0,1); _.Position=UDim2.new(0,0,0,38); _.BackgroundColor3=C.red; _.BorderSizePixel=0
local LG=Instance.new("Frame",TB); LG.Size=UDim2.new(0,218,1,0); LG.BackgroundTransparency=1
local _=Instance.new("TextLabel",LG); _.Text="◈"; _.Size=UDim2.new(0,30,1,0); _.Position=UDim2.new(0,8,0,0); _.BackgroundTransparency=1; _.TextColor3=C.red; _.Font=FB; _.TextSize=20
local _=Instance.new("TextLabel",LG); _.Text="223HUB  v1.0"; _.Size=UDim2.new(1,-40,0,22); _.Position=UDim2.new(0,36,0,5); _.BackgroundTransparency=1; _.TextColor3=C.wht; _.Font=FB; _.TextSize=15; _.TextXAlignment=Enum.TextXAlignment.Left
local _=Instance.new("TextLabel",LG); _.Text="BRUNO223J & TY · .223j | frty2017"; _.Size=UDim2.new(1,-40,0,12); _.Position=UDim2.new(0,36,0,22); _.BackgroundTransparency=1; _.TextColor3=C.gold; _.Font=FM; _.TextSize=9; _.TextXAlignment=Enum.TextXAlignment.Left
local _=Instance.new("Frame",TB); _.Size=UDim2.new(0,1,0.55,0); _.Position=UDim2.new(0,216,0.22,0); _.BackgroundColor3=C.sep; _.BorderSizePixel=0
local MinB=Instance.new("TextButton",TB); MinB.Text="—"; MinB.Size=UDim2.new(0,28,0,22); MinB.Position=UDim2.new(1,-33,0.5,-11); MinB.BackgroundColor3=C.bg4; MinB.TextColor3=C.dim; MinB.Font=FB; MinB.TextSize=13; MinB.BorderSizePixel=0; Instance.new("UICorner",MinB).CornerRadius=UDim.new(0,4)
MinB.MouseButton1Click:Connect(function() _guiVisible=not _guiVisible; Win.Visible=_guiVisible end)
local TA=Instance.new("Frame",TB); TA.Size=UDim2.new(1,-258,1,0); TA.Position=UDim2.new(0,220,0,0); TA.BackgroundTransparency=1
local TALL=Instance.new("UIListLayout",TA); TALL.FillDirection=Enum.FillDirection.Horizontal; TALL.VerticalAlignment=Enum.VerticalAlignment.Center; TALL.Padding=UDim.new(0,1)
local CF=Instance.new("Frame",Win); CF.Size=UDim2.new(1,-16,1,-52); CF.Position=UDim2.new(0,8,0,48); CF.BackgroundTransparency=1; CF.BorderSizePixel=0

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
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,26); f.BackgroundColor3=C.bg3; f.BorderSizePixel=0; f.LayoutOrder=order; Instance.new("UICorner",f).CornerRadius=UDim.new(0,4)
    local chk=Instance.new("Frame",f); chk.Size=UDim2.new(0,16,0,16); chk.Position=UDim2.new(0,7,0.5,-8); chk.BackgroundColor3=C.bg4; chk.BorderSizePixel=0; Instance.new("UICorner",chk).CornerRadius=UDim.new(0,4)
    local cS=Instance.new("UIStroke",chk); cS.Color=C.sep; cS.Thickness=1
    local ck=Instance.new("TextLabel",chk); ck.Text="✓"; ck.Size=UDim2.new(1,0,1,0); ck.BackgroundTransparency=1; ck.TextColor3=col; ck.Font=FB; ck.TextSize=13
    local lb=Instance.new("TextLabel",f); lb.Text=label; lb.Size=UDim2.new(1,-36,1,0); lb.Position=UDim2.new(0,30,0,0); lb.BackgroundTransparency=1; lb.TextColor3=C.text; lb.Font=FM; lb.TextSize=12; lb.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    local function ref()
        local v=getV()
        ck.Visible=v; chk.BackgroundColor3=v and Color3.fromRGB(30,8,30) or C.bg4
        cS.Color=v and col or C.sep; f.BackgroundColor3=v and Color3.fromRGB(20,6,20) or C.bg3
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
local function Slider(parent,label,mn,mx,def,order,cb,ac)
    local cur=def; local fcol=ac or C.pink
    local hf=Instance.new("Frame",parent); hf.Size=UDim2.new(1,0,0,16); hf.BackgroundTransparency=1; hf.LayoutOrder=order
    local hl=Instance.new("TextLabel",hf); hl.Text=label; hl.Size=UDim2.new(1,-38,1,0); hl.BackgroundTransparency=1; hl.TextColor3=C.dim; hl.Font=FM; hl.TextSize=11; hl.TextXAlignment=Enum.TextXAlignment.Left
    local bm=Instance.new("TextButton",hf); bm.Text="-"; bm.Size=UDim2.new(0,16,1,0); bm.Position=UDim2.new(1,-34,0,0); bm.BackgroundTransparency=1; bm.TextColor3=C.dim; bm.Font=FB; bm.TextSize=14; bm.BorderSizePixel=0
    local bp=Instance.new("TextButton",hf); bp.Text="+"; bp.Size=UDim2.new(0,16,1,0); bp.Position=UDim2.new(1,-16,0,0); bp.BackgroundTransparency=1; bp.TextColor3=C.dim; bp.Font=FB; bp.TextSize=14; bp.BorderSizePixel=0
    local bf=Instance.new("Frame",parent); bf.Size=UDim2.new(1,0,0,18); bf.BackgroundTransparency=1; bf.LayoutOrder=order+1
    local bar=Instance.new("Frame",bf); bar.Size=UDim2.new(1,0,0,18); bar.BackgroundColor3=C.bg4; bar.BorderSizePixel=0; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local r0=math.clamp((def-mn)/(mx-mn),0,1)
    local fill=Instance.new("Frame",bar); fill.Size=UDim2.new(r0,0,1,0); fill.BackgroundColor3=fcol; fill.BorderSizePixel=0; Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3)
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
    b.MouseEnter:Connect(function() b.BackgroundColor3=Color3.fromRGB(math.min(bgc.R*255+20,255),math.min(bgc.G*255+12,255),math.min(bgc.B*255+12,255)) end)
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
        local v=getCfg(); eTk.Visible=v
        ec.BackgroundColor3=v and Color3.fromRGB(35,7,7) or C.bg4; eS.Color=v and acol or C.sep
        er.BackgroundColor3=v and Color3.fromRGB(35,9,9) or Color3.fromRGB(22,6,6)
    end
    if cbKey then _CBs[cbKey]=ref end
    eBtn.MouseButton1Click:Connect(function() setCfg(not getCfg()); ref() end)
    ref()
end
local function PLWidget(parent,sO,title,data,ac)
    local col=ac or C.red
    Sep(parent,sO); SL(parent,title,sO+1,col)
    local ar=Instance.new("Frame",parent); ar.Size=UDim2.new(1,0,0,28); ar.BackgroundTransparency=1; ar.LayoutOrder=sO+2
    local ab=Instance.new("TextBox",ar); ab.PlaceholderText="Username..."; ab.Text=""; ab.Size=UDim2.new(1,-54,1,0); ab.BackgroundColor3=C.bg3; ab.TextColor3=C.text; ab.PlaceholderColor3=C.dim; ab.Font=FM; ab.TextSize=12; ab.BorderSizePixel=0; ab.ClearTextOnFocus=false
    Instance.new("UICorner",ab).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",ab).Color=C.sep; Instance.new("UIPadding",ab).PaddingLeft=UDim.new(0,7)
    local abtn=Instance.new("TextButton",ar); abtn.Text="+ Add"; abtn.Size=UDim2.new(0,48,1,0); abtn.Position=UDim2.new(1,-48,0,0); abtn.BackgroundColor3=col; abtn.TextColor3=C.wht; abtn.Font=FB; abtn.TextSize=11; abtn.BorderSizePixel=0; Instance.new("UICorner",abtn).CornerRadius=UDim.new(0,4)
    local lh=Instance.new("Frame",parent); lh.Size=UDim2.new(1,0,0,90); lh.BackgroundColor3=C.bg4; lh.BorderSizePixel=0; lh.LayoutOrder=sO+3; Instance.new("UICorner",lh).CornerRadius=UDim.new(0,4)
    local ls=Instance.new("ScrollingFrame",lh); ls.Size=UDim2.new(1,-8,1,-8); ls.Position=UDim2.new(0,4,0,4); ls.BackgroundTransparency=1; ls.BorderSizePixel=0; ls.ScrollBarThickness=2; ls.ScrollBarImageColor3=col; ls.CanvasSize=UDim2.new(0,0,0,0); ls.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",ls).Padding=UDim.new(0,2)
    local sf=Instance.new("Frame",parent); sf.Size=UDim2.new(1,0,0,14); sf.BackgroundTransparency=1; sf.LayoutOrder=sO+4
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

local _pages={}; local _curTab=nil
local function MakeTab(name,order,col)
    local btn=Instance.new("TextButton",TA); btn.Text=name:upper(); btn.Size=UDim2.new(0,73,0,38); btn.BackgroundTransparency=1; btn.TextColor3=C.dim; btn.Font=FB; btn.TextSize=11; btn.BorderSizePixel=0; btn.LayoutOrder=order
    local ul=Instance.new("Frame",btn); ul.Size=UDim2.new(0.75,0,0,2); ul.Position=UDim2.new(0.125,0,1,-2); ul.BackgroundColor3=col or C.redH; ul.BorderSizePixel=0; ul.Visible=false
    local pg=Instance.new("Frame",CF); pg.Size=UDim2.new(1,0,1,0); pg.BackgroundTransparency=1; pg.Visible=false
    _pages[name]={btn=btn,ul=ul,pg=pg}
    btn.MouseButton1Click:Connect(function()
        if _curTab then _pages[_curTab].btn.TextColor3=C.dim; _pages[_curTab].ul.Visible=false; _pages[_curTab].pg.Visible=false end
        _curTab=name; btn.TextColor3=C.wht; ul.Visible=true; pg.Visible=true
    end)
    return pg
end

local PMain=MakeTab("Main",1); local PVis=MakeTab("Visuals",2); local PXray=MakeTab("Xray",3,C.blueH)
local PMisc=MakeTab("Misc",4); local PModes=MakeTab("Modos",5,C.tealH)
local PSettings=MakeTab("Settings",6)
_pages["Main"].btn.TextColor3=C.wht; _pages["Main"].ul.Visible=true; _pages["Main"].pg.Visible=true; _curTab="Main"

local AimP=Panel(PMain,"Aimbot",0,0,435,468); local FovP=Panel(PMain,"FOV Circle",443,0,435,215); local TrgP=Panel(PMain,"TriggerBot",443,223,435,185)
EnableBadge(AimP,0,"Aimbot","AIM",function() return Cfg.Aim.Aimbot end,function(v) Cfg.Aim.Aimbot=v end,"Aim")
Toggle(AimP,"Wall Check",1,function() return Cfg.Aim.WallCheck end,function(v) Cfg.Aim.WallCheck=v end)
Toggle(AimP,"Team Check",2,function() return Cfg.Aim.TeamCheck end,function(v) Cfg.Aim.TeamCheck=v end)
Toggle(AimP,"Prediction (Mira Preditiva)",3,function() return Cfg.Aim.Prediction end,function(v) Cfg.Aim.Prediction=v end)
Slider(AimP,"Prediction Strength",1,20,3,5,function(v) Cfg.Aim.PredStr=v end)
do local f=Instance.new("Frame",AimP); f.Size=UDim2.new(1,0,0,12); f.BackgroundTransparency=1; f.LayoutOrder=7; local l=Instance.new("TextLabel",f); l.Text="  ↑ maior = mais antecipação (ex: sniper)"; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left end
Sel(AimP,"Parte do Alvo",{"Head","HumanoidRootPart","Torso","UpperTorso","Neck"},"Head",8,function(v) Cfg.Aim.AimPart=v end)
Slider(AimP,"Suavidade (1=suave / 100=snap)",1,100,8,11,function(v) Cfg.Aim.Smoothness=v end)
do local f=Instance.new("Frame",AimP); f.Size=UDim2.new(1,0,0,12); f.BackgroundTransparency=1; f.LayoutOrder=13; local l=Instance.new("TextLabel",f); l.Text="  ↑ 1=mais suave · 100=snap imediato"; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left end
Slider(AimP,"Força do Aimbot (%)",1,100,70,15,function(v) Cfg.Aim.AimStrength=v end)
do local f=Instance.new("Frame",AimP); f.Size=UDim2.new(1,0,0,12); f.BackgroundTransparency=1; f.LayoutOrder=17; local l=Instance.new("TextLabel",f); l.Text="  ↑ 100=lock total · 1=assistência leve"; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left end
Sep(AimP,18); SL(AimP,"AUXÍLIOS DE MIRA",19)
Toggle(AimP,"No Recoil",20,function() return Cfg.Aim.NoRecoil end,function(v) Cfg.Aim.NoRecoil=v end)
Toggle(AimP,"Infinite Ammo",21,function() return Cfg.Aim.InfAmmo end,function(v)
    Cfg.Aim.InfAmmo=v
    if v then _HookChar(LP.Character) else
        for tool in pairs(_iaConns) do _UnhookTool(tool) end
    end
end)
KB(AimP,"Aim Key (segurar)",23,function() return Cfg.Aim.AimKeyName end,function(k,n) Cfg.Aim.AimKey=k; Cfg.Aim.AimKeyName=n end)
PLWidget(AimP,25,"LISTA DE EXCLUSÃO",Cfg.Aim.Blacklist)
Toggle(FovP,"Mostrar Círculo FOV",0,function() return Cfg.Aim.ShowFOV end,function(v) Cfg.Aim.ShowFOV=v; _fovLastVis=nil end)
Toggle(FovP,"Usar FOV no Aimbot",1,function() return Cfg.Aim.UseFOV end,function(v) Cfg.Aim.UseFOV=v end)
Toggle(FovP,"FOV Segue o Mouse",2,function() return Cfg.Aim.FOVFollow end,function(v) Cfg.Aim.FOVFollow=v; _fovLastCX=-1 end)
Slider(FovP,"Tamanho do FOV (px)",10,800,150,4,function(v) Cfg.Aim.FOV=v; _fovLastR=-1 end)
Slider(FovP,"Espessura da Linha",1,6,1,7,function(v)
    for _,ln in ipairs(_fovLines) do pcall(function() ln.Thickness=v end) end
end)
EnableBadge(TrgP,0,"TriggerBot","TRIG",function() return Cfg.Trigger.Enabled end,function(v) Cfg.Trigger.Enabled=v end)
Toggle(TrgP,"Team Check",1,function() return Cfg.Trigger.TeamCheck end,function(v) Cfg.Trigger.TeamCheck=v end)
Slider(TrgP,"Delay (ms)",0,1000,80,3,function(v) Cfg.Trigger.Delay=v end)
Sep(TrgP,5); SL(TrgP,"CLICK CONTROL",6)
Toggle(TrgP,"Click Control (múltiplos clicks)",7,function() return Cfg.Trigger.ClickControl end,function(v) Cfg.Trigger.ClickControl=v end,nil,C.orange)
Slider(TrgP,"Nº de Clicks por alvo",1,10,3,9,function(v) Cfg.Trigger.ClickCount=v end)
do local f=Instance.new("Frame",TrgP); f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.LayoutOrder=11
    local l=Instance.new("TextLabel",f); l.Text="Dispara N clicks ao detectar um alvo.\nSem Click Control = 1 click padrão."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Top end
Sep(TrgP,12); SL(TrgP,"ONE-SHOT",13,C.orange)
Toggle(TrgP,"One-Shot (1 tiro por lock)",14,function() return Cfg.Trigger.OneShot end,function(v)
    Cfg.Trigger.OneShot=v; _osShotReady=true; _osLastTgt=nil
end,nil,C.orange)
Slider(TrgP,"Delay entre tiros (s)",1,10,3,16,function(v) Cfg.Trigger.OneShotDelay=v end)
do local f=Instance.new("Frame",TrgP); f.Size=UDim2.new(1,0,0,30); f.BackgroundTransparency=1; f.LayoutOrder=18
    local l=Instance.new("TextLabel",f); l.Text="Ao travar num alvo: atira 1x e aguarda o delay.\nAo trocar de alvo, atira imediatamente."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Top end
Sep(TrgP,20); SL(TrgP,"AUTO AIMBOT",21)
Toggle(TrgP,"AutoBot (Aimbot automático)",22,function() return Cfg.Trigger.AutoBot end,function(v) Cfg.Trigger.AutoBot=v end)
do local f=Instance.new("Frame",TrgP); f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.LayoutOrder=24
    local l=Instance.new("TextLabel",f); l.Text="Mira automaticamente sem segurar tecla.\nUsa Wall/Team Check e FOV do Aimbot."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Top end

local EspP=Panel(PVis,"ESP",0,0,435,468); local TrackP=Panel(PVis,"Track Player",443,0,435,468)
EnableBadge(EspP,0,"ESP Enabled","ESP",function() return Cfg.ESP.Enabled end,function(v) Cfg.ESP.Enabled=v end,"ESP")
Toggle(EspP,"Box ESP",1,function() return Cfg.ESP.Box end,function(v) Cfg.ESP.Box=v end)
Toggle(EspP,"Fill Box",2,function() return Cfg.ESP.Fill end,function(v) Cfg.ESP.Fill=v end)
Toggle(EspP,"Name ESP",3,function() return Cfg.ESP.Names end,function(v) Cfg.ESP.Names=v end)
Toggle(EspP,"Health Bar",4,function() return Cfg.ESP.HP end,function(v) Cfg.ESP.HP=v end)
Toggle(EspP,"Tracers",5,function() return Cfg.ESP.Tracers end,function(v) Cfg.ESP.Tracers=v end)
Toggle(EspP,"Distance",6,function() return Cfg.ESP.Dist end,function(v) Cfg.ESP.Dist=v end)
Toggle(EspP,"Wall Check",7,function() return Cfg.ESP.WallCheck end,function(v) Cfg.ESP.WallCheck=v end)
Toggle(EspP,"Team Check",8,function() return Cfg.ESP.TeamCheck end,function(v) Cfg.ESP.TeamCheck=v end)
Toggle(EspP,"Item na Mão",9,function() return Cfg.ESP.HeldTool end,function(v) Cfg.ESP.HeldTool=v end)
Slider(EspP,"Distância Máxima",50,2000,500,11,function(v) Cfg.ESP.MaxDist=v end)
do
    local rb=PLWidget(TrackP,0,"JOGADORES RASTREADOS",Cfg.ESP.TrackList)
    Sep(TrackP,6); SL(TrackP,"SERVIDOR",7)
    local onlS=Instance.new("ScrollingFrame",TrackP); onlS.Size=UDim2.new(1,0,0,200); onlS.BackgroundColor3=C.bg4; onlS.BorderSizePixel=0; onlS.LayoutOrder=8; Instance.new("UICorner",onlS).CornerRadius=UDim.new(0,4); onlS.ScrollBarThickness=2; onlS.ScrollBarImageColor3=C.red; onlS.CanvasSize=UDim2.new(0,0,0,0); onlS.AutomaticCanvasSize=Enum.AutomaticSize.Y
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
                else Cfg.ESP.TrackList[cap.Name]=true; tB.BackgroundColor3=C.red; tB.Text="Untrack" end; rb()
            end)
        end
    end
    Btn(TrackP,"↺ Atualizar Lista",9,RefOnl); RefOnl()
end

local XrayP=Panel(PXray,"Xray (Wallhack)",0,0,435,468,C.blue); local SkelP=Panel(PXray,"Skeleton",443,0,435,280,C.blue)
EnableBadge(XrayP,0,"Xray Enabled","XRAY",function() return Cfg.Xray.Enabled end,function(v) Cfg.Xray.Enabled=v end,"Xray",C.blue)
Toggle(XrayP,"Box ESP",1,function() return Cfg.Xray.Box end,function(v) Cfg.Xray.Box=v end,nil,C.blueH)
Toggle(XrayP,"Fill Box",2,function() return Cfg.Xray.Fill end,function(v) Cfg.Xray.Fill=v end,nil,C.blueH)
Toggle(XrayP,"Name ESP",3,function() return Cfg.Xray.Names end,function(v) Cfg.Xray.Names=v end,nil,C.blueH)
Toggle(XrayP,"Health Bar",4,function() return Cfg.Xray.HP end,function(v) Cfg.Xray.HP=v end,nil,C.blueH)
Toggle(XrayP,"Tracers",5,function() return Cfg.Xray.Tracers end,function(v) Cfg.Xray.Tracers=v end,nil,C.blueH)
Toggle(XrayP,"Distance",6,function() return Cfg.Xray.Dist end,function(v) Cfg.Xray.Dist=v end,nil,C.blueH)
Toggle(XrayP,"Team Check",7,function() return Cfg.Xray.TeamCheck end,function(v) Cfg.Xray.TeamCheck=v end,nil,C.blueH)
Slider(XrayP,"Distância Máxima",50,5000,1000,9,function(v) Cfg.Xray.MaxDist=v end)
Toggle(SkelP,"Skeleton",0,function() return Cfg.Xray.Skeleton end,function(v) Cfg.Xray.Skeleton=v end,nil,C.blueH)
do local f=Instance.new("Frame",SkelP); f.Size=UDim2.new(1,0,0,32); f.BackgroundTransparency=1; f.LayoutOrder=2; local l=Instance.new("TextLabel",f); l.Text="Detecta rig R15/R6 automaticamente.\nFunciona apenas com Xray ativo."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Top end

local MovP=Panel(PMisc,"Movimento & Física",0,0,435,468); local UtilP=Panel(PMisc,"Utilidades & Server",443,0,435,468)
SL(MovP,"VOAR",0)
Toggle(MovP,"Fly",1,function() return Cfg.Misc.Fly end,function(v) Cfg.Misc.Fly=v; if v then EnableFly() else DisableFly() end end,"Fly")
Toggle(MovP,"Fly Boost (3x)",2,function() return Cfg.Misc.FlyBoost end,function(v) Cfg.Misc.FlyBoost=v end)
Slider(MovP,"Fly Speed",1,500,50,3,function(v) Cfg.Misc.FlySpeed=v end)
Sep(MovP,5); SL(MovP,"MOVIMENTO",6)
Toggle(MovP,"Noclip",7,function() return Cfg.Misc.Noclip end,function(v) Cfg.Misc.Noclip=v; if v then EnableNoclip() else DisableNoclip() end end,"NC")
Toggle(MovP,"Speed Hack",9,function() return Cfg.Misc.Speed end,function(v) Cfg.Misc.Speed=v; ApplySpeed() end,"Speed")
Slider(MovP,"Walk Speed",1,1000,25,11,function(v) Cfg.Misc.WalkSpeed=v; if Cfg.Misc.Speed then ApplySpeed() end end)
Toggle(MovP,"Always Sprint",13,function() return Cfg.Misc.AlwaysSprint end,function(v) Cfg.Misc.AlwaysSprint=v end)
Sep(MovP,15); SL(MovP,"PULO",16)
Toggle(MovP,"Jump Modifier",17,function() return Cfg.Misc.JumpMod end,function(v) Cfg.Misc.JumpMod=v; ApplyJump() end)
Toggle(MovP,"Infinite Jump",18,function() return Cfg.Misc.InfJump end,function(v) Cfg.Misc.InfJump=v end)
Slider(MovP,"Jump Power",1,500,80,20,function(v) Cfg.Misc.JumpPower=v; if Cfg.Misc.JumpMod then ApplyJump() end end)
Sep(MovP,23); SL(MovP,"CÂMERA",24)
Toggle(MovP,"Terceira Pessoa",25,function() return Cfg.Misc.ThirdPerson end,function(v) Cfg.Misc.ThirdPerson=v; if v then EnableThirdPerson() else DisableThirdPerson() end end)
Slider(MovP,"Distância 3ª Pessoa",2,30,8,27,function(v) Cfg.Misc.ThirdPersonDist=v end)
Toggle(MovP,"FreeCam",29,function() return Cfg.Misc.FreeCam end,function(v) Cfg.Misc.FreeCam=v; if v then EnableFreeCam() else DisableFreeCam() end end,"FC")
Slider(MovP,"FreeCam Speed",1,30,1,31,function(v) Cfg.Misc.FCamSpeed=v end)
Sep(MovP,33); SL(MovP,"OUTROS",34)
Toggle(MovP,"Anti Ragdoll",35,function() return Cfg.Misc.AntiRag end,function(v) Cfg.Misc.AntiRag=v end)
Toggle(MovP,"Click Teleport",36,function() return Cfg.Misc.ClickTp end,function(v) Cfg.Misc.ClickTp=v end)
Toggle(MovP,"Anti-AFK",37,function() return Cfg.Misc.AntiAFK end,function(v) Cfg.Misc.AntiAFK=v end)
SL(UtilP,"HITBOX",0)
Toggle(UtilP,"Hitbox Extender",1,function() return Cfg.Misc.HitboxExtender end,function(v) Cfg.Misc.HitboxExtender=v; RefreshHitboxes() end)
Slider(UtilP,"Hitbox Size",1,80,8,3,function(v) Cfg.Misc.HitboxSize=v; if Cfg.Misc.HitboxExtender then RefreshHitboxes() end end)
Sel(UtilP,"Parte da Hitbox",{"All","Head","Torso","Arms","Legs","HRP"},"All",5,function(v) Cfg.Misc.HitboxPart=v; if Cfg.Misc.HitboxExtender then RefreshHitboxes() end end)
Sep(UtilP,8); SL(UtilP,"TOOLS DO MAPA",9)
do
    local gs=StatusLbl(UtilP,10)
    local tlH=Instance.new("Frame",UtilP); tlH.Size=UDim2.new(1,0,0,100); tlH.BackgroundColor3=C.bg4; tlH.BorderSizePixel=0; tlH.LayoutOrder=11; Instance.new("UICorner",tlH).CornerRadius=UDim.new(0,4)
    local tlS=Instance.new("ScrollingFrame",tlH); tlS.Size=UDim2.new(1,-8,1,-8); tlS.Position=UDim2.new(0,4,0,4); tlS.BackgroundTransparency=1; tlS.BorderSizePixel=0; tlS.ScrollBarThickness=2; tlS.ScrollBarImageColor3=C.red; tlS.CanvasSize=UDim2.new(0,0,0,0); tlS.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",tlS).Padding=UDim.new(0,2)
    local function RefTools()
        for _,c in ipairs(tlS:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        local tools=GetMapTools()
        if #tools==0 then local el=Instance.new("TextLabel",tlS); el.Text="(nenhuma)"; el.Size=UDim2.new(1,0,0,18); el.BackgroundTransparency=1; el.TextColor3=C.dim; el.Font=FM; el.TextSize=11; el.TextXAlignment=Enum.TextXAlignment.Left; return end
        for _,entry in ipairs(tools) do
            local row=Instance.new("Frame",tlS); row.Size=UDim2.new(1,0,0,24); row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
            local nl=Instance.new("TextLabel",row); nl.Text="🔧 "..entry.name; nl.Size=UDim2.new(1,-60,1,0); nl.Position=UDim2.new(0,6,0,0); nl.BackgroundTransparency=1; nl.TextColor3=C.text; nl.Font=FM; nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left
            local gb=Instance.new("TextButton",row); gb.Text="Pegar"; gb.Size=UDim2.new(0,52,0,18); gb.Position=UDim2.new(1,-55,0.5,-9); gb.BackgroundColor3=C.red; gb.TextColor3=C.wht; gb.Font=FB; gb.TextSize=10; gb.BorderSizePixel=0; Instance.new("UICorner",gb).CornerRadius=UDim.new(0,3)
            local cap=entry.tool
            gb.MouseButton1Click:Connect(function()
                gs("⏳ Tentando...", C.orange)
                task.spawn(function()
                    local ok = _TryGrab(cap)
                    gs(ok and "✓ "..entry.name or "❌ Falhou / Bloqueado", ok and C.green or C.redH)
                end)
            end)
        end
    end
    Btn(UtilP,"🔧 Pegar Mais Próxima",12,function()
    gs("⏳ Tentando...", C.orange)
    task.spawn(function()
        local n=GrabNearestTool()
        gs(n and "✓ "..n or "❌ Nenhuma / Não pegável", n and C.green or C.redH)
    end)
end,Color3.fromRGB(20,50,20))
    Btn(UtilP,"↺ Listar Tools do Mapa",13,RefTools,Color3.fromRGB(12,35,55),C.blueH)
end
Sep(UtilP,15); SL(UtilP,"INFINITE YIELD",16)

local btn = Instance.new("TextButton")
btn.Parent = UtilP
btn.Size = UDim2.new(1,0,0,28)
btn.LayoutOrder = 17
btn.Text = "Executar Infinite Yield"
btn.BackgroundColor3 = Color3.fromRGB(14,52,14)
btn.TextColor3 = C.green
btn.Font = FB
btn.TextSize = 12
btn.BorderSizePixel = 0
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
btn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

Sep(UtilP,22); SL(UtilP,"TOOL DUPLICATOR",23)
IFld(UtilP,"Nome da Tool...",24,function(v) Cfg.Misc.DupeToolName=v end)
Btn(UtilP,"Duplicar Tool",26,DupeTool)
Sep(UtilP,28); SL(UtilP,"SERVER",29)
Btn(UtilP,"🔄 Rejoin",30,Rejoin,Color3.fromRGB(10,10,55),C.blueH)
Btn(UtilP,"🌐 Server Hop",32,ServerHop,Color3.fromRGB(10,40,10),C.green)

local Md1=Panel(PModes,"Modos de Movimento",0,0,435,300,C.teal); local Md2=Panel(PModes,"Sobre os Modos",443,0,435,300,C.teal)
SL(Md1,"🌊  AQUAMAN",0,C.tealH)
Toggle(Md1,"Modo Aquaman",1,function() return Cfg.Modes.Aquaman end,function(v) Cfg.Modes.Aquaman=v end,nil,C.teal)
do local f=Instance.new("Frame",Md1); f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.LayoutOrder=3; local l=Instance.new("TextLabel",f); l.Text="Impede afogamento regenerando HP ao nadar."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left end
Sep(Md1,4); SL(Md1,"🪂  SEM DANO DE QUEDA",5,C.tealH)
Toggle(Md1,"Anti Queda (No Fall Damage)",6,function() return Cfg.Modes.NoFallDmg end,function(v) Cfg.Modes.NoFallDmg=v end,nil,C.teal)
do local f=Instance.new("Frame",Md1); f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.LayoutOrder=8; local l=Instance.new("TextLabel",f); l.Text="Restaura HP perdido por queda (client-side)."; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left end
do
    local infos={{"🌊 Aquaman","Ao nadar, regenera HP continuamente e desabilita scripts de afogamento do jogo."},{"🪂 Anti Queda","Salva o HP antes de cair e restaura se houve queda brusca ao aterrissar."},{"⚠️ Aviso","Funções client-side. Servidores com anti-cheat podem reverter efeitos."}}
    local order=0
    for _,info in ipairs(infos) do
        SL(Md2,info[1],order,C.tealH); order=order+1
        local f=Instance.new("Frame",Md2); f.Size=UDim2.new(1,0,0,30); f.BackgroundTransparency=1; f.LayoutOrder=order
        local l=Instance.new("TextLabel",f); l.Text=info[2]; l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=C.dim; l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Top
        order=order+2
    end
end

local KbP=Panel(PSettings,"Teclas de Atalho",0,0,435,468); local CfgP=Panel(PSettings,"Configurações & Saves",443,0,290,468); local LogP=Panel(PSettings,"Chat Log",737,0,175,468)
KB(KbP,"Toggle GUI",0,function() return Cfg.Settings.ToggleKeyName end,function(k,n) Cfg.Settings.ToggleKey=k; Cfg.Settings.ToggleKeyName=n end)
KB(KbP,"ESP On/Off",2,function() return Cfg.Settings.ESPKeyName end,function(k,n) Cfg.Settings.ESPKey=k; Cfg.Settings.ESPKeyName=n end)
KB(KbP,"Aimbot On/Off",4,function() return Cfg.Settings.AimbotKeyName end,function(k,n) Cfg.Settings.AimbotKey=k; Cfg.Settings.AimbotKeyName=n end)
KB(KbP,"Fly On/Off",6,function() return Cfg.Settings.FlyKeyName end,function(k,n) Cfg.Settings.FlyKey=k; Cfg.Settings.FlyKeyName=n end)
KB(KbP,"Noclip On/Off",8,function() return Cfg.Settings.NoclipKeyName end,function(k,n) Cfg.Settings.NoclipKey=k; Cfg.Settings.NoclipKeyName=n end)
KB(KbP,"Speed On/Off",10,function() return Cfg.Settings.SpeedKeyName end,function(k,n) Cfg.Settings.SpeedKey=k; Cfg.Settings.SpeedKeyName=n end)
KB(KbP,"Xray On/Off",12,function() return Cfg.Settings.XrayKeyName end,function(k,n) Cfg.Settings.XrayKey=k; Cfg.Settings.XrayKeyName=n end)
KB(KbP,"FreeCam On/Off",14,function() return Cfg.Settings.FreeCamKeyName end,function(k,n) Cfg.Settings.FreeCamKey=k; Cfg.Settings.FreeCamKeyName=n end)
KB(KbP,"Aim Key (segurar)",16,function() return Cfg.Aim.AimKeyName end,function(k,n) Cfg.Aim.AimKey=k; Cfg.Aim.AimKeyName=n end)
Sep(KbP,18); SL(KbP,"🫥  TELAGEM BYPASS",19,C.orange)
Toggle(KbP,"Ativar Telagem Bypass",20,
    function() return Cfg.Settings.BypassEnabled end,
    function(v)
        Cfg.Settings.BypassEnabled=v
        -- se desabilitar e bypass estava ativo, restaura
        if not v and _bypassActive then
            _bypassActive=false; ApplyBypass(false)
        end
    end, nil, C.orange)
KB(KbP,"Bypass Key (toggle)",22,
    function() return Cfg.Settings.BypassKeyName end,
    function(k,n) Cfg.Settings.BypassKey=k; Cfg.Settings.BypassKeyName=n end)
do
    local f=Instance.new("Frame",KbP); f.Size=UDim2.new(1,0,0,42); f.BackgroundColor3=Color3.fromRGB(28,18,6); f.BorderSizePixel=0; f.LayoutOrder=24; Instance.new("UICorner",f).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",f).Color=Color3.fromRGB(80,50,10)
    local l=Instance.new("TextLabel",f); l.Text="🫥  Quando ativado, pressionar a Bypass Key esconde\na GUI e os drawings (ESP/FOV) instantaneamente.\nPressione novamente para restaurar tudo."; l.Size=UDim2.new(1,-12,1,0); l.Position=UDim2.new(0,6,0,0); l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(180,130,50); l.Font=FM; l.TextSize=10; l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextYAlignment=Enum.TextYAlignment.Center
end
-- botão de teste rápido
local _bypassBtnLbl = "🫥  Testar Bypass (toggle)"
local bypassTestBtn = Btn(KbP, _bypassBtnLbl, 26, function()
    if not Cfg.Settings.BypassEnabled then return end
    _bypassActive = not _bypassActive
    ApplyBypass(_bypassActive)
end, Color3.fromRGB(30,20,6), C.orange)
SL(CfgP,"SAVES",0)
local svSt=StatusLbl(CfgP,1)
local svBox=IFld(CfgP,"Nome do save...",2,function() end)
local function GSN() return svBox and svBox.Text~="" and svBox.Text or "default" end
Btn(CfgP,"💾 Salvar",4,function() local ok,i=SaveCfg(GSN()); svSt(ok and "✓ "..i or "❌ "..tostring(i),ok and C.green or C.redH) end,Color3.fromRGB(10,50,10))
Btn(CfgP,"📂 Carregar",6,function() local ok,i=LoadCfg(GSN()); svSt(ok and "✓ Carregado" or "❌ "..tostring(i),ok and C.green or C.redH) end,Color3.fromRGB(20,34,8))
Btn(CfgP,"🗑 Deletar",8,function() svSt(DelCfg(GSN()) and "✓ Deletado" or "❌ delfile indisponível",C.orange) end,Color3.fromRGB(46,10,4))
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
Sep(CfgP,15); SL(CfgP,"CRÉDITOS",16)
IL(CfgP,"SCRIPT POR BRUNO223J AND TY",17,C.gold)
IL(CfgP,"DISCORD: .223j  |  frty2017",18,C.gold)
IL(CfgP,"REVOLUCIONARI'US GROUP  ·  v1.0 RELEASE 🔴",19,C.wht)
IL(CfgP,"Toggle: [;] · Arrastar pela topbar",20,C.dim)
Sep(CfgP,21); SL(CfgP,"REMOVER SCRIPT",22,C.red)
Btn(CfgP,"🗑 Desligar & Remover Tudo",23,function()
    Cfg.Aim.Aimbot=false; Cfg.ESP.Enabled=false; Cfg.Xray.Enabled=false
    Cfg.Misc.Fly=false; Cfg.Misc.Noclip=false; Cfg.Misc.Speed=false; Cfg.Misc.FreeCam=false
    Cfg.Misc.ThirdPerson=false; Cfg.Misc.SpinBot=false
    Cfg.Modes.Aquaman=false; Cfg.Modes.NoFallDmg=false
    DisableFly(); DisableNoclip(); DisableFreeCam(); DisableThirdPerson()
    if _bypassActive then _bypassActive=false; ApplyBypass(false) end
    for tool in pairs(_iaConns) do _UnhookTool(tool) end
    for p,_ in pairs(ESPO) do KillESP(p) end
    for _,ln in ipairs(_fovLines) do pcall(function() ln:Remove() end) end
    local char=LP.Character; if char then
        local h=char:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=16; h.JumpPower=50; h.PlatformStand=false end
    end
    task.wait(0.1); if SG and SG.Parent then SG:Destroy() end
    print("[223HUB v1.0 RELEASE] Removido com sucesso.")
end,Color3.fromRGB(80,8,8),C.redH)

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

print("[223HUB v1.0 RELEASE] ✓ LOADED | BRUNO223J & TY | .223j | frty2017 | Toggle=[;]")

end -- fim de _223HUB_MAIN()
