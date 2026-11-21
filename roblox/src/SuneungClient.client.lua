-- 한국 수능 부정행위! : 클라이언트 UI (StarterPlayerScripts)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Shared = require(ReplicatedStorage:WaitForChild("SuneungShared"))
local remote = ReplicatedStorage:WaitForChild("SuneungEvent")
local player = Players.LocalPlayer

-------------------------------------------------------------------
-- UI 도우미
-------------------------------------------------------------------
local C = {
	bg = Color3.fromRGB(27, 29, 36),
	panel = Color3.fromRGB(38, 41, 52),
	panel2 = Color3.fromRGB(48, 52, 74),
	line = Color3.fromRGB(61, 66, 88),
	text = Color3.fromRGB(241, 241, 246),
	muted = Color3.fromRGB(154, 159, 184),
	accent = Color3.fromRGB(255, 77, 109),
	good = Color3.fromRGB(61, 220, 151),
	warn = Color3.fromRGB(255, 200, 87),
	paper = Color3.fromRGB(251, 247, 234),
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
	return new("UICorner", { CornerRadius = UDim.new(0, r or 10) })
end
local function stroke(color, t)
	return new("UIStroke", { Color = color or C.line, Thickness = t or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end
local function pad(n)
	return new("UIPadding", { PaddingTop = UDim.new(0, n), PaddingBottom = UDim.new(0, n), PaddingLeft = UDim.new(0, n), PaddingRight = UDim.new(0, n) })
end
local function label(props)
	props.BackgroundTransparency = props.BackgroundTransparency or 1
	props.Font = props.Font or Enum.Font.GothamBold
	props.TextColor3 = props.TextColor3 or C.text
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextWrapped = true
	return new("TextLabel", props)
end
local function button(props)
	props.Font = props.Font or Enum.Font.GothamBold
	props.TextColor3 = props.TextColor3 or Color3.new(1, 1, 1)
	props.BackgroundColor3 = props.BackgroundColor3 or C.accent
	props.AutoButtonColor = true
	local b = new("TextButton", props, { corner(10) })
	return b
end

local gui = new("ScreenGui", { Name = "SuneungUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = player:WaitForChild("PlayerGui") })

-- 제목
label({ Parent = gui, Text = "한국 수능 부정행위!", Font = Enum.Font.GothamBlack, TextSize = 34, TextColor3 = C.accent, TextStrokeTransparency = 0, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 8) })

-------------------------------------------------------------------
-- 왼쪽: 부정행위 적기!
-------------------------------------------------------------------
local left = new("Frame", { Parent = gui, BackgroundColor3 = C.panel, Size = UDim2.new(0, 300, 1, -80), Position = UDim2.fromOffset(12, 64) }, { corner(14), stroke(), pad(14) })
new("UIListLayout", { Parent = left, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

label({ Parent = left, LayoutOrder = 1, Text = "✏️ 부정행위 적기!", Font = Enum.Font.GothamBlack, TextSize = 24, TextColor3 = C.warn, Size = UDim2.new(1, 0, 0, 30) })
local row = new("Frame", { Parent = left, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40) })
local input = new("TextBox", { Parent = row, Size = UDim2.new(1, -72, 1, 0), BackgroundColor3 = C.bg, TextColor3 = C.text, PlaceholderText = "예) 스마트워치, 비둘기…", PlaceholderColor3 = C.muted, Text = "", Font = Enum.Font.Gotham, TextSize = 16, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left }, { corner(10), stroke(), pad(8) })
local addBtn = button({ Parent = row, Text = "추가", TextSize = 16, BackgroundColor3 = C.warn, TextColor3 = Color3.fromRGB(34, 34, 17), Size = UDim2.new(0, 64, 1, 0), Position = UDim2.new(1, -64, 0, 0) })
label({ Parent = left, LayoutOrder = 3, Text = "아무거나 적으면 그걸로 부정행위를 해요. 적은 것마다 성공률·위험도가 달라요!", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 30) })

local list = new("ScrollingFrame", { Parent = left, LayoutOrder = 4, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0.42, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, BorderSizePixel = 0 })
new("UIListLayout", { Parent = list, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

local startBtn = button({ Parent = left, LayoutOrder = 5, Text = "📝 시험 시작", TextSize = 20, Size = UDim2.new(1, 0, 0, 48) })

local cheatBox = new("Frame", { Parent = left, LayoutOrder = 6, BackgroundColor3 = C.panel2, Size = UDim2.new(1, 0, 0, 200), Visible = false }, { corner(10), pad(10) })
local curLabel = label({ Parent = cheatBox, Text = "사용 중: -", TextSize = 15, TextColor3 = C.warn, Size = UDim2.new(1, 0, 0, 22) })
local cheatBtn = button({ Parent = cheatBox, Text = "🤫 부정행위 하기!", TextSize = 20, Size = UDim2.new(1, 0, 0, 46), Position = UDim2.fromOffset(0, 28) })
local progBg = new("Frame", { Parent = cheatBox, BackgroundColor3 = C.bg, Size = UDim2.new(1, 0, 0, 10), Position = UDim2.fromOffset(0, 82), Visible = false }, { corner(5) })
local progFill = new("Frame", { Parent = progBg, BackgroundColor3 = C.warn, Size = UDim2.new(0, 0, 1, 0) }, { corner(5) })
local hintLabel = label({ Parent = cheatBox, Text = "", TextSize = 14, TextColor3 = C.good, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 98) })
local logLabel = label({ Parent = cheatBox, Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 52), Position = UDim2.fromOffset(0, 144), TextYAlignment = Enum.TextYAlignment.Top })

-------------------------------------------------------------------
-- 오른쪽 아래: 시험지
-------------------------------------------------------------------
local paper = new("Frame", { Parent = gui, BackgroundColor3 = C.paper, Size = UDim2.new(0, 440, 0, 380), Position = UDim2.new(1, -452, 1, -392), Visible = false }, { corner(6), pad(16) })
local hud = label({ Parent = paper, Text = "", TextSize = 13, TextColor3 = Color3.fromRGB(100, 100, 100), Size = UDim2.new(1, 0, 0, 18) })
new("Frame", { Parent = paper, BackgroundColor3 = Color3.fromRGB(34, 34, 34), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromOffset(0, 22) })
local qLabel = label({ Parent = paper, Text = "", TextSize = 18, TextColor3 = Color3.fromRGB(34, 34, 34), Size = UDim2.new(1, 0, 0, 48), Position = UDim2.fromOffset(0, 30) })
local choiceBtns = {}
local picked = nil
for i = 1, 5 do
	local b = new("TextButton", { Parent = paper, Text = "", Font = Enum.Font.Gotham, TextSize = 16, TextColor3 = Color3.fromRGB(34, 34, 34), TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = Color3.fromRGB(239, 231, 207), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Position = UDim2.fromOffset(0, 82 + (i - 1) * 40), AutoButtonColor = false }, { corner(6), pad(8) })
	local st = stroke(Color3.fromRGB(34, 34, 34), 2)
	st.Enabled = false
	st.Parent = b
	b.MouseButton1Click:Connect(function()
		picked = i
		for j, other in ipairs(choiceBtns) do
			other.BackgroundTransparency = j == i and 0 or 1
			other.UIStroke.Enabled = j == i
		end
	end)
	choiceBtns[i] = b
end
local submitBtn = button({ Parent = paper, Text = "답 제출 ➜", TextSize = 18, BackgroundColor3 = C.good, TextColor3 = Color3.fromRGB(16, 34, 17), Size = UDim2.new(0, 140, 0, 40), Position = UDim2.new(0, 0, 1, -40) })

-------------------------------------------------------------------
-- 영역전개 오버레이
-------------------------------------------------------------------
-- 배경 없이 사진과 대사만 화면 위에 뜸 (검은 화면 없음)
local domain = new("Frame", { Parent = gui, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Visible = false })
local domainImg = new("ImageLabel", { Parent = domain, ZIndex = 51, Image = Shared.DOMAIN_IMAGE, BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromScale(0.45, 0.5), Position = UDim2.fromScale(0.5, 0.42) })
local domainText = label({ Parent = domain, ZIndex = 52, Text = "\"" .. Shared.DOMAIN_LINE .. "\"", Font = Enum.Font.GothamBlack, TextSize = 54, TextColor3 = Color3.new(1, 1, 1), TextStrokeColor3 = Color3.fromRGB(76, 201, 240), TextStrokeTransparency = 0, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, -20, 0, 70), Position = UDim2.fromScale(0.5, 0.72) })
local domainWho = label({ Parent = domain, ZIndex = 52, Text = "", TextSize = 22, TextColor3 = C.accent, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, -20, 0, 30), Position = UDim2.fromScale(0.5, 0.84) })

-------------------------------------------------------------------
-- 결과창
-------------------------------------------------------------------
local modal = new("Frame", { Parent = gui, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), ZIndex = 40, Visible = false })
local box = new("Frame", { Parent = modal, ZIndex = 41, BackgroundColor3 = C.panel, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(420, 300) }, { corner(16), stroke(C.accent, 3), pad(20) })
local mTitle = label({ Parent = box, ZIndex = 42, Text = "", Font = Enum.Font.GothamBlack, TextSize = 30, TextColor3 = C.accent, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 40) })
local mGrade = label({ Parent = box, ZIndex = 42, Text = "", Font = Enum.Font.GothamBlack, TextSize = 60, TextColor3 = C.warn, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 80), Position = UDim2.fromOffset(0, 44) })
local mDesc = label({ Parent = box, ZIndex = 42, Text = "", Font = Enum.Font.Gotham, TextSize = 16, TextColor3 = C.muted, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 50), Position = UDim2.fromOffset(0, 130) })
local retryBtn = button({ Parent = box, ZIndex = 42, Text = "다시 하기", TextSize = 20, Size = UDim2.new(1, 0, 0, 48), Position = UDim2.new(0, 0, 1, -48) })

