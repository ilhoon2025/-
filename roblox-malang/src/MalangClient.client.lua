-- 말랑이 공방: 클라이언트 (StarterPlayerScripts)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = require(ReplicatedStorage:WaitForChild("MalangShared"))
local remote = ReplicatedStorage:WaitForChild("MalangEvent")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-------------------------------------------------------------------
-- 말랑 애니메이션: 눌리면 납작해졌다가 탱글탱글 돌아옴
-------------------------------------------------------------------
local anims = {} -- [model] = { t, parts = { [part] = { size, rel } } }

local function capture(model)
	local root = model.PrimaryPart
	if not root then
		return nil
	end
	local parts = {}
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") and p ~= root then
			parts[p] = { size = p.Size, rel = root.CFrame:ToObjectSpace(p.CFrame) }
		end
	end
	return parts
end

local function startSquish(model)
	local a = anims[model]
	if a then
		a.t = 0
	else
		local parts = capture(model)
		if parts then
			anims[model] = { t = 0, parts = parts }
		end
	end
end

local UP = Vector3.new(0, 1, 0)
RunService.RenderStepped:Connect(function(dt)
	for model, a in pairs(anims) do
		a.t = a.t + dt
		local root = model.PrimaryPart
		if not root or not model.Parent then
			anims[model] = nil
		else
			local done = a.t >= 0.7
			local w = done and 0 or math.exp(-6 * a.t) * math.cos(16 * a.t)
			local sy = 1 - 0.42 * w
			local sx = 1 + 0.3 * w
			for p, o in pairs(a.parts) do
				if p.Parent then
					-- 부품의 각 축이 위쪽(Y)과 얼마나 같은 방향인지에 따라 늘이고 줄이기
					local r = o.rel
					local function f(axis)
						local k = math.abs(axis:Dot(UP))
						return sx + (sy - sx) * k
					end
					p.Size = o.size * Vector3.new(f(r.RightVector), f(r.UpVector), f(r.LookVector))
					local pos = r.Position
					p.CFrame = root.CFrame * (CFrame.new(pos.X * sx, pos.Y * sy, pos.Z * sx) * r.Rotation)
				end
			end
			if done then
				anims[model] = nil
			end
		end
	end
end)

-------------------------------------------------------------------
-- UI
-------------------------------------------------------------------
local function new(class, props, children)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			o[k] = v
		end
	end
	for _, ch in ipairs(children or {}) do
		ch.Parent = o
	end
	o.Parent = props.Parent
	return o
