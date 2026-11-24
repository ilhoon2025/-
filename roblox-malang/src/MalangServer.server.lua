-- 말랑이 공방: 서버 스크립트 (ServerScriptService)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Shared = require(ReplicatedStorage:WaitForChild("MalangShared"))

local remote = Instance.new("RemoteEvent")
remote.Name = "MalangEvent"
remote.Parent = ReplicatedStorage

local world = Instance.new("Folder")
world.Name = "MalangWorld"
world.Parent = workspace

Lighting.ClockTime = 13
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(150, 140, 160)
Lighting.OutdoorAmbient = Color3.fromRGB(170, 160, 180)

-------------------------------------------------------------------
-- 도우미
-------------------------------------------------------------------
local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in pairs(props) do
		if k ~= "Parent" then
			p[k] = v
		end
	end
	p.Parent = props.Parent or world
	return p
end

-- 늘어나는 공 모양 (찌그러질 수 있게 Sphere 메시 사용)
local function blob(parent, size, cf, color, extra)
	local p = part({ Parent = parent, Size = size, CFrame = cf, Color = color, CanCollide = false })
	local m = Instance.new("SpecialMesh")
	m.MeshType = Enum.MeshType.Sphere
	m.Parent = p
	if extra then
		for k, v in pairs(extra) do
			p[k] = v
		end
	end
	return p
end

local function surfaceText(p, face, str, color)
	local sg = Instance.new("SurfaceGui")
	sg.Face = face
	sg.PixelsPerStud = 40
	sg.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = str
	t.TextColor3 = color
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.Parent = sg
end

local function billboard(adornee, str, offsetY, color, w)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(w or 160, 30)
	bb.StudsOffset = Vector3.new(0, offsetY, 0)
	bb.AlwaysOnTop = false
	bb.MaxDistance = 80
	bb.Adornee = adornee
	local t = Instance.new("TextLabel")
	t.Name = "Label"
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = str
	t.TextColor3 = color
	t.TextStrokeTransparency = 0.4
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.Parent = bb
	bb.Parent = adornee
	return bb
end

-------------------------------------------------------------------
-- 말랑이 모델 만들기 (s = 크기 배율, 앞쪽 = -Z)
-------------------------------------------------------------------
local function addFace(m, body, s)
	local sz = body.Size
	local front = body.CFrame * CFrame.new(0, sz.Y * 0.05, -sz.Z * 0.46)
	local black = Color3.fromRGB(40, 35, 40)
	for _, x in ipairs({ -1, 1 }) do
		blob(m, Vector3.new(0.18, 0.24, 0.1) * s, front * CFrame.new(x * sz.X * 0.17, 0, 0), black)
		blob(m, Vector3.new(0.26, 0.14, 0.06) * s, front * CFrame.new(x * sz.X * 0.3, -sz.Y * 0.1, 0.02), Color3.fromRGB(255, 150, 170))
	end
	blob(m, Vector3.new(0.16, 0.08, 0.06) * s, front * CFrame.new(0, -sz.Y * 0.1, 0), black)
end

