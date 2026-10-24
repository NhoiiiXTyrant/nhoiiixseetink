local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local pid = game.PlaceId

local GameList = {
    [114326934417838] = "https://vxezestudio.online/api/scripts/script_7duMHGZTfKaWU/stream/init", -- Break and Steal an Egg
    [113290951185459] = "https://vxezestudio.online/api/scripts/script_82HVMJlLn6Omw/stream/init", -- Anime Dice
    [142823291] = "https://vxezestudio.online/api/scripts/script_r0VeAauEuUxPg/stream/init", -- Murder Mystery 2
    [98502499119821] = "https://vxezestudio.online/api/scripts/script_58QYU7BTt9Dg/stream/init", -- Heavyweight Fishing
    [9872472334] = "https://api.xhider.xyz/files/v4/loaders/4955e760c9f9b495f25dcdb2ea54d7e5.lua", -- Evade
    [119091355492870] = "https://api.xhider.xyz/files/v4/loaders/5e11f8e2650b675806aaa7ccd238f1f3.lua", -- RockFruit Sea 1
    [132854526011923] = "https://api.xhider.xyz/files/v4/loaders/a0d3fb06848e377e3c760eee682ea5b8.lua", -- RockFruit Sea 2
    [82878101790702] = "https://api.xhider.xyz/files/v4/loaders/5e11f8e2650b675806aaa7ccd238f1f3.lua", -- Raid Rockfruitsea1
    [13772394625] = "https://api.xhider.xyz/files/v4/loaders/b264cc179514f7b3b7115beddfa456d9.lua", -- Blade Ball
    [85211729168715] = "BLOX_FRUITS_SELECTOR",
    [79091703265657] = "BLOX_FRUITS_SELECTOR",
    [100117331123089] = "BLOX_FRUITS_SELECTOR",
    [107778070777162] = "STEAL_EGG_SELECTOR", -- Steal A Egg: choose version
}

local function loadUrl(url)
    local ok, err = pcall(function()
        local source = game:HttpGet(url)
        local fn = assert(loadstring(source), "Không biên dịch được script")
        fn()
    end)
    if not ok then warn("NhoiiiX Hub load error:", err) end
end

local function showSelector(titleText, options)
    local playerGui = lp:WaitForChild("PlayerGui")
    local oldGui = playerGui:FindFirstChild("NhoiiiXHubSelector")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NhoiiiXHubSelector"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(280, 190)
    frame.Position = UDim2.new(0.5, -140, 0.5, -95)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 45)
    title.Position = UDim2.fromOffset(10, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.fromOffset(10, 160)
    status.BackgroundTransparency = 1
    status.Text = "Chọn một phiên bản"
    status.TextColor3 = Color3.fromRGB(190, 190, 200)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.Parent = frame

    local function makeButton(label, y, url)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -30, 0, 42)
        button.Position = UDim2.new(0, 15, 0, y)
        button.BackgroundColor3 = Color3.fromRGB(75, 95, 220)
        button.BorderSizePixel = 0
        button.Text = label
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 15
        button.Font = Enum.Font.GothamBold
        button.Parent = frame
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

        button.Activated:Connect(function()
            button.Active = false
            button.Text = "Loading..."
            status.Text = "Loading the selected version..."
            local ok, err = pcall(function()
                local source = game:HttpGet(url)
                local fn = assert(loadstring(source), "Không biên dịch được script")
                gui:Destroy()
                fn()
            end)
            if not ok then
                warn("NhoiiiX Hub load error:", err)
                if gui.Parent then
                    button.Active = true
                    button.Text = label
                    status.Text = "Download failed; please try again"
                end
            end
        end)
    end

    for index, option in ipairs(options) do
        makeButton(option.label, 50 + (index - 1) * 50, option.url)
    end
end

local url = GameList[pid]

if url == "BLOX_FRUITS_SELECTOR" then
    showSelector("NhoiiiX - Chọn Hub Blox Fruits", {
        { label = "Aimbot PVP", url = "https://vxezestudio.online/api/scripts/script_Pa7uy5Z0mpKdN/stream/init" },
        { label = "Main Farm", url = "https://vxezestudio.online/api/scripts/script_KSNOqPAlOI2lc/stream/init" },
    })
elseif url == "STEAL_EGG_SELECTOR" then
    showSelector("NhoiiiX - Chọn Steal A Egg", {
        { label = "Steal A Egg - V6", url = "https://vxezestudio.online/api/scripts/script_LlZrCUbDIL2mG/stream/init" },
        { label = "Steal A Egg - V7", url = "https://vxezestudio.online/api/scripts/script_tj3Yg4VG0lxvp/stream/init" },
    })
elseif url then
    loadUrl(url)
else
    warn("Game not supported. PlaceId:", pid)
end
