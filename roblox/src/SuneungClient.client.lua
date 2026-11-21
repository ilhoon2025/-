-- 한국 수능 부정행위! : 클라이언트 UI (StarterPlayerScripts)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Shared = require(ReplicatedStorage:WaitForChild("SuneungShared"))
local remote = ReplicatedStorage:WaitForChild("SuneungEvent")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-------------------------------------------------------------------
-- 스타일
-------------------------------------------------------------------
local C = {
	surface = Color3.fromRGB(255, 255, 255),
	sub = Color3.fromRGB(246, 247, 249),
	line = Color3.fromRGB(226, 229, 234),
	text = Color3.fromRGB(31, 35, 40),
	muted = Color3.fromRGB(107, 114, 128),
	accent = Color3.fromRGB(30, 58, 138),
	danger = Color3.fromRGB(185, 28, 28),
	ok = Color3.fromRGB(21, 128, 61),
	paper = Color3.fromRGB(252, 251, 247),
}
local F = {
	reg = Enum.Font.Gotham,
	mid = Enum.Font.GothamMedium,
	bold = Enum.Font.GothamBold,
}

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
	return new("UICorner", { CornerRadius = UDim.new(0, r or 8) })
end
local function stroke(color, t)
	return new("UIStroke", { Color = color or C.line, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end
local function pad(x, y)
	y = y or x
	return new("UIPadding", { PaddingTop = UDim.new(0, y), PaddingBottom = UDim.new(0, y), PaddingLeft = UDim.new(0, x), PaddingRight = UDim.new(0, x) })
end
local function text(props)
	props.BackgroundTransparency = props.BackgroundTransparency or 1
	props.Font = props.Font or F.reg
	props.TextSize = props.TextSize or 14
	props.TextColor3 = props.TextColor3 or C.text
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	props.TextWrapped = true
	return new("TextLabel", props)
end
local function button(props, primary)
	props.Font = props.Font or F.bold
	props.TextSize = props.TextSize or 15
	props.AutoButtonColor = true
	if primary == false then
		props.BackgroundColor3 = props.BackgroundColor3 or C.surface
		props.TextColor3 = props.TextColor3 or C.text
		return new("TextButton", props, { corner(8), stroke() })
	end
	props.BackgroundColor3 = props.BackgroundColor3 or C.accent
	props.TextColor3 = props.TextColor3 or Color3.new(1, 1, 1)
	return new("TextButton", props, { corner(8) })
end
local function card(props)
	props.BackgroundColor3 = props.BackgroundColor3 or C.surface
	return new("Frame", props, { corner(12), stroke() })
end

-------------------------------------------------------------------
-- 화면 크기에 맞춰 UI 크기 자동 조절
-- 기준 해상도 1280x720 → 화면이 작으면 줄이고 크면 키움
-------------------------------------------------------------------
local gui = new("ScreenGui", { Name = "SuneungUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = player:WaitForChild("PlayerGui") })
local root = new("Frame", { Parent = gui, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) })
local uiScale = new("UIScale", { Parent = root })

local function fit()
	local v = camera.ViewportSize
	local s = math.clamp(math.min(v.X / 1280, v.Y / 720), 0.5, 1.6)
	uiScale.Scale = s
	root.Size = UDim2.fromOffset(v.X / s, v.Y / s)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
fit()

-------------------------------------------------------------------
-- 상단 바
-------------------------------------------------------------------
local top = card({ Parent = root, Size = UDim2.new(1, -32, 0, 48), Position = UDim2.fromOffset(16, 12) })
text({ Parent = top, Text = "한국 수능 부정행위", Font = F.bold, TextSize = 18, Size = UDim2.new(0, 260, 1, 0), Position = UDim2.fromOffset(18, 0) })
local status = text({ Parent = top, Text = "대기 중", Font = F.mid, TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -440, 1, 0), Position = UDim2.new(0, 280, 0, 0) })
local moneyLabel = text({ Parent = top, Text = "", Font = F.bold, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 130, 1, 0), Position = UDim2.new(1, -148, 0, 0) })

-------------------------------------------------------------------
-- 왼쪽: 부정행위 적기
-------------------------------------------------------------------
local left = card({ Parent = root, Size = UDim2.new(0, 300, 1, -88), Position = UDim2.fromOffset(16, 72) })
pad(16).Parent = left

text({ Parent = left, Text = "부정행위 적기", Font = F.bold, TextSize = 17, Size = UDim2.new(1, 0, 0, 22) })
text({ Parent = left, Text = "세상에 있는 아무거나 적어 보세요. 적은 것마다 성공률과 적발 확률이 달라요.", TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 32), Position = UDim2.fromOffset(0, 26) })

local inputRow = new("Frame", { Parent = left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Position = UDim2.fromOffset(0, 66) })
-- 키보드가 있으면 게임이 직접 키를 받아 한글을 조합하는 입력창, 터치 전용 기기는 일반 입력칸
local useCustomField = UserInputService.KeyboardEnabled
local field = button({ Parent = inputRow, Text = "", BackgroundColor3 = C.sub, Size = UDim2.new(1, -110, 1, 0), AutoButtonColor = false, Visible = useCustomField }, false)
field.BackgroundColor3 = C.sub
local fieldText = text({ Parent = field, Text = "", TextSize = 15, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), TextTruncate = Enum.TextTruncate.AtEnd })
local modeBtn = button({ Parent = inputRow, Text = "한", TextSize = 14, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -104, 0, 0), Visible = useCustomField }, false)
local input = new("TextBox", {
	Parent = inputRow,
	Size = UDim2.new(1, -66, 1, 0),
	BackgroundColor3 = C.sub,
	Text = "",
	PlaceholderText = "예) 스마트워치, 지우개",
	PlaceholderColor3 = C.muted,
	TextColor3 = C.text,
	Font = F.reg,
	TextSize = 15,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Visible = not useCustomField,
}, { corner(8), stroke(), pad(10, 0) })
local addBtn = button({ Parent = inputRow, Text = "추가", Size = UDim2.new(0, 58, 1, 0), Position = UDim2.new(1, -58, 0, 0) })