local function buildSquishy(def, s, at)
	local m = Instance.new("Model")
	m.Name = "Squishy"
	m:SetAttribute("SquishyId", def.id)
	local base = CFrame.new(at)
	local mat = def.neon and Enum.Material.Neon or (def.glass and Enum.Material.Glass or Enum.Material.SmoothPlastic)
	local extra = { Material = mat, Transparency = def.glass and 0.25 or 0 }
	local body
	local shape = def.shape
	if shape == "ball" or shape == "leafball" or shape == "space" then
		body = blob(m, Vector3.new(2.2, 1.7, 2.2) * s, base * CFrame.new(0, 0.85 * s, 0), def.color, extra)
		if shape == "leafball" then
			blob(m, Vector3.new(0.9, 0.25, 0.5) * s, base * CFrame.new(0, 1.75 * s, 0) * CFrame.Angles(0, 0, 0.3), def.leaf)
		elseif shape == "space" then
			for i = 1, 6 do
				local a = i * 1.05
				blob(m, Vector3.new(0.18, 0.18, 0.18) * s, base * CFrame.new(math.cos(a) * 0.9 * s, (0.6 + (i % 3) * 0.35) * s, math.sin(a) * 0.9 * s), Color3.fromRGB(255, 255, 200), { Material = Enum.Material.Neon })
			end
		end
	elseif shape == "bread" then
		body = part({ Parent = m, Size = Vector3.new(2.2, 1.6, 1.4) * s, CFrame = base * CFrame.new(0, 0.8 * s, 0), Color = def.color, CanCollide = false })
		blob(m, Vector3.new(2.4, 1.0, 1.5) * s, base * CFrame.new(0, 1.6 * s, 0), Color3.fromRGB(200, 140, 80))
		blob(m, Vector3.new(2.1, 0.85, 1.42) * s, base * CFrame.new(0, 1.55 * s, 0), def.color)
	elseif shape == "pudding" then
		body = part({ Parent = m, Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.6, 2.2, 2.2) * s, CFrame = base * CFrame.new(0, 0.8 * s, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = def.color, CanCollide = false })
		blob(m, Vector3.new(2.0, 0.6, 2.0) * s, base * CFrame.new(0, 1.65 * s, 0), Color3.fromRGB(140, 80, 30))
		body = blob(m, Vector3.new(2.25, 1.5, 2.25) * s, base * CFrame.new(0, 0.8 * s, 0), def.color) -- 얼굴 붙일 앞면
	elseif shape == "cloud" then
		body = blob(m, Vector3.new(1.8, 1.5, 1.8) * s, base * CFrame.new(0, 0.9 * s, 0), def.color)
		blob(m, Vector3.new(1.3, 1.1, 1.4) * s, base * CFrame.new(-1.1 * s, 0.6 * s, 0.1 * s), def.color)
		blob(m, Vector3.new(1.3, 1.1, 1.4) * s, base * CFrame.new(1.1 * s, 0.6 * s, 0.1 * s), def.color)
	elseif shape == "cat" then
		body = blob(m, Vector3.new(2.2, 1.8, 2.0) * s, base * CFrame.new(0, 0.9 * s, 0), def.color)
		for _, x in ipairs({ -0.65, 0.65 }) do
			local ear = Instance.new("WedgePart")
			ear.Anchored = true
			ear.CanCollide = false
			ear.Color = def.color
			ear.Material = Enum.Material.SmoothPlastic
			ear.Size = Vector3.new(0.3, 0.6, 0.6) * s
			ear.CFrame = base * CFrame.new(x * s, 1.85 * s, 0) * CFrame.Angles(0, math.rad(90), 0)
			ear.Parent = m
		end
	elseif shape == "buddy" then
		body = blob(m, Vector3.new(1.8, 1.9, 1.6) * s, base * CFrame.new(0, 0.95 * s, 0), def.color, extra)
		blob(m, Vector3.new(0.6, 0.6, 0.6) * s, base * CFrame.new(-0.6 * s, 2.0 * s, 0), def.color, extra)
		blob(m, Vector3.new(0.6, 0.6, 0.6) * s, base * CFrame.new(0.6 * s, 2.0 * s, 0), def.color, extra)
	elseif shape == "rainbow" then
		local cols = { Color3.fromRGB(255, 120, 120), Color3.fromRGB(255, 200, 110), Color3.fromRGB(150, 230, 130), Color3.fromRGB(120, 190, 255), Color3.fromRGB(190, 140, 255) }
		for i, c in ipairs(cols) do
			local b = blob(m, Vector3.new(2.3 - i * 0.18, 0.55, 2.3 - i * 0.18) * s, base * CFrame.new(0, (0.25 + (i - 1) * 0.42) * s, 0), c)
			if i == 2 then
				body = b
			end
		end
		body.Size = Vector3.new(body.Size.X, body.Size.Y, body.Size.Z)
	end
	addFace(m, body, s)
	body.Name = "Body"
	-- 찌그러질 때 기준이 되는 바닥 중심
	local root = part({ Parent = m, Name = "Root", Size = Vector3.new(0.2, 0.2, 0.2), CFrame = base, Transparency = 1, CanCollide = false, CanQuery = false })
	m.PrimaryPart = root
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 40
	click.Parent = m
	return m, click
end

-------------------------------------------------------------------
-- 플레이어 데이터
-------------------------------------------------------------------
local data = {} -- [player] = { owned = { [id] = 개수 }, pets = { {id, model} }, combo, lastSquish }

local function pointsValue(player)
	local ls = player:FindFirstChild("leaderstats")
	return ls and ls:FindFirstChild("말랑P")
end

local function sendCollection(player)
	local d = data[player]
	if d then
		remote:FireClient(player, "Collection", d.owned)
		local ls = player:FindFirstChild("leaderstats")
		local n = 0
		for _ in pairs(d.owned) do
			n = n + 1
		end
		if ls then
			ls["도감"].Value = n
		end
	end
end

-- 말랑이 누르기
local function squish(player, model, mult)
	local d = data[player]
	if not d or not model.Parent then
		return
	end
	local now = os.clock()
	if now - (d.lastSquish or 0) < 0.08 then
		return
	end
	if now - (d.lastSquish or 0) < 0.7 then
		d.combo = math.min(20, (d.combo or 0) + 1)
	else
		d.combo = 0
	end
	d.lastSquish = now
	local id = model:GetAttribute("SquishyId")
	local gain = math.floor(Shared.pointsOf(id) * (mult or 1) * (1 + d.combo * 0.1) + 0.5)
	local pv = pointsValue(player)
	if pv then
		pv.Value = pv.Value + gain
	end
	remote:FireAllClients("Squish", model)
	remote:FireClient(player, "Gain", gain, d.combo, model)
