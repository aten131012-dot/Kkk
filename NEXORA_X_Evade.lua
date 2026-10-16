-- NEXORA X Evade | Dashboard + Thai/English language support
-- Tema Atual Configurável | Keybind Customizável (K) | Save System (JSON)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local function GetSafeParent()
    local success, parent = pcall(function()
        if gethui then 
            return gethui()
        elseif syn and syn.protect_gui then
            local sg = Instance.new("ScreenGui")
            syn.protect_gui(sg)
            return sg
        else 
            return CoreGui 
        end
    end)
    if success and parent then 
        return parent 
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local TargetParent = GetSafeParent()

pcall(function()
    if TargetParent:FindFirstChild("NEXORAXEvadeUI") then TargetParent.NEXORAXEvadeUI:Destroy() end
    if TargetParent:FindFirstChild("RTSpriteSuiteUI") then TargetParent.RTSpriteSuiteUI:Destroy() end
    pcall(function() if LocalPlayer.PlayerGui:FindFirstChild("NEXORAXEvadeUI") then LocalPlayer.PlayerGui.NEXORAXEvadeUI:Destroy() end end)
end)

local ScriptActive = true
local Connections = {}
local OriginalMaterials = {}

-- Guardar iluminação original de forma segura
local OriginalLighting = {
    Brightness = game.Lighting.Brightness,
    OutdoorAmbient = game.Lighting.OutdoorAmbient,
    Ambient = game.Lighting.Ambient,
    GlobalShadows = game.Lighting.GlobalShadows,
    FogEnd = game.Lighting.FogEnd,
    FogStart = game.Lighting.FogStart
}

local State = {
    ValueSpeed = 16,
    ActiveCFrameSpeedBoost = false,
    JumpBoost = false,
    JumpPowerValue = 50,
    InfiniteJump = false,
    Noclip = false,
    GravityValue = 196.2,
    BhopEnabled = false,
    IsHoldingJump = false,
    SelectedMapNumber = 1,
    AutoVoteEnabled = false,
    AutoReviveEnabled = false,
    ActiveEspPlayers = false,
    ActiveEspBots = false,
    ActiveDistanceEsp = false,
    ActiveTracerEsp = false,
    CustomFOVValue = 70,
    ActiveFOV = false,
    BotProximityAlert = true,
    AntiAFK = true,
    FullBright = false,
    SuperFullBright = false,
    NoFog = false,
    FPSBoost = false,
    ToggleKey = Enum.KeyCode.K,
    WaitingForKeybind = false,
    CurrentTheme = "Halloween Orange",
    SelectedSpectatePlayer = nil,
    BloomShader = false,
    BlurShader = false
}

-- SISTEMA DE CONFIGURAÇÕES (SAVE & LOAD CONFIGS ROBUSTO)
local ConfigFileName = "RTSpriteSuite_EvadeConfig.json"

local function SaveConfig()
    pcall(function()
        if writefile and HttpService then
            local saveData = {
                ValueSpeed = State.ValueSpeed,
                JumpPowerValue = State.JumpPowerValue,
                GravityValue = State.GravityValue,
                CustomFOVValue = State.CustomFOVValue,
                CurrentTheme = State.CurrentTheme,
                ToggleKey = tostring(State.ToggleKey.Name),
                BloomShader = State.BloomShader,
                BlurShader = State.BlurShader,
                AntiAFK = State.AntiAFK,
                BotProximityAlert = State.BotProximityAlert
            }
            writefile(ConfigFileName, HttpService:JSONEncode(saveData))
            print("[RT] Configurações salvas com sucesso em: " .. ConfigFileName)
        else
            warn("[RT] writefile não suportado pelo executor!")
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if readfile and isfile and isfile(ConfigFileName) and HttpService then
            local content = readfile(ConfigFileName)
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if success and decoded then
                if decoded.ValueSpeed then State.ValueSpeed = decoded.ValueSpeed end
                if decoded.JumpPowerValue then State.JumpPowerValue = decoded.JumpPowerValue end
                if decoded.GravityValue then State.GravityValue = decoded.GravityValue Workspace.Gravity = decoded.GravityValue end
                if decoded.CustomFOVValue then State.CustomFOVValue = decoded.CustomFOVValue end
                if decoded.CurrentTheme then State.CurrentTheme = decoded.CurrentTheme end
                if decoded.ToggleKey then 
                    pcall(function() State.ToggleKey = Enum.KeyCode[decoded.ToggleKey] end)
                end
                if decoded.BloomShader ~= nil then State.BloomShader = decoded.BloomShader end
                if decoded.BlurShader ~= nil then State.BlurShader = decoded.BlurShader end
                if decoded.AntiAFK ~= nil then State.AntiAFK = decoded.AntiAFK end
                if decoded.BotProximityAlert ~= nil then State.BotProximityAlert = decoded.BotProximityAlert end
                print("[RT] Configurações carregadas com sucesso!")
            end
        else
            print("[RT] Nenhum arquivo de configuração encontrado. Usando padrões.")
        end
    end)
end

LoadConfig()

-- SISTEMA DE TEMAS EXPANDIDO (RT THEMES)
local Themes = {
    ["Halloween Orange"] = {
        Background = Color3.fromRGB(12, 8, 5),
        TopBar = Color3.fromRGB(22, 14, 8),
        Sidebar = Color3.fromRGB(17, 11, 6),
        Card = Color3.fromRGB(30, 19, 10),
        CardHover = Color3.fromRGB(50, 32, 18),
        Purple = Color3.fromRGB(249, 115, 22),
        PurpleBright = Color3.fromRGB(251, 146, 60),
        PurpleDark = Color3.fromRGB(154, 52, 18),
        PurpleGlow = Color3.fromRGB(234, 88, 12),
        Text = Color3.fromRGB(255, 247, 237),
        TextDim = Color3.fromRGB(180, 150, 130),
        Border = Color3.fromRGB(124, 45, 18),
        Stroke = Color3.fromRGB(249, 115, 22),
    },
    ["Neon Purple"] = {
        Background = Color3.fromRGB(8, 7, 12),
        TopBar = Color3.fromRGB(13, 11, 20),
        Sidebar = Color3.fromRGB(10, 9, 16),
        Card = Color3.fromRGB(18, 15, 28),
        CardHover = Color3.fromRGB(36, 28, 54),
        Purple = Color3.fromRGB(178, 75, 255),
        PurpleBright = Color3.fromRGB(202, 122, 255),
        PurpleDark = Color3.fromRGB(75, 25, 125),
        PurpleGlow = Color3.fromRGB(150, 40, 240),
        Text = Color3.fromRGB(245, 245, 250),
        TextDim = Color3.fromRGB(140, 135, 165),
        Border = Color3.fromRGB(48, 35, 75),
        Stroke = Color3.fromRGB(115, 45, 195),
    },
    ["Cyber Cyan"] = {
        Background = Color3.fromRGB(7, 10, 14),
        TopBar = Color3.fromRGB(11, 16, 24),
        Sidebar = Color3.fromRGB(9, 13, 19),
        Card = Color3.fromRGB(15, 23, 36),
        CardHover = Color3.fromRGB(28, 42, 66),
        Purple = Color3.fromRGB(6, 182, 212),
        PurpleBright = Color3.fromRGB(34, 211, 238),
        PurpleDark = Color3.fromRGB(14, 116, 144),
        PurpleGlow = Color3.fromRGB(8, 145, 178),
        Text = Color3.fromRGB(240, 253, 250),
        TextDim = Color3.fromRGB(133, 175, 189),
        Border = Color3.fromRGB(22, 78, 99),
        Stroke = Color3.fromRGB(8, 145, 178),
    },
    ["Blood Crimson"] = {
        Background = Color3.fromRGB(12, 7, 8),
        TopBar = Color3.fromRGB(20, 11, 13),
        Sidebar = Color3.fromRGB(16, 9, 10),
        Card = Color3.fromRGB(28, 16, 19),
        CardHover = Color3.fromRGB(50, 28, 33),
        Purple = Color3.fromRGB(239, 68, 68),
        PurpleBright = Color3.fromRGB(248, 113, 113),
        PurpleDark = Color3.fromRGB(153, 27, 27),
        PurpleGlow = Color3.fromRGB(220, 38, 38),
        Text = Color3.fromRGB(254, 242, 242),
        TextDim = Color3.fromRGB(180, 140, 142),
        Border = Color3.fromRGB(127, 29, 29),
        Stroke = Color3.fromRGB(185, 28, 28),
    },
    ["Matrix Emerald"] = {
        Background = Color3.fromRGB(6, 12, 8),
        TopBar = Color3.fromRGB(10, 20, 13),
        Sidebar = Color3.fromRGB(8, 16, 10),
        Card = Color3.fromRGB(14, 30, 18),
        CardHover = Color3.fromRGB(24, 52, 31),
        Purple = Color3.fromRGB(34, 197, 94),
        PurpleBright = Color3.fromRGB(74, 222, 128),
        PurpleDark = Color3.fromRGB(20, 83, 45),
        PurpleGlow = Color3.fromRGB(22, 163, 74),
        Text = Color3.fromRGB(240, 253, 244),
        TextDim = Color3.fromRGB(134, 175, 148),
        Border = Color3.fromRGB(22, 101, 52),
        Stroke = Color3.fromRGB(21, 128, 61),
    },
    ["Sunset Gold"] = {
        Background = Color3.fromRGB(14, 10, 6),
        TopBar = Color3.fromRGB(22, 16, 10),
        Sidebar = Color3.fromRGB(18, 13, 8),
        Card = Color3.fromRGB(32, 23, 13),
        CardHover = Color3.fromRGB(56, 40, 22),
        Purple = Color3.fromRGB(245, 158, 11),
        PurpleBright = Color3.fromRGB(251, 191, 36),
        PurpleDark = Color3.fromRGB(180, 83, 9),
        PurpleGlow = Color3.fromRGB(217, 119, 6),
        Text = Color3.fromRGB(254, 243, 199),
        TextDim = Color3.fromRGB(180, 155, 120),
        Border = Color3.fromRGB(146, 64, 14),
        Stroke = Color3.fromRGB(202, 138, 4),
    },
    ["Royal Amethyst"] = {
        Background = Color3.fromRGB(10, 6, 14),
        TopBar = Color3.fromRGB(16, 10, 22),
        Sidebar = Color3.fromRGB(13, 8, 18),
        Card = Color3.fromRGB(24, 15, 34),
        CardHover = Color3.fromRGB(44, 28, 62),
        Purple = Color3.fromRGB(216, 180, 254),
        PurpleBright = Color3.fromRGB(233, 213, 255),
        PurpleDark = Color3.fromRGB(107, 33, 168),
        PurpleGlow = Color3.fromRGB(147, 51, 234),
        Text = Color3.fromRGB(250, 245, 255),
        TextDim = Color3.fromRGB(175, 155, 195),
        Border = Color3.fromRGB(88, 28, 135),
        Stroke = Color3.fromRGB(168, 85, 247),
    },
    ["Dark Midnight"] = {
        Background = Color3.fromRGB(10, 10, 10),
        TopBar = Color3.fromRGB(18, 18, 18),
        Sidebar = Color3.fromRGB(14, 14, 14),
        Card = Color3.fromRGB(24, 24, 24),
        CardHover = Color3.fromRGB(45, 45, 45),
        Purple = Color3.fromRGB(255, 255, 255),
        PurpleBright = Color3.fromRGB(240, 240, 240),
        PurpleDark = Color3.fromRGB(60, 60, 60),
        PurpleGlow = Color3.fromRGB(150, 150, 150),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(160, 160, 160),
        Border = Color3.fromRGB(60, 60, 60),
        Stroke = Color3.fromRGB(100, 100, 100),
    }
}

