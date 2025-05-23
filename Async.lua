local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()
local Window = Library:CreateWindow("Async", Vector2.new(492, 598), Enum.KeyCode.RightControl)

-- Main Aiming Tab
local AimingTab = Window:CreateTab("Combat")
local CombatSection = AimingTab:CreateSector("Combat Settings", "left")

-- Original functionality with improvements
local AutoShootToggle = CombatSection:AddToggle("Crossbow silent aim", false, function(state)
    getgenv().autoShoot = state
end)

CombatSection:AddSlider("Targeting Range", 10, 50, 500, 1, function(value)
    getgenv().targetRange = value
end)

CombatSection:AddDropdown("Target Priority", {"Closest", "Lowest Health", "Highest Threat"}, "Closest", false, function(priority)
    getgenv().targetPriority = priority
end)

-- Visual Effects Section
local VisualSection = AimingTab:CreateSector("Visual Effects", "right")

local TracerToggle = VisualSection:AddToggle("Enable Bullet Tracers", true, function(state)
    getgenv().showTracers = state
end)

local TracerColor = TracerToggle:AddColorpicker(Color3.fromRGB(75, 0, 130), function(color)
    getgenv().tracerColor = color
end)

VisualSection:AddSlider("Tracer Transparency", 0, 30, 100, 1, function(value)
    getgenv().tracerTransparency = value/100
end)

local HitMarkerToggle = VisualSection:AddToggle("Hit Markers", true, function(state)
    getgenv().showHitMarkers = state
end)

-- Sound Settings Section
local SoundSection = AimingTab:CreateSector("Sound Settings", "left")

SoundSection:AddToggle("Enable Hit Sounds", true, function(state)
    getgenv().playHitSounds = state
end)

SoundSection:AddDropdown("Hit Sound", {"Default", "Headshot", "Squelch", "Custom"}, "Default", false, function(sound)
    getgenv().hitSound = sound
end)

SoundSection:AddSlider("Sound Volume", 0, 80, 100, 1, function(value)
    getgenv().soundVolume = value/100
end)

-- Advanced Settings Tab
local AdvancedTab = Window:CreateTab("Advanced")
local PerformanceSection = AdvancedTab:CreateSector("Performance", "left")

PerformanceSection:AddToggle("Optimize Performance", false, function(state)
    getgenv().performanceMode = state
end)

PerformanceSection:AddSlider("Update Rate (Hz)", 1, 60, 1000, 1, function(value)
    getgenv().updateRate = 1/value
end)

-- Config System
AimingTab:CreateConfigSystem("right")

-- Main functionality
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetworkEvent = ReplicatedStorage:WaitForChild("NetworkEvents"):WaitForChild("RemoteEvent")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function getRandomColor()
    return Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
end

local function playHitSound()
    if not getgenv().playHitSounds then return end
    
    local soundId = "rbxassetid://160432334" -- Default
    if getgenv().hitSound == "Headshot" then
        soundId = "rbxassetid://138080939"
    elseif getgenv().hitSound == "Squelch" then
        soundId = "rbxassetid://376943451"
    end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = getgenv().soundVolume or 0.8
    sound.PlaybackSpeed = 1
    sound.Parent = workspace
    sound:Play()
    task.delay(2, function() sound:Destroy() end)
end

local function createHitMarker(position)
    if not getgenv().showHitMarkers then return end
    
    local marker = Instance.new("Part")
    marker.Size = Vector3.new(1, 1, 1)
    marker.Position = position
    marker.Anchored = true
    marker.CanCollide = false
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.new(1, 0, 0)
    marker.Transparency = 0.5
    marker.Shape = Enum.PartType.Ball
    marker.Parent = workspace
    
    task.delay(0.3, function() marker:Destroy() end)
end

local function findTarget()
    local closestTarget = nil
    local closestDistance = getgenv().targetRange or math.huge
    local targetEnemy = false
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local distance = (localPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestTarget = player
                    targetEnemy = (player.Team ~= localPlayer.Team)
                end
            end
        end
    end
    
    return closestTarget, targetEnemy
end

local function fireAtTarget(target)
    local args = {"GUN_DAMAGE", game:GetService("Players"):WaitForChild(target.Name).Character}
    NetworkEvent:FireServer(unpack(args))
    
    playHitSound()
    createHitMarker(target.Character.HumanoidRootPart.Position)
    
    if getgenv().showTracers then
        local distance = (localPlayer.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
        local rayPart = Instance.new("Part")
        rayPart.Size = Vector3.new(0.2, 0.2, distance)
        rayPart.Position = localPlayer.Character.HumanoidRootPart.Position +
                         (target.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position) / 2
        rayPart.Anchored = true
        rayPart.CanCollide = false
        rayPart.Material = Enum.Material.Neon
        rayPart.Color = getgenv().tracerColor or getRandomColor()
        rayPart.Transparency = getgenv().tracerTransparency or 0.3
        rayPart.CFrame = CFrame.lookAt(rayPart.Position, target.Character.HumanoidRootPart.Position)
        rayPart.Parent = workspace
        
        task.delay(0.5, function() rayPart:Destroy() end)
    end
end

-- Main loop
RunService.Heartbeat:Connect(function()
    if not getgenv().autoShoot then return end
    
    local target, isEnemy = findTarget()
    if target and isEnemy then
        fireAtTarget(target)
    end
    
    if getgenv().performanceMode then
        task.wait(getgenv().updateRate or 0.1)
    else
        task.wait()
    end
end)
   
