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
local status = text({ Parent = top, Text = "대기 중", Font = F.mid, TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -300, 1, 0), Position = UDim2.new(0, 280, 0, 0) })

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
local actionH = 196
local list = new("ScrollingFrame", { Parent = left, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -(listTop + actionH + 10)), Position = UDim2.fromOffset(0, listTop), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = C.line })
new("UIListLayout", { Parent = list, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

-- 아래쪽 동작 영역
local action = new("Frame", { Parent = left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, actionH), Position = UDim2.new(0, 0, 1, -actionH) })
new("Frame", { Parent = action, BackgroundColor3 = C.line, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1) })
local curLabel = text({ Parent = action, Text = "선택: -", Font = F.mid, TextSize = 13, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 12), TextTruncate = Enum.TextTruncate.AtEnd })
local startBtn = button({ Parent = action, Text = "시험 시작", TextSize = 16, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 38) })
local cheatBtn = button({ Parent = action, Text = "부정행위 시도", TextSize = 16, BackgroundColor3 = C.danger, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 38), Visible = false })
local progBg = new("Frame", { Parent = action, BackgroundColor3 = C.sub, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.fromOffset(0, 90), Visible = false }, { corner(3) })
local progFill = new("Frame", { Parent = progBg, BackgroundColor3 = C.danger, Size = UDim2.new(0, 0, 1, 0) }, { corner(3) })
local hintLabel = text({ Parent = action, Text = "", Font = F.mid, TextSize = 13, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, 100), TextYAlignment = Enum.TextYAlignment.Top })
local logLabel = text({ Parent = action, Text = "", TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 50), Position = UDim2.fromOffset(0, 144), TextYAlignment = Enum.TextYAlignment.Top })

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
		text({ Parent = item, Text = c.type, TextSize = 11, TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 90, 0, 18), Position = UDim2.new(1, -90, 0, 0) })
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
	table.insert(cheats, 1, Shared.makeCheat(name))
	selected = 1
	renderCheats()
end

for _, n in ipairs({ "옆자리 친구", "손바닥 필기", "스마트워치" }) do
	addCheat(n)
end

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
	elseif action == "End" then
		cheatingUntil = nil
		progBg.Visible = false
		paper.Visible = false
		if data.caught then
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
