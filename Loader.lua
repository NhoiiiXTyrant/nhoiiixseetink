local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local pid = game.PlaceId

local HUB_LOGO = "rbxassetid://75850663384500"
local GUI_NAME = "NhoiiiXHubSelector"

local GameList = {
    [114326934417838] = "https://vxezestudio.online/api/scripts/script_7duMHGZTfKaWU/stream/init", -- Break and Steal an Egg
    [113290951185459] = "https://vxezestudio.online/api/scripts/script_82HVMJlLn6Omw/stream/init", -- Anime Dice
    [142823291] = "https://vxezestudio.online/api/scripts/script_r0VeAauEuUxPg/stream/init", -- Murder Mystery 2
    [9872472334] = "https://api.xhider.xyz/files/v4/loaders/4955e760c9f9b495f25dcdb2ea54d7e5.lua", -- Evade
    [119091355492870] = "https://api.xhider.xyz/files/v4/loaders/5e11f8e2650b675806aaa7ccd238f1f3.lua", -- RockFruit Sea 1
    [132854526011923] = "https://api.xhider.xyz/files/v4/loaders/a0d3fb06848e377e3c760eee682ea5b8.lua", -- RockFruit Sea 2
    [82878101790702] = "https://api.xhider.xyz/files/v4/loaders/5e11f8e2650b675806aaa7ccd238f1f3.lua", -- Raid Rockfruitsea1
    [13772394625] = "https://api.xhider.xyz/files/v4/loaders/b264cc179514f7b3b7115beddfa456d9.lua", -- Blade Ball
    [98502499119821] = "HEAVYWEIGHT_FISHING_SELECTOR", -- Heavyweight Fishing
    [107778070777162] = "STEAL_EGG_SELECTOR", -- Steal A Egg
    [85211729168715] = "BLOX_FRUITS_SELECTOR",
    [79091703265657] = "BLOX_FRUITS_SELECTOR",
    [100117331123089] = "BLOX_FRUITS_SELECTOR",
}

local function loadUrl(url)
    local ok, err = pcall(function()
        local source = game:HttpGet(url)
        local fn, compileErr = loadstring(source)
        assert(fn, compileErr or "Không biên dịch được script")
        fn()
    end)

    if not ok then
        warn("NhoiiiX Hub load error:", err)
    end
end

-- Xoá bảng chọn cũ (ở mọi nơi có thể đã gắn trước đó)
local function destroyOld()
    local containers = {}

    pcall(function()
        if gethui then
            table.insert(containers, gethui())
        end
    end)
    pcall(function()
        table.insert(containers, game:GetService("CoreGui"))
    end)
    table.insert(containers, lp:WaitForChild("PlayerGui"))

    for _, container in ipairs(containers) do
        pcall(function()
            local old = container:FindFirstChild(GUI_NAME)
            if old then
                old:Destroy()
            end
        end)
    end
end

-- Gắn GUI vào gethui/CoreGui trước (ít bị game che hoặc xoá), lỗi thì dùng PlayerGui
local function mountGui(gui)
    local ok = pcall(function()
        if gethui then
            gui.Parent = gethui()
        else
            gui.Parent = game:GetService("CoreGui")
        end
    end)

    if not ok or not gui.Parent then
        gui.Parent = lp:WaitForChild("PlayerGui")
    end
end

-- Chữ tự co lại cho vừa khung, không bị tràn/cắt
local function fitText(label, maxSize)
    label.TextScaled = true

    local constraint = Instance.new("UITextSizeConstraint")
    constraint.MaxTextSize = maxSize
    constraint.MinTextSize = 9
    constraint.Parent = label
end

local function showSelector(titleText, options)
    destroyOld()

    local BUTTON_H = 42
    local GAP = 8
    local TOP = 50
    local STATUS_H = 20

    local frameH = TOP + #options * (BUTTON_H + GAP) + STATUS_H + 10

    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    mountGui(gui)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(280, frameH)
    frame.Position = UDim2.new(0.5, -140, 0.5, -math.floor(frameH / 2))
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 45)
    title.Position = UDim2.fromOffset(10, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    fitText(title, 18)

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.fromOffset(28, 28)
    closeButton.Position = UDim2.new(1, -36, 0, 8)
    closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = frame

    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)

    closeButton.Activated:Connect(function()
        gui:Destroy()
    end)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, STATUS_H)
    status.Position = UDim2.fromOffset(10, frameH - STATUS_H - 10)
    status.BackgroundTransparency = 1
    status.Text = "Chọn một phiên bản"
    status.TextColor3 = Color3.fromRGB(190, 190, 200)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.Parent = frame

    -- Chặn bấm nhiều lần / bấm nút khác trong lúc đang tải
    local busy = false

    local function makeButton(label, y, url)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -30, 0, BUTTON_H)
        button.Position = UDim2.new(0, 15, 0, y)
        button.BackgroundColor3 = Color3.fromRGB(75, 95, 220)
        button.BorderSizePixel = 0
        button.AutoButtonColor = true
        button.Text = label
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 15
        button.Font = Enum.Font.GothamBold
        button.Parent = frame
        fitText(button, 15)

        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

        button.Activated:Connect(function()
            if busy then
                return
            end
            busy = true

            button.Text = "Loading..."
            status.Text = "Loading the selected version..."

            local ok, err = pcall(function()
                local source = game:HttpGet(url)
                local fn, compileErr = loadstring(source)
                assert(fn, compileErr or "Could not compile the script")

                gui:Destroy()
                fn()
            end)

            if not ok then
                warn("NhoiiiX Hub load error:", err)

                -- Chỉ khôi phục nút khi bảng chọn còn tồn tại (tải/biên dịch thất bại)
                if gui.Parent then
                    busy = false
                    button.Text = label
                    status.Text = "Download failed, please try again"
                end
            end
        end)
    end

    for index, option in ipairs(options) do
        makeButton(option.label, TOP + (index - 1) * (BUTTON_H + GAP), option.url)
    end
end

local url = GameList[pid]

if url == "BLOX_FRUITS_SELECTOR" then
    showSelector("NhoiiiX - Blox Fruits", {
        {
            label = "Aimbot PVP",
            url = "https://vxezestudio.online/api/scripts/script_Pa7uy5Z0mpKdN/stream/init"
        },
        {
            label = "Main Farm",
            url = "https://vxezestudio.online/api/scripts/script_KSNOqPAlOI2lc/stream/init"
        },
    })

elseif url == "STEAL_EGG_SELECTOR" then
    showSelector("NhoiiiX - Steal A Egg", {
        {
            label = "Steal A Egg - V6",
            url = "https://vxezestudio.online/api/scripts/script_LlZrCUbDIL2mG/stream/init"
        },
        {
            label = "Steal A Egg - V7",
            url = "https://vxezestudio.online/api/scripts/script_tj3Yg4VG0lxvp/stream/init"
        },
    })

elseif url == "HEAVYWEIGHT_FISHING_SELECTOR" then
    showSelector("NhoiiiX - Heavyweight Fishing", {
        {
            label = "NhoiiiX - V1",
            url = "https://vxezestudio.online/api/scripts/script_58QYU7BTt9Dg/stream/init"
        },
        {
            label = "NhoiiiX - Premium",
            url = "https://vxezestudio.online/api/scripts/script_aVqhlNnUgiodZ/stream/init"
        },
    })

elseif url then
    loadUrl(url)

else
    warn("Game not supported. PlaceId:", pid)
end
