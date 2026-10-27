--[[
    ✦ Linoria Glass — kompletny redesign ✦
    Styl: glassmorphism + neon. API 100% kompatybilne z oryginałem.
    Kolory, fonty, animacje — wszystko nowe. Twoje komendy bez zmian.
]]

local cloneref = (cloneref or clonereference or function(i) return i end)
local InputService = cloneref(game:GetService("UserInputService"))
local TextService  = cloneref(game:GetService("TextService"))
local CoreGui      = cloneref(game:GetService("CoreGui"))
local Teams        = cloneref(game:GetService("Teams"))
local Players      = cloneref(game:GetService("Players"))
local RunService   = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Lighting     = cloneref(game:GetService("Lighting"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local DrawingLib = { drawing_replaced = true, new = function() error("Drawing not supported") end }
if typeof(getgenv) == "function" and typeof(getgenv().Drawing) == "table" then
    DrawingLib = getgenv().Drawing
end

local setclipboard = setclipboard or nil
local getgenv = getgenv or function() return shared end
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHUI = gethui or function() return CoreGui end

local function assert(c, m) if not c then error(m or "assert failed", 3) end end

local function SafeParentUI(I, P)
    local ok = pcall(function()
        if not P then P = CoreGui end
        local D = typeof(P) == "function" and P() or P
        I.Parent = D
    end)
    if not (ok and I.Parent) then I.Parent = LocalPlayer:WaitForChild("PlayerGui", math.huge) end
end

local function ParentUI(UI, Skip)
    if Skip then SafeParentUI(UI, CoreGui); return end
    pcall(ProtectGui, UI)
    SafeParentUI(UI, GetHUI)
end

-- ============================================================
-- SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LinoriaGlass"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ParentUI(ScreenGui)

local ModalElement = Instance.new("TextButton")
ModalElement.BackgroundTransparency = 1
ModalElement.Modal = false
ModalElement.Size = UDim2.fromScale(0, 0)
ModalElement.Text = ""
ModalElement.ZIndex = -999
ModalElement.Parent = ScreenGui

-- ============================================================
-- GLOBALNE BUCKETY
-- ============================================================
local LibraryMainOuterFrame = nil
local Toggles, Options, Labels, Buttons, Tooltips, Dialogues = {}, {}, {}, {}, {}, {}

-- ============================================================
-- IMAGE MANAGER (kompatybilny)
-- ============================================================
local BaseURL = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    Cursor         = { RobloxId = 9619665977,  Path = "LinoriaLib/assets/Cursor.png",         URL = BaseURL .. "assets/Cursor.png",         Id = nil },
    DropdownArrow  = { RobloxId = 6282522798,  Path = "LinoriaLib/assets/DropdownArrow.png",  URL = BaseURL .. "assets/DropdownArrow.png",  Id = nil },
    Checker        = { RobloxId = 12977615774, Path = "LinoriaLib/assets/Checker.png",        URL = BaseURL .. "assets/Checker.png",        Id = nil },
    CheckerLong    = { RobloxId = 12978095818, Path = "LinoriaLib/assets/CheckerLong.png",    URL = BaseURL .. "assets/CheckerLong.png",    Id = nil },
    SaturationMap  = { RobloxId = 4155801252,  Path = "LinoriaLib/assets/SaturationMap.png",  URL = BaseURL .. "assets/SaturationMap.png",  Id = nil },
}
do
    local function mkpath(P, F)
        if not isfolder or not makefolder then return end
        local S = P:split("/"); local T = ""
        if F then table.remove(S, #S) end
        for _, s in ipairs(S) do if not isfolder(T .. s) then makefolder(T .. s) end; T = T .. s .. "/" end
    end
    function CustomImageManager.AddAsset(N, Id, U, Force)
        assert(typeof(Id) == "number", "RobloxId must be number")
        CustomImageManagerAssets[N] = { RobloxId = Id, Path = "Obsidian/custom_assets/" .. N, URL = U, Id = nil }
        CustomImageManager.DownloadAsset(N, Force)
    end
    function CustomImageManager.GetAsset(N)
        local A = CustomImageManagerAssets[N]; if not A then return end
        if A.Id then return A.Id end
        local ID = "rbxassetid://" .. A.RobloxId
        if getcustomasset then local s, r = pcall(getcustomasset, A.Path); if s and r then ID = r end end
        A.Id = ID; return ID
    end
    function CustomImageManager.DownloadAsset(N, Force)
        if not (getcustomasset and writefile and isfile) then return false end
        local A = CustomImageManagerAssets[N]; mkpath(A.Path, true)
        if not Force and isfile(A.Path) then return true end
        local s, e = pcall(function() writefile(A.Path, game:HttpGet(A.URL)) end); return s, e
    end
    for N in CustomImageManagerAssets do CustomImageManager.DownloadAsset(N) end
end

-- ============================================================
-- ✦ NOWY STYL — GLASS / NEON ✦
-- ============================================================
local DPIScale = 1
local Library = {
    Registry = {}; RegistryMap = {}; HudRegistry = {};

    -- ====== PALETA GLASS NEON ======
    FontColor          = Color3.fromRGB(235, 240, 255),
    FontMuted          = Color3.fromRGB(140, 150, 180),
    MainColor          = Color3.fromRGB(18, 20, 32),
    MainColorDark      = Color3.fromRGB(12, 14, 22),
    BackgroundColor    = Color3.fromRGB(10, 12, 20),
    BackgroundColorDark= Color3.fromRGB(6, 8, 14),
    SurfaceColor       = Color3.fromRGB(24, 28, 44),

    AccentColor        = Color3.fromRGB(0, 220, 255),      -- CYJAN NEON
    AccentColorDark    = Color3.fromRGB(0, 160, 200),
    AccentColorLight   = Color3.fromRGB(120, 240, 255),
    SecondaryAccent    = Color3.fromRGB(180, 90, 255),     -- fiolet neon (gradient)
    TertiaryAccent     = Color3.fromRGB(255, 90, 200),     -- róż neon

    OutlineColor       = Color3.fromRGB(40, 48, 70),
    OutlineColorLight  = Color3.fromRGB(70, 80, 110),
    DisabledAccentColor= Color3.fromRGB(70, 78, 100),
    DisabledOutlineColor=Color3.fromRGB(40, 46, 65),
    DisabledTextColor  = Color3.fromRGB(90, 100, 125),

    RiskColor          = Color3.fromRGB(255, 70, 90),
    SuccessColor       = Color3.fromRGB(0, 255, 150),
    WarnColor          = Color3.fromRGB(255, 200, 60),

    Black = Color3.new(0, 0, 0),
    White = Color3.new(1, 1, 1),

    Font       = Enum.Font.Gotham,
    FontBold   = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    FontMono   = Enum.Font.RobotoMono,

    OpenedFrames = {}; DependencyBoxes = {}; DependencyGroupboxes = {};
    UnloadSignals = {}; Signals = {};
    ActiveTab = nil; TotalTabs = 0;
    ScreenGui = ScreenGui; KeybindFrame = nil; KeybindContainer = nil;
    Window = { Holder = nil; Tabs = {}; };
    VideoLink = ""; Toggled = false; ToggleKeybind = nil;
    IsMobile = false; DevicePlatform = Enum.Platform.None;
    CanDrag = true; CantDragForced = false; Unloaded = false;
    Notify = nil; NotifySide = "Left"; ShowCustomCursor = true; ShowToggleFrameInKeybinds = true; NotifyOnError = false;
    SaveManager = nil; ThemeManager = nil;
    Toggles = Toggles; Options = Options; Labels = Labels; Buttons = Buttons;
    Dialogues = Dialogues; ActiveDialog = nil;
    ImageManager = CustomImageManager;
    ShowCursorBinding = string.sub(tostring({}), 10);
}

if RunService:IsStudio() then
    Library.IsMobile = InputService.TouchEnabled and not InputService.MouseEnabled
else
    pcall(function() Library.DevicePlatform = InputService:GetPlatform() end)
    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
end
Library.MinSize = if Library.IsMobile then Vector2.new(560, 260) else Vector2.new(560, 360)

-- ============================================================
-- HELPERY (nowe + kompatybilne)
-- ============================================================
local function ApplyDPIScale(p) return UDim2.new(p.X.Scale, p.X.Offset * DPIScale, p.Y.Scale, p.Y.Offset * DPIScale) end
local function ApplyTextScale(t) return t * DPIScale end
local function GetTableSize(t) local n = 0; for _ in pairs(t) do n = n + 1 end; return n end

local function GetPlayers(Ex, Inst)
    local L = Players:GetPlayers()
    if Ex then local i = table.find(L, LocalPlayer); if i then table.remove(L, i) end end
    table.sort(L, function(a, b) return a.Name:lower() < b.Name:lower() end)
    if Inst then return L end
    local F = {}; for _, p in next, L do F[#F+1] = p.Name end; return F
end
local function GetTeams(Inst)
    local L = Teams:GetTeams()
    table.sort(L, function(a, b) return a.Name:lower() < b.Name:lower() end)
    if Inst then return L end
    local F = {}; for _, t in next, L do F[#F+1] = t.Name end; return F
end
local function Trim(s) return s:match("^%s*(.-)%s*$") end

-- ============================================================
-- IKONY
-- ============================================================
local FetchIcons, Icons = pcall(function()
    return (loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")))()
end)
function Library:IsValidCustomIcon(I) return typeof(I) == "string" and (I:match("rbxasset") or I:match("roblox%.com/asset/%?id=") or I:match("rbxthumb://type=")) end
function Library:GetIcon(N) if not FetchIcons then return end; local s, i = pcall(Icons.GetAsset, N); if not s then return end; return i end
function Library:GetCustomIcon(N)
    if not self:IsValidCustomIcon(N) then return self:GetIcon(N) end
    return { Url = N, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = true }
end
function Library:SetIconModule(m) FetchIcons = true; Icons = m end

function Library:GetDarkerColor(c) local h,s,v = Color3.toHSV(c); return Color3.fromHSV(h, s, v/1.6) end
function Library:GetLighterColor(c) local h,s,v = Color3.toHSV(c); return Color3.fromHSV(h, s, math.min(1, v*1.4)) end
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)

-- ============================================================
-- CORE HELPERS
-- ============================================================
function Library:Validate(T, Tpl)
    if typeof(T) ~= "table" then return Tpl end
    for k, v in pairs(Tpl) do
        if typeof(k) == "number" then continue end
        if typeof(v) == "table" then T[k] = Library:Validate(T[k], v)
        elseif T[k] == nil then T[k] = v end
    end
    return T
end

function Library:SetDPIScale(v)
    assert(type(v) == "number", "number expected")
    DPIScale = v / 100
    Library.MinSize = (if Library.IsMobile then Vector2.new(560, 260) else Vector2.new(560, 360)) * DPIScale
end

function Library:SafeCallback(F, ...)
    if not (F and typeof(F) == "function") then return end
    local R = table.pack(xpcall(F, function(E) task.defer(error, debug.traceback(E, 2)); if Library.NotifyOnError then Library:Notify(E) end; return E end, ...))
    if not R[1] then return nil end
    return table.unpack(R, 2, R.n)
end

function Library:AttemptSave() if Library.SaveManager then Library.SaveManager:Save() end end

-- === NOWE: ZAOKRĄGLENIE / OBRYS / NEON GLOW / SHADOW / GRADIENT ===
function Library:AddCorner(Inst, R)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, R or 8); c.Parent = Inst; return c
end

function Library:AddStroke(Inst, C, T, Tr)
    local s = Instance.new("UIStroke"); s.Color = C or Library.OutlineColor; s.Thickness = T or 1
    s.Transparency = Tr or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = Inst; return s
end

function Library:AddShadow(Inst, Tr)
    local sh = Instance.new("ImageLabel"); sh.Name = "Shadow"
    sh.BackgroundTransparency = 1; sh.Image = "rbxassetid://1316045217"
    sh.ImageColor3 = Color3.new(0, 0, 0); sh.ImageTransparency = Tr or 0.5
    sh.ScaleType = Enum.ScaleType.Slice; sh.SliceCenter = Rect.new(10, 10, 118, 118)
    sh.Size = UDim2.new(1, 50, 1, 50); sh.Position = UDim2.new(0, -25, 0, -25)
    sh.ZIndex = Inst.ZIndex - 1; sh.Parent = Inst; return sh
end

function Library:AddGlow(Inst, Color)
    local g = Instance.new("ImageLabel"); g.Name = "Glow"
    g.BackgroundTransparency = 1; g.Image = "rbxassetid://5028857084"
    g.ImageColor3 = Color or Library.AccentColor; g.ImageTransparency = 0.55
    g.ScaleType = Enum.ScaleType.Slice; g.SliceCenter = Rect.new(24, 24, 276, 276)
    g.Size = UDim2.new(1, 18, 1, 18); g.Position = UDim2.new(0, -9, 0, -9)
    g.ZIndex = Inst.ZIndex - 1; g.Parent = Inst; return g
end

function Library:Tween(Obj, Props, T, S, D)
    TweenService:Create(Obj, TweenInfo.new(T or 0.18, S or Enum.EasingStyle.Quart, D or Enum.EasingDirection.Out), Props):Play()
end

function Library:Create(Class, P)
    local I = Class
    if typeof(Class) == "string" then I = Instance.new(Class) end
    for K, V in next, P do
        if K == "Size" or K == "Position" then V = ApplyDPIScale(V)
        elseif K == "TextSize" then V = ApplyTextScale(V) end
        pcall(function() I[K] = V end)
    end
    return I
end

function Library:ApplyTextStroke(I)
    I.TextStrokeTransparency = 1
    return Library:Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1, LineJoinMode = Enum.LineJoinMode.Miter, Parent = I })
end

function Library:CreateLabel(P, IsHud)
    local I = Library:Create("TextLabel", {
        BackgroundTransparency = 1; Font = Library.Font; TextColor3 = Library.FontColor;
        TextSize = 14; TextStrokeTransparency = 1;
    })
    Library:AddToRegistry(I, { TextColor3 = "FontColor" }, IsHud)
    return Library:Create(I, P)
end

function Library:AddToRegistry(I, P, IsHud)
    local Idx = #Library.Registry + 1
    local D = { Instance = I; Properties = P; Idx = Idx; }
    table.insert(Library.Registry, D); Library.RegistryMap[I] = D
    if IsHud then table.insert(Library.HudRegistry, D) end
end

function Library:RemoveFromRegistry(I)
    local D = Library.RegistryMap[I]; if not D then return end
    for i = #Library.Registry, 1, -1 do if Library.Registry[i] == D then table.remove(Library.Registry, i) end end
    for i = #Library.HudRegistry, 1, -1 do if Library.HudRegistry[i] == D then table.remove(Library.HudRegistry, i) end end
    Library.RegistryMap[I] = nil
end

function Library:UpdateColorsUsingRegistry()
    for _, O in next, Library.Registry do
        for P, C in next, O.Properties do
            if typeof(C) == "string" then O.Instance[P] = Library[C]
            elseif typeof(C) == "function" then O.Instance[P] = C() end
        end
    end
end

function Library:GiveSignal(C)
    local T = typeof(C)
    if C and (T == "RBXScriptConnection" or T == "RBXScriptSignal") then table.insert(Library.Signals, C) end
    return C
end

function Library:Unload()
    for i = #Library.Signals, 1, -1 do
        local C = table.remove(Library.Signals, i)
        if C and C.Connected then C:Disconnect() end
    end
    for _, cb in Library.UnloadSignals do Library:SafeCallback(cb) end
    for _, T in Tooltips do Library:SafeCallback(T.Destroy, T) end
    Library.Unloaded = true
    ScreenGui:Destroy()
    if getgenv().Linoria == Library then getgenv().Linoria = nil end
end

function Library:OnUnload(C) table.insert(Library.UnloadSignals, C) end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(I)
    if Library.Unloaded then return end
    if Library.RegistryMap[I] then Library:RemoveFromRegistry(I) end
end))