end
local function corner(r)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 12) })
end
local function stroke(c, t)
	return new("UIStroke", { Color = c, Thickness = t or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end
local PINK = Color3.fromRGB(255, 120, 170)
local TEXT = Color3.fromRGB(80, 60, 80)
local function label(props)
	props.BackgroundTransparency = props.BackgroundTransparency or 1
	props.Font = props.Font or Enum.Font.GothamBold
	props.TextColor3 = props.TextColor3 or TEXT
	props.TextScaled = true
	return new("TextLabel", props)
end

local gui = new("ScreenGui", { Name = "MalangUI", ResetOnSpawn = false, IgnoreGuiInset = true, Parent = player:WaitForChild("PlayerGui") })
local root = new("Frame", { Parent = gui, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
local uiScale = new("UIScale", { Parent = root })
local function fit()
	local v = camera.ViewportSize
	local s = math.clamp(math.min(v.X / 1280, v.Y / 720), 0.55, 1.6)
	uiScale.Scale = s
	root.Size = UDim2.fromOffset(v.X / s, v.Y / s)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
fit()

-- 포인트 카드
local card = new("Frame", { Parent = root, BackgroundColor3 = Color3.fromRGB(255, 245, 250), Size = UDim2.fromOffset(260, 96), Position = UDim2.fromOffset(16, 16) }, { corner(18), stroke(PINK, 3) })
label({ Parent = card, Text = "말랑 포인트", TextColor3 = PINK, Size = UDim2.new(1, -24, 0, 22), Position = UDim2.fromOffset(12, 8), TextXAlignment = Enum.TextXAlignment.Left })
local ptsLabel = label({ Parent = card, Text = "0 P", Font = Enum.Font.GothamBlack, Size = UDim2.new(1, -24, 0, 40), Position = UDim2.fromOffset(12, 30), TextXAlignment = Enum.TextXAlignment.Left })
local comboLabel = label({ Parent = card, Text = "", TextColor3 = Color3.fromRGB(255, 150, 60), Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(12, 72), TextXAlignment = Enum.TextXAlignment.Left })

-- 안내
local hint = label({ Parent = root, Text = "말랑이를 클릭해서 포인트를 모으고, 뽑기 기계에서 " .. Shared.GACHA_COST .. "P로 새 말랑이를 뽑아 보세요!", Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.3, AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.new(0, 760, 0, 26), Position = UDim2.new(0.5, 0, 1, -16) })
task.delay(15, function()
	hint.Visible = false
end)

-- 알림
local toastL = label({ Parent = root, Text = "", TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.1, BackgroundColor3 = PINK, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(460, 40), Position = UDim2.new(0.5, 0, 0, 16), Visible = false })
corner(12).Parent = toastL
local toastId = 0
local function toast(msg)
	toastId = toastId + 1
	local my = toastId
	toastL.Text = msg
	toastL.Visible = true
	task.delay(2.5, function()
		if toastId == my then
			toastL.Visible = false
		end
	end)
end

-- 도감
local owned = {}
local bookBtn = new("TextButton", { Parent = root, Text = "도감", Font = Enum.Font.GothamBlack, TextScaled = true, TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = PINK, AnchorPoint = Vector2.new(1, 1), Size = UDim2.fromOffset(120, 56), Position = UDim2.new(1, -16, 1, -16) }, { corner(16), new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }) })
local book = new("Frame", { Parent = root, BackgroundColor3 = Color3.fromRGB(255, 248, 252), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(640, 470), Visible = false, ZIndex = 10 }, { corner(20), stroke(PINK, 3) })
label({ Parent = book, ZIndex = 11, Text = "말랑이 도감", Font = Enum.Font.GothamBlack, TextColor3 = PINK, Size = UDim2.new(1, -40, 0, 36), Position = UDim2.fromOffset(20, 14) })
local bookCount = label({ Parent = book, ZIndex = 11, Text = "", Size = UDim2.new(1, -40, 0, 20), Position = UDim2.fromOffset(20, 50) })
local closeBtn = new("TextButton", { Parent = book, ZIndex = 11, Text = "X", Font = Enum.Font.GothamBlack, TextScaled = true, TextColor3 = Color3.new(1, 1, 1), BackgroundColor3 = PINK, AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -14, 0, 14) }, { corner(10) })
local grid = new("Frame", { Parent = book, ZIndex = 11, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -96), Position = UDim2.fromOffset(20, 80) })
new("UIGridLayout", { Parent = grid, CellSize = UDim2.fromOffset(140, 84), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder })
local cells = {}
for i, s in ipairs(Shared.SQUISHIES) do
	local r = Shared.RARITY[s.rarity]
	local c = new("Frame", { Parent = grid, ZIndex = 12, LayoutOrder = i, BackgroundColor3 = Color3.new(1, 1, 1) }, { corner(12), stroke(r.color, 2) })
	local dot = new("Frame", { Parent = c, ZIndex = 13, BackgroundColor3 = s.color, AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(36, 36), Position = UDim2.new(0, 10, 0.5, 0) }, { corner(18) })
	local nm = label({ Parent = c, ZIndex = 13, Text = "???", Size = UDim2.new(1, -56, 0, 22), Position = UDim2.fromOffset(52, 12), TextXAlignment = Enum.TextXAlignment.Left })
	local rr = label({ Parent = c, ZIndex = 13, Text = r.name, TextColor3 = r.color, Size = UDim2.new(1, -56, 0, 16), Position = UDim2.fromOffset(52, 36), TextXAlignment = Enum.TextXAlignment.Left })
	local cnt = label({ Parent = c, ZIndex = 13, Text = "", Font = Enum.Font.Gotham, Size = UDim2.new(1, -56, 0, 14), Position = UDim2.fromOffset(52, 56), TextXAlignment = Enum.TextXAlignment.Left })
	cells[s.id] = { name = nm, dot = dot, count = cnt, def = s }
end
local function refreshBook()
	local have = 0
	for id, cell in pairs(cells) do
		local n = owned[id]
		if n and n > 0 then
			have = have + 1
			cell.name.Text = cell.def.name
			cell.dot.BackgroundColor3 = cell.def.color
			cell.count.Text = n .. "개"
		else
			cell.name.Text = "???"
			cell.dot.BackgroundColor3 = Color3.fromRGB(220, 215, 225)
			cell.count.Text = ""
		end
	end
	bookCount.Text = "모은 종류 " .. have .. " / " .. #Shared.SQUISHIES