local Colors = Themes[State.CurrentTheme]

-- GUI PRINCIPAL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NEXORAXEvadeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = TargetParent

-- JANELA PRINCIPAL (DECLARADA ANTES PARA COMEÇAR OCULTA DURANTE O LOAD)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 640, 0, 430)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -215)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false -- Começa oculto para não aparecer na tela de load!
MainFrame.Parent = ScreenGui

-- TELA DE INICIALIZAÇÃO (LOADING SCREEN PREMIUM E ELEGANTE)
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "RT_LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.BackgroundColor3 = Color3.fromRGB(3, 2, 5)
LoadingScreen.BackgroundTransparency = 0.1
LoadingScreen.BorderSizePixel = 0
LoadingScreen.ZIndex = 10
LoadingScreen.Parent = ScreenGui

-- Blur de fundo na tela de carregamento se possível
pcall(function()
    local loadBlur = Instance.new("BlurEffect", game:GetService("Lighting"))
    loadBlur.Name = "RT_LoadBlur"
    loadBlur.Size = 15
    task.spawn(function()
        task.wait(1.8)
        TweenService:Create(loadBlur, TweenInfo.new(0.6), {Size = 0}):Play()
        task.wait(0.6)
        loadBlur:Destroy()
    end)
end)

local LoadCenterBox = Instance.new("Frame", LoadingScreen)
LoadCenterBox.Size = UDim2.new(0, 360, 0, 210)
LoadCenterBox.Position = UDim2.new(0.5, -180, 0.5, -105)
LoadCenterBox.BackgroundColor3 = Color3.fromRGB(14, 10, 18)
LoadCenterBox.BorderSizePixel = 0
Instance.new("UICorner", LoadCenterBox).CornerRadius = UDim.new(0, 18)

local LoadStroke = Instance.new("UIStroke", LoadCenterBox)
LoadStroke.Color = Colors.Purple
LoadStroke.Transparency = 0.2
LoadStroke.Thickness = 2

local LoadGlow = Instance.new("ImageLabel", LoadCenterBox)
LoadGlow.Size = UDim2.new(1, 60, 1, 60)
LoadGlow.Position = UDim2.new(0, -30, 0, -30)
LoadGlow.BackgroundTransparency = 1
LoadGlow.Image = "rbxassetid://5028857084"
LoadGlow.ImageColor3 = Colors.PurpleGlow
LoadGlow.ImageTransparency = 0.6
LoadGlow.ScaleType = Enum.ScaleType.Slice
LoadGlow.SliceCenter = Rect.new(24,24,276,276)
LoadGlow.ZIndex = -1

local LoadTitle = Instance.new("TextLabel", LoadCenterBox)
LoadTitle.Size = UDim2.new(1, 0, 0, 36)
LoadTitle.Position = UDim2.new(0, 0, 0, 24)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "NEXORA X Evade"
LoadTitle.TextColor3 = Colors.PurpleBright
LoadTitle.TextSize = 26
LoadTitle.Font = Enum.Font.GothamBold

local LoadSub = Instance.new("TextLabel", LoadCenterBox)
LoadSub.Size = UDim2.new(1, 0, 0, 24)
LoadSub.Position = UDim2.new(0, 0, 0, 62)
LoadSub.BackgroundTransparency = 1
LoadSub.Text = "Loading NEXORA X Evade..."
LoadSub.TextColor3 = Colors.TextDim
LoadSub.TextSize = 12
LoadSub.Font = Enum.Font.Gotham

-- Porcentagem numérica de load
local PercentLabel = Instance.new("TextLabel", LoadCenterBox)
PercentLabel.Size = UDim2.new(1, 0, 0, 20)
PercentLabel.Position = UDim2.new(0, 0, 0, 92)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Text = "0%"
PercentLabel.TextColor3 = Colors.Text
PercentLabel.TextSize = 12
PercentLabel.Font = Enum.Font.GothamBold

local LoadBarTrack = Instance.new("Frame", LoadCenterBox)
LoadBarTrack.Size = UDim2.new(0, 290, 0, 8)
LoadBarTrack.Position = UDim2.new(0.5, -145, 0, 135)
LoadBarTrack.BackgroundColor3 = Color3.fromRGB(24, 18, 32)
LoadBarTrack.BorderSizePixel = 0
Instance.new("UICorner", LoadBarTrack).CornerRadius = UDim.new(1, 0)

local LoadBarFill = Instance.new("Frame", LoadBarTrack)
LoadBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadBarFill.BackgroundColor3 = Colors.Purple
LoadBarFill.BorderSizePixel = 0
Instance.new("UICorner", LoadBarFill).CornerRadius = UDim.new(1, 0)

local LoadBarGlow = Instance.new("UIStroke", LoadBarFill)
LoadBarGlow.Color = Colors.PurpleBright
LoadBarGlow.Transparency = 0.5
LoadBarGlow.Thickness = 1

