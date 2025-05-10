local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/TynaRan/Ferocity/refs/heads/main/UILib.lua"))()
UILib:Notify("HyperStrike Loaded", 3)
UILib:CreateWindow("HyperStrike")

local HitboxTab = UILib.Window:CreateTab("Hitbox Control")
local ESPTab = UILib.Window:CreateTab("ESP Drawing")
local ConfigTab = UILib.Window:CreateTab("Config Management")

local hitboxSize = 2
local hitboxTransparency = 0.4
local hitboxEnabled = false

local espEnabled = false
local espColor = Color3.new(1, 0, 0)
local espThickness = 2
local espHollow = false
local espFilled = false

local configName = "defaultConfig.json"
local localPlayer = game:GetService("Players").LocalPlayer

-- Function: Apply hitbox settings to other players
local function applyHitbox()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            root.Transparency = hitboxTransparency
        end
    end
end

-- Function: Reset hitbox to default for other players
local function resetHitbox()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            root.Size = Vector3.new(2, 1, 1)
            root.Transparency = 0
        end
    end
end

-- Function: Apply ESP settings
local function applyESP()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local box = Drawing.new(espFilled and "Square" or "Line")
            box.Position = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            box.Color = espColor
            box.Thickness = espThickness
            box.Filled = espFilled
            box.Visible = true
        end
    end
end

-- Function: Save config to file
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

-- Function: Load config from file
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

HitboxTab:CreateInput("Hitbox Size", "Enter size", function(value)
    local num = tonumber(value)
    if num then
        hitboxSize = num
    end
end)

HitboxTab:CreateInput("Hitbox Transparency", "Enter transparency (0-1)", function(value)
    local num = tonumber(value)
    if num and num >= 0 and num <= 1 then
        hitboxTransparency = num
    end
end)

HitboxTab:CreateCheckbox("Toggle Hitbox", function()
    hitboxEnabled = not hitboxEnabled
    if hitboxEnabled then
        while hitboxEnabled do
            applyHitbox()
            task.wait(0.1)
        end
    else
        resetHitbox()
    end
end)

ESPTab:CreateInput("ESP Thickness", "Enter thickness", function(value)
    local num = tonumber(value)
    if num then
        espThickness = num
    end
end)

ESPTab:CreateInput("ESP Color (RGB format)", "Enter R,G,B", function(value)
    local rgb = {}
    for val in string.gmatch(value, "%d+") do
        table.insert(rgb, tonumber(val) / 255)
    end
    if #rgb == 3 then
        espColor = Color3.new(rgb[1], rgb[2], rgb[3])
    end
end)

ESPTab:CreateCheckbox("Toggle ESP", function()
    espEnabled = not espEnabled
    if espEnabled then
        while espEnabled do
            applyESP()
            task.wait(0.1)
        end
    end
end)

ESPTab:CreateButton("Toggle Hollow ESP", function()
    espHollow = not espHollow
end)

ESPTab:CreateButton("Toggle Filled ESP", function()
    espFilled = not espFilled
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