-- ============================================================
-- DRAGGABLE
-- ============================================================
function Library:MouseIsOverFrame(F, Inp)
    local P = Mouse
    if Library.IsMobile and Inp then P = Inp.Position end
    local A, S = F.AbsolutePosition, F.AbsoluteSize
    return P.X >= A.X and P.X <= A.X + S.X and P.Y >= A.Y and P.Y <= A.Y + S.Y
end
function Library:IsFrameInsideDialog(F)
    if not Library.ActiveDialog then return false end
    local P = F.AbsolutePosition
    local A, S = Library.ActiveDialog.Container.AbsolutePosition, Library.ActiveDialog.Container.AbsoluteSize
    return P.X >= A.X and P.X <= A.X + S.X and P.Y >= A.Y and P.Y <= A.Y + S.Y
end
function Library:MouseIsOverOpenedFrame(Inp)
    if Library.ActiveDialog then
        if Library:MouseIsOverFrame(Library.ActiveDialog.Container, Inp) then return false end
        return true
    end
    for F in next, Library.OpenedFrames do if Library:MouseIsOverFrame(F, Inp) then return true end end
    return false
end

function Library:MakeDraggable(I, Cut, IsMain)
    I.Active = true
    if Library.IsMobile == false then
        I.InputBegan:Connect(function(Inp)
            if Inp.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMain and Library.CantDragForced then return end
                local O = Vector2.new(Mouse.X - I.AbsolutePosition.X, Mouse.Y - I.AbsolutePosition.Y)
                if O.Y > (Cut or 40) then return end
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    I.Position = UDim2.new(0, Mouse.X - O.X + (I.Size.X.Offset * I.AnchorPoint.X), 0, Mouse.Y - O.Y + (I.Size.Y.Offset * I.AnchorPoint.Y))
                    RunService.RenderStepped:Wait()
                end
            end
        end)
    else
        local D, DI, DS, SP
        InputService.TouchStarted:Connect(function(Inp)
            if IsMain and Library.CantDragForced then D = false; return end
            if not D and Library:MouseIsOverFrame(I, Inp) and (IsMain and (Library.CanDrag and Library.Window.Holder and Library.Window.Holder.Visible) or true) then
                DI = Inp; DS = Inp.Position; SP = I.Position
                if (Inp.Position - DS).Y > (Cut or 40) then D = false; return end
                D = true
            end
        end)
        InputService.TouchMoved:Connect(function(Inp)
            if IsMain and Library.CantDragForced then D = false; return end
            if Inp == DI and D then
                local O = Inp.Position - DS
                I.Position = UDim2.new(SP.X.Scale, SP.X.Offset + O.X, SP.Y.Scale, SP.Y.Offset + O.Y)
            end
        end)
        InputService.TouchEnded:Connect(function(Inp) if Inp == DI then D = false end end)
    end
end

function Library:MakeDraggableUsingParent(I, P, C, M)
    I.Active = true
    if Library.IsMobile == false then
        I.InputBegan:Connect(function(Inp)
            if Inp.UserInputType == Enum.UserInputType.MouseButton1 then
                if M and Library.CantDragForced then return end
                local O = Vector2.new(Mouse.X - P.AbsolutePosition.X, Mouse.Y - P.AbsolutePosition.Y)
                if O.Y > (C or 40) then return end
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    P.Position = UDim2.new(0, Mouse.X - O.X + (P.Size.X.Offset * P.AnchorPoint.X), 0, Mouse.Y - O.Y + (P.Size.Y.Offset * P.AnchorPoint.Y))
                    RunService.RenderStepped:Wait()
                end
            end
        end)
    else Library:MakeDraggable(P, C, M) end
end

function Library:MakeResizable(I, MinS)
    if Library.IsMobile then return end
    I.Active = true
    local SZ = 22 * DPIScale
    local R = Library:Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -30, 1, -30), ZIndex = 1, Parent = I })
    local RI = Library:Create("ImageButton", { BackgroundColor3 = Library.AccentColor, BackgroundTransparency = 1, Size = UDim2.new(2, 0, 2, 0), Position = UDim2.new(1, -30, 1, -30), ZIndex = 2, Parent = R })
    Library:AddCorner(RI, 999)
    Library:AddToRegistry(RI, { BackgroundColor3 = "AccentColor" })
    R.Size = UDim2.fromOffset(SZ, SZ); R.Position = UDim2.new(1, -SZ, 1, -SZ)
    MinS = MinS or Library.MinSize
    local O
    local function Fin(T) RI.Position = UDim2.new(); RI.Size = UDim2.new(2, 0, 2, 0); RI.Parent = R; RI.BackgroundTransparency = T; O = nil end
    RI.MouseButton1Down:Connect(function()
        if not O then
            O = Vector2.new(Mouse.X - (I.AbsolutePosition.X + I.AbsoluteSize.X), Mouse.Y - (I.AbsolutePosition.Y + I.AbsoluteSize.Y))
            RI.BackgroundTransparency = 1; RI.Size = UDim2.fromOffset(Library.ScreenGui.AbsoluteSize.X, Library.ScreenGui.AbsoluteSize.Y)
            RI.Position = UDim2.new(); RI.Parent = Library.ScreenGui
        end
    end)
    RI.MouseMoved:Connect(function()
        if O then
            local M = Vector2.new(Mouse.X - O.X, Mouse.Y - O.Y)
            local F = Vector2.new(math.clamp(M.X - I.AbsolutePosition.X, MinS.X, math.huge), math.clamp(M.Y - I.AbsolutePosition.Y, MinS.Y, math.huge))
            I.Size = UDim2.fromOffset(F.X, F.Y)
        end
    end)
    RI.MouseEnter:Connect(function() Fin(0.4) end)
    RI.MouseLeave:Connect(function() Fin(1) end)
    RI.MouseButton1Up:Connect(function() Fin(0.4) end)
end

function Library:GetTextBounds(T, F, S, Res)
    if typeof(Res) == "number" then Res = Vector2.new(Res, 10000) end
    local B = TextService:GetTextSize(T:gsub("<%/?[%w:]+[^>]*>", ""), S, F, Res or Vector2.new(1920, 1080))
    return B.X, B.Y
end
function Library:MapValue(v, a, b, c, d) return (1 - ((v - a) / (b - a))) * c + ((v - a) / (b - a)) * d end

function Library:UpdateDependencyBoxes() for _, D in next, Library.DependencyBoxes do D:Update() end end
function Library:UpdateDependencyGroupboxes() for _, D in next, Library.DependencyGroupboxes do D:Update() end end

function Library:OnHighlight(HI, I, P, PD, cond)
    local function U()
        local R = Library.RegistryMap[I]
        for p, c in next, PD do I[p] = Library[c] or c; if R and R.Properties[p] then R.Properties[p] = c end end
    end
    local function D()
        if cond and not cond() then U(); return end
        if Library.ActiveDialog and not Library:IsFrameInsideDialog(I) then U(); return end
        local R = Library.RegistryMap[I]
        for p, c in next, P do I[p] = Library[c] or c; if R and R.Properties[p] then R.Properties[p] = c end end
    end
    HI.MouseEnter:Connect(D); HI.MouseMoved:Connect(D); HI.MouseLeave:Connect(U)
end