-- Animação da tela de carregamento fluida com contador (e mostra o menu principal ao terminar)
task.spawn(function()
    local tweenInfo = TweenInfo.new(1.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(LoadBarFill, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
    
    for i = 1, 100 do
        PercentLabel.Text = i .. "%"
        if i < 40 then
            LoadSub.Text = "Initializing NEXORA X Evade..."
        elseif i < 75 then
            LoadSub.Text = "Loading interface modules..."
        else
            LoadSub.Text = "Finishing interface..."
        end
        task.wait(0.014)
    end
    
    task.wait(0.2)
    local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LoadingScreen, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadCenterBox, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadTitle, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(LoadSub, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(PercentLabel, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(LoadBarTrack, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadBarFill, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadStroke, fadeInfo, {Transparency = 1}):Play()
    TweenService:Create(LoadGlow, fadeInfo, {ImageTransparency = 1}):Play()
    
    task.wait(0.5)
    LoadingScreen.Visible = false
    MainFrame.Visible = true -- Só aparece após a tela de load sumir!
end)

-- SHADERS (BLOOM & BLUR DE ESTILO NO LIGHTING)
local function ApplyShaders(enableBloom, enableBlur)
    pcall(function()
        local lighting = game:GetService("Lighting")
        local existingBloom = lighting:FindFirstChild("RT_BloomShader")
        local existingBlur = lighting:FindFirstChild("RT_BlurShader")
        
        if enableBloom and not existingBloom then
            local bloom = Instance.new("BloomEffect")
            bloom.Name = "RT_BloomShader"
            bloom.Intensity = 0.4
            bloom.Size = 24
            bloom.Threshold = 0.8
            bloom.Parent = lighting
        elseif not enableBloom and existingBloom then
            existingBloom:Destroy()
        end

        if enableBlur and not existingBlur then
            local blur = Instance.new("BlurEffect")
            blur.Name = "RT_BlurShader"
            blur.Size = 6
            blur.Parent = lighting
        elseif not enableBlur and existingBlur then
            existingBlur:Destroy()
        end
    end)
end

-- Aplicar shaders salvos se houver
if State.BloomShader or State.BlurShader then
    ApplyShaders(State.BloomShader, State.BlurShader)
end

-- BOTÃO FLUTUANTE (RT ICON COM LOGO PERFEITAMENTE POSICIONADA)
local LauncherIcon = Instance.new("TextButton")
LauncherIcon.Name = "RT_Launcher"
LauncherIcon.Size = UDim2.new(0, 52, 0, 52)
LauncherIcon.Position = UDim2.new(0.02, 0, 0.22, 0)
LauncherIcon.BackgroundColor3 = Colors.Background
LauncherIcon.BorderSizePixel = 0
LauncherIcon.Text = ""
LauncherIcon.Active = true
LauncherIcon.Draggable = true
LauncherIcon.Parent = ScreenGui

local LauncherCorner = Instance.new("UICorner", LauncherIcon)
LauncherCorner.CornerRadius = UDim.new(0, 14)
local LauncherStroke = Instance.new("UIStroke", LauncherIcon)
LauncherStroke.Name = "RT_Stroke"
LauncherStroke.Thickness = 2
LauncherStroke.Color = Colors.Purple
LauncherStroke.Transparency = 0.3

local LauncherLogo = Instance.new("ImageLabel", LauncherIcon)
LauncherLogo.Name = "NEXORA_Logo"
LauncherLogo.Size = UDim2.new(1, -8, 1, -8)
LauncherLogo.Position = UDim2.new(0, 4, 0, 4)
LauncherLogo.BackgroundTransparency = 1
LauncherLogo.Image = "rbxassetid://119290932517877"
LauncherLogo.ScaleType = Enum.ScaleType.Fit
LauncherLogo.ZIndex = 2
Instance.new("UICorner", LauncherLogo).CornerRadius = UDim.new(0, 10)

local LauncherText = Instance.new("TextLabel", LauncherIcon)
LauncherText.Name = "RT_Text"
LauncherText.Size = UDim2.new(1, 0, 1, 0)
LauncherText.Position = UDim2.new(0, 0, 0, -1)
LauncherText.BackgroundTransparency = 1
LauncherText.Text = "NX"
LauncherText.Visible = false
LauncherText.TextColor3 = Colors.PurpleBright
LauncherText.TextSize = 16
LauncherText.Font = Enum.Font.GothamBold
LauncherText.TextXAlignment = Enum.TextXAlignment.Center
LauncherText.TextYAlignment = Enum.TextYAlignment.Center

local iconGlow = Instance.new("ImageLabel", LauncherIcon)
iconGlow.Size = UDim2.new(1, 32, 1, 32)
iconGlow.Position = UDim2.new(0, -16, 0, -16)
iconGlow.BackgroundTransparency = 1
iconGlow.Image = "rbxassetid://5028857084"
iconGlow.ImageColor3 = Colors.PurpleGlow
iconGlow.ImageTransparency = 0.5
iconGlow.ScaleType = Enum.ScaleType.Slice
iconGlow.SliceCenter = Rect.new(24,24,276,276)
iconGlow.ZIndex = -1

-- NOTIFICAÇÃO DE PROXIMIDADE (ALERTA NEXTBOT)
local AlertBanner = Instance.new("TextLabel")
AlertBanner.Name = "RT_AlertBanner"
AlertBanner.Size = UDim2.new(0, 340, 0, 36)
AlertBanner.Position = UDim2.new(0.5, -170, 0.08, 0)
AlertBanner.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
AlertBanner.TextColor3 = Color3.fromRGB(255, 255, 255)
AlertBanner.TextSize = 12
AlertBanner.Font = Enum.Font.GothamBold
AlertBanner.Text = "⚠️ ALERTA: NEXTBOT PRÓXIMO!"
AlertBanner.Visible = false
AlertBanner.Parent = ScreenGui
Instance.new("UICorner", AlertBanner).CornerRadius = UDim.new(0, 8)
local AlertStroke = Instance.new("UIStroke", AlertBanner)
AlertStroke.Color = Color3.fromRGB(255, 255, 255)
AlertStroke.Thickness = 1.5

local MainConstraint = Instance.new("UISizeConstraint")
MainConstraint.MaxSize = Vector2.new(720, 500)
MainConstraint.MinSize = Vector2.new(460, 320)
MainConstraint.Parent = MainFrame

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Name = "RT_Stroke"
MainStroke.Thickness = 1.5
MainStroke.Color = Colors.Stroke
MainStroke.Transparency = 0.35

local mainGlow = Instance.new("ImageLabel", MainFrame)
mainGlow.Size = UDim2.new(1, 40, 1, 40)
mainGlow.Position = UDim2.new(0, -20, 0, -20)
mainGlow.BackgroundTransparency = 1
mainGlow.Image = "rbxassetid://5028857084"
mainGlow.ImageColor3 = Colors.PurpleGlow
mainGlow.ImageTransparency = 0.75
mainGlow.ScaleType = Enum.ScaleType.Slice
mainGlow.SliceCenter = Rect.new(24,24,276,276)
mainGlow.ZIndex = -1

-- BARRA SUPERIOR
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundColor3 = Colors.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 14)
local TopFix = Instance.new("Frame", TopBar)
TopFix.Name = "RT_TopFix"
TopFix.Size = UDim2.new(1, 0, 0, 14)
TopFix.Position = UDim2.new(0, 0, 1, -14)
TopFix.BackgroundColor3 = Colors.TopBar
TopFix.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "RT_Text"
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "NEXORA X Evade"
TitleLabel.TextColor3 = Colors.Text
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local TitleGradient = Instance.new("UIGradient", TitleLabel)
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Colors.Text),
    ColorSequenceKeypoint.new(1, Colors.PurpleBright)
}

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "RT_CloseBtn"
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -34, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(45, 20, 35)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(248, 113, 113)
CloseButton.TextSize = 11
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 7)

local HideButton = Instance.new("TextButton")
HideButton.Name = "RT_HideBtn"
HideButton.Size = UDim2.new(0, 26, 0, 26)
HideButton.Position = UDim2.new(1, -66, 0, 10)
HideButton.BackgroundColor3 = Colors.Card
HideButton.Text = "—"
HideButton.TextColor3 = Colors.TextDim
HideButton.TextSize = 11
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = TopBar
Instance.new("UICorner", HideButton).CornerRadius = UDim.new(0, 7)

-- BARRA LATERAL (TABS)
local SideBar = Instance.new("ScrollingFrame")
SideBar.Name = "RT_SideBar"
SideBar.Size = UDim2.new(0.26, 0, 1, -46)
SideBar.Position = UDim2.new(0, 0, 0, 46)
SideBar.BackgroundColor3 = Colors.Sidebar
SideBar.BorderSizePixel = 0
SideBar.ScrollBarThickness = 2
SideBar.ScrollBarImageColor3 = Colors.Purple
SideBar.Parent = MainFrame

local TabHolder = Instance.new("UIListLayout", SideBar)
TabHolder.Padding = UDim.new(0, 6)
TabHolder.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabHolder.SortOrder = Enum.SortOrder.LayoutOrder

local SidePadding = Instance.new("UIPadding", SideBar)
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.PaddingLeft = UDim.new(0, 8)
SidePadding.PaddingRight = UDim.new(0, 8)

-- CONTAINER DE PÁGINAS
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0.74, -12, 1, -56)
Container.Position = UDim2.new(0.26, 8, 0, 52)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Tabs = {}
local FirstTab = true

local function CreateTab(tabName, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = "RT_TabBtn"
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Colors.Card
    TabButton.BorderSizePixel = 0
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.Parent = SideBar
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
    
    local TabStroke = Instance.new("UIStroke", TabButton)
    TabStroke.Name = "RT_Stroke"
    TabStroke.Color = Colors.Border
    TabStroke.Thickness = 1
    TabStroke.Transparency = 0.6
    
    local IconLabel = Instance.new("TextLabel", TabButton)
    IconLabel.Name = "RT_Icon"
    IconLabel.Size = UDim2.new(0, 26, 1, 0)
    IconLabel.Position = UDim2.new(0, 8, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon or "●"
    IconLabel.TextColor3 = Colors.TextDim
    IconLabel.TextSize = 12
    IconLabel.Font = Enum.Font.GothamBold
    
    local TextLabel = Instance.new("TextLabel", TabButton)
    TextLabel.Name = "RT_Text"
    TextLabel.Size = UDim2.new(1, -34, 1, 0)
    TextLabel.Position = UDim2.new(0, 32, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = tabName
    TextLabel.TextColor3 = Colors.TextDim
    TextLabel.TextSize = 11
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Page = Instance.new("ScrollingFrame")
    Page.Name = tabName .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Colors.Purple
    Page.Visible = false
    Page.Parent = Container
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local PagePadding = Instance.new("UIPadding", Page)
    PagePadding.PaddingRight = UDim.new(0, 8)
    PagePadding.PaddingBottom = UDim.new(0, 12)
    
    if FirstTab then
        FirstTab = false
        Page.Visible = true
        TabButton.BackgroundColor3 = Colors.PurpleDark
        TextLabel.TextColor3 = Colors.Text
        IconLabel.TextColor3 = Colors.PurpleBright
        TabStroke.Color = Colors.Purple
        TabStroke.Transparency = 0.2
    end
    
    TabButton.MouseEnter:Connect(function()
        if Page.Visible == false then
            local currentT = Themes[State.CurrentTheme]
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = currentT.CardHover}):Play()
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if Page.Visible == false then
            local currentT = Themes[State.CurrentTheme]
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = currentT.Card}):Play()
        end
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        local currentT = Themes[State.CurrentTheme]
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundColor3 = currentT.Card}):Play()
            TweenService:Create(t.TextLabel, TweenInfo.new(0.2), {TextColor3 = currentT.TextDim}):Play()
            TweenService:Create(t.IconLabel, TweenInfo.new(0.2), {TextColor3 = currentT.TextDim}):Play()
            t.Stroke.Transparency = 0.6
            t.Stroke.Color = currentT.Border
        end
        Page.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = currentT.PurpleDark}):Play()
        TweenService:Create(TextLabel, TweenInfo.new(0.2), {TextColor3 = currentT.Text}):Play()
        TweenService:Create(IconLabel, TweenInfo.new(0.2), {TextColor3 = currentT.PurpleBright}):Play()
        TabStroke.Color = currentT.Purple
        TabStroke.Transparency = 0.2
    end)
    
    table.insert(Tabs, {Button = TabButton, Page = Page, TextLabel = TextLabel, IconLabel = IconLabel, Stroke = TabStroke})
    return Page