end

local function hookClick(model, click, mult)
	click.MouseClick:Connect(function(player)
		squish(player, model, mult)
	end)
end

-------------------------------------------------------------------
-- 광장 만들기
-------------------------------------------------------------------
part({ Name = "Floor", Size = Vector3.new(200, 1, 200), Position = Vector3.new(0, -0.5, 0), Color = Color3.fromRGB(190, 240, 215) })
-- 체크무늬 타일
for x = -90, 90, 20 do
	for z = -90, 90, 20 do
		if ((x + z) / 20) % 2 == 0 then
			part({ Size = Vector3.new(20, 0.05, 20), Position = Vector3.new(x, 0.02, z), Color = Color3.fromRGB(205, 248, 228), CanCollide = false })
		end
	end
end
-- 낮은 파스텔 울타리
for _, w in ipairs({ { 0, -100, 200, 1 }, { 0, 100, 200, 1 }, { -100, 0, 1, 200 }, { 100, 0, 1, 200 } }) do
	part({ Size = Vector3.new(w[3], 3, w[4]), Position = Vector3.new(w[1], 1.5, w[2]), Color = Color3.fromRGB(255, 200, 220) })
end
-- 솜사탕 나무
for i = 1, 14 do
	local a = i / 14 * math.pi * 2
	local x, z = math.cos(a) * 82, math.sin(a) * 82
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(8, 1.2, 1.2), CFrame = CFrame.new(x, 4, z) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(190, 140, 110) })
	local cols = { Color3.fromRGB(255, 190, 220), Color3.fromRGB(200, 220, 255), Color3.fromRGB(255, 240, 180) }
	part({ Shape = Enum.PartType.Ball, Size = Vector3.new(7, 7, 7), Position = Vector3.new(x, 10, z), Color = cols[i % 3 + 1] })
end
-- 간판
local sign = part({ Size = Vector3.new(40, 8, 1), Position = Vector3.new(0, 14, 60), Color = Color3.fromRGB(255, 170, 200) })
surfaceText(sign, Enum.NormalId.Back, "말랑이 공방", Color3.new(1, 1, 1))
surfaceText(sign, Enum.NormalId.Front, "말랑이 공방", Color3.new(1, 1, 1))
for _, x in ipairs({ -18, 18 }) do
	part({ Size = Vector3.new(1, 10, 1), Position = Vector3.new(x, 5, 60), Color = Color3.fromRGB(255, 255, 255) })
end

local spawn = Instance.new("SpawnLocation")
spawn.Anchored = true
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 0, 70)
spawn.Transparency = 1
spawn.CanCollide = false
spawn.Neutral = true
spawn.Duration = 0
spawn.Parent = world

-- 왕말랑이 (가운데, 누르면 2배)
do
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 22, 22), CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(255, 255, 255) })
	local giant, click = buildSquishy(Shared.byId("mochi"), 7, Vector3.new(0, 2, 0))
	giant.Name = "GiantSquishy"
	giant:PivotTo(CFrame.new(0, 2, 0) * CFrame.Angles(0, math.pi, 0))
	giant.Parent = world
	hookClick(giant, click, 2)
	billboard(giant.Root, "왕말랑이 (포인트 2배)", 16, Color3.fromRGB(255, 120, 170), 260)
end

-- 말랑이 테이블 4개 (누구나 눌러볼 수 있는 일반·희귀 말랑이)
local TABLE_SPOTS = { Vector3.new(-40, 0, -30), Vector3.new(40, 0, -30), Vector3.new(-40, 0, 30), Vector3.new(40, 0, 30) }
for ti, pos in ipairs(TABLE_SPOTS) do
	part({ Size = Vector3.new(18, 1, 10), Position = pos + Vector3.new(0, 3, 0), Color = Color3.fromRGB(255, 230, 200) })
	for _, dx in ipairs({ -8, 8 }) do
		for _, dz in ipairs({ -4, 4 }) do
			part({ Size = Vector3.new(0.8, 3, 0.8), Position = pos + Vector3.new(dx, 1.5, dz), Color = Color3.fromRGB(230, 200, 170) })
		end
	end
	for k = 0, 5 do
		local def = Shared.SQUISHIES[((ti - 1) * 6 + k) % 7 + 1]
		local at = pos + Vector3.new(-6.5 + (k % 3) * 6.5, 3.5, k < 3 and -2.5 or 2.5)
		local m, click = buildSquishy(def, 1.2, at)
		m:PivotTo(CFrame.new(at) * CFrame.Angles(0, math.pi * (pos.Z > 0 and 0 or 1), 0))
		m.Parent = world
		hookClick(m, click, 1)
	end
