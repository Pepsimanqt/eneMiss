-- Rivals Ultimate (Coastified Edition) - Game ID: 17625359962
if game.PlaceId ~= 17625359962 then return end

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/ui-libraries/main/coastified/src.lua"))()
local Window = Lib:Window("Rivals Ultimate", "rivals_ultimate", Enum.KeyCode.RightControl)

-- Safe variables initialization
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Combat Tab
local CombatTab = Window:Tab("Combat")

-- Visuals Tab
local VisualsTab = Window:Tab("Visuals")

-- Movement Tab
local MovementTab = Window:Tab("Movement")

-- Weapon Tab
local WeaponTab = Window:Tab("Weapons")

-- Core features with memory optimization
local features = {
    SilentAim = {
        Enabled = false,
        HitChance = 100,
        TargetPart = "Head",
        FOV = 100,
        TeamCheck = true
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = false, -- Disabled by default for stability
        TeamCheck = true,
        Color = Color3.fromRGB(255, 50, 50)
    },
    Movement = {
        Bhop = false,
        Speed = 16,
        SpeedEnabled = false
    },
    Weapons = {
        RapidFire = false,
        NoSpread = false,
        InfiniteAmmo = false
    }
}

-- Lightweight ESP system
local espDrawings = {}

local function createESP(player)
    espDrawings[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text")
    }
    
    -- Configure drawings
    for _, drawing in pairs(espDrawings[player]) do
        drawing.Visible = false
        drawing.ZIndex = 1
    end
    
    espDrawings[player].Name.Size = 14
    espDrawings[player].Name.Center = true
end

local function updateESP()
    for player, drawings in pairs(espDrawings) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            
            if head then
                local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local size = (camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0)).Y - camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,2.5,0)).Y)/2
                    local width = size * 1.5
                    
                    -- Box ESP
                    if features.ESP.Boxes then
                        drawings.Box.Size = Vector2.new(width, size*2)
                        drawings.Box.Position = Vector2.new(pos.X - width/2, pos.Y - size)
                        drawings.Box.Color = features.ESP.Color
                        drawings.Box.Thickness = 1
                        drawings.Box.Visible = features.ESP.Enabled
                    else
                        drawings.Box.Visible = false
                    end
                    
                    -- Name ESP
                    if features.ESP.Names then
                        drawings.Name.Position = Vector2.new(pos.X, pos.Y - size - 20)
                        drawings.Name.Text = player.Name
                        drawings.Name.Color = features.ESP.Color
                        drawings.Name.Visible = features.ESP.Enabled
                    else
                        drawings.Name.Visible = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                end
            end
        else
            drawings.Box.Visible = false
            drawings.Name.Visible = false
        end
    end
end

-- Initialize ESP for all players
for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer then
        createESP(player)
    end
end

players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

players.PlayerRemoving:Connect(function(player)
    if espDrawings[player] then
        for _, drawing in pairs(espDrawings[player]) do
            drawing:Remove()
        end
        espDrawings[player] = nil
    end
end)

-- Silent Aim functionality
local function getClosestTarget()
    if not features.SilentAim.Enabled then return nil end
    
    local closestPlayer, closestDistance = nil, features.SilentAim.FOV
    local localTeam = localPlayer.Team
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            if features.SilentAim.TeamCheck and player.Team == localTeam then continue end
            
            local part = player.Character:FindFirstChild(features.SilentAim.TargetPart)
            if part then
                local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    
                    if distance < closestDistance and math.random(1, 100) <= features.SilentAim.HitChance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Weapon modifications
local function modifyWeapons()
    local character = localPlayer.Character
    if not character then return end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            -- Rapid Fire
            if features.Weapons.RapidFire and tool:FindFirstChild("FireRate") then
                tool.FireRate.Value = 0.05
            end
            
            -- No Spread
            if features.Weapons.NoSpread and tool:FindFirstChild("Spread") then
                tool.Spread.Value = 0
            end
            
            -- Infinite Ammo
            if features.Weapons.InfiniteAmmo then
                if tool:FindFirstChild("Ammo") then tool.Ammo.Value = 999 end
                if tool:FindFirstChild("Clip") then tool.Clip.Value = 999 end
            end
        end
    end
end

-- Movement
local function handleMovement()
    local character = localPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Speed
    if features.Movement.SpeedEnabled then
        humanoid.WalkSpeed = features.Movement.Speed
    else
        humanoid.WalkSpeed = 16
    end
    
    -- Bhop
    if features.Movement.Bhop and humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- Main loop
runService.Heartbeat:Connect(function()
    -- ESP
    if features.ESP.Enabled then
        updateESP()
    else
        for _, drawings in pairs(espDrawings) do
            drawings.Box.Visible = false
            drawings.Name.Visible = false
        end
    end
    
    -- Movement
    handleMovement()
    
    -- Weapons
    modifyWeapons()
end)

-- Combat Tab
CombatTab:Toggle("Silent Aim", function(state)
    features.SilentAim.Enabled = state
end)

CombatTab:Slider("Hit Chance", 1, 100, 100, function(value)
    features.SilentAim.HitChance = value
end)

CombatTab:Dropdown("Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, function(part)
    features.SilentAim.TargetPart = part
end)

CombatTab:Slider("FOV", 10, 360, 100, function(value)
    features.SilentAim.FOV = value
end)

CombatTab:Toggle("Team Check", function(state)
    features.SilentAim.TeamCheck = state
end)

-- Visuals Tab
VisualsTab:Toggle("ESP", function(state)
    features.ESP.Enabled = state
end)

VisualsTab:Toggle("Boxes", function(state)
    features.ESP.Boxes = state
end)

VisualsTab:Toggle("Names", function(state)
    features.ESP.Names = state
end)

VisualsTab:Toggle("Team Check", function(state)
    features.ESP.TeamCheck = state
end)

VisualsTab:Colorpicker("ESP Color", Color3.fromRGB(255, 50, 50), function(color)
    features.ESP.Color = color
end)

-- Movement Tab
MovementTab:Toggle("Bunny Hop", function(state)
    features.Movement.Bhop = state
end)

MovementTab:Toggle("Speed", function(state)
    features.Movement.SpeedEnabled = state
end)

MovementTab:Slider("Speed Value", 16, 100, 16, function(value)
    features.Movement.Speed = value
end)

-- Weapon Tab
WeaponTab:Toggle("Rapid Fire", function(state)
    features.Weapons.RapidFire = state
    modifyWeapons()
end)

WeaponTab:Toggle("No Spread", function(state)
    features.Weapons.NoSpread = state
    modifyWeapons()
end)

WeaponTab:Toggle("Infinite Ammo", function(state)
    features.Weapons.InfiniteAmmo = state
    modifyWeapons()
end)

-- Initialize weapon mods when character spawns
localPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for tools to load
    modifyWeapons()
    
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            modifyWeapons()
        end
    end)
end)

-- Initial notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Rivals Ultimate",
    Text = "Successfully loaded! Press RightControl",
    Duration = 5
})
