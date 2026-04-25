export type Feature = {
  title: string;
  body: string;
};

export type InstallMethod = {
  title: string;
  description: string;
  code: string;
};

export type ApiMethod = {
  name: string;
  signature: string;
  description: string;
  notes?: string[];
};

export type ApiSection = {
  id: string;
  title: string;
  description: string;
  methods: ApiMethod[];
};

export const heroSnippet = `local EldoraUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/eldora-ui/main/dist/EldoraUI.lua"))()

local Window = EldoraUI:CreateWindow({
    Name = "Eldora UI Demo",
    Subtitle = "Smooth, themeable, and executor-friendly",
    Theme = "Midnight",
    ToggleKeybind = Enum.KeyCode.RightControl
})

local Main = Window:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://6031071053"
})

local Section = Main:CreateSection({
    Name = "Automation",
    Description = "Core controls for your script."
})

Section:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(value)
        print("Auto Farm:", value)
    end
})`;

export const features: Feature[] = [
  {
    title: "Executor-Friendly",
    body: "The shipping entrypoint is a single Luau file that can be loaded directly with game:HttpGet and loadstring, so it fits the script ecosystem people already use."
  },
  {
    title: "Rayfield-Like Flow, Cleaner Architecture",
    body: "The API feels familiar for users coming from Rayfield, but the layout, theme system, state handling, and visual depth are designed to feel more intentional and easier to customize."
  },
  {
    title: "High Polish Motion",
    body: "Buttons, toggles, active tabs, color feedback, notifications, and window visibility all animate with smooth tweens to make the interface feel premium instead of static."
  },
  {
    title: "Config and Theme Ready",
    body: "Flagged controls are tracked in one state table, exportable to JSON and importable later, which makes configuration systems straightforward to build on top of."
  }
];

export const installMethods: InstallMethod[] = [
  {
    title: "Direct GitHub Raw Load",
    description: "The most common executor setup. Point users to the single-file distribution inside dist.",
    code: `local EldoraUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/eldora-ui/main/dist/EldoraUI.lua"))()`
  },
  {
    title: "Bundled In Your Script Hub",
    description: "Paste the distribution file directly into your project or use a local module wrapper if your environment supports it.",
    code: `local EldoraUI = loadstring(readfile("EldoraUI.lua"))()`
  },
  {
    title: "Theme Override On Creation",
    description: "Pass a theme name or a full theme table to CreateWindow when you want custom branding from the start.",
    code: `local Window = EldoraUI:CreateWindow({
    Name = "Custom Hub",
    Theme = {
        Accent = Color3.fromRGB(255, 149, 64),
        AccentSoft = Color3.fromRGB(75, 43, 16),
        Surface = Color3.fromRGB(24, 18, 14)
    }
})`
  }
];

export const themeTokens = [
  "Background",
  "Surface",
  "SurfaceAlt",
  "SurfaceRaised",
  "Accent",
  "AccentMuted",
  "AccentSoft",
  "Text",
  "TextMuted",
  "Outline",
  "Divider",
  "Success",
  "Warning",
  "Danger",
  "Shadow"
];