end

-- 뽑기 기계
local gachaPos = Vector3.new(0, 0, -45)
do
	part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(8, 8, 8), CFrame = CFrame.new(gachaPos + Vector3.new(0, 4, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(255, 120, 160) })
	local dome = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(10, 10, 10), Position = gachaPos + Vector3.new(0, 12, 0), Color = Color3.fromRGB(220, 240, 255), Material = Enum.Material.Glass, Transparency = 0.5 })
	local cols = { Color3.fromRGB(255, 150, 150), Color3.fromRGB(150, 200, 255), Color3.fromRGB(255, 230, 120), Color3.fromRGB(180, 255, 180), Color3.fromRGB(220, 160, 255) }
	for i = 1, 16 do
		local a = i * 2.4
		part({ Shape = Enum.PartType.Ball, Size = Vector3.new(1.6, 1.6, 1.6), Position = gachaPos + Vector3.new(math.cos(a) * 2.8, 9.5 + (i % 4) * 1.1, math.sin(a) * 2.8), Color = cols[i % 5 + 1] })
	end
	local front = part({ Size = Vector3.new(5, 2.5, 0.3), Position = gachaPos + Vector3.new(0, 5, 4.05), Color = Color3.new(1, 1, 1) })
	surfaceText(front, Enum.NormalId.Back, "말랑이 뽑기", Color3.fromRGB(255, 100, 150))
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "뽑기 (" .. Shared.GACHA_COST .. "P)"
	prompt.ObjectText = "말랑이 뽑기"
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = front
	billboard(dome, "말랑이 뽑기", 7, Color3.fromRGB(255, 100, 150), 220)

	local rng = Random.new()
	prompt.Triggered:Connect(function(player)
		local d = data[player]
		local pv = pointsValue(player)
		if not d or not pv then
			return
		end
		if pv.Value < Shared.GACHA_COST then
			remote:FireClient(player, "Toast", "포인트가 부족해요! 말랑이를 더 눌러 보세요.")
			return
		end
		pv.Value = pv.Value - Shared.GACHA_COST
		local def = Shared.roll(rng)
		local isNew = not d.owned[def.id]
		d.owned[def.id] = (d.owned[def.id] or 0) + 1
		remote:FireClient(player, "Gacha", def.id, isNew)
		sendCollection(player)
		-- 새로 뽑은 말랑이가 펫으로 따라옴
		task.delay(1.2, function()
			if data[player] then
				local m, click = buildSquishy(def, 0.9, Vector3.new(0, -50, 0))
				m.Name = "Pet"
				m.Parent = world
				hookClick(m, click, 1)
				table.insert(d.pets, { id = def.id, model = m, t = math.random() * 10 })
				if #d.pets > Shared.MAX_PETS then
					local old = table.remove(d.pets, 1)
					old.model:Destroy()
				end
			end
		end)
	end)
end

-------------------------------------------------------------------
-- 접속
-------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	local pts = Instance.new("IntValue")
	pts.Name = "말랑P"
	pts.Parent = ls
	local col = Instance.new("IntValue")
	col.Name = "도감"
	col.Parent = ls
	ls.Parent = player
	data[player] = { owned = {}, pets = {}, combo = 0, lastSquish = 0, passive = 0 }
	task.delay(2, function()
		sendCollection(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local d = data[player]
	if d then
		for _, p in ipairs(d.pets) do
			p.model:Destroy()
		end
	end
	data[player] = nil
end)

-------------------------------------------------------------------
-- 펫 따라다니기 + 펫이 주는 포인트
-------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	for player, d in pairs(data) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			for i, pet in ipairs(d.pets) do
				pet.t = pet.t + dt
				local side = (i - (#d.pets + 1) / 2) * 3.2
				local goal = hrp.CFrame * CFrame.new(side, -2.6 + math.abs(math.sin(pet.t * 4)) * 0.8, 5)
				local cur = pet.model:GetPivot()
				local pos = cur.Position:Lerp(goal.Position, math.min(1, dt * 6))
				local look = hrp.CFrame.LookVector
				pet.model:PivotTo(CFrame.lookAt(pos, pos + Vector3.new(look.X, 0, look.Z)))
			end
			-- 펫 포인트
			d.passive = d.passive + dt
			if d.passive >= Shared.PASSIVE_EVERY and #d.pets > 0 then
				d.passive = 0
				local gain = 0
				for _, pet in ipairs(d.pets) do
					gain = gain + Shared.pointsOf(pet.id)
				end
				local pv = pointsValue(player)
				if pv then
					pv.Value = pv.Value + gain
				end
				remote:FireClient(player, "Passive", gain)
			end
		end
	end
end)