-------------------------------------------------------------------
-- 부정행위 목록
-------------------------------------------------------------------
local cheats = {}
local selected = 1

local function bar(parent, y, pct, color)
	local bg = new("Frame", { Parent = parent, BackgroundColor3 = C.bg, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.fromOffset(0, y) }, { corner(3) })
	new("Frame", { Parent = bg, BackgroundColor3 = color, Size = UDim2.new(pct / 100, 0, 1, 0) }, { corner(3) })
end

local function renderCheats()
	for _, ch in ipairs(list:GetChildren()) do
		if ch:IsA("GuiObject") then
			ch:Destroy()
		end
	end
	for i, c in ipairs(cheats) do
		local card = new("TextButton", { Parent = list, LayoutOrder = i, Text = "", AutoButtonColor = true, BackgroundColor3 = C.panel2, Size = UDim2.new(1, -6, 0, 98) }, { corner(10), pad(8) })
		local st = stroke(i == selected and C.warn or C.panel2, 2)
		st.Parent = card
		label({ Parent = card, Text = c.name, Font = Enum.Font.GothamBlack, TextSize = 15, Size = UDim2.new(1, 0, 0, 18) })
		label({ Parent = card, Text = c.type, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(76, 201, 240), Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 20) })
		label({ Parent = card, Text = "성공률 " .. c.success .. "%", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 38) })
		bar(card, 53, c.success, C.good)
		label({ Parent = card, Text = "들킬 확률 " .. c.risk .. "%", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.muted, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 62) })
		bar(card, 77, c.risk, C.accent)
		card.MouseButton1Click:Connect(function()
			selected = i
			curLabel.Text = "사용 중: " .. c.name
			renderCheats()
		end)
	end
	if cheats[selected] then
		curLabel.Text = "사용 중: " .. cheats[selected].name
	end