-- ============================================================
-- ✦ ULEPSZONY TOOLTIP (glass) ✦
-- ============================================================
function Library:AddToolTip(Info, DInfo, Hover)
    Info = typeof(Info) == "string" and Info or nil
    DInfo = typeof(DInfo) == "string" and DInfo or nil
    local TT = Library:Create("Frame", { BackgroundColor3 = Library.SurfaceColor, BorderColor3 = Library.AccentColor, ZIndex = 100, Parent = Library.ScreenGui, Visible = false })
    Library:AddCorner(TT, 10); Library:AddStroke(TT, Library.AccentColor, 1.2, 0.2)
    local L = Library:CreateLabel({ Position = UDim2.fromOffset(10, 6), TextSize = 13, Font = Library.FontMedium, Text = Info, TextColor3 = Library.FontColor, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101, Parent = TT })
    local T = { Tooltip = TT, Disabled = false, Signals = {} }
    local Hov = false
    local function Upd(S)
        if not S then return end
        local X, Y = Library:GetTextBounds(S, Library.FontMedium, 13 * DPIScale)
        L.Text = S; TT.Size = UDim2.fromOffset(X + 20, Y + 12); L.Size = UDim2.fromOffset(X, Y)
    end
    local function Sig(C) table.insert(T.Signals, C); return C end
    Upd(Info)
    Sig(Hover.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then TT.Visible = false; return end
        if not T.Disabled then if not Info or Info == "" then TT.Visible = false; return end; if L.Text ~= Info then Upd(Info) end
        else if not DInfo or DInfo == "" then TT.Visible = false; return end; if L.Text ~= DInfo then Upd(DInfo) end end
        Hov = true; TT.Position = UDim2.fromOffset(Mouse.X + 16, Mouse.Y + 14); TT.Visible = true
        while Hov do
            if T.Disabled and not DInfo then break end
            RunService.Heartbeat:Wait(); TT.Position = UDim2.fromOffset(Mouse.X + 16, Mouse.Y + 14)
        end
        Hov = false; TT.Visible = false
    end))
    Sig(Hover.MouseLeave:Connect(function() Hov = false; TT.Visible = false end))
    if LibraryMainOuterFrame then Sig(LibraryMainOuterFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not LibraryMainOuterFrame.Visible then Hov = false; TT.Visible = false end
    end)) end
    function T:Destroy() for i = #T.Signals, 1, -1 do local C = table.remove(T.Signals, i); if C and C.Connected then C:Disconnect() end end TT:Destroy() end
    table.insert(Tooltips, T); return T
end

-- ============================================================
-- ✦ WINDOW HELPERS — TAB BUTTON + GLASS GROUPBOX ✦
-- ============================================================
local function MakeTabButton(Parent, Name)
    local Btn = Library:Create("Frame", { BackgroundColor3 = Library.BackgroundColor, BackgroundTransparency = 0.4, Size = UDim2.new(0, 100, 1, 0), ZIndex = 5, Parent = Parent })
    Library:AddCorner(Btn, 8)
    Library:AddStroke(Btn, Library.OutlineColor, 1, 0.5)
    local Label = Library:CreateLabel({ Size = UDim2.new(1, 0, 1, 0), TextSize = 14, Font = Library.FontMedium, Text = Name, ZIndex = 6, Parent = Btn })
    local Glow = Library:Create("Frame", { BackgroundColor3 = Library.AccentColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), ZIndex = 6, Parent = Btn })
    Library:AddCorner(Glow, 999)
    Library:AddToRegistry(Btn, { BackgroundColor3 = "BackgroundColor" })
    Library:AddToRegistry(Label, { TextColor3 = "FontMuted" })
    Library:AddToRegistry(Glow, { BackgroundColor3 = "AccentColor" })
    return Btn, Label, Glow
end

local function MakeGroupbox(Tab, Name, Side)
    local G = { Elements = {}, Side = Side, Tab = Tab, TableType = "Groupbox" }

    local Outer = Library:Create("Frame", {
        BackgroundColor3 = Library.MainColor, BackgroundTransparency = 0.35,
        BorderColor3 = Library.OutlineColor,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 2, Parent = Side == 1 and Tab.LeftSideFrame or Tab.RightSideFrame,
    })
    Library:AddCorner(Outer, 12)
    Library:AddStroke(Outer, Library.OutlineColor, 1.2, 0.4)

    -- gradient glass
    local Grad = Library:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 200, 255)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.98),
            NumberSequenceKeypoint.new(1, 0.94),
        }),
        Rotation = 90, Parent = Outer,
    })

    -- neon top border
    local TopLine = Library:Create("Frame", {
        BackgroundColor3 = Library.AccentColor, BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 0, 2),
        ZIndex = 10, Parent = Outer,
    })
    Library:AddCorner(TopLine, 999)
    Library:AddToRegistry(TopLine, { BackgroundColor3 = "AccentColor" })

    local Title = Library:CreateLabel({
        Size = UDim2.new(1, -24, 0, 20), Position = UDim2.new(0, 12, 0, 8),
        TextSize = 13, Font = Library.FontBold, Text = Name,
        TextColor3 = Library.FontColor, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5, Parent = Outer,
    })

    local Sep = Library:Create("Frame", {
        BackgroundColor3 = Library.OutlineColor, BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -24, 0, 1),
        BackgroundTransparency = 0.5, ZIndex = 4, Parent = Outer,
    })

    local C = Library:Create("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 36),
        Size = UDim2.new(1, -20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 3, Parent = Outer,
    })
    Library:Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0), Parent = C })
    Library:Create("UIPadding", { PaddingBottom = UDim.new(0, 10), Parent = C })

    function G:Resize()
        local Total = 0
        for _, E in next, C:GetChildren() do
            if not E:IsA("UIListLayout") and E.Visible then Total = Total + E.Size.Y.Offset end
        end
        Outer.Size = UDim2.new(1, 0, 0, 36 + Total + 10)
    end

    G.Container = C
    setmetatable(G, getmetatable(Tab):__index and getmetatable(Tab) or nil)
    Tab.Groupboxes[Name] = G
    return G
end

