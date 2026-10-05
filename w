local Limbo = {}
local LIB_VERSION = "2.0.7"
Limbo.Version = LIB_VERSION

Limbo._resetCallbacks = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer.PlayerGui
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local ConfigFolder = "LimboConfig"

local function CircleClick(Button, X, Y)
    spawn(
        function()
            Button.ClipsDescendants = true
            local Circle = Instance.new("ImageLabel")
            Circle.Image = "rbxassetid://266543268"
            Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
            Circle.ImageTransparency = 0.9
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.BackgroundTransparency = 1
            Circle.ZIndex = 10
            Circle.Name = "Circle"
            Circle.Parent = Button

            local NewX = X - Circle.AbsolutePosition.X
            local NewY = Y - Circle.AbsolutePosition.Y
            Circle.Position = UDim2.new(0, NewX, 0, NewY)
            local Size = 0
            if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.X * 1.5
            elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.Y * 1.5
            elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.X * 1.5
            end

            local Time = 0.5
            Circle:TweenSizeAndPosition(
                UDim2.new(0, Size, 0, Size),
                UDim2.new(0.5, -Size / 2, 0.5, -Size / 2),
                "Out",
                "Quad",
                Time,
                false,
                nil
            )
            for i = 1, 10 do
                Circle.ImageTransparency = Circle.ImageTransparency + 0.01
                wait(Time / 10)
            end
            Circle:Destroy()
        end
    )
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos =
            UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        object.Position = pos
    end

    topbarobject.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position

                input.Changed:Connect(
                    function()
                        if input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                        end
                    end
                )
            end
        end
    )

    topbarobject.InputChanged:Connect(
        function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch
             then
                DragInput = input
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)
            if input == DragInput and Dragging then
                UpdatePos(input)
            end
        end
    )
end

local function MakeDraggableMobileButton(button, object, screenGui)
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    local ClickStartPos = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local newX = StartPosition.X + Delta.X
        local newY = StartPosition.Y + Delta.Y

        local screenSize = screenGui.AbsoluteSize
        local buttonSize = object.AbsoluteSize

        local padding = 10
        newX = math.clamp(newX, padding, screenSize.X - buttonSize.X - padding)
        newY = math.clamp(newY, padding, screenSize.Y - buttonSize.Y - padding)

        object.Position = UDim2.new(0, newX, 0, newY)
    end

    pcall(function() button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            ClickStartPos = input.Position
            DragStart = input.Position
            pcall(function()
                StartPosition = Vector2.new(object.AbsolutePosition.X, object.AbsolutePosition.Y)
            end)
            if not StartPosition then
                StartPosition = Vector2.new(object.Position.X.Offset, object.Position.Y.Offset)
            end
        end
    end) end)

    pcall(function() UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end) end)

    pcall(function() button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if not Dragging and ClickStartPos then
                local dragDistance = (input.Position - ClickStartPos).Magnitude
                if dragDistance > 5 then Dragging = true end
            end
            DragInput = input
        end
    end) end)

    pcall(function() UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePos(input)
        end
    end) end)

    return function()
        return Dragging
    end
end

local function MakeResizable(resizeHandle, targetObject, minSize, maxSize, onResize)
    minSize = minSize or Vector2.new(300, 200)
    maxSize = maxSize or Vector2.new(1000, 800)

    local isResizing = false
    local resizeStartPos = nil
    local startSize = nil
    local startMousePos = nil

    resizeHandle.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = true
                resizeStartPos = targetObject.Position
                startSize = Vector2.new(targetObject.Size.X.Offset, targetObject.Size.Y.Offset)
                startMousePos = input.Position

                input.Changed:Connect(function()
                    if not isResizing then return end
                    if input.UserInputState == Enum.UserInputState.End then
                        isResizing = false
                        return
                    end
                    local delta = input.Position - startMousePos
                    local newWidth  = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
                    local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
                    targetObject.Size = UDim2.new(0, newWidth, 0, newHeight)
                    if onResize then onResize(Vector2.new(newWidth, newHeight)) end
                end)
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = false
            end
        end
    )
end


local LUCIDE_URL = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
local LucideIcons = nil

local function GetLucideIcons()
    if LucideIcons then return LucideIcons end
    local cachePath = "LimboHUB/assets/.lucide_icons.lua"
    pcall(function()
        if isfile and isfile(cachePath) then
            local src = readfile(cachePath)
            if src and #src > 1000 then
                local fn = loadstring(src)
                if fn then LucideIcons = fn() end
            end
        end
    end)
    if not LucideIcons then
        pcall(function()
            local src = game:HttpGet(LUCIDE_URL)
            if src and #src > 1000 then
                if makefolder and isfolder and not isfolder("LimboHUB") then makefolder("LimboHUB") end
                if makefolder and isfolder and not isfolder("LimboHUB/assets") then makefolder("LimboHUB/assets") end
                if writefile then writefile(cachePath, src) end
                local fn = loadstring(src)
                if fn then LucideIcons = fn() end
            end
        end)
    end
    LucideIcons = LucideIcons or {}
    return LucideIcons
end

local ICON_ALIASES = {
    ["home"] = "house",
    ["gear"] = "settings",
    ["cog"] = "settings",
    ["config"] = "settings",
    ["configuration"] = "settings",
    ["setting"] = "settings",
    ["location"] = "map-pin",
    ["teleport"] = "map-pin",
    ["player"] = "user",
    ["players"] = "users",
    ["money"] = "banknote",
    ["coin"] = "coins",
    ["barcode"] = "scan-barcode",
    ["qr"] = "scan-qr-code",
    ["qrcode"] = "scan-qr-code",
    ["scan"] = "scan-qr-code",
    ["exit"] = "log-out",
    ["quit"] = "x",
    ["close"] = "x",
}

local function ResolveIcon(icon)
    if not icon or icon == "" then return nil end
    if type(icon) == "number" then return "rbxassetid://" .. tostring(icon) end
    if type(icon) ~= "string" then return nil end
    
    if icon:match("^https?://") then
        local ok, customAsset = pcall(function()
            local cleanName = icon:gsub("[^%w%.%-_]", "_")
            if #cleanName > 64 then cleanName = string.sub(cleanName, -60) end
            local path = "LimboHUB/assets/." .. cleanName
            if makefolder and isfolder and not isfolder("LimboHUB") then makefolder("LimboHUB") end
            if makefolder and isfolder and not isfolder("LimboHUB/assets") then makefolder("LimboHUB/assets") end
            if isfile and not isfile(path) then
                local req = (syn and syn.request) or (http and http.request) or request or http_request
                local body = (game.HttpGet and game:HttpGet(icon)) or (req and req({Url = icon, Method = "GET"}).Body)
                if body and writefile then writefile(path, body) end
            end
            if getcustomasset and isfile and isfile(path) then
                return getcustomasset(path)
            end
            return nil
        end)
        if ok and customAsset then return customAsset end
    end

    if icon:match("^rbxasset") or icon:match("^rbxthumb") then
        return icon
    end

    local clean = icon
    if clean:sub(1, 7) == "lucide:" then
        clean = clean:sub(8)
    end

    local lower = clean:lower()
    if ICON_ALIASES[lower] then
        lower = ICON_ALIASES[lower]
    end

    local icons = GetLucideIcons()
    if icons[clean] then return icons[clean] end
    if icons[lower] then return icons[lower] end
    

    return icon
end

local ConfigSystem = {
    CurrentConfig = nil,
    Configs = {},
    ThemeColors = {
        ["Limbo"] = Color3.fromRGB(150, 150, 170),
        ["Darker"] = Color3.fromRGB(150, 150, 170),
        ["Purple"] = Color3.fromHex("#A000FF"),
        ["Magenta"] = Color3.fromHex("#FF00E0"),
    },
    CurrentTheme = "Darker",
    ThemeElements = {},
    ToggleElements = {},
    SliderElements = {},
    DropdownElements = {},
    TabElements = {},
    AllElements = {},
    DropdownOptionFrames = {}
}

function ConfigSystem:SetTheme(themeName)
    if self.ThemeColors[themeName] then
        self.CurrentTheme = themeName
        local newColor = self.ThemeColors[themeName]
        self:UpdateAllThemeElements(newColor)
        return true, newColor
    end
    return false, nil
end

function ConfigSystem:UpdateAllThemeElements(newColor)
    for _, toggle in pairs(self.ToggleElements) do
        if toggle and toggle:IsA("Frame") then
            local featureFrame = toggle:FindFirstChild("FeatureFrame")
            local toggleCircle = toggle:FindFirstChild("ToggleCircle")
            local frameStroke = featureFrame and featureFrame:FindFirstChild("UIStroke")
            local toggleTitle = toggle:FindFirstChild("ToggleTitle")

            if toggleCircle then
                local isOn = toggleCircle.Position == UDim2.new(0, 15, 0, 0)
                if isOn then
                    toggleCircle.BackgroundColor3 = newColor
                    if frameStroke then
                        frameStroke.Color = newColor
                    end
                    if featureFrame then
                        featureFrame.BackgroundColor3 = newColor
                    end
                    if toggleTitle then
                        toggleTitle.TextColor3 = newColor
                    end
                end
            end
        end
    end

    for _, slider in pairs(self.SliderElements) do
        if slider and slider:IsA("Frame") then
            local sliderFill = slider:FindFirstChild("SliderFill")

            if sliderFill then
                sliderFill.BackgroundColor3 = newColor
            end
        end
    end

    for _, dropdown in pairs(self.DropdownElements) do
        if dropdown and dropdown:IsA("Frame") then
            local dropdownList = dropdown:FindFirstChild("DropdownList")
            if dropdownList then
                local listScroll = dropdownList:FindFirstChild("ListScroll")
                if listScroll then
                    for _, option in listScroll:GetChildren() do
                        if option:IsA("Frame") and option.Name == "Option" then
                            local chooseFrame = option:FindFirstChild("ChooseFrame")
                            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
                            local optionText = option:FindFirstChild("OptionText")

                            if chooseFrame then
                                chooseFrame.BackgroundColor3 = newColor
                            end
                            if chooseStroke then
                                chooseStroke.Color = newColor
                            end
                            if optionText and optionText.TextColor3 ~= Color3.fromRGB(230, 230, 230) then
                                optionText.TextColor3 = newColor
                            end
                        end
                    end
                end
            end
        end
    end

    for _, optionData in pairs(self.DropdownOptionFrames) do
        if optionData.Frame and optionData.Frame.Parent then
            local chooseFrame = optionData.Frame:FindFirstChild("ChooseFrame")
            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
            local optionText = optionData.Frame:FindFirstChild("OptionText")

            if optionData.IsSelected then
                if chooseFrame then
                    chooseFrame.BackgroundColor3 = newColor
                end
                if chooseStroke then
                    chooseStroke.Color = newColor
                end
                if optionText then
                    optionText.TextColor3 = newColor
                end
            end
        end
    end

    for _, tab in pairs(self.TabElements) do
        if tab and tab:IsA("Frame") then
            local chooseFrame = tab:FindFirstChild("ChooseFrame")
            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")

            if chooseFrame then
                chooseFrame.BackgroundColor3 = newColor
            end
            if chooseStroke then
                chooseStroke.Color = newColor
            end
        end
    end

    for _, element in pairs(self.ThemeElements) do
        if element and element:IsA("Frame") and element:FindFirstChild("ChooseFrame") then
            local chooseFrame = element.ChooseFrame
            if chooseFrame then
                chooseFrame.BackgroundColor3 = newColor
                local stroke = chooseFrame:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = newColor
                end
            end
        elseif type(element) == "table" and element.Update then
            element.Update(newColor)
        end
    end

    return newColor
end

function ConfigSystem:EnsureFolder()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

function ConfigSystem:SaveConfig(name, data)
    self:EnsureFolder()

    local success, encoded =
        pcall(
        function()
            return HttpService:JSONEncode(data or {})
        end
    )

    if success then
        writefile(ConfigFolder .. "/" .. name .. ".json", encoded)
        self.CurrentConfig = name

        return {
            Title = "Config",
            Description = "Saved",
            Content = "Config '" .. name .. "' saved successfully!",
            Color = self.ThemeColors[self.CurrentTheme],
            Delay = 3
        }
    else
        return {
            Title = "Config",
            Description = "Error",
            Content = "Failed to save config: " .. tostring(encoded),
            Color = Color3.fromRGB(150, 150, 170),
            Delay = 3
        }
    end
end

function ConfigSystem:LoadConfig(name)
    self:EnsureFolder()
    local filePath = ConfigFolder .. "/" .. name .. ".json"

    if isfile(filePath) then
        local success, content =
            pcall(
            function()
                return readfile(filePath)
            end
        )

        if success then
            local decodeSuccess, decoded =
                pcall(
                function()
                    return HttpService:JSONDecode(content)
                end
            )

            if decodeSuccess and decoded then
                self.CurrentConfig = name
                -- support both flat format and legacy {Data=...} format
                local configData = decoded.Data or decoded
                return {
                    Title = "Config",
                    Description = "Loaded",
                    Content = "Config '" .. name .. "' loaded successfully!",
                    Color = self.ThemeColors[self.CurrentTheme],
                    Delay = 3
                }, configData
            end
        end
    end

    return {
        Title = "Config",
        Description = "Error",
        Content = "Config '" .. name .. "' not found or corrupted!",
        Color = Color3.fromRGB(150, 150, 170),
        Delay = 3
    }, nil
end

function ConfigSystem:DeleteConfig(name)
    self:EnsureFolder()
    local filePath = ConfigFolder .. "/" .. name .. ".json"

    if isfile(filePath) then
        local success =
            pcall(
            function()
                delfile(filePath)
            end
        )

        if success then
            if self.CurrentConfig == name then
                self.CurrentConfig = nil
            end

            return {
                Title = "Config",
                Description = "Deleted",
                Content = "Config '" .. name .. "' deleted successfully!",
                Color = self.ThemeColors[self.CurrentTheme],
                Delay = 3
            }
        end
    end

    return {
        Title = "Config",
        Description = "Error",
        Content = "Config '" .. name .. "' not found!",
        Color = Color3.fromRGB(150, 150, 170),
        Delay = 3
    }
end

function ConfigSystem:GetConfigList()
    self:EnsureFolder()
    local configs = {}

    local success, files =
        pcall(
        function()
            return listfiles(ConfigFolder)
        end
    )

    if success and files then
        for _, filePath in ipairs(files) do
            local fileName = filePath:match("([^/\\]+)%.json$")
            if fileName then
                table.insert(configs, fileName)
            end
        end
    end

    return configs
end

local function MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Notification"
    NotifyConfig.Description = NotifyConfig.Description or ""
    NotifyConfig.Content = (NotifyConfig.Content and tostring(NotifyConfig.Content) ~= "" and tostring(NotifyConfig.Content))
        or (NotifyConfig.Description and tostring(NotifyConfig.Description) ~= "" and tostring(NotifyConfig.Description))
        or "Notification"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromHex("#FF00E0")
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = tonumber(NotifyConfig.Delay or NotifyConfig.Duration) or 4

    local NotifyFunction = {}

    task.spawn(
        function()
            local notifyGuiParent = (gethui and gethui()) or CoreGui
            local notifyGui = notifyGuiParent:FindFirstChild("NotifyGui")
            if not notifyGui then
                notifyGui = Instance.new("ScreenGui")
                notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                notifyGui.Name = "NotifyGui"
                notifyGui.Parent = notifyGuiParent
            end

            local notifyLayout = notifyGui:FindFirstChild("NotifyLayout")
            if not notifyLayout then
                notifyLayout = Instance.new("Frame")
                notifyLayout.AnchorPoint = Vector2.new(1, 1)
                notifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                notifyLayout.BackgroundTransparency = 0.999
                notifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
                notifyLayout.BorderSizePixel = 0
                notifyLayout.Position = UDim2.new(1, -30, 1, -30)
                notifyLayout.Size = UDim2.new(0, 320, 1, 0)
                notifyLayout.Name = "NotifyLayout"
                notifyLayout.Parent = notifyGui

                local notifyScale = Instance.new("UIScale")
                notifyScale.Name = "NotifyUIScale"
                notifyScale.Scale = 1.0
                notifyScale.Parent = notifyLayout

                local function syncNotifyScale()
                    local cam = workspace.CurrentCamera
                    if cam then
                        local vp = cam.ViewportSize
                        local minDim = math.min(vp.X, vp.Y)
                        local s = math.clamp(minDim / 600, 0.75, 1.0)
                        notifyScale.Scale = s
                    end
                end

                pcall(function()
                    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(syncNotifyScale)
                    syncNotifyScale()
                end)

                notifyLayout.ChildRemoved:Connect(
                    function()
                        local Count = 0
                        for _, v in ipairs(notifyLayout:GetChildren()) do
                            if v:IsA("Frame") then
                                TweenService:Create(
                                    v,
                                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                                    {Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count))}
                                ):Play()
                                Count = Count + 1
                            end
                        end
                    end
                )
            end

            local NotifyPosHeigh = 0
            for _, v in ipairs(notifyLayout:GetChildren()) do
                if v:IsA("Frame") then
                    NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
                end
            end

            local NotifyFrame = Instance.new("Frame")
            local NotifyFrameReal = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local DropShadowHolder = Instance.new("Frame")
            local DropShadow = Instance.new("ImageLabel")
            local Top = Instance.new("Frame")
            local TextLabel = Instance.new("TextLabel")
            local UIStroke = Instance.new("UIStroke")
            local UICorner1 = Instance.new("UICorner")
            local TextLabel1 = Instance.new("TextLabel")
            local UIStroke1 = Instance.new("UIStroke")
            local Close = Instance.new("TextButton")
            local ImageLabel = Instance.new("ImageLabel")
            local TextLabel2 = Instance.new("TextLabel")

            NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrame.BorderSizePixel = 0
            NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
            NotifyFrame.Name = "NotifyFrame"
            NotifyFrame.BackgroundTransparency = 1
            NotifyFrame.Parent = notifyLayout
            NotifyFrame.AnchorPoint = Vector2.new(0, 1)
            NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

            NotifyFrameReal.BackgroundColor3 = Color3.fromHex("#141414")
            NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrameReal.BorderSizePixel = 0
            NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
            NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
            NotifyFrameReal.Name = "NotifyFrameReal"
            NotifyFrameReal.Parent = NotifyFrame

            UICorner.CornerRadius = UDim.new(0, 18)
            UICorner.Parent = NotifyFrameReal

            local NotifyStroke = Instance.new("UIStroke")
            NotifyStroke.Color = Color3.fromHex("#2A2A2A")
            NotifyStroke.Thickness = 1
            NotifyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            NotifyStroke.Parent = NotifyFrameReal

            -- Accent pill kiri
            local AccentPill = Instance.new("Frame")
            AccentPill.BackgroundColor3 = NotifyConfig.Color
            AccentPill.Size = UDim2.new(0, 3, 0.6, 0)
            AccentPill.Position = UDim2.new(0, 6, 0.2, 0)
            AccentPill.BorderSizePixel = 0
            AccentPill.ZIndex = 4
            AccentPill.Parent = NotifyFrameReal
            local PillCorner = Instance.new("UICorner")
            PillCorner.CornerRadius = UDim.new(1, 0)
            PillCorner.Parent = AccentPill

            DropShadowHolder.BackgroundTransparency = 1
            DropShadowHolder.BorderSizePixel = 0
            DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
            DropShadowHolder.ZIndex = 0
            DropShadowHolder.Name = "DropShadowHolder"
            DropShadowHolder.Parent = NotifyFrameReal

            DropShadow.Image = "rbxassetid://6015897843"
            DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            DropShadow.ImageTransparency = 0.5
            DropShadow.ScaleType = Enum.ScaleType.Slice
            DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
            DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
            DropShadow.BackgroundTransparency = 1
            DropShadow.BorderSizePixel = 0
            DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            DropShadow.Size = UDim2.new(1, 47, 1, 47)
            DropShadow.ZIndex = 0
            DropShadow.Name = "DropShadow"
            DropShadow.Parent = DropShadowHolder

            Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Top.BackgroundTransparency = 0.999
            Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Top.BorderSizePixel = 0
            Top.Size = UDim2.new(1, 0, 0, 36)
            Top.Name = "Top"
            Top.Parent = NotifyFrameReal

            Top.Size = UDim2.new(1, -30, 0, 26)
            Top.Position = UDim2.new(0, 10, 0, 8)

            local TopLayout = Instance.new("UIListLayout")
            TopLayout.FillDirection = Enum.FillDirection.Horizontal
            TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            TopLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TopLayout.Padding = UDim.new(0, 6)
            TopLayout.Parent = Top

            local notifyIconUrl = ResolveIcon(NotifyConfig.Icon or "rbxassetid://97957114633547")
            if notifyIconUrl then
                local NIcon = Instance.new("ImageLabel")
                NIcon.Image = notifyIconUrl
                NIcon.BackgroundTransparency = 1
                NIcon.Size = UDim2.new(0, 16, 0, 16)
                NIcon.LayoutOrder = 1
                NIcon.Parent = Top
            end

            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.Text = NotifyConfig.Title
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextSize = 13
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.LayoutOrder = 2
            TextLabel.Parent = Top

            if NotifyConfig.Subtitle and NotifyConfig.Subtitle ~= "" then
                local SubLabel = Instance.new("TextLabel")
                SubLabel.Font = Enum.Font.GothamBold
                SubLabel.Text = "• " .. tostring(NotifyConfig.Subtitle)
                SubLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
                SubLabel.TextSize = 11
                SubLabel.TextXAlignment = Enum.TextXAlignment.Left
                SubLabel.BackgroundTransparency = 1
                SubLabel.BorderSizePixel = 0
                SubLabel.AutomaticSize = Enum.AutomaticSize.XY
                SubLabel.LayoutOrder = 3
                SubLabel.Parent = Top
            end

            if NotifyConfig.Description and NotifyConfig.Description ~= "" and NotifyConfig.Description ~= NotifyConfig.Title then
                TextLabel1.Font = Enum.Font.GothamBold
                TextLabel1.Text = NotifyConfig.Description
                TextLabel1.TextColor3 = NotifyConfig.Color
                TextLabel1.TextSize = 12
                TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel1.BackgroundTransparency = 1
                TextLabel1.BorderSizePixel = 0
                TextLabel1.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel1.LayoutOrder = 4
                TextLabel1.Parent = Top
            else
                TextLabel1.Visible = false
            end

            Close.Font = Enum.Font.SourceSans
            Close.Text = ""
            Close.TextColor3 = Color3.fromRGB(0, 0, 0)
            Close.TextSize = 14
            Close.AnchorPoint = Vector2.new(1, 0.5)
            Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Close.BackgroundTransparency = 0.999
            Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Close.BorderSizePixel = 0
            Close.Position = UDim2.new(1, -6, 0, 20)
            Close.Size = UDim2.new(0, 22, 0, 22)
            Close.Name = "Close"
            Close.Parent = NotifyFrameReal

            ImageLabel.Image = "rbxassetid://9886659671"
            ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ImageLabel.BackgroundTransparency = 0.999
            ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ImageLabel.BorderSizePixel = 0
            ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageLabel.Size = UDim2.new(1, -8, 1, -8)
            ImageLabel.Parent = Close

            TextLabel2.Font = Enum.Font.GothamBold
            TextLabel2.Text = NotifyConfig.Content
            TextLabel2.TextSize = 12
            TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
            TextLabel2.BackgroundTransparency = 1
            TextLabel2.TextColor3 = Color3.fromRGB(240, 240, 245)
            TextLabel2.TextTransparency = 0.1
            TextLabel2.BorderSizePixel = 0
            TextLabel2.Position = UDim2.new(0, 14, 0, 36)
            TextLabel2.Size = UDim2.new(1, -28, 0, 0)
            TextLabel2.AutomaticSize = Enum.AutomaticSize.Y
            TextLabel2.TextWrapped = true
            TextLabel2.Parent = NotifyFrameReal

            local contentHeight = TextService:GetTextSize(
                NotifyConfig.Content or "",
                12,
                Enum.Font.GothamBold,
                Vector2.new(270, math.huge)
            ).Y
            NotifyFrame.Size = UDim2.new(1, 0, 0, math.max(62, contentHeight + 46))

            local waitbruh = false
            function NotifyFunction:Close()
                if waitbruh then
                    return false
                end
                waitbruh = true
                TweenService:Create(
                    NotifyFrameReal,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    {Position = UDim2.new(0, 400, 0, 0)}
                ):Play()
                task.wait(tonumber(NotifyConfig.Time) / 1.2)
                NotifyFrame:Destroy()
            end

            Close.Activated:Connect(
                function()
                    NotifyFunction:Close()
                end
            )

            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, 0)}
            ):Play()
            task.wait(tonumber(NotifyConfig.Delay))
            NotifyFunction:Close()
        end
    )

    return NotifyFunction
