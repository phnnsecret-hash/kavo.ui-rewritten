local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local ThemeManager = {
    Current = {
        SchemeColor = Color3.fromRGB(74, 99, 135),
        Background = Color3.fromRGB(36, 37, 43),
        Header = Color3.fromRGB(28, 29, 34),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(32, 32, 38)
    },
    Objects = {}
}

local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function Tween(obj, props, time, style, dir)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.InOut), props):Play()
end

local function RegisterTheme(obj, prop, themeKey)
    if not ThemeManager.Objects[themeKey] then
        ThemeManager.Objects[themeKey] = {}
    end
    table.insert(ThemeManager.Objects[themeKey], {Object = obj, Property = prop})
    obj[prop] = ThemeManager.Current[themeKey]
end

function Library:SetTheme(themeTable)
    for key, color in pairs(themeTable) do
        ThemeManager.Current[key] = color
        if ThemeManager.Objects[key] then
            for _, item in ipairs(ThemeManager.Objects[key]) do
                item.Object[item.Property] = color
            end
        end
    end
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Library"
    local theme = options.Theme or ThemeManager.Current
    
    Library:SetTheme(theme)

    local ScreenGui = Create("ScreenGui", {
        Name = title,
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = ThemeManager.Current.Background,
        Position = UDim2.new(0.5, -262, 0.5, -159),
        Size = UDim2.new(0, 525, 0, 318),
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Main})
    RegisterTheme(Main, "BackgroundColor3", "Background")

    local Header = Create("Frame", {
        Name = "Header",
        Parent = Main,
        BackgroundColor3 = ThemeManager.Current.Header,
        Size = UDim2.new(1, 0, 0, 29)
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Header})
    RegisterTheme(Header, "BackgroundColor3", "Header")

    local HeaderTitle = Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.02, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    MakeDraggable(Main, Header)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        BackgroundColor3 = ThemeManager.Current.Header,
        Position = UDim2.new(0, 0, 0.091, 0),
        Size = UDim2.new(0, 150, 0.909, 0)
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})
    RegisterTheme(Sidebar, "BackgroundColor3", "Header")

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(1, -10, 1, -10),
        ScrollBarThickness = 0
    })
    local TabList = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    local Pages = Create("Frame", {
        Name = "Pages",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.29, 0, 0.1, 0),
        Size = UDim2.new(0.70, 0, 0.89, 0)
    })

    local MobileToggle = Create("TextButton", {
        Parent = ScreenGui,
        BackgroundColor3 = ThemeManager.Current.Header,
        Position = UDim2.new(0.1, 0, 0.1, 0),
        Size = UDim2.new(0, 50, 0, 50),
        Text = "UI",
        TextColor3 = ThemeManager.Current.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Visible = false
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MobileToggle})
    RegisterTheme(MobileToggle, "BackgroundColor3", "Header")
    RegisterTheme(MobileToggle, "TextColor3", "TextColor")

    if UserInputService.TouchEnabled then
        MobileToggle.Visible = true
        MakeDraggable(MobileToggle, MobileToggle)
        MobileToggle.MouseButton1Click:Connect(function()
            Main.Visible = not Main.Visible
        end)
    end
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)

    local Tabs = {}
    local firstTab = true

    function Tabs:NewTab(tabName)
        local Tab = {}
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = ThemeManager.Current.SchemeColor,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham,
            Text = tabName,
            TextColor3 = ThemeManager.Current.TextColor,
            TextSize = 14
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = TabButton})
        RegisterTheme(TabButton, "TextColor3", "TextColor")
        RegisterTheme(TabButton, "BackgroundColor3", "SchemeColor")

        local Page = Create("ScrollingFrame", {
            Name = tabName,
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            Visible = false
        })
        local PageList = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabButton.BackgroundTransparency = 0
            TabButton.TextColor3 = Color3.new(1, 1, 1)
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(Pages:GetChildren()) do
                v.Visible = false
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, {BackgroundTransparency = 1}, 0.2)
                    v.TextColor3 = ThemeManager.Current.TextColor
                end
            end
            
            Page.Visible = true
            Tween(TabButton, {BackgroundTransparency = 0}, 0.2)
            TabButton.TextColor3 = Color3.new(1, 1, 1)
        end)

        function Tab:NewSection(sectionName)
            local Section = {}
            local SectionFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = ThemeManager.Current.Background,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 30)
            })

            local SectionHeader = Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = ThemeManager.Current.SchemeColor,
                Size = UDim2.new(1, 0, 0, 30)
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SectionHeader})
            RegisterTheme(SectionHeader, "BackgroundColor3", "SchemeColor")

            local SectionTitle = Create("TextLabel", {
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.02, 0, 0, 0),
                Size = UDim2.new(0.98, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = ThemeManager.Current.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            RegisterTheme(SectionTitle, "TextColor3", "TextColor")

            local SectionContainer = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 0, 0)
            })
            local SectionContainerList = Create("UIListLayout", {
                Parent = SectionContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })

            SectionContainerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContainer.Size = UDim2.new(1, 0, 0, SectionContainerList.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, -10, 0, SectionContainerList.AbsoluteContentSize.Y + 40)
            end)

            function Section:NewLabel(text)
                local LabelFrame = Create("Frame", {
                    Parent = SectionContainer,
                    BackgroundColor3 = ThemeManager.Current.ElementColor,
                    Size = UDim2.new(1, 0, 0, 25)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = LabelFrame})
                RegisterTheme(LabelFrame, "BackgroundColor3", "ElementColor")
                
                local LabelText = Create("TextLabel", {
                    Parent = LabelFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14
                })
                RegisterTheme(LabelText, "TextColor3", "TextColor")
            end

            function Section:NewButton(text, callback)
                callback = callback or function() end
                local ButtonFrame = Create("TextButton", {
                    Parent = SectionContainer,
                    BackgroundColor3 = ThemeManager.Current.ElementColor,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. text,
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ButtonFrame})
                RegisterTheme(ButtonFrame, "BackgroundColor3", "ElementColor")
                RegisterTheme(ButtonFrame, "TextColor3", "TextColor")

                local Icon = Create("ImageLabel", {
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0.15, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    Image = "rbxassetid://3926305904",
                    ImageRectOffset = Vector2.new(84, 204),
                    ImageRectSize = Vector2.new(36, 36),
                    ImageColor3 = ThemeManager.Current.SchemeColor
                })
                RegisterTheme(Icon, "ImageColor3", "SchemeColor")

                ButtonFrame.MouseButton1Click:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = ThemeManager.Current.SchemeColor}, 0.1)
                    callback()
                    wait(0.1)
                    Tween(ButtonFrame, {BackgroundColor3 = ThemeManager.Current.ElementColor}, 0.1)
                end)
            end

            function Section:NewToggle(text, callback)
                callback = callback or function() end
                local toggled = false
                local Toggle = {}

                local ToggleFrame = Create("TextButton", {
                    Parent = SectionContainer,
                    BackgroundColor3 = ThemeManager.Current.ElementColor,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. text,
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ToggleFrame})
                RegisterTheme(ToggleFrame, "BackgroundColor3", "ElementColor")
                RegisterTheme(ToggleFrame, "TextColor3", "TextColor")

                local Checkbox = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = ThemeManager.Current.Background,
                    Position = UDim2.new(1, -25, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Checkbox})
                RegisterTheme(Checkbox, "BackgroundColor3", "Background")

                local Checkmark = Create("ImageLabel", {
                    Parent = Checkbox,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = "rbxassetid://3926305904",
                    ImageRectOffset = Vector2.new(644, 204),
                    ImageRectSize = Vector2.new(36, 36),
                    ImageColor3 = ThemeManager.Current.SchemeColor,
                    ImageTransparency = 1
                })
                RegisterTheme(Checkmark, "ImageColor3", "SchemeColor")

                local function UpdateState()
                    if toggled then
                        Tween(Checkmark, {ImageTransparency = 0}, 0.2)
                    else
                        Tween(Checkmark, {ImageTransparency = 1}, 0.2)
                    end
                    callback(toggled)
                end

                ToggleFrame.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    UpdateState()
                end)

                function Toggle:Update(state)
                    toggled = state
                    UpdateState()
                end
                return Toggle
            end

            function Section:NewSlider(text, min, max, default, callback)
                callback = callback or function() end
                default = default or min
                local dragging = false
                
                local SliderFrame = Create("Frame", {
                    Parent = SectionContainer,
                    BackgroundColor3 = ThemeManager.Current.ElementColor,
                    Size = UDim2.new(1, 0, 0, 45)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SliderFrame})
                RegisterTheme(SliderFrame, "BackgroundColor3", "ElementColor")

                local Label = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                RegisterTheme(Label, "TextColor3", "TextColor")

                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 5),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(default),
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                RegisterTheme(ValueLabel, "TextColor3", "TextColor")

                local SliderBar = Create("TextButton", {
                    Parent = SliderFrame,
                    BackgroundColor3 = ThemeManager.Current.Background,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 6),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBar})
                RegisterTheme(SliderBar, "BackgroundColor3", "Background")

                local Fill = Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = ThemeManager.Current.SchemeColor,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})
                RegisterTheme(Fill, "BackgroundColor3", "SchemeColor")

                local function Update(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(((pos * (max - min)) + min))
                    
                    Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                    ValueLabel.Text = tostring(val)
                    callback(val)
                end

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)
            end

            function Section:NewDropdown(text, options, callback)
                callback = callback or function() end
                local isOpen = false
                local Dropdown = {}

                local DropdownFrame = Create("Frame", {
                    Parent = SectionContainer,
                    BackgroundColor3 = ThemeManager.Current.ElementColor,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = true
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropdownFrame})
                RegisterTheme(DropdownFrame, "BackgroundColor3", "ElementColor")

                local TopButton = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. text,
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                RegisterTheme(TopButton, "TextColor3", "TextColor")

                local Icon = Create("ImageLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0.2, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    Image = "rbxassetid://3926305904",
                    ImageRectOffset = Vector2.new(644, 364),
                    ImageRectSize = Vector2.new(36, 36),
                    ImageColor3 = ThemeManager.Current.SchemeColor
                })
                RegisterTheme(Icon, "ImageColor3", "SchemeColor")

                local ListLayout = Create("UIListLayout", {
                    Parent = DropdownFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })

                local function Refresh()
                    for _, child in pairs(DropdownFrame:GetChildren()) do
                        if child:IsA("TextButton") and child ~= TopButton then
                            child:Destroy()
                        end
                    end
                    for _, option in pairs(options) do
                        local OptionBtn = Create("TextButton", {
                            Parent = DropdownFrame,
                            BackgroundColor3 = ThemeManager.Current.Background,
                            Size = UDim2.new(1, 0, 0, 30),
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = ThemeManager.Current.TextColor,
                            TextSize = 14
                        })
                        RegisterTheme(OptionBtn, "BackgroundColor3", "Background")
                        RegisterTheme(OptionBtn, "TextColor3", "TextColor")
                        
                        OptionBtn.MouseButton1Click:Connect(function()
                            TopButton.Text = "  " .. option
                            isOpen = false
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
                            Tween(Icon, {Rotation = 0}, 0.2)
                            callback(option)
                        end)
                    end
                end

                TopButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        Refresh()
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 5)}, 0.2)
                        Tween(Icon, {Rotation = 180}, 0.2)
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
                        Tween(Icon, {Rotation = 0}, 0.2)
                    end
                end)

                function Dropdown:Refresh(newOptions)
                    options = newOptions
                    if isOpen then Refresh() end
                end
                return Dropdown
            end

            function Section:NewColorPicker(text, default, callback)
                callback = callback or function() end
                default = default or Color3.fromRGB(255, 255, 255)
                local isOpen = false
                
                local PickerFrame = Create("Frame", {
                    Parent = SectionContainer,
                    BackgroundColor3 = ThemeManager.Current.ElementColor,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = true
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = PickerFrame})
                RegisterTheme(PickerFrame, "BackgroundColor3", "ElementColor")
                
                local TopButton = Create("TextButton", {
                    Parent = PickerFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. text,
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                RegisterTheme(TopButton, "TextColor3", "TextColor")

                local ColorPreview = Create("Frame", {
                    Parent = TopButton,
                    BackgroundColor3 = default,
                    Position = UDim2.new(1, -35, 0.2, 0),
                    Size = UDim2.new(0, 25, 0, 20)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ColorPreview})
                
                local PickerContainer = Create("Frame", {
                    Parent = PickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 35),
                    Size = UDim2.new(1, 0, 0, 100)
                })
                
                local HSVImg = Create("ImageButton", {
                    Parent = PickerContainer,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(0.7, 0, 0, 80),
                    Image = "rbxassetid://4155801252"
                })
                
                local HueImg = Create("ImageButton", {
                    Parent = PickerContainer,
                    Position = UDim2.new(0.75, 0, 0, 10),
                    Size = UDim2.new(0.2, 0, 0, 80),
                    Image = "rbxassetid://4155801252"
                })
                Create("UIGradient", {Parent = HueImg, Rotation = 90, Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                }})

                local h, s, v = default:ToHSV()
                local color = default
                
                TopButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 140)}, 0.2)
                    else
                        Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
                    end
                end)
                
                local function UpdateColor()
                    color = Color3.fromHSV(h, s, v)
                    ColorPreview.BackgroundColor3 = color
                    HSVImg.ImageColor3 = Color3.fromHSV(h, 1, 1)
                    callback(color)
                end
                
                local function UpdateHSV(input)
                    local pos = math.clamp((input.Position.X - HSVImg.AbsolutePosition.X) / HSVImg.AbsoluteSize.X, 0, 1)
                    local posY = math.clamp((input.Position.Y - HSVImg.AbsolutePosition.Y) / HSVImg.AbsoluteSize.Y, 0, 1)
                    s = pos
                    v = 1 - posY
                    UpdateColor()
                end
                
                local function UpdateHue(input)
                    local posY = math.clamp((input.Position.Y - HueImg.AbsolutePosition.Y) / HueImg.AbsoluteSize.Y, 0, 1)
                    h = 1 - posY
                    UpdateColor()
                end
                
                local draggingHSV, draggingHue = false, false
                
                HSVImg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHSV = true; UpdateHSV(input) end end)
                HueImg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true; UpdateHue(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHSV = false; draggingHue = false end end)
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingHSV then UpdateHSV(input) end
                        if draggingHue then UpdateHue(input) end
                    end
                end)
            end

            function Section:NewTextBox(text, placeholder, callback)
                callback = callback or function() end
                local TextBoxFrame = Create("Frame", {
                    Parent = SectionContainer,
                    BackgroundColor3 = ThemeManager.Current.ElementColor,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = TextBoxFrame})
                RegisterTheme(TextBoxFrame, "BackgroundColor3", "ElementColor")

                local Label = Create("TextLabel", {
                    Parent = TextBoxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                RegisterTheme(Label, "TextColor3", "TextColor")

                local Input = Create("TextBox", {
                    Parent = TextBoxFrame,
                    BackgroundColor3 = ThemeManager.Current.Background,
                    Position = UDim2.new(0.6, 0, 0.15, 0),
                    Size = UDim2.new(0.38, 0, 0.7, 0),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = placeholder or "Type...",
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Input})
                RegisterTheme(Input, "BackgroundColor3", "Background")
                RegisterTheme(Input, "TextColor3", "TextColor")

                Input.FocusLost:Connect(function(enter)
                    callback(Input.Text)
                end)
            end

            function Section:NewKeybind(text, default, callback)
                callback = callback or function() end
                local key = default or Enum.KeyCode.RightControl
                local waiting = false
                
                local KeybindFrame = Create("TextButton", {
                    Parent = SectionContainer,
                    BackgroundColor3 = ThemeManager.Current.ElementColor,
                    Size = UDim2.new(1, 0, 0, 32),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = KeybindFrame})
                RegisterTheme(KeybindFrame, "BackgroundColor3", "ElementColor")
                
                local Label = Create("TextLabel", {
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ThemeManager.Current.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                RegisterTheme(Label, "TextColor3", "TextColor")
                
                local KeyLabel = Create("TextLabel", {
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.6, 0, 0, 0),
                    Size = UDim2.new(0.35, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = key.Name,
                    TextColor3 = ThemeManager.Current.SchemeColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                RegisterTheme(KeyLabel, "TextColor3", "SchemeColor")
                
                KeybindFrame.MouseButton1Click:Connect(function()
                    waiting = true
                    KeyLabel.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, gp)
                    if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        KeyLabel.Text = key.Name
                        waiting = false
                    elseif not waiting and not gp and input.KeyCode == key then
                        callback()
                    end
                end)
            end

            return Section
        end
        return Tab
    end
    return Tabs
end

return Library