local listTop = 116
local actionH = 240
local list = new("ScrollingFrame", { Parent = left, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -(listTop + actionH + 10)), Position = UDim2.fromOffset(0, listTop), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = C.line })
new("UIListLayout", { Parent = list, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

-- 아래쪽 동작 영역
local action = new("Frame", { Parent = left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, actionH), Position = UDim2.new(0, 0, 1, -actionH) })
new("Frame", { Parent = action, BackgroundColor3 = C.line, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1) })
local curLabel = text({ Parent = action, Text = "선택: -", Font = F.mid, TextSize = 13, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 12), TextTruncate = Enum.TextTruncate.AtEnd })
local startBtn = button({ Parent = action, Text = "시험 시작", TextSize = 16, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 38) })
local cheatBtn = button({ Parent = action, Text = "부정행위 시도", TextSize = 16, BackgroundColor3 = C.danger, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 38), Visible = false })
local leaveBtn = button({ Parent = action, Text = "몰래 나가기", TextSize = 14, Size = UDim2.new(1, 0, 0, 36), Position = UDim2.fromOffset(0, 88), Visible = false }, false)
local progBg = new("Frame", { Parent = action, BackgroundColor3 = C.sub, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.fromOffset(0, 132), Visible = false }, { corner(3) })
local progFill = new("Frame", { Parent = progBg, BackgroundColor3 = C.danger, Size = UDim2.new(0, 0, 1, 0) }, { corner(3) })
local hintLabel = text({ Parent = action, Text = "", Font = F.mid, TextSize = 13, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, 144), TextYAlignment = Enum.TextYAlignment.Top })
local logLabel = text({ Parent = action, Text = "", TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 50), Position = UDim2.fromOffset(0, 188), TextYAlignment = Enum.TextYAlignment.Top })

-------------------------------------------------------------------
-- 오른쪽 아래: 시험지
-------------------------------------------------------------------
local paper = card({ Parent = root, BackgroundColor3 = C.paper, AnchorPoint = Vector2.new(1, 1), Size = UDim2.fromOffset(460, 430), Position = UDim2.new(1, -16, 1, -16), Visible = false })
pad(22, 18).Parent = paper
local paperHead = text({ Parent = paper, Text = "2027학년도 대학수학능력시험", Font = F.mid, TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 16) })
local paperNum = text({ Parent = paper, Text = "", Font = F.mid, TextSize = 12, TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 16) })
new("Frame", { Parent = paper, BackgroundColor3 = C.text, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromOffset(0, 24) })
local qLabel = text({ Parent = paper, Text = "", Font = F.bold, TextSize = 18, Size = UDim2.new(1, 0, 0, 52), Position = UDim2.fromOffset(0, 36), TextYAlignment = Enum.TextYAlignment.Top })

local choiceBtns = {}
local picked = nil
for i = 1, 5 do
	local b = new("TextButton", {
		Parent = paper,
		Text = "",
		Font = F.reg,
		TextSize = 16,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = C.paper,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromOffset(0, 94 + (i - 1) * 46),
	}, { corner(8), pad(12, 0) })
	local st = stroke(C.line, 1)
	st.Parent = b
	b.MouseButton1Click:Connect(function()
		picked = i
		for j, other in ipairs(choiceBtns) do
			local on = j == i
			other.BackgroundColor3 = on and Color3.fromRGB(232, 237, 250) or C.paper
			other.UIStroke.Color = on and C.accent or C.line
			other.UIStroke.Thickness = on and 2 or 1
		end
	end)
	choiceBtns[i] = b
end
local submitBtn = button({ Parent = paper, Text = "답안 제출", TextSize = 16, AnchorPoint = Vector2.new(1, 1), Size = UDim2.fromOffset(140, 42), Position = UDim2.fromScale(1, 1) })
local paperMsg = text({ Parent = paper, Text = "", TextSize = 13, TextColor3 = C.danger, AnchorPoint = Vector2.new(0, 1), Size = UDim2.new(1, -150, 0, 42), Position = UDim2.fromScale(0, 1) })

-------------------------------------------------------------------
-- 영역전개 (배경 없이 사진과 대사만)
-------------------------------------------------------------------
local domain = new("Frame", { Parent = root, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Visible = false })
local domainImg = new("ImageLabel", { Parent = domain, ZIndex = 51, Image = Shared.DOMAIN_IMAGE, BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromScale(0.4, 0.45), Position = UDim2.fromScale(0.5, 0.42) })
local domainText = text({ Parent = domain, ZIndex = 52, Text = Shared.DOMAIN_LINE, Font = F.bold, TextSize = 48, TextColor3 = Color3.new(1, 1, 1), TextStrokeColor3 = Color3.fromRGB(20, 40, 90), TextStrokeTransparency = 0, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, -40, 0, 60), Position = UDim2.fromScale(0.5, 0.7) })
local domainWho = text({ Parent = domain, ZIndex = 52, Text = "", Font = F.bold, TextSize = 20, TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.2, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, -40, 0, 28), Position = UDim2.fromScale(0.5, 0.8) })

-------------------------------------------------------------------
-- 가방 (오른쪽 위)
-------------------------------------------------------------------
local bag = card({ Parent = root, AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(260, 180), Position = UDim2.new(1, -16, 0, 72) })
pad(14, 12).Parent = bag
text({ Parent = bag, Text = "가방", Font = F.bold, TextSize = 15, Size = UDim2.new(1, 0, 0, 20) })
local bagEmpty = text({ Parent = bag, Text = "비어 있음. 교실 밖 도로 건너 매점에서 살 수 있어요.", TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 26) })
local bagList = new("ScrollingFrame", { Parent = bag, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -26), Position = UDim2.fromOffset(0, 26), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = C.line })
new("UIListLayout", { Parent = bagList, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

-------------------------------------------------------------------
-- 매점 창
-------------------------------------------------------------------
local shop = new("Frame", { Parent = root, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Size = UDim2.fromScale(1, 1), ZIndex = 30, Visible = false })
local shopBox = card({ Parent = shop, ZIndex = 31, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(460, 420) })
pad(20).Parent = shopBox
text({ Parent = shopBox, ZIndex = 32, Text = "매점", Font = F.bold, TextSize = 20, Size = UDim2.new(1, 0, 0, 26) })
local shopMoney = text({ Parent = shopBox, ZIndex = 32, Text = "", Font = F.mid, TextSize = 14, TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -40, 0, 26) })
local shopClose = button({ Parent = shopBox, ZIndex = 32, Text = "X", TextSize = 14, AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(28, 26), Position = UDim2.fromScale(1, 0) }, false)
for i, it in ipairs(Shared.SHOP) do
	local row = new("Frame", { Parent = shopBox, ZIndex = 32, BackgroundColor3 = C.sub, Size = UDim2.new(1, 0, 0, 52), Position = UDim2.fromOffset(0, 38 + (i - 1) * 58) }, { corner(8) })
	text({ Parent = row, ZIndex = 33, Text = it.name, Font = F.bold, TextSize = 15, Size = UDim2.new(1, -200, 0, 20), Position = UDim2.fromOffset(12, 7) })
	text({ Parent = row, ZIndex = 33, Text = it.desc, TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, -200, 0, 16), Position = UDim2.fromOffset(12, 28) })
	text({ Parent = row, ZIndex = 33, Text = it.price .. "원", Font = F.mid, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.fromOffset(80, 52), Position = UDim2.new(1, -172, 0, 0) })
	local buy = button({ Parent = row, ZIndex = 33, Text = "구매", TextSize = 14, AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.fromOffset(72, 34), Position = UDim2.new(1, -10, 0.5, 0) })
	buy.MouseButton1Click:Connect(function()
		remote:FireServer("Buy", it.id)
	end)