end
bookBtn.MouseButton1Click:Connect(function()
	refreshBook()
	book.Visible = not book.Visible
end)
closeBtn.MouseButton1Click:Connect(function()
	book.Visible = false
end)

-- 뽑기 결과
local gachaLayer = new("Frame", { Parent = root, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 20 })
local capsule = new("Frame", { Parent = gachaLayer, ZIndex = 21, BackgroundColor3 = PINK, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(160, 160) }, { corner(80) })
local capsuleTop = new("Frame", { Parent = capsule, ZIndex = 22, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 0.5) }, { corner(80) })
local resName = label({ Parent = gachaLayer, ZIndex = 23, Text = "", Font = Enum.Font.GothamBlack, TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.2, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(520, 56), Position = UDim2.fromScale(0.5, 0.66) })
local resRarity = label({ Parent = gachaLayer, ZIndex = 23, Text = "", TextStrokeTransparency = 0.3, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(400, 30), Position = UDim2.fromScale(0.5, 0.74) })
local resNew = label({ Parent = gachaLayer, ZIndex = 23, Text = "NEW!", Font = Enum.Font.GothamBlack, TextColor3 = Color3.fromRGB(255, 230, 80), TextStrokeTransparency = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(200, 40), Position = UDim2.fromScale(0.5, 0.25) })

local function showGacha(id, isNew)
	local def = Shared.byId(id)
	local r = Shared.RARITY[def.rarity]
	gachaLayer.Visible = true
	resName.Text = ""
	resRarity.Text = ""
	resNew.Visible = false
	capsule.BackgroundColor3 = PINK
	capsuleTop.Visible = true
	capsule.Size = UDim2.fromOffset(160, 160)
	-- 캡슐 흔들기
	for i = 1, 10 do
		capsule.Rotation = (i % 2 == 0) and 12 or -12
		task.wait(0.07)
	end
	capsule.Rotation = 0
	-- 펑! 열리면서 말랑이 색으로
	capsuleTop.Visible = false
	capsule.BackgroundColor3 = def.color
	TweenService:Create(capsule, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(220, 190) }):Play()
	resName.Text = def.name
	resRarity.Text = r.name .. " 등급"
	resRarity.TextColor3 = r.color
	resNew.Visible = isNew
	task.wait(2.2)
	gachaLayer.Visible = false
	toast(def.name .. "이(가) 따라오기 시작했어요!")
end

-- 떠오르는 +숫자
local function floatText(model, str, color)
	local adornee = model and (model:FindFirstChild("Body") or model.PrimaryPart)
	if not adornee then
		return
	end
	local bb = new("BillboardGui", { Parent = gui, Adornee = adornee, Size = UDim2.fromOffset(120, 40), StudsOffset = Vector3.new(math.random(-10, 10) / 10, 2, 0), AlwaysOnTop = true })
	local t = label({ Parent = bb, Text = str, Font = Enum.Font.GothamBlack, TextColor3 = color, TextStrokeTransparency = 0.2, Size = UDim2.fromScale(1, 1) })
	TweenService:Create(bb, TweenInfo.new(0.8), { StudsOffset = bb.StudsOffset + Vector3.new(0, 3, 0) }):Play()
	TweenService:Create(t, TweenInfo.new(0.8), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(0.85, function()
		bb:Destroy()
	end)
end

-- 포인트 표시
task.spawn(function()
	local ls = player:WaitForChild("leaderstats")
	local pv = ls:WaitForChild("말랑P")
	local function show()
		ptsLabel.Text = pv.Value .. " P"
	end
	show()
	pv.Changed:Connect(show)
end)

local comboClear = 0
remote.OnClientEvent:Connect(function(action, a, b, c)
	if action == "Squish" then
		startSquish(a)
	elseif action == "Gain" then
		floatText(c, "+" .. a, b >= 5 and Color3.fromRGB(255, 150, 60) or PINK)
		comboClear = comboClear + 1
		local my = comboClear
		comboLabel.Text = b > 0 and ("콤보 x" .. b .. "  (+" .. (b * 10) .. "%)") or ""
		task.delay(1, function()
			if comboClear == my then
				comboLabel.Text = ""
			end
		end)
	elseif action == "Passive" then
		toast("따라다니는 말랑이들이 +" .. a .. "P를 모아 왔어요")
	elseif action == "Gacha" then
		task.spawn(showGacha, a, b)
	elseif action == "Collection" then
		owned = a
		refreshBook()
	elseif action == "Toast" then
		toast(a)
	end
end)
