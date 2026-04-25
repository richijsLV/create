# Eldora UI

Eldora UI is a polished Roblox UI API built for real-world script usage. The library is written in pure Luau so it stays executor-friendly, while the documentation site is built in TypeScript for a modern GitHub-ready project experience.

## Highlights

- Single-file library for easy `loadstring(game:HttpGet(...))()` usage
- Smooth tweens, hover states, glow layers, collapsible sections, and notifications
- Clean Rayfield-style API with more theme control and richer components
- Theme presets plus full custom theme overrides
- State export/import helpers for config sharing
- Tabs, sections, buttons, toggles, sliders, dropdowns, inputs, paragraphs, labels, keybinds, and color pickers
- Detailed docs site with installation, API reference, theming notes, and live snippets

## Quick Start

```lua
local EldoraUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/eldora-ui/main/dist/EldoraUI.lua"))()

local Window = EldoraUI:CreateWindow({
    Name = "Eldora UI Demo",
    Subtitle = "High polish executor-ready UI",
    Theme = "Midnight",
    ToggleKeybind = Enum.KeyCode.RightControl
})

local Main = Window:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://6031071053"
})

local Combat = Main:CreateSection({
    Name = "Combat"
})

Combat:CreateToggle({
    Name = "Auto Farm",
    Description = "Continuously attack the nearest valid target.",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(value)
        print("Auto Farm:", value)
    end
})

Combat:CreateSlider({
    Name = "Attack Radius",
    Range = {5, 120},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 30,
    Flag = "AttackRadius",
    Callback = function(value)
        print("Radius:", value)
    end
})

Window:Notify({
    Title = "Library Loaded",
    Content = "Eldora UI is ready to use.",
    Duration = 4
})
```

## Project Layout

- `src/EldoraUI.lua`: source version of the Roblox UI library
- `dist/EldoraUI.lua`: release-friendly single-file version for GitHub/CDN usage
- `examples/showcase.lua`: full example script
- `docs/`: TypeScript documentation site

## Docs Site

Install dependencies and run the docs locally:

```bash
npm install
npm run docs:dev
```

Build the static docs site:

```bash
npm run docs:build
```

## Publishing Tips

1. Create a GitHub repository and push this folder.
2. Use the raw URL of `dist/EldoraUI.lua` in your script examples.
3. Publish the docs site using GitHub Pages, Vercel, Netlify, or Cloudflare Pages.
4. Keep the `dist/EldoraUI.lua` file as the stable entrypoint users load from scripts.