end


-- Close confirmation modal (module-level: avoids CreateWindow local limit)
local function setupCloseModal(closeBtn, main, screenGui)
    local overlay = Instance.new("Frame")
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.ZIndex = 50
    overlay.Active = true
    overlay.Visible = false
    overlay.Parent = main
    local dialog = Instance.new("Frame")
    dialog.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    dialog.BorderSizePixel = 0
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.Size = UDim2.new(0, 300, 0, 155)
    dialog.ZIndex = 51
    dialog.Parent = overlay
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(0, 10)
    dc.Parent = dialog
    local ds = Instance.new("UIStroke")
    ds.Color = Color3.fromRGB(150, 150, 170)
    ds.Thickness = 1.5
    ds.Parent = dialog
    local dt = Instance.new("TextLabel")
    dt.Font = Enum.Font.GothamBold
    dt.Text = "Close Window"
    dt.TextColor3 = Color3.fromRGB(255, 255, 255)
    dt.TextSize = 24
    dt.BackgroundTransparency = 1
    dt.Size = UDim2.new(1, 0, 0, 36)
    dt.Position = UDim2.new(0, 0, 0, 10)
    dt.TextXAlignment = Enum.TextXAlignment.Center
    dt.ZIndex = 52
    dt.Parent = dialog
    local body = Instance.new("TextLabel")
    body.Font = Enum.Font.Gotham
    body.Text = "Are you sure you want to close this window?"
    body.TextColor3 = Color3.fromRGB(150, 150, 170)
    body.TextSize = 15
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1, -20, 0, 28)
    body.Position = UDim2.new(0, 10, 0, 52)
    body.TextXAlignment = Enum.TextXAlignment.Center
    body.TextWrapped = true
    body.ZIndex = 52
    body.Parent = dialog
    local sub = Instance.new("TextLabel")
    sub.Font = Enum.Font.Gotham
    sub.Text = "You will not be able to open it again"
    sub.TextColor3 = Color3.fromRGB(150, 150, 170)
    sub.TextSize = 15
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, -20, 0, 18)
    sub.Position = UDim2.new(0, 10, 0, 82)
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.ZIndex = 52
    sub.Parent = dialog
    local btnYes = Instance.new("TextButton")
    btnYes.Font = Enum.Font.GothamBold
    btnYes.Text = "Yes"
    btnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnYes.TextSize = 14
    btnYes.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btnYes.BorderSizePixel = 0
    btnYes.Size = UDim2.new(0, 120, 0, 32)
    btnYes.Position = UDim2.new(0, 16, 1, -44)
    btnYes.ZIndex = 52
    btnYes.AutoButtonColor = false
    btnYes.Parent = dialog
    local yc = Instance.new("UICorner")
    yc.CornerRadius = UDim.new(0, 6)
    yc.Parent = btnYes
    local btnCancel = Instance.new("TextButton")
    btnCancel.Font = Enum.Font.GothamBold
    btnCancel.Text = "Cancel"
    btnCancel.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCancel.TextSize = 14
    btnCancel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btnCancel.BorderSizePixel = 0
    btnCancel.Size = UDim2.new(0, 120, 0, 32)
    btnCancel.Position = UDim2.new(1, -136, 1, -44)
    btnCancel.ZIndex = 52
    btnCancel.AutoButtonColor = false
    btnCancel.Parent = dialog
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = btnCancel
    btnCancel.Activated:Connect(function() overlay.Visible = false end)
    btnYes.Activated:Connect(function()
        for _, fn in pairs(Limbo._resetCallbacks) do
            pcall(fn)
        end
        task.wait(0.1)
        screenGui:Destroy()
    end)
    closeBtn.Activated:Connect(function()
        CircleClick(closeBtn, Mouse.X, Mouse.Y)
        overlay.Visible = true
    end)
end

local function setupKeySystemModal(ksConfig, screenGui, dropShadowHolder, onComplete)
    if not ksConfig or type(ksConfig) ~= "table" then
        if onComplete then onComplete() end
        return
    end

    local keyFile = "LimboHUB/saved_key.txt"
    if ksConfig.SaveKey and isfile and isfile(keyFile) then
        local saved = readfile(keyFile):gsub("%s+", "")
        if saved ~= "" and ksConfig.KeyValidator and ksConfig.KeyValidator(saved) then
            if onComplete then onComplete() end
            return
        end
    end

    dropShadowHolder.Visible = false

    local KeyHolder = Instance.new("Frame")
    KeyHolder.Name = "KeySystemHolder"
    KeyHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    KeyHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    KeyHolder.Size = UDim2.fromOffset(360, 220)
    KeyHolder.BackgroundColor3 = Color3.fromHex("#141414")
    KeyHolder.BorderSizePixel = 0
    KeyHolder.ZIndex = 50000
    KeyHolder.Parent = screenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = KeyHolder

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromHex("#2A2A2A")
    Stroke.Thickness = 1
    Stroke.Parent = KeyHolder

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft = UDim.new(0, 16)
    Pad.PaddingRight = UDim.new(0, 16)
    Pad.PaddingTop = UDim.new(0, 14)
    Pad.PaddingBottom = UDim.new(0, 14)
    Pad.Parent = KeyHolder

    local VList = Instance.new("UIListLayout")
    VList.FillDirection = Enum.FillDirection.Vertical
    VList.Padding = UDim.new(0, 10)
    VList.SortOrder = Enum.SortOrder.LayoutOrder
    VList.Parent = KeyHolder

    local TopRow = Instance.new("Frame")
    TopRow.BackgroundTransparency = 1
    TopRow.Size = UDim2.new(1, 0, 0, 24)
    TopRow.LayoutOrder = 1
    TopRow.Parent = KeyHolder

    local TopLayout = Instance.new("UIListLayout")
    TopLayout.FillDirection = Enum.FillDirection.Horizontal
    TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TopLayout.Padding = UDim.new(0, 8)
    TopLayout.Parent = TopRow

    local Logo = Instance.new("ImageLabel")
    Logo.Image = "rbxassetid://97957114633547"
    Logo.Size = UDim2.fromOffset(20, 20)
    Logo.BackgroundTransparency = 1
    Logo.Parent = TopRow

    local Title = Instance.new("TextLabel")
    Title.Text = ksConfig.Title or "Limbo Hub Access"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopRow

    local Note = Instance.new("TextLabel")
    Note.Text = ksConfig.Note or "Enter a valid key to access Limbo Hub."
    Note.Font = Enum.Font.Gotham
    Note.TextSize = 11
    Note.TextColor3 = Color3.fromRGB(160, 160, 170)
    Note.BackgroundTransparency = 1
    Note.TextWrapped = true
    Note.TextXAlignment = Enum.TextXAlignment.Left
    Note.Size = UDim2.new(1, 0, 0, 32)
    Note.LayoutOrder = 2
    Note.Parent = KeyHolder

    local InputBox = Instance.new("TextBox")
    InputBox.PlaceholderText = "Paste your key here..."
    InputBox.Text = ""
    InputBox.Font = Enum.Font.GothamBold
    InputBox.TextSize = 12
    InputBox.TextColor3 = Color3.fromRGB(240, 240, 240)
    InputBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 120)
    InputBox.BackgroundColor3 = Color3.fromHex("#1C1C1C")
    InputBox.BorderSizePixel = 0
    InputBox.Size = UDim2.new(1, 0, 0, 36)
    InputBox.ClearTextOnFocus = false
    InputBox.LayoutOrder = 3
    InputBox.Parent = KeyHolder
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
    local InpStroke = Instance.new("UIStroke", InputBox)
    InpStroke.Color = Color3.fromHex("#2E2E2E")
    InpStroke.Thickness = 1

    local BtnRow = Instance.new("Frame")
    BtnRow.BackgroundTransparency = 1
    BtnRow.Size = UDim2.new(1, 0, 0, 32)
    BtnRow.LayoutOrder = 4
    BtnRow.Parent = KeyHolder

    local BLayout = Instance.new("UIListLayout")
    BLayout.FillDirection = Enum.FillDirection.Horizontal
    BLayout.Padding = UDim.new(0, 8)
    BLayout.Parent = BtnRow

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.TextSize = 12
    GetKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    GetKeyBtn.BackgroundColor3 = Color3.fromHex("#232323")
    GetKeyBtn.Size = UDim2.new(0.5, -4, 1, 0)
    GetKeyBtn.Parent = BtnRow
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Text = "Submit Key"
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.TextSize = 12
    SubmitBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    SubmitBtn.BackgroundColor3 = Color3.fromHex("#2A2A2A")
    SubmitBtn.Size = UDim2.new(0.5, -4, 1, 0)
    SubmitBtn.Parent = BtnRow
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

    GetKeyBtn.Activated:Connect(function()
        local copy = setclipboard or toclipboard
        if copy and ksConfig.URL then
            copy(ksConfig.URL)
            MakeNotify({
                Title = "Limbo HUB",
                Content = "Key URL copied to clipboard!",
                Delay = 3
            })
        end
    end)

    SubmitBtn.Activated:Connect(function()
        local key = InputBox.Text:gsub("%s+", "")
        if key == "" then
            MakeNotify({ Title = "Key System", Content = "Please enter a key first!", Delay = 2 })
            return
        end
        SubmitBtn.Text = "Verifying..."
        task.spawn(function()
            local valid = ksConfig.KeyValidator and ksConfig.KeyValidator(key)
            if valid then
                if ksConfig.SaveKey and writefile then
                    if makefolder and not isfolder("LimboHUB") then makefolder("LimboHUB") end
                    writefile(keyFile, key)
                end
                KeyHolder:Destroy()
                dropShadowHolder.Visible = true
                if onComplete then onComplete() end
            else
                SubmitBtn.Text = "Submit Key"
                MakeNotify({ Title = "Key System", Content = "Invalid key! Please try again.", Delay = 3 })
            end
        end)
    end)
end