end

-- COMPONENTES UI COM SUPORTE A SHADERS E TOGGLES
local function CreateToggle(parentPage, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "RT_ThemeItem"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 44)
    ToggleFrame.BackgroundColor3 = Colors.Card
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parentPage
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", ToggleFrame)
    Stroke.Name = "RT_Stroke"
    Stroke.Color = Colors.Border
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    
    local Label = Instance.new("TextLabel")
    Label.Name = "RT_Text"
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.Parent = ToggleFrame
    
    local Switch = Instance.new("TextButton")
    Switch.Name = "RT_Switch"
    Switch.Size = UDim2.new(0, 44, 0, 22)
    Switch.Position = UDim2.new(1, -54, 0.5, -11)
    Switch.BackgroundColor3 = default and Colors.Purple or Colors.CardHover
    Switch.Text = ""
    Switch.Parent = ToggleFrame
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame")
    Knob.Name = "RT_Knob"
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Switch
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
    Switch:SetAttribute("Toggled", default)
    
    local toggled = default
    Switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        Switch:SetAttribute("Toggled", toggled)
        local t = Themes[State.CurrentTheme]
        TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = toggled and t.Purple or t.CardHover}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = toggled and t.Purple or t.Border, Transparency = toggled and 0.25 or 0.5}):Play()
        callback(toggled)
        SaveConfig()
    end)
end

local function CreateSlider(parentPage, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "RT_ThemeItem"
    SliderFrame.Size = UDim2.new(1, 0, 0, 52)
    SliderFrame.BackgroundColor3 = Colors.Card
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parentPage
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", SliderFrame)
    Stroke.Name = "RT_Stroke"
    Stroke.Color = Colors.Border
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    
    local Label = Instance.new("TextLabel")
    Label.Name = "RT_Text"
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Name = "RT_Value"
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, -12, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Colors.PurpleBright
    ValueLabel.TextSize = 11
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local Track = Instance.new("TextButton")
    Track.Name = "RT_Track"
    Track.Size = UDim2.new(1, -24, 0, 6)
    Track.Position = UDim2.new(0, 12, 0, 32)
    Track.BackgroundColor3 = Colors.CardHover
    Track.Text = ""
    Track.Parent = SliderFrame
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Name = "RT_Fill"
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Colors.Purple
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function UpdateSlider(input)
        local posX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
        local percentage = posX / Track.AbsoluteSize.X
        local value = math.floor(min + (max - min) * percentage)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        callback(value)
    end
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true UpdateSlider(input) end
    end)
    Connections["SliderInputChanged_" .. text] = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end
    end)
    Connections["SliderInputEnded_" .. text] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
            SaveConfig() 
        end
    end)
end

local function CreateButton(parentPage, text, callback)
    local Button = Instance.new("TextButton")
    Button.Name = "RT_ThemeItem"
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Colors.Card
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Colors.Text
    Button.TextSize = 11
    Button.Font = Enum.Font.GothamBold
    Button.Parent = parentPage
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Button)
    Stroke.Name = "RT_Stroke"
    Stroke.Color = Colors.Border
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    
    Button.MouseEnter:Connect(function() 
        local t = Themes[State.CurrentTheme]
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = t.CardHover}):Play() 
    end)
    Button.MouseLeave:Connect(function() 
        local t = Themes[State.CurrentTheme]
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = t.Card}):Play() 
    end)
    
    Button.MouseButton1Click:Connect(function()
        local t = Themes[State.CurrentTheme]
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = t.Purple}):Play()
        task.wait(0.1)
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = t.Card}):Play()
        callback()
    end)
end

local function CreateDropdown(parentPage, text, options, default, callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Name = "RT_ThemeItem"
    DropFrame.Size = UDim2.new(1, 0, 0, 44)
    DropFrame.BackgroundColor3 = Colors.Card
    DropFrame.BorderSizePixel = 0
    DropFrame.ClipsDescendants = true
    DropFrame.Parent = parentPage
    Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", DropFrame)
    Stroke.Name = "RT_Stroke"
    Stroke.Color = Colors.Border
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    
    local Label = Instance.new("TextLabel")
    Label.Name = "RT_Text"
    Label.Size = UDim2.new(0.5, 0, 0, 44)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropFrame
    
    local SelectedBtn = Instance.new("TextButton")
    SelectedBtn.Name = "RT_DropdownBtn"
    SelectedBtn.Size = UDim2.new(0, 130, 0, 26)
    SelectedBtn.Position = UDim2.new(1, -140, 0, 9)
    SelectedBtn.BackgroundColor3 = Colors.PurpleDark
    SelectedBtn.Text = default
    SelectedBtn.TextColor3 = Colors.Text
    SelectedBtn.TextSize = 11
    SelectedBtn.Font = Enum.Font.GothamBold
    SelectedBtn.Parent = DropFrame
    Instance.new("UICorner", SelectedBtn).CornerRadius = UDim.new(0, 6)
    
    local ListHolder = Instance.new("ScrollingFrame")
    ListHolder.Name = "RT_ListHolder"
    ListHolder.Size = UDim2.new(1, -24, 0, #options * 30)
    ListHolder.Position = UDim2.new(0, 12, 0, 48)
    ListHolder.BackgroundTransparency = 1
    ListHolder.BorderSizePixel = 0
    ListHolder.ScrollBarThickness = 2
    ListHolder.Visible = false
    ListHolder.Parent = DropFrame
    
    local ListLayout = Instance.new("UIListLayout", ListHolder)
    ListLayout.Padding = UDim.new(0, 4)
    
    local isOpen = false
    SelectedBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ListHolder.Visible = isOpen
        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = isOpen and UDim2.new(1, 0, 0, 56 + (#options * 34)) or UDim2.new(1, 0, 0, 44)}):Play()
    end)
    
    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Name = "RT_DropOption"
        OptBtn.Size = UDim2.new(1, 0, 0, 28)
        OptBtn.BackgroundColor3 = Colors.CardHover
        OptBtn.Text = opt
        OptBtn.TextColor3 = Colors.TextDim
        OptBtn.TextSize = 11
        OptBtn.Font = Enum.Font.GothamBold
        OptBtn.Parent = ListHolder
        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 6)
        
        OptBtn.MouseEnter:Connect(function()
            local t = Themes[State.CurrentTheme]
            TweenService:Create(OptBtn, TweenInfo.new(0.15), {BackgroundColor3 = t.PurpleDark, TextColor3 = t.Text}):Play()
        end)
        OptBtn.MouseLeave:Connect(function()
            local t = Themes[State.CurrentTheme]
            TweenService:Create(OptBtn, TweenInfo.new(0.15), {BackgroundColor3 = t.CardHover, TextColor3 = t.TextDim}):Play()
        end)
        
        OptBtn.MouseButton1Click:Connect(function()
            SelectedBtn.Text = opt
            isOpen = false
            ListHolder.Visible = false
            TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 44)}):Play()
            callback(opt)
            SaveConfig()
        end)
    end
    return DropFrame
end

local function CreateKeybind(parentPage, text, defaultKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Name = "RT_ThemeItem"
    Frame.Size = UDim2.new(1, 0, 0, 44)
    Frame.BackgroundColor3 = Colors.Card
    Frame.BorderSizePixel = 0
    Frame.Parent = parentPage
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Name = "RT_Stroke"
    Stroke.Color = Colors.Border
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    
    local Label = Instance.new("TextLabel")
    Label.Name = "RT_Text"
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local KeyButton = Instance.new("TextButton")
    KeyButton.Name = "RT_KeyButton"
    KeyButton.Size = UDim2.new(0, 70, 0, 24)
    KeyButton.Position = UDim2.new(1, -80, 0.5, -12)
    KeyButton.BackgroundColor3 = Colors.PurpleDark
    KeyButton.Text = defaultKey.Name
    KeyButton.TextColor3 = Colors.Text
    KeyButton.TextSize = 11
    KeyButton.Font = Enum.Font.GothamBold
    KeyButton.Parent = Frame
    Instance.new("UICorner", KeyButton).CornerRadius = UDim.new(0, 6)
    local KeyStroke = Instance.new("UIStroke", KeyButton)
    KeyStroke.Name = "RT_Stroke"
    KeyStroke.Color = Colors.Purple
    KeyStroke.Thickness = 1
    
    KeyButton.MouseButton1Click:Connect(function()
        if State.WaitingForKeybind then return end
        State.WaitingForKeybind = true
        KeyButton.Text = "..."
        KeyButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local newKey = input.KeyCode
                if newKey ~= Enum.KeyCode.Unknown then
                    State.ToggleKey = newKey
                    KeyButton.Text = newKey.Name
                    KeyButton.BackgroundColor3 = Themes[State.CurrentTheme].PurpleDark
                    State.WaitingForKeybind = false
                    if callback then callback(newKey) end
                    SaveConfig()
                    connection:Disconnect()
                end
            end
        end)
        task.wait(5)
        if State.WaitingForKeybind then
            State.WaitingForKeybind = false
            KeyButton.Text = State.ToggleKey.Name
            KeyButton.BackgroundColor3 = Themes[State.CurrentTheme].PurpleDark
            if connection then connection:Disconnect() end
        end
    end)
    return Frame