end
shopClose.MouseButton1Click:Connect(function()
	shop.Visible = false
end)

-------------------------------------------------------------------
-- 부정행위 전문점 창
-------------------------------------------------------------------
local proShop = new("Frame", { Parent = root, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Size = UDim2.fromScale(1, 1), ZIndex = 30, Visible = false })
local proBox = card({ Parent = proShop, ZIndex = 31, BackgroundColor3 = Color3.fromRGB(24, 22, 34), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(560, 600) })
proBox.UIStroke.Color = Color3.fromRGB(150, 90, 240)
pad(20).Parent = proBox
local PRO_TEXT = Color3.fromRGB(235, 230, 250)
local PRO_MUTED = Color3.fromRGB(160, 150, 190)
local PRO_ACCENT = Color3.fromRGB(150, 90, 240)
text({ Parent = proBox, ZIndex = 32, Text = "부정행위 전문점", Font = F.bold, TextSize = 20, TextColor3 = PRO_TEXT, Size = UDim2.new(1, 0, 0, 26) })
text({ Parent = proBox, ZIndex = 32, Text = "세상의 모든 전자기기. 정품은 성공률 +25%, 적발 확률 -15%", TextSize = 12, TextColor3 = PRO_MUTED, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 28) })
local proMoney = text({ Parent = proBox, ZIndex = 32, Text = "", Font = F.mid, TextSize = 14, TextColor3 = PRO_MUTED, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -40, 0, 26) })
local proClose = button({ Parent = proBox, ZIndex = 32, Text = "X", TextSize = 14, AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(28, 26), Position = UDim2.fromScale(1, 0) }, false)

-- 맞춤 제작: 왼쪽 목록에서 고른 물건을 그대로 주문
local custom = new("Frame", { Parent = proBox, ZIndex = 32, BackgroundColor3 = Color3.fromRGB(40, 32, 62), Size = UDim2.new(1, 0, 0, 58), Position = UDim2.fromOffset(0, 54) }, { corner(8) })
text({ Parent = custom, ZIndex = 33, Text = "맞춤 제작", Font = F.bold, TextSize = 13, TextColor3 = Color3.fromRGB(200, 170, 255), Size = UDim2.new(1, -140, 0, 18), Position = UDim2.fromOffset(12, 8) })
local customName = text({ Parent = custom, ZIndex = 33, Text = "", Font = F.mid, TextSize = 13, TextColor3 = PRO_TEXT, Size = UDim2.new(1, -140, 0, 22), Position = UDim2.fromOffset(12, 28), TextTruncate = Enum.TextTruncate.AtEnd })
local customBtn = button({ Parent = custom, ZIndex = 33, Text = "주문", TextSize = 14, BackgroundColor3 = PRO_ACCENT, AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.fromOffset(110, 38), Position = UDim2.new(1, -10, 0.5, 0) })

local proList = new("ScrollingFrame", { Parent = proBox, ZIndex = 32, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -124), Position = UDim2.fromOffset(0, 124), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = PRO_ACCENT })
new("UIGridLayout", { Parent = proList, CellSize = UDim2.new(0.5, -6, 0, 50), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder })
local owned = {}
local proButtons = {}
for i, it in ipairs(Shared.PRO) do
	local row = new("Frame", { Parent = proList, ZIndex = 33, LayoutOrder = i, BackgroundColor3 = Color3.fromRGB(36, 32, 52) }, { corner(8) })
	text({ Parent = row, ZIndex = 34, Text = it.name, Font = F.bold, TextSize = 13, TextColor3 = PRO_TEXT, Size = UDim2.new(1, -86, 0, 18), Position = UDim2.fromOffset(10, 7), TextTruncate = Enum.TextTruncate.AtEnd })
	text({ Parent = row, ZIndex = 34, Text = it.price .. "원", TextSize = 12, TextColor3 = PRO_MUTED, Size = UDim2.new(1, -86, 0, 16), Position = UDim2.fromOffset(10, 27) })
	local b = button({ Parent = row, ZIndex = 34, Text = "구매", TextSize = 13, BackgroundColor3 = PRO_ACCENT, AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.fromOffset(66, 32), Position = UDim2.new(1, -8, 0.5, 0) })
	b.MouseButton1Click:Connect(function()
		if not owned[it.name] then
			remote:FireServer("BuyPro", it.name)
		end
	end)
	proButtons[it.name] = b
end
local function refreshProButtons()
	for name, b in pairs(proButtons) do
		local has = owned[name]
		b.Text = has and "보유" or "구매"
		b.BackgroundColor3 = has and Color3.fromRGB(70, 70, 85) or PRO_ACCENT
	end
end
proClose.MouseButton1Click:Connect(function()
	proShop.Visible = false
end)
-- customBtn 은 cheats 가 정의된 뒤에 연결 (아래)

-------------------------------------------------------------------
-- 알림
-------------------------------------------------------------------
local toastLabel = text({ Parent = root, ZIndex = 60, Text = "", Font = F.mid, TextSize = 15, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.15, BackgroundColor3 = Color3.fromRGB(31, 35, 40), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(420, 40), Position = UDim2.new(0.5, 0, 0, 72), Visible = false })
corner(8).Parent = toastLabel
local toastId = 0
local function toast(msg)
	toastId = toastId + 1
	local my = toastId
	toastLabel.Text = msg
	toastLabel.Visible = true
	task.delay(2.5, function()
		if toastId == my then
			toastLabel.Visible = false
		end
	end)
end

-------------------------------------------------------------------
-- 부정행위 물건 화면 (스마트워치면 스마트워치 화면에 정답이 뜸)
-------------------------------------------------------------------
local KINDS = {
	{ kind = "watch", words = { "워치", "시계", "watch" } },
	{ kind = "phone", words = { "폰", "핸드폰", "휴대폰", "아이패드", "태블릿", "phone" } },
	{ kind = "calc", words = { "계산기" } },
	{ kind = "palm", words = { "손바닥", "손", "팔" } },
	{ kind = "eraser", words = { "지우개" } },
	{ kind = "note", words = { "쪽지", "메모", "종이", "커닝페이퍼", "포스트잇", "필기" } },
	{ kind = "earbud", words = { "이어폰", "이어버드", "무전기", "스피커", "녹음기", "mp3", "귀" } },
	{ kind = "glasses", words = { "안경", "렌즈", "vr", "디스플레이", "카메라", "헤드셋" } },
}
local function kindOf(name, isCopy)
	if isCopy then
		return "neighbor"
	end
	for _, k in ipairs(KINDS) do
		for _, w in ipairs(k.words) do
			if string.find(string.lower(name), w, 1, true) then
				return k.kind
			end
		end
	end
	return "generic"
