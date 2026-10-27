--[[
    Linoria Library - Modern Redesign
    Zachowane pełne API oryginału. Ulepszony wygląd.
    
    Użycie:
        local Library = loadstring(game:HttpGet("URL"))()
        local Window = Library:CreateWindow({ Title = "My Hub", Center = true, AutoShow = true })
]]

local cloneref = (cloneref or clonereference or function(instance) return instance end)
local InputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Teams = cloneref(game:GetService("Teams"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local DrawingLib = { drawing_replaced = true, new = function(...) error("Drawing is not supported.") end }
if typeof(getgenv) == "function" and typeof(getgenv().Drawing) == "table" then
    DrawingLib = getgenv().Drawing
end

local setclipboard = setclipboard or nil
local getgenv = getgenv or function() return shared end
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHUI = gethui or function() return CoreGui end

local assert = function(condition, errorMessage)
    if not condition then
        error(if errorMessage then errorMessage else "assert failed", 3)
    end
end

local function SafeParentUI(Instance, Parent)
    local success = pcall(function()
        if not Parent then Parent = CoreGui end
        local DestinationParent = typeof(Parent) == "function" and Parent() or Parent
        Instance.Parent = DestinationParent
    end)
    if not (success and Instance.Parent) then
        Instance.Parent = LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI, SkipHiddenUI)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end
    pcall(ProtectGui, UI)
    SafeParentUI(UI, GetHUI)
end

-- ============================================================
--  SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LinoriaModern"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
ParentUI(ScreenGui)

local ModalElement = Instance.new("TextButton")
ModalElement.BackgroundTransparency = 1
ModalElement.Modal = false
ModalElement.Size = UDim2.fromScale(0, 0)
ModalElement.Text = ""
ModalElement.ZIndex = -999
ModalElement.Parent = ScreenGui

local LibraryMainOuterFrame = nil

local Toggles = {}
local Options = {}
local Labels = {}
local Buttons = {}
local Tooltips = {}
local Dialogues = {}

-- ============================================================
--  IMAGE MANAGER (identyczny z oryginałem)
-- ============================================================
local BaseURL = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    Cursor = { RobloxId = 9619665977, Path = "LinoriaLib/assets/Cursor.png", URL = BaseURL .. "assets/Cursor.png", Id = nil },
    DropdownArrow = { RobloxId = 6282522798, Path = "LinoriaLib/assets/DropdownArrow.png", URL = BaseURL .. "assets/DropdownArrow.png", Id = nil },
    Checker = { RobloxId = 12977615774, Path = "LinoriaLib/assets/Checker.png", URL = BaseURL .. "assets/Checker.png", Id = nil },
    CheckerLong = { RobloxId = 12978095818, Path = "LinoriaLib/assets/CheckerLong.png", URL = BaseURL .. "assets/CheckerLong.png", Id = nil },
    SaturationMap = { RobloxId = 4155801252, Path = "LinoriaLib/assets/SaturationMap.png", URL = BaseURL .. "assets/SaturationMap.png", Id = nil },
}
do
    local function RecursiveCreatePath(Path, IsFile)
        if not isfolder or not makefolder then return end
        local Segments = Path:split("/")
        local TraversedPath = ""
        if IsFile then table.remove(Segments, #Segments) end
        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then makefolder(TraversedPath .. Segment) end
            TraversedPath = TraversedPath .. Segment .. "/"
        end
        return TraversedPath
    end

    function CustomImageManager.AddAsset(AssetName, RobloxAssetId, URL, ForceRedownload)
        if CustomImageManagerAssets[AssetName] then error(string.format("Asset %q already exists", AssetName)) end
        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")
        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId, Path = string.format("Obsidian/custom_assets/%s", AssetName), URL = URL, Id = nil,
        }
        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName)
        local AssetData = CustomImageManagerAssets[AssetName]
        if not AssetData then return nil end
        if AssetData.Id then return AssetData.Id end
        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)
        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)
            if Success and NewID then AssetID = NewID end
        end
        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
        if not getcustomasset or not writefile or not isfile then return false, "missing functions" end
        local AssetData = CustomImageManagerAssets[AssetName]
        RecursiveCreatePath(AssetData.Path, true)
        if ForceRedownload ~= true and isfile(AssetData.Path) then return true, nil end
        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)
        return success, errorMessage
    end

    for AssetName in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

