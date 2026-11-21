-- 한국 수능 부정행위! : 서버 스크립트 (ServerScriptService)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")

local Shared = require(ReplicatedStorage:WaitForChild("SuneungShared"))

local remote = Instance.new("RemoteEvent")
remote.Name = "SuneungEvent"
remote.Parent = ReplicatedStorage

-------------------------------------------------------------------
-- 교실 만들기
-------------------------------------------------------------------
local room = Instance.new("Folder")
room.Name = "Classroom"
room.Parent = workspace

local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		if k ~= "Parent" then
			p[k] = v
		end
	end
	p.Parent = props.Parent or room
	return p
end

local ROOM_X, ROOM_Z0, ROOM_Z1 = 26, -22, 24

part({ Name = "Floor", Size = Vector3.new(ROOM_X * 2, 1, ROOM_Z1 - ROOM_Z0), Position = Vector3.new(0, -0.5, (ROOM_Z0 + ROOM_Z1) / 2), Color = Color3.fromRGB(176, 138, 98), Material = Enum.Material.WoodPlanks })
part({ Name = "Ceiling", Size = Vector3.new(ROOM_X * 2, 1, ROOM_Z1 - ROOM_Z0), Position = Vector3.new(0, 16.5, (ROOM_Z0 + ROOM_Z1) / 2), Color = Color3.fromRGB(235, 235, 230) })
local wallColor = Color3.fromRGB(228, 222, 200)
part({ Name = "WallL", Size = Vector3.new(1, 16, ROOM_Z1 - ROOM_Z0), Position = Vector3.new(-ROOM_X, 8, (ROOM_Z0 + ROOM_Z1) / 2), Color = wallColor })
part({ Name = "WallR", Size = Vector3.new(1, 16, ROOM_Z1 - ROOM_Z0), Position = Vector3.new(ROOM_X, 8, (ROOM_Z0 + ROOM_Z1) / 2), Color = wallColor })
part({ Name = "WallF", Size = Vector3.new(ROOM_X * 2, 16, 1), Position = Vector3.new(0, 8, ROOM_Z0), Color = wallColor })
part({ Name = "WallB", Size = Vector3.new(ROOM_X * 2, 16, 1), Position = Vector3.new(0, 8, ROOM_Z1), Color = wallColor })

-- 천장 조명
for _, x in ipairs({ -12, 12 }) do
	for _, z in ipairs({ -8, 10 }) do
		local lamp = part({ Name = "Lamp", Size = Vector3.new(8, 0.3, 2), Position = Vector3.new(x, 15.9, z), Color = Color3.new(1, 1, 1), Material = Enum.Material.Neon })
		local light = Instance.new("PointLight")
		light.Range = 24
		light.Brightness = 1.2
		light.Parent = lamp
	end
end

-- 칠판
local board = part({ Name = "Blackboard", Size = Vector3.new(30, 7, 0.4), Position = Vector3.new(0, 8, ROOM_Z0 + 0.7), Color = Color3.fromRGB(31, 77, 58) })
do
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Back
	sg.PixelsPerStud = 40
	sg.Parent = board
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = "2027학년도 대학수학능력시험\n부정행위 적발 시 가루 처리"
	t.TextColor3 = Color3.fromRGB(233, 245, 238)
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.Parent = sg
end

Lighting.ClockTime = 14
Lighting.Brightness = 1
Lighting.Ambient = Color3.fromRGB(90, 90, 100)

-- 스폰 (교실 뒤쪽)
local spawn = Instance.new("SpawnLocation")
spawn.Anchored = true
spawn.Size = Vector3.new(6, 1, 6)
spawn.Position = Vector3.new(0, 0, ROOM_Z1 - 5)
spawn.Transparency = 1
spawn.CanCollide = false
spawn.Neutral = true
spawn.Duration = 0
spawn.Parent = room