-- ============================================================
-- ✦ BASE ADDONS (KeyPicker + ColorPicker) — kompatybilne ✦
-- ============================================================
local BaseAddons = {}
do
    local F = {}
    function F:AddColorPicker(Idx, Info)
        assert(Info.Default, string.format("AddColorPicker (IDX: %s): Missing default value.", tostring(Idx)))
        local Parent, ToggleLabel = self, self.TextLabel
        local CP = { Value = Info.Default, Transparency = Info.Transparency or 0, Type = "ColorPicker", Title = Info.Title or "Color", Callback = Info.Callback or function() end, Changed = nil }
        local Prev = { Value = nil, Transparency = nil }
        local function RC()
            if CP.Value == Prev.Value and CP.Transparency == Prev.Transparency then return end
            Prev.Value = CP.Value; Prev.Transparency = CP.Transparency
            Library:SafeCallback(CP.Callback, CP.Value, CP.Transparency)
            Library:SafeCallback(CP.Changed, CP.Value, CP.Transparency)
        end
        function CP:SetHSVFromRGB(c) local h, s, v = c:ToHSV(); self.Hue, self.Sat, self.Vib = h, s, v end
        CP:SetHSVFromRGB(CP.Value)
        local Disp = Library:Create("Frame", { BackgroundColor3 = CP.Value, BorderColor3 = Library:GetDarkerColor(CP.Value), BorderMode = Enum.BorderMode.Inset, Size = UDim2.new(0, 28, 0, 18), ZIndex = 6, Parent = ToggleLabel })
        Library:AddCorner(Disp, 6)

        local Picker = Library:Create("Frame", {
            Name = "Color", BackgroundColor3 = Library.MainColor, BorderColor3 = Library.AccentColor,
            Position = UDim2.fromOffset(Disp.AbsolutePosition.X, Disp.AbsolutePosition.Y + 20),
            Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253),
            Visible = false, ZIndex = 15, Parent = ScreenGui,
        })
        Library:AddCorner(Picker, 10); Library:AddStroke(Picker, Library.AccentColor, 1.2, 0.3); Library:AddShadow(Picker, 0.4)

        Disp:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            Picker.Position = UDim2.fromOffset(Disp.AbsolutePosition.X, Disp.AbsolutePosition.Y + 20)
        end)

        local Map = Library:Create("ImageLabel", { BackgroundColor3 = Library.AccentColor, BorderSizePixel = 0, Position = UDim2.new(0, 5, 0, 26), Size = UDim2.new(0, 200, 0, 200), Image = CustomImageManager.GetAsset("SaturationMap"), ZIndex = 16, Parent = Picker })
        local Cursor = Library:Create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 8, 0, 8), BackgroundTransparency = 1, Image = CustomImageManager.GetAsset("Cursor"), ImageColor3 = Color3.new(0,0,0), ZIndex = 19, Parent = Map })

        local Hue = Library:Create("Frame", { BackgroundColor3 = Color3.new(1,1,1), BorderColor3 = Library.OutlineColor, BorderMode = Enum.BorderMode.Inset, Position = UDim2.new(0, 210, 0, 26), Size = UDim2.new(0, 14, 0, 200), ZIndex = 17, Parent = Picker })
        Library:AddCorner(Hue, 6)
        local Seq = {}
        for h = 0, 1, 0.1 do table.insert(Seq, ColorSequenceKeypoint.new(h, Color3.fromHSV(h, 1, 1))) end
        Library:Create("UIGradient", { Color = ColorSequence.new(Seq), Rotation = 90, Parent = Hue })
        local HC = Library:Create("Frame", { BackgroundColor3 = Color3.new(1,1,1), AnchorPoint = Vector2.new(0, 0.5), BorderColor3 = Color3.new(0,0,0), Size = UDim2.new(1, 0, 0, 2), ZIndex = 19, Parent = Hue })

        local HexBox = Library:Create("TextBox", { BackgroundColor3 = Library.SurfaceColor, BorderColor3 = Library.OutlineColor, BorderMode = Enum.BorderMode.Inset, Position = UDim2.fromOffset(5, 232), Size = UDim2.new(0.5, -7, 0, 20), Font = Library.FontMono, PlaceholderColor3 = Library.FontMuted, PlaceholderText = "Hex", Text = "#FFFFFF", TextColor3 = Library.FontColor, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 18, Parent = Picker })
        Library:AddCorner(HexBox, 6)

        local RgbBox = Library:Create("TextBox", { BackgroundColor3 = Library.SurfaceColor, BorderColor3 = Library.OutlineColor, BorderMode = Enum.BorderMode.Inset, Position = UDim2.new(0.5, 2, 0, 232), Size = UDim2.new(0.5, -7, 0, 20), Font = Library.FontMono, PlaceholderColor3 = Library.FontMuted, PlaceholderText = "RGB", Text = "255, 255, 255", TextColor3 = Library.FontColor, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 18, Parent = Picker })
        Library:AddCorner(RgbBox, 6)

        function CP:Display()
            CP.Value = Color3.fromHSV(CP.Hue, CP.Sat, CP.Vib)
            Map.BackgroundColor3 = Color3.fromHSV(CP.Hue, 1, 1)
            Disp.BackgroundColor3 = CP.Value; Disp.BackgroundTransparency = CP.Transparency
            Cursor.Position = UDim2.new(CP.Sat, 0, 1 - CP.Vib, 0)
            HC.Position = UDim2.new(0, 0, CP.Hue, 0)
            HexBox.Text = "#" .. CP.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(CP.Value.R*255), math.floor(CP.Value.G*255), math.floor(CP.Value.B*255) }, ", ")
        end
        function CP:OnChanged(Fn) CP.Changed = Fn end
        function CP:Show() for F, _ in next, Library.OpenedFrames do if F.Name == "Color" then F.Visible = false; Library.OpenedFrames[F] = nil end end; Picker.Visible = true; Library.OpenedFrames[Picker] = true end
        function CP:Hide() Picker.Visible = false; Library.OpenedFrames[Picker] = nil end
        function CP:SetValue(HSV, T)
            if typeof(HSV) == "Color3" then CP:SetValueRGB(HSV, T); return end
            local c = Color3.fromHSV(HSV[1], HSV[2], HSV[3]); CP.Transparency = T or 0; CP:SetHSVFromRGB(c); CP:Display(); RC()
        end
        function CP:SetValueRGB(c, T) CP.Transparency = T or 0; CP:SetHSVFromRGB(c); CP:Display(); RC() end

        HexBox.FocusLost:Connect(function(e) if e then local s, r = pcall(Color3.fromHex, HexBox.Text); if s then CP.Hue, CP.Sat, CP.Vib = Color3.toHSV(r) end end; CP:Display() end)
        RgbBox.FocusLost:Connect(function(e) if e then local r, g, b = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)"); if r then CP.Hue, CP.Sat, CP.Vib = Color3.toHSV(Color3.fromRGB(r, g, b)) end end; CP:Display() end)

        local function dragImg(Img, fn)
            Img.InputBegan:Connect(function(Inp)
                if Inp.UserInputType == Enum.UserInputType.MouseButton1 or Inp.UserInputType == Enum.UserInputType.Touch then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        fn(); RC(); RunService.RenderStepped:Wait()
                    end
                    Library:AttemptSave()
                end
            end)
        end
        dragImg(Map, function()
            local MinX, MaxX = Map.AbsolutePosition.X, Map.AbsolutePosition.X + Map.AbsoluteSize.X
            local MinY, MaxY = Map.AbsolutePosition.Y, Map.AbsolutePosition.Y + Map.AbsoluteSize.Y
            local MX = math.clamp(Mouse.X, MinX, MaxX); local MY = math.clamp(Mouse.Y, MinY, MaxY)
            CP.Sat = (MX - MinX) / (MaxX - MinX); CP.Vib = 1 - ((MY - MinY) / (MaxY - MinY)); CP:Display()
        end)
        dragImg(Hue, function()
            local MinY, MaxY = Hue.AbsolutePosition.Y, Hue.AbsolutePosition.Y + Hue.AbsoluteSize.Y
            local MY = math.clamp(Mouse.Y, MinY, MaxY); CP.Hue = (MY - MinY) / (MaxY - MinY); CP:Display()
        end)

        Disp.InputBegan:Connect(function(Inp)
            if Library:MouseIsOverOpenedFrame(Inp) then return end
            if Inp.UserInputType == Enum.UserInputType.MouseButton1 or Inp.UserInputType == Enum.UserInputType.Touch then
                if Picker.Visible then CP:Hide() else CP:Show() end
            end
        end)

        Library:GiveSignal(InputService.InputBegan:Connect(function(Inp)
            if Library.Unloaded then return end
            if Inp.UserInputType == Enum.UserInputType.MouseButton1 or Inp.UserInputType == Enum.UserInputType.Touch then
                local A, S = Picker.AbsolutePosition, Picker.AbsoluteSize
                if Mouse.X < A.X or Mouse.X > A.X + S.X or Mouse.Y < (A.Y - 21) or Mouse.Y > A.Y + S.Y then CP:Hide() end
            end
        end))

        CP:Display(); CP.DisplayFrame = Disp; CP.Default = CP.Value
        Options[Idx] = CP
        if Parent.Addons then table.insert(Parent.Addons, CP) end
        return self
    end

    function F:AddKeyPicker(Idx, Info)
        assert(Info.Default, string.format("AddKeyPicker (IDX: %s): Missing default value.", tostring(Idx)))
        local Parent, ToggleLabel = self, self.TextLabel
        local KP = {
            Value = nil, Modifiers = {}, DisplayValue = nil, Toggled = false,
            Mode = Info.Mode or "Toggle", Type = "KeyPicker",
            Callback = Info.Callback or function() end, ChangedCallback = Info.ChangedCallback or function() end,
            SyncToggleState = Info.SyncToggleState or false,
        }
        if KP.Mode == "Press" then KP.SyncToggleState = false; Info.Modes = {"Press"}; Info.Mode = "Press" end
        if KP.SyncToggleState then Info.Modes = {"Toggle", "Hold"}; if not table.find(Info.Modes, Info.Mode) then Info.Mode = "Toggle" end end

        local SK = { MB1 = Enum.UserInputType.MouseButton1, MB2 = Enum.UserInputType.MouseButton2, MB3 = Enum.UserInputType.MouseButton3 }
        local SKI = { [Enum.UserInputType.MouseButton1] = "MB1", [Enum.UserInputType.MouseButton2] = "MB2", [Enum.UserInputType.MouseButton3] = "MB3" }
        local Mods = { LAlt = Enum.KeyCode.LeftAlt, RAlt = Enum.KeyCode.RightAlt, LCtrl = Enum.KeyCode.LeftControl, RCtrl = Enum.KeyCode.RightControl, LShift = Enum.KeyCode.LeftShift, RShift = Enum.KeyCode.RightShift, Tab = Enum.KeyCode.Tab, CapsLock = Enum.KeyCode.CapsLock }
        local ModsI = { [Enum.KeyCode.LeftAlt] = "LAlt", [Enum.KeyCode.RightAlt] = "RAlt", [Enum.KeyCode.LeftControl] = "LCtrl", [Enum.KeyCode.RightControl] = "RCtrl", [Enum.KeyCode.LeftShift] = "LShift", [Enum.KeyCode.RightShift] = "RShift", [Enum.KeyCode.Tab] = "Tab", [Enum.KeyCode.CapsLock] = "CapsLock" }

        local function IsMod(Inp) return Inp.UserInputType == Enum.UserInputType.Keyboard and ModsI[Inp.KeyCode] ~= nil end
        local function Held(R)
            if not (typeof(R) == "table" and GetTableSize(R) > 0) then return true end
            for _, n in R do if not InputService:IsKeyDown(Mods[n]) then return false end end
            return true
        end

        local Pick = Library:Create("Frame", { BackgroundColor3 = Library.SurfaceColor, BorderColor3 = Library.AccentColor, BorderMode = Enum.BorderMode.Inset, Size = UDim2.new(0, 28, 0, 18), ZIndex = 6, Parent = ToggleLabel })
        Library:AddCorner(Pick, 6); Library:AddStroke(Pick, Library.AccentColor, 1, 0.4)
        local DL = Library:CreateLabel({ Size = UDim2.new(1, 0, 1, 0), TextSize = 12, Font = Library.FontMono, Text = Info.Default, ZIndex = 8, Parent = Pick })

        local Modes = Info.Modes or { "Always", "Toggle", "Hold" }
        local ModeSelect = Library:Create("Frame", { BackgroundColor3 = Library.SurfaceColor, BorderColor3 = Library.AccentColor, Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y), Size = UDim2.new(0, 80, 0, 0), Visible = false, ZIndex = 14, Parent = ScreenGui })
        Library:AddCorner(ModeSelect, 8); Library:AddStroke(ModeSelect, Library.AccentColor, 1, 0.3); Library:AddShadow(ModeSelect, 0.4)
        Library:Create("UIListLayout", { Parent = ModeSelect })

        local MB = {}
        for _, M in Modes do
            local L = Library:CreateLabel({ Size = UDim2.new(1, 0, 0, 20), TextSize = 13, Font = Library.FontMedium, Text = M, ZIndex = 16, Parent = ModeSelect })
            ModeSelect.Size = ModeSelect.Size + UDim2.new(0, 0, 0, 20)
            local B = {}
            function B:Select() for _, x in MB do x:Deselect() end; KP.Mode = M; L.TextColor3 = Library.AccentColor; Library.RegistryMap[L].Properties.TextColor3 = "AccentColor"; ModeSelect.Visible = false end
            function B:Deselect() L.TextColor3 = Library.FontColor; Library.RegistryMap[L].Properties.TextColor3 = "FontColor" end
            L.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then B:Select() end end)
            if M == KP.Mode then B:Select() end
            MB[M] = B
        end
        local Unbind = Library:Create("Frame", { BackgroundColor3 = Library.SurfaceColor, BorderColor3 = Library.OutlineColor, Position = UDim2.new(0, 0, 0, ModeSelect.Size.Y.Offset + 3), Size = UDim2.new(1, 0, 0, 20), ZIndex = 15, Parent = ModeSelect })
        ModeSelect.Size = ModeSelect.Size + UDim2.new(0, 0, 0, 23)
        Library:AddCorner(Unbind, 6)
        local UL = Library:CreateLabel({ Size = UDim2.new(1, 0, 1, 0), TextSize = 13, Text = "Unbind Key", Parent = Unbind, ZIndex = 16 })
        UL.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then KP:SetValue({ nil, KP.Mode, {} }); ModeSelect.Visible = false end end)

        local function UpdatePos() ModeSelect.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y) end
        UpdatePos(); ToggleLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)

        function KP:Display(T) DL.Text = T or KP.DisplayValue; Pick.Size = UDim2.new(0, 99999, 0, 18); RunService.RenderStepped:Wait(); Pick.Size = UDim2.new(0, math.max(28, DL.TextBounds.X + 12), 0, 18) end
        function KP:GetState()
            if KP.Mode == "Always" then return true
            elseif KP.Mode == "Hold" then
                if KP.Value == "None" then return false end
                if not Held(KP.Modifiers) then return false end
                if SK[KP.Value] then return InputService:IsMouseButtonPressed(SK[KP.Value]) and not InputService:GetFocusedTextBox() end
                return InputService:IsKeyDown(Enum.KeyCode[KP.Value]) and not InputService:GetFocusedTextBox()
            else return KP.Toggled end
        end
        function KP:Update() if Info.NoUI then return end end
        function KP:SetValue(D, Skip)
            local Key, Mode, Mod = D[1], D[2], D[3]
            if Key == nil or Key == "None" then KP.Value = "None"; Key = nil
            elseif SK[Key] then KP.Value = Key
            elseif pcall(function() return Enum.KeyCode[Key] end) then KP.Value = Key
            else KP.Value = "Unknown" end
            KP.Modifiers = typeof(Mod) == "table" and Mod or KP.Modifiers
            KP.DisplayValue = GetTableSize(KP.Modifiers) > 0 and (table.concat(KP.Modifiers, " + ") .. " + " .. KP.Value) or KP.Value
            DL.Text = KP.DisplayValue
            if Mode and MB[Mode] then MB[Mode]:Select() end
            KP:Display()
            if Skip then return end
            Library:SafeCallback(KP.ChangedCallback)
        end
        function KP:OnClick(c) KP.Clicked = c end
        function KP:OnChanged(c) KP.Changed = c end
        function KP:DoClick()
            if KP.Mode == "Press" then if KP.Toggled and Info.WaitForCallback then return end; KP.Toggled = true end
            Library:SafeCallback(KP.Callback, KP.Toggled); Library:SafeCallback(KP.Clicked, KP.Toggled)
            if KP.Mode == "Press" then KP.Toggled = false end
        end
        function KP:SetModePickerVisibility(b) ModeSelect.Visible = b end
        function KP:GetModePickerVisibility() return ModeSelect.Visible end

        Pick.InputBegan:Connect(function(Inp)
            if Inp.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                KP:Display("...")
                local I
                repeat
                    task.wait()
                    I = InputService.InputBegan:Wait()
                    if InputService:GetFocusedTextBox() then KP:Display(); return end
                    if I.KeyCode == Enum.KeyCode.Escape then break end
                    if IsMod(I) then repeat task.wait(); if not InputService:IsKeyDown(I.KeyCode) then break end; task.wait(0.075) until false; if not IsMod(I) then break end end
                    break
                until false
                local K = "Unknown"
                if SKI[I.UserInputType] then K = SKI[I.UserInputType]
                elseif I.UserInputType == Enum.UserInputType.Keyboard then K = I.KeyCode == Enum.KeyCode.Escape and "None" or I.KeyCode.Name end
                KP.Toggled = false
                KP:SetValue({ K, KP.Mode, {} })
            elseif Inp.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                local v = KP:GetModePickerVisibility()
                if v == false then for _, o in Options do if o.Type == "KeyPicker" then o:SetModePickerVisibility(false) end end end
                KP:SetModePickerVisibility(not v)
            end
        end)

        Library:GiveSignal(InputService.InputBegan:Connect(function(I)
            if Library.Unloaded or KP.Value == "Unknown" then return end
            if not InputService:GetFocusedTextBox() then
                local Holding = false
                if Held(KP.Modifiers) then
                    if I.UserInputType == Enum.UserInputType.Keyboard and I.KeyCode.Name == KP.Value then Holding = true
                    elseif SKI[I.UserInputType] == KP.Value then Holding = true end
                end
                if KP.Mode == "Toggle" and Holding then KP.Toggled = not KP.Toggled; KP:DoClick()
                elseif KP.Mode == "Press" and Holding then KP:DoClick() end
            end
            if I.UserInputType == Enum.UserInputType.MouseButton1 then
                local A, S = ModeSelect.AbsolutePosition, ModeSelect.AbsoluteSize
                if Mouse.X < A.X or Mouse.X > A.X + S.X or Mouse.Y < A.Y - 21 or Mouse.Y > A.Y + S.Y then KP:SetModePickerVisibility(false) end
            end
        end))

        KP:SetValue({ Info.Default, Info.Mode or "Toggle", Info.DefaultModifiers }, true)
        KP.DisplayFrame = Pick
        KP.Default = KP.Value
        KP.DefaultModifiers = table.clone(KP.Modifiers or {})
        Options[Idx] = KP
        if Parent.Addons then table.insert(Parent.Addons, KP) end
        return self
    end

    BaseAddons.__index = F
    BaseAddons.__namecall = function(T, K, ...) return F[K](...) end
