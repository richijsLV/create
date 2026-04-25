local EldoraUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/eldora-ui/main/dist/EldoraUI.lua"))()

local Window = EldoraUI:CreateWindow({
    Name = "Eldora UI Showcase",
    Subtitle = "Executor-friendly, polished, and themeable",
    Theme = "Midnight",
    ToggleKeybind = Enum.KeyCode.RightControl,
})

local MainTab = Window:CreateTab({
    Name = "Main",
    Description = "The core controls you will use the most.",
    Icon = "rbxassetid://6031071053",
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Description = "Themes, keybinds, configs, and quality-of-life tools.",
    Icon = "rbxassetid://6031280882",
})

local CombatSection = MainTab:CreateSection({
    Name = "Combat Automation",
    Description = "Example toggles and sliders for a farming script.",
})

local FarmingEnabled = CombatSection:CreateToggle({
    Name = "Auto Farm",
    Description = "Continuously target and attack the closest valid enemy.",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(value)
        print("Auto Farm:", value)
    end,
})

CombatSection:CreateSlider({
    Name = "Farm Radius",
    Description = "Distance from the player used for target searching.",
    Range = {5, 250},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 50,
    Flag = "FarmRadius",
    Callback = function(value)
        print("Farm Radius:", value)
    end,
})

CombatSection:CreateDropdown({
    Name = "Target Priority",
    Description = "Choose which enemy selection rule to use.",
    Options = {"Nearest", "Lowest Health", "Highest Value", "Bosses First"},
    CurrentValue = "Nearest",
    Flag = "TargetPriority",
    Callback = function(value)
        print("Target Priority:", value)
    end,
})

CombatSection:CreateButton({
    Name = "Force Clear Targets",
    Description = "Resets cached NPC targets and restarts the finder loop.",
    ButtonText = "Clear",
    Callback = function()
        Window:Notify({
            Title = "Target Cache Reset",
            Content = "All tracked targets were cleared successfully.",
            Duration = 3,
        })
    end,
})

local VisualSection = MainTab:CreateSection({
    Name = "Visuals",
    Description = "Color and text controls that show the API range.",
})

VisualSection:CreateColorPicker({
    Name = "ESP Accent",
    Description = "Primary highlight color used by your overlays and tracers.",
    CurrentValue = Color3.fromRGB(90, 167, 255),
    Flag = "ESPAccent",
    Callback = function(value)
        print("ESP Accent:", value)
    end,
})

VisualSection:CreateInput({
    Name = "Watermark Text",
    Description = "Text displayed in your own overlay or info widgets.",
    PlaceholderText = "Script loaded successfully",
    CurrentValue = "Eldora UI running",
    Flag = "WatermarkText",
    Callback = function(value)
        print("Watermark Text:", value)
    end,
})

VisualSection:CreateParagraph({
    Name = "Why This Layout Works",
    Content = "The library keeps a Rayfield-style flow while adding more visual depth, cleaner spacing, stronger theme control, and a state system that is easier to integrate into large scripts.",
})

local ConfigSection = SettingsTab:CreateSection({
    Name = "Configuration",
    Description = "Theme switching and state import or export helpers.",
})

ConfigSection:CreateDropdown({
    Name = "Theme Preset",
    Description = "Swap the entire visual palette at runtime.",
    Options = {"Midnight", "Ember", "Glacier"},
    CurrentValue = "Midnight",
    Callback = function(value)
        Window:SetTheme(value)
        Window:Notify({
            Title = "Theme Updated",
            Content = "The interface theme changed to " .. value .. ".",
            Duration = 3,
        })
    end,
})

ConfigSection:CreateKeybind({
    Name = "Panic Keybind",
    Description = "Run your own safety or hide routine when pressed.",
    CurrentKeybind = Enum.KeyCode.End,
    Flag = "PanicKey",
    Callback = function()
        print("Panic key pressed")
    end,
})

ConfigSection:CreateButton({
    Name = "Export Current State",
    Description = "Serializes every flagged control into JSON.",
    ButtonText = "Export",
    Callback = function()
        local exported = Window:ExportState()
        print("Exported State:", exported)

        Window:Notify({
            Title = "State Exported",
            Content = "The current flagged control values were printed to the console.",
            Duration = 4,
        })
    end,
})

ConfigSection:CreateLabel({
    Text = "Tip: you can restore saved settings later with Window:ImportState(savedJson).",
})

Window:Notify({
    Title = "Eldora UI Loaded",
    Content = "The showcase window is ready. Press RightControl to hide or show it.",
    Duration = 4,
})

print("Auto Farm Controller:", FarmingEnabled:Get())