-- ============================================================
--  LIBRARY TABLE - NOWA PALETA + FONT
-- ============================================================
local DPIScale = 1;
local Library = {
    Registry = {};
    RegistryMap = {};
    HudRegistry = {};

    -- === NOWY THEME ===
    FontColor = Color3.fromRGB(240, 240, 245);
    FontMuted = Color3.fromRGB(160, 160, 175);
    MainColor = Color3.fromRGB(30, 30, 38);
    MainColorDark = Color3.fromRGB(24, 24, 30);
    BackgroundColor = Color3.fromRGB(22, 22, 27);
    BackgroundColorDark = Color3.fromRGB(16, 16, 20);

    AccentColor = Color3.fromRGB(99, 102, 241);      -- indygo
    AccentColorDark = Color3.fromRGB(79, 82, 221);
    AccentColorLight = Color3.fromRGB(129, 132, 255);

    OutlineColor = Color3.fromRGB(55, 55, 68);
    OutlineColorLight = Color3.fromRGB(75, 75, 90);
    DisabledAccentColor = Color3.fromRGB(100, 100, 115);
    DisabledOutlineColor = Color3.fromRGB(65, 65, 78);
    DisabledTextColor = Color3.fromRGB(120, 120, 135);

    RiskColor = Color3.fromRGB(239, 68, 68);
    SuccessColor = Color3.fromRGB(34, 197, 94);

    Black = Color3.new(0, 0, 0);
    White = Color3.new(1, 1, 1);

    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,

    -- frames
    OpenedFrames = {};
    DependencyBoxes = {};
    DependencyGroupboxes = {};

    -- signals
    UnloadSignals = {};
    Signals = {};

    -- gui
    ActiveTab = nil;
    TotalTabs = 0;

    ScreenGui = ScreenGui;
    KeybindFrame = nil;
    KeybindContainer = nil;
    Window = { Holder = nil; Tabs = {}; };

    -- variables
    VideoLink = "";
    Toggled = false;
    ToggleKeybind = nil;

    IsMobile = false;
    DevicePlatform = Enum.Platform.None;

    CanDrag = true;
    CantDragForced = false;

    Unloaded = false;

    -- notification
    Notify = nil;
    NotifySide = "Left";
    ShowCustomCursor = true;
    ShowToggleFrameInKeybinds = true;
    NotifyOnError = false;

    -- addons
    SaveManager = nil;
    ThemeManager = nil;

    -- for better usage
    Toggles = Toggles;
    Options = Options;
    Labels = Labels;
    Buttons = Buttons;
    Dialogues = Dialogues;
    ActiveDialog = nil;

    ImageManager = CustomImageManager;
    ShowCursorBinding = string.sub(tostring({}), 10);
}

if RunService:IsStudio() then
    Library.IsMobile = InputService.TouchEnabled and not InputService.MouseEnabled
else
    pcall(function() Library.DevicePlatform = InputService:GetPlatform() end)
    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
end

Library.MinSize = if Library.IsMobile then Vector2.new(550, 200) else Vector2.new(550, 320)

-- ============================================================
--  HELPERY
-- ============================================================
local function ApplyDPIScale(Position)
    return UDim2.new(Position.X.Scale, Position.X.Offset * DPIScale, Position.Y.Scale, Position.Y.Offset * DPIScale)
end

local function ApplyTextScale(TextSize)
    return TextSize * DPIScale
end