-------------------------------------------------------------------
-- 책상 & 학생
-------------------------------------------------------------------
local HAIRS = { Color3.fromRGB(43, 29, 20), Color3.fromRGB(17, 17, 17), Color3.fromRGB(90, 58, 34), Color3.fromRGB(29, 29, 43), Color3.fromRGB(112, 44, 26) }
local SHIRTS = { Color3.fromRGB(76, 110, 245), Color3.fromRGB(232, 89, 12), Color3.fromRGB(47, 158, 68), Color3.fromRGB(174, 62, 201), Color3.fromRGB(240, 140, 0), Color3.fromRGB(16, 152, 173), Color3.fromRGB(201, 42, 42) }
local SKIN = Color3.fromRGB(243, 210, 179)

local desks = {} -- { pos = Vector3(학생 자리), occupant = "npc"|Player|nil, model = Model, seed = number }
local COLS_X = { -15, -5, 5, 15 }
local ROWS_Z = { -6, 3, 12 }

local function makeBillboard(adornee, text, offsetY, color)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(120, 36)
	bb.StudsOffset = Vector3.new(0, offsetY, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = adornee
	local t = Instance.new("TextLabel")
	t.Name = "Label"
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = color or Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0.3
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = bb
	bb.Parent = adornee
	return bb
end

local function buildDesk(i, pos)
	local m = Instance.new("Model")
	m.Name = "Desk" .. i
	local deskZ = pos.Z - 2.2
	part({ Parent = m, Name = "Top", Size = Vector3.new(5, 0.4, 3), Position = Vector3.new(pos.X, 3, deskZ), Color = Color3.fromRGB(141, 110, 79), Material = Enum.Material.Wood })
	for _, dx in ipairs({ -2.2, 2.2 }) do
		for _, dz in ipairs({ -1.2, 1.2 }) do
			part({ Parent = m, Size = Vector3.new(0.3, 2.8, 0.3), Position = Vector3.new(pos.X + dx, 1.4, deskZ + dz), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Metal })
		end
	end
	part({ Parent = m, Name = "Paper", Size = Vector3.new(2, 0.05, 1.4), Position = Vector3.new(pos.X, 3.23, deskZ), Color = Color3.fromRGB(251, 247, 234) })
	part({ Parent = m, Name = "Seat", Size = Vector3.new(2.6, 0.3, 2.4), Position = Vector3.new(pos.X, 1.8, pos.Z + 0.3), Color = Color3.fromRGB(141, 110, 79) })
	part({ Parent = m, Name = "Back", Size = Vector3.new(2.6, 2.4, 0.3), Position = Vector3.new(pos.X, 3.1, pos.Z + 1.5), Color = Color3.fromRGB(141, 110, 79) })
	m.Parent = room
	return m
end

local function buildNPC(i)
	local d = desks[i]
	local m = Instance.new("Model")
	m.Name = "Student" .. i
	local x, z = d.pos.X, d.pos.Z
	local shirt = SHIRTS[(i * 3) % #SHIRTS + 1]
	part({ Parent = m, Name = "LegL", Size = Vector3.new(0.9, 0.9, 2), Position = Vector3.new(x - 0.5, 2.4, z - 0.5), Color = Color3.fromRGB(40, 45, 70) })
	part({ Parent = m, Name = "LegR", Size = Vector3.new(0.9, 0.9, 2), Position = Vector3.new(x + 0.5, 2.4, z - 0.5), Color = Color3.fromRGB(40, 45, 70) })
	local torso = part({ Parent = m, Name = "Torso", Size = Vector3.new(2, 2, 1), Position = Vector3.new(x, 3.9, z + 0.4), Color = shirt })
	part({ Parent = m, Name = "ArmL", Size = Vector3.new(0.8, 0.8, 2), Position = Vector3.new(x - 1.4, 4.1, z - 0.4), Color = shirt })
	part({ Parent = m, Name = "ArmR", Size = Vector3.new(0.8, 0.8, 2), Position = Vector3.new(x + 1.4, 4.1, z - 0.4), Color = shirt })
	local head = part({ Parent = m, Name = "Head", Size = Vector3.new(1.6, 1.6, 1.6), Position = Vector3.new(x, 5.7, z + 0.4), Color = SKIN, Shape = Enum.PartType.Ball })
	part({ Parent = m, Name = "Hair", Size = Vector3.new(1.75, 0.7, 1.75), Position = Vector3.new(x, 6.4, z + 0.5), Color = HAIRS[(i * 7) % #HAIRS + 1] })
	-- 눈 (칠판 쪽 = -Z 방향)
	for _, dx in ipairs({ -0.3, 0.3 }) do
		part({ Parent = m, Name = "Eye", Size = Vector3.new(0.18, 0.25, 0.1), Position = Vector3.new(x + dx, 5.8, z - 0.38), Color = Color3.new(0.1, 0.1, 0.1) })
	end
	makeBillboard(head, i .. "번", 2.2, Color3.fromRGB(200, 205, 225))
	local sweat = makeBillboard(head, "💦 부정행위 중", 3.4, Color3.fromRGB(255, 200, 87))
	sweat.Name = "Sweat"
	sweat.Enabled = false
	m.PrimaryPart = torso
	m.Parent = room
	d.model = m
	d.occupant = "npc"
	d.cheating = 0
end

for r, z in ipairs(ROWS_Z) do
	for c, x in ipairs(COLS_X) do
		local i = (r - 1) * #COLS_X + c
		desks[i] = { pos = Vector3.new(x, 0, z), seed = 1000 + i * 97 }
		buildDesk(i, desks[i].pos)
		buildNPC(i)
	end
end

-------------------------------------------------------------------
-- 감독관
-------------------------------------------------------------------
local VIEW_RANGE = 30
local VIEW_ANGLE = math.rad(32)

local teacher = Instance.new("Model")
teacher.Name = "Teacher"
local tRoot = part({ Parent = teacher, Name = "Root", Size = Vector3.new(2, 2, 1), Position = Vector3.new(0, 4.5, 0), Color = Color3.fromRGB(51, 56, 77), CanCollide = false })
local function tPart(name, size, offset, color, shape)
	local p = part({ Parent = teacher, Name = name, Size = size, CFrame = tRoot.CFrame * CFrame.new(offset), Color = color, CanCollide = false })
	if shape then
		p.Shape = shape
	end
	return p
end
tPart("Legs", Vector3.new(2, 2.5, 1), Vector3.new(0, -2.25, 0), Color3.fromRGB(30, 30, 40))
tPart("ArmL", Vector3.new(0.9, 2, 0.9), Vector3.new(-1.45, 0, 0), Color3.fromRGB(51, 56, 77))
tPart("ArmR", Vector3.new(0.9, 2, 0.9), Vector3.new(1.45, 0, 0), Color3.fromRGB(51, 56, 77))
local tHead = tPart("Head", Vector3.new(1.7, 1.7, 1.7), Vector3.new(0, 1.85, 0), SKIN, Enum.PartType.Ball)
tPart("Hair", Vector3.new(1.85, 0.6, 1.85), Vector3.new(0, 2.55, 0.1), Color3.fromRGB(220, 220, 220))
tPart("Glasses", Vector3.new(1.3, 0.35, 0.1), Vector3.new(0, 1.95, -0.85), Color3.fromRGB(15, 15, 15))
-- 시야 표시 (바닥에 빨간 광선 부채꼴)
for k = -3, 3 do
	local a = VIEW_ANGLE * k / 3
	local dir = Vector3.new(math.sin(a), 0, -math.cos(a))
	local mid = dir * (VIEW_RANGE / 2)
	local ray = part({ Parent = teacher, Name = "Sight", Size = Vector3.new(0.25, 0.05, VIEW_RANGE), Color = Color3.fromRGB(255, 77, 109), Material = Enum.Material.Neon, Transparency = 0.55, CanCollide = false, CanQuery = false })
	ray.CFrame = tRoot.CFrame * CFrame.new(mid.X, -4.4, mid.Z) * CFrame.Angles(0, -a, 0)
end
local spot = Instance.new("SpotLight")
spot.Face = Enum.NormalId.Front
spot.Angle = 70
spot.Range = VIEW_RANGE
spot.Brightness = 3
spot.Color = Color3.fromRGB(255, 90, 110)
spot.Parent = tHead
makeBillboard(tHead, "감독관", 2.2, Color3.fromRGB(255, 143, 163))
local speech = makeBillboard(tHead, "", 4.5, Color3.fromRGB(201, 24, 74))
speech.Size = UDim2.fromOffset(420, 60)
speech.Label.BackgroundTransparency = 0
speech.Label.BackgroundColor3 = Color3.new(1, 1, 1)
speech.Enabled = false
teacher.PrimaryPart = tRoot
teacher.Parent = room

local tState = { pos = Vector3.new(0, 4.5, ROOM_Z0 + 5), look = 0, target = nil, wait = 2 }
local freeze = 0 -- 영역전개 중에는 모두 멈춤

local function teacherCF()
	return CFrame.new(tState.pos) * CFrame.Angles(0, tState.look, 0)
end
teacher:PivotTo(teacherCF())

local function teacherSees(pos)
	local cf = teacherCF()
	local v = pos - tState.pos
	v = Vector3.new(v.X, 0, v.Z)
	if v.Magnitude > VIEW_RANGE or v.Magnitude < 0.01 then
		return v.Magnitude < 3
	end
	local look = cf.LookVector
	look = Vector3.new(look.X, 0, look.Z).Unit
	return math.acos(math.clamp(look:Dot(v.Unit), -1, 1)) < VIEW_ANGLE
end

-------------------------------------------------------------------
-- 시험 세션
-------------------------------------------------------------------
local sessions = {} -- [player] = session

local function filterFor(player, text)
	local ok, res = pcall(function()
		local r = TextService:FilterStringAsync(text, player.UserId)
		return r:GetNonChatStringForUserAsync(player.UserId)
	end)
	if ok and res then
		return res
	end
	return "???"
end

local function logAll(text)
	remote:FireAllClients("Log", text)
end

local function deskOf(player)
	for i, d in ipairs(desks) do
		if d.occupant == player then
			return i, d
		end
	end
end

local function sendQuestion(player, s)
	local qIndex = s.questions[s.qi]
	local opts = Shared.paperFor(s.seed, qIndex)
	remote:FireClient(player, "Question", {
		num = s.qi,
		total = Shared.TOTAL_Q,
		text = Shared.BANK[qIndex].q,
		options = opts,
		seat = s.desk,
	})
end

-- 가루 효과
local function dustParts(parts)
	local count = 0
	for _, p in ipairs(parts) do
		if p:IsA("BasePart") and p.Transparency < 0.9 and p.Name ~= "Sight" then
			local n = math.clamp(math.floor(p.Size.Magnitude * 6), 6, 30)
			for _ = 1, n do
				if count > 600 then
					break
				end
				count = count + 1
				local bit = Instance.new("Part")
				bit.Anchored = true
				bit.CanCollide = false
				bit.CanQuery = false
				bit.Size = Vector3.new(0.25, 0.25, 0.25)
				bit.Color = p.Color
				bit.Material = Enum.Material.SmoothPlastic
				local off = Vector3.new((math.random() - 0.5) * p.Size.X, (math.random() - 0.5) * p.Size.Y, (math.random() - 0.5) * p.Size.Z)
				bit.CFrame = p.CFrame * CFrame.new(off)
				bit.Parent = workspace
				local drift = Vector3.new(math.random() * 6 + 2, math.random() * 7 + 3, (math.random() - 0.5) * 6)
				local info = TweenInfo.new(1.6 + math.random() * 1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, math.random() * 0.8)
				local tw = TweenService:Create(bit, info, { Position = bit.Position + drift, Transparency = 1, Size = Vector3.new(0.05, 0.05, 0.05) })
				tw:Play()
				tw.Completed:Connect(function()
					bit:Destroy()
				end)
			end
			p.Transparency = 1
			for _, c in ipairs(p:GetChildren()) do
				if c:IsA("Decal") then
					c.Transparency = 1
				elseif c:IsA("BillboardGui") then
					c.Enabled = false
				end
			end
		elseif p:IsA("Accessory") then
			local h = p:FindFirstChild("Handle")
			if h then
				h.Transparency = 1
			end
		end
	end
end

local endSession

local function catchAt(deskIndex)
	local d = desks[deskIndex]
	if not d or d.dying then
		return
	end
	d.dying = true
	freeze = freeze + 1
	local victim = d.occupant
	local isPlayer = typeof(victim) == "Instance" and victim:IsA("Player")
	local name = isPlayer and victim.DisplayName or (deskIndex .. "번 학생")

	-- 감독관이 학생을 바라봄
	local v = d.pos - tState.pos
	tState.look = math.atan2(-v.X, -v.Z)
	teacher:PivotTo(teacherCF())
	speech.Label.Text = Shared.DOMAIN_LINE
	speech.Enabled = true
	logAll("🚨 " .. name .. " 적발!")
	remote:FireAllClients("Domain", name)

	task.wait(2)
	speech.Enabled = false
	if isPlayer then
		local char = victim.Character
		if char then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then
					p.Anchored = true
				end
			end
			dustParts(char:GetDescendants())
		end
	elseif d.model then
		local m = d.model
		dustParts(m:GetDescendants())
		task.delay(4, function()
			m:Destroy()
		end)
		d.model = nil
		d.occupant = nil
	end
	freeze = freeze - 1
	d.dying = false
	if isPlayer then
		task.wait(2.5)
		endSession(victim, true)
	end
end

local function nearestNeighbor(deskIndex)
	local me = desks[deskIndex]
	local best, bestD
	for i, d in ipairs(desks) do
		if i ~= deskIndex and d.occupant and not d.dying then
			local dist = (d.pos - me.pos).Magnitude
			if dist < 14 and (not bestD or dist < bestD) then
				best, bestD = i, dist
			end
		end
	end
	return best
end

local function seedOf(i)
	local d = desks[i]
	if typeof(d.occupant) == "Instance" and sessions[d.occupant] then
		return sessions[d.occupant].seed
	end
	return d.seed
end

local function seatPlayer(player, i)
	local char = player.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hrp and hum then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		hum.UseJumpPower = true
		hrp.Anchored = true
		local p = desks[i].pos
		hrp.CFrame = CFrame.new(p.X, 3.2, p.Z + 0.3) * CFrame.Angles(0, 0, 0)
	end
end

endSession = function(player, caught)
	local s = sessions[player]
	if not s or s.ended then
		return
	end
	s.ended = true
	local dead = 0
	for _, d in ipairs(desks) do
		if not d.occupant then
			dead = dead + 1
		end
	end
	remote:FireClient(player, "End", {
		caught = caught,
		score = s.score,
		answered = s.qi - 1,
		grade = Shared.grade(s.score),
		dead = dead,
		timeUp = s.timeLeft <= 0,
	})
	local i, d = deskOf(player)
	if d then
		d.occupant = nil
		buildNPC(i) -- 빈 자리에 새 학생 입장
	end
	sessions[player] = nil
	if caught then
		player:LoadCharacter()
	else
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hum and hrp then
			hrp.Anchored = false
			hum.WalkSpeed = 16
			hum.JumpPower = 50
			hrp.CFrame = CFrame.new(0, 3, ROOM_Z1 - 5)
		end
	end
end

remote.OnServerEvent:Connect(function(player, action, arg)
	if action == "Start" then
		if sessions[player] or type(arg) ~= "string" then
			return
		end
		-- 자리 고르기: 7번 자리 우선, 아니면 다른 학생 자리
		local order = { 7, 6, 3, 2, 10, 11, 5, 8, 1, 4, 9, 12 }
		local seat
		for _, i in ipairs(order) do
			local d = desks[i]
			if d.occupant ~= nil and typeof(d.occupant) ~= "Instance" and not d.dying then
				seat = i
				break
			elseif d.occupant == nil and not d.dying then
				seat = i
				break
			end
		end
		if not seat then
			return
		end
		local d = desks[seat]
		if d.model then
			d.model:Destroy()
			d.model = nil
		end
		d.occupant = player
		-- 문제 뽑기
		local idx = {}
		for k = 1, #Shared.BANK do
			idx[k] = k
		end
		for k = #idx, 2, -1 do
			local j = math.random(1, k)
			idx[k], idx[j] = idx[j], idx[k]
		end
		local qs = {}
		for k = 1, Shared.TOTAL_Q do
			qs[k] = idx[k]
		end
		local cheatName = string.sub(arg, 1, 60)
		sessions[player] = {
			seed = math.random(1, 999999),
			questions = qs,
			qi = 1,
			score = 0,
			timeLeft = Shared.TIME_LIMIT,
			suspicion = 0,
			cheating = false,
			cheat = Shared.makeCheat(cheatName),
			cheatShown = filterFor(player, cheatName),
			desk = seat,
		}
		seatPlayer(player, seat)
		logAll("📝 " .. player.DisplayName .. " 시험 시작 (" .. seat .. "번 자리)")
		sendQuestion(player, sessions[player])
	elseif action == "Answer" then
		local s = sessions[player]
		if not s or s.ended or freeze > 0 or type(arg) ~= "number" then
			return
		end
		local _, correct = Shared.paperFor(s.seed, s.questions[s.qi])
		if arg == correct then
			s.score = s.score + 1
		end
		s.qi = s.qi + 1
		if s.qi > Shared.TOTAL_Q then
			endSession(player, false)
		else
			sendQuestion(player, s)
		end
	elseif action == "Cheat" then
		local s = sessions[player]
		if not s or s.ended or s.cheating or freeze > 0 then
			return
		end
		if type(arg) == "string" and arg ~= s.cheat.name then
			local n = string.sub(arg, 1, 60)
			s.cheat = Shared.makeCheat(n)
			s.cheatShown = filterFor(player, n)
		end
		s.cheating = true
		s.cheatEnd = os.clock() + Shared.CHEAT_TIME
		remote:FireClient(player, "CheatStart", Shared.CHEAT_TIME)
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		if head and not head:FindFirstChild("Sweat") then
			local bb = makeBillboard(head, "💦", 2.5, Color3.fromRGB(255, 200, 87))
			bb.Name = "Sweat"
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local i, d = deskOf(player)
	sessions[player] = nil
	if d then
		d.occupant = nil
		buildNPC(i)
	end
end)

-- 부정행위 끝났을 때
local function finishCheat(player, s)
	s.cheating = false
	local char = player.Character
	local head = char and char:FindFirstChild("Head")
	if head and head:FindFirstChild("Sweat") then
		head.Sweat:Destroy()
	end
	s.suspicion = math.min(100, s.suspicion + math.floor(s.cheat.risk / 3))
	if math.random() * 100 < s.cheat.risk * (0.4 + s.suspicion / 150) then
		task.spawn(catchAt, s.desk)
		return
	end
	local qIndex = s.questions[s.qi]
	local _, mine = Shared.paperFor(s.seed, qIndex)
	local text
	if s.cheat.copy then
		local n = nearestNeighbor(s.desk)
		if n then
			local _, theirs = Shared.paperFor(seedOf(n), qIndex)
			text = "👀 " .. n .. "번 자리 답: " .. Shared.NUM[theirs] .. "번 (근데 시험지가 다른데…?)"
		else
			text = "주변에 살아있는 친구가 없다…"
		end
	else
		local ans = mine
		if math.random() * 100 >= s.cheat.success then
			repeat
				ans = math.random(1, 5)
			until ans ~= mine
		end
		text = "✨ " .. s.cheatShown .. "이(가) 알려줌: 정답은 " .. Shared.NUM[ans] .. "번인 것 같다!"
	end
	remote:FireClient(player, "Hint", text)
end

-------------------------------------------------------------------
-- 메인 루프
-------------------------------------------------------------------
local function pickTarget()
	local suspect
	for p, s in pairs(sessions) do
		if math.random() < s.suspicion / 150 then
			suspect = desks[s.desk].pos
		end
	end
	if suspect then
		return Vector3.new(suspect.X + 3.5, 4.5, suspect.Z - 3.5)
	end
	-- 책상 사이 통로
	local xs = { -20, -10, 0, 10, 20 }
	return Vector3.new(xs[math.random(1, #xs)], 4.5, math.random(ROOM_Z0 + 4, ROOM_Z1 - 6))
end

RunService.Heartbeat:Connect(function(dt)
	if freeze > 0 then
		return
	end
	-- 감독관 이동
	if tState.wait > 0 then
		tState.wait = tState.wait - dt
		tState.look = tState.look + math.sin(os.clock() * 1.5) * dt * 1.2
	else
		if not tState.target then
			tState.target = pickTarget()
		end
		local v = tState.target - tState.pos
		local dist = v.Magnitude
		if dist < 0.5 then
			tState.target = nil
			tState.wait = 1 + math.random() * 2.5
			tState.look = math.random() * math.pi * 2
		else
			local want = math.atan2(-v.X, -v.Z)
			local diff = (want - tState.look + math.pi) % (math.pi * 2) - math.pi
			tState.look = tState.look + diff * math.min(1, dt * 6)
			tState.pos = tState.pos + v.Unit * math.min(dist, 7 * dt)
		end
	end
	teacher:PivotTo(teacherCF())

	-- 부정행위 감시
	for i, d in ipairs(desks) do
		if d.occupant and not d.dying then
			local cheating = false
			if d.occupant == "npc" then
				cheating = (d.cheating or 0) > 0
			elseif sessions[d.occupant] then
				cheating = sessions[d.occupant].cheating
			end
			if cheating and teacherSees(d.pos) then
				if d.occupant == "npc" then
					d.cheating = 0
					if d.model and d.model:FindFirstChild("Head") then
						d.model.Head.Sweat.Enabled = false
					end
				else
					local s = sessions[d.occupant]
					s.cheating = false
					remote:FireClient(d.occupant, "CheatCancel")
				end
				task.spawn(catchAt, i)
				return
			end
		end
	end

	-- NPC 몰래 부정행위
	for _, d in ipairs(desks) do
		if d.occupant == "npc" and d.model and not d.dying then
			local sweat = d.model.Head.Sweat
			if d.cheating > 0 then
				d.cheating = d.cheating - dt
				if d.cheating <= 0 then
					sweat.Enabled = false
				end
			elseif math.random() < dt * 0.06 then
				d.cheating = 2 + math.random() * 2.5
				sweat.Enabled = true
			end
		end
	end

	-- 플레이어 부정행위 완료
	for player, s in pairs(sessions) do
		if s.cheating and os.clock() >= s.cheatEnd then
			finishCheat(player, s)
		end
	end
end)

-- 타이머
task.spawn(function()
	while true do
		task.wait(1)
		if freeze == 0 then
			for player, s in pairs(sessions) do
				if not s.ended then
					s.timeLeft = s.timeLeft - 1
					remote:FireClient(player, "Timer", s.timeLeft, s.suspicion)
					if s.timeLeft <= 0 then
						endSession(player, false)
					end
				end
			end
		end
	end
end)