end

-- ==========================================
-- ADVANCED ESP & TRACERS ENGINE
-- ==========================================

local ESPObjects = {}

local function RemoveESP(instance)
    if ESPObjects[instance] then
        if ESPObjects[instance].Highlight then ESPObjects[instance].Highlight:Destroy() end
        if ESPObjects[instance].Billboard then ESPObjects[instance].Billboard:Destroy() end
        if ESPObjects[instance].TracerLine then pcall(function() ESPObjects[instance].TracerLine:Remove() end) end
        ESPObjects[instance] = nil
    end
end

local function GetActiveBots()
    local botList = {}
    local gameFolder = Workspace:FindFirstChild("Game")
    if gameFolder then
        local effectsFolder = gameFolder:FindFirstChild("Effects")
        if effectsFolder and effectsFolder:FindFirstChild("Bots") then
            for _, bot in pairs(effectsFolder.Bots:GetChildren()) do table.insert(botList, bot) end
        end
        if gameFolder:FindFirstChild("Bots") then
            for _, bot in pairs(gameFolder.Bots:GetChildren()) do table.insert(botList, bot) end
        end
    end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local isPlayer = Players:GetPlayerFromCharacter(obj)
            if not isPlayer then
                if obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Root") or obj:HasTag("Bot") or obj:GetAttribute("IsBot") or obj:FindFirstChild("Hitbox") then
                    table.insert(botList, obj)
                end
            end
        end
    end
    return botList
end

local function UpdateESPForTarget(target, isBot)
    if not target or not target.Parent then
        RemoveESP(target)
        return
    end

    local rootPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Root") or target:FindFirstChild("Head")
    if not rootPart then return end

    if not ESPObjects[target] then
        local highlight = Instance.new("Highlight")
        highlight.Name = "RT_Highlight"
        highlight.Adornee = target
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.45
        highlight.OutlineTransparency = 0.05
        highlight.Parent = target

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RT_Billboard"
        billboard.Size = UDim2.new(0, 120, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3.2, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = rootPart

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Name = "Text"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0.15
        textLabel.TextStrokeColor3 = Color3.fromRGB(15, 10, 25)
        textLabel.TextSize = 11
        textLabel.Font = Enum.Font.GothamBold

        billboard.Parent = target

        local tracer = nil
        if Drawing then
            pcall(function()
                tracer = Drawing.new("Line")
                tracer.Visible = false
                tracer.Thickness = 1.5
                tracer.Color = isBot and Color3.fromRGB(255, 75, 75) or Color3.fromRGB(75, 255, 120)
                tracer.Transparency = 0.8
            end)
        end

        ESPObjects[target] = {Highlight = highlight, Billboard = billboard, Text = textLabel, TracerLine = tracer}
    end

    local data = ESPObjects[target]
    local enabled = (isBot and State.ActiveEspBots) or (not isBot and State.ActiveEspPlayers)
    
    local color = isBot and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(50, 245, 120)
    data.Highlight.FillColor = color
    data.Highlight.OutlineColor = color
    data.Highlight.Enabled = enabled

    if enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        local dist = math.floor((rootPart.Position - myPos).Magnitude)
        local nameStr = isBot and "⚠️ NextBot" or target.Name
        
        if State.ActiveDistanceEsp then
            data.Text.Text = string.format("[%s]\n📍 %dm", nameStr, dist)
            data.Text.Visible = true
        else
            data.Text.Text = string.format("[%s]", nameStr)
            data.Text.Visible = true
        end

        if State.ActiveTracerEsp and data.TracerLine and Drawing then
            local cam = Workspace.CurrentCamera
            if cam then
                local vector, onScreen = cam:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    data.TracerLine.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    data.TracerLine.To = Vector2.new(vector.X, vector.Y)
                    data.TracerLine.Visible = true
                else
                    data.TracerLine.Visible = false
                end
            end
        elseif data.TracerLine then
            data.TracerLine.Visible = false
        end
    else
        data.Highlight.Enabled = false
        data.Text.Visible = false
        if data.TracerLine then data.TracerLine.Visible = false end
    end
end

-- CRIAÇÃO DAS ABAS DA RT SUITE
local HomeTab = CreateTab("Home", "🏠")
local PlayerTab = CreateTab("Player", "🏃")
local AutoTab = CreateTab("Automation", "🤖")
local SpectateTab = CreateTab("Spectate & TP", "👁️‍🗨️")
local EspTab = CreateTab("ESP", "👁️")
local VisualTab = CreateTab("Visuals", "🎨")
local SettingsTab = CreateTab("Settings", "⚙️")

-- NEXORA X EVADE | HOME DASHBOARD
local DashboardFrame = Instance.new("Frame")
DashboardFrame.Name = "RT_ThemeItem"
DashboardFrame.Size = UDim2.new(1, 0, 0, 246)
DashboardFrame.BackgroundColor3 = Colors.Card
DashboardFrame.BorderSizePixel = 0
DashboardFrame.Parent = HomeTab
Instance.new("UICorner", DashboardFrame).CornerRadius = UDim.new(0, 10)
local DashStroke = Instance.new("UIStroke", DashboardFrame)
DashStroke.Name = "RT_Stroke"; DashStroke.Color = Colors.Border; DashStroke.Thickness = 1; DashStroke.Transparency = 0.35

local DashTitle = Instance.new("TextLabel", DashboardFrame)
DashTitle.Name = "RT_Text"; DashTitle.Size = UDim2.new(1, -20, 0, 26); DashTitle.Position = UDim2.new(0, 12, 0, 7)
DashTitle.BackgroundTransparency = 1; DashTitle.Text = "NEXORA X Evade • Dashboard"; DashTitle.TextColor3 = Colors.PurpleBright
DashTitle.TextSize = 14; DashTitle.Font = Enum.Font.GothamBold; DashTitle.TextXAlignment = Enum.TextXAlignment.Left

local MapImage = Instance.new("ImageLabel", DashboardFrame)
MapImage.Name = "MapThumbnail"; MapImage.Size = UDim2.new(0, 86, 0, 70); MapImage.Position = UDim2.new(0, 12, 0, 40)
MapImage.BackgroundColor3 = Colors.Background; MapImage.BorderSizePixel = 0; MapImage.ScaleType = Enum.ScaleType.Crop
MapImage.Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.PlaceId) .. "&w=150&h=150"
Instance.new("UICorner", MapImage).CornerRadius = UDim.new(0, 8)

local AvatarImage = Instance.new("ImageLabel", DashboardFrame)
AvatarImage.Name = "AvatarThumbnail"; AvatarImage.Size = UDim2.new(0, 64, 0, 64); AvatarImage.Position = UDim2.new(0, 25, 0, 118)
AvatarImage.BackgroundColor3 = Colors.Background; AvatarImage.BorderSizePixel = 0; AvatarImage.ScaleType = Enum.ScaleType.Crop
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

local InfoText = Instance.new("TextLabel", DashboardFrame)
InfoText.Name = "DashboardInfo"; InfoText.Size = UDim2.new(1, -128, 0, 148); InfoText.Position = UDim2.new(0, 108, 0, 38)
InfoText.BackgroundTransparency = 1; InfoText.TextColor3 = Colors.Text; InfoText.TextSize = 11; InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Left; InfoText.TextYAlignment = Enum.TextYAlignment.Top; InfoText.TextWrapped = true

local LanguageButton = Instance.new("TextButton", DashboardFrame)
LanguageButton.Name = "LanguageToggle"; LanguageButton.Size = UDim2.new(0, 104, 0, 28); LanguageButton.Position = UDim2.new(0, 12, 1, -38)
LanguageButton.BackgroundColor3 = Colors.PurpleDark; LanguageButton.Text = "🌐 ภาษา: ไทย"; LanguageButton.TextColor3 = Colors.Text
LanguageButton.TextSize = 10; LanguageButton.Font = Enum.Font.GothamBold; Instance.new("UICorner", LanguageButton).CornerRadius = UDim.new(0, 7)

local DiscordButton = Instance.new("TextButton", DashboardFrame)
DiscordButton.Name = "DiscordCopy"; DiscordButton.Size = UDim2.new(0, 160, 0, 28); DiscordButton.Position = UDim2.new(1, -172, 1, -38)
DiscordButton.BackgroundColor3 = Colors.PurpleDark; DiscordButton.Text = "📋 Copy Discord Link"; DiscordButton.TextColor3 = Colors.Text
DiscordButton.TextSize = 10; DiscordButton.Font = Enum.Font.GothamBold; Instance.new("UICorner", DiscordButton).CornerRadius = UDim.new(0, 7)
local DiscordURL = "https://discord.gg/Hvyf8crug"
DiscordButton.MouseButton1Click:Connect(function()
    local copied = pcall(function() if setclipboard then setclipboard(DiscordURL) elseif toclipboard then toclipboard(DiscordURL) else error("clipboard unavailable") end end)
    DiscordButton.Text = copied and "✓ Copied!" or "Discord: discord.gg/Hvyf8crug"
    task.delay(2, function() if DiscordButton and DiscordButton.Parent then DiscordButton.Text = "📋 Copy Discord Link" end end)
end)