local function GetTableSize(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function GetPlayers(ExcludeLocalPlayer, ReturnInstances)
    local PlayerList = Players:GetPlayers()
    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then table.remove(PlayerList, Idx) end
    end
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    if ReturnInstances then return PlayerList end
    local Fixed = {}
    for _, p in next, PlayerList do Fixed[#Fixed + 1] = p.Name end
    return Fixed
end

local function GetTeams(ReturnInstances)
    local TeamList = Teams:GetTeams()
    table.sort(TeamList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    if ReturnInstances then return TeamList end
    local Fixed = {}
    for _, t in next, TeamList do Fixed[#Fixed + 1] = t.Name end
    return Fixed
end

local function Trim(Text)
    return Text:match("^%s*(.-)%s*$")
end

-- ============================================================
--  IKONY (lucide)
-- ============================================================
local FetchIcons, Icons = pcall(function()
    return (loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")))()
end)

function Library:IsValidCustomIcon(Icon)
    return typeof(Icon) == "string" and (Icon:match("rbxasset") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

function Library:GetIcon(IconName)
    if not FetchIcons then return end
    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then return end
    return Icon
end

function Library:GetCustomIcon(IconName)
    if not Library:IsValidCustomIcon(IconName) then
        return Library:GetIcon(IconName)
    else
        return { Url = IconName, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = true }
    end
end

function Library:SetIconModule(module)
    FetchIcons = true
    Icons = module
end

function Library:GetBetterColor(Color, Add)
    Add = Add * 2
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color)
    return Color3.fromHSV(H, S, V / 1.5)
end
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)

-- ============================================================
--  LIBRARY FUNCTIONS
-- ============================================================
function Library:Validate(Table, Template)
    if typeof(Table) ~= "table" then return Template end
    for k, v in pairs(Template) do
        if typeof(k) == "number" then continue end
        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end
    return Table
end

function Library:SetDPIScale(value)
    assert(type(value) == "number", "Expected number for DPI scale but got " .. typeof(value))
    DPIScale = value / 100
    Library.MinSize = (if Library.IsMobile then Vector2.new(550, 200) else Vector2.new(550, 320)) * DPIScale
end

function Library:SafeCallback(Func, ...)
    if not (Func and typeof(Func) == "function") then return end
    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError then Library:Notify(Error) end
        return Error
    end, ...))
    if not Result[1] then return nil end
    return table.unpack(Result, 2, Result.n)
end

function Library:AttemptSave()
    if not Library.SaveManager then return end
    Library.SaveManager:Save()
end

-- === NOWA FUNKCJA POMOCNICZA: ZAOKRĄGLENIE + STROKE ===
function Library:AddCorner(Instance, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or 6)
    Corner.Parent = Instance
    return Corner
end

function Library:AddStroke(Instance, Color, Thickness, Transparency)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or Library.OutlineColor
    Stroke.Thickness = Thickness or 1
    Stroke.Transparency = Transparency or 0
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Instance
    return Stroke
end

function Library:AddShadow(Instance, Transparency)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = Transparency or 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.ZIndex = Instance.ZIndex - 1
    Shadow.Parent = Instance
    return Shadow
end

function Library:Create(Class, Properties)
    local _Instance = Class
    if typeof(Class) == "string" then _Instance = Instance.new(Class) end
    for Property, Value in next, Properties do
        if Property == "Size" or Property == "Position" then
            Value = ApplyDPIScale(Value)
        elseif Property == "TextSize" then
            Value = ApplyTextScale(Value)
        end
        pcall(function() _Instance[Property] = Value end)
    end
    return _Instance
end

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1
    return Library:Create("UIStroke", {
        Color = Color3.new(0, 0, 0);
        Thickness = 1;
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = Inst;
    })
end

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create("TextLabel", {
        BackgroundTransparency = 1;
        Font = Library.Font;
        TextColor3 = Library.FontColor;
        TextSize = 14;
        TextStrokeTransparency = 0;
    })
    Library:ApplyTextStroke(_Instance)
    Library:AddToRegistry(_Instance, { TextColor3 = "FontColor" }, IsHud)
    return Library:Create(_Instance, Properties)
end

function Library:MakeDraggable(Instance, Cutoff, IsMainWindow)
    Instance.Active = true
    if Library.IsMobile == false then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow == true and Library.CantDragForced == true then return end
                local ObjPos = Vector2.new(Mouse.X - Instance.AbsolutePosition.X, Mouse.Y - Instance.AbsolutePosition.Y)
                if ObjPos.Y > (Cutoff or 40) then return end
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Instance.Position = UDim2.new(
                        0, Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                        0, Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                    )
                    RunService.RenderStepped:Wait()
                end
            end
        end)
    else
        local Dragging, DraggingInput, DraggingStart, StartPosition
        InputService.TouchStarted:Connect(function(Input)
            if IsMainWindow == true and Library.CantDragForced == true then Dragging = false; return end
            if not Dragging and Library:MouseIsOverFrame(Instance, Input) and (IsMainWindow == true and (Library.CanDrag == true and Library.Window.Holder.Visible == true) or true) then
                DraggingInput = Input
                DraggingStart = Input.Position
                StartPosition = Instance.Position
                local OffsetPos = Input.Position - DraggingStart
                if OffsetPos.Y > (Cutoff or 40) then Dragging = false; return end
                Dragging = true
            end
        end)
        InputService.TouchMoved:Connect(function(Input)
            if IsMainWindow == true and Library.CantDragForced == true then Dragging = false; return end
            if Input == DraggingInput and Dragging and (IsMainWindow == true and (Library.CanDrag == true and Library.Window.Holder.Visible == true) or true) then
                local OffsetPos = Input.Position - DraggingStart
                Instance.Position = UDim2.new(
                    StartPosition.X.Scale, StartPosition.X.Offset + OffsetPos.X,
                    StartPosition.Y.Scale, StartPosition.Y.Offset + OffsetPos.Y
                )
            end
        end)
        InputService.TouchEnded:Connect(function(Input)
            if Input == DraggingInput then Dragging = false end
        end)
    end
end

function Library:MakeDraggableUsingParent(Instance, Parent, Cutoff, IsMainWindow)
    Instance.Active = true
    if Library.IsMobile == false then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow == true and Library.CantDragForced == true then return end
                local ObjPos = Vector2.new(Mouse.X - Parent.AbsolutePosition.X, Mouse.Y - Parent.AbsolutePosition.Y)
                if ObjPos.Y > (Cutoff or 40) then return end
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Parent.Position = UDim2.new(
                        0, Mouse.X - ObjPos.X + (Parent.Size.X.Offset * Parent.AnchorPoint.X),
                        0, Mouse.Y - ObjPos.Y + (Parent.Size.Y.Offset * Parent.AnchorPoint.Y)
                    )
                    RunService.RenderStepped:Wait()
                end
            end
        end)
    else
        Library:MakeDraggable(Parent, Cutoff, IsMainWindow)
    end
