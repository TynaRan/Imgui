local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()
local Window = Library:CreateWindow("Pelo A", Vector2.new(492, 598), Enum.KeyCode.RightControl)
local MainTab = Window:CreateTab("Main")

-- Combat Section
local CombatSection = MainTab:CreateSector("Combat", "left")

-- Melee Remote
local MeleeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Melee"):WaitForChild("Damage")
local ZombieRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ZombieRelated"):WaitForChild("PlayerAttack")

-- Toggles
CombatSection:AddToggle("Crossbow silent aim", false, function(state)
    _G.SilentAim = state
end)

CombatSection:AddToggle("Auto tool", false, function(state)
    _G.AutoZombieSword = state
    if state then
        spawn(function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            while _G.AutoZombieSword and task.wait() do
                local t = c:FindFirstChildOfClass("Tool")
                if t then pcall(t.Activate, t) end
            end
        end)
    end
end)

CombatSection:AddToggle("Auto Zombie Sword", false, function(state)
    _G.AutoTool = state
    if state then
        spawn(function()
            local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
            local localHumanoid = localCharacter:WaitForChild("Humanoid")
            
            while _G.AutoTool do
                if localHumanoid and localHumanoid.Health > 0 then
                    local closestDistance = math.huge
                    local closestArgs = nil

                    -- Player targeting
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= localPlayer and player.Team ~= localPlayer.Team then
                            local character = player.Character
                            if character then
                                local humanoid = character:FindFirstChild("Humanoid")
                                local rootPart = character:FindFirstChild("HumanoidRootPart")
                                if humanoid and humanoid.Health > 0 and rootPart then
                                    local distance = (localCharacter.HumanoidRootPart.Position - rootPart.Position).Magnitude
                                    if distance < closestDistance then
                                        closestDistance = distance
                                        closestArgs = {player.Character.HumanoidRootPart}
                                    end
                                end
                            end
                        end
                    end

                    -- Zombie targeting
                    if not closestArgs then
                        local npcFolder = Workspace:WaitForChild("LivingThings")
                        if npcFolder then
                            local zombieFolder = npcFolder:WaitForChild("ZombieNpc")
                            if zombieFolder then
                                for _, npc in pairs(zombieFolder:GetChildren()) do
                                    local humanoid = npc:FindFirstChild("Humanoid")
                                    local leftArm = npc:FindFirstChild("Left Arm")
                                    if humanoid and humanoid.Health > 0 and leftArm then
                                        local distance = (localCharacter.HumanoidRootPart.Position - leftArm.Position).Magnitude
                                        if distance < closestDistance then
                                            closestDistance = distance
                                            closestArgs = {leftArm}
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if closestArgs then
                        MeleeRemote:InvokeServer(unpack(closestArgs))
                    end
                end
                wait(0.00001)
            end
        end)
    end
end)

