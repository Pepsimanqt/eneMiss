-- Rivals Ultimate by DeepSeek (Game ID: 17625359962)
if game.PlaceId ~= 17625359962 then return end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/uwuware-ui/main/main.lua"))()
local window = library:CreateWindow("Rivals Ultimate") do
    window:SetTheme("Midnight")
end

local tabs = {
    Combat = window:AddTab("Combat"),
    Visuals = window:AddTab("Visuals"),
    Movement = window:AddTab("Movement"),
    Misc = window:AddTab("Misc")
}

-- Core variables
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Silent Aim
local silentAim = {
    Enabled = false,
    HitChance = 100,
    TargetPart = "Head",
    FOV = 60,
    TeamCheck = true
}

-- Trigger Bot
local triggerBot = {
    Enabled = false,
    Delay = 0.1,
    AutoFire = false
}

-- ESP
local esp = {
    Enabled = false,
    Boxes = true,
    Names = true,
    Health = true,
    TeamCheck = true,
    Color = Color3.fromRGB(255, 0, 0)
}

-- Weapon Mods
local weaponMods = {
    RapidFire = false,
    NoSpread = false,
    NoRecoil = false,
    InstantReload = false,
    InfiniteAmmo = false
}

-- Movement
local movement = {
    Bhop = false,
    Speed = 16,
    InfiniteJump = false,
    Noclip = false
}

-- Misc
local misc = {
    ForceHit = false,
    NoFlash = false,
    HitSounds = true,
    KillSay = false
}

-- Drawing setup
local drawings = {}
local function createEsp(player)
    drawings[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthText = Drawing.new("Text")
    }
    
    for _, drawing in pairs(drawings[player]) do
        drawing.Visible = false
    end
end

local function updateEsp()
    for player, drawing in pairs(drawings) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if head then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local size = (workspace.CurrentCamera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0)).Y - workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0,2.5,0)).Y)/2
                    local width = size * 1.5
                    
                    -- Box ESP
                    if esp.Boxes then
                        drawing.Box.Size = Vector2.new(width, size*2)
                        drawing.Box.Position = Vector2.new(pos.X - width/2, pos.Y - size)
                        drawing.Box.Color = esp.Color
                        drawing.Box.Thickness = 1
                        drawing.Box.Visible = esp.Enabled
                    else
                        drawing.Box.Visible = false
                    end
                    
                    -- Name ESP
                    if esp.Names then
                        drawing.Name.Position = Vector2.new(pos.X, pos.Y - size - 20)
                        drawing.Name.Text = player.Name
                        drawing.Name.Color = esp.Color
                        drawing.Name.Visible = esp.Enabled
                    else
                        drawing.Name.Visible = false
                    end
                    
                    -- Health ESP
                    if esp.Health and humanoid then
                        local health = humanoid.Health / humanoid.MaxHealth
                        local barLength = size * 2 * health
                        
                        drawing.HealthBar.From = Vector2.new(pos.X - width/2 - 6, pos.Y + size)
                        drawing.HealthBar.To = Vector2.new(pos.X - width/2 - 6, pos.Y + size - barLength)
                        drawing.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                        drawing.HealthBar.Thickness = 2
                        drawing.HealthBar.Visible = esp.Enabled
                        
                        drawing.HealthText.Position = Vector2.new(pos.X - width/2 - 6, pos.Y + size + 5)
                        drawing.HealthText.Text = tostring(math.floor(humanoid.Health))
                        drawing.HealthText.Color = Color3.fromRGB(255, 255, 255)
                        drawing.HealthText.Visible = esp.Enabled
                    else
                        drawing.HealthBar.Visible = false
                        drawing.HealthText.Visible = false
                    end
                else
                    for _, d in pairs(drawing) do
                        d.Visible = false
                    end
                end
            end
        else
            for _, d in pairs(drawing) do
                d.Visible = false
            end
        end
    end
end