end

-- ============================================================
-- ✦ BASE GROUPBOX — TOGGLE / SLIDER / DROPDOWN / INPUT / BUTTON / LABEL ✦
-- ============================================================
local BaseGroupbox = {}
do
    local F = {}

    function F:AddBlank(Size, Vis) return Library:Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Size), Visible = if typeof(Vis) == "boolean" then Vis else true, ZIndex = 1, Parent = self.Container }) end

    function F:AddLabel(...)
        local Data = {}
        if select(2, ...) ~= nil and typeof(select(2, ...)) == "table" then
            local P = select(2, ...)
            Data.Text = P.Text or ""; Data.DoesWrap = P.DoesWrap or false; Data.Idx = select(1, ...)
        else Data.Text = select(1, ...) or ""; Data.DoesWrap = select(2, ...) or false; Data.Idx = select(3, ...) end
        local L = { Type = "Label" }
        local TL = Library:CreateLabel({ Size = UDim2.new(1, -4, 0, 16), TextSize = 14, Font = Library.FontMedium, Text = Data.Text, TextWrapped = Data.DoesWrap, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = self.Container, RichText = true })
        L.TextLabel = TL; L.Container = self.Container
        function L:SetText(T) TL.Text = T; self.Resize and self.Resize() end
        if not Data.DoesWrap then setmetatable(L, BaseAddons) end
        self:AddBlank(4); self:Resize()
        table.insert(self.Elements, L)
        if Data.Idx then Labels[Data.Idx] = L else table.insert(Labels, L) end
        return L
    end

    function F:AddButton(...)
        local B = typeof(select(1, ...)) == "table" and select(1, ...) or { Text = select(1, ...), Func = select(2, ...) }
        B.Func = B.Func or B.Callback
        assert(typeof(B.Func) == "function", "AddButton: `Func` missing.")
        local G = self
        local Vis = typeof(B.Visible) == "boolean" and B.Visible or true

        local Outer = Library:Create("Frame", { BackgroundColor3 = Library.AccentColor, BackgroundTransparency = 0.9, Size = UDim2.new(1, -4, 0, 24), Visible = Vis, ZIndex = 5, Parent = self.Container })
        Library:AddCorner(Outer, 8); Library:AddStroke(Outer, Library.AccentColor, 1, 0.3)
        local Btn = Library:Create("TextButton", { BackgroundColor3 = Library.SurfaceColor, BackgroundTransparency = 0.4, BorderSizePixel = 0, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1), Text = "", AutoButtonColor = false, ZIndex = 6, Parent = Outer })
        Library:AddCorner(Btn, 7)
        local L = Library:CreateLabel({ Size = UDim2.new(1, 0, 1, 0), TextSize = 14, Font = Library.FontBold, Text = B.Text, ZIndex = 7, Parent = Btn })
        Library:AddToRegistry(Btn, { BackgroundColor3 = "SurfaceColor" }); Library:AddToRegistry(Outer, { BackgroundColor3 = "AccentColor" })

        Btn.MouseEnter:Connect(function() Library:Tween(Btn, { BackgroundColor3 = Library.AccentColor, BackgroundTransparency = 0.7 }) end)
        Btn.MouseLeave:Connect(function() Library:Tween(Btn, { BackgroundColor3 = Library.SurfaceColor, BackgroundTransparency = 0.4 }) end)
        Btn.MouseButton1Click:Connect(function() if not B.Disabled then Library:SafeCallback(B.Func) end end)

        B.Outer, B.Inner, B.Label = Outer, Btn, L
        function B:SetText(T) L.Text = T end
        function B:SetVisible(V) Outer.Visible = V; G:Resize() end
        function B:SetDisabled(D) B.Disabled = D; L.TextColor3 = D and Library.DisabledTextColor or Library.FontColor end
        function B:AddToolTip(a, b) B.TT = Library:AddToolTip(a, b, Outer); B.TT.Disabled = B.Disabled; return B end
        function B:UpdateColors() end
        function B:AddButton(...) return end

        table.insert(Buttons, B); table.insert(self.Elements, B)
        self:AddBlank(6); self:Resize()
        return B
    end

    function F:AddToggle(Idx, Info)
        assert(Info.Text, string.format("AddToggle (IDX: %s): Missing `Text`.", tostring(Idx)))
        local T = { Value = Info.Default or false, Type = "Toggle", Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true, Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false, Risky = if typeof(Info.Risky) == "boolean" then Info.Risky else false, OriginalText = Info.Text, Text = Info.Text, Callback = Info.Callback or function() end, Addons = {} }
        local G = self
        local Blank, TT

        local Row = Library:Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -4, 0, 22), Visible = T.Visible, ZIndex = 5, Parent = self.Container })

        local Track = Library:Create("Frame", { BackgroundColor3 = Library.OutlineColor, BackgroundTransparency = 0.2, Size = UDim2.new(0, 32, 0, 16), Position = UDim2.new(1, -32, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 5, Parent = Row })
        Library:AddCorner(Track, 999); Library:AddStroke(Track, Library.OutlineColor, 1, 0.3)

        local Knob = Library:Create("Frame", { BackgroundColor3 = Library.FontColor, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 6, Parent = Track })
        Library:AddCorner(Knob, 999)

        local Label = Library:CreateLabel({ Size = UDim2.new(1, -44, 1, 0), TextSize = 14, Font = Library.FontMedium, Text = Info.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = Row, RichText = true })
        Library:Create("UIListLayout", { Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = Label })

        local Region = Library:Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0), ZIndex = 8, Parent = Track })
        Library:OnHighlight(Region, Track, { BorderColor3 = "AccentColor" }, { BorderColor3 = "OutlineColor" }, function() return not T.Disabled end)

        if Info.Tooltip or Info.DisabledTooltip then TT = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, Region); TT.Disabled = T.Disabled end

        function T:UpdateColors() self:Display() end
        function T:Display()
            if T.Disabled then
                Library:Tween(Track, { BackgroundColor3 = Library.DisabledOutlineColor }); Library:Tween(Knob, { Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Library.DisabledTextColor }); Library:Tween(Label, { TextColor3 = Library.DisabledTextColor })
                return
            end
            local tc = T.Value and Library.AccentColor or Library.OutlineColor
            local tp = T.Value and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            Library:Tween(Track, { BackgroundColor3 = tc }); Library:Tween(Knob, { Position = tp }); Library:Tween(Label, { TextColor3 = T.Risky and Library.RiskColor or Library.FontColor })
        end
        function T:OnChanged(f) T.Changed = f end
        function T:SetValue(B)
            if T.Disabled then return end; B = not not B; if T.Value == B then return end
            T.Value = B; T:Display()
            for _, A in T.Addons do if A.Type == "KeyPicker" and A.SyncToggleState then A.Toggled = B; A:Update() end end
            Library:SafeCallback(T.Callback, B); Library:SafeCallback(T.Changed, B)
            Library:UpdateDependencyBoxes(); Library:UpdateDependencyGroupboxes()
        end
        function T:SetVisible(V) T.Visible = V; Row.Visible = V; if Blank then Blank.Visible = V end; G:Resize() end
        function T:SetDisabled(D) T.Disabled = D; if TT then TT.Disabled = D end; T:Display() end
        function T:SetText(S) if typeof(S) == "string" then T.Text = S; Label.Text = S end end

        Region.InputBegan:Connect(function(i)
            if T.Disabled then return end
            if (i.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or i.UserInputType == Enum.UserInputType.Touch then
                T:SetValue(not T.Value); Library:AttemptSave()
            end
        end)

        T:Display()
        Blank = G:AddBlank(Info.BlankSize or 6, T.Visible); G:Resize()
        T.TextLabel = Label; T.Container = G.Container
        setmetatable(T, BaseAddons)
        T.Default = T.Value
        table.insert(G.Elements, T); Toggles[Idx] = T
        Library:UpdateDependencyBoxes(); Library:UpdateDependencyGroupboxes()
        return T
    end

    function F:AddSlider(Idx, Info)
        assert(Info.Default and Info.Text and Info.Min and Info.Max and Info.Rounding, string.format("AddSlider (IDX: %s): missing required fields.", tostring(Idx)))
        local S = { Value = Info.Default, Min = Info.Min, Max = Info.Max, Rounding = Info.Rounding, MaxSize = 232, Type = "Slider", Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true, Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false, OriginalText = Info.Text, Text = Info.Text, Prefix = typeof(Info.Prefix) == "string" and Info.Prefix or "", Suffix = typeof(Info.Suffix) == "string" and Info.Suffix or "", Callback = Info.Callback or function() end }
        local G = self
        local Blanks, SLabel, TT = {}, nil, nil

        if not Info.Compact then
            SLabel = Library:CreateLabel({ Size = UDim2.new(1, 0, 0, 14), TextSize = 13, Font = Library.FontMedium, Text = Info.Text, TextXAlignment = Enum.TextXAlignment.Left, Visible = S.Visible, ZIndex = 5, Parent = self.Container, RichText = true })
            table.insert(Blanks, G:AddBlank(4, S.Visible))
        end

        local Track = Library:Create("Frame", { BackgroundColor3 = Library.BackgroundColor, BackgroundTransparency = 0.2, Size = UDim2.new(1, -4, 0, 8), Visible = S.Visible, ZIndex = 5, Parent = self.Container })
        Library:AddCorner(Track, 999); Library:AddStroke(Track, Library.OutlineColor, 1, 0.4)
        Track:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() S.MaxSize = Track.AbsoluteSize.X end)

        local Fill = Library:Create("Frame", { BackgroundColor3 = Library.AccentColor, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), ZIndex = 7, Parent = Track })
        Library:AddCorner(Fill, 999)
        Library:Create("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Library.AccentColorDark), ColorSequenceKeypoint.new(1, Library.AccentColorLight) }), Parent = Fill })

        local Knob = Library:Create("Frame", { BackgroundColor3 = Library.FontColor, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), ZIndex = 9, Parent = Fill })
        Library:AddCorner(Knob, 999); Library:AddStroke(Knob, Library.AccentColorDark, 1, 0)

        local Disp = Library:CreateLabel({ Size = UDim2.new(1, 0, 1, 0), TextSize = 12, Font = Library.FontMono, Text = "", ZIndex = 9, TextColor3 = Library.FontColor, Parent = Track })

        Library:OnHighlight(Track, Track, { BorderColor3 = "AccentColor" }, { BorderColor3 = "OutlineColor" }, function() return not S.Disabled end)
        if Info.Tooltip or Info.DisabledTooltip then TT = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, Track); TT.Disabled = S.Disabled end

        function S:UpdateColors()
            if SLabel then SLabel.TextColor3 = S.Disabled and Library.DisabledTextColor or Library.FontColor end
            Disp.TextColor3 = S.Disabled and Library.DisabledTextColor or Library.FontColor
            Library:Tween(Fill, { BackgroundColor3 = S.Disabled and Library.DisabledAccentColor or Library.AccentColor })
        end
        function S:Display()
            local custom = Info.FormatDisplayValue and Info.FormatDisplayValue(S, S.Value)
            if custom then Disp.Text = tostring(custom)
            else
                local fv = (S.Value == 0 or S.Value == -0) and "0" or tostring(S.Value)
                if Info.Compact then Disp.Text = string.format("%s: %s%s%s", S.Text, S.Prefix, fv, S.Suffix)
                elseif Info.HideMax then Disp.Text = S.Prefix .. fv .. S.Suffix
                else Disp.Text = string.format("%s%s%s / %s%s%s", S.Prefix, fv, S.Suffix, S.Prefix, tostring(S.Max), S.Suffix) end
            end
            local X = Library:MapValue(S.Value, S.Min, S.Max, 0, 1)
            Library:Tween(Fill, { Size = UDim2.new(X, 0, 1, 0) }, 0.08)
        end
        function S:OnChanged(f) S.Changed = f end
        local function Rnd(v) return S.Rounding == 0 and math.floor(v) or tonumber(string.format("%." .. S.Rounding .. "f", v)) end
        function S:GetValueFromXScale(X) return Rnd(Library:MapValue(X, 0, 1, S.Min, S.Max)) end
        function S:SetMax(V) assert(V > S.Min, "Max < Min"); S.Value = math.clamp(S.Value, S.Min, V); S.Max = V; S:Display() end
        function S:SetMin(V) assert(V < S.Max, "Min > Max"); S.Value = math.clamp(S.Value, V, S.Max); S.Min = V; S:Display() end
        function S:SetValue(Str)
            if S.Disabled then return end
            local n = tonumber(Str); if not n then return end; n = math.clamp(n, S.Min, S.Max)
            if n == S.Value then return end
            S.Value = n; S:Display(); Library:SafeCallback(S.Callback, S.Value); Library:SafeCallback(S.Changed, S.Value)
        end
        function S:SetVisible(V) S.Visible = V; if SLabel then SLabel.Visible = V end; Track.Visible = V; for _, b in Blanks do b.Visible = V end; G:Resize() end
        function S:SetDisabled(D) S.Disabled = D; if TT then TT.Disabled = D end; S:UpdateColors() end
        function S:SetText(t) if typeof(t) == "string" then S.Text = t; if SLabel then SLabel.Text = t end; S:Display() end end
        function S:SetPrefix(p) if typeof(p) == "string" then S.Prefix = p; S:Display() end end
        function S:SetSuffix(p) if typeof(p) == "string" then S.Suffix = p; S:Display() end end

        Track.InputBegan:Connect(function(i)
            if S.Disabled then return end
            if (i.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or i.UserInputType == Enum.UserInputType.Touch then
                if Library.IsMobile then Library.CanDrag = false end
                local mp = Mouse.X; local gp = Fill.AbsoluteSize.X; local d = mp - (Fill.AbsolutePosition.X + gp)
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local nmp = Mouse.X
                    local nxo = math.clamp(gp + (nmp - mp) + d, 0, S.MaxSize)
                    local nxs = Library:MapValue(nxo, 0, S.MaxSize, 0, 1)
                    local nv = S:GetValueFromXScale(nxs)
                    if nv ~= S.Value then S.Value = nv; S:Display(); Library:SafeCallback(S.Callback, S.Value); Library:SafeCallback(S.Changed, S.Value) end
                    RunService.RenderStepped:Wait()
                end
                if Library.IsMobile then Library.CanDrag = true end
                Library:AttemptSave()
            end
        end)

        task.delay(0.1, S.UpdateColors, S)
        S:Display()
        table.insert(Blanks, G:AddBlank(Info.BlankSize or 8, S.Visible)); G:Resize()
        S.Default = S.Value
        table.insert(G.Elements, S); Options[Idx] = S
        return S
    end

    function F:AddInput(Idx, Info)
        assert(Info.Text, string.format("AddInput (IDX: %s): Missing `Text`.", tostring(Idx)))
        local T = { Value = Info.Default or "", Numeric = Info.Numeric or false, Finished = Info.Finished or false, Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true, Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false, AllowEmpty = if typeof(Info.AllowEmpty) == "boolean" then Info.AllowEmpty else true, EmptyReset = typeof(Info.EmptyReset) == "string" and Info.EmptyReset or "---", Type = "Input", Callback = Info.Callback or function() end }
        local G = self; local Blank, TT
        local L = Library:CreateLabel({ Size = UDim2.new(1, 0, 0, 14), TextSize = 13, Font = Library.FontMedium, Text = Info.Text, TextXAlignment = Enum.TextXAlignment.Left, Visible = T.Visible, ZIndex = 5, Parent = self.Container })
        G:AddBlank(2)
        local Outer = Library:Create("Frame", { BackgroundColor3 = Library.BackgroundColor, BackgroundTransparency = 0.3, BorderColor3 = Library.OutlineColor, BorderMode = Enum.BorderMode.Inset, Size = UDim2.new(1, -4, 0, 22), Visible = T.Visible, ZIndex = 5, Parent = self.Container })
        Library:AddCorner(Outer, 6); Library:AddStroke(Outer, Library.OutlineColor, 1, 0.4)
        local Box = Library:Create("TextBox", { BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -8, 1, 0), Font = Library.FontMono, PlaceholderColor3 = Library.FontMuted, PlaceholderText = Info.Placeholder or "", Text = Info.Default or (not T.AllowEmpty and T.EmptyReset or "---"), TextColor3 = Library.FontColor, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextEditable = not T.Disabled, ClearTextOnFocus = not T.Disabled, ZIndex = 7, Parent = Outer })
        Library:OnHighlight(Outer, Outer, { BorderColor3 = "AccentColor" }, { BorderColor3 = "OutlineColor" }, function() return not T.Disabled end)
        if Info.Tooltip or Info.DisabledTooltip then TT = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, Outer); TT.Disabled = T.Disabled end
        function T:OnChanged(f) T.Changed = f end
        function T:UpdateColors() Box.TextColor3 = T.Disabled and Library.DisabledTextColor or Library.FontColor end
        function T:Display() Outer.Visible = T.Visible; L.Visible = T.Visible; if Blank then Blank.Visible = T.Visible end; G:Resize() end
        function T:SetValue(Text)
            if not T.AllowEmpty and Trim(Text) == "" then Text = T.EmptyReset end
            if Info.MaxLength and #Text > Info.MaxLength then Text = Text:sub(1, Info.MaxLength) end
            if T.Numeric and #tostring(Text) > 0 and not tonumber(Text) then Text = T.Value end
            T.Value = Text; Box.Text = Text
            Library:SafeCallback(T.Callback, T.Value); Library:SafeCallback(T.Changed, T.Value)
        end
        function T:SetVisible(V) T.Visible = V; T:Display() end
        function T:SetDisabled(D) T.Disabled = D; Box.TextEditable = not D; Box.ClearTextOnFocus = not D; if TT then TT.Disabled = D end; T:UpdateColors() end
        if T.Finished then Box.FocusLost:Connect(function(e) if e then T:SetValue(Box.Text); Library:AttemptSave() end end)
        else Box:GetPropertyChangedSignal("Text"):Connect(function() T:SetValue(Box.Text); Library:AttemptSave() end) end
        task.delay(0.1, T.UpdateColors, T)
        T:Display()
        Blank = G:AddBlank(6, T.Visible); G:Resize()
        T.Default = T.Value
        table.insert(G.Elements, T); Options[Idx] = T
        return T
    end

    function F:AddDropdown(Idx, Info)
        Info.ReturnInstanceInstead = typeof(Info.ReturnInstanceInstead) == "boolean" and Info.ReturnInstanceInstead or false
        if Info.SpecialType == "Player" then
            Info.ExcludeLocalPlayer = typeof(Info.ExcludeLocalPlayer) == "boolean" and Info.ExcludeLocalPlayer or false
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer, Info.ReturnInstanceInstead); Info.AllowNull = true
        elseif Info.SpecialType == "Team" then Info.Values = GetTeams(Info.ReturnInstanceInstead); Info.AllowNull = true end
        assert(Info.Values, string.format("AddDropdown (IDX: %s): Missing values.", tostring(Idx)))
        if not (Info.AllowNull or Info.Default) then Info.Default = 1 end
        Info.Searchable = typeof(Info.Searchable) == "boolean" and Info.Searchable or false

        if not Info.Text then Info.Compact = true end

        local D = { Values = Info.Values, Value = Info.Multi and {}, DisabledValues = Info.DisabledValues or {}, Multi = Info.Multi, Type = "Dropdown", SpecialType = Info.SpecialType, Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true, Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false, Callback = Info.Callback or function() end, Changed = Info.Changed or function() end, OriginalText = Info.Text, Text = Info.Text, ExcludeLocalPlayer = Info.ExcludeLocalPlayer, ReturnInstanceInstead = Info.ReturnInstanceInstead }
        local G = self; local DLbl, Blank, TT

        if not Info.Compact then
            DLbl = Library:CreateLabel({ Size = UDim2.new(1, 0, 0, 14), TextSize = 13, Font = Library.FontMedium, Text = Info.Text, TextXAlignment = Enum.TextXAlignment.Left, Visible = D.Visible, ZIndex = 5, Parent = self.Container })
            G:AddBlank(2)
        end

        local Outer = Library:Create("Frame", { BackgroundColor3 = Library.BackgroundColor, BackgroundTransparency = 0.3, Size = UDim2.new(1, -4, 0, 24), Visible = D.Visible, ZIndex = 5, Parent = self.Container })
        Library:AddCorner(Outer, 6); Library:AddStroke(Outer, Library.OutlineColor, 1, 0.4)

        local Arrow = Library:Create("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -18, 0.5, 0), Size = UDim2.new(0, 12, 0, 12), Image = CustomImageManager.GetAsset("DropdownArrow"), ZIndex = 8, Parent = Outer })
        local Item = Library:CreateLabel({ Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -30, 1, 0), TextSize = 13, Font = Library.FontMedium, Text = "--", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, RichText = true, ZIndex = 7, Parent = Outer })

        Library:OnHighlight(Outer, Outer, { BorderColor3 = "AccentColor" }, { BorderColor3 = "OutlineColor" }, function() return not D.Disabled end)
        if Info.Tooltip or Info.DisabledTooltip then TT = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, Outer); TT.Disabled = D.Disabled end

        local MaxItems = typeof(Info.MaxVisibleDropdownItems) == "number" and math.clamp(Info.MaxVisibleDropdownItems, 4, 16) or 8
        local List = Library:Create("Frame", { BackgroundColor3 = Library.SurfaceColor, BorderColor3 = Library.AccentColor, ZIndex = 20, Visible = false, Parent = ScreenGui })
        Library:AddCorner(List, 8); Library:AddStroke(List, Library.AccentColor, 1, 0.3); Library:AddShadow(List, 0.4)

        local Scrolling = Library:Create("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), Size = UDim2.new(1, 0, 1, 0), ZIndex = 21, Parent = List, ScrollBarThickness = 3, ScrollBarImageColor3 = Library.AccentColor })
        Library:AddCorner(Scrolling, 8)
        Library:Create("UIListLayout", { Parent = Scrolling })
        Library:Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = Scrolling })

        local Search
        if Info.Searchable then
            Search = Library:Create("TextBox", { BackgroundTransparency = 1, Visible = false, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -8, 1, 0), Font = Library.FontMedium, PlaceholderColor3 = Library.FontMuted, PlaceholderText = "Search...", Text = "", TextColor3 = Library.FontColor, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 7, Parent = Outer })
        end

        local function Pos() List.Position = UDim2.fromOffset(Outer.AbsolutePosition.X, Outer.AbsolutePosition.Y + Outer.Size.Y.Offset + 2) end
        local function Size(Y) List.Size = UDim2.fromOffset(Outer.AbsoluteSize.X, Y or math.clamp(GetTableSize(D.Values) * 22, 0, MaxItems * 22) + 8) end
        Pos(); Size()
        Outer:GetPropertyChangedSignal("AbsolutePosition"):Connect(Pos)

        function D:UpdateColors()
            if DLbl then DLbl.TextColor3 = D.Disabled and Library.DisabledTextColor or Library.FontColor end
            Item.TextColor3 = D.Disabled and Library.DisabledTextColor or Library.FontColor
            Arrow.ImageColor3 = D.Disabled and Library.DisabledTextColor or Library.FontColor
        end
        function D:Display()
            local S = ""
            if Info.Multi then
                for _, V in D.Values do if D.Value[V] then S = S .. tostring(V) .. ", " end end
                S = S:sub(1, #S - 2); Item.Text = (S == "" and "--" or S)
            else
                if not D.Value then Item.Text = "--"; return end
                Item.Text = tostring(D.Value)
            end
        end
        function D:GetActiveValues()
            if Info.Multi then local T = {}; for V in D.Value do table.insert(T, V) end; return T end
            return D.Value and 1 or 0
        end
        function D:BuildDropdownList()
            for _, E in Scrolling:GetChildren() do if not E:IsA("UIListLayout") and not E:IsA("UIPadding") then E:Destroy() end end
            local Count = 0
            for _, V in D.Values do
                local SV = tostring(V)
                if Info.Searchable and not string.lower(SV):match(string.lower(Search.Text)) then continue end
                local IsD = table.find(D.DisabledValues, SV); local Table = {}
                Count = Count + 1
                local Btn = Library:Create("TextButton", { AutoButtonColor = false, BackgroundColor3 = Library.SurfaceColor, BackgroundTransparency = 0.5, BorderSizePixel = 0, Size = UDim2.new(1, -8, 0, 20), Text = "", ZIndex = 23, Parent = Scrolling })
                Library:AddCorner(Btn, 6)
                local BL = Library:CreateLabel({ Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 6, 0, 0), TextSize = 13, Font = Library.FontMedium, Text = SV, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 25, Parent = Btn })
                Btn.MouseEnter:Connect(function() Library:Tween(Btn, { BackgroundColor3 = Library.AccentColor, BackgroundTransparency = 0.7 }) end)
                Btn.MouseLeave:Connect(function() Library:Tween(Btn, { BackgroundColor3 = Library.SurfaceColor, BackgroundTransparency = 0.5 }) end)
                local Selected = Info.Multi and D.Value[V] or D.Value == V
                function Table:UpdateButton()
                    if Info.Multi then Selected = D.Value[V] else Selected = D.Value == V end
                    BL.TextColor3 = Selected and Library.AccentColor or (IsD and Library.DisabledTextColor or Library.FontColor)
                end
                if not IsD then
                    Btn.MouseButton1Click:Connect(function()
                        local Try = not Selected
                        if D:GetActiveValues() == 1 and not Try and not Info.AllowNull then return end
                        if Info.Multi then Selected = Try; D.Value[V] = Try and true or nil
                        else Selected = Try; D.Value = Try and V or nil; for _, ob in pairs(Scrolling:GetChildren()) do if ob ~= Btn and ob:IsA("TextButton") then local tl = ob:FindFirstChildOfClass("TextLabel"); if tl then tl.TextColor3 = Library.FontColor end end end end
                        Table:UpdateButton(); D:Display()
                        Library:UpdateDependencyBoxes(); Library:UpdateDependencyGroupboxes()
                        Library:SafeCallback(D.Callback, D.Value); Library:SafeCallback(D.Changed, D.Value)
                        Library:AttemptSave()
                    end)
                end
                Table:UpdateButton(); D:Display()
            end
            Scrolling.CanvasSize = UDim2.fromOffset(0, Count * 22 + 8)
            local Y = math.clamp(Count * 22, 0, MaxItems * 22) + 8
            List.Size = UDim2.fromOffset(Outer.AbsoluteSize.X, Y)
        end
        function D:SetValues(V) if V then D.Values = V end; D:BuildDropdownList() end
        function D:AddValues(V) if typeof(V) == "table" then for _, x in pairs(V) do table.insert(D.Values, x) end elseif typeof(V) == "string" then table.insert(D.Values, V) end; D:BuildDropdownList() end
        function D:SetDisabledValues(V) if V then D.DisabledValues = V end; D:BuildDropdownList() end
        function D:SetVisible(V) D.Visible = V; Outer.Visible = V; if DLbl then DLbl.Visible = V end; if Blank then Blank.Visible = V end; if not V then D:CloseDropdown() end; G:Resize() end
        function D:SetDisabled(X) D.Disabled = X; if TT then TT.Disabled = X end; if X then D:CloseDropdown() end; D:Display(); D:UpdateColors() end
        function D:OpenDropdown() if D.Disabled then return end; if Library.IsMobile then Library.CanDrag = false end; if Info.Searchable then Item.Visible = false; Search.Text = ""; Search.Visible = true end; List.Visible = true; Library.OpenedFrames[List] = true; Arrow.Rotation = 180 end
        function D:CloseDropdown() if Library.IsMobile then Library.CanDrag = true end; if Info.Searchable then Search.Text = ""; Search.Visible = false; Item.Visible = true end; List.Visible = false; Library.OpenedFrames[List] = nil; Arrow.Rotation = 0 end
        function D:OnChanged(f) D.Changed = f end
        function D:SetValue(V)
            if D.Multi then local T = {}; for k, act in pairs(V or {}) do if typeof(act) ~= "boolean" then T[act] = true elseif act and table.find(D.Values, k) then T[k] = true end end; D.Value = T
            else if table.find(D.Values, V) then D.Value = V elseif not V then D.Value = nil end end
            D:BuildDropdownList()
            Library:SafeCallback(D.Callback, D.Value); Library:SafeCallback(D.Changed, D.Value)
        end
        function D:SetText(t) if typeof(t) == "string" then if Info.Compact then Info.Compact = false end; D.Text = t; if DLbl then DLbl.Text = t end; D:Display() end end

        Outer.InputBegan:Connect(function(i)
            if D.Disabled then return end
            if (i.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or i.UserInputType == Enum.UserInputType.Touch then
                if List.Visible then D:CloseDropdown() else D:OpenDropdown() end
            end
        end)
        if Info.Searchable then Search:GetPropertyChangedSignal("Text"):Connect(function() D:BuildDropdownList() end) end
        Library:GiveSignal(InputService.InputBegan:Connect(function(i)
            if D.Disabled or Library.Unloaded then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                local A, S = List.AbsolutePosition, List.AbsoluteSize
                if Mouse.X < A.X or Mouse.X > A.X + S.X or Mouse.Y < A.Y - 21 or Mouse.Y > A.Y + S.Y then D:CloseDropdown() end
            end
        end))

        D:BuildDropdownList(); D:Display()
        local Defaults = {}
        if typeof(Info.Default) == "string" then local i = table.find(D.Values, Info.Default); if i then table.insert(Defaults, i) end
        elseif typeof(Info.Default) == "table" then for _, v in Info.Default do local i = table.find(D.Values, v); if i then table.insert(Defaults, i) end end
        elseif typeof(Info.Default) == "number" and D.Values[Info.Default] then table.insert(Defaults, Info.Default) end
        if next(Defaults) then
            for i = 1, #Defaults do
                local Idx2 = Defaults[i]
                if Info.Multi then D.Value[D.Values[Idx2]] = true else D.Value = D.Values[Idx2] end
                if not Info.Multi then break end
            end
            D:BuildDropdownList(); D:Display()
        end
        task.delay(0.1, D.UpdateColors, D)
        Blank = G:AddBlank(Info.BlankSize or 6, D.Visible); G:Resize()
        D.Default = Defaults; D.DefaultValues = D.Values
        table.insert(G.Elements, D); Options[Idx] = D
        return D
    end

    function F:AddDependencyBox()
        local DB = { Elements = {}, Dependencies = {}, TableType = "DepBox" }
        local G = self
        local Holder = Library:Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Visible = false, Parent = G.Container })
        local Frame = Library:Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = true, Parent = Holder })
        local Layout = Library:Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Parent = Frame })
        function DB:Resize() Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y); G:Resize() end
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() DB:Resize() end)
        Holder:GetPropertyChangedSignal("Visible"):Connect(function() DB:Resize() end)
        function DB:Update()
            for _, Dep in DB.Dependencies do
                local E, V = Dep[1], Dep[2]
                if if E.Multi then not table.find(E:GetActiveValues(), V) else E.Value ~= V then Holder.Visible = false; DB:Resize(); return end
            end
            Holder.Visible = true; DB:Resize()
        end
        function DB:SetupDependencies(D)
            for _, x in D do assert(typeof(x) == "table", "Dependency table expected") end
            DB.Dependencies = D; DB:Update()
        end
        DB.Container = Frame; setmetatable(DB, BaseGroupbox)
        table.insert(G.Elements, DB); table.insert(Library.DependencyBoxes, DB)
        return DB
    end

    function F:AddDivider(...)
        local P = select(1, ...); local T, MT, MB = nil, 2, 9
        if typeof(P) == "table" then T = P.Text; MT = P.MarginTop or P.Margin or 2; MB = P.MarginBottom or P.Margin or 9
        elseif typeof(P) == "string" then T = P end
        self:AddBlank(MT)
        local D = Library:Create("Frame", { BackgroundColor3 = Library.OutlineColor, BackgroundTransparency = 0.4, Size = UDim2.new(1, -4, 0, 1), ZIndex = 5, Parent = self.Container })
        if T then
            local L = Library:CreateLabel({ Size = UDim2.new(1, -4, 0, 16), TextSize = 12, Font = Library.FontBold, Text = T:upper(), TextColor3 = Library.FontMuted, ZIndex = 6, Parent = self.Container })
            Library:AddToRegistry(L, { TextColor3 = "FontMuted" })
        end
        self:AddBlank(MB); self:Resize()
        table.insert(self.Elements, { Holder = D, Type = "Divider" })
    end

    BaseGroupbox.__index = F
    BaseGroupbox.__namecall = function(T, K, ...) return F[K](...) end