CombatSection:AddToggle("Fire Axe Aura", false, function(state)
    _G.FireAxeAura = state
    if state then
        spawn(function()
            local function getNearest()
                local target, distance = nil, math.huge
                local targetEnemy = false
                for _,v in ipairs(Players:GetPlayers()) do
                    local c = v.Character
                    if v ~= localPlayer and c and c:FindFirstChild("HumanoidRootPart") then
                        local h = c:FindFirstChild("Humanoid")
                        local dis = (c.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if h and h.Health > 0 and dis < distance then
                            target, distance = v, dis
                            targetEnemy = (v.Team ~= localPlayer.Team and v ~= localPlayer)
                        end
                    end
                end
                return target, targetEnemy
            end

            while _G.FireAxeAura do
                local target, targetEnemy = getNearest()
                if target and target.Character and target.Character:FindFirstChild("Head") and targetEnemy then
                    local args = {target.Character.Head}
                    ZombieRemote:InvokeServer(unpack(args))
                    
                    local sound = Instance.new("Sound")
                    sound.SoundId = "rbxassetid://160432334"
                    sound.Volume = 1
                    sound.PlaybackSpeed = 1
                    sound.Parent = Workspace
                    sound:Play()
                end
                wait(0.000001)
            end
        end)
    end
end)

CombatSection:AddToggle("Infection Aura", false, function(state)
    _G.InfectionAura = state
    if state then
        spawn(function()
            local function getNearest()
                local target, distance = nil, math.huge
                local targetEnemy = false
                for _,v in ipairs(game:GetService("Players"):GetPlayers()) do
                    local c = v.Character
                    if v ~= game:GetService("Players").LocalPlayer and c and c:FindFirstChild("HumanoidRootPart") then
                        local h = c:FindFirstChild("Humanoid")
                        local dis = (c.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if h and h.Health > 0 and dis < distance then
                            target, distance = v, dis
                            targetEnemy = (v.Team ~= game:GetService("Players").LocalPlayer.Team and v ~= game:GetService("Players").LocalPlayer)
                        end
                    end
                end
                return target, targetEnemy
            end

            while _G.InfectionAura do
                local target, targetEnemy = getNearest()
                if target and target.Character and target.Character:FindFirstChild("Head") and targetEnemy then
                    local args = {target.Character.Head}
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ZombieRelated"):WaitForChild("PlayerAttack"):InvokeServer(unpack(args))
                    
                    local sound = Instance.new("Sound")
                    sound.SoundId = "rbxassetid://160432334"
                    sound.Volume = 1
                    sound.PlaybackSpeed = 1
                    sound.Parent = game:GetService("Workspace")
                    sound:Play()
                end
                wait(0.000001)
            end
        end)
    end
end)
-- Silent Aim Loop
spawn(function()
    while true do
        if _G.SilentAim then
            local closestTarget = nil
            local closestDistance = math.huge

            for _,player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    local character = player.Character
                    if character and character:FindFirstChild("Head") then
                        local distance = (localPlayer.Character.HumanoidRootPart.Position - character.Head.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestTarget = player
                        end
                    end
                end
            end

            if closestTarget then
                local args = {closestTarget.Character.Head}
                MeleeRemote:InvokeServer(unpack(args))

                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://160432334"
                sound.Volume = 1
                sound.PlaybackSpeed = 1
                sound.Parent = Workspace
                sound:Play()
            end
        end
        wait(0.001)
    end
end)
local Players=game:GetService("Players")
CombatSection:AddToggle("Auto Zombie Throw", false, function(state)
    _G.AutoZombieThrow = state
    if state then
        spawn(function()
            while _G.AutoZombieThrow do
                local localPlayer = game:GetService("Players").LocalPlayer
                local ZombieThrowRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ZombieRelated"):WaitForChild("ZombieThrow")

                local function getNearestTarget()
                    local closestTarget = nil
                    local closestDistance = math.huge

                    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= localPlayer then
                            local character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") and player.Team ~= localPlayer.Team then
                                local humanoid = character:FindFirstChild("Humanoid")
                                local distance = (character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if humanoid and humanoid.Health > 0 and distance < closestDistance then
                                    closestDistance = distance
                                    closestTarget = player
                                end
                            end
                        end
                    end
                    return closestTarget
                end

                local target = getNearestTarget()
                if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local args = {
                        Vector3.new(localPlayer.Character.HumanoidRootPart.Position.X, localPlayer.Character.HumanoidRootPart.Position.Y, localPlayer.Character.HumanoidRootPart.Position.Z),
                        Vector3.new(target.Character.HumanoidRootPart.Position.X, target.Character.HumanoidRootPart.Position.Y, target.Character.HumanoidRootPart.Position.Z)
                    }
                    ZombieThrowRemote:FireServer(unpack(args))
                end

                wait(0.011) -- Adds delay to prevent excessive execution
            end
        end)
    end
end)
local p=game:GetService("Players")
local r=game:GetService("ReplicatedStorage")
local l=p.LocalPlayer

local t=w:CreateTab("Player")

local s=t:CreateSector("Player Settings", "left")

s:AddToggle("Random Player Name", false, function(state)
    _G.RandomNameChange=state
    if state then
        spawn(function()
            while _G.RandomNameChange do
                local rp=p:GetPlayers()[math.random(1,#p:GetPlayers())]
                if rp and rp~=l then
                    l.DisplayName=rp.DisplayName
                end
                wait(1)
            end
        end)
    end
end)

s:AddToggle("Speed Control", false, function(state)
    _G.SpeedControl=state
    if state then
        spawn(function()
            while _G.SpeedControl do
                if l.Character and l.Character:FindFirstChild("Humanoid")then
                    l.Character.Humanoid.WalkSpeed=_G.SpeedValue or 50
                end
                wait(0.1)
            end
        end)
    else
        if l.Character and l.Character:FindFirstChild("Humanoid")then
            l.Character.Humanoid.WalkSpeed=16
        end
    end
end)

s:AddSlider("Set Speed", 16, 50, 200, 1, function(value)
    _G.SpeedValue=value
end)

t:CreateConfigSystem("right")