end

-- === ZAAWANSOWANY RESIZER Z ZAOKRĄGLENIEM ===
function Library:MakeResizable(Instance, MinSize)
    if Library.IsMobile then return end
    Instance.Active = true
    local ResizerImage_Size = 22 * DPIScale
    local ResizerImage_HoverTransparency = 0.5

    local Resizer = Library:Create("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.new(0, 30, 0, 30);
        Position = UDim2.new(1, -30, 1, -30);
        Visible = true;
        ClipsDescendants = true;
        ZIndex = 1;
        Parent = Instance;
    })

    local ResizerImage = Library:Create("ImageButton", {
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.new(2, 0, 2, 0);
        Position = UDim2.new(1, -30, 1, -30);
        ZIndex = 2;
        Parent = Resizer;
    })

    Library:AddCorner(ResizerImage, 999)

    Library:AddToRegistry(ResizerImage, { BackgroundColor3 = "AccentColor" })
    Resizer.Size = UDim2.fromOffset(ResizerImage_Size, ResizerImage_Size)
    Resizer.Position = UDim2.new(1, -ResizerImage_Size, 1, -ResizerImage_Size)
    MinSize = MinSize or Library.MinSize

    local OffsetPos
    Resizer.Parent = Instance

    local function FinishResize(Transparency)
        ResizerImage.Position = UDim2.new()
        ResizerImage.Size = UDim2.new(2, 0, 2, 0)
        ResizerImage.Parent = Resizer
        ResizerImage.BackgroundTransparency = Transparency
        OffsetPos = nil
    end

    ResizerImage.MouseButton1Down:Connect(function()
        if not OffsetPos then
            OffsetPos = Vector2.new(Mouse.X - (Instance.AbsolutePosition.X + Instance.AbsoluteSize.X), Mouse.Y - (Instance.AbsolutePosition.Y + Instance.AbsoluteSize.Y))
            ResizerImage.BackgroundTransparency = 1
            ResizerImage.Size = UDim2.fromOffset(Library.ScreenGui.AbsoluteSize.X, Library.ScreenGui.AbsoluteSize.Y)
            ResizerImage.Position = UDim2.new()
            ResizerImage.Parent = Library.ScreenGui
        end
    end)
    ResizerImage.MouseMoved:Connect(function()
        if OffsetPos then
            local MousePos = Vector2.new(Mouse.X - OffsetPos.X, Mouse.Y - OffsetPos.Y)
            local FinalSize = Vector2.new(math.clamp(MousePos.X - Instance.AbsolutePosition.X, MinSize.X, math.huge), math.clamp(MousePos.Y - Instance.AbsolutePosition.Y, MinSize.Y, math.huge))
            Instance.Size = UDim2.fromOffset(FinalSize.X, FinalSize.Y)
        end
    end)
    ResizerImage.MouseEnter:Connect(function() FinishResize(ResizerImage_HoverTransparency) end)
    ResizerImage.MouseLeave:Connect(function() FinishResize(1) end)
    ResizerImage.MouseButton1Up:Connect(function() FinishResize(ResizerImage_HoverTransparency) end)