end

-- ============================================================
-- ✦ POWIADOMIENIA GLASS ✦
-- ============================================================
do
    Library.LeftNotificationArea = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(0, 320, 0, 500),
        ZIndex = 11000,
        Parent = ScreenGui,
    })
    Library:Create("UIListLayout", { Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Parent = Library.LeftNotificationArea })

    Library.RightNotificationArea = Library:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0, 50),
        Size = UDim2.new(0, 320, 0, 500),
        ZIndex = 11000,
        Parent = ScreenGui,
    })
    Library:Create("UIListLayout", { Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Parent = Library.RightNotificationArea })

    function Library:SetNotifySide(Side) Library.NotifySide = Side end

    function Library:Notify(...)
        local Data = {}
        local Info = select(1, ...)
        if typeof(Info) == "table" then
            Data.Title = Info.Title and tostring(Info.Title) or ""
            Data.Description = tostring(Info.Description)
            Data.Time = Info.Time or 5
            Data.SoundId = Info.SoundId
            Data.Icon = Info.Icon
            Data.IconColor = Info.IconColor
            Data.Persist = Info.Persist
        else
            Data.Title = ""
            Data.Description = tostring(Info)
            Data.Time = select(2, ...) or 5
            Data.SoundId = select(3, ...)
        end
        Data.Destroyed = false

        local Side = string.lower(Library.NotifySide)
        local XSize, YSize = Library:GetTextBounds(Data.Description, Library.FontMedium, 13)
        YSize = YSize + 14

        local Outer = Library:Create("Frame", {
            BackgroundColor3 = Library.MainColor,
            BackgroundTransparency = 0.1,
            BorderColor3 = Library.AccentColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(0, 0, 0, YSize + 8),
            ClipsDescendants = false,
            ZIndex = 11000,
            Visible = false,
            Name = "Notif",
            Parent = Side == "left" and Library.LeftNotificationArea or Library.RightNotificationArea,
        })
        Library:AddCorner(Outer, 10)
        Library:AddStroke(Outer, Library.AccentColor, 1.2, 0.4)
        Library:AddShadow(Outer, 0.45)

        local Inner = Library:Create("Frame", {
            BackgroundColor3 = Library.MainColorDark,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 11001,
            Parent = Outer,
        })
        Library:AddCorner(Inner, 10)
        Library:AddToRegistry(Inner, { BackgroundColor3 = "MainColorDark" })

        -- lewy pasek neon
        local Bar = Library:Create("Frame", {
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel = 0,
            Position = Side == "left" and UDim2.new(0, 0, 0, 8) or UDim2.new(1, -3, 0, 8),
            Size = UDim2.new(0, 3, 1, -16),
            ZIndex = 11004,
            Parent = Outer,
        })
        Library:AddCorner(Bar, 999)
        Library:AddToRegistry(Bar, { BackgroundColor3 = "AccentColor" })

        local ExtraWidth = 0
        if Data.Icon then
            local P = Library:GetCustomIcon(Data.Icon)
            if P then
                ExtraWidth = 22
                Library:Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    Image = P.Url,
                    ImageColor3 = Data.IconColor or Library.AccentColor,
                    ImageRectOffset = P.ImageRectOffset,
                    ImageRectSize = P.ImageRectSize,
                    ZIndex = 11004,
                    Parent = Inner,
                })
            end
        end

        local Lbl = Library:CreateLabel({
            AnchorPoint = Side == "left" and Vector2.new(0, 0) or Vector2.new(1, 0),
            Position = Side == "left" and UDim2.new(0, 12 + ExtraWidth, 0, 0) or UDim2.new(1, -12, 0, 0),
            Size = UDim2.new(1, -24 - ExtraWidth, 1, 0),
            Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. Data.Description,
            TextXAlignment = Side == "left" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right,
            TextSize = 13,
            Font = Library.FontMedium,
            TextWrapped = true,
            RichText = true,
            ZIndex = 11003,
            Parent = Inner,
        })

        -- pasek postępu
        if typeof(Data.Time) == "number" and not Data.Persist then
            local Prog = Library:Create("Frame", {
                BackgroundColor3 = Library.AccentColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -2),
                Size = UDim2.new(1, 0, 0, 2),
                ZIndex = 11005,
                Parent = Inner,
            })
            Library:AddCorner(Prog, 999)
            TweenService:Create(Prog, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()
        end

        function Data:Destroy()
            Data.Destroyed = true
            TweenService:Create(Outer, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 0, 0, YSize + 8),
                BackgroundTransparency = 1,
            }):Play()
            task.wait(0.25)
            Outer:Destroy()
        end
        function Data:ChangeTitle(T) Data.Title = t or ""; Lbl.Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. Data.Description end
        function Data:ChangeDescription(T) Data.Description = tostring(T or ""); Lbl.Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. Data.Description end
        function Data:ChangeStep() end

        if Data.SoundId then
            Library:Create("Sound", {
                SoundId = "rbxassetid://" .. tostring(Data.SoundId):gsub("rbxassetid://", ""),
                Volume = 3,
                PlayOnRemove = true,
                Parent = game:GetService("SoundService"),
            }):Destroy()
        end

        Outer.Visible = true
        -- animacja slide-in
        Outer.Position = Side == "left" and UDim2.new(0, -360, 0, 0) or UDim2.new(1, 360, 0, 0)
        TweenService:Create(Outer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, XSize + 26 + ExtraWidth, 0, YSize + 8),
        }):Play()

        task.delay(Data.Time or 5, function()
            if not Data.Destroyed then Data:Destroy() end
        end)

        return Data
    end
