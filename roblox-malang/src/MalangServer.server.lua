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
-- 말랑이 모델 만들기: 실제 말랑이 장난감처럼 (s = 크기 배율, 앞쪽 = -Z)
-------------------------------------------------------------------
local function blockPart(m, size, cf, color, extra)
	local p = part({ Parent = m, Size = size, CFrame = cf, Color = color, CanCollide = false })
	if extra then
		for k, v in pairs(extra) do
			p[k] = v
		end
	end
	return p
end
-- 테이프 말랑이 특유의 살짝 반짝이는 광택
local TAPE = { Reflectance = 0.06 }

local function buildSquishy(def, s, at)
	local m = Instance.new("Model")
	m.Name = "Squishy"
	m:SetAttribute("SquishyId", def.id)
	local base = CFrame.new(at)
	local function B(x, y, z)
		return base * CFrame.new(x * s, y * s, z * s)
	end
	local shape = def.shape
	local c = def.color
	local body
	if shape == "mochi" then
		-- 납작하고 둥근 찹쌀떡 + 하얀 전분 가루
		body = blob(m, Vector3.new(2.4, 1.25, 2.4) * s, B(0, 0.62, 0), c)
		for i = 1, 10 do
			local a = i * 2.39
			local r = 0.3 + (i % 4) * 0.22
			blob(m, Vector3.new(0.12, 0.05, 0.12) * s, B(math.cos(a) * r, 1.22 - r * 0.25, math.sin(a) * r), Color3.new(1, 1, 1))
		end
	elseif shape == "tofu" then
		-- 하얀 두부 블록 + 위쪽 테이프 광택
		body = blockPart(m, Vector3.new(2.2, 1.4, 2.2) * s, B(0, 0.7, 0), c, TAPE)
		blockPart(m, Vector3.new(1.6, 0.04, 1.6) * s, B(-0.1, 1.42, -0.1), Color3.new(1, 1, 1), { Transparency = 0.55, Material = Enum.Material.Neon })
	elseif shape == "bread" then
		-- 갈색 테두리(빵 껍질) + 노란 속살 단면 + 둥근 윗부분
		body = blockPart(m, Vector3.new(2.3, 1.5, 1.4) * s, B(0, 0.75, 0), Color3.fromRGB(195, 130, 65), TAPE)
		blob(m, Vector3.new(2.5, 1.1, 1.38) * s, B(0, 1.5, 0), Color3.fromRGB(195, 130, 65), TAPE)
		for _, z in ipairs({ -0.71, 0.71 }) do
			blockPart(m, Vector3.new(2.05, 1.3, 0.04) * s, B(0, 0.78, z), c)
			blob(m, Vector3.new(2.25, 0.9, 0.04) * s, B(0, 1.5, z), c)
		end
	elseif shape == "egg" then
		-- 울퉁불퉁한 흰자 + 볼록한 노른자
		body = blob(m, Vector3.new(2.6, 0.45, 2.2) * s, B(0, 0.22, 0), c)
		blob(m, Vector3.new(1.4, 0.42, 1.5) * s, B(0.8, 0.2, 0.5), c)
		blob(m, Vector3.new(1.2, 0.4, 1.2) * s, B(-0.9, 0.2, -0.5), c)
		blob(m, Vector3.new(1.0, 0.75, 1.0) * s, B(0.1, 0.55, -0.1), Color3.fromRGB(255, 175, 30), TAPE)
	elseif shape == "macaron" then
		-- 위아래 꼬끄 + 가운데 크림 + 꼬끄 아래 주름(피에)
		local cyl = CFrame.Angles(0, 0, math.rad(90))
		blockPart(m, Vector3.new(0.6, 2.3, 2.3) * s, B(0, 0.3, 0) * cyl, c, { Shape = Enum.PartType.Cylinder })
		blockPart(m, Vector3.new(0.18, 2.42, 2.42) * s, B(0, 0.62, 0) * cyl, c:Lerp(Color3.new(1, 1, 1), 0.3), { Shape = Enum.PartType.Cylinder })
		blockPart(m, Vector3.new(0.45, 2.05, 2.05) * s, B(0, 0.92, 0) * cyl, Color3.fromRGB(255, 250, 240), { Shape = Enum.PartType.Cylinder })
		blockPart(m, Vector3.new(0.18, 2.42, 2.42) * s, B(0, 1.22, 0) * cyl, c:Lerp(Color3.new(1, 1, 1), 0.3), { Shape = Enum.PartType.Cylinder })
		body = blob(m, Vector3.new(2.3, 0.75, 2.3) * s, B(0, 1.5, 0), c)
	elseif shape == "cheese" then
		-- 삼각 치즈 조각 + 구멍
		local w = Instance.new("WedgePart")
		w.Anchored = true
		w.CanCollide = false
		w.Material = Enum.Material.SmoothPlastic
		w.Color = c
		w.Size = Vector3.new(1.6, 1.4, 2.6) * s
		w.CFrame = B(0, 0.7, 0)
		w.Parent = m
		body = w
		local holeC = Color3.fromRGB(230, 180, 50)
		for _, h in ipairs({ { -0.81, 0.4, 0.5, 0.45 }, { -0.81, 0.9, -0.3, 0.3 }, { 0.81, 0.35, 0.8, 0.35 }, { 0.81, 0.5, -0.5, 0.4 } }) do
			blob(m, Vector3.new(0.05, h[4], h[4]) * s, B(h[1], h[2], h[3]), holeC)
		end
	elseif shape == "jelly" then
		-- 투명한 젤리 큐브 + 안쪽 진한 색
		body = blockPart(m, Vector3.new(2, 2, 2) * s, B(0, 1, 0), c, { Material = Enum.Material.Glass, Transparency = 0.35 })
		blockPart(m, Vector3.new(1.2, 1.2, 1.2) * s, B(0, 1, 0), c:Lerp(Color3.new(0, 0.3, 0.2), 0.3), { Material = Enum.Material.Glass, Transparency = 0.2 })
	elseif shape == "fish" then
		-- 붕어빵: 길쭉한 몸통 + 꼬리 + 비늘 무늬 + 눈
		local extra = def.neon and { Material = Enum.Material.Neon } or TAPE
		body = blob(m, Vector3.new(3.0, 1.3, 1.5) * s, B(0, 0.65, 0), c, extra)
		for _, y in ipairs({ 0.35, 0.95 }) do
			local t = Instance.new("WedgePart")
			t.Anchored = true
			t.CanCollide = false
			t.Material = def.neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
			t.Color = c
			t.Size = Vector3.new(0.5, 0.7, 1.0) * s
			t.CFrame = B(1.75, y, 0) * CFrame.Angles(y < 0.5 and math.pi or 0, math.rad(90), 0)
			t.Parent = m
		end
		local dark = c:Lerp(Color3.new(0.3, 0.15, 0), 0.35)
		for i = -1, 1 do
			for _, z in ipairs({ -0.74, 0.74 }) do
				blob(m, Vector3.new(0.35, 0.5, 0.04) * s, B(i * 0.45 + 0.2, 0.7, z), dark)
			end
		end
		for _, z in ipairs({ -0.7, 0.7 }) do
			blob(m, Vector3.new(0.2, 0.2, 0.05) * s, B(-1.05, 0.85, z), Color3.fromRGB(60, 35, 20))
		end
	elseif shape == "mesh" then
		-- 메쉬볼: 말랑한 공 + 그물 사이로 튀어나온 구슬들
		body = blob(m, Vector3.new(2.2, 2.2, 2.2) * s, B(0, 1.1, 0), c, { Material = Enum.Material.Fabric })
		local n = 34
		local beads = { Color3.fromRGB(255, 150, 200), Color3.fromRGB(255, 240, 150), Color3.fromRGB(180, 255, 200), Color3.fromRGB(255, 255, 255) }
		for i = 0, n - 1 do
			local y = 1 - (i + 0.5) / n * 2
			local r = math.sqrt(1 - y * y)
			local a = i * 2.39996
			local dir = Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
			local p = blob(m, Vector3.new(0.36, 0.36, 0.36) * s, base * CFrame.new(Vector3.new(0, 1.1 * s, 0) + dir * 1.05 * s), beads[i % #beads + 1], { Material = Enum.Material.Glass, Transparency = 0.15 })
			p.Name = "Bead"
		end
	elseif shape == "water" then
		-- 물방울 말랑이: 투명한 공 + 안쪽 반짝이
		body = blob(m, Vector3.new(2.3, 2.1, 2.3) * s, B(0, 1.05, 0), c, { Material = Enum.Material.Glass, Transparency = 0.45 })
		for i = 1, 14 do
			local a = i * 2.39996
			local r = 0.2 + (i % 5) * 0.13
			blob(m, Vector3.new(0.12, 0.12, 0.12) * s, B(math.cos(a) * r, 0.5 + (i % 7) * 0.15, math.sin(a) * r), Color3.fromRGB(255, 255, 255), { Material = Enum.Material.Neon })
		end
	elseif shape == "glitter" then
		-- 반짝이 슬라임볼: 보랏빛 공 + 빛나는 반짝이 가루
		body = blob(m, Vector3.new(2.3, 2.1, 2.3) * s, B(0, 1.05, 0), c, { Material = Enum.Material.Glass, Transparency = 0.15 })
		local gl = { Color3.fromRGB(255, 220, 255), Color3.fromRGB(180, 240, 255), Color3.fromRGB(255, 250, 180) }
		for i = 1, 24 do
			local y = 1 - (i + 0.5) / 24 * 2
			local r = math.sqrt(1 - y * y)
			local a = i * 2.39996
			blob(m, Vector3.new(0.14, 0.14, 0.14) * s, base * CFrame.new(Vector3.new(math.cos(a) * r * 1.0, 1.05 + y * 0.92, math.sin(a) * r * 1.0) * s), gl[i % 3 + 1], { Material = Enum.Material.Neon })
		end
		local l = Instance.new("PointLight")
		l.Color = c
		l.Range = 8 * s
		l.Brightness = 1
		l.Parent = body
	end
	body.Name = "Body"
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
		local def = Shared.SQUISHIES[((ti - 1) * 6 + k) % 7 + 1] -- 일반·희귀 말랑이
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