export const apiSections: ApiSection[] = [
  {
    id: "library",
    title: "Library",
    description: "Entry-level methods available on the object returned by loadstring(... )().",
    methods: [
      {
        name: "RegisterTheme",
        signature: `EldoraUI:RegisterTheme(name, themeTable)`,
        description: "Registers a reusable theme preset. Missing color tokens fall back to the default Eldora palette.",
        notes: [
          "Use this before CreateWindow if you want to reference the theme by name.",
          "themeTable can be partial. Only the keys you provide are overridden."
        ]
      },
      {
        name: "CreateWindow",
        signature: `local Window = EldoraUI:CreateWindow(options)`,
        description: "Creates the main UI shell. This is the starting point for tabs, sections, notifications, theming, and state management.",
        notes: [
          "Recommended fields: Name, Subtitle, Theme, ToggleKeybind.",
          "Theme accepts either a preset name like Midnight or a custom table."
        ]
      }
    ]
  },
  {
    id: "window",
    title: "Window",
    description: "Main methods used after creating the UI shell.",
    methods: [
      {
        name: "CreateTab",
        signature: `local Tab = Window:CreateTab({ Name, Description, Icon })`,
        description: "Adds a sidebar tab and a matching content page."
      },
      {
        name: "Notify",
        signature: `Window:Notify({ Title, Content, Duration })`,
        description: "Creates a polished bottom-right notification card with progress timing."
      },
      {
        name: "SetTheme",
        signature: `Window:SetTheme(themeNameOrTable)`,
        description: "Swaps the current interface theme on the fly. Accepts either a registered name or a raw theme table."
      },
      {
        name: "SetToggleKey",
        signature: `Window:SetToggleKey(Enum.KeyCode.RightControl)`,
        description: "Changes the global window visibility keybind."
      },
      {
        name: "ExportState",
        signature: `local json = Window:ExportState()`,
        description: "Serializes every flagged controller value to JSON so you can save or share configs."
      },
      {
        name: "ImportState",
        signature: `Window:ImportState(jsonOrTable, fireCallbacks)`,
        description: "Restores controller state from JSON or a Lua table. Pass true for fireCallbacks if your script should re-run side effects during load."
      },
      {
        name: "GetController",
        signature: `local controller = Window:GetController("FlagName")`,
        description: "Returns the controller associated with a flag so you can update it later from elsewhere in your script."
      },
      {
        name: "GetState",
        signature: `local state = Window:GetState()`,
        description: "Returns the live state table tracked by flagged controls."
      },
      {
        name: "Destroy",
        signature: `Window:Destroy()`,
        description: "Disconnects listeners and removes the UI completely."
      }
    ]
  },
  {
    id: "tab-section",
    title: "Tabs And Sections",
    description: "Layout building blocks used to organize controls cleanly.",
    methods: [
      {
        name: "CreateSection",
        signature: `local Section = Tab:CreateSection({ Name, Description, Collapsed })`,
        description: "Creates a rounded card section that can be collapsed by clicking its header."
      }
    ]
  },
  {
    id: "controls",
    title: "Controls",
    description: "Interactive components exposed by section objects.",
    methods: [
      {
        name: "CreateButton",
        signature: `Section:CreateButton({ Name, Description, ButtonText, Callback })`,
        description: "Adds a one-click action control. It returns a small helper with Press() if you want to trigger it manually."
      },
      {
        name: "CreateToggle",
        signature: `local toggle = Section:CreateToggle({ Name, Description, CurrentValue, Flag, Callback })`,
        description: "Creates an animated boolean switch and returns a controller with Set, Get, OnChanged, and Destroy."
      },
      {
        name: "CreateSlider",
        signature: `local slider = Section:CreateSlider({ Name, Range, Increment, CurrentValue, Suffix, Flag, Callback })`,
        description: "Creates a draggable numeric slider with automatic value rounding."
      },
      {
        name: "CreateDropdown",
        signature: `local dropdown = Section:CreateDropdown({ Name, Options, CurrentValue, Multi, Flag, Callback })`,
        description: "Creates a single-select or multi-select dropdown. Returned helpers include Get, Set, Refresh, OnChanged, and Destroy."
      },
      {
        name: "CreateInput",
        signature: `local input = Section:CreateInput({ Name, PlaceholderText, CurrentValue, Flag, Callback })`,
        description: "Creates a text box for names, IDs, commands, or other user text."
      },
      {
        name: "CreateParagraph",
        signature: `local paragraph = Section:CreateParagraph({ Name, Content })`,
        description: "Creates a wrapped text block for instructions, status, or contextual explanations."
      },
      {
        name: "CreateLabel",
        signature: `local label = Section:CreateLabel({ Text })`,
        description: "Creates a compact highlighted message card for short notes or guidance."
      },
      {
        name: "CreateKeybind",
        signature: `local keybind = Section:CreateKeybind({ Name, CurrentKeybind, Flag, Callback })`,
        description: "Lets the user choose a key and invokes your callback whenever that key is pressed."
      },
      {
        name: "CreateColorPicker",
        signature: `local picker = Section:CreateColorPicker({ Name, CurrentValue, Flag, Callback })`,
        description: "Creates a built-in color picker with saturation, brightness, and hue controls."
      }
    ]
  },
  {
    id: "controllers",
    title: "Controllers",
    description: "Reusable objects returned by most interactive controls.",
    methods: [
      {
        name: "Set",
        signature: `controller:Set(value, silent)`,
        description: "Updates the control and syncs both UI and internal state. Pass silent as true to suppress the original callback."
      },
      {
        name: "Get",
        signature: `local value = controller:Get()`,
        description: "Returns the current value."
      },
      {
        name: "OnChanged",
        signature: `controller:OnChanged(function(value) ... end)`,
        description: "Subscribes to value changes without replacing the control's main callback."
      },
      {
        name: "Destroy",
        signature: `controller:Destroy()`,
        description: "Cleans up the internal signal for that controller."
      }
    ]
  }
];

export const advancedPatterns = [
  {
    title: "Flag Everything Important",
    body: "Any control with a Flag participates in the live state table and state export/import helpers. If a value matters to your script, give it a unique flag."
  },
  {
    title: "Use GetController For Cross-Script Updates",
    body: "If another thread in your script needs to update UI state, fetch the control by flag and call controller:Set(newValue, true) so the UI stays synced without re-running heavy callbacks."
  },
  {
    title: "Keep The Library Pure Luau",
    body: "The documentation site uses TypeScript because it is excellent for a polished web experience, but the actual Roblox library stays pure Luau to maximize compatibility with executor environments."
  }
];
