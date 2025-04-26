-- Rivals X by Enemiss (Game ID: 17625359962)
if game.PlaceId ~= 17625359962 then return end

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/ui-libraries/main/coastified/src.lua"))()
local Window = Lib:Window("Rivals X", "rivals_private", Enum.KeyCode.RightControl)

-- Core Variables
local silentAimEnabled = false
local triggerBot = false
local espEnabled = false
local weaponModsActive = false

-- Rivals-Specific Exploits
local rapidFire = false
local noSpread = false
local instantReload = false
local forceHit = false
local noRecoil = false
local noClip = false
local bhopEnabled = false

-- Silent Aim Function
local function getClosestPlayer()
    local closestPlayer, closestDistance = nil, math.huge
    local camera = workspace.CurrentCamera
    local localPlayer = game.Players.LocalPlayer
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPoint = camera:WorldToViewportPoint(humanoidRootPart.Position)
                local magnitude = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                
                if magnitude < closestDistance then
                    closestDistance = magnitude
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- Weapon Modification
local function modifyWeapons()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer.Character then return end
    
    for _, tool in pairs(localPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") then
            -- Rapid Fire
            local fireRate = tool:FindFirstChild("FireRate")
            if fireRate and rapidFire then
                fireRate.Value = 0.05
            end
            
            -- No Spread
            local spread = tool:FindFirstChild("Spread")
            if spread and noSpread then
                spread.Value = 0
            end
            
            -- Instant Reload
            local reloadTime = tool:FindFirstChild("ReloadTime")
            if reloadTime and instantReload then
                reloadTime.Value = 0
            end
            
            -- No Recoil
            local recoil = tool:FindFirstChild("Recoil")
            if recoil and noRecoil then
                recoil.Value = 0
            end
        end
    end
end

-- Force Hit Registration
local function setupForceHit()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if getnamecallmethod() == "FireServer" and tostring(self) == "HitPart" and forceHit then
            args[2] = 100 -- Force max damage
            return oldNamecall(self, unpack(args))
        end
        return oldNamecall(self, ...)
    end)
end

-- Bunny Hop
local function bhop()
    if not bhopEnabled then return end
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- No Clip
local function noclip()
    if not noClip then return end
    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Main Loop
game:GetService("RunService").Stepped:Connect(function()
    -- Weapon Mods
    if weaponModsActive then
        modifyWeapons()
    end
    
    -- Movement
    bhop()
    noclip()
end)

-- Initialize
setupForceHit()

-- Combat Tab
local CombatTab = Window:Tab("Combat")
CombatTab:Toggle("Silent Aim", function(state)
    silentAimEnabled = state
end)

CombatTab:Toggle("Trigger Bot", function(state)
    triggerBot = state
end)

CombatTab:Toggle("Force Hit", function(state)
    forceHit = state
end)

-- Weapon Tab
local WeaponTab = Window:Tab("Weapons")
WeaponTab:Toggle("Weapon Mods", function(state)
    weaponModsActive = state
end)

WeaponTab:Toggle("Rapid Fire", function(state)
    rapidFire = state
end)

WeaponTab:Toggle("No Spread", function(state)
    noSpread = state
end)

WeaponTab:Toggle("Instant Reload", function(state)
    instantReload = state
end)

WeaponTab:Toggle("No Recoil", function(state)
    noRecoil = state
end)

-- Movement Tab
local MovementTab = Window:Tab("Movement")
MovementTab:Toggle("Bunny Hop", function(state)
    bhopEnabled = state
end)

MovementTab:Toggle("No Clip", function(state)
    noClip = state
end)

-- Visuals Tab
local VisualsTab = Window:Tab("Visuals")
VisualsTab:Toggle("ESP", function(state)
    espEnabled = state
    -- ESP implementation would go here
end)

-- Notify user
game.StarterGui:SetCore("SendNotification", {
    Title = "Rivals X Loaded",
    Text = "Press RightControl to open",
    Duration = 5
})