end

local function addCheat(name)
	name = string.gsub(name, "^%s+", "")
	name = string.gsub(name, "%s+$", "")
	if name == "" then
		return
	end
	name = string.sub(name, 1, 40)
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

addBtn.MouseButton1Click:Connect(function()
	addCheat(input.Text)
	input.Text = ""
end)
input.FocusLost:Connect(function(enter)
	if enter then
		addCheat(input.Text)
		input.Text = ""
	end
end)

-------------------------------------------------------------------
-- 시험 진행
-------------------------------------------------------------------
local logs = {}
local timeLeft, suspicion, qNum, qTotal = Shared.TIME_LIMIT, 0, 0, Shared.TOTAL_Q
local cheatingUntil = nil
local cheatDur = Shared.CHEAT_TIME

local function updateHud()
	hud.Text = string.format("문제 %d / %d   ⏱ %d:%02d   👀 의심도 %d%%", qNum, qTotal, math.floor(timeLeft / 60), timeLeft % 60, suspicion)
end

startBtn.MouseButton1Click:Connect(function()
	local c = cheats[selected]
	if not c then
		return
	end
	remote:FireServer("Start", c.name)
end)

cheatBtn.MouseButton1Click:Connect(function()
	local c = cheats[selected]
	if c and not cheatingUntil then
		remote:FireServer("Cheat", c.name)
	end
end)