local CurrentLanguage = "TH"
local Translations = {
    ["Home"]="หน้าหลัก", ["Player"]="ตัวละคร", ["Automation"]="ระบบอัตโนมัติ", ["Spectate & TP"]="ส่องผู้เล่น / วาร์ป", ["ESP"]="แสดงตำแหน่ง", ["Visuals"]="ภาพและ FPS", ["Settings"]="ตั้งค่า",
    ["Movement Speed"]="ความเร็วเคลื่อนที่", ["CFrame Speed Boost"]="เพิ่มความเร็วแบบ CFrame", ["Enable Jump Boost Mode"]="เปิดโหมดเพิ่มแรงกระโดด", ["Jump Power Multiplier"]="แรงกระโดด", ["Infinite Jump Mode"]="กระโดดไม่จำกัด", ["Noclip Mode (Pass Walls)"]="ทะลุกำแพง", ["Auto BunnyHop (Hold Jump)"]="กระโดดต่อเนื่อง (กดกระโดดค้าง)", ["World Gravity Settings"]="ปรับแรงโน้มถ่วง", ["Reset Gravity to Default"]="คืนค่าแรงโน้มถ่วง", ["Custom Camera FOV"]="ปรับมุมกล้องเอง", ["Field of View (FOV)"]="มุมมองกล้อง (FOV)",
    ["Map Selection Number"]="เลือกหมายเลขแมพ", ["Vote Selected Map"]="โหวตแมพที่เลือก", ["Auto Map Voting"]="โหวตแมพอัตโนมัติ", ["Instant Revive Self"]="ลองชุบตัวเองทันที", ["Auto Revive Self [RT SMART]"]="ชุบตัวเองอัตโนมัติ", ["Select Player"]="เลือกผู้เล่น", ["Teleport to Selected Player"]="วาร์ปไปหาผู้เล่น", ["Spectate Selected Player"]="ส่องผู้เล่นที่เลือก", ["Player ESP"]="แสดงตำแหน่งผู้เล่น", ["NextBot Monster ESP"]="แสดงตำแหน่ง NextBot", ["Distance Measurement ESP"]="แสดงระยะห่าง", ["Tracer Lines (Snaplines)"]="เส้นชี้ตำแหน่ง", ["NextBot Proximity Alert Banner"]="เตือนเมื่อ NextBot อยู่ใกล้", ["Anti-AFK Kick Protection"]="ป้องกันหลุดเพราะไม่ขยับ", ["Full Brightness Mode"]="เพิ่มความสว่าง", ["Super Brightness Exposure"]="สว่างพิเศษ", ["Restore Default Lighting"]="คืนค่าแสงเดิม", ["Disable Fog Engine"]="ปิดหมอก", ["Shader: Cinematic Bloom"]="เอฟเฟกต์แสง Bloom", ["Shader: Depth Blur"]="เอฟเฟกต์เบลอฉาก", ["FPS Enhancement (Low Quality)"]="เพิ่ม FPS (ลดคุณภาพภาพ)", ["Unlock Max Frame Rate (240 FPS)"]="ตั้งค่า FPS สูงสุด 240", ["Select UI Theme"]="เลือกธีมหน้าตา", ["Toggle UI Keybind"]="ปุ่มเปิด/ปิด GUI", ["Reset Keybind to K"]="คืนปุ่มลัดเป็น K", ["Reset All Configs"]="รีเซ็ตการตั้งค่าทั้งหมด", ["Destroy UI"]="ปิดและลบ GUI"
}
local OriginalText = {}
local function TranslateUI()
    for _, obj in ipairs(ScreenGui:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj ~= InfoText then
            if OriginalText[obj] == nil then OriginalText[obj] = obj.Text end
            local original = OriginalText[obj]
            if CurrentLanguage == "TH" then
                obj.Text = Translations[original] or original
            else
                obj.Text = original
            end
        end
    end
    for _, tabData in ipairs(Tabs) do
        local original = tabData.TextLabel:GetAttribute("OriginalTabText")
        if not original then original = tabData.TextLabel.Text; tabData.TextLabel:SetAttribute("OriginalTabText", original) end
        tabData.TextLabel.Text = CurrentLanguage == "TH" and (Translations[original] or original) or original
    end
    LanguageButton.Text = CurrentLanguage == "TH" and "🌐 ภาษา: ไทย" or "🌐 Language: EN"
    DiscordButton.Text = CurrentLanguage == "TH" and "📋 คัดลอกลิงก์ดิส" or "📋 Copy Discord Link"
end
LanguageButton.MouseButton1Click:Connect(function()
    CurrentLanguage = CurrentLanguage == "TH" and "EN" or "TH"
    TranslateUI()
end)

local function GetMapName()
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name then return info.Name end
    return "Unknown Map"
end
local mapName = GetMapName()
local function UpdateDashboard()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local health = humanoid and math.floor(humanoid.Health) or 0
    local maxHealth = humanoid and math.floor(humanoid.MaxHealth) or 0
    local fps = 0
    if _G.NX_FPS then fps = _G.NX_FPS end
    local executorName = "Unknown"
    pcall(function() if identifyexecutor then executorName = identifyexecutor() end end)
    if CurrentLanguage == "TH" then
        InfoText.Text = string.format("แมพ: %s\nชื่อผู้เล่น: %s\nเลือด: %d / %d\nFPS: %d\nPlace ID: %s\nExecutor: %s", mapName, LocalPlayer.DisplayName, health, maxHealth, fps, tostring(game.PlaceId), executorName)
    else
        InfoText.Text = string.format("Map: %s\nPlayer: %s (@%s)\nHealth: %d / %d\nFPS: %d\nPlace ID: %s\nExecutor: %s", mapName, LocalPlayer.DisplayName, LocalPlayer.Name, health, maxHealth, fps, tostring(game.PlaceId), executorName)
    end
end
local frameCount, lastFpsTime = 0, os.clock()
Connections["DashboardFPS"] = RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = os.clock()
    if now - lastFpsTime >= 1 then
        _G.NX_FPS = frameCount; frameCount = 0; lastFpsTime = now
        UpdateDashboard()
    end
end)
Connections["DashboardHealth"] = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1); UpdateDashboard()
end)
task.spawn(function() while ScriptActive do UpdateDashboard(); task.wait(2) end end)
TranslateUI()

local WelcomeCard = Instance.new("Frame")
WelcomeCard.Name = "RT_ThemeItem"
WelcomeCard.Size = UDim2.new(1, 0, 0, 86)
WelcomeCard.BackgroundColor3 = Colors.Card
WelcomeCard.BorderSizePixel = 0
WelcomeCard.Parent = HomeTab
Instance.new("UICorner", WelcomeCard).CornerRadius = UDim.new(0, 8)
local WelcomeStroke = Instance.new("UIStroke", WelcomeCard)
WelcomeStroke.Name = "RT_Stroke"; WelcomeStroke.Color = Colors.Border; WelcomeStroke.Thickness = 1; WelcomeStroke.Transparency = 0.5
local WelcomeTitle = Instance.new("TextLabel", WelcomeCard)
WelcomeTitle.Name = "RT_Text"; WelcomeTitle.Size = UDim2.new(1, -20, 0, 24); WelcomeTitle.Position = UDim2.new(0, 12, 0, 8)
WelcomeTitle.BackgroundTransparency = 1; WelcomeTitle.Text = "Welcome to NEXORA X Evade"; WelcomeTitle.TextColor3 = Colors.PurpleBright
WelcomeTitle.TextSize = 12; WelcomeTitle.Font = Enum.Font.GothamBold; WelcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
local WelcomeDesc = Instance.new("TextLabel", WelcomeCard)
WelcomeDesc.Name = "RT_TextDim"; WelcomeDesc.Size = UDim2.new(1, -24, 1, -34); WelcomeDesc.Position = UDim2.new(0, 12, 0, 32)
WelcomeDesc.BackgroundTransparency = 1; WelcomeDesc.Text = "เลือกหมวดหมู่จากแถบด้านซ้าย และใช้ปุ่มภาษาเพื่อสลับไทย/อังกฤษ"
WelcomeDesc.TextColor3 = Colors.TextDim; WelcomeDesc.TextSize = 11; WelcomeDesc.Font = Enum.Font.Gotham
WelcomeDesc.TextXAlignment = Enum.TextXAlignment.Left; WelcomeDesc.TextYAlignment = Enum.TextYAlignment.Top; WelcomeDesc.TextWrapped = true

-- PLAYER TAB
CreateSlider(PlayerTab, "Movement Speed", 1, 50, State.ValueSpeed, function(v) State.ValueSpeed = v end)

Connections["FirstPersonCamFix"] = RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local cam = Workspace.CurrentCamera
    if char and cam then
        local head = char:FindFirstChild("Head")
        if head then
            local isFirstPerson = (cam.CFrame.Position - head.Position).Magnitude < 2
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = isFirstPerson and 1 or 0
                end
            end
        end
    end
end)