end

local viewHolder = new("Frame", { Parent = root, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(320, 400), Position = UDim2.new(0.5, 0, 1, 420), ZIndex = 20 })
local viewId = 0

local function z(o, n)
	o.ZIndex = n
	return o
end
local function rect(parent, color, size, pos, r, zi, props)
	props = props or {}
	props.Parent = parent
	props.BackgroundColor3 = color
	props.Size = size
	props.Position = pos
	props.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
	props.ZIndex = zi or 21
	props.BorderSizePixel = 0
	local f = new("Frame", props)
	if r then
		corner(r).Parent = f
	end
	return f
end
local function txt(parent, str, size, color, pos, zi, font, sz)
	return text({ Parent = parent, Text = str, TextSize = size, TextColor3 = color, Font = font or F.bold, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = sz or UDim2.new(1, -20, 0, size + 8), ZIndex = zi or 25 })
end

local function buildView(kind, name, ans, extra)
	local h = viewHolder
	for _, ch in ipairs(h:GetChildren()) do
		ch:Destroy()
	end
	local num = Shared.NUM[ans] or "?"
	local qn = extra.q or 0
	local center = UDim2.fromScale(0.5, 0.5)
	if kind == "watch" then
		rect(h, Color3.fromRGB(40, 42, 48), UDim2.fromOffset(120, 400), center, 24, 21)
		local case = rect(h, Color3.fromRGB(70, 72, 80), UDim2.fromOffset(230, 250), center, 60, 22)
		rect(case, Color3.fromRGB(90, 92, 100), UDim2.fromOffset(14, 46), UDim2.new(1, 4, 0.4, 0), 6, 21)
		local screen = rect(case, Color3.fromRGB(5, 5, 8), UDim2.new(1, -24, 1, -24), center, 50, 23)
		txt(screen, os.date("%H:%M"), 16, Color3.fromRGB(160, 160, 170), UDim2.fromScale(0.5, 0.17), 25, F.mid)
		txt(screen, qn .. "번 정답", 14, Color3.fromRGB(120, 200, 255), UDim2.fromScale(0.5, 0.32), 25, F.mid)
		txt(screen, num, 84, Color3.fromRGB(120, 255, 170), UDim2.fromScale(0.5, 0.62), 25, F.bold, UDim2.new(1, 0, 0, 90))
		rect(screen, Color3.fromRGB(120, 255, 170), UDim2.fromOffset(60, 4), UDim2.fromScale(0.5, 0.88), 2, 25)
	elseif kind == "phone" then
		local body = rect(h, Color3.fromRGB(20, 20, 24), UDim2.fromOffset(210, 390), center, 32, 21)
		local screen = rect(body, Color3.fromRGB(28, 44, 80), UDim2.new(1, -16, 1, -16), center, 26, 22)
		rect(screen, Color3.fromRGB(10, 10, 12), UDim2.fromOffset(70, 18), UDim2.new(0.5, 0, 0, 16), 9, 23)
		txt(screen, os.date("%H:%M"), 40, Color3.new(1, 1, 1), UDim2.fromScale(0.5, 0.2), 24, F.bold)
		local bubble = rect(screen, Color3.fromRGB(245, 245, 248), UDim2.new(1, -24, 0, 110), UDim2.fromScale(0.5, 0.55), 16, 24)
		text({ Parent = bubble, Text = "메시지 · 지금", TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, -24, 0, 16), Position = UDim2.fromOffset(12, 10), ZIndex = 25 })
		text({ Parent = bubble, Text = "답 알려줄게", Font = F.bold, TextSize = 14, Size = UDim2.new(1, -24, 0, 18), Position = UDim2.fromOffset(12, 30), ZIndex = 25 })
		text({ Parent = bubble, Text = qn .. "번 정답 " .. num, Font = F.bold, TextSize = 26, TextColor3 = C.accent, Size = UDim2.new(1, -24, 0, 34), Position = UDim2.fromOffset(12, 56), ZIndex = 25 })
	elseif kind == "calc" then
		local body = rect(h, Color3.fromRGB(50, 52, 58), UDim2.fromOffset(220, 340), center, 18, 21)
		local disp = rect(body, Color3.fromRGB(170, 190, 150), UDim2.new(1, -30, 0, 80), UDim2.new(0.5, 0, 0, 60), 6, 22)
		text({ Parent = disp, Text = qn .. "번=" .. ans, Font = Enum.Font.Code, TextSize = 40, TextColor3 = Color3.fromRGB(30, 40, 30), TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), ZIndex = 23 })
		for r = 0, 3 do
			for c = 0, 3 do
				local k = rect(body, Color3.fromRGB(90, 92, 100), UDim2.fromOffset(38, 34), UDim2.new(0, 38 + c * 48, 0, 140 + r * 46), 6, 22)
				k.AnchorPoint = Vector2.new(0.5, 0.5)
			end
		end
	elseif kind == "palm" then
		local skin = Color3.fromRGB(240, 200, 170)
		for i2, off in ipairs({ -66, -22, 22, 66 }) do
			rect(h, skin, UDim2.fromOffset(40, 130 + ((i2 == 2 or i2 == 3) and 20 or 0)), UDim2.new(0.5, off, 0.5, -150), 20, 21)
		end
		rect(h, skin, UDim2.fromOffset(40, 120), UDim2.new(0.5, -120, 0.5, 10), 20, 21).Rotation = -35
		local palm = rect(h, skin, UDim2.fromOffset(200, 230), UDim2.new(0.5, 0, 0.5, 20), 90, 22)
		local ink = txt(palm, qn .. "번 " .. num, 44, Color3.fromRGB(30, 60, 170), UDim2.fromScale(0.5, 0.45), 24, F.bold, UDim2.new(1, 0, 0, 60))
		ink.Rotation = -8
		local ink2 = txt(palm, "정답!!", 22, Color3.fromRGB(30, 60, 170), UDim2.fromScale(0.5, 0.7), 24, F.mid)
		ink2.Rotation = -6
	elseif kind == "eraser" then
		local e = rect(h, Color3.fromRGB(250, 250, 250), UDim2.fromOffset(260, 140), center, 14, 21)
		e.Rotation = -6
		stroke(C.line, 1).Parent = e
		local sleeve = rect(e, Color3.fromRGB(40, 90, 190), UDim2.new(0.5, 0, 1, 0), UDim2.fromScale(0.7, 0.5), nil, 22)
		txt(sleeve, "ERASER", 18, Color3.new(1, 1, 1), UDim2.fromScale(0.5, 0.5), 23)
		local w = txt(e, qn .. "번 " .. num, 34, Color3.fromRGB(60, 60, 60), UDim2.fromScale(0.25, 0.5), 23, F.mid, UDim2.new(0.5, 0, 0, 44))
		w.Rotation = 4
	elseif kind == "note" then
		local n = rect(h, Color3.fromRGB(255, 244, 150), UDim2.fromOffset(250, 250), center, 4, 21)
		n.Rotation = 4
		for i2 = 1, 6 do
			rect(n, Color3.fromRGB(230, 210, 110), UDim2.new(1, -30, 0, 1), UDim2.new(0.5, 0, 0, 40 + i2 * 30), nil, 22)
		end
		txt(n, "커닝 쪽지", 16, Color3.fromRGB(120, 100, 30), UDim2.fromScale(0.5, 0.12), 23, F.mid)
		txt(n, qn .. "번 → " .. num, 46, Color3.fromRGB(40, 40, 40), UDim2.fromScale(0.5, 0.5), 23, F.bold, UDim2.new(1, 0, 0, 56))
	elseif kind == "neighbor" then
		local p = rect(h, C.paper, UDim2.fromOffset(280, 300), center, 6, 21)
		p.Rotation = -5
		stroke(C.line, 1).Parent = p
		txt(p, (extra.seat or "?") .. "번 자리 답안지", 16, C.muted, UDim2.fromScale(0.5, 0.1), 23, F.mid)
		for i2 = 1, 5 do
			local y = 0.25 + (i2 - 1) * 0.14
			txt(p, Shared.NUM[i2], 26, C.text, UDim2.fromScale(0.5, y), 23, F.reg, UDim2.fromOffset(40, 34))
			if i2 == ans then
				local circle = rect(p, Color3.new(1, 1, 1), UDim2.fromOffset(44, 44), UDim2.fromScale(0.5, y), 22, 22, { BackgroundTransparency = 1 })
				stroke(C.danger, 3).Parent = circle
			end
		end
		txt(p, qn .. "번 문제", 14, C.muted, UDim2.fromScale(0.5, 0.95), 23, F.mid)
	elseif kind == "earbud" then
		local bud = rect(h, Color3.fromRGB(245, 245, 248), UDim2.fromOffset(90, 90), UDim2.new(0.5, 0, 1, -60), 45, 22)
		stroke(C.line, 1).Parent = bud
		rect(bud, Color3.fromRGB(40, 40, 45), UDim2.fromOffset(34, 34), center, 17, 23)
		for k = 1, 3 do
			local wave = rect(h, Color3.new(1, 1, 1), UDim2.fromOffset(90 + k * 50, 90 + k * 50), UDim2.new(0.5, 0, 1, -60), 200, 21, { BackgroundTransparency = 1 })
			stroke(Color3.fromRGB(120, 200, 255), 3).Parent = wave
			wave.UIStroke.Transparency = 0.2 + k * 0.2
		end
		local bubble = rect(h, Color3.fromRGB(20, 24, 36), UDim2.fromOffset(280, 110), UDim2.new(0.5, 0, 0, 80), 16, 24)
		txt(bubble, "(속삭임)", 13, Color3.fromRGB(150, 170, 200), UDim2.fromScale(0.5, 0.2), 25, F.mid)
		txt(bubble, qn .. "번… 정답은 " .. num, 30, Color3.fromRGB(120, 220, 255), UDim2.fromScale(0.5, 0.62), 25, F.bold, UDim2.new(1, 0, 0, 40))
	elseif kind == "glasses" then
		local frameC = Color3.fromRGB(25, 25, 30)
		for _, off in ipairs({ -78, 78 }) do
			local lens = rect(h, Color3.fromRGB(120, 200, 255), UDim2.fromOffset(140, 110), UDim2.new(0.5, off, 0.5, 0), 40, 22, { BackgroundTransparency = 0.55 })
			stroke(frameC, 8).Parent = lens
		end
		rect(h, frameC, UDim2.fromOffset(30, 8), UDim2.new(0.5, 0, 0.5, -20), 4, 23)
		local hud = txt(h, qn .. "번 정답 " .. num, 30, Color3.fromRGB(120, 255, 170), UDim2.new(0.5, 78, 0.5, 0), 25, F.bold, UDim2.fromOffset(140, 40))
		hud.TextScaled = true
		txt(h, "HUD", 12, Color3.fromRGB(120, 255, 170), UDim2.new(0.5, 78, 0.5, -36), 25, F.mid, UDim2.fromOffset(140, 16))
	else
		local c2 = rect(h, C.surface, UDim2.fromOffset(260, 220), center, 18, 21)
		stroke(C.line, 1).Parent = c2
		txt(c2, name, 20, C.text, UDim2.fromScale(0.5, 0.18), 23, F.bold)
		txt(c2, "이(가) 속삭인다…", 13, C.muted, UDim2.fromScale(0.5, 0.32), 23, F.mid)
		txt(c2, qn .. "번 정답 " .. num, 40, C.accent, UDim2.fromScale(0.5, 0.65), 23, F.bold, UDim2.new(1, 0, 0, 50))
	end