function Limbo:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Limbo UI"
    local Theme = config.Theme or "Limbo"
    local Size = config.Size or UDim2.fromOffset(560, 340)
    local Center = config.Center ~= false
    local Draggable = config.Draggable ~= false
    local Resizable = config.Resizable or config.Resize or false
    local MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    local rawGame = config.Subtitle or config.Folder or (game.Name ~= "" and game.Name) or "Game"
    local gameClean = rawGame:gsub("%s+", ""):gsub("[^%w]", "")
    if gameClean == "" then gameClean = "Game" end

    if config.ConfigFolder then
        ConfigFolder = config.ConfigFolder
    else
        ConfigFolder = "Limbo" .. gameClean .. "/Config"
    end
    local MinimizeButton = config.MinimizeButton or false
    local MinimizeButtonImage = config.MinimizeButton_Image or "rbxassetid://16932740082"
    local Badges = config.Badges or {}
    local Icon = ResolveIcon(config.Icon or "rbxassetid://97957114633547")
    local TitleImage = config.TitleImage or ""
    local Version = config.Version or ("v" .. LIB_VERSION)
    local ShowExecutor = config.ShowExecutor ~= false
    local ConfigData = config.Config or {}
    local Background = config.Background or config.BackgroundImage or "rbxassetid://74613200492285"
    local BackgroundImageTransparency = config.BackgroundImageTransparency or 0.88
    local Watermark = config.Watermark or "rbxassetid://74613200492285"
    local WatermarkTransparency = config.WatermarkTransparency or 0.94
    local WatermarkSize = config.WatermarkSize or 285

    if ConfigSystem.ThemeColors[Theme] then
        ConfigSystem.CurrentTheme = Theme
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Name = "LimboUI"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = Size
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = ScreenGui
    DropShadowHolder.Visible = false -- Orvion Gen 2 style: hidden until all tabs are built

    if Center then
        DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    end

    local UIScaleObj = Instance.new("UIScale")
    UIScaleObj.Scale = 1
    UIScaleObj.Parent = DropShadowHolder

    local AutoScale = config.AutoScale ~= false
    local CurrentCamera = workspace.CurrentCamera

    local function UpdateAutoScale()
        if not AutoScale then return end
        local camera = CurrentCamera or workspace.CurrentCamera
        if not camera then return end
        local ViewportSize = camera.ViewportSize
        local Margin = 20
        local WindowWidth = Size.X.Offset > 0 and Size.X.Offset or 560
        local WindowHeight = Size.Y.Offset > 0 and Size.Y.Offset or 340

        local AvailableWidth = ViewportSize.X - (Margin * 2)
        local AvailableHeight = ViewportSize.Y - (Margin * 2)

        local ScaleX = AvailableWidth / WindowWidth
        local ScaleY = AvailableHeight / WindowHeight

        local RequiredScale = math.min(ScaleX, ScaleY)
        -- Clamp batas aman untuk Split 6:
        -- Minimal 0.68x (font 13px -> ~9px, tetap tajam dan mudah dibaca)
        -- Maksimal 1.0x (tidak zoom in berlebihan di PC/layar besar)
        local FinalScale = math.clamp(RequiredScale, 0.68, 1.0)

        local current = UIScaleObj.Scale
        if math.abs(FinalScale - current) > 0.03 then
            TweenService:Create(UIScaleObj, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = FinalScale }):Play()
        end
    end

    if CurrentCamera then
        CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateAutoScale)
    end
    task.defer(UpdateAutoScale)

    -- Centered via AnchorPoint (0.5, 0.5)

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://8992230677"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.6
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(99, 99, 99, 99)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 100, 1, 100)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    local Main = Instance.new("ImageLabel")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Image = "rbxassetid://89641024074289"
    Main.ImageColor3 = Color3.fromHex("#0B0B0B")
    Main.ImageTransparency = 0
    Main.ScaleType = Enum.ScaleType.Slice
    Main.SliceCenter = Rect.new(460, 460, 460, 460)
    Main.SliceScale = 0.0258
    Main.BackgroundColor3 = Color3.fromHex("#0B0B0B")
    Main.BackgroundTransparency = 1
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -100, 1, -100)
    Main.Name = "Main"
    Main.Parent = DropShadow

    -- No UIStroke on Main squircle image to avoid rectangular black outer corners

    -- Background image (customizable, shown only on selected theme)
    local BgImageId    = config.BackgroundImage       or "rbxassetid://97957114633547"
    local BgImageTheme = config.BackgroundImage_Theme or "Darker"

    local ImageWrapper = Instance.new("Frame")
    ImageWrapper.Name = "ImageWrapper"
    ImageWrapper.Size = UDim2.new(1, 0, 1, 0)
    ImageWrapper.Position = UDim2.new(0, 0, 0, 0)
    ImageWrapper.BackgroundTransparency = 1
    ImageWrapper.ClipsDescendants = true
    ImageWrapper.ZIndex = 1
    ImageWrapper.Parent = Main

    local ImageWrapperCorner = Instance.new("UICorner")
    ImageWrapperCorner.CornerRadius = UDim.new(0, 8)
    ImageWrapperCorner.Parent = ImageWrapper

    -- Background Image (Window-wide)
    local fullBg = config.BackgroundImage or config.Background
    if fullBg and typeof(fullBg) == "string" and fullBg ~= "" then
        local resolvedBg = ResolveIcon(fullBg)
        if resolvedBg then
            local FullBgLabel = Instance.new("ImageLabel")
            FullBgLabel.Name = "WindowBackground"
            FullBgLabel.Size = UDim2.new(1, 0, 1, 0)
            FullBgLabel.Position = UDim2.new(0, 0, 0, 0)
            FullBgLabel.BackgroundTransparency = 1
            FullBgLabel.Image = resolvedBg
            FullBgLabel.ImageTransparency = config.BackgroundImageTransparency or 0.85
            FullBgLabel.ScaleType = Enum.ScaleType.Crop
            FullBgLabel.ZIndex = 1
            FullBgLabel.Parent = ImageWrapper
        end
    end

    -- Resolve Watermark
    local WatermarkAsset = nil
    if typeof(Watermark) == "string" and Watermark ~= "" then
        if Watermark:match("^rbxasset") then
            WatermarkAsset = Watermark
        elseif Watermark:match("^https?://") then
            pcall(function()
                local assetPath = "LimboHUB/assets/.limbo_watermark.png"
                if makefolder and isfolder and not isfolder("LimboHUB") then makefolder("LimboHUB") end
                if makefolder and isfolder and not isfolder("LimboHUB/assets") then makefolder("LimboHUB/assets") end
                if isfile and not isfile(assetPath) then
                    local reqFn = (syn and syn.request) or (http and http.request) or request or http_request
                    local body = (game.HttpGet and game:HttpGet(Watermark)) or (reqFn and reqFn({Url = Watermark, Method = "GET"}).Body)
                    if body and writefile then writefile(assetPath, body) end
                end
                if getcustomasset and isfile and isfile(assetPath) then
                    WatermarkAsset = getcustomasset(assetPath)
                end
            end)
        end
    end



    local Top = Instance.new("Frame")
    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.999
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 42)
    Top.Name = "Top"
    Top.Parent = Main

    local DecideFrame = Instance.new("Frame")
    DecideFrame.Name = "HeaderSeparator"
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.Position = UDim2.new(0, 10, 0, 42)
    DecideFrame.Size = UDim2.new(1, -20, 0, 1)
    DecideFrame.BorderSizePixel = 0
    DecideFrame.ZIndex = 2
    DecideFrame.Parent = Main

    local SepCorner = Instance.new("UICorner")
    SepCorner.CornerRadius = UDim.new(1, 0)
    SepCorner.Parent = DecideFrame

    local SepGradient = Instance.new("UIGradient")
    SepGradient.Rotation = 0
    SepGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#2E2E2E")),
        ColorSequenceKeypoint.new(0.28, Color3.fromHex("#4A4A4A")),
        ColorSequenceKeypoint.new(0.55, Color3.fromHex("#5E5E5E")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#3A3A3A")),
    })
    SepGradient.Parent = DecideFrame

    -- Vertical divider between Sidebar tabs and Content panel (PaneSeparator)
    local PaneSeparator = Instance.new("Frame")
    PaneSeparator.Name = "PaneSeparator"
    PaneSeparator.Size = UDim2.new(0, 1, 1, -54)
    PaneSeparator.Position = UDim2.new(0, 134, 0, 48)
    PaneSeparator.BackgroundColor3 = Color3.fromHex("#242424")
    PaneSeparator.BackgroundTransparency = 0.45
    PaneSeparator.BorderSizePixel = 0
    PaneSeparator.ZIndex = 2
    PaneSeparator.Parent = Main

    local PaneSepGradient = Instance.new("UIGradient")
    PaneSepGradient.Rotation = 90
    PaneSepGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.14, 0.25),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(0.86, 0.25),
        NumberSequenceKeypoint.new(1, 1)
    })
    PaneSepGradient.Parent = PaneSeparator

    local function createBadge(text, name)
        local Badge = Instance.new("Frame")
        Badge.Name = name or "Badge"
        Badge.AutomaticSize = Enum.AutomaticSize.XY
        Badge.BackgroundColor3 = Color3.fromHex("#2A2A2A")
        Badge.BorderSizePixel = 0

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(1, 0)
        bCorner.Parent = Badge

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Color3.fromHex("#5A5A5A")
        bStroke.Thickness = 1
        bStroke.Transparency = 0.45
        bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bStroke.Parent = Badge

        local bPad = Instance.new("UIPadding")
        bPad.PaddingTop = UDim.new(0, 2)
        bPad.PaddingBottom = UDim.new(0, 2)
        bPad.PaddingLeft = UDim.new(0, 7)
        bPad.PaddingRight = UDim.new(0, 7)
        bPad.Parent = Badge

        local bLabel = Instance.new("TextLabel")
        bLabel.Font = Enum.Font.GothamBold
        bLabel.Text = text
        bLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
        bLabel.TextSize = 11
        bLabel.TextTransparency = 0.12
        bLabel.BackgroundTransparency = 1
        bLabel.BorderSizePixel = 0
        bLabel.AutomaticSize = Enum.AutomaticSize.XY
        bLabel.Parent = Badge

        return Badge
    end

    local TitleWrapper = Instance.new("Frame")
    TitleWrapper.BackgroundTransparency = 1
    TitleWrapper.AutomaticSize = Enum.AutomaticSize.X
    TitleWrapper.Size = UDim2.new(0, 0, 1, 0)
    TitleWrapper.Position = UDim2.new(0, 8, 0, 0)
    TitleWrapper.Parent = Top

    local TitleWrapLayout = Instance.new("UIListLayout")
    TitleWrapLayout.FillDirection = Enum.FillDirection.Horizontal
    TitleWrapLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TitleWrapLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TitleWrapLayout.Padding = UDim.new(0, 8)
    TitleWrapLayout.Parent = TitleWrapper

    -- Icon (20x20)
    if Icon and Icon ~= "" then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Image = Icon
        IconImg.BackgroundTransparency = 1
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.LayoutOrder = 0
        IconImg.Parent = TitleWrapper
    end

    local TitleColumn = Instance.new("Frame")
    TitleColumn.BackgroundTransparency = 1
    TitleColumn.AutomaticSize = Enum.AutomaticSize.XY
    TitleColumn.LayoutOrder = 1
    TitleColumn.Parent = TitleWrapper

    local TitleColLayout = Instance.new("UIListLayout")
    TitleColLayout.FillDirection = Enum.FillDirection.Vertical
    TitleColLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TitleColLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TitleColLayout.Padding = UDim.new(0, 1)
    TitleColLayout.Parent = TitleColumn

    local Row1 = Instance.new("Frame")
    Row1.BackgroundTransparency = 1
    Row1.AutomaticSize = Enum.AutomaticSize.XY
    Row1.LayoutOrder = 1
    Row1.Parent = TitleColumn

    local Row1Layout = Instance.new("UIListLayout")
    Row1Layout.FillDirection = Enum.FillDirection.Horizontal
    Row1Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Row1Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Row1Layout.Padding = UDim.new(0, 6)
    Row1Layout.Parent = Row1

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.AutomaticSize = Enum.AutomaticSize.XY
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.BorderSizePixel = 0
    TitleLabel.LayoutOrder = 1
    TitleLabel.Parent = Row1

    if Version and Version ~= "" then
        local vBadge = createBadge(Version, "VersionBadge")
        vBadge.LayoutOrder = 2
        vBadge.Parent = Row1
    end

    if ShowExecutor then
        local execName = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Executor"
        local eBadge = createBadge(execName, "ExecutorBadge")
        eBadge.LayoutOrder = 3
        eBadge.Parent = Row1
    end

    local Subtitle = config.Subtitle or ""
    if Subtitle ~= "" then
        local SubtitleLabel = Instance.new("TextLabel")
        SubtitleLabel.Font = Enum.Font.Gotham
        SubtitleLabel.Text = Subtitle
        SubtitleLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
        SubtitleLabel.TextSize = 11
        SubtitleLabel.TextTransparency = 0.35
        SubtitleLabel.AutomaticSize = Enum.AutomaticSize.XY
        SubtitleLabel.BackgroundTransparency = 1
        SubtitleLabel.BorderSizePixel = 0
        SubtitleLabel.LayoutOrder = 2
        SubtitleLabel.Parent = TitleColumn
    end

    local BadgeContainer = Instance.new("Frame")
    BadgeContainer.Name = "BadgeContainer"
    BadgeContainer.AnchorPoint = Vector2.new(1, 0.5)
    BadgeContainer.BackgroundTransparency = 1
    BadgeContainer.Size = UDim2.new(0, 160, 1, 0)
    BadgeContainer.Position = UDim2.new(1, -77, 0.5, 0)
    BadgeContainer.Parent = Top

    local BadgeLayout = Instance.new("UIListLayout")
    BadgeLayout.FillDirection = Enum.FillDirection.Horizontal
    BadgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    BadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BadgeLayout.Padding = UDim.new(0, 6)
    BadgeLayout.Parent = BadgeContainer

    for _, badgeText in ipairs(Badges) do
        local Badge = Instance.new("TextLabel")
        Badge.Name = "Badge"
        Badge.Font = Enum.Font.GothamBold
        Badge.Text = badgeText
        Badge.TextColor3 = Color3.fromRGB(255, 255, 255)
        Badge.TextSize = 14
        Badge.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        Badge.BackgroundTransparency = 0.3
        Badge.BorderSizePixel = 0
        Badge.Size =
            UDim2.new(
            0,
            TextService:GetTextSize(badgeText, 14, Enum.Font.GothamBold, Vector2.new(999, 999)).X + 18,
            0,
            24
        )

        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(1, 0)
        BadgeCorner.Parent = Badge

        Badge.Parent = BadgeContainer

        table.insert(
            ConfigSystem.ThemeElements,
            {
                Update = function(color)
                    Badge.BackgroundColor3 = color
                end
            }
        )
    end

    local Close = Instance.new("TextButton")
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Close.BackgroundTransparency = 0.999
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = "rbxassetid://110786993356448"
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseIcon.BackgroundTransparency = 0.999
    CloseIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseIcon.BorderSizePixel = 0
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(1, -8, 1, -8)
    CloseIcon.Parent = Close

    local Min = Instance.new("TextButton")
    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Min.BackgroundTransparency = 0.999
    Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -42, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Image = "rbxassetid://118026365011536"
    MinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinIcon.BackgroundTransparency = 0.999
    MinIcon.ImageTransparency = 0.2
    MinIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MinIcon.BorderSizePixel = 0
    MinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinIcon.Size = UDim2.new(1, -9, 1, -9)
    MinIcon.Parent = Min



    local ResizeHandle = nil
    if Resizable then
        ResizeHandle = Instance.new("TextButton")
        ResizeHandle.Name = "ResizeHandle"
        ResizeHandle.Text = ""
        ResizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ResizeHandle.BackgroundTransparency = 1
        ResizeHandle.BorderSizePixel = 0
        ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
        ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
        ResizeHandle.AutoButtonColor = false
        ResizeHandle.Parent = Main

        local ResizeCorner = Instance.new("UICorner")
        ResizeCorner.CornerRadius = UDim.new(0, 3)
        ResizeCorner.Parent = ResizeHandle

        local ResizeIcon = Instance.new("ImageLabel")
        ResizeIcon.Name = "ResizeIcon"
        ResizeIcon.Image = "rbxassetid://116269596042539"
        ResizeIcon.BackgroundTransparency = 1
        ResizeIcon.AnchorPoint = Vector2.new(1, 1)
        ResizeIcon.Size = UDim2.new(0, 10, 0, 10)
        ResizeIcon.Position = UDim2.new(1, 0, 1, 0)
        ResizeIcon.Parent = ResizeHandle

        MakeResizable(
            ResizeHandle,
            DropShadowHolder,
            Vector2.new(250, 150),
            Vector2.new(1200, 900),
            function(newSize)
                Main.Size = UDim2.new(1, -47, 1, -47)
            end
        )
    end

    local TabFrame = Instance.new("Frame")
    TabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabFrame.BackgroundTransparency = 0.999
    TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabFrame.BorderSizePixel = 0
    TabFrame.Position = UDim2.new(0, 9, 0, 43)
    TabFrame.Size = UDim2.new(0, 120, 1, -43)
    TabFrame.Name = "TabFrame"
    TabFrame.Parent = Main

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 2)
    TabCorner.Parent = TabFrame

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    TabScroll.ScrollBarThickness = 0
    TabScroll.Active = true
    TabScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabScroll.BackgroundTransparency = 0.999
    TabScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabScroll.BorderSizePixel = 0
    TabScroll.Position = UDim2.new(0, 0, 0, 36)
    TabScroll.Size = UDim2.new(1, 0, 1, -86)
    TabScroll.Name = "TabScroll"
    TabScroll.Parent = TabFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabScroll

    local TabTopPadding = Instance.new("UIPadding")
    TabTopPadding.PaddingTop = UDim.new(0, 4)
    TabTopPadding.Parent = TabScroll



    -- Player footer
    local PlayerFooter = Instance.new("Frame")
    PlayerFooter.Name = "PlayerFooter"
    PlayerFooter.BackgroundTransparency = 1
    PlayerFooter.Position = UDim2.new(0, 0, 1, -46)
    PlayerFooter.Size = UDim2.new(1, 0, 0, 42)
    PlayerFooter.BorderSizePixel = 0
    PlayerFooter.Parent = TabFrame

    local AvatarContainer = Instance.new("Frame")
    AvatarContainer.BackgroundTransparency = 1
    AvatarContainer.Position = UDim2.new(0, 5, 0.5, 0)
    AvatarContainer.AnchorPoint = Vector2.new(0, 0.5)
    AvatarContainer.Size = UDim2.new(0, 32, 0, 32)
    AvatarContainer.BorderSizePixel = 0
    AvatarContainer.Parent = PlayerFooter

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.Image = "rbxassetid://0"
    AvatarImg.Parent = AvatarContainer

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImg

    local AvatarStroke = Instance.new("UIStroke")
    AvatarStroke.Color = Color3.fromRGB(120, 120, 135)
    AvatarStroke.Thickness = 1.5
    AvatarStroke.Transparency = 0.2
    AvatarStroke.Parent = AvatarImg

    pcall(function()
        local lp = Players.LocalPlayer
        local content, isReady = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then AvatarImg.Image = content end
    end)

    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Name = "WelcomeLabel"
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 43, 0.5, -8)
    WelcomeLabel.AnchorPoint = Vector2.new(0, 0)
    WelcomeLabel.Size = UDim2.new(1, -47, 0, 13)
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
    WelcomeLabel.TextSize = 11
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeLabel.TextWrapped = false
    WelcomeLabel.Text = "Welcome,"
    WelcomeLabel.Visible = false
    WelcomeLabel.Parent = PlayerFooter

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Position = UDim2.new(0, 43, 0.5, 0)
    UsernameLabel.AnchorPoint = Vector2.new(0, 0.5)
    UsernameLabel.Size = UDim2.new(1, -47, 0, 13)
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
    UsernameLabel.TextSize = 11
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextWrapped = false
    UsernameLabel.Text = "usr***"
    UsernameLabel.Parent = PlayerFooter

    local maskedName = "usr***"
    pcall(function()
        local rawName = tostring(Players.LocalPlayer.Name)
        maskedName = string.sub(rawName, 1, 3) .. "***"
        UsernameLabel.Text = maskedName
    end)

    -- Dynamic footer: 1 line when small, 2 lines when large
    local function UpdateFooterLayout()
        local h = Main.AbsoluteSize.Y
        if h > 300 then
            -- 2 labels
            WelcomeLabel.Visible = true
            WelcomeLabel.Position = UDim2.new(0, 43, 0.5, -8)
            UsernameLabel.Position = UDim2.new(0, 43, 0.5, 3)
            UsernameLabel.AnchorPoint = Vector2.new(0, 0)
            UsernameLabel.Text = maskedName
        else
            -- 1 label: "Welcome, usr***"
            WelcomeLabel.Visible = false
            UsernameLabel.Position = UDim2.new(0, 43, 0.5, 0)
            UsernameLabel.AnchorPoint = Vector2.new(0, 0.5)
            UsernameLabel.Text = "Welcome, " .. maskedName
        end
    end

    Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateFooterLayout)
    task.defer(UpdateFooterLayout)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentFrame.BackgroundTransparency = 0.999
    ContentFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 138, 0, 43)
    ContentFrame.Size = UDim2.new(1, -147, 1, -43)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = Main
    if WatermarkAsset then
        local WMLabel = Instance.new("ImageLabel")
        WMLabel.Name = "Watermark"
        WMLabel.Size = UDim2.fromOffset(WatermarkSize, math.floor(WatermarkSize * 496 / 512 + 0.5))
        WMLabel.Position = UDim2.new(0.5, 0, 1, 0)
        WMLabel.AnchorPoint = Vector2.new(0.5, 1)
        WMLabel.BackgroundTransparency = 1
        WMLabel.Image = WatermarkAsset
        WMLabel.ImageTransparency = (WatermarkTransparency and WatermarkTransparency < 0.94) and WatermarkTransparency or 0.88
        WMLabel.ScaleType = Enum.ScaleType.Fit
        WMLabel.ZIndex = 1
        WMLabel.Parent = ContentFrame
    end

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 2)
    ContentCorner.Parent = ContentFrame

    if WatermarkAsset then
        local WMLabel = Instance.new("ImageLabel")
        WMLabel.Name = "Watermark"
        WMLabel.Size = UDim2.fromOffset(WatermarkSize, math.floor(WatermarkSize * 496 / 512 + 0.5))
        WMLabel.Position = UDim2.new(0.5, 0, 1, 0)
        WMLabel.AnchorPoint = Vector2.new(0.5, 1)
        WMLabel.BackgroundTransparency = 1
        WMLabel.Image = WatermarkAsset
        WMLabel.ImageTransparency = WatermarkTransparency or 0.94
        WMLabel.ScaleType = Enum.ScaleType.Fit
        WMLabel.ZIndex = 0
        WMLabel.Parent = ContentFrame
    end

    ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ContentScroll.ScrollBarThickness = 0
    ContentScroll.Active = true
    ContentScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentScroll.BackgroundTransparency = 0.999
    ContentScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ClipsDescendants = true
    ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.Position = UDim2.new(0, 8, 0, 6)
    ContentScroll.Size = UDim2.new(1, -16, 1, -12)
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Parent = ContentFrame



    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentScroll

    TabContents = {}
    local CurrentTab = nil
    local TabCount = 0
    local AllElements = {}
    TabSwitchFns = {}

    local function UpdateTabSize()
        local OffsetY = 0
        for _, child in TabScroll:GetChildren() do
            if child:IsA("Frame") then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end

    local function UpdateContentSize()
        if CurrentTab and TabContents[CurrentTab] then
            local OffsetY = 0
            for _, child in TabContents[CurrentTab]:GetChildren() do
                if child:IsA("Frame") then
                    OffsetY = OffsetY + 8 + child.Size.Y.Offset
                end
            end
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY + 60)
        end
    end

    TabScroll.ChildAdded:Connect(UpdateTabSize)
    TabScroll.ChildRemoved:Connect(UpdateTabSize)

    setupCloseModal(Close, Main, ScreenGui)

    Min.Activated:Connect(
        function()
            CircleClick(Min, Mouse.X, Mouse.Y)
            DropShadowHolder.Visible = false
        end
    )

    UserInputService.InputBegan:Connect(
        function(input)
            if input.KeyCode == MinimizeKey then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end
    )

    if Draggable then
        MakeDraggable(Top, DropShadowHolder)
    end

    local ToggleBtn = nil
    local enableToggleBtn = (config.ToggleButton ~= false) or (config.MinimizeButton == true)

    if enableToggleBtn then
        ToggleBtn = Instance.new("Frame")
        ToggleBtn.Name = "LimboToggleButton"
        ToggleBtn.BackgroundColor3 = Color3.fromHex("#141414")
        ToggleBtn.BackgroundTransparency = 0
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Size = UDim2.fromOffset(44, 44)
        ToggleBtn.Position = UDim2.new(0.015, 0, 0.1, 0)
        ToggleBtn.ZIndex = 10000
        ToggleBtn.Parent = ScreenGui

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 11)
        ButtonCorner.Parent = ToggleBtn

        local activeThemeColor = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme] or Color3.fromRGB(150, 150, 170)

        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Thickness = 1
        ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ButtonStroke.Color = activeThemeColor
        ButtonStroke.Transparency = 0.15
        ButtonStroke.Parent = ToggleBtn

        local ButtonGradient = Instance.new("UIGradient")
        ButtonGradient.Color = ColorSequence.new(activeThemeColor, activeThemeColor)
        ButtonGradient.Parent = ButtonStroke

        table.insert(ConfigSystem.ThemeElements, {
            Update = function(newColor)
                ButtonStroke.Color = newColor
                ButtonGradient.Color = ColorSequence.new(newColor, newColor)
            end
        })

        local ButtonImage = Instance.new("ImageLabel")
        ButtonImage.Name = "ButtonImage"
        ButtonImage.Image = "rbxassetid://97957114633547"
        ButtonImage.BackgroundTransparency = 1
        ButtonImage.Size = UDim2.fromOffset(30, 30)
        ButtonImage.AnchorPoint = Vector2.new(0.5, 0.5)
        ButtonImage.Position = UDim2.fromScale(0.5, 0.5)
        ButtonImage.ScaleType = Enum.ScaleType.Fit
        ButtonImage.ZIndex = 10001
        ButtonImage.Active = false
        ButtonImage.Parent = ToggleBtn

        local TBSurface = Instance.new("Frame", ToggleBtn)
        TBSurface.Name = "TBSurface"
        TBSurface.BackgroundTransparency = 1
        TBSurface.Size = UDim2.new(1, 0, 1, 0)
        TBSurface.ZIndex = 10002
        TBSurface.Active = true

        local dragging, dragged, dragStart, startPos = false, false, nil, nil
        local clickStartPos = nil

        TBSurface.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragged = false
                dragStart = input.Position
                clickStartPos = input.Position
                startPos = ToggleBtn.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local delta = input.Position - dragStart
            if not dragged and clickStartPos and (input.Position - clickStartPos).Magnitude > 6 then
                dragged = true
            end
            if not dragged then return end
            local ss = ScreenGui.AbsoluteSize
            local bs = ToggleBtn.AbsoluteSize
            local pad = 10
            ToggleBtn.Position = UDim2.new(0,
                math.clamp(startPos.X.Offset + delta.X, pad, ss.X - bs.X - pad),
                0,
                math.clamp(startPos.Y.Offset + delta.Y, pad, ss.Y - bs.Y - pad))
        end)

        local lastClick = 0
        TBSurface.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if dragging and not dragged then
                    local now = workspace.DistributedGameTime
                    if now - lastClick >= 0.2 then
                        lastClick = now
                        DropShadowHolder.Visible = not DropShadowHolder.Visible
                    end
                end
                dragging = false
                dragged = false
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- Element Creation Functions
    local function CreateSingleButton(tabContainer, title, callback)
        if not tabContainer or not tabContainer:IsA("Frame") then return end

        local BtnFrame = Instance.new("Frame")
        BtnFrame.BackgroundColor3 = Color3.fromHex("#1C1C1C")
        BtnFrame.BackgroundTransparency = 0
        BtnFrame.BorderSizePixel = 0
        BtnFrame.Size = UDim2.new(1, 0, 0, 36)
        BtnFrame.Name = "SingleButton"
        BtnFrame.Parent = tabContainer

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = BtnFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromHex("#2E2E2E")
        Stroke.Thickness = 1
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Parent = BtnFrame

        local TextBtn = Instance.new("TextButton")
        TextBtn.Font = Enum.Font.GothamBold
        TextBtn.Text = title or "Button"
        TextBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
        TextBtn.TextSize = 13
        TextBtn.TextXAlignment = Enum.TextXAlignment.Center
        TextBtn.TextYAlignment = Enum.TextYAlignment.Center
        TextBtn.BackgroundTransparency = 1
        TextBtn.Size = UDim2.new(1, 0, 1, 0)
        TextBtn.Parent = BtnFrame

        TextBtn.MouseEnter:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromHex("#262626")}):Play()
        end)
        TextBtn.MouseLeave:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromHex("#1C1C1C")}):Play()
        end)

        TextBtn.MouseButton1Down:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.06), {Size = UDim2.new(1, -4, 0, 34)}):Play()
        end)
        TextBtn.MouseButton1Up:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 36)}):Play()
        end)

        TextBtn.Activated:Connect(function()
            CircleClick(TextBtn, Mouse.X, Mouse.Y)
            if callback then callback() end
        end)

        UpdateContentSize()
        return BtnFrame
    end

    local function CreateParagraph(tabContainer, titleOrConfig, content, buttons)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local title = ""
        local desc = ""
        local btnList = buttons

        if type(titleOrConfig) == "table" then
            title = titleOrConfig.Title or ""
            desc = titleOrConfig.Desc or titleOrConfig.Content or ""
            btnList = titleOrConfig.Buttons or btnList
        else
            title = tostring(titleOrConfig or "")
            desc = tostring(content or "")
        end

        local Paragraph = Instance.new("Frame")
        Paragraph.BackgroundColor3 = Color3.fromHex("#1C1C1C")
        Paragraph.BackgroundTransparency = 0
        Paragraph.BorderSizePixel = 0
        Paragraph.Size = UDim2.new(1, 0, 0, 50)
        Paragraph.Name = "Paragraph"
        Paragraph.Parent = tabContainer

        local ParagraphCorner = Instance.new("UICorner")
        ParagraphCorner.CornerRadius = UDim.new(0, 6)
        ParagraphCorner.Parent = Paragraph

        local ParagraphStroke = Instance.new("UIStroke")
        ParagraphStroke.Color = Color3.fromHex("#282828")
        ParagraphStroke.Thickness = 1
        ParagraphStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ParagraphStroke.Parent = Paragraph

        local Pad = Instance.new("UIPadding")
        Pad.PaddingLeft = UDim.new(0, 12)
        Pad.PaddingRight = UDim.new(0, 12)
        Pad.PaddingTop = UDim.new(0, 10)
        Pad.PaddingBottom = UDim.new(0, 10)
        Pad.Parent = Paragraph

        local VList = Instance.new("UIListLayout")
        VList.FillDirection = Enum.FillDirection.Vertical
        VList.Padding = UDim.new(0, 8)
        VList.SortOrder = Enum.SortOrder.LayoutOrder
        VList.Parent = Paragraph

        local ParagraphTitle = Instance.new("TextLabel")
        ParagraphTitle.Font = Enum.Font.GothamBold
        ParagraphTitle.Text = title
        ParagraphTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
        ParagraphTitle.TextSize = 14
        ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphTitle.BackgroundTransparency = 1
        ParagraphTitle.Size = UDim2.new(1, 0, 0, 16)
        ParagraphTitle.LayoutOrder = 1
        ParagraphTitle.Name = "ParagraphTitle"
        ParagraphTitle.Parent = Paragraph

        local ParagraphContent = Instance.new("TextLabel")
        ParagraphContent.Font = Enum.Font.GothamBold
        ParagraphContent.Text = desc
        ParagraphContent.TextColor3 = Color3.fromRGB(180, 180, 190)
        ParagraphContent.TextSize = 12
        ParagraphContent.TextTransparency = 0.2
        ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
        ParagraphContent.BackgroundTransparency = 1
        ParagraphContent.Size = UDim2.new(1, 0, 0, 0)
        ParagraphContent.AutomaticSize = Enum.AutomaticSize.Y
        ParagraphContent.TextWrapped = true
        ParagraphContent.LayoutOrder = 2
        ParagraphContent.Name = "ParagraphContent"
        ParagraphContent.Parent = Paragraph

        if btnList and type(btnList) == "table" and #btnList > 0 then
            for idx, btnData in ipairs(btnList) do
                local btnH = btnData.Height or 26 -- Sleek slim 26px height (Ale standard)
                local isFull = btnData.FullWidth ~= false

                local ActionBtn = Instance.new("Frame")
                ActionBtn.BackgroundColor3 = Color3.fromHex("#2A2A2A")
                ActionBtn.Size = isFull and UDim2.new(1, 0, 0, btnH) or UDim2.fromOffset(btnData.Width or 160, btnH)
                ActionBtn.BorderSizePixel = 0
                ActionBtn.LayoutOrder = 10 + idx
                ActionBtn.Name = "ActionBtn"
                ActionBtn.Parent = Paragraph

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, btnData.Radius or 5)
                btnCorner.Parent = ActionBtn

                local btnStroke = Instance.new("UIStroke")
                btnStroke.Color = Color3.fromHex("#383838")
                btnStroke.Thickness = 1
                btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                btnStroke.Parent = ActionBtn

                local TextBtn = Instance.new("TextButton")
                TextBtn.Font = Enum.Font.GothamBold
                TextBtn.Text = btnData.Title or "Button"
                TextBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
                TextBtn.TextSize = btnData.TextSize or 12
                TextBtn.TextXAlignment = Enum.TextXAlignment.Center
                TextBtn.TextYAlignment = Enum.TextYAlignment.Center
                TextBtn.BackgroundTransparency = 1
                TextBtn.Size = UDim2.new(1, 0, 1, 0)
                TextBtn.Parent = ActionBtn

                TextBtn.MouseEnter:Connect(function()
                    TweenService:Create(ActionBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromHex("#333333")}):Play()
                end)
                TextBtn.MouseLeave:Connect(function()
                    TweenService:Create(ActionBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromHex("#2A2A2A")}):Play()
                end)

                TextBtn.Activated:Connect(function()
                    CircleClick(TextBtn, Mouse.X, Mouse.Y)
                    if btnData.Callback then btnData.Callback() end
                end)
            end
        end

        Paragraph.AutomaticSize = Enum.AutomaticSize.Y
        UpdateContentSize()

        local paraFunc = {
            Instance = Paragraph,
            Title = ParagraphTitle,
            Content = ParagraphContent,
            Type = "Paragraph"
        }

        function paraFunc:SetTitle(newTitle)
            ParagraphTitle.Text = tostring(newTitle or "")
            UpdateContentSize()
        end

        function paraFunc:SetDesc(newDesc)
            ParagraphContent.Text = tostring(newDesc or "")
            UpdateContentSize()
        end

        function paraFunc:Set(newDescOrTitle, maybeDesc)
            if maybeDesc ~= nil then
                paraFunc:SetTitle(newDescOrTitle)
                paraFunc:SetDesc(maybeDesc)
            else
                paraFunc:SetDesc(newDescOrTitle)
            end
        end

        function paraFunc:Destroy()
            Paragraph:Destroy()
            UpdateContentSize()
        end

        return paraFunc
    end

    local function CreateButton(tabContainer, title, content, iconId, callback)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        title = tostring(title or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        content = tostring(content or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

        local Button = Instance.new("Frame")
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 46)
        Button.Name = "Button"
        Button.Parent = tabContainer

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = Button

        local ButtonTitle = Instance.new("TextLabel")
        ButtonTitle.Font = Enum.Font.GothamBold
        ButtonTitle.Text = title
        ButtonTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ButtonTitle.TextSize = 14
        ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
        ButtonTitle.TextYAlignment = Enum.TextYAlignment.Top
        ButtonTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonTitle.BackgroundTransparency = 0.999
        ButtonTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonTitle.BorderSizePixel = 0
        ButtonTitle.Position = UDim2.new(0, 10, 0, 10)
        ButtonTitle.Size = UDim2.new(1, -100, 0, 13)
        ButtonTitle.Name = "ButtonTitle"
        ButtonTitle.Parent = Button

        local ButtonContent = Instance.new("TextLabel")
        ButtonContent.Font = Enum.Font.GothamBold
        ButtonContent.Text = content
        ButtonContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonContent.TextSize = 13
        ButtonContent.TextTransparency = 0.6
        ButtonContent.TextXAlignment = Enum.TextXAlignment.Left
        ButtonContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ButtonContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonContent.BackgroundTransparency = 0.999
        ButtonContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonContent.BorderSizePixel = 0
        ButtonContent.Position = UDim2.new(0, 10, 0, 23)
        ButtonContent.Name = "ButtonContent"
        ButtonContent.Parent = Button

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        ButtonContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ButtonContent.TextWrapped = true
        Button.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ButtonButton = Instance.new("TextButton")
        ButtonButton.Font = Enum.Font.SourceSans
        ButtonButton.Text = ""
        ButtonButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.TextSize = 14
        ButtonButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.BackgroundTransparency = 0.999
        ButtonButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.BorderSizePixel = 0
        ButtonButton.Size = UDim2.new(1, 0, 1, 0)
        ButtonButton.Name = "ButtonButton"
        ButtonButton.Parent = Button

        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BackgroundTransparency = 0.999
        FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -17, 0.5, 0)
        FeatureFrame.Size = UDim2.new(0, 18, 0, 18)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Button

        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.Image = ResolveIcon(iconId) or "rbxassetid://16932740082"
        FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
        FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        FeatureImg.BackgroundTransparency = 0.999
        FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        FeatureImg.Size = UDim2.new(1, 0, 1, 0)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = FeatureFrame

        ButtonButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(ButtonButton, Mouse.X, Mouse.Y)
                if callback then
                    callback()
                end
            end
        )

        UpdateContentSize()

        return Button
    end

    local function CreateToggle(tabContainer, title, content, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        elementId = elementId or title

        local Toggle = Instance.new("Frame")
        Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.BackgroundTransparency = 0.935
        Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Toggle.BorderSizePixel = 0
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        Toggle.Name = "Toggle"
        Toggle.Parent = tabContainer

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = Toggle

        local ToggleTitle = Instance.new("TextLabel")
        ToggleTitle.Font = Enum.Font.GothamBold
        ToggleTitle.Text = title
        ToggleTitle.TextSize = 14
        ToggleTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
        ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
        ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleTitle.BackgroundTransparency = 0.999
        ToggleTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleTitle.BorderSizePixel = 0
        local hasContent = content and tostring(content) ~= ""
        ToggleTitle.Position = hasContent and UDim2.new(0, 10, 0, 6) or UDim2.new(0, 10, 0.5, -7)
        ToggleTitle.Size = UDim2.new(1, -60, 0, 14)
        ToggleTitle.Name = "ToggleTitle"
        ToggleTitle.Parent = Toggle

        local ToggleContent = nil
        local cardHeight = 38

        if hasContent then
            ToggleContent = Instance.new("TextLabel")
            ToggleContent.Font = Enum.Font.GothamBold
            ToggleContent.Text = content
            ToggleContent.TextColor3 = Color3.fromRGB(180, 180, 190)
            ToggleContent.TextSize = 11
            ToggleContent.TextTransparency = 0.35
            ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
            ToggleContent.TextYAlignment = Enum.TextYAlignment.Top
            ToggleContent.BackgroundTransparency = 1
            ToggleContent.BorderSizePixel = 0
            ToggleContent.Position = UDim2.new(0, 10, 0, 22)
            ToggleContent.Size = UDim2.new(1, -60, 0, 14)
            ToggleContent.TextTruncate = Enum.TextTruncate.AtEnd
            ToggleContent.Name = "ToggleContent"
            ToggleContent.Parent = Toggle
            cardHeight = 44
        end

        Toggle.Size = UDim2.new(1, 0, 0, cardHeight)

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.TextSize = 14
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.BackgroundTransparency = 0.999
        ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
        ToggleButton.Position = UDim2.new(1, -6, 0.5, 0)
        ToggleButton.Size = UDim2.fromOffset(48, 28)
        ToggleButton.ZIndex = 10
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = Toggle

        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundColor3 = Color3.fromHex("#232323")
        FeatureFrame.BackgroundTransparency = 0
        FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -10, 0.5, 0)
        FeatureFrame.Size = UDim2.fromOffset(40, 22)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Toggle

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(1, 0)
        FrameCorner.Parent = FeatureFrame

        local FrameStroke = Instance.new("UIStroke")
        FrameStroke.Color = Color3.fromHex("#2E2E2E")
        FrameStroke.Thickness = 1
        FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        FrameStroke.Parent = FeatureFrame

        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        ToggleCircle.BackgroundColor3 = defaultValue and Color3.fromHex("#0B0B0B") or Color3.fromHex("#808080")
        ToggleCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Position = defaultValue and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
        ToggleCircle.Size = UDim2.fromOffset(16, 16)
        ToggleCircle.Name = "ToggleCircle"
        ToggleCircle.Parent = FeatureFrame

        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = ToggleCircle

        table.insert(ConfigSystem.ToggleElements, Toggle)

        local state = defaultValue or false

        local function ApplyToggleVisual(value, animated)
            local themeColor = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme] or Color3.fromHex("#FF00E0")
            local titleProps
            local circleProps
            local frameProps

            if value then
                titleProps = {TextColor3 = Color3.fromRGB(245, 245, 245)}
                circleProps = {
                    Position = UDim2.new(1, -11, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                }
                frameProps = {
                    BackgroundColor3 = themeColor,
                    BackgroundTransparency = 0
                }
            else
                titleProps = {TextColor3 = Color3.fromRGB(200, 200, 200)}
                circleProps = {
                    Position = UDim2.new(0, 11, 0.5, 0),
                    BackgroundColor3 = Color3.fromHex("#808080")
                }
                frameProps = {
                    BackgroundColor3 = Color3.fromHex("#232323"),
                    BackgroundTransparency = 0
                }
            end

            if animated then
                local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(ToggleTitle, tweenInfo, titleProps):Play()
                TweenService:Create(ToggleCircle, tweenInfo, circleProps):Play()
                TweenService:Create(FeatureFrame, tweenInfo, frameProps):Play()
            else
                for property, value2 in pairs(titleProps) do
                    ToggleTitle[property] = value2
                end
                for property, value2 in pairs(circleProps) do
                    ToggleCircle[property] = value2
                end
                for property, value2 in pairs(frameProps) do
                    FeatureFrame[property] = value2
                end
            end
        end

        table.insert(ConfigSystem.ThemeElements, {
            Update = function(newColor)
                if state then
                    FeatureFrame.BackgroundColor3 = newColor
                end
            end
        })

        local function SetState(value, fireCallback)
            state = value == true
            ApplyToggleVisual(state, fireCallback ~= false)
            if fireCallback ~= false and callback then
                callback(state)
            end
        end

        SetState(state, false)

        ToggleButton.Activated:Connect(
            function()
                CircleClick(ToggleButton, Mouse.X, Mouse.Y)
                SetState(not state)
            end
        )

        UpdateContentSize()

        local toggleFunc = {
            Value = state,
            _live = function() return state end,
            Type = "Toggle",
            Id = elementId
        }

        function toggleFunc:Set(value)
            SetState(value == true, true)
        end

        if elementId then
            AllElements[elementId] = toggleFunc
            table.insert(Limbo._resetCallbacks, function() toggleFunc.Set(false) end)
        end

        return toggleFunc
    end

    local function CreateInput(tabContainer, title, content, placeholder, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        elementId = elementId or title

        local hasDesc = content and tostring(content) ~= ""
        local cleanDesc = hasDesc and tostring(content):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "") or ""

        local Input = Instance.new("Frame")
        Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Input.BackgroundTransparency = 0.935
        Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Input.BorderSizePixel = 0
        Input.Size = UDim2.new(1, 0, 0, (hasDesc and cleanDesc ~= "") and 76 or 54)
        Input.Name = "Input"
        Input.Parent = tabContainer

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 4)
        InputCorner.Parent = Input

        local InputTitle = Instance.new("TextLabel")
        InputTitle.Font = Enum.Font.GothamBold
        InputTitle.Text = title
        InputTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        InputTitle.TextSize = 13
        InputTitle.TextXAlignment = Enum.TextXAlignment.Left
        InputTitle.BackgroundTransparency = 1
        InputTitle.BorderSizePixel = 0
        InputTitle.Position = UDim2.new(0, 8, 0, 6)
        InputTitle.Size = UDim2.new(1, -16, 0, 14)
        InputTitle.Name = "InputTitle"
        InputTitle.Parent = Input

        local frameY = 24
        if hasDesc and cleanDesc ~= "" then
            local InputContent = Instance.new("TextLabel")
            InputContent.Font = Enum.Font.GothamBold
            InputContent.Text = cleanDesc
            InputContent.TextColor3 = Color3.fromRGB(180, 180, 190)
            InputContent.TextTransparency = 0.35
            InputContent.TextSize = 11
            InputContent.TextXAlignment = Enum.TextXAlignment.Left
            InputContent.TextYAlignment = Enum.TextYAlignment.Top
            InputContent.BackgroundTransparency = 1
            InputContent.BorderSizePixel = 0
            InputContent.Position = UDim2.new(0, 8, 0, 22)
            InputContent.Size = UDim2.new(1, -16, 0, 13)
            InputContent.TextTruncate = Enum.TextTruncate.AtEnd
            InputContent.Name = "InputContent"
            InputContent.Parent = Input
            frameY = 40
        end

        local InputFrame = Instance.new("Frame")
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.95
        InputFrame.BorderSizePixel = 0
        InputFrame.ClipsDescendants = true
        InputFrame.AnchorPoint = Vector2.new(0, 0)
        InputFrame.Position = UDim2.new(0, 8, 0, frameY)
        InputFrame.Size = UDim2.new(1, -16, 0, 28)
        InputFrame.Name = "InputFrame"
        InputFrame.Parent = Input

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = InputFrame

        local InputTextBox = Instance.new("TextBox")
        InputTextBox.ClearTextOnFocus = false
        InputTextBox.CursorPosition = -1
        InputTextBox.Font = Enum.Font.GothamBold
        InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputTextBox.PlaceholderText = placeholder or "Write your input there"
        InputTextBox.Text = ""
        InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.TextSize = 13
        InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
        InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
        InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.BackgroundTransparency = 0.999
        InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTextBox.BorderSizePixel = 0
        InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
        InputTextBox.Size = UDim2.new(1, -10, 1, -4)
        InputTextBox.Name = "InputTextBox"
        InputTextBox.Parent = InputFrame

        local inputFunc = {
            Value = "",
            Type = "Input",
            Id = elementId
        }

        function inputFunc:Set(value)
            InputTextBox.Text = value
            inputFunc.Value = value
            if callback then
                callback(value)
            end
        end

        InputTextBox.FocusLost:Connect(function()
            inputFunc:Set(InputTextBox.Text)
        end)

        UpdateContentSize()

        if elementId then
            AllElements[elementId] = inputFunc
        end

        return inputFunc
    end
    
    local function CreateDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        elementId = elementId or title
        local Dropdown = Instance.new("Frame")
        Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Dropdown.BackgroundTransparency = 0.935
        Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Dropdown.BorderSizePixel = 0
        Dropdown.Size = UDim2.new(1, 0, 0, 46)
        Dropdown.Name = "Dropdown"
        Dropdown.Parent = tabContainer

        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 4)
        DropdownCorner.Parent = Dropdown

        local hasDesc = content and tostring(content) ~= ""
        local cleanDesc = hasDesc and tostring(content):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "") or ""

        local DropdownTitle = Instance.new("TextLabel")
        DropdownTitle.Font = Enum.Font.GothamBold
        DropdownTitle.Text = title
        DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        DropdownTitle.TextSize = 13
        DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
        DropdownTitle.TextYAlignment = hasDesc and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
        DropdownTitle.BackgroundTransparency = 1
        DropdownTitle.BorderSizePixel = 0
        DropdownTitle.Position = hasDesc and UDim2.new(0, 10, 0, 6) or UDim2.new(0, 10, 0.5, -7)
        DropdownTitle.Size = UDim2.new(1, -165, 0, 14)
        DropdownTitle.Name = "DropdownTitle"
        DropdownTitle.Parent = Dropdown

        local DropdownContent = nil
        if hasDesc and cleanDesc ~= "" then
            DropdownContent = Instance.new("TextLabel")
            DropdownContent.Font = Enum.Font.GothamBold
            DropdownContent.Text = cleanDesc
            DropdownContent.TextColor3 = Color3.fromRGB(180, 180, 190)
            DropdownContent.TextSize = 11
            DropdownContent.TextTransparency = 0.35
            DropdownContent.TextTruncate = Enum.TextTruncate.AtEnd
            DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
            DropdownContent.TextYAlignment = Enum.TextYAlignment.Top
            DropdownContent.BackgroundTransparency = 1
            DropdownContent.BorderSizePixel = 0
            DropdownContent.Position = UDim2.new(0, 10, 0, 22)
            DropdownContent.Size = UDim2.new(1, -165, 0, 14)
            DropdownContent.Name = "DropdownContent"
            DropdownContent.Parent = Dropdown
        end

        Dropdown.Size = UDim2.new(1, 0, 0, hasDesc and 44 or 38)

        local SelectOptionsFrame = Instance.new("Frame")
        SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
        SelectOptionsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SelectOptionsFrame.BackgroundTransparency = 0.95
        SelectOptionsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SelectOptionsFrame.BorderSizePixel = 0
        SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
        SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
        SelectOptionsFrame.Name = "SelectOptionsFrame"
        SelectOptionsFrame.Parent = Dropdown

        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Font = Enum.Font.SourceSans
        DropdownButton.Text = ""
        DropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.TextSize = 14
        DropdownButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.BackgroundTransparency = 0.999
        DropdownButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Size = UDim2.new(1, 0, 1, 0)
        DropdownButton.Position = UDim2.new(0, 0, 0, 0)
        DropdownButton.ZIndex = 15
        DropdownButton.Name = "DropdownButton"
        DropdownButton.Parent = SelectOptionsFrame

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = SelectOptionsFrame

        local OptionSelecting = Instance.new("TextLabel")
        OptionSelecting.Font = Enum.Font.GothamBold
        OptionSelecting.Text = "Select Option"
        OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.TextSize = 13
        OptionSelecting.TextTransparency = 0.6
        OptionSelecting.TextWrapped = true
        OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
        OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
        OptionSelecting.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.BackgroundTransparency = 0.999
        OptionSelecting.BorderColor3 = Color3.fromRGB(0, 0, 0)
        OptionSelecting.BorderSizePixel = 0
        OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
        OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
        OptionSelecting.Name = "OptionSelecting"
        OptionSelecting.Parent = SelectOptionsFrame

        local OptionImg = Instance.new("ImageLabel")
        OptionImg.Image = "rbxassetid://16851841101"
        OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
        OptionImg.AnchorPoint = Vector2.new(1, 0.5)
        OptionImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptionImg.BackgroundTransparency = 0.999
        OptionImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        OptionImg.BorderSizePixel = 0
        OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
        OptionImg.Size = UDim2.new(0, 25, 0, 25)
        OptionImg.Name = "OptionImg"
        OptionImg.Parent = SelectOptionsFrame

        local DropdownList = Instance.new("Frame")
        DropdownList.AnchorPoint = Vector2.new(0, 0)
        DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DropdownList.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownList.BorderSizePixel = 0
        DropdownList.Position = UDim2.new(1, -12, 0, 35)
        DropdownList.Size = UDim2.new(0, 160, 0, 0)
        DropdownList.Name = "DropdownList"
        DropdownList.Visible = false
        DropdownList.ClipsDescendants = true
        DropdownList.ZIndex = 10
        DropdownList.Parent = Main

        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 2)
        ListCorner.Parent = DropdownList

        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = Color3.fromRGB(255, 255, 255)
        ListStroke.Thickness = 2.5
        ListStroke.Transparency = 0.8
        ListStroke.Parent = DropdownList

        local ListScroll = Instance.new("ScrollingFrame")
        ListScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        ListScroll.ScrollBarThickness = 0
        ListScroll.Active = true
        ListScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ListScroll.BackgroundTransparency = 0.999
        ListScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ListScroll.BorderSizePixel = 0
        ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        ListScroll.Size = UDim2.new(1, -10, 1, -50)
        ListScroll.Position = UDim2.new(0, 5, 0, 40)
        ListScroll.Name = "ListScroll"
        ListScroll.ZIndex = 52
        ListScroll.Parent = DropdownList

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 3)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = ListScroll

        -- ====== SEARCH INPUT ======
        local SearchFrame = Instance.new("Frame")
        SearchFrame.BackgroundTransparency = 1
        SearchFrame.BorderSizePixel = 0
        SearchFrame.Size = UDim2.new(1, 0, 0, 34)
        SearchFrame.Position = UDim2.new(0, 0, 0, 0)
        SearchFrame.ZIndex = 51
        SearchFrame.Name = "SearchFrame"
        SearchFrame.Parent = DropdownList

        local SearchInput = Instance.new("TextBox")
        SearchInput.Font = Enum.Font.Gotham
        SearchInput.PlaceholderText = "Search..."
        SearchInput.Text = ""
        SearchInput.TextSize = 12
        SearchInput.TextColor3 = Color3.fromRGB(230, 230, 230)
        SearchInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        SearchInput.TextXAlignment = Enum.TextXAlignment.Center
        SearchInput.BackgroundTransparency = 1
        SearchInput.BorderSizePixel = 0
        SearchInput.Size = UDim2.new(1, -16, 1, -8)
        SearchInput.Position = UDim2.new(0, 10, 0, 4)
        SearchInput.ZIndex = 13
        SearchInput.ClearTextOnFocus = false
        SearchInput.MultiLine = false
        SearchInput.Name = "SearchInput"
        SearchInput.Parent = SearchFrame

        local function ResetSearch()
            SearchInput.Text = ""
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    child.Visible = true
                end
            end
        end

        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local query = SearchInput.Text:lower()
            local totalH = 0
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    local optText = child:FindFirstChild("OptionText")
                    local match = query == "" or (optText and optText.Text:lower():find(query, 1, true) ~= nil)
                    child.Visible = match
                    if match then totalH = totalH + child.Size.Y.Offset + 3 end
                end
            end
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, totalH)
        end)

        table.insert(ConfigSystem.DropdownElements, Dropdown)

        local dropdownData = {
            Options = options or {},
            Value = multi and (defaultValue or {}) or defaultValue or nil,
            Multi = multi ~= false and multi ~= nil,
            MaxSelect = type(multi) == "number" and multi or math.huge,
            Open = false,
            OptionFrames = {}
        }

        local function UpdateListSize()
            local totalHeight = 0
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") then
                    totalHeight = totalHeight + child.Size.Y.Offset + 3
                end
            end
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
            DropdownList.Size = UDim2.new(0, 160, 0, math.min(150, totalHeight + 10))
        end

        local function UpdateSelectedDisplay()
            if dropdownData.Multi then
                if #dropdownData.Value > 0 then
                    local displayText = ""
                    for i, v in ipairs(dropdownData.Value) do
                        if i > 3 then
                            displayText = displayText .. ", ..."
                            break
                        end
                        displayText = displayText .. (i > 1 and ", " or "") .. v
                    end
                    OptionSelecting.Text = displayText
                else
                    OptionSelecting.Text = "Select Option"
                end
            else
                OptionSelecting.Text = dropdownData.Value or "Select Option"
            end
        end


        DropdownList.Parent = ContentFrame
        DropdownList.ZIndex = 50

        local csConn = nil
        local function ToggleDropdown()
            dropdownData.Open = not dropdownData.Open
            if dropdownData.Open then
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end

                DropdownList.Position = UDim2.new(0.46, 0, 0, 4)
                DropdownList.Size = UDim2.new(0.54, -6, 1, -8)
                DropdownList.ZIndex = 50
                DropdownList.Visible = true

                Limbo._activeDropdownClose = function()
                    if not dropdownData.Open then return end
                    dropdownData.Open = false
                    ResetSearch()
                    DropdownList.Visible = false
                    Limbo._activeDropdownClose = nil
                    if csConn then csConn:Disconnect(); csConn = nil end
                    local dOvr = ContentFrame:FindFirstChild("DropOverlay")
                    if dOvr then dOvr:Destroy() end
                end

                local overlay = Instance.new("TextButton")
                overlay.Name = "DropOverlay"
                overlay.BackgroundTransparency = 1
                overlay.BorderSizePixel = 0
                overlay.Size = UDim2.new(1, 0, 1, 0)
                overlay.ZIndex = 49
                overlay.Text = ""
                overlay.AutoButtonColor = false
                overlay.Parent = ContentFrame
                csConn = overlay.Activated:Connect(function()
                    if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                end)
            else
                if Limbo._activeDropdownClose then
                    Limbo._activeDropdownClose()
                end
            end
        end

        local function CreateOption(optionName)
            local Option = Instance.new("Frame")
            Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Option.BackgroundTransparency = 1
            Option.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Option.BorderSizePixel = 0
            Option.Size = UDim2.new(1, -6, 0, 28)
            Option.Position = UDim2.new(0, 3, 0, 0)
            Option.Name = "Option"
            Option.ZIndex = 53
            Option.Parent = ListScroll

            local OptionCorner = Instance.new("UICorner")
            OptionCorner.CornerRadius = UDim.new(0, 4)
            OptionCorner.Parent = Option

            local OptionButton = Instance.new("TextButton")
            OptionButton.Font = Enum.Font.GothamBold
            OptionButton.Text = ""
            OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.TextSize = 13
            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
            OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.BackgroundTransparency = 1
            OptionButton.BorderSizePixel = 0
            OptionButton.Size = UDim2.new(1, 0, 1, 0)
            OptionButton.Name = "OptionButton"
            OptionButton.ZIndex = 54
            OptionButton.Parent = Option

            local OptionText = Instance.new("TextLabel")
            OptionText.Font = Enum.Font.GothamBold
            OptionText.Text = optionName
            OptionText.TextSize = 12
            OptionText.TextColor3 = Color3.fromRGB(200, 200, 210)
            OptionText.TextXAlignment = Enum.TextXAlignment.Left
            OptionText.TextYAlignment = Enum.TextYAlignment.Center
            OptionText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptionText.BackgroundTransparency = 1
            OptionText.BorderSizePixel = 0
            OptionText.Position = UDim2.new(0, 10, 0, 0)
            OptionText.Size = UDim2.new(1, -20, 1, 0)
            OptionText.Name = "OptionText"
            OptionText.ZIndex = 55
            OptionText.Parent = Option

            local optionId = HttpService:GenerateGUID(false)
            ConfigSystem.DropdownOptionFrames[optionId] = {
                Frame = Option,
                IsSelected = false
            }

            local function UpdateOptionVisual()
                local isSelected = false
                if dropdownData.Multi then
                    isSelected = table.find(dropdownData.Value, optionName) ~= nil
                else
                    isSelected = dropdownData.Value == optionName
                end

                ConfigSystem.DropdownOptionFrames[optionId].IsSelected = isSelected

                if isSelected then
                    Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Option.BackgroundTransparency = 0.92
                    OptionText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    OptionText.Font = Enum.Font.GothamBold
                else
                    Option.BackgroundTransparency = 1
                    OptionText.TextColor3 = Color3.fromRGB(180, 180, 190)
                    OptionText.Font = Enum.Font.GothamBold
                end
            end

            OptionButton.Activated:Connect(
                function()
                    if dropdownData.Multi then
                        local index = table.find(dropdownData.Value, optionName)
                        if index then
                            table.remove(dropdownData.Value, index)
                        elseif #dropdownData.Value < dropdownData.MaxSelect then
                            table.insert(dropdownData.Value, optionName)
                        end
                        UpdateOptionVisual()
                    else
                        dropdownData.Value = optionName
                        for _, child in ListScroll:GetChildren() do
                            if child:IsA("Frame") and child.Name == "Option" then
                                local childOptionText = child:FindFirstChild("OptionText")
                                local isThis = childOptionText and childOptionText.Text == optionName
                                if isThis then
                                    child.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                    child.BackgroundTransparency = 0.92
                                    childOptionText.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    childOptionText.Font = Enum.Font.GothamBold
                                else
                                    child.BackgroundTransparency = 1
                                    if childOptionText then
                                        childOptionText.TextColor3 = Color3.fromRGB(180, 180, 190)
                                        childOptionText.Font = Enum.Font.GothamBold
                                    end
                                end
                            end
                        end
                    end

                    UpdateSelectedDisplay()

                    if callback then
                        callback(dropdownData.Value)
                    end
                end
            )

            UpdateOptionVisual()
            return Option
        end

        for _, option in ipairs(dropdownData.Options) do
            CreateOption(option)
        end

        UpdateListSize()
        UpdateSelectedDisplay()

        DropdownButton.Activated:Connect(
            function()
                CircleClick(DropdownButton, Mouse.X, Mouse.Y)
                ToggleDropdown()
            end
        )

        Dropdown.Destroying:Connect(
            function()
                for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                    if data.Frame and data.Frame:IsDescendantOf(DropdownList) then
                        ConfigSystem.DropdownOptionFrames[id] = nil
                    end
                end
                DropdownList:Destroy()
            end
        )

        UpdateContentSize()

        local dropdownFunc = {
            Value = dropdownData.Value,
            _data = dropdownData,
            Options = dropdownData.Options,
            Type = "Dropdown",
            Id = elementId
        }

        function dropdownFunc:Set(value)
            if dropdownData.Multi then
                dropdownData.Value = value or {}
            else
                dropdownData.Value = value
            end
            UpdateSelectedDisplay()

            for _, child in ipairs(ListScroll:GetChildren()) do
                if child:IsA("Frame") and child.Name == "Option" then
                    local childOptionText = child:FindFirstChild("OptionText")
                    local optionName = childOptionText and childOptionText.Text
                    local isSelected = false
                    if dropdownData.Multi then
                        isSelected = table.find(dropdownData.Value, optionName) ~= nil
                    else
                        isSelected = dropdownData.Value == optionName
                    end

                    if isSelected then
                        child.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        child.BackgroundTransparency = 0.92
                        if childOptionText then
                            childOptionText.TextColor3 = Color3.fromRGB(255, 255, 255)
                            childOptionText.Font = Enum.Font.GothamBold
                        end
                    else
                        child.BackgroundTransparency = 1
                        if childOptionText then
                            childOptionText.TextColor3 = Color3.fromRGB(180, 180, 190)
                            childOptionText.Font = Enum.Font.GothamBold
                        end
                    end
                end
            end
            if callback then pcall(callback, dropdownData.Value) end
        end

        function dropdownFunc:Select(value)
            return dropdownFunc:Set(value)
        end

        function dropdownFunc:Refresh(newOptions, newValue)
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                if data.Frame and data.Frame:IsDescendantOf(ListScroll) then
                    ConfigSystem.DropdownOptionFrames[id] = nil
                end
            end

            dropdownData.Options = newOptions or {}
            dropdownData.Value = newValue or (dropdownData.Multi and {} or nil)

            for _, option in ipairs(dropdownData.Options) do
                CreateOption(option)
            end

            UpdateListSize()
            UpdateSelectedDisplay()
            dropdownFunc.Value = dropdownData.Value
            dropdownFunc.Options = dropdownData.Options
        end

        if elementId then
            AllElements[elementId] = dropdownFunc
        end

        return dropdownFunc
    end
    
    local function CreateSlider(
        tabContainer,
        title,
        content,
        minValue,
        maxValue,
        defaultValue,
        callback,
        elementId,
        showKnob)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        elementId = elementId or title
        showKnob = showKnob ~= false

        local Slider = Instance.new("Frame")
        Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Slider.BackgroundTransparency = 0.935
        Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Slider.BorderSizePixel = 0
        Slider.Size = UDim2.new(1, 0, 0, 46)
        Slider.Name = "Slider"
        Slider.Parent = tabContainer

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 4)
        SliderCorner.Parent = Slider

        local SliderTitle = Instance.new("TextLabel")
        SliderTitle.Font = Enum.Font.GothamBold
        SliderTitle.Text = title
        SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        SliderTitle.TextSize = 14
        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
        SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
        SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.BackgroundTransparency = 0.999
        SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderTitle.BorderSizePixel = 0
        SliderTitle.Position = UDim2.new(0, 10, 0, 10)
        SliderTitle.Size = UDim2.new(1, -60, 0, 13)
        SliderTitle.Name = "SliderTitle"
        SliderTitle.Parent = Slider

        local SliderContent = Instance.new("TextLabel")
        SliderContent.Font = Enum.Font.GothamBold
        SliderContent.Text = content
        SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.TextSize = 13
        SliderContent.TextTransparency = 0.6
        SliderContent.TextXAlignment = Enum.TextXAlignment.Left
        SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
        SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.BackgroundTransparency = 0.999
        SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderContent.BorderSizePixel = 0
        SliderContent.Position = UDim2.new(0, 10, 0, 23)
        SliderContent.Size = UDim2.new(1, -60, 0, 12)
        SliderContent.Name = "SliderContent"
        SliderContent.Parent = Slider

        local hasDesc = content and tostring(content) ~= ""
        SliderTitle.Position = hasDesc and UDim2.new(0, 10, 0, 6) or UDim2.new(0, 10, 0, 8)
        SliderTitle.Size = UDim2.new(1, -60, 0, 14)

        if hasDesc then
            SliderContent.Position = UDim2.new(0, 10, 0, 20)
            SliderContent.Size = UDim2.new(1, -60, 0, 12)
            SliderContent.TextSize = 11
            SliderContent.TextTruncate = Enum.TextTruncate.AtEnd
            SliderContent.Visible = true
        else
            SliderContent.Visible = false
        end

        local trackY = hasDesc and 36 or 28
        local cardH = hasDesc and 48 or 40

        local ValueDisplay = Instance.new("TextLabel")
        ValueDisplay.Font = Enum.Font.GothamBold
        ValueDisplay.Text = tostring(defaultValue or minValue)
        ValueDisplay.TextColor3 = Color3.fromRGB(240, 240, 240)
        ValueDisplay.TextSize = 12
        ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        ValueDisplay.AnchorPoint = Vector2.new(1, 0)
        ValueDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ValueDisplay.BackgroundTransparency = 0.999
        ValueDisplay.BorderSizePixel = 0
        ValueDisplay.Position = UDim2.new(1, -10, 0, 6)
        ValueDisplay.Size = UDim2.new(0, 45, 0, 14)
        ValueDisplay.Name = "ValueDisplay"
        ValueDisplay.Parent = Slider

        Slider.Size = UDim2.new(1, 0, 0, cardH)

        local SliderFrame = Instance.new("Frame")
        SliderFrame.AnchorPoint = Vector2.new(0, 0)
        SliderFrame.BackgroundColor3 = Color3.fromHex("#262626")
        SliderFrame.BackgroundTransparency = 0
        SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Position = UDim2.new(0, 10, 0, trackY)
        SliderFrame.Size = UDim2.new(1, -20, 0, 4)
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = Slider

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 2)
        FrameCorner.Parent = SliderFrame

        local SliderFill = Instance.new("Frame")
        SliderFill.AnchorPoint = Vector2.new(0, 0.5)
        SliderFill.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        SliderFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFill.BorderSizePixel = 0
        SliderFill.Position = UDim2.new(0, 0, 0.5, 0)
        SliderFill.Size = UDim2.new(0.5, 0, 0, 3)
        SliderFill.Name = "SliderFill"
        SliderFill.Parent = SliderFrame

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 2)
        FillCorner.Parent = SliderFill

        local SliderCircle = nil
        if showKnob then
            SliderCircle = Instance.new("Frame")
            SliderCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SliderCircle.BorderSizePixel = 0
            SliderCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
            SliderCircle.Size = UDim2.fromOffset(14, 14)
            SliderCircle.ZIndex = 10
            SliderCircle.Name = "SliderCircle"
            SliderCircle.Parent = SliderFrame

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = SliderCircle

            local CircleStroke = Instance.new("UIStroke")
            CircleStroke.Color = Color3.fromHex("#333333")
            CircleStroke.Thickness = 1
            CircleStroke.Parent = SliderCircle
        end

        table.insert(ConfigSystem.SliderElements, SliderFrame)

        local sliderData = {
            Min = minValue or 0,
            Max = maxValue or 100,
            Value = defaultValue or minValue or 0,
            Dragging = false,
            TouchInput = nil
        }

        local function GetDecimals(num)
            local str = tostring(num or 0)
            local dot = str:find("%.")
            return dot and (#str - dot) or 0
        end

        local decimals = math.max(GetDecimals(sliderData.Min), GetDecimals(sliderData.Max), GetDecimals(defaultValue or 0))

        local function Round(num, decimalPlaces)
            local mult = 10 ^ (decimalPlaces or 0)
            return math.floor(num * mult + 0.5) / mult
        end

        local function SetValue(value, instant)
            value = math.clamp(value, sliderData.Min, sliderData.Max)
            sliderData.Value = Round(value, decimals)

            if decimals > 0 then
                ValueDisplay.Text = string.format("%." .. tostring(decimals) .. "f", sliderData.Value)
            else
                ValueDisplay.Text = tostring(math.floor(sliderData.Value + 0.5))
            end

            local range = sliderData.Max - sliderData.Min
            local percentage = range > 0 and math.clamp((sliderData.Value - sliderData.Min) / range, 0, 1) or 0

            if instant then
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                if SliderCircle then
                    SliderCircle.Position = UDim2.new(percentage, 0, 0.5, 0)
                end
            else
                TweenService:Create(
                    SliderFill,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(percentage, 0, 1, 0)}
                ):Play()
                if SliderCircle then
                    TweenService:Create(
                        SliderCircle,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Position = UDim2.new(percentage, 0, 0.5, 0)}
                    ):Play()
                end
            end

            if callback then
                callback(sliderData.Value)
            end
        end

        local startValue = defaultValue or minValue or 0
        SetValue(startValue, true)

        local function UpdateSliderFromInput(input)
            local inputPos
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                inputPos = input.Position
            elseif input.UserInputType == Enum.UserInputType.Touch then
                inputPos = input.Position
            else
                return
            end

            local sliderPos = SliderFrame.AbsolutePosition
            local sliderSize = SliderFrame.AbsoluteSize

            local percentage = math.clamp((inputPos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = sliderData.Min + (percentage * (sliderData.Max - sliderData.Min))

            SetValue(value)
        end

        SliderFrame.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    sliderData.Dragging = true
                    sliderData.TouchInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
                    UpdateSliderFromInput(input)
                end
            end
        )

        UserInputService.InputChanged:Connect(
            function(input)
                if
                    sliderData.Dragging and
                        (input.UserInputType == Enum.UserInputType.MouseMovement or
                            (input.UserInputType == Enum.UserInputType.Touch and sliderData.TouchInput and
                                input == sliderData.TouchInput))
                 then
                    UpdateSliderFromInput(input)
                end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input)
                if
                    (input.UserInputType == Enum.UserInputType.MouseButton1 and sliderData.Dragging) or
                        (input.UserInputType == Enum.UserInputType.Touch and sliderData.TouchInput and
                            input == sliderData.TouchInput)
                 then
                    sliderData.Dragging = false
                    sliderData.TouchInput = nil
                end
            end
        )

        UpdateContentSize()

        local sliderFunc = {
            Value = sliderData.Value,
            _data = sliderData,
            _default = defaultValue,
            Type = "Slider",
            Id = elementId
        }

        function sliderFunc:Set(value)
            SetValue(value)
            sliderFunc.Value = sliderData.Value
        end

        if elementId then
            AllElements[elementId] = sliderFunc
        end

        return sliderFunc
    end
    
    local function CreateImageBox(tabContainer, title, content, imageId, size, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        
        local ImageBox = Instance.new("Frame")
        ImageBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBox.BackgroundTransparency = 0.935
        ImageBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBox.BorderSizePixel = 0
        ImageBox.Size = UDim2.new(1, 0, 0, 46)
        ImageBox.Name = "ImageBox"
        ImageBox.Parent = tabContainer

        local ImageBoxCorner = Instance.new("UICorner")
        ImageBoxCorner.CornerRadius = UDim.new(0, 4)
        ImageBoxCorner.Parent = ImageBox

        local ImageBoxTitle = Instance.new("TextLabel")
        ImageBoxTitle.Font = Enum.Font.GothamBold
        ImageBoxTitle.Text = title
        ImageBoxTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ImageBoxTitle.TextSize = 14
        ImageBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
        ImageBoxTitle.TextYAlignment = Enum.TextYAlignment.Top
        ImageBoxTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxTitle.BackgroundTransparency = 0.999
        ImageBoxTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBoxTitle.BorderSizePixel = 0
        ImageBoxTitle.Position = UDim2.new(0, 10, 0, 10)
        ImageBoxTitle.Size = UDim2.new(1, -20, 0, 13)
        ImageBoxTitle.Name = "ImageBoxTitle"
        ImageBoxTitle.Parent = ImageBox

        local ImageBoxContent = Instance.new("TextLabel")
        ImageBoxContent.Font = Enum.Font.GothamBold
        ImageBoxContent.Text = content
        ImageBoxContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxContent.TextSize = 13
        ImageBoxContent.TextTransparency = 0.6
        ImageBoxContent.TextXAlignment = Enum.TextXAlignment.Left
        ImageBoxContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ImageBoxContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxContent.BackgroundTransparency = 0.999
        ImageBoxContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBoxContent.BorderSizePixel = 0
        ImageBoxContent.Position = UDim2.new(0, 10, 0, 23)
        ImageBoxContent.Size = UDim2.new(1, -20, 0, 12)
        ImageBoxContent.Name = "ImageBoxContent"
        ImageBoxContent.Parent = ImageBox

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 40, math.huge)
        )
        ImageBoxContent.Size = UDim2.new(1, -20, 0, textSize.Y)
        ImageBoxContent.TextWrapped = true

        local imageSize = size or UDim2.new(0, 100, 0, 100)
        local totalHeight = textSize.Y + 33 + imageSize.Y.Offset + 10

        ImageBox.Size = UDim2.new(1, 0, 0, math.max(46, totalHeight))

        local ImageContainer = Instance.new("Frame")
        ImageContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageContainer.BackgroundTransparency = 0.95
        ImageContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageContainer.BorderSizePixel = 0
        ImageContainer.Position = UDim2.new(0, 10, 0, textSize.Y + 33)
        ImageContainer.Size = imageSize
        ImageContainer.Name = "ImageContainer"
        ImageContainer.Parent = ImageBox

        local ContainerCorner = Instance.new("UICorner")
        ContainerCorner.CornerRadius = UDim.new(0, 4)
        ContainerCorner.Parent = ImageContainer

        local ImageDisplay = Instance.new("ImageLabel")
        ImageDisplay.Image = imageId or "rbxassetid://0"
        ImageDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageDisplay.BackgroundTransparency = 0.999
        ImageDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageDisplay.BorderSizePixel = 0
        ImageDisplay.Position = UDim2.new(0, 5, 0, 5)
        ImageDisplay.Size = UDim2.new(1, -10, 1, -10)
        ImageDisplay.Name = "ImageDisplay"
        ImageDisplay.Parent = ImageContainer

        local ImageButton = Instance.new("TextButton")
        ImageButton.Font = Enum.Font.SourceSans
        ImageButton.Text = ""
        ImageButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.TextSize = 14
        ImageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.BackgroundTransparency = 0.999
        ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.BorderSizePixel = 0
        ImageButton.Size = UDim2.new(1, 0, 1, 0)
        ImageButton.Name = "ImageButton"
        ImageButton.Parent = ImageBox

        ImageButton.Activated:Connect(
            function()
                CircleClick(ImageButton, Mouse.X, Mouse.Y)
                if callback then
                    callback(imageId)
                end
            end
        )

        UpdateContentSize()

        local imageBoxFunc = {
            ImageId = imageId,
            Type = "ImageBox",
            Id = elementId
        }

        function imageBoxFunc:SetImage(newImageId)
            ImageDisplay.Image = newImageId
            imageBoxFunc.ImageId = newImageId
        end

        function imageBoxFunc:SetSize(newSize)
            ImageContainer.Size = newSize
            local newTotalHeight = textSize.Y + 33 + newSize.Y.Offset + 10
            ImageBox.Size = UDim2.new(1, 0, 0, math.max(46, newTotalHeight))
            UpdateContentSize()
        end

        if elementId then
            AllElements[elementId] = imageBoxFunc
        end

        return imageBoxFunc
    end

    local function CreateTextHeader(tabContainer, title)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local header = Instance.new("TextLabel")
        header.BackgroundTransparency = 1
        header.BorderSizePixel = 0
        header.Position = UDim2.new(0, 0, 0, 0)
        header.Size = UDim2.new(1, 0, 0, 28)
        header.Font = Enum.Font.GothamBold
        header.Text = title or ""
        header.TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        header.TextSize = 15
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.TextYAlignment = Enum.TextYAlignment.Center
        header.Name = "TextHeader"
        header.Parent = tabContainer

        local headerPadding = Instance.new("UIPadding")
        headerPadding.PaddingLeft = UDim.new(0, 10)
        headerPadding.Parent = header

        table.insert(
            ConfigSystem.ThemeElements, 
            {
                Update = function(color)
                    if header and header.Parent then
                        header.TextColor3 = color
                    end
                end
            }
        )

        return header
    end

    -- FIXED: Renamed from CreateSection to CreateDivider
    local function CreateDivider(tabContainer, title)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        
        local Divider = Instance.new("Frame")
        Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Divider.BackgroundTransparency = 0.935
        Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Divider.BorderSizePixel = 0
        Divider.Size = UDim2.new(1, 0, 0, 40)
        Divider.Name = "Divider"
        Divider.Parent = tabContainer

        local DividerCorner = Instance.new("UICorner")
        DividerCorner.CornerRadius = UDim.new(0, 4)
        DividerCorner.Parent = Divider

        local DividerTitle = Instance.new("TextLabel")
        DividerTitle.Font = Enum.Font.GothamBold
        DividerTitle.Text = title
        DividerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        DividerTitle.TextSize = 14
        DividerTitle.TextXAlignment = Enum.TextXAlignment.Left
        DividerTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DividerTitle.BackgroundTransparency = 0.999
        DividerTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DividerTitle.BorderSizePixel = 0
        DividerTitle.Position = UDim2.new(0, 10, 0, 0)
        DividerTitle.Size = UDim2.new(1, -20, 0, 40)
        DividerTitle.Name = "DividerTitle"
        DividerTitle.Parent = Divider

        local DividerLine = Instance.new("Frame")
        DividerLine.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        DividerLine.BackgroundTransparency = 0.5
        DividerLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DividerLine.BorderSizePixel = 0
        DividerLine.Position = UDim2.new(0, 10, 0, 35)
        DividerLine.Size = UDim2.new(1, -20, 0, 2)
        DividerLine.Name = "DividerLine"
        DividerLine.Parent = Divider

        table.insert(
            ConfigSystem.ThemeElements, 
            {
                Update = function(color)
                    DividerLine.BackgroundColor3 = color
                end
            }
        )

        UpdateContentSize()

        return Divider
    end

    local function CreateColorPicker(tabContainer, title, content, defaultColor, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        elementId = elementId or title
        defaultColor = defaultColor or Color3.fromRGB(150, 150, 170)

        local hasDesc = content and tostring(content) ~= ""
        local cleanDesc = hasDesc and tostring(content):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "") or ""

        local curR = math.floor(defaultColor.R * 255 + 0.5)
        local curG = math.floor(defaultColor.G * 255 + 0.5)
        local curB = math.floor(defaultColor.B * 255 + 0.5)

        local ColorPicker = Instance.new("Frame")
        ColorPicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorPicker.BackgroundTransparency = 0.935
        ColorPicker.BorderSizePixel = 0
        ColorPicker.Size = UDim2.new(1, 0, 0, 0)
        ColorPicker.AutomaticSize = Enum.AutomaticSize.Y
        ColorPicker.Name = "ColorPicker"
        ColorPicker.ClipsDescendants = false
        ColorPicker.Parent = tabContainer

        local CPCorner = Instance.new("UICorner")
        CPCorner.CornerRadius = UDim.new(0, 4)
        CPCorner.Parent = ColorPicker

        local CPLayout = Instance.new("UIListLayout")
        CPLayout.FillDirection = Enum.FillDirection.Vertical
        CPLayout.SortOrder = Enum.SortOrder.LayoutOrder
        CPLayout.Padding = UDim.new(0, 4)
        CPLayout.Parent = ColorPicker

        -- Header Bar
        local Header = Instance.new("Frame")
        Header.BackgroundTransparency = 1
        Header.Size = UDim2.new(1, 0, 0, hasDesc and 44 or 38)
        Header.LayoutOrder = 1
        Header.Name = "Header"
        Header.Parent = ColorPicker

        local CPTitle = Instance.new("TextLabel")
        CPTitle.Font = Enum.Font.GothamBold
        CPTitle.Text = title
        CPTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        CPTitle.TextSize = 13
        CPTitle.TextXAlignment = Enum.TextXAlignment.Left
        CPTitle.TextYAlignment = hasDesc and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
        CPTitle.BackgroundTransparency = 1
        CPTitle.BorderSizePixel = 0
        CPTitle.Position = hasDesc and UDim2.new(0, 10, 0, 6) or UDim2.new(0, 10, 0.5, -7)
        CPTitle.Size = UDim2.new(1, -60, 0, 14)
        CPTitle.Name = "ColorPickerTitle"
        CPTitle.Parent = Header

        if hasDesc and cleanDesc ~= "" then
            local CPContent = Instance.new("TextLabel")
            CPContent.Font = Enum.Font.GothamBold
            CPContent.Text = cleanDesc
            CPContent.TextColor3 = Color3.fromRGB(180, 180, 190)
            CPContent.TextSize = 11
            CPContent.TextTransparency = 0.35
            CPContent.TextTruncate = Enum.TextTruncate.AtEnd
            CPContent.TextXAlignment = Enum.TextXAlignment.Left
            CPContent.TextYAlignment = Enum.TextYAlignment.Top
            CPContent.BackgroundTransparency = 1
            CPContent.BorderSizePixel = 0
            CPContent.Position = UDim2.new(0, 10, 0, 22)
            CPContent.Size = UDim2.new(1, -60, 0, 14)
            CPContent.Name = "ColorPickerContent"
            CPContent.Parent = Header
        end

        local ColorPreview = Instance.new("Frame")
        ColorPreview.AnchorPoint = Vector2.new(1, 0.5)
        ColorPreview.BackgroundColor3 = defaultColor
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Position = UDim2.new(1, -10, 0.5, 0)
        ColorPreview.Size = UDim2.fromOffset(26, 26)
        ColorPreview.Name = "ColorPreview"
        ColorPreview.Parent = Header

        local PrevCorner = Instance.new("UICorner")
        PrevCorner.CornerRadius = UDim.new(0, 6)
        PrevCorner.Parent = ColorPreview

        local PrevStroke = Instance.new("UIStroke")
        PrevStroke.Color = Color3.fromRGB(255, 255, 255)
        PrevStroke.Thickness = 1
        PrevStroke.Transparency = 0.8
        PrevStroke.Parent = ColorPreview

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.BackgroundTransparency = 1
        ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
        ToggleBtn.Text = ""
        ToggleBtn.Parent = Header

        -- Slider Container (In-place collapsible)
        local SliderContainer = Instance.new("Frame")
        SliderContainer.BackgroundTransparency = 1
        SliderContainer.Size = UDim2.new(1, 0, 0, 0)
        SliderContainer.AutomaticSize = Enum.AutomaticSize.Y
        SliderContainer.Visible = false
        SliderContainer.LayoutOrder = 2
        SliderContainer.Name = "SliderContainer"
        SliderContainer.Parent = ColorPicker

        local SCLayout = Instance.new("UIListLayout")
        SCLayout.FillDirection = Enum.FillDirection.Vertical
        SCLayout.Padding = UDim.new(0, 4)
        SCLayout.Parent = SliderContainer

        local SCPad = Instance.new("UIPadding")
        SCPad.PaddingLeft = UDim.new(0, 12)
        SCPad.PaddingRight = UDim.new(0, 12)
        SCPad.PaddingBottom = UDim.new(0, 8)
        SCPad.Parent = SliderContainer

        local isOpen = false
        ToggleBtn.Activated:Connect(function()
            isOpen = not isOpen
            SliderContainer.Visible = isOpen
        end)

        local function UpdateCurrentColor()
            local c = Color3.fromRGB(curR, curG, curB)
            ColorPreview.BackgroundColor3 = c
            if callback then callback(c) end
        end

        local function CreateChannelSlider(name, initialVal, accentColor, onVal)
            local row = Instance.new("Frame")
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 24)
            row.Parent = SliderContainer

            local lbl = Instance.new("TextLabel")
            lbl.Font = Enum.Font.GothamBold
            lbl.Text = name
            lbl.TextColor3 = accentColor
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.new(0, 0, 0.5, -6)
            lbl.Size = UDim2.new(0, 16, 0, 12)
            lbl.Parent = row

            local valLbl = Instance.new("TextLabel")
            valLbl.Font = Enum.Font.GothamBold
            valLbl.Text = tostring(initialVal)
            valLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
            valLbl.TextSize = 11
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.BackgroundTransparency = 1
            valLbl.Position = UDim2.new(1, -28, 0.5, -6)
            valLbl.Size = UDim2.new(0, 28, 0, 12)
            valLbl.Parent = row

            local track = Instance.new("Frame")
            track.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
            track.BorderSizePixel = 0
            track.AnchorPoint = Vector2.new(0, 0.5)
            track.Position = UDim2.new(0, 22, 0.5, 0)
            track.Size = UDim2.new(1, -56, 0, 4)
            track.Parent = row
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = accentColor
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new(initialVal / 255, 0, 1, 0)
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.Position = UDim2.new(initialVal / 255, 0, 0.5, 0)
            knob.Size = UDim2.fromOffset(12, 12)
            knob.ZIndex = 5
            knob.Parent = track
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local dragBtn = Instance.new("TextButton")
            dragBtn.BackgroundTransparency = 1
            dragBtn.Text = ""
            dragBtn.Size = UDim2.new(1, 0, 1, 0)
            dragBtn.Parent = track

            local function setValFromX(inputX)
                local absX = track.AbsolutePosition.X
                local absW = track.AbsoluteSize.X
                local pct = math.clamp((inputX - absX) / absW, 0, 1)
                local v = math.floor(pct * 255 + 0.5)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                valLbl.Text = tostring(v)
                onVal(v)
            end

            local isDragging = false
            dragBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    setValFromX(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if isDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    setValFromX(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            return {
                Set = function(newV)
                    local v = math.clamp(newV or 0, 0, 255)
                    local pct = v / 255
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, 0, 0.5, 0)
                    valLbl.Text = tostring(v)
                    onVal(v)
                end
            }
        end

        local rSlider = CreateChannelSlider("R", curR, Color3.fromRGB(240, 70, 70), function(v) curR = v; UpdateCurrentColor() end)
        local gSlider = CreateChannelSlider("G", curG, Color3.fromRGB(70, 220, 90), function(v) curG = v; UpdateCurrentColor() end)
        local bSlider = CreateChannelSlider("B", curB, Color3.fromRGB(70, 140, 255), function(v) curB = v; UpdateCurrentColor() end)

        local colorPickerFunc = {
            Value = defaultColor,
            Type = "ColorPicker",
            Id = elementId
        }

        function colorPickerFunc:Set(c)
            if type(c) == "table" then
                c = Color3.new(c[1] or 0, c[2] or 0, c[3] or 0)
            end
            if typeof(c) ~= "Color3" then return end
            curR = math.floor(c.R * 255 + 0.5)
            curG = math.floor(c.G * 255 + 0.5)
            curB = math.floor(c.B * 255 + 0.5)
            rSlider.Set(curR)
            gSlider.Set(curG)
            bSlider.Set(curB)
            colorPickerFunc.Value = c
        end

        if elementId then
            AllElements[elementId] = colorPickerFunc
        end

        return colorPickerFunc
    end
    local function CreateKeybind(tabContainer, title, content, defaultKey, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        elementId = elementId or title
        local Keybind = Instance.new("Frame")
        Keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Keybind.BackgroundTransparency = 0.935
        Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Keybind.BorderSizePixel = 0
        Keybind.Size = UDim2.new(1, 0, 0, 46)
        Keybind.Name = "Keybind"
        Keybind.Parent = tabContainer

        local KeybindCorner = Instance.new("UICorner")
        KeybindCorner.CornerRadius = UDim.new(0, 4)
        KeybindCorner.Parent = Keybind

        local KeybindTitle = Instance.new("TextLabel")
        KeybindTitle.Font = Enum.Font.GothamBold
        KeybindTitle.Text = title
        KeybindTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        KeybindTitle.TextSize = 14
        KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
        KeybindTitle.TextYAlignment = Enum.TextYAlignment.Top
        KeybindTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindTitle.BackgroundTransparency = 0.999
        KeybindTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindTitle.BorderSizePixel = 0
        KeybindTitle.Position = UDim2.new(0, 10, 0, 10)
        KeybindTitle.Size = UDim2.new(1, -100, 0, 13)
        KeybindTitle.Name = "KeybindTitle"
        KeybindTitle.Parent = Keybind

        local KeybindContent = Instance.new("TextLabel")
        KeybindContent.Font = Enum.Font.GothamBold
        KeybindContent.Text = content
        KeybindContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindContent.TextSize = 13
        KeybindContent.TextTransparency = 0.6
        KeybindContent.TextXAlignment = Enum.TextXAlignment.Left
        KeybindContent.TextYAlignment = Enum.TextYAlignment.Bottom
        KeybindContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindContent.BackgroundTransparency = 0.999
        KeybindContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindContent.BorderSizePixel = 0
        KeybindContent.Position = UDim2.new(0, 10, 0, 23)
        KeybindContent.Size = UDim2.new(1, -100, 0, 12)
        KeybindContent.Name = "KeybindContent"
        KeybindContent.Parent = Keybind

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        KeybindContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        KeybindContent.TextWrapped = true
        Keybind.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local KeybindFrame = Instance.new("Frame")
        KeybindFrame.AnchorPoint = Vector2.new(1, 0.5)
        KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindFrame.BackgroundTransparency = 0.95
        KeybindFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindFrame.BorderSizePixel = 0
        KeybindFrame.ClipsDescendants = true
        KeybindFrame.Position = UDim2.new(1, -7, 0.5, 0)
        KeybindFrame.Size = UDim2.new(0, 80, 0, 30)
        KeybindFrame.Name = "KeybindFrame"
        KeybindFrame.Parent = Keybind

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = KeybindFrame

        local KeybindText = Instance.new("TextLabel")
        KeybindText.Font = Enum.Font.GothamBold
        KeybindText.Text = defaultKey and defaultKey.Name or "None"
        KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindText.TextSize = 13
        KeybindText.TextTransparency = 0.6
        KeybindText.TextXAlignment = Enum.TextXAlignment.Center
        KeybindText.TextYAlignment = Enum.TextYAlignment.Center
        KeybindText.AnchorPoint = Vector2.new(0.5, 0.5)
        KeybindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindText.BackgroundTransparency = 0.999
        KeybindText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindText.BorderSizePixel = 0
        KeybindText.Position = UDim2.new(0.5, 0, 0.5, 0)
        KeybindText.Size = UDim2.new(1, -10, 1, -8)
        KeybindText.Name = "KeybindText"
        KeybindText.Parent = KeybindFrame

        local KeybindButton = Instance.new("TextButton")
        KeybindButton.Font = Enum.Font.SourceSans
        KeybindButton.Text = ""
        KeybindButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.TextSize = 14
        KeybindButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.BackgroundTransparency = 0.999
        KeybindButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.BorderSizePixel = 0
        KeybindButton.Size = UDim2.new(1, 0, 1, 0)
        KeybindButton.Name = "KeybindButton"
        KeybindButton.Parent = Keybind

        local keybindData = {
            Key = defaultKey,
            Listening = false,
            Connection = nil
        }

        local function SetKey(key)
            keybindData.Key = key
            KeybindText.Text = key and key.Name or "None"

            if keybindData.Connection then
                keybindData.Connection:Disconnect()
                keybindData.Connection = nil
            end

            if key then
                keybindData.Connection =
                    UserInputService.InputBegan:Connect(
                    function(input, gameProcessed)
                        if not gameProcessed and input.KeyCode == key then
                            if callback then
                                callback(key)
                            end
                        end
                    end
                )
            end
        end

        KeybindButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(KeybindButton, Mouse.X, Mouse.Y)

                if keybindData.Listening then
                    return
                end
                keybindData.Listening = true

                KeybindText.Text = "..."
                KeybindText.TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]

                local listeningConnection
                listeningConnection =
                    UserInputService.InputBegan:Connect(
                    function(input, gameProcessed)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then
                                keybindData.Listening = false
                                KeybindText.Text = keybindData.Key and keybindData.Key.Name or "None"
                                KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
                                if listeningConnection then
                                    listeningConnection:Disconnect()
                                end
                                return
                            end

                            keybindData.Listening = false
                            SetKey(input.KeyCode)
                            KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)

                            if listeningConnection then
                                listeningConnection:Disconnect()
                            end
                        end
                    end
                )
            end
        )

        if defaultKey then
            SetKey(defaultKey)
        end

        Keybind.Destroying:Connect(
            function()
                if keybindData.Connection then
                    keybindData.Connection:Disconnect()
                end
            end
        )

        UpdateContentSize()

        local keybindFunc = {
            Value = defaultKey,
            Type = "Keybind",
            Id = elementId
        }

        function keybindFunc:Set(key)
            SetKey(key)
            keybindFunc.Value = key
        end

        if elementId then
            AllElements[elementId] = keybindFunc
        end

        return keybindFunc
    end
    
    local function CreateHStack(tabContainer)
        if not tabContainer or not tabContainer:IsA("Frame") then return end

        local GridFrame = Instance.new("Frame")
        GridFrame.BackgroundTransparency = 1
        GridFrame.Size = UDim2.new(1, 0, 0, 36)
        GridFrame.BorderSizePixel = 0
        GridFrame.Name = "HStack"
        GridFrame.Parent = tabContainer

        local GridLayout = Instance.new("UIListLayout")
        GridLayout.FillDirection = Enum.FillDirection.Horizontal
        GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        GridLayout.Padding = UDim.new(0, 6)
        GridLayout.Parent = GridFrame

        local row = {
            Instance = GridFrame,
            Container = GridFrame,
            Buttons = {}
        }

        local function rebalance()
            local count = #row.Buttons
            if count == 0 then return end
            local totalGap = 6 * (count - 1)
            local widthScale = 1 / count
            local offsetPerBtn = -math.floor(totalGap / count)
            for _, b in ipairs(row.Buttons) do
                b.Size = UDim2.new(widthScale, offsetPerBtn, 1, 0)
            end
        end

        function row:Button(titleOrCfg, content, iconId, callback)
            local cfg = titleOrCfg
            if type(titleOrCfg) ~= "table" then
                cfg = {
                    Title = titleOrCfg,
                    Desc = content,
                    Icon = iconId,
                    Callback = callback
                }
            end

            local Btn = Instance.new("TextButton")
            Btn.Font = Enum.Font.GothamBold
            Btn.Text = cfg.Title or "Button"
            Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            Btn.TextSize = 12
            Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Btn.BackgroundTransparency = 0.92
            Btn.BorderSizePixel = 0
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.AutoButtonColor = true
            Btn.Name = "HBtn"
            Btn.Parent = GridFrame

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = Btn

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(80, 80, 80)
            BtnStroke.Thickness = 1
            BtnStroke.Transparency = 0.6
            BtnStroke.Parent = Btn

            if cfg.Callback then
                Btn.Activated:Connect(function()
                    if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                    CircleClick(Btn, Mouse.X, Mouse.Y)
                    cfg.Callback()
                end)
            end

            table.insert(row.Buttons, Btn)
            rebalance()
            task.wait(0.05)
            UpdateContentSize()
            return Btn
        end
        row.AddButton = row.Button

        task.wait(0.05)
        UpdateContentSize()
        return row
    end

    local function CreateButtonGrid(tabContainer, btn1Config, btn2Config)
        local row = CreateHStack(tabContainer)
        if not row then return end
        if btn1Config then row:Button(btn1Config) end
        if btn2Config then row:Button(btn2Config) end
        return row
    end

    local function AddWelcomeCard(tabContainer)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        local LP = game:GetService("Players").LocalPlayer
        local WC = Instance.new("Frame")
        WC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WC.BackgroundTransparency = 0.935
        WC.BorderSizePixel = 0
        WC.Size = UDim2.new(1, 0, 0, 88)
        WC.LayoutOrder = 0
        WC.Name = "WelcomeCard"
        WC.Parent = tabContainer
        Instance.new("UICorner", WC).CornerRadius = UDim.new(0, 4)

        local AF = Instance.new("Frame")
        AF.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        AF.BorderSizePixel = 0
        AF.Position = UDim2.new(0, 14, 0.5, -28)
        AF.Size = UDim2.new(0, 56, 0, 56)
        AF.Parent = WC
        Instance.new("UICorner", AF).CornerRadius = UDim.new(1, 0)

        local AI = Instance.new("ImageLabel")
        AI.Size = UDim2.new(1, 0, 1, 0)
        AI.BackgroundTransparency = 1
        AI.BorderSizePixel = 0
        AI.Parent = AF
        Instance.new("UICorner", AI).CornerRadius = UDim.new(1, 0)

        task.spawn(function()
            local ok, img = pcall(function()
                return game:GetService("Players"):GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and img then AI.Image = img end
        end)

        local NL = Instance.new("TextLabel")
        NL.Font = Enum.Font.GothamBold
        do
            local _n = LP.Name
            local _m = #_n > 3 and _n:sub(1, #_n - 3) .. "***" or "***"
            NL.Text = "Hey, " .. _m .. "!"
        end
        NL.TextColor3 = Color3.fromRGB(240, 240, 255)
        NL.TextSize = 14
        NL.TextXAlignment = Enum.TextXAlignment.Left
        NL.BackgroundTransparency = 1
        NL.BorderSizePixel = 0
        NL.Size = UDim2.new(1, -96, 0, 20)
        NL.Position = UDim2.new(0, 82, 0, 24)
        NL.Parent = WC

        local SL = Instance.new("TextLabel")
        SL.Font = Enum.Font.GothamBold
        SL.Text = "Welcome to Limbo Hub"
        SL.TextColor3 = Color3.fromRGB(255, 255, 255)
        SL.TextTransparency = 0.6
        SL.TextSize = 12
        SL.TextXAlignment = Enum.TextXAlignment.Left
        SL.BackgroundTransparency = 1
        SL.BorderSizePixel = 0
        SL.Size = UDim2.new(1, -96, 0, 16)
        SL.Position = UDim2.new(0, 82, 0, 50)
        SL.Parent = WC
    end

    local function CreateCollapsible(tabContainer, title, defaultOpen)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        defaultOpen = defaultOpen == true

        local SectionFrame = Instance.new("Frame")
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.Size = UDim2.new(1, 0, 0, 0)
        SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
        SectionFrame.BorderSizePixel = 0
        SectionFrame.ClipsDescendants = false
        SectionFrame.Name = "Collapsible"
        SectionFrame.Parent = tabContainer

        local SecLayout = Instance.new("UIListLayout")
        SecLayout.FillDirection = Enum.FillDirection.Vertical
        SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SecLayout.Padding = UDim.new(0, 4)
        SecLayout.Parent = SectionFrame

        local HeaderBtn = Instance.new("TextButton")
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Size = UDim2.new(1, 0, 0, 34)
        HeaderBtn.Font = Enum.Font.GothamBold
        HeaderBtn.Text = "  " .. (title or "Section")
        HeaderBtn.TextColor3 = Color3.fromRGB(170, 170, 185)
        HeaderBtn.TextSize = 14
        HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left
        HeaderBtn.BorderSizePixel = 0
        HeaderBtn.LayoutOrder = 1
        HeaderBtn.Name = "HeaderBtn"
        HeaderBtn.Parent = SectionFrame

        local SectionArrow = Instance.new("ImageLabel")
        SectionArrow.BackgroundTransparency = 1
        SectionArrow.AnchorPoint = Vector2.new(1, 0.5)
        SectionArrow.Position = UDim2.new(1, -8, 0.5, 0)
        SectionArrow.Size = UDim2.new(0, 25, 0, 25)
        SectionArrow.Image = "rbxassetid://16851841101"
        SectionArrow.ImageTransparency = 0.3
        SectionArrow.Rotation = defaultOpen and 0 or -90
        SectionArrow.Name = "SectionArrow"
        SectionArrow.Parent = HeaderBtn

        local InnerContainer = Instance.new("Frame")
        InnerContainer.BackgroundTransparency = 1
        InnerContainer.Size = UDim2.new(1, 0, 0, 0)
        InnerContainer.AutomaticSize = Enum.AutomaticSize.Y
        InnerContainer.BorderSizePixel = 0
        InnerContainer.ClipsDescendants = false
        InnerContainer.Visible = defaultOpen
        InnerContainer.LayoutOrder = 2
        InnerContainer.Name = "InnerContainer"
        InnerContainer.Parent = SectionFrame

        local InnerLayout = Instance.new("UIListLayout")
        InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        InnerLayout.Padding = UDim.new(0, 5)
        InnerLayout.Parent = InnerContainer

        local isOpen = defaultOpen

        local function updateSize()
            InnerContainer.Visible = isOpen
            TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = isOpen and 0 or -90}):Play()
        end

        HeaderBtn.Activated:Connect(function()
            if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
            isOpen = not isOpen
            updateSize()
        end)



        updateSize()
        return InnerContainer
    end

    local function CreateTabButton(tabName, iconId, isConfigTab)
        TabCount = TabCount + 1
        local Tab = Instance.new("Frame")
        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Tab.BackgroundTransparency = 0.999
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BorderSizePixel = 0
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.LayoutOrder = isConfigTab and 999 or TabCount
        Tab.Name = "Tab"
        Tab.Parent = TabScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = Tab

        local TabButton = Instance.new("TextButton")
        TabButton.ZIndex = 10
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 0.999
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        local TabNameLabel = Instance.new("TextLabel")
        TabNameLabel.Font = Enum.Font.GothamBold
        TabNameLabel.Text = tabName
        TabNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabNameLabel.TextSize = 13
        TabNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabNameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabNameLabel.BackgroundTransparency = 0.999
        TabNameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabNameLabel.BorderSizePixel = 0
        TabNameLabel.Size = UDim2.new(1, 0, 1, 0)
        TabNameLabel.Position = UDim2.new(0, iconId and iconId ~= "" and 30 or 10, 0, 0)
        TabNameLabel.Name = "TabName"
        TabNameLabel.Parent = Tab

        local resolvedTabIcon = ResolveIcon(iconId)
        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.Image = resolvedTabIcon or ""
        FeatureImg.BackgroundTransparency = 1
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Visible = resolvedTabIcon ~= nil and resolvedTabIcon ~= ""
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab



        local ChooseFrame = Instance.new("Frame")
        ChooseFrame.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ChooseFrame.BorderSizePixel = 0
        ChooseFrame.Position = UDim2.new(0, 0, 0, 9)
        ChooseFrame.Size = UDim2.new(0, 3, 0, 12)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Tab
        ChooseFrame.Visible = false

        local ChooseStroke = Instance.new("UIStroke")
        ChooseStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ChooseStroke.Thickness = 1.6
        ChooseStroke.Parent = ChooseFrame

        local ChooseCorner = Instance.new("UICorner")
        ChooseCorner.Parent = ChooseFrame

        table.insert(ConfigSystem.TabElements, Tab)

        local TabContentContainer = Instance.new("Frame")
        TabContentContainer.BackgroundTransparency = 1
        TabContentContainer.Size = UDim2.new(1, 0, 0, 0)
        TabContentContainer.AutomaticSize = Enum.AutomaticSize.Y
        TabContentContainer.Visible = false
        TabContentContainer.LayoutOrder = isConfigTab and 999 or TabCount
        TabContentContainer.Name = tabName .. "Content"
        TabContentContainer.Parent = ContentScroll

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = TabContentContainer

        local ContainerPad = Instance.new("UIPadding")
        ContainerPad.PaddingLeft = UDim.new(0, 4)
        ContainerPad.PaddingRight = UDim.new(0, 4)
        ContainerPad.PaddingTop = UDim.new(0, 4)
        ContainerPad.PaddingBottom = UDim.new(0, 16)
        ContainerPad.Parent = TabContentContainer

        TabContents[tabName] = TabContentContainer
        TabContentContainer:SetAttribute("LimboTabName", tabName)

        local function SwitchToTab()
            for name, container in pairs(TabContents) do
                container.Visible = false
            end

            for _, tabFrame in TabScroll:GetChildren() do
                if tabFrame:IsA("Frame") and tabFrame.Name == "Tab" then
                    local chooseFrame = tabFrame:FindFirstChild("ChooseFrame")
                    if chooseFrame then
                        chooseFrame.Visible = false
                    end
                    tabFrame.BackgroundTransparency = 0.999
                end
            end

            TabContentContainer.Visible = true
            ChooseFrame.Visible = true
            Tab.BackgroundTransparency = 0.92
            CurrentTab = tabName
            UpdateContentSize()
        end

        TabSwitchFns[tabName] = SwitchToTab

        TabButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(TabButton, Mouse.X, Mouse.Y)
                SwitchToTab()
            end
        )

        return TabContentContainer, SwitchToTab
    end
    
    local ConfigTabContainer, SwitchToConfigTab = CreateTabButton("Configuration", "settings", true)
    
    -- Helper Utilities (Rejoin & Server Hop)
    local function doRejoin()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local placeId = game.PlaceId
        local jobId = game.JobId

        local success, err = pcall(function()
            if #Players:GetPlayers() <= 1 then
                TeleportService:Teleport(placeId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
            end
        end)

        if not success then
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
        end
    end

    local function doServerHop()
        local placeId = game.PlaceId
        local best, bestPlayers
        local cursor = ""
        local lookupError

        for _ = 1, 3 do
            local ok, body = pcall(function()
                local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(placeId)
                if cursor ~= "" then url = url .. "&cursor=" .. cursor end
                return game:GetService("HttpService"):JSONDecode(game:HttpGet(url))
            end)
            if not ok or not body then
                lookupError = body
                break
            end
            for _, s in ipairs(body.data or {}) do
                if s.id ~= game.JobId and s.playing and s.playing < s.maxPlayers then
                    if not bestPlayers or s.playing < bestPlayers then
                        bestPlayers = s.playing
                        best = s.id
                    end
                end
            end
            cursor = body.nextPageCursor or ""
            if cursor == "" then break end
        end

        if best then
            local ok, err = pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, best, game:GetService("Players").LocalPlayer)
            end)
            if not ok then
                MakeNotify({
                    Title = "Limbo HUB",
                    Content = "Server hop failed: " .. tostring(err),
                    Delay = 4,
                })
            end
        else
            MakeNotify({
                Title = "Limbo HUB",
                Content = lookupError and "Could not fetch public servers." or "No available public server was found.",
                Delay = 4,
            })
        end
    end

    -- Section 1 (Pertama): Utilities (Default false / tertutup)
    local UtilSection = CreateCollapsible(ConfigTabContainer, "Utilities", false)

    CreateButton(UtilSection, "Rejoin Server", "Rejoin to Current server", "refresh-cw", function()
        MakeNotify({ Title = "Rejoin", Description = "Connecting", Content = "Rejoining current server...", Delay = 2.5 })
        doRejoin()
    end)

    CreateButton(UtilSection, "Server Hop", "Teleport to server with fewest players", "mouse-pointer-click", function()
        MakeNotify({ Title = "Server Hop", Description = "Searching", Content = "Searching for lowest player server...", Delay = 2.5 })
        doServerHop()
    end)

    -- Section 2 (Kedua): Configuration
    local CurrentConfigName = ""
    local SelectedConfigName = ""
    local AutoloadFile = ConfigFolder .. "/Autoload.txt"
    local CfgSection = CreateCollapsible(ConfigTabContainer, "Configuration", true)

    -- Status header frame with gear icon + two-line status
    local CfgHeaderFrame = Instance.new("Frame", CfgSection)
    CfgHeaderFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    CfgHeaderFrame.BackgroundTransparency = 0.935
    CfgHeaderFrame.BorderSizePixel = 0
    CfgHeaderFrame.Size = UDim2.new(1, 0, 0, 56)
    CfgHeaderFrame.Name = "CfgHeader"
    Instance.new("UICorner", CfgHeaderFrame).CornerRadius = UDim.new(0, 4)

    local CfgGearIcon = Instance.new("ImageLabel", CfgHeaderFrame)
    CfgGearIcon.Image = "rbxassetid://112919034802026"
    CfgGearIcon.BackgroundTransparency = 1
    CfgGearIcon.Position = UDim2.new(0, 8, 0.5, 0)
    CfgGearIcon.AnchorPoint = Vector2.new(0, 0.5)
    CfgGearIcon.Size = UDim2.new(0, 18, 0, 18)
    CfgGearIcon.ZIndex = 2

    local CfgTitle = Instance.new("TextLabel", CfgHeaderFrame)
    CfgTitle.Font = Enum.Font.GothamBold
    CfgTitle.Text = "Config Manager"
    CfgTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    CfgTitle.TextSize = 14
    CfgTitle.TextXAlignment = Enum.TextXAlignment.Left
    CfgTitle.BackgroundTransparency = 1
    CfgTitle.BorderSizePixel = 0
    CfgTitle.Position = UDim2.new(0, 32, 0, 13)
    CfgTitle.Size = UDim2.new(1, -36, 0, 14)
    CfgTitle.ZIndex = 2

    local CfgStatusLabel = Instance.new("TextLabel", CfgHeaderFrame)
    CfgStatusLabel.Font = Enum.Font.GothamBold
    CfgStatusLabel.Text = "Current: None  |  Autoload: None"
    CfgStatusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    CfgStatusLabel.TextSize = 12
    CfgStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    CfgStatusLabel.TextWrapped = true
    CfgStatusLabel.BackgroundTransparency = 1
    CfgStatusLabel.BorderSizePixel = 0
    CfgStatusLabel.Position = UDim2.new(0, 32, 0, 29)
    CfgStatusLabel.Size = UDim2.new(1, -36, 0, 24)
    CfgStatusLabel.ZIndex = 2

    local function updateCfgStatus()
        local cur = CurrentConfigName ~= "" and CurrentConfigName or "None"
        local al = "None"
        pcall(function()
            if isfile(AutoloadFile) then
                local v = readfile(AutoloadFile)
                if v and v ~= "" then al = v end
            end
        end)
        CfgStatusLabel.Text = "Current: " .. cur .. "  |  Autoload: " .. al
    end
    updateCfgStatus()



    local ConfigNameInput =
        CreateInput(
        CfgSection,
        "Config Name",
        "",
        "Write your input here...",
        function(value)
            CurrentConfigName = value
        end,
        "ConfigName"
    )

    local SelectConfigDropdown = CreateDropdown(
        CfgSection,
        "Select Config",
        "Choose from saved configs",
        ConfigSystem:GetConfigList(),
        false,
        nil,
        function(value)
            if value and value ~= "" then
                SelectedConfigName = value
                CurrentConfigName = value
                updateCfgStatus()
            end
        end,
        "SelectConfigDropdown"
    )

    local function doSaveConfig()
        local targetName = CurrentConfigName ~= "" and CurrentConfigName or SelectedConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Enter or select a config name first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local autoName = ""
        pcall(function()
            if isfile(AutoloadFile) then autoName = readfile(AutoloadFile) end
        end)
        local configData = {
            __autoload = (targetName == autoName),
            __elements = {}
        }
        for id, element in pairs(AllElements) do
            local val = nil
            if element.Type == "Toggle" then
                local live = element._live and element._live() or element.Value
                val = live
            elseif element.Type == "Slider" then
                local live = element._data and element._data.Value or element.Value
                local def = element._default
                if def == nil or live ~= def then val = live end
            elseif element.Type == "Dropdown" then
                local live = element._data and element._data.Value or element.Value
                if element._data and element._data.Multi then
                    if type(live) == "table" and #live > 0 then val = live end
                else
                    if live and live ~= "" and live ~= "Select Option" then val = live end
                end
            elseif element.Type == "Input" then
                if element.Value and element.Value ~= "" then val = element.Value end
            elseif element.Type == "ColorPicker" then
                if element.Value then val = {element.Value.R, element.Value.G, element.Value.B} end
            elseif element.Type == "Keybind" then
                if element.Value then val = element.Value.Name end
            end
            if val ~= nil then
                configData[id] = val
                configData.__elements[id] = {
                    __type = element.Type,
                    value = val
                }
            end
        end
        local notifyData = ConfigSystem:SaveConfig(targetName, configData)
        MakeNotify(notifyData)
        CurrentConfigName = targetName
        updateCfgStatus()
        local configList = ConfigSystem:GetConfigList()
        SelectConfigDropdown:Refresh(configList)
    end

    local function doLoadConfig()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local _, configData = ConfigSystem:LoadConfig(targetName)
        if configData then
            for id, val in pairs(configData) do
                pcall(function()
                    if AllElements[id] then
                        if AllElements[id].Type == "Toggle" and val == false then
                            return
                        end
                        if AllElements[id].Type == "ColorPicker" and type(val) == "table" then
                            AllElements[id]:Set(Color3.new(val[1], val[2], val[3]))
                        elseif AllElements[id].Type == "Keybind" and val then
                            AllElements[id]:Set(Enum.KeyCode[val])
                        else
                            AllElements[id]:Set(val)
                        end
                    end
                end)
            end
        end
        CurrentConfigName = targetName
        updateCfgStatus()
        MakeNotify({ Title = "Config", Description = "Loaded", Content = "\"" .. targetName .. "\" loaded!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
    end

    local function doDeleteConfig()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local notifyData = ConfigSystem:DeleteConfig(targetName)
        MakeNotify(notifyData)
        SelectedConfigName = ""
        CurrentConfigName = ""
        updateCfgStatus()
        local configList = ConfigSystem:GetConfigList()
        SelectConfigDropdown:Refresh(configList)
    end

    local function doSetAutoload()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        pcall(function()
            if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
            writefile(AutoloadFile, targetName)
        end)
        MakeNotify({ Title = "Config", Description = "Autoload Set", Content = "Autoload -> \"" .. targetName .. "\"", Color = Color3.fromRGB(150,150,170), Delay = 3 })
        updateCfgStatus()
    end

    local function doClearAutoload()
        pcall(function()
            if isfile(AutoloadFile) then writefile(AutoloadFile, "") end
        end)
        MakeNotify({ Title = "Config", Description = "Cleared", Content = "Autoload cleared.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
        updateCfgStatus()
    end

    CreateButtonGrid(CfgSection,
        { Title = "Save Config", Callback = doSaveConfig },
        { Title = "Load Config", Callback = doLoadConfig }
    )

    CreateButtonGrid(CfgSection,
        { Title = "Delete Config", Callback = doDeleteConfig },
        { Title = "Set Autoload",  Callback = doSetAutoload }
    )

    CreateButtonGrid(CfgSection,
        { Title = "Refresh List", Callback = function()
            local configList = ConfigSystem:GetConfigList()
            SelectConfigDropdown:Refresh(configList)
            MakeNotify({ Title = "Config", Description = "Refreshed", Content = "Config list updated.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
        end },
        { Title = "Clear Autoload", Callback = doClearAutoload }
    )

    CreateButton(CfgSection, "Reset All Elements", "Reset all elements to default", "mouse-pointer-click", function()
        for id, element in pairs(AllElements) do
            pcall(function()
                if element.Type == "Toggle" then
                    element:Set(false)
                elseif element.Type == "Slider" then
                    local min = element._data and element._data.MinValue or 0
                    element:Set(min)
                elseif element.Type == "Dropdown" then
                    if element._data and element._data.Multi then
                        element:Set({})
                    else
                        element:Set(nil)
                    end
                elseif element.Type == "Input" then
                    element:Set("")
                end
            end)
        end
        MakeNotify({ Title = "Config", Description = "Reset", Content = "All elements reset to default.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
    end)

    -- backward compat refs
    local LoadConfigDropdown = SelectConfigDropdown
    local DeleteConfigDropdown = SelectConfigDropdown
    
    -- Switch to first tab is handled by Window:Show()

    -- Window Methods
    local Window = {}
    Window.UIElements = {
        Main = DropShadowHolder,
        DropShadowHolder = DropShadowHolder,
        Container = Main,
        ScreenGui = ScreenGui,
    }

    local ContainerMethods = {}

    function ContainerMethods:Section(titleOrCfg, defaultOpen)
        local title = titleOrCfg
        local opened = defaultOpen
        if type(titleOrCfg) == "table" then
            title = titleOrCfg.Title or titleOrCfg.title or "Section"
            opened = (titleOrCfg.Opened ~= nil and titleOrCfg.Opened) or (titleOrCfg.opened ~= nil and titleOrCfg.opened) or (titleOrCfg.Box and false) or defaultOpen
        end
        local secFrame = CreateCollapsible(self.Container, title, opened)
        local secObj = setmetatable({
            Container = secFrame,
            Instance = secFrame,
            Title = title,
            Type = "Section"
        }, { __index = ContainerMethods })
        return secObj
    end

    function ContainerMethods:Toggle(titleOrCfg, content, defaultValue, callback, elementId)
        if type(titleOrCfg) == "table" then
            local cfg = titleOrCfg
            return CreateToggle(self.Container, cfg.Title, cfg.Desc or cfg.Content, cfg.Value or cfg.Default, cfg.Callback, cfg.Flag or cfg.Id)
        else
            return CreateToggle(self.Container, titleOrCfg, content, defaultValue, callback, elementId)
        end
    end

    function ContainerMethods:Slider(titleOrCfg, content, minValue, maxValue, defaultValue, callback, elementId, showKnob)
        if type(titleOrCfg) == "table" then
            local cfg = titleOrCfg
            return CreateSlider(self.Container, cfg.Title, cfg.Desc or cfg.Content, cfg.Min or cfg.minValue or 0, cfg.Max or cfg.maxValue or 100, cfg.Value or cfg.Default or cfg.defaultValue, cfg.Callback, cfg.Flag or cfg.Id, cfg.showKnob ~= false)
        else
            return CreateSlider(self.Container, titleOrCfg, content, minValue, maxValue, defaultValue, callback, elementId, showKnob)
        end
    end

    function ContainerMethods:Dropdown(titleOrCfg, content, options, multi, defaultValue, callback, elementId)
        if type(titleOrCfg) == "table" then
            local cfg = titleOrCfg
            return CreateDropdown(self.Container, cfg.Title, cfg.Desc or cfg.Content, cfg.Values or cfg.options, cfg.Multi or cfg.multi, cfg.Value or cfg.Default or cfg.defaultValue, cfg.Callback, cfg.Flag or cfg.Id)
        else
            return CreateDropdown(self.Container, titleOrCfg, content, options, multi, defaultValue, callback, elementId)
        end
    end

    function ContainerMethods:Input(titleOrCfg, content, placeholder, callback, elementId)
        if type(titleOrCfg) == "table" then
            local cfg = titleOrCfg
            return CreateInput(self.Container, cfg.Title, cfg.Desc or cfg.Content, cfg.Placeholder or cfg.placeholder, cfg.Callback, cfg.Flag or cfg.Id)
        else
            return CreateInput(self.Container, titleOrCfg, content, placeholder, callback, elementId)
        end
    end

    function ContainerMethods:Button(titleOrCfg, content, iconId, callback)
        if type(titleOrCfg) == "table" then
            local cfg = titleOrCfg
            return CreateButton(self.Container, cfg.Title, cfg.Desc or cfg.Content, cfg.Icon or cfg.iconId or "mouse-pointer-click", cfg.Callback)
        else
            return CreateButton(self.Container, titleOrCfg, content, iconId, callback)
        end
    end

    function ContainerMethods:Paragraph(titleOrConfig, content, buttons)
        return CreateParagraph(self.Container, titleOrConfig, content, buttons)
    end

    function ContainerMethods:HStack(...)
        return CreateHStack(self.Container)
    end

    function ContainerMethods:ButtonGrid(btn1Config, btn2Config)
        return CreateButtonGrid(self.Container, btn1Config, btn2Config)
    end

    function ContainerMethods:ColorPicker(titleOrCfg, content, defaultColor, callback, elementId)
        if type(titleOrCfg) == "table" then
            local cfg = titleOrCfg
            return CreateColorPicker(self.Container, cfg.Title, cfg.Desc or cfg.Content, cfg.Default or cfg.Color or cfg.defaultColor, cfg.Callback, cfg.Flag or cfg.Id)
        else
            return CreateColorPicker(self.Container, titleOrCfg, content, defaultColor, callback, elementId)
        end
    end

    function ContainerMethods:Keybind(titleOrCfg, content, defaultKey, callback, elementId)
        if type(titleOrCfg) == "table" then
            local cfg = titleOrCfg
            return CreateKeybind(self.Container, cfg.Title, cfg.Desc or cfg.Content, cfg.Default or cfg.Key or cfg.defaultKey, cfg.Callback, cfg.Flag or cfg.Id)
        else
            return CreateKeybind(self.Container, titleOrCfg, content, defaultKey, callback, elementId)
        end
    end

    function ContainerMethods:Divider(title)
        return CreateDivider(self.Container, title)
    end

    function ContainerMethods:SingleButton(title, callback)
        return CreateSingleButton(self.Container, title, callback)
    end

    function ContainerMethods:TextHeader(title)
        return CreateTextHeader(self.Container, title)
    end

    function ContainerMethods:WelcomeCard()
        return AddWelcomeCard(self.Container)
    end

    function ContainerMethods:ImageBox(title, content, imageId, size, callback, elementId)
        return CreateImageBox(self.Container, title, content, imageId, size, callback, elementId)
    end

    function ContainerMethods:LineSlider(title, content, minValue, maxValue, defaultValue, callback, elementId)
        return CreateSlider(self.Container, title, content, minValue, maxValue, defaultValue, callback, elementId, false)
    end

    function ContainerMethods:MultiDropdown(title, content, options, defaultValue, callback, elementId)
        return CreateDropdown(self.Container, title, content, options, true, defaultValue, callback, elementId)
    end

    -- CreateTab definition
    function Window:Tab(tabNameOrCfg, iconId)
        local tabName = tabNameOrCfg
        local icon = iconId
        if type(tabNameOrCfg) == "table" then
            tabName = tabNameOrCfg.Title or tabNameOrCfg.title or "Tab"
            icon = tabNameOrCfg.Icon or tabNameOrCfg.icon or iconId
        end
        local container, switchFn = CreateTabButton(tabName, icon, false)
        if not CurrentTab then
            task.defer(function()
                if not CurrentTab then
                    switchFn()
                end
            end)
        end
        local tabObj = setmetatable({
            Container = container,
            Instance = container,
            Title = tabName,
            Type = "Tab"
        }, { __index = ContainerMethods })
        return tabObj
    end
    Window.CreateTab = Window.Tab
    Window.AddTab = Window.Tab

    function Window:SelectTab(target)
        if type(target) == "number" then
            local count = 0
            for tabName, switchFn in pairs(TabSwitchFns) do
                count = count + 1
                if count == target then
                    switchFn()
                    break
                end
            end
        elseif type(target) == "string" and TabSwitchFns[target] then
            TabSwitchFns[target]()
        end
    end

    function Window:Open()
        return Window:Show()
    end

    function Window:ConfigPanel(container)
        local rawFrame = (type(container) == "table" and container.Container) or container
        return setmetatable({
            Container = rawFrame,
            Instance = rawFrame,
            Type = "ConfigPanel"
        }, { __index = ContainerMethods })
    end

    Window.OpenButtonMain = {
        Visible = function() end,
        Button = { Visible = false }
    }
    
    function Window:Notify(notifyConfig)
        return MakeNotify(notifyConfig)
    end
    
    function Window:SetTheme(themeName)
        return ConfigSystem:SetTheme(themeName)
    end
    
    function Window:SetVersion(newVersion)
        if not newVersion or newVersion == "" then return end
        Version = tostring(newVersion)
        Window.Version = Version
        if Row1 then
            local vb = Row1:FindFirstChild("VersionBadge")
            if vb then
                local lbl = vb:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.Text = Version end
            end
        end
    end

    function Window:SaveConfig(name)
        local autoName = ""
        pcall(function()
            if isfile(AutoloadFile) then autoName = readfile(AutoloadFile) end
        end)

        local configData = {
            __autoload = (name == autoName),
            __elements = {}
        }
        for id, element in pairs(AllElements) do
            configData[id] = element.Value
            configData.__elements[id] = {
                __type = element.Type,
                value = element.Value
            }
        end
        local notifyData = ConfigSystem:SaveConfig(name, configData)
        MakeNotify(notifyData)
    end
    
    function Window:LoadConfig(name)
        local notifyData, rawData = ConfigSystem:LoadConfig(name)
        MakeNotify(notifyData)
        if rawData then
            local elems = (type(rawData) == "table" and rawData.__elements) or rawData
            for id, val in pairs(elems) do
                local actualVal = (type(val) == "table" and val.value ~= nil) and val.value or val
                if AllElements[id] then
                    if AllElements[id].Type == "ColorPicker" and type(actualVal) == "table" then
                        AllElements[id]:Set(Color3.new(actualVal[1], actualVal[2], actualVal[3]))
                    elseif AllElements[id].Type == "Keybind" and actualVal then
                        AllElements[id]:Set(Enum.KeyCode[actualVal])
                    else
                        AllElements[id]:Set(actualVal)
                    end
                end
            end
        end
    end
    
    function Window:DeleteConfig(name)
        local notifyData = ConfigSystem:DeleteConfig(name)
        MakeNotify(notifyData)
    end
    
    function Window:GetConfigs()
        return ConfigSystem:GetConfigList()
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:SetActiveTab(tabName)
        if TabSwitchFns[tabName] then
            TabSwitchFns[tabName]()
        end
    end

    function Window:GetUIScale()
        return UIScaleObj.Scale
    end

    function Window:SetUIScale(scale)
        local clamped = math.clamp(tonumber(scale) or 1, 0.5, 1.5)
        TweenService:Create(UIScaleObj, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = clamped }):Play()
        return Window
    end

    function Window:SetAutoScale(enabled)
        AutoScale = enabled == true
        if AutoScale then
            UpdateAutoScale()
        end
        return Window
    end

    function Window:Toggle()
        DropShadowHolder.Visible = not DropShadowHolder.Visible
        return DropShadowHolder.Visible
    end

    function Window:Show()
        DropShadowHolder.Visible = true
        task.spawn(function()
            task.wait(0.5)
            pcall(function()
                if isfile(AutoloadFile) then
                    local autoName = readfile(AutoloadFile)
                    if autoName and autoName ~= "" then
                        local _, configData = ConfigSystem:LoadConfig(autoName)
                        if configData then
                            for id, val in pairs(configData) do
                                pcall(function()
                                    if AllElements[id] then
                                        if AllElements[id].Type == "Toggle" and val == false then
                                            return
                                        end
                                        if AllElements[id].Type == "ColorPicker" and type(val) == "table" then
                                            AllElements[id]:Set(Color3.new(val[1], val[2], val[3]))
                                        elseif AllElements[id].Type == "Keybind" and val then
                                            AllElements[id]:Set(Enum.KeyCode[val])
                                        else
                                            AllElements[id]:Set(val)
                                        end
                                    end
                                end)
                                task.wait(0.04)
                            end
                            CurrentConfigName = autoName
                            updateCfgStatus()
                            MakeNotify({ Title = "Config", Description = "Autoloaded", Content = "\"" .. autoName .. "\" loaded!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
                        end
                    end
                end
            end)
        end)
    end
    
    return Window
end

function Limbo:Notify(config)
    MakeNotify(config)
end

return Limbo
