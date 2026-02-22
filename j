--use it carefully saar
task.spawn(function()
	local Settings = {
        LockRange = 30,
        Smoothness = 0.5,
        TPWalkSpeed = 0.5,
        OnslaughtDur = 4.5, 
        Key2Dur = 2.5,      
        Key4Dur = 3.5       
    }

    local lp = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local rs = game:GetService("RunService")
    local uis = game:GetService("UserInputService")

    local lockEndTime = 0
    local systemEnabled = false

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JJS_Moveset_Rainbow"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = lp.PlayerGui

    local toggleButton = Instance.new("TextButton", screenGui)
    toggleButton.Size = UDim2.new(0, 200, 0, 55)
    toggleButton.Position = UDim2.new(0, 20, 0.5, -27)
    toggleButton.Text = "chara moveset booster"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.Code
    toggleButton.TextSize = 16
    toggleButton.BorderSizePixel = 4

    task.spawn(function()
        while true do
            for i = 0, 1, 0.01 do
                if systemEnabled then
                    toggleButton.BackgroundColor3 = Color3.fromHSV(i, 0.8, 0.3) 
                    toggleButton.BorderColor3 = Color3.fromHSV(i, 1, 1)
                else
                    toggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                    toggleButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
                end
                task.wait(0.03)
            end
        end
    end)

    toggleButton.MouseButton1Click:Connect(function()
        systemEnabled = not systemEnabled
        if systemEnabled then
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            toggleButton.TextColor3 = Color3.fromRGB(255, 50, 50)
            lockEndTime = 0
        end
    end)

    local function getClosestPlayer()
        local target = nil
        local shortestDist = Settings.LockRange
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local root = v.Character.HumanoidRootPart
                local _, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (lp.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = root
                    end
                end
            end
        end
        return target
    end

    local function applyRotationBypass()
        if uis.MouseBehavior == Enum.MouseBehavior.LockCenter then
            local char = lp.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local lookVector = camera.CFrame.LookVector
                root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            end
        end
    end

    local function applyTPWalk(delta)
        local char = lp.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if char and hum and hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * Settings.TPWalkSpeed * delta * 10)
        end
    end

    uis.InputBegan:Connect(function(input, gpe)
        if gpe or not systemEnabled then return end
        if input.KeyCode == Enum.KeyCode.One then
            lockEndTime = tick() + Settings.OnslaughtDur
        elseif input.KeyCode == Enum.KeyCode.Two then
            lockEndTime = tick() + Settings.Key2Dur
        elseif input.KeyCode == Enum.KeyCode.Four then
            lockEndTime = tick() + Settings.Key4Dur
        end
    end)

    rs.Heartbeat:Connect(function(delta)
        if not systemEnabled then return end

        applyTPWalk(delta)
        applyRotationBypass()
        
        if tick() < lockEndTime then
            local targetPart = getClosestPlayer()
            if targetPart then
                local targetCF = CFrame.new(camera.CFrame.Position, targetPart.Position)
                camera.CFrame = camera.CFrame:Lerp(targetCF, Settings.Smoothness)
            end
        end
    end)
end)