-- Silent Aim Calculation
local function getClosestTarget()
    if not silentAim.Enabled then return nil end
    
    local closestPlayer, closestDistance = nil, silentAim.FOV
    local camera = workspace.CurrentCamera
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            if silentAim.TeamCheck and player.Team == localPlayer.Team then continue end
            
            local part = player.Character:FindFirstChild(silentAim.TargetPart)
            if part then
                local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Weapon Modification
local function modifyWeapon(tool)
    if not tool:IsA("Tool") then return end
    
    if weaponMods.RapidFire and tool:FindFirstChild("FireRate") then
        tool.FireRate.Value = 0.05
    end
    
    if weaponMods.NoSpread and tool:FindFirstChild("Spread") then
        tool.Spread.Value = 0
    end
    
    if weaponMods.NoRecoil and tool:FindFirstChild("Recoil") then
        tool.Recoil.Value = 0
    end
    
    if weaponMods.InstantReload and tool:FindFirstChild("ReloadTime") then
        tool.ReloadTime.Value = 0
    end
    
    if weaponMods.InfiniteAmmo then
        if tool:FindFirstChild("Ammo") then tool.Ammo.Value = 999 end
        if tool:FindFirstChild("Clip") then tool.Clip.Value = 999 end
    end
end

-- Force Hit
local function setupForceHit()
    if not misc.ForceHit then return end
    
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if getnamecallmethod() == "FireServer" and tostring(self) == "HitPart" then
            args[2] = 100 -- Max damage
            return oldNamecall(self, unpack(args))
        end
        return oldNamecall(self, ...)
    end)
end

-- Bunny Hop
local function bhop()
    if not movement.Bhop then return end
    
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- Speed Hack
local function speedHack()
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = movement.Speed
        end
    end
end

-- Infinite Jump
local function infiniteJump()
    if movement.InfiniteJump then
        uis.JumpRequest:Connect(function()
            local character = localPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

-- Noclip
local function noclip()
    if not movement.Noclip then return end
    
    local character = localPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- No Flash
local function noFlash()
    if not misc.NoFlash then return end
    
    for _, effect in pairs(game:GetService("Lighting"):GetChildren()) do
        if effect.Name == "FlashEffect" then
            effect:Destroy()
        end
    end
end

-- Hit Sounds
local function playHitSound()
    if not misc.HitSounds then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://131233123"
    sound.Parent = workspace
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Initialize
for _, player in pairs(players:GetPlayers()) do
    createEsp(player)
end

players.PlayerAdded:Connect(function(player)
    createEsp(player)
end)

players.PlayerRemoving:Connect(function(player)
    if drawings[player] then
        for _, drawing in pairs(drawings[player]) do
            drawing:Remove()
        end
        drawings[player] = nil
    end
end)

localPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    speedHack()
    
    if weaponMods.RapidFire or weaponMods.NoSpread or weaponMods.NoRecoil or weaponMods.InstantReload or weaponMods.InfiniteAmmo then
        for _, tool in pairs(character:GetChildren()) do
            modifyWeapon(tool)
        end
        
        character.ChildAdded:Connect(function(tool)
            modifyWeapon(tool)
        end)
    end
end)

setupForceHit()
infiniteJump()

-- Main loop
runService.Stepped:Connect(function()
    -- ESP
    if esp.Enabled then
        updateEsp()
    else
        for _, playerDrawing in pairs(drawings) do
            for _, drawing in pairs(playerDrawing) do
                drawing.Visible = false
            end
        end
    end
    
    -- Movement
    bhop()
    speedHack()
    noclip()
    
    -- Misc
    noFlash()
end)

-- Combat Tab
tabs.Combat:AddToggle("Silent Aim", silentAim.Enabled, function(state)
    silentAim.Enabled = state
end)

tabs.Combat:AddSlider("Hit Chance", silentAim.HitChance, 1, 100, function(value)
    silentAim.HitChance = value
end)

tabs.Combat:AddDropdown("Target Part", silentAim.TargetPart, {"Head", "HumanoidRootPart", "UpperTorso"}, function(part)
    silentAim.TargetPart = part
end)