end

local function showCheatView(name, isCopy, ans, extra)
	viewId = viewId + 1
	local my = viewId
	buildView(kindOf(name, isCopy), name, ans, extra)
	viewHolder.Position = UDim2.new(0.5, 0, 1, 420)
	TweenService:Create(viewHolder, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 1, -20) }):Play()
	task.delay(4, function()
		if viewId == my then
			TweenService:Create(viewHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 1, 420) }):Play()
		end
	end)
end

-------------------------------------------------------------------
-- 결과창
-------------------------------------------------------------------
local modal = new("Frame", { Parent = root, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Size = UDim2.fromScale(1, 1), ZIndex = 40, Visible = false })
local box = card({ Parent = modal, ZIndex = 41, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(380, 280) })
pad(24).Parent = box
local mTitle = text({ Parent = box, ZIndex = 42, Text = "", Font = F.bold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 28) })
local mGrade = text({ Parent = box, ZIndex = 42, Text = "", Font = F.bold, TextSize = 52, TextColor3 = C.accent, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 70), Position = UDim2.fromOffset(0, 36) })
local mDesc = text({ Parent = box, ZIndex = 42, Text = "", TextSize = 14, TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 112) })
local retryBtn = button({ Parent = box, ZIndex = 42, Text = "확인", TextSize = 16, AnchorPoint = Vector2.new(0, 1), Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromScale(0, 1) })

