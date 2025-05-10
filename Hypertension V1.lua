local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/TynaRan/Ferocity/refs/heads/main/UILib.lua"))()
UILib:Notify("HyperStrike Loaded", 3)
UILib:CreateWindow("HyperStrike")

local HitboxTab = UILib.Window:CreateTab("Hitbox Control")
local ESPTab = UILib.Window:CreateTab("ESP Drawing")
local ConfigTab = UILib.Window:CreateTab("Config Management")

local hitboxEnabled = false
local hitboxSize = 2
local hitboxTransparency = 0.4

local espEnabled = false
local espColor = Color3.new(1, 0, 0)
local espThickness = 2
local espHollow = false
local espFilled = false

local configName = "defaultConfig.json"
local localPlayer = game:GetService("Players").LocalPlayer

local function updateHitbox(state)
    hitboxEnabled = state
    while hitboxEnabled do
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                root.Transparency = hitboxTransparency
            end
        end
        task.wait(0.1)
    end
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            root.Size = Vector3.new(2, 1, 1)
            root.Transparency = 0
        end
    end
end

local function updateESP(state)
    espEnabled = state
    while espEnabled do
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = player.Character
                highlight.FillColor = espColor
                highlight.FillTransparency = espHollow and 0.7 or 0
                highlight.OutlineTransparency = 0
                highlight.Parent = player.Character

                local line = Drawing.new("Line")
                line.From = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                line.To = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                line.Color = espColor
                line.Thickness = espThickness
                line.Visible = true
            end
        end
        task.wait(0.1)
    end
end

local function saveConfig()
    local configData = {
        hitboxSize = hitboxSize,
        hitboxTransparency = hitboxTransparency,
        espThickness = espThickness,
        espColor = { espColor.R, espColor.G, espColor.B },
        espHollow = espHollow,
        espFilled = espFilled
    }
    writefile(configName, game:GetService("HttpService"):JSONEncode(configData))
end

local function loadConfig()
    if isfile(configName) then
        local configData = game:GetService("HttpService"):JSONDecode(readfile(configName))
        hitboxSize = configData.hitboxSize
        hitboxTransparency = configData.hitboxTransparency
        espThickness = configData.espThickness
        espColor = Color3.new(unpack(configData.espColor))
        espHollow = configData.espHollow
        espFilled = configData.espFilled
    end
end

HitboxTab:CreateCheckbox("Enable Hitbox", hitboxEnabled, function(state)
    updateHitbox(state)
end)

ESPTab:CreateCheckbox("Enable ESP", espEnabled, function(state)
    updateESP(state)
end)

ESPTab:CreateCheckbox("Filled ESP", espFilled, function(state)
    espFilled = state
end)

ConfigTab:CreateInput("Config Name", "Enter filename", function(value)
    configName = value .. ".json"
end)

ConfigTab:CreateButton("Save Config", function()
    saveConfig()
end)

ConfigTab:CreateButton("Load Config", function()
    loadConfig()
end)

loadConfig()