tabs.Combat:AddSlider("FOV", silentAim.FOV, 1, 360, function(value)
    silentAim.FOV = value
end)

tabs.Combat:AddToggle("Trigger Bot", triggerBot.Enabled, function(state)
    triggerBot.Enabled = state
end)

tabs.Combat:AddSlider("Trigger Delay", triggerBot.Delay, 0, 0.5, function(value)
    triggerBot.Delay = value
end)

tabs.Combat:AddToggle("Force Hit", misc.ForceHit, function(state)
    misc.ForceHit = state
    setupForceHit()
end)

-- Weapon Tab
tabs.Combat:AddToggle("Rapid Fire", weaponMods.RapidFire, function(state)
    weaponMods.RapidFire = state
    if localPlayer.Character then
        for _, tool in pairs(localPlayer.Character:GetChildren()) do
            modifyWeapon(tool)
        end
    end
end)

tabs.Combat:AddToggle("No Spread", weaponMods.NoSpread, function(state)
    weaponMods.NoSpread = state
    if localPlayer.Character then
        for _, tool in pairs(localPlayer.Character:GetChildren()) do
            modifyWeapon(tool)
        end
    end
end)

tabs.Combat:AddToggle("No Recoil", weaponMods.NoRecoil, function(state)
    weaponMods.NoRecoil = state
    if localPlayer.Character then
        for _, tool in pairs(localPlayer.Character:GetChildren()) do
            modifyWeapon(tool)
        end
    end
end)

tabs.Combat:AddToggle("Instant Reload", weaponMods.InstantReload, function(state)
    weaponMods.InstantReload = state
    if localPlayer.Character then
        for _, tool in pairs(localPlayer.Character:GetChildren()) do
            modifyWeapon(tool)
        end
    end
end)

tabs.Combat:AddToggle("Infinite Ammo", weaponMods.InfiniteAmmo, function(state)
    weaponMods.InfiniteAmmo = state
    if localPlayer.Character then
        for _, tool in pairs(localPlayer.Character:GetChildren()) do
            modifyWeapon(tool)
        end
    end
end)

-- Movement Tab
tabs.Movement:AddToggle("Bunny Hop", movement.Bhop, function(state)
    movement.Bhop = state
end)

tabs.Movement:AddSlider("Speed", movement.Speed, 16, 100, function(value)
    movement.Speed = value
    speedHack()
end)

tabs.Movement:AddToggle("Infinite Jump", movement.InfiniteJump, function(state)
    movement.InfiniteJump = state
    infiniteJump()
end)

tabs.Movement:AddToggle("Noclip", movement.Noclip, function(state)
    movement.Noclip = state
end)

-- Visuals Tab
tabs.Visuals:AddToggle("ESP", esp.Enabled, function(state)
    esp.Enabled = state
end)

tabs.Visuals:AddToggle("Boxes", esp.Boxes, function(state)
    esp.Boxes = state
end)

tabs.Visuals:AddToggle("Names", esp.Names, function(state)
    esp.Names = state
end)

tabs.Visuals:AddToggle("Health", esp.Health, function(state)
    esp.Health = state
end)

tabs.Visuals:AddToggle("Team Check", esp.TeamCheck, function(state)
    esp.TeamCheck = state
end)

tabs.Visuals:AddColorPicker("ESP Color", esp.Color, function(color)
    esp.Color = color
end)

-- Misc Tab
tabs.Misc:AddToggle("No Flash", misc.NoFlash, function(state)
    misc.NoFlash = state
end)

tabs.Misc:AddToggle("Hit Sounds", misc.HitSounds, function(state)
    misc.HitSounds = state
end)

tabs.Misc:AddToggle("Kill Say", misc.KillSay, function(state)
    misc.KillSay = state
end)

-- Notify
game.StarterGui:SetCore("SendNotification", {
    Title = "Rivals Ultimate",
    Text = "Successfully loaded!",
    Duration = 5
})