-------------------------------------------------------------------
-- 부정행위 목록
-------------------------------------------------------------------
local cheats = {}
local selected = 1

local function meter(parent, y, name, pct, color)
	text({ Parent = parent, Text = name, TextSize = 11, TextColor3 = C.muted, Size = UDim2.new(0, 60, 0, 12), Position = UDim2.fromOffset(0, y) })
	text({ Parent = parent, Text = pct .. "%", Font = F.mid, TextSize = 11, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 40, 0, 12), Position = UDim2.new(1, -40, 0, y) })
	local bg = new("Frame", { Parent = parent, BackgroundColor3 = C.sub, Size = UDim2.new(1, -120, 0, 4), Position = UDim2.fromOffset(64, y + 4) }, { corner(2) })
	new("Frame", { Parent = bg, BackgroundColor3 = color, Size = UDim2.new(pct / 100, 0, 1, 0) }, { corner(2) })
end

local function renderCheats()
	for _, ch in ipairs(list:GetChildren()) do
		if ch:IsA("GuiObject") then
			ch:Destroy()
		end
	end
	for i, c in ipairs(cheats) do
		local on = i == selected
		local item = new("TextButton", { Parent = list, LayoutOrder = i, Text = "", AutoButtonColor = false, BackgroundColor3 = on and Color3.fromRGB(240, 243, 251) or C.surface, Size = UDim2.new(1, -4, 0, 76) }, { corner(8), pad(12, 10) })
		local st = stroke(on and C.accent or C.line, on and 2 or 1)
		st.Parent = item
		text({ Parent = item, Text = c.name, Font = F.bold, TextSize = 14, Size = UDim2.new(1, -90, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
		text({ Parent = item, Text = c.type, TextSize = 11, TextColor3 = c.pro and Color3.fromRGB(130, 70, 220) or C.muted, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 90, 0, 18), Position = UDim2.new(1, -90, 0, 0) })
		meter(item, 26, "성공률", c.success, C.ok)
		meter(item, 42, "적발 확률", c.risk, C.danger)
		item.MouseButton1Click:Connect(function()
			selected = i
			renderCheats()
		end)
	end
	curLabel.Text = "선택: " .. (cheats[selected] and cheats[selected].name or "-")
end

local function addCheat(name)
	name = string.gsub(name or "", "^%s+", "")
	name = string.gsub(name, "%s+$", "")
	name = Shared.clip(name, 20)
	if name == "" then
		return
	end
	for i, c in ipairs(cheats) do
		if c.name == name then
			selected = i
			renderCheats()
			return
		end
	end
	table.insert(cheats, 1, Shared.makeCheat(name, owned[name]))
	selected = 1
	renderCheats()
end

for _, n in ipairs({ "옆자리 친구", "손바닥 필기", "스마트워치" }) do
	addCheat(n)
end

customBtn.MouseButton1Click:Connect(function()
	local c = cheats[selected]
	if c then
		if owned[c.name] then
			toast("이미 정품을 가지고 있어요.")
		else
			remote:FireServer("BuyPro", c.name)
		end
	end
end)

-------------------------------------------------------------------
-- 한글 입력기 (두벌식)
-- Roblox 입력칸은 한글 조합(IME)이 안 되는 경우가 있어서
-- 누른 키를 직접 받아서 한글로 조합합니다.
-------------------------------------------------------------------
local CHO = { "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ" }
local JUNG = { "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ" }
local JONG = { "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ" }
local CHO_I, JUNG_I, JONG_I = {}, {}, {}
for i, v in ipairs(CHO) do
	CHO_I[v] = i - 1
end
for i, v in ipairs(JUNG) do
	JUNG_I[v] = i - 1
end
for i, v in ipairs(JONG) do
	JONG_I[v] = i
end
local VCOMB = { ["ㅗㅏ"] = "ㅘ", ["ㅗㅐ"] = "ㅙ", ["ㅗㅣ"] = "ㅚ", ["ㅜㅓ"] = "ㅝ", ["ㅜㅔ"] = "ㅞ", ["ㅜㅣ"] = "ㅟ", ["ㅡㅣ"] = "ㅢ" }
local JCOMB = { ["ㄱㅅ"] = "ㄳ", ["ㄴㅈ"] = "ㄵ", ["ㄴㅎ"] = "ㄶ", ["ㄹㄱ"] = "ㄺ", ["ㄹㅁ"] = "ㄻ", ["ㄹㅂ"] = "ㄼ", ["ㄹㅅ"] = "ㄽ", ["ㄹㅌ"] = "ㄾ", ["ㄹㅍ"] = "ㄿ", ["ㄹㅎ"] = "ㅀ", ["ㅂㅅ"] = "ㅄ" }
local JSPLIT = {}
for k, v in pairs(JCOMB) do
	JSPLIT[v] = { string.sub(k, 1, 3), string.sub(k, 4, 6) } -- 자모는 3바이트
end
local KEYMAP = {
	Q = "ㅂ", W = "ㅈ", E = "ㄷ", R = "ㄱ", T = "ㅅ", Y = "ㅛ", U = "ㅕ", I = "ㅑ", O = "ㅐ", P = "ㅔ",
	A = "ㅁ", S = "ㄴ", D = "ㅇ", F = "ㄹ", G = "ㅎ", H = "ㅗ", J = "ㅓ", K = "ㅏ", L = "ㅣ",
	Z = "ㅋ", X = "ㅌ", C = "ㅊ", V = "ㅍ", B = "ㅠ", N = "ㅜ", M = "ㅡ",
}
local SHIFTMAP = { Q = "ㅃ", W = "ㅉ", E = "ㄸ", R = "ㄲ", T = "ㅆ", O = "ㅒ", P = "ㅖ" }
local DIGITS = { Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9" }

-- 입력한 자모/글자 목록 → 완성된 문자열
local function compose(units)
	local out = {}
	local cho, jung, jong
	local function flush()
		if cho and jung then
			out[#out + 1] = utf8.char(0xAC00 + (CHO_I[cho] * 21 + JUNG_I[jung]) * 28 + (jong and JONG_I[jong] or 0))
		elseif cho then
			out[#out + 1] = cho
		elseif jung then
			out[#out + 1] = jung
		end
		cho, jung, jong = nil, nil, nil
	end
	for _, u in ipairs(units) do
		if CHO_I[u] then -- 자음
			if cho and jung then
				if not jong then
					if JONG_I[u] then
						jong = u
					else
						flush()
						cho = u
					end
				elseif JCOMB[jong .. u] then
					jong = JCOMB[jong .. u]
				else
					flush()
					cho = u
				end
			else
				flush()
				cho = u
			end
		elseif JUNG_I[u] then -- 모음
			if cho and jung and jong then
				local nextCho
				if JSPLIT[jong] then
					jong, nextCho = JSPLIT[jong][1], JSPLIT[jong][2]
				else
					jong, nextCho = nil, jong
				end
				flush()
				cho, jung = nextCho, u
			elseif jung then
				if VCOMB[jung .. u] then
					jung = VCOMB[jung .. u]
				else
					flush()
					jung = u
				end
			else
				jung = u
			end
		else -- 영어, 숫자, 띄어쓰기
			flush()
			out[#out + 1] = u
		end
	end
	flush()
	return table.concat(out)
end

local units = {}
local hangulMode = true
local focused = false
local caretOn = true

local function refreshField()
	local str = compose(units)
	if str == "" and not focused then
		fieldText.Text = "예) 스마트워치, 지우개"
		fieldText.TextColor3 = C.muted
	else
		fieldText.Text = str .. ((focused and caretOn) and "|" or "")
		fieldText.TextColor3 = C.text
	end
	field.UIStroke.Color = focused and C.accent or C.line
	modeBtn.Text = hangulMode and "한" or "A"
end

local function submitInput()
	if useCustomField then
		local t = compose(units)
		units = {}
		refreshField()
		addCheat(t)
	else
		task.defer(function()
			local t = input.Text
			input.Text = ""
			addCheat(t)
		end)
	end
end

local function setFocus(on)
	if focused == on then
		return
	end
	focused = on
	if on then
		ContextActionService:BindActionAtPriority("SuneungTyping", function(_, state, obj)
			if state ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Sink
			end
			local key = obj.KeyCode
			local name = key.Name
			local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			if key == Enum.KeyCode.Return or key == Enum.KeyCode.KeypadEnter then
				submitInput()
			elseif key == Enum.KeyCode.Escape then
				setFocus(false)
			elseif key == Enum.KeyCode.Backspace then
				table.remove(units)
			elseif key == Enum.KeyCode.Space then
				table.insert(units, " ")
			elseif key == Enum.KeyCode.RightAlt or key == Enum.KeyCode.Tab then
				hangulMode = not hangulMode
			elseif DIGITS[name] then
				table.insert(units, DIGITS[name])
			elseif KEYMAP[name] then
				if hangulMode then
					table.insert(units, (shift and SHIFTMAP[name]) or KEYMAP[name])
				else
					table.insert(units, shift and name or string.lower(name))
				end
			end
			-- 20자 넘으면 마지막 입력 취소
			if utf8.len(compose(units)) > 20 then
				table.remove(units)
			end
			refreshField()
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value + 100,
		Enum.KeyCode.A, Enum.KeyCode.B, Enum.KeyCode.C, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.G,
		Enum.KeyCode.H, Enum.KeyCode.I, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.M, Enum.KeyCode.N,
		Enum.KeyCode.O, Enum.KeyCode.P, Enum.KeyCode.Q, Enum.KeyCode.R, Enum.KeyCode.S, Enum.KeyCode.T, Enum.KeyCode.U,
		Enum.KeyCode.V, Enum.KeyCode.W, Enum.KeyCode.X, Enum.KeyCode.Y, Enum.KeyCode.Z,
		Enum.KeyCode.Zero, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four,
		Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine,
		Enum.KeyCode.Space, Enum.KeyCode.Backspace, Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter,
		Enum.KeyCode.Escape, Enum.KeyCode.RightAlt, Enum.KeyCode.Tab)
	else
		ContextActionService:UnbindAction("SuneungTyping")
	end
	refreshField()
end

field.MouseButton1Click:Connect(function()
	setFocus(true)
end)
modeBtn.MouseButton1Click:Connect(function()
	hangulMode = not hangulMode
	setFocus(true)
	refreshField()
end)
-- 입력창 밖을 클릭하면 입력 끝
UserInputService.InputBegan:Connect(function(obj)
	if focused and obj.UserInputType == Enum.UserInputType.MouseButton1 then
		local p = obj.Position
		local function inside(g)
			local a, s = g.AbsolutePosition, g.AbsoluteSize
			return p.X >= a.X and p.X <= a.X + s.X and p.Y >= a.Y and p.Y <= a.Y + s.Y
		end
		if not (inside(field) or inside(modeBtn) or inside(addBtn)) then
			setFocus(false)
		end
	end
end)
task.spawn(function()
	while true do
		task.wait(0.5)
		caretOn = not caretOn
		if focused then
			refreshField()
		end
	end
end)
refreshField()

addBtn.MouseButton1Click:Connect(submitInput)
input.FocusLost:Connect(function(enter)
	if enter then
		submitInput()
	end
end)

-------------------------------------------------------------------
-- 시험 진행
-------------------------------------------------------------------
local logs = {}
local timeLeft, suspicion, qNum, qTotal = Shared.TIME_LIMIT, 0, 0, Shared.TOTAL_Q
local cheatingUntil = nil
local cheatDur = Shared.CHEAT_TIME
local inExam = false

local function updateStatus()
	if not inExam then
		status.Text = "대기 중"
		return
	end
	status.Text = string.format("문제 %d / %d     남은 시간 %d:%02d     의심도 %d%%", qNum, qTotal, math.floor(timeLeft / 60), timeLeft % 60, suspicion)
end

local function setExamMode(on)
	inExam = on
	startBtn.Visible = not on
	cheatBtn.Visible = on
	leaveBtn.Visible = on
	leaveBtn.Text = "몰래 나가기"
	paper.Visible = on
	progBg.Visible = false
	hintLabel.Text = ""
	updateStatus()
end

startBtn.MouseButton1Click:Connect(function()
	local c = cheats[selected]
	if c then
		remote:FireServer("Start", c.name)
	end
end)

local away = false
leaveBtn.MouseButton1Click:Connect(function()
	remote:FireServer(away and "Return" or "Leave")
end)

local function renderBag(inv)
	for _, ch in ipairs(bagList:GetChildren()) do
		if ch:IsA("GuiObject") then
			ch:Destroy()
		end
	end
	local any = false
	for i, it in ipairs(Shared.SHOP) do
		local n = inv[it.id]
		if n and n > 0 then
			any = true
			local row = new("Frame", { Parent = bagList, LayoutOrder = i, BackgroundColor3 = C.sub, Size = UDim2.new(1, -4, 0, 32) }, { corner(6) })
			text({ Parent = row, Text = it.name .. "  x" .. n, Font = F.mid, TextSize = 13, Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(10, 0) })
			local eat = button({ Parent = row, Text = "먹기", TextSize = 12, AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.fromOffset(52, 24), Position = UDim2.new(1, -4, 0.5, 0) })
			eat.MouseButton1Click:Connect(function()
				remote:FireServer("Eat", it.id)
			end)
		end
	end
	bagEmpty.Visible = not any
end
renderBag({})

local function showMoney(v)
	moneyLabel.Text = v .. "원"
	shopMoney.Text = "가진 돈 " .. v .. "원"
	proMoney.Text = "가진 돈 " .. v .. "원"
end
task.spawn(function()
	local ls = player:WaitForChild("leaderstats")
	local m = ls:WaitForChild("돈")
	showMoney(m.Value)
	m.Changed:Connect(showMoney)
end)

cheatBtn.MouseButton1Click:Connect(function()
	local c = cheats[selected]
	if c and not cheatingUntil then
		remote:FireServer("Cheat", c.name)
	end
end)

submitBtn.MouseButton1Click:Connect(function()
	if not picked then
		paperMsg.Text = "답을 선택하세요."
		return
	end
	paperMsg.Text = ""
	remote:FireServer("Answer", picked)
end)

retryBtn.MouseButton1Click:Connect(function()
	modal.Visible = false
	setExamMode(false)
end)

RunService.RenderStepped:Connect(function()
	if cheatingUntil then
		local remain = cheatingUntil - os.clock()
		progFill.Size = UDim2.new(math.clamp(1 - remain / cheatDur, 0, 1), 0, 1, 0)
	end
end)

local function showDomain(who)
	domainWho.Text = who .. " 적발"
	domainImg.Visible = Shared.DOMAIN_IMAGE ~= "rbxassetid://0"
	domainImg.ImageTransparency = 1
	domainText.TextTransparency = 1
	domainText.TextStrokeTransparency = 1
	domainImg.Size = UDim2.fromScale(0.55, 0.6)
	domain.Visible = true
	local fast = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(domainImg, fast, { ImageTransparency = 0, Size = UDim2.fromScale(0.4, 0.45) }):Play()
	TweenService:Create(domainText, fast, { TextTransparency = 0, TextStrokeTransparency = 0 }):Play()
	local base = UDim2.fromScale(0.5, 0.42)
	local t0 = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if os.clock() - t0 > 1.5 then
			conn:Disconnect()
			domainImg.Position = base
			return
		end
		domainImg.Position = base + UDim2.fromOffset(math.random(-3, 3), math.random(-3, 3))
	end)
	task.delay(1.5, function()
		local slow = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(domainImg, slow, { ImageTransparency = 1, Size = UDim2.fromScale(0.3, 0.32) }):Play()
		TweenService:Create(domainText, slow, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		task.wait(0.5)
		domain.Visible = false
	end)
end

remote.OnClientEvent:Connect(function(action, data, extra)
	if action == "Question" then
		if not inExam then
			setExamMode(true)
		end
		modal.Visible = false
		qNum, qTotal = data.num, data.total
		if data.num == 1 then
			timeLeft, suspicion = Shared.TIME_LIMIT, 0
		end
		paperNum.Text = data.seat .. "번 좌석"
		qLabel.Text = data.num .. ".  " .. data.text
		picked = nil
		paperMsg.Text = ""
		for i, b in ipairs(choiceBtns) do
			b.Text = Shared.NUM[i] .. "   " .. tostring(data.options[i])
			b.BackgroundColor3 = C.paper
			b.UIStroke.Color = C.line
			b.UIStroke.Thickness = 1
		end
		hintLabel.Text = ""
		updateStatus()
	elseif action == "Timer" then
		timeLeft, suspicion = data, extra
		updateStatus()
	elseif action == "CheatStart" then
		cheatDur = data
		cheatingUntil = os.clock() + data
		progBg.Visible = true
		hintLabel.TextColor3 = C.muted
		hintLabel.Text = "시도 중…"
	elseif action == "Hint" or action == "CheatCancel" then
		cheatingUntil = nil
		progBg.Visible = false
		if action == "Hint" then
			hintLabel.TextColor3 = C.ok
			hintLabel.Text = data
			if type(extra) == "table" and extra.ans then
				local c = cheats[selected]
				showCheatView(c and c.name or "", c and c.copy, extra.ans, extra)
			end
		end
	elseif action == "Domain" then
		cheatingUntil = nil
		progBg.Visible = false
		showDomain(data)
	elseif action == "Log" then
		table.insert(logs, 1, data)
		if #logs > 3 then
			table.remove(logs)
		end
		logLabel.Text = table.concat(logs, "\n")
	elseif action == "Away" then
		away = data
		leaveBtn.Text = away and "자리로 돌아가기" or "몰래 나가기"
		paper.Visible = not away
		cheatBtn.Visible = not away
		if away then
			toast("감독관 시야(빨간 빛)를 피해 문으로 나가세요. 돌아오면 자리 근처에서 버튼을 누르세요.")
		end
	elseif action == "Toast" then
		toast(data)
	elseif action == "Inventory" then
		renderBag(data)
	elseif action == "Money" then
		showMoney(data)
	elseif action == "OpenProShop" then
		proMoney.Text = "가진 돈 " .. data .. "원"
		local c = cheats[selected]
		if c then
			customName.Text = c.name .. "  ·  " .. Shared.proPrice(c.name) .. "원"
		else
			customName.Text = "왼쪽에서 물건을 고르세요"
		end
		refreshProButtons()
		proShop.Visible = true
	elseif action == "Owned" then
		owned = {}
		for _, n in ipairs(data) do
			owned[n] = true
		end
		for i, c in ipairs(cheats) do
			cheats[i] = Shared.makeCheat(c.name, owned[c.name])
		end
		if extra then
			addCheat(extra)
		end
		renderCheats()
		refreshProButtons()
	elseif action == "OpenShop" then
		showMoney(data)
		shop.Visible = true
	elseif action == "End" then
		cheatingUntil = nil
		away = false
		progBg.Visible = false
		paper.Visible = false
		if data.reason == "car" then
			mTitle.Text = "교통사고"
			mGrade.Text = "실격"
			mGrade.TextColor3 = C.danger
			mDesc.Text = string.format("시험 중 몰래 나갔다가 차에 치였습니다.\n푼 문제 %d개 중 %d개 정답", data.answered, data.score)
		elseif data.reason == "caught" then
			mTitle.Text = "부정행위 적발"
			mGrade.Text = "실격"
			mGrade.TextColor3 = C.danger
			mDesc.Text = string.format("가루가 되었습니다.\n푼 문제 %d개 중 %d개 정답", data.answered, data.score)
		else
			mTitle.Text = data.timeUp and "시험 시간 종료" or "시험 종료"
			mGrade.Text = data.grade .. "등급"
			mGrade.TextColor3 = C.accent
			mDesc.Text = string.format("%d문제 중 %d개 정답", Shared.TOTAL_Q, data.score)
		end
		modal.Visible = true
	end
end)

updateStatus()