end

-- === ULEPSZONY TOOLTIP ===
function Library:AddToolTip(InfoStr, DisabledInfoStr, HoverInstance)
    InfoStr = typeof(InfoStr) == "string" and InfoStr or nil
    DisabledInfoStr = typeof(DisabledInfoStr) == "string" and DisabledInfoStr or nil

    local Tooltip = Library:Create("Frame", {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        ZIndex = 100;
        Parent = Library.ScreenGui;
        Visible = false;
    })
    Library:AddCorner(Tooltip, 6)
    Library:AddStroke(Tooltip, Library.OutlineColor, 1, 0)

    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(8, 5);
        TextSize = 13;
        Text = InfoStr;
        TextColor3 = Library.FontColor;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1;
        Parent = Tooltip;
    })
    Library:AddToRegistry(Tooltip, { BackgroundColor3 = "MainColor"; BorderColor3 = "OutlineColor"; })
    Library:AddToRegistry(Label, { TextColor3 = "FontColor" })

    local TooltipTable = { Tooltip = Tooltip; Disabled = false; Signals = {}; }
    local IsHovering = false

    local function UpdateText(Text)
        if Text == nil then return end
        local X, Y = Library:GetTextBounds(Text, Library.Font, 13 * DPIScale)
        Label.Text = Text
        Tooltip.Size = UDim2.fromOffset(X + 16, Y + 10)
        Label.Size = UDim2.fromOffset(X, Y)
    end

    local function GiveSignal(Connection)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end
        return Connection
    end

    UpdateText(InfoStr)

    GiveSignal(HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then Tooltip.Visible = false; return end
        if not TooltipTable.Disabled then
            if InfoStr == nil or InfoStr == "" then Tooltip.Visible = false; return end
            if Label.Text ~= InfoStr then UpdateText(InfoStr) end
        else
            if DisabledInfoStr == nil or DisabledInfoStr == "" then Tooltip.Visible = false; return end
            if Label.Text ~= DisabledInfoStr then UpdateText(DisabledInfoStr) end
        end
        IsHovering = true
        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        Tooltip.Visible = true
        while IsHovering do
            if TooltipTable.Disabled == true and DisabledInfoStr == nil then break end
            RunService.Heartbeat:Wait()
            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        end
        IsHovering = false
        Tooltip.Visible = false
    end))

    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end))

    if LibraryMainOuterFrame then
        GiveSignal(LibraryMainOuterFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if LibraryMainOuterFrame.Visible == false then
                IsHovering = false
                Tooltip.Visible = false
            end
        end))
    end

    function TooltipTable:Destroy()
        for Idx = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Idx)
            if Connection and Connection.Connected then Connection:Disconnect() end
        end
        Tooltip:Destroy()
    end

    table.insert(Tooltips, TooltipTable)
    return TooltipTable