CreateToggle(PlayerTab, "CFrame Speed Boost", State.ActiveCFrameSpeedBoost, function(v)
    State.ActiveCFrameSpeedBoost = v
    if v then
        Connections["CFrameSpeed"] = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if char and hum and hrp and hum.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + hum.MoveDirection * math.max(State.ValueSpeed, 1) * 0.08
            end
        end)
    elseif Connections["CFrameSpeed"] then Connections["CFrameSpeed"]:Disconnect() Connections["CFrameSpeed"] = nil end
end)

CreateToggle(PlayerTab, "Enable Jump Boost Mode", State.JumpBoost, function(v)
    State.JumpBoost = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = v end
end)

CreateSlider(PlayerTab, "Jump Power Multiplier", 0, 1000, State.JumpPowerValue, function(v)
    State.JumpPowerValue = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end
end)

CreateToggle(PlayerTab, "Infinite Jump Mode", State.InfiniteJump, function(v) State.InfiniteJump = v end)

task.spawn(function()
    while ScriptActive do
        task.wait(0.05)
        if State.InfiniteJump and State.IsHoldingJump and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

CreateToggle(PlayerTab, "Noclip Mode (Pass Walls)", State.Noclip, function(v)
    State.Noclip = v
    if v then
        Connections["NoclipLoop"] = RunService.Stepped:Connect(function()
            if State.Noclip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    elseif Connections["NoclipLoop"] then Connections["NoclipLoop"]:Disconnect() Connections["NoclipLoop"] = nil end
end)

CreateToggle(PlayerTab, "Auto BunnyHop (Hold Jump)", State.BhopEnabled, function(v) State.BhopEnabled = v end)
CreateSlider(PlayerTab, "World Gravity Settings", 0, 500, State.GravityValue, function(v) 
    State.GravityValue = v 
    Workspace.Gravity = v 
end)
CreateButton(PlayerTab, "Reset Gravity to Default", function() 
    State.GravityValue = 196.2
    Workspace.Gravity = 196.2 
    SaveConfig()
end)

-- FOV MODIFIER
CreateToggle(PlayerTab, "Custom Camera FOV", State.ActiveFOV, function(v) State.ActiveFOV = v end)
CreateSlider(PlayerTab, "Field of View (FOV)", 50, 120, State.CustomFOVValue, function(v)
    State.CustomFOVValue = v
end)

Connections["FOVLoop"] = RunService.RenderStepped:Connect(function()
    if State.ActiveFOV and Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = State.CustomFOVValue
    end
end)

-- AUTOMATION TAB
CreateSlider(AutoTab, "Map Selection Number", 1, 4, State.SelectedMapNumber, function(v) State.SelectedMapNumber = v end)
CreateButton(AutoTab, "Vote Selected Map", function()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if events then
        local playerEvents = events:FindFirstChild("Player") or events
        if playerEvents:FindFirstChild("Vote") then playerEvents.Vote:FireServer(State.SelectedMapNumber) end
    end
end)

CreateToggle(AutoTab, "Auto Map Voting", State.AutoVoteEnabled, function(v)
    State.AutoVoteEnabled = v
    if v then
        Connections["AutoVote"] = RunService.Heartbeat:Connect(function()
            local events = ReplicatedStorage:FindFirstChild("Events")
            if events then
                local playerEvents = events:FindFirstChild("Player") or events
                if playerEvents:FindFirstChild("Vote") then playerEvents.Vote:FireServer(State.SelectedMapNumber) end
            end
        end)
    elseif Connections["AutoVote"] then Connections["AutoVote"]:Disconnect() Connections["AutoVote"] = nil end
end)

local function TriggerSelfRevive()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if events then
        for _, rn in ipairs({"Revive", "SetPlayerMode"}) do
            if events:FindFirstChild(rn) then
                pcall(function()
                    if rn == "SetPlayerMode" then events[rn]:FireServer(true)
                    else events[rn]:FireServer() events[rn]:FireServer(LocalPlayer) events[rn]:FireServer(LocalPlayer.Character) end
                end)
            end
        end
        for _, fn in ipairs({"Player", "Character", "Game"}) do
            local folder = events:FindFirstChild(fn)
            if folder then
                if folder:FindFirstChild("Revive") then pcall(function() folder.Revive:FireServer() folder.Revive:FireServer(LocalPlayer) end) end
                if folder:FindFirstChild("SetPlayerMode") then pcall(function() folder.SetPlayerMode:FireServer(true) end) end
            end
        end
    end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
    end)
end

local function IsDowned()
    local char = LocalPlayer.Character
    if not char then return false end
    if char:GetAttribute("Downed") == true or LocalPlayer:GetAttribute("Downed") == true then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and (hum:GetAttribute("Downed") == true or hum.Health <= 0) then return true end
    if char:FindFirstChild("Downed") or char:FindFirstChild("Knocked") then return true end
    return false
end

CreateButton(AutoTab, "Instant Revive Self", function() for i=1,5 do TriggerSelfRevive() task.wait(0.05) end end)
CreateToggle(AutoTab, "Auto Revive Self [RT SMART]", State.AutoReviveEnabled, function(v) State.AutoReviveEnabled = v end)

task.spawn(function()
    while ScriptActive do
        task.wait(0.4)
        if State.AutoReviveEnabled and IsDowned() then
            for i=1,3 do TriggerSelfRevive() task.wait(0.15) end
            task.wait(3)
        end
    end
end)

-- SPECTATE & TP TAB DEDICADA
local playerNames = {}
for _, plr in pairs(Players:GetPlayers()) do 
    if plr ~= LocalPlayer then 
        table.insert(playerNames, plr.Name) 
    end 
end
Players.PlayerAdded:Connect(function(plr) table.insert(playerNames, plr.Name) end)

CreateDropdown(SpectateTab, "Select Player", playerNames, "Choose...", function(selected)
    State.SelectedSpectatePlayer = selected
end)

CreateButton(SpectateTab, "Teleport to Selected Player", function()
    if State.SelectedSpectatePlayer then
        local targetPlr = Players:FindFirstChild(State.SelectedSpectatePlayer)
        if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                myHrp.CFrame = targetPlr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

CreateToggle(SpectateTab, "Spectate Selected Player", false, function(v)
    if v and State.SelectedSpectatePlayer then
        Connections["SpectateLoop"] = RunService.RenderStepped:Connect(function()
            local targetPlr = Players:FindFirstChild(State.SelectedSpectatePlayer)
            if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
                local cam = Workspace.CurrentCamera
                if cam then
                    cam.CameraSubject = targetPlr.Character:FindFirstChildOfClass("Humanoid")
                end
            end
        end)
    else
        if Connections["SpectateLoop"] then Connections["SpectateLoop"]:Disconnect() Connections["SpectateLoop"] = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and Workspace.CurrentCamera then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

-- ESP TAB
CreateToggle(EspTab, "Player ESP", State.ActiveEspPlayers, function(v)
    State.ActiveEspPlayers = v
    if not v then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and ESPObjects[plr.Character] then RemoveESP(plr.Character) end
        end
    end
end)

CreateToggle(EspTab, "NextBot Monster ESP", State.ActiveEspBots, function(v)
    State.ActiveEspBots = v
    if not v then
        for _, bot in pairs(GetActiveBots()) do
            if ESPObjects[bot] then RemoveESP(bot) end
        end
    end
end)

CreateToggle(EspTab, "Distance Measurement ESP", State.ActiveDistanceEsp, function(v) State.ActiveDistanceEsp = v end)
CreateToggle(EspTab, "Tracer Lines (Snaplines)", State.ActiveTracerEsp, function(v)
    State.ActiveTracerEsp = v
    if not v then
        for _, data in pairs(ESPObjects) do
            if data.TracerLine then data.TracerLine.Visible = false end
        end
    end
end)

CreateToggle(EspTab, "NextBot Proximity Alert Banner", State.BotProximityAlert, function(v) 
    State.BotProximityAlert = v 
    SaveConfig()
end)

Connections["UniversalESPLoop"] = RunService.Heartbeat:Connect(function()
    local botClose = false
    if State.ActiveEspPlayers then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                UpdateESPForTarget(plr.Character, false)
            end
        end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and ESPObjects[plr.Character] then
                ESPObjects[plr.Character].Highlight.Enabled = false
                ESPObjects[plr.Character].Text.Visible = false
                if ESPObjects[plr.Character].TracerLine then ESPObjects[plr.Character].TracerLine.Visible = false end
            end
        end
    end

    if State.ActiveEspBots then
        for _, bot in pairs(GetActiveBots()) do
            UpdateESPForTarget(bot, true)
            if State.BotProximityAlert and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local botRoot = bot:FindFirstChild("HumanoidRootPart") or bot:FindFirstChild("Root")
                if botRoot then
                    local dist = (botRoot.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= 60 then botClose = true end
                end
            end
        end
    else
        for _, bot in pairs(GetActiveBots()) do
            if ESPObjects[bot] then
                ESPObjects[bot].Highlight.Enabled = false
                ESPObjects[bot].Text.Visible = false
                if ESPObjects[bot].TracerLine then ESPObjects[bot].TracerLine.Visible = false end
            end
        end
    end

    if State.BotProximityAlert then
        AlertBanner.Visible = botClose
    else
        AlertBanner.Visible = false
    end
end)

-- VISUALS TAB (COM SHADERS DE BLOOM E BLUR)
CreateToggle(VisualTab, "Anti-AFK Kick Protection", State.AntiAFK, function(v) 
    State.AntiAFK = v 
    SaveConfig()
end)
CreateToggle(VisualTab, "Full Brightness Mode", State.FullBright, function(v)
    State.FullBright = v
    if v then game.Lighting.Brightness = 2 game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) game.Lighting.Ambient = Color3.fromRGB(255, 255, 255) game.Lighting.GlobalShadows = false
    else game.Lighting.Brightness = OriginalLighting.Brightness game.Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient game.Lighting.Ambient = OriginalLighting.Ambient game.Lighting.GlobalShadows = OriginalLighting.GlobalShadows end
end)
CreateToggle(VisualTab, "Super Brightness Exposure", State.SuperFullBright, function(v)
    State.SuperFullBright = v
    if v then game.Lighting.Brightness = 15 game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) game.Lighting.Ambient = Color3.fromRGB(255, 255, 255) game.Lighting.GlobalShadows = false
    else game.Lighting.Brightness = OriginalLighting.Brightness end
end)
CreateButton(VisualTab, "Restore Default Lighting", function()
    game.Lighting.Brightness = OriginalLighting.Brightness game.Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient game.Lighting.Ambient = OriginalLighting.Ambient game.Lighting.GlobalShadows = OriginalLighting.GlobalShadows game.Lighting.FogEnd = OriginalLighting.FogEnd game.Lighting.FogStart = OriginalLighting.FogStart
end)
CreateToggle(VisualTab, "Disable Fog Engine", State.NoFog, function(v)
    State.NoFog = v
    if v then game.Lighting.FogEnd = 1000000 game.Lighting.FogStart = 999999
    else game.Lighting.FogEnd = OriginalLighting.FogEnd game.Lighting.FogStart = OriginalLighting.FogStart end
end)

CreateToggle(VisualTab, "Shader: Cinematic Bloom", State.BloomShader, function(v)
    State.BloomShader = v
    ApplyShaders(State.BloomShader, State.BlurShader)
    SaveConfig()
end)

CreateToggle(VisualTab, "Shader: Depth Blur", State.BlurShader, function(v)
    State.BlurShader = v
    ApplyShaders(State.BloomShader, State.BlurShader)
    SaveConfig()
end)

CreateToggle(VisualTab, "FPS Enhancement (Low Quality)", State.FPSBoost, function(v)
    State.FPSBoost = v
    if v then
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("BasePart") then OriginalMaterials[obj] = {Material = obj.Material, Reflectance = obj.Reflectance} obj.Material = Enum.Material.SmoothPlastic obj.Reflectance = 0 end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    else
        for obj, data in pairs(OriginalMaterials) do if obj and obj.Parent then obj.Material = data.Material obj.Reflectance = data.Reflectance end end
        table.clear(OriginalMaterials)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end)
CreateButton(VisualTab, "Unlock Max Frame Rate (240 FPS)", function() if setfpscap then setfpscap(240) end end)

-- SETTINGS TAB
CreateDropdown(SettingsTab, "Select UI Theme", {"Halloween Orange", "Neon Purple", "Cyber Cyan", "Blood Crimson", "Matrix Emerald", "Sunset Gold", "Royal Amethyst", "Dark Midnight"}, State.CurrentTheme, function(selectedTheme)
    State.CurrentTheme = selectedTheme
    SaveConfig()
    local t = Themes[selectedTheme]
    if t then
        -- 1. Janela Principal e Barras Globais
        MainFrame.BackgroundColor3 = t.Background
        TopBar.BackgroundColor3 = t.TopBar
        TopFix.BackgroundColor3 = t.TopBar
        SideBar.BackgroundColor3 = t.Sidebar
        MainStroke.Color = t.Stroke
        LauncherIcon.BackgroundColor3 = t.Background
        LauncherIcon.TextColor3 = t.PurpleBright
        LauncherStroke.Color = t.Purple
        iconGlow.ImageColor3 = t.PurpleGlow
        mainGlow.ImageColor3 = t.PurpleGlow
        HideButton.BackgroundColor3 = t.Card
        HideButton.TextColor3 = t.TextDim

        -- 2. Varredura Completa na UI para atualizar TUDO (incluindo toggles ativos e inativos)
        for _, desc in pairs(ScreenGui:GetDescendants()) do
            if desc.Name == "RT_ThemeItem" then
                desc.BackgroundColor3 = t.Card
            elseif desc.Name == "RT_Stroke" then
                desc.Color = t.Border
            elseif desc.Name == "RT_Text" or desc.Name == "RT_TextSub" then
                desc.TextColor3 = t.Text
            elseif desc.Name == "RT_TextDim" then
                desc.TextColor3 = t.TextDim
            elseif desc.Name == "RT_Value" then
                desc.TextColor3 = t.PurpleBright
            elseif desc.Name == "RT_Track" then
                desc.BackgroundColor3 = t.CardHover
            elseif desc.Name == "RT_Fill" then
                desc.BackgroundColor3 = t.Purple
            elseif desc.Name == "RT_Switch" then
                local isToggled = desc:GetAttribute("Toggled")
                desc.BackgroundColor3 = isToggled and t.Purple or t.CardHover
            elseif desc.Name == "RT_DropdownBtn" or desc.Name == "RT_KeyButton" then
                desc.BackgroundColor3 = t.PurpleDark
                desc.TextColor3 = t.Text
            elseif desc.Name == "RT_DropOption" then
                desc.BackgroundColor3 = t.CardHover
                desc.TextColor3 = t.TextDim
            end
        end

        -- 3. Atualiza os Botões das Abas na Sidebar
        for _, tabData in pairs(Tabs) do
            tabData.Stroke.Color = t.Border
            if tabData.Page.Visible then
                tabData.Button.BackgroundColor3 = t.PurpleDark
                tabData.TextLabel.TextColor3 = t.Text
                tabData.IconLabel.TextColor3 = t.PurpleBright
                tabData.Stroke.Color = t.Purple
            else
                tabData.Button.BackgroundColor3 = t.Card
                tabData.TextLabel.TextColor3 = t.TextDim
                tabData.IconLabel.TextColor3 = t.TextDim
            end
        end
    end
end)

CreateKeybind(SettingsTab, "Toggle UI Keybind", State.ToggleKey, function(newKey)
    State.ToggleKey = newKey
    SaveConfig()
end)

CreateButton(SettingsTab, "Reset Keybind to K", function()
    State.ToggleKey = Enum.KeyCode.K
    SaveConfig()
    for _, child in pairs(SettingsTab:GetChildren()) do
        if child:IsA("Frame") then
            local btn = child:FindFirstChild("RT_KeyButton") or child:FindFirstChild("KeyButton")
            if btn then btn.Text = "K" end
        end
    end
end)

CreateButton(SettingsTab, "Reset All Configs", function()
    pcall(function()
        if delfile and isfile(ConfigFileName) then
            delfile(ConfigFileName)
            print("[RT] Arquivo de configuração deletado com sucesso!")
        end
    end)
end)

CreateButton(SettingsTab, "Destroy UI", function()
    ScriptActive = false
    for _, conn in pairs(Connections) do
        if type(conn) == "thread" then task.cancel(conn)
        elseif typeof(conn) == "RBXScriptConnection" and conn.Connected then conn:Disconnect() end
    end
    table.clear(Connections)
    for obj, _ in pairs(ESPObjects) do RemoveESP(obj) end
    ScreenGui:Destroy()
end)

-- Apply the selected language after every control has been created.
TranslateUI()

-- EVENTOS GLOBAIS
Connections["ToggleKeyListener"] = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if State.WaitingForKeybind then return end
    if input.KeyCode == State.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local function HookMobileJumpButton()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not playerGui then return end
    local touchGui = playerGui:FindFirstChild("TouchGui")
    if touchGui then
        for _, child in pairs(touchGui:GetDescendants()) do
            if child.Name == "JumpButton" then
                child.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then State.IsHoldingJump = true end
                end)
                child.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then State.IsHoldingJump = false end
                end)
            end
        end
    end