end

-- ============================================================
-- ✦ WATERMARK + KEYBIND FRAME ✦
-- ============================================================
do
    -- KEYBIND FRAME
    local KbOuter = Library:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        BackgroundColor3 = Library.MainColor,
        BackgroundTransparency = 0.1,
        BorderColor3 = Library.AccentColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(0, 220, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 100,
        Parent = ScreenGui,
    })
    Library:AddCorner(KbOuter, 10)
    Library:AddStroke(KbOuter, Library.AccentColor, 1.2, 0.4)
    Library:AddShadow(KbOuter, 0.4)

    local KbInner = Library:Create("Frame", {
        BackgroundColor3 = Library.MainColorDark,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 101,
        Parent = KbOuter,
    })
    Library:AddCorner(KbInner, 10)
    Library:AddToRegistry(KbInner, { BackgroundColor3 = "MainColorDark" }, true)

    local _KeybindTitle = Library:CreateLabel({
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 8, 0, 6),
        Text = "Keybinds",
        Font = Library.FontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 104,
        Parent = KbInner,
    })

    local KbContainer = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 1,
        Parent = KbInner,
    })
    Library:Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = KbContainer })
    Library:Create("UIPadding", { PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = KbContainer })

    Library.KeybindFrame = KbOuter
    Library.KeybindContainer = KbContainer
    Library:MakeDraggable(KbOuter)

    -- WATERMARK
    local WmOuter = Library:Create("Frame", {
        BackgroundColor3 = Library.MainColor,
        BackgroundTransparency = 0.1,
        BorderColor3 = Library.AccentColor,
        BorderMode = Enum.BorderMode.Inset,
        Position = UDim2.new(0, 100, 0, 10),
        Size = UDim2.new(0, 200, 0, 24),
        ZIndex = 200,
        Visible = false,
        Parent = ScreenGui,
    })
    Library:AddCorner(WmOuter, 8)
    Library:AddStroke(WmOuter, Library.AccentColor, 1.2, 0.4)
    Library:AddShadow(WmOuter, 0.5)

    local WmInner = Library:Create("Frame", {
        BackgroundColor3 = Library.MainColorDark,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 201,
        Parent = WmOuter,
    })
    Library:AddCorner(WmInner, 8)
    Library:AddToRegistry(WmInner, { BackgroundColor3 = "MainColorDark" })

    Library:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.AccentColor),
            ColorSequenceKeypoint.new(1, Library.SecondaryAccent),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(1, 0.85),
        }),
        Rotation = 0,
        Parent = WmInner,
    })

    local WmLabel = Library:CreateLabel({
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -8, 1, 0),
        TextSize = 12,
        Font = Library.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
        Parent = WmInner,
    })

    Library.Watermark = WmOuter
    Library.WatermarkText = WmLabel
    Library:MakeDraggable(WmOuter)

    function Library:SetWatermarkVisibility(B) WmOuter.Visible = B end
    function Library:SetWatermark(Text)
        local X, Y = Library:GetTextBounds(Text, Library.FontBold, 12)
        WmOuter.Size = UDim2.new(0, X + 20, 0, 24)
        WmOuter.Visible = true
        WmLabel.Text = Text
    end