end

function Library:MouseIsOverFrame(Frame, Input)
    local Pos = Mouse
    if Library.IsMobile and Input then Pos = Input.Position end
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
        and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then
        return true
    end
    return false
end

function Library:IsFrameInsideDialog(Frame)
    if not Library.ActiveDialog then return false end
    local Pos = Frame.AbsolutePosition
    local AbsPos, AbsSize = Library.ActiveDialog.Container.AbsolutePosition, Library.ActiveDialog.Container.AbsoluteSize
    if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
        and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then
        return true
    end
    return false
end

function Library:MouseIsOverOpenedFrame(Input)
    if Library.ActiveDialog then
        if Library:MouseIsOverFrame(Library.ActiveDialog.Container, Input) then return false end
        return true
    end
    for Frame in next, Library.OpenedFrames do
        if Library:MouseIsOverFrame(Frame, Input) then return true end
    end
    return false
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault, condition)
    local function undoHighlight()
        local Reg = Library.RegistryMap[Instance]
        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx
            if Reg and Reg.Properties[Property] then Reg.Properties[Property] = ColorIdx end
        end
    end
    local function doHighlight()
        if condition and not condition() then undoHighlight(); return end
        if Library.ActiveDialog and not Library:IsFrameInsideDialog(Instance) then undoHighlight(); return end
        local Reg = Library.RegistryMap[Instance]
        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx
            if Reg and Reg.Properties[Property] then Reg.Properties[Property] = ColorIdx end
        end
    end
    HighlightInstance.MouseEnter:Connect(doHighlight)
    HighlightInstance.MouseMoved:Connect(doHighlight)
    HighlightInstance.MouseLeave:Connect(undoHighlight)
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do Depbox:Update() end
end

function Library:UpdateDependencyGroupboxes()
    for _, Depbox in next, Library.DependencyGroupboxes do Depbox:Update() end
end

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB
end

function Library:GetTextBounds(Text, Font, Size, Resolution)
    if typeof(Resolution) == "number" then Resolution = Vector2.new(Resolution, 10000) end
    local Bounds = TextService:GetTextSize(Text:gsub("<%/?[%w:]+[^>]*>", ""), Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end

function Library:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1
    local Data = { Instance = Instance; Properties = Properties; Idx = Idx; }
    table.insert(Library.Registry, Data)
    Library.RegistryMap[Instance] = Data
    if IsHud then table.insert(Library.HudRegistry, Data) end
end

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance]
    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then table.remove(Library.Registry, Idx) end
        end
        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then table.remove(Library.HudRegistry, Idx) end
        end
        Library.RegistryMap[Instance] = nil
    end
end

function Library:UpdateColorsUsingRegistry()
    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if typeof(ColorIdx) == "string" then
                Object.Instance[Property] = Library[ColorIdx]
            elseif typeof(ColorIdx) == "function"