end

Connections["JumpInputBegan"] = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Space then State.IsHoldingJump = true end
end)
Connections["JumpInputEnded"] = UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Space then State.IsHoldingJump = false end
end)

local function HookBhop(character)
    if not character then return end
    local hum = character:WaitForChild("Humanoid", 5)
    if hum then
        if Connections["BhopStateChanged"] then Connections["BhopStateChanged"]:Disconnect() Connections["BhopStateChanged"] = nil end
        Connections["BhopStateChanged"] = hum.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Landed then
                if State.IsHoldingJump and State.BhopEnabled then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
    task.defer(HookMobileJumpButton)
end

if LocalPlayer.Character then HookBhop(LocalPlayer.Character) end
Connections["CharacterAdded"] = LocalPlayer.CharacterAdded:Connect(HookBhop)

task.spawn(function()
    while ScriptActive do
        task.wait(60)
        if State.AntiAFK and LocalPlayer.Character and Workspace.CurrentCamera then
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end
    end
end)

LauncherIcon.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
HideButton.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
CloseButton.MouseButton1Click:Connect(function()
    ScriptActive = false
    for _, conn in pairs(Connections) do
        if type(conn) == "thread" then task.cancel(conn)
        elseif typeof(conn) == "RBXScriptConnection" and conn.Connected then conn:Disconnect() end
    end
    table.clear(Connections)
    for obj, _ in pairs(ESPObjects) do RemoveESP(obj) end
    ScreenGui:Destroy()
end)

print("⚡ NEXORA X Evade - Loaded successfully!")
print("Dashboard: map, avatar, player, health, FPS, Thai/English and Discord copy.")