submitBtn.MouseButton1Click:Connect(function()
	if not picked then
		hintLabel.TextColor3 = C.warn
		hintLabel.Text = "답을 골라주세요!"
		return
	end
	remote:FireServer("Answer", picked)
end)

retryBtn.MouseButton1Click:Connect(function()
	modal.Visible = false
	startBtn.Visible = true
	cheatBox.Visible = false
	paper.Visible = false
end)

RunService.RenderStepped:Connect(function()
	if cheatingUntil then
		local left = cheatingUntil - os.clock()
		progFill.Size = UDim2.new(math.clamp(1 - left / cheatDur, 0, 1), 0, 1, 0)
	end
end)

local function showDomain(who)
	domainWho.Text = who .. " 적발!"
	domainImg.Visible = Shared.DOMAIN_IMAGE ~= "rbxassetid://0"
	domainImg.ImageTransparency = 1
	domainText.TextTransparency = 1
	domainImg.Size = UDim2.fromScale(0.6, 0.65)
	domain.Visible = true
	local fast = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(domainImg, fast, { ImageTransparency = 0, Size = UDim2.fromScale(0.45, 0.5) }):Play()
	TweenService:Create(domainText, fast, { TextTransparency = 0 }):Play()
	-- 흔들림
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
		TweenService:Create(domainImg, slow, { ImageTransparency = 1, Size = UDim2.fromScale(0.3, 0.35) }):Play()
		TweenService:Create(domainText, slow, { TextTransparency = 1 }):Play()
		task.wait(0.5)
		domain.Visible = false
	end)
end

remote.OnClientEvent:Connect(function(action, data, extra)
	if action == "Question" then
		startBtn.Visible = false
		cheatBox.Visible = true
		paper.Visible = true
		modal.Visible = false
		qNum, qTotal = data.num, data.total
		if data.num == 1 then
			timeLeft, suspicion = Shared.TIME_LIMIT, 0
		end
		qLabel.Text = data.num .. ". " .. data.text
		picked = nil
		for i, b in ipairs(choiceBtns) do
			b.Text = Shared.NUM[i] .. " " .. tostring(data.options[i])
			b.BackgroundTransparency = 1
			b.UIStroke.Enabled = false
		end
		hintLabel.Text = ""
		updateHud()
	elseif action == "Timer" then
		timeLeft, suspicion = data, extra
		updateHud()
	elseif action == "CheatStart" then
		cheatDur = data
		cheatingUntil = os.clock() + data
		progBg.Visible = true
		hintLabel.TextColor3 = C.muted
		hintLabel.Text = (cheats[selected] and cheats[selected].name or "") .. "(으)로 부정행위 중…"
	elseif action == "Hint" or action == "CheatCancel" then
		cheatingUntil = nil
		progBg.Visible = false
		if action == "Hint" then
			hintLabel.TextColor3 = C.good
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
			mTitle.Text = "당신은 가루가 되었습니다"
			mGrade.Text = "💀"
			mDesc.Text = string.format("감독관에게 적발! (푼 문제 %d개 중 %d개 정답이었음)", data.answered, data.score)
		else
			mTitle.Text = data.timeUp and "시간 종료!" or "시험 종료!"
			mGrade.Text = data.grade .. "등급"
			mDesc.Text = string.format("%d문제 중 %d개 정답 · 가루가 된 친구 %d명", Shared.TOTAL_Q, data.score, data.dead)
		end
		modal.Visible = true
	end
end)