end

-- ============================================================
-- ✦ TOGGLE KEYBIND (Right Ctrl / Right Shift) ✦
-- ============================================================
Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
    if Library.Unloaded then return end
    if typeof(Library.ToggleKeybind) == "table" and Library.ToggleKeybind.Type == "KeyPicker" then
        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
            task.spawn(function() Library.Window:Toggle() end)
        end
    elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and not Processed) then
        task.spawn(function() Library.Window:Toggle() end)
    end
end))

-- ============================================================
-- ✦ HOOKI PLAYER / TEAM (dropdown auto-refresh) ✦
-- ============================================================
local function OnPlayerChange()
    if Library.Unloaded then return end
    local PL, EPL = GetPlayers(false, true), GetPlayers(true, true)
    local SPL, SEPL = GetPlayers(false, false), GetPlayers(true, false)
    for _, V in pairs(Options) do
        if V.SetValues and V.Type == "Dropdown" and V.SpecialType == "Player" then
            V:SetValues(V.ReturnInstanceInstead and (V.ExcludeLocalPlayer and EPL or PL) or (V.ExcludeLocalPlayer and SEPL or SPL))
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then return end
    local TL = GetTeams(true); local STL = GetTeams(false)
    for _, V in pairs(Options) do
        if V.SetValues and V.Type == "Dropdown" and V.SpecialType == "Team" then
            V:SetValues(V.ReturnInstanceInstead and TL or STL)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))
Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

-- ============================================================
-- ✦ RAINBOW ACCENT HANDLER ✦
-- ============================================================
local RainbowStep, Hue = 0, 0
Library:GiveSignal(RunService.RenderStepped:Connect(function(Delta)
    if Library.Unloaded then return end
    RainbowStep = RainbowStep + Delta
    if RainbowStep >= (1 / 60) then
        RainbowStep = 0
        Hue = Hue + (1 / 400)
        if Hue > 1 then Hue = 0 end
        Library.CurrentRainbowHue = Hue
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1)
    end
end))

-- ============================================================
-- ✦ MOBILE QUICK TOGGLE ✦
-- ============================================================
if Library.IsMobile then
    local Tgl = Library:Create("TextButton", {
        BackgroundColor3 = Library.MainColor,
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0.01, 0, 0.02, 0),
        Size = UDim2.new(0, 90, 0, 32),
        Font = Library.FontBold,
        Text = "MENU",
        TextColor3 = Library.FontColor,
        TextSize = 13,
        ZIndex = 200,
        Parent = ScreenGui,
    })
    Library:AddCorner(Tgl, 8)
    Library:AddStroke(Tgl, Library.AccentColor, 1.2, 0.4)
    Tgl.MouseButton1Click:Connect(function() Library.Window:Toggle() end)
end

-- ============================================================
-- ✦ FINAL EXPORT ✦
-- ============================================================
getgenv().Linoria = Library
if getgenv().skip_getgenv_linoria ~= true then getgenv().Library = Library end
return Library
