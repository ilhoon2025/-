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
-- 공통 도우미
-------------------------------------------------------------------
local world = Instance.new("Folder")
world.Name = "SuneungWorld"
world.Parent = workspace

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
	p.Parent = props.Parent or world
	return p
end

-- 두 점 사이를 채우는 상자
local function box(x0, y0, z0, x1, y1, z1, props)
	props = props or {}
	props.Size = Vector3.new(math.abs(x1 - x0), math.abs(y1 - y0), math.abs(z1 - z0))
	props.Position = Vector3.new((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
	return part(props)
end

local function surfaceText(p, face, str, color, font)
	local sg = Instance.new("SurfaceGui")
	sg.Face = face
	sg.PixelsPerStud = 40
	sg.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = str
	t.TextColor3 = color
	t.Font = font or Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = sg
	return t
end

local function makeBillboard(adornee, str, offsetY, color)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(140, 32)
	bb.StudsOffset = Vector3.new(0, offsetY, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = adornee
	local t = Instance.new("TextLabel")
	t.Name = "Label"
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = str
	t.TextColor3 = color or Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0.3
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Parent = bb
	bb.Parent = adornee
	return bb
end

Lighting.ClockTime = 14
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(100, 100, 110)
Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 150)

-------------------------------------------------------------------
-- 땅
-------------------------------------------------------------------
part({ Name = "Grass", Size = Vector3.new(700, 1, 700), Position = Vector3.new(60, -0.6, 20), Color = Color3.fromRGB(96, 150, 72), Material = Enum.Material.Grass })

-------------------------------------------------------------------
-- 교실 (넓은 교실 + 창문 + 출입문)
-------------------------------------------------------------------
local ROOM_X, ROOM_Z0, ROOM_Z1 = 70, -36, 80
local WALL_H = 16
local WALL_C = Color3.fromRGB(228, 222, 200)
local GLASS = { Color = Color3.fromRGB(170, 210, 235), Material = Enum.Material.Glass, Transparency = 0.6 }
local DOOR_Z0, DOOR_Z1 = 36, 44

box(-ROOM_X, -1, ROOM_Z0, ROOM_X, 0, ROOM_Z1, { Name = "Floor", Color = Color3.fromRGB(176, 138, 98), Material = Enum.Material.WoodPlanks })
box(-ROOM_X, WALL_H, ROOM_Z0, ROOM_X, WALL_H + 1, ROOM_Z1, { Name = "Ceiling", Color = Color3.fromRGB(235, 235, 230) })

-- 벽 하나를 창문/문 구멍과 함께 만들기
-- along = "z" 이면 x=fixed 인 벽, "x" 이면 z=fixed 인 벽
local function wall(along, fixed, a0, a1, openings)
	local function seg(b0, b1, y0, y1, props)
		props = props or { Color = WALL_C }
		if along == "z" then
			return box(fixed - 0.5, y0, b0, fixed + 0.5, y1, b1, props)
		else
			return box(b0, y0, fixed - 0.5, b1, y1, fixed + 0.5, props)
		end
	end
	seg(a0, a1, 11, WALL_H) -- 위쪽 띠
	table.sort(openings, function(p, q)
		return p[1] < q[1]
	end)
	local cur = a0
	for _, o in ipairs(openings) do
		if o[1] > cur then
			seg(cur, o[1], 0, 11)
		end
		if o[3] == "door" then
			seg(o[1], o[2], 10, 11)
		else
			seg(o[1], o[2], 0, 4) -- 창틀 아래
			seg(o[1], o[2], 4, 11, { Color = GLASS.Color, Material = GLASS.Material, Transparency = GLASS.Transparency, Name = "Window" })
		end
		cur = o[2]
	end
	if cur < a1 then
		seg(cur, a1, 0, 11)
	end
end

local function windowsAlong(a0, a1, every, width, skip0, skip1)
	local list = {}
	local c = a0 + every / 2
	while c + width / 2 < a1 do
		local w0, w1 = c - width / 2, c + width / 2
		if not (skip0 and w1 > skip0 - 2 and w0 < skip1 + 2) then
			table.insert(list, { w0, w1 })
		end
		c = c + every
	end
	return list
end

wall("z", -ROOM_X, ROOM_Z0, ROOM_Z1, windowsAlong(ROOM_Z0, ROOM_Z1, 14, 9))
do
	local rightOpen = windowsAlong(ROOM_Z0, ROOM_Z1, 14, 9, DOOR_Z0, DOOR_Z1)
	table.insert(rightOpen, { DOOR_Z0, DOOR_Z1, "door" })
	wall("z", ROOM_X, ROOM_Z0, ROOM_Z1, rightOpen)
end
wall("x", ROOM_Z1, -ROOM_X - 0.5, ROOM_X + 0.5, windowsAlong(-ROOM_X, ROOM_X, 14, 9))
wall("x", ROOM_Z0, -ROOM_X - 0.5, ROOM_X + 0.5, {})

-- 문틀 & 표지판
box(ROOM_X - 0.7, 0, DOOR_Z0 - 0.6, ROOM_X + 0.7, 10.6, DOOR_Z0, { Color = Color3.fromRGB(90, 70, 50) })
box(ROOM_X - 0.7, 0, DOOR_Z1, ROOM_X + 0.7, 10.6, DOOR_Z1 + 0.6, { Color = Color3.fromRGB(90, 70, 50) })
local doorSign = box(ROOM_X - 0.8, 11.2, DOOR_Z0, ROOM_X - 0.6, 12.8, DOOR_Z1, { Color = Color3.fromRGB(30, 58, 138) })
surfaceText(doorSign, Enum.NormalId.Left, "출입문", Color3.new(1, 1, 1))

-- 천장 조명
for _, x in ipairs({ -45, -15, 15, 45 }) do
	for _, z in ipairs({ -20, 6, 32, 58 }) do
		local lamp = part({ Name = "Lamp", Size = Vector3.new(10, 0.3, 2), Position = Vector3.new(x, WALL_H - 0.2, z), Color = Color3.new(1, 1, 1), Material = Enum.Material.Neon })
		local light = Instance.new("PointLight")
		light.Range = 26
		light.Brightness = 1.2
		light.Parent = lamp
	end
end

-- 칠판
local board = part({ Name = "Blackboard", Size = Vector3.new(72, 9, 0.4), Position = Vector3.new(0, 8.5, ROOM_Z0 + 0.7), Color = Color3.fromRGB(31, 77, 58) })
surfaceText(board, Enum.NormalId.Back, "2027학년도 대학수학능력시험\n부정행위 적발 시 가루 처리", Color3.fromRGB(233, 245, 238), Enum.Font.GothamBlack)

-- 스폰 (교실 뒤쪽)
local spawn = Instance.new("SpawnLocation")
spawn.Anchored = true
spawn.Size = Vector3.new(6, 1, 6)
spawn.Position = Vector3.new(0, 0, ROOM_Z1 - 6)
spawn.Transparency = 1
spawn.CanCollide = false
spawn.Neutral = true
spawn.Duration = 0
spawn.Parent = world

-------------------------------------------------------------------
-- 책상
-------------------------------------------------------------------
local desks = {} -- { pos, occupant = Player|nil, seed, dying }
local COLS_X = { -49, -35, -21, -7, 7, 21, 35, 49 }
local ROWS_Z = { -16, -2, 12, 26, 40, 54 }

local function buildDesk(pos)
	local deskZ = pos.Z - 2.2
	part({ Size = Vector3.new(5, 0.4, 3), Position = Vector3.new(pos.X, 3, deskZ), Color = Color3.fromRGB(141, 110, 79), Material = Enum.Material.Wood })
	for _, dx in ipairs({ -2.2, 2.2 }) do
		for _, dz in ipairs({ -1.2, 1.2 }) do
			part({ Size = Vector3.new(0.3, 2.8, 0.3), Position = Vector3.new(pos.X + dx, 1.4, deskZ + dz), Color = Color3.fromRGB(80, 80, 85), Material = Enum.Material.Metal })
		end
	end
	part({ Size = Vector3.new(2, 0.05, 1.4), Position = Vector3.new(pos.X, 3.23, deskZ), Color = Color3.fromRGB(251, 247, 234) })
	part({ Size = Vector3.new(2.6, 0.3, 2.4), Position = Vector3.new(pos.X, 1.8, pos.Z + 0.3), Color = Color3.fromRGB(141, 110, 79) })
	part({ Size = Vector3.new(2.6, 2.4, 0.3), Position = Vector3.new(pos.X, 3.1, pos.Z + 1.5), Color = Color3.fromRGB(141, 110, 79) })
end

for r, z in ipairs(ROWS_Z) do
	for c, x in ipairs(COLS_X) do
		local i = (r - 1) * #COLS_X + c
		desks[i] = { pos = Vector3.new(x, 0, z), seed = 1000 + i * 97 }
		buildDesk(desks[i].pos)
	end
end

-------------------------------------------------------------------
-- 도로 & 차
-------------------------------------------------------------------
local ROAD_X0, ROAD_X1 = 82, 110
local ROAD_LEN = 340
box(ROOM_X, -0.2, -ROAD_LEN / 2, ROAD_X0, 0.3, ROAD_LEN / 2, { Name = "Sidewalk", Color = Color3.fromRGB(190, 190, 185), Material = Enum.Material.Concrete })
box(ROAD_X0, -0.2, -ROAD_LEN / 2, ROAD_X1, 0.05, ROAD_LEN / 2, { Name = "Road", Color = Color3.fromRGB(55, 57, 62), Material = Enum.Material.Asphalt })
box(ROAD_X1, -0.2, -ROAD_LEN / 2, ROAD_X1 + 8, 0.3, ROAD_LEN / 2, { Name = "Sidewalk2", Color = Color3.fromRGB(190, 190, 185), Material = Enum.Material.Concrete })
-- 중앙선
box(95.7, 0.05, -ROAD_LEN / 2, 96.3, 0.1, ROAD_LEN / 2, { Color = Color3.fromRGB(240, 190, 40), Material = Enum.Material.SmoothPlastic, CanCollide = false })
-- 차선
for z = -ROAD_LEN / 2, ROAD_LEN / 2 - 8, 14 do
	for _, x in ipairs({ 89, 103 }) do
		box(x - 0.2, 0.05, z, x + 0.2, 0.1, z + 7, { Color = Color3.new(1, 1, 1), Material = Enum.Material.SmoothPlastic, CanCollide = false })
	end
end
-- 횡단보도 (차는 안 멈춤)
for x = ROAD_X0 + 1, ROAD_X1 - 2, 3 do
	box(x, 0.05, DOOR_Z0 - 2, x + 1.6, 0.1, DOOR_Z1 + 2, { Color = Color3.new(1, 1, 1), Material = Enum.Material.SmoothPlastic, CanCollide = false })
end

-- 차선: x 위치, 방향(+1 = +Z 쪽으로)
local LANES = { { x = 85.5, dir = 1 }, { x = 92.5, dir = 1 }, { x = 99.5, dir = -1 }, { x = 106.5, dir = -1 } }
local CAR_COLORS = { Color3.fromRGB(200, 40, 40), Color3.fromRGB(30, 60, 160), Color3.fromRGB(240, 240, 240), Color3.fromRGB(30, 30, 30), Color3.fromRGB(240, 190, 30), Color3.fromRGB(40, 140, 80), Color3.fromRGB(150, 150, 155) }
local carFolder = Instance.new("Folder")
carFolder.Name = "Cars"
carFolder.Parent = world
local cars = {}

local function buildCar(color)
	local m = Instance.new("Model")
	m.Name = "Car"
	local body = part({ Parent = m, Name = "Body", Size = Vector3.new(6, 2, 12), CFrame = CFrame.new(0, 1.8, 0), Color = color, CanCollide = false, Material = Enum.Material.SmoothPlastic })
	part({ Parent = m, Size = Vector3.new(5.4, 1.8, 6), CFrame = CFrame.new(0, 3.7, 0.8), Color = Color3.fromRGB(40, 50, 60), Material = Enum.Material.Glass, Transparency = 0.2, CanCollide = false })
	for _, x in ipairs({ -2.8, 2.8 }) do
		for _, z in ipairs({ -3.8, 3.8 }) do
			local w = part({ Parent = m, Size = Vector3.new(0.8, 2, 2), CFrame = CFrame.new(x, 1, z) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(20, 20, 20), Shape = Enum.PartType.Cylinder, CanCollide = false })
			w.Size = Vector3.new(0.8, 2, 2)
		end
	end
	for _, x in ipairs({ -2, 2 }) do
		part({ Parent = m, Size = Vector3.new(1.2, 0.6, 0.2), CFrame = CFrame.new(x, 2, -6.05), Color = Color3.fromRGB(255, 250, 220), Material = Enum.Material.Neon, CanCollide = false })
		part({ Parent = m, Size = Vector3.new(1.2, 0.6, 0.2), CFrame = CFrame.new(x, 2, 6.05), Color = Color3.fromRGB(220, 30, 30), Material = Enum.Material.Neon, CanCollide = false })
	end
	m.PrimaryPart = body
	return m
end

local function spawnCar(lane)
	local m = buildCar(CAR_COLORS[math.random(1, #CAR_COLORS)])
	local z = -lane.dir * ROAD_LEN / 2
	local car = { model = m, lane = lane, z = z, speed = math.random(90, 140) }
	m:PivotTo(CFrame.new(lane.x, 0, z) * CFrame.Angles(0, lane.dir == 1 and math.pi or 0, 0))
	m.Parent = carFolder
	table.insert(cars, car)
end

for _, lane in ipairs(LANES) do
	lane.next = math.random() * 2
end

-------------------------------------------------------------------
-- 매점
-------------------------------------------------------------------
local SX0, SX1, SZ0, SZ1 = ROAD_X1 + 10, ROAD_X1 + 46, 16, 64
local SDOOR0, SDOOR1 = 36, 44
local storeWall = Color3.fromRGB(245, 240, 230)
box(SX0, -0.2, SZ0, SX1, 0.2, SZ1, { Name = "StoreFloor", Color = Color3.fromRGB(220, 220, 225), Material = Enum.Material.Marble })
box(SX0, 12, SZ0, SX1, 13, SZ1, { Name = "StoreRoof", Color = Color3.fromRGB(200, 70, 60) })
-- 앞벽 (도로 쪽, 유리문 구멍)
box(SX0, 0, SZ0, SX0 + 1, 12, SDOOR0, { Color = storeWall })
box(SX0, 0, SDOOR1, SX0 + 1, 12, SZ1, { Color = storeWall })
box(SX0, 9, SDOOR0, SX0 + 1, 12, SDOOR1, { Color = storeWall })
box(SX0, 3, SZ0 + 4, SX0 + 1.1, 8, SDOOR0 - 3, GLASS)
box(SX0, 3, SDOOR1 + 3, SX0 + 1.1, 8, SZ1 - 4, GLASS)
box(SX1 - 1, 0, SZ0, SX1, 12, SZ1, { Color = storeWall })
box(SX0, 0, SZ0, SX1, 12, SZ0 + 1, { Color = storeWall })
box(SX0, 0, SZ1 - 1, SX1, 12, SZ1, { Color = storeWall })
local sign = box(SX0 - 0.6, 12.5, SZ0 + 8, SX0 - 0.2, 17, SZ1 - 8, { Color = Color3.fromRGB(200, 40, 40) })
surfaceText(sign, Enum.NormalId.Left, "매점", Color3.new(1, 1, 1), Enum.Font.GothamBlack)
do
	local lamp = part({ Size = Vector3.new(16, 0.3, 2), Position = Vector3.new((SX0 + SX1) / 2, 11.8, 40), Color = Color3.new(1, 1, 1), Material = Enum.Material.Neon })
	local light = Instance.new("PointLight")
	light.Range = 30
	light.Brightness = 1.5
	light.Parent = lamp
end
-- 선반과 상품
local PRODUCT_C = { Color3.fromRGB(240, 200, 60), Color3.fromRGB(220, 60, 60), Color3.fromRGB(60, 140, 220), Color3.fromRGB(250, 240, 200), Color3.fromRGB(120, 70, 40), Color3.fromRGB(60, 180, 90) }
for _, z in ipairs({ SZ0 + 6, SZ1 - 6 }) do
	box(SX0 + 12, 0, z - 1.5, SX1 - 4, 7, z + 1.5, { Color = Color3.fromRGB(180, 180, 185), Material = Enum.Material.Metal })
	for x = SX0 + 13, SX1 - 6, 2 do
		for _, y in ipairs({ 2.5, 5 }) do
			part({ Size = Vector3.new(1.4, 1.6, 1), Position = Vector3.new(x, y + 2.3 - 2.3 + 0.8, z - 1.9), Color = PRODUCT_C[math.random(1, #PRODUCT_C)] })
		end
	end
end
-- 계산대
local counter = box(SX1 - 12, 0, 34, SX1 - 8, 4, 46, { Name = "Counter", Color = Color3.fromRGB(120, 90, 60), Material = Enum.Material.Wood })
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "물건 사기"
prompt.ObjectText = "매점"
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = counter
-- 매점 주인 (블록 캐릭터)
do
	local cx, cz = SX1 - 5, 40
	part({ Size = Vector3.new(2, 2.5, 1), Position = Vector3.new(cx, 1.25, cz), Color = Color3.fromRGB(40, 40, 60) })
	part({ Size = Vector3.new(2, 2, 1), Position = Vector3.new(cx, 3.5, cz), Color = Color3.fromRGB(230, 120, 40) })
	local h = part({ Size = Vector3.new(1.6, 1.6, 1.6), Position = Vector3.new(cx, 5.3, cz), Color = Color3.fromRGB(243, 210, 179), Shape = Enum.PartType.Ball })
	makeBillboard(h, "매점 아주머니", 2, Color3.fromRGB(255, 230, 180))
end

-------------------------------------------------------------------
-- 부정행위 전문점 (매점 옆)
-------------------------------------------------------------------
local PZ0, PZ1 = SZ1 + 6, SZ1 + 52
local PDOOR0, PDOOR1 = PZ0 + 19, PZ0 + 27
local proWall = Color3.fromRGB(45, 30, 70)
box(SX0, -0.2, PZ0, SX1, 0.2, PZ1, { Color = Color3.fromRGB(30, 30, 40), Material = Enum.Material.Slate })
box(SX0, 12, PZ0, SX1, 13, PZ1, { Color = Color3.fromRGB(25, 20, 35) })
box(SX0, 0, PZ0, SX0 + 1, 12, PDOOR0, { Color = proWall })
box(SX0, 0, PDOOR1, SX0 + 1, 12, PZ1, { Color = proWall })
box(SX0, 9, PDOOR0, SX0 + 1, 12, PDOOR1, { Color = proWall })
box(SX0, 3, PZ0 + 4, SX0 + 1.1, 8, PDOOR0 - 3, { Color = Color3.fromRGB(60, 40, 90), Material = Enum.Material.Glass, Transparency = 0.3 })
box(SX0, 3, PDOOR1 + 3, SX0 + 1.1, 8, PZ1 - 4, { Color = Color3.fromRGB(60, 40, 90), Material = Enum.Material.Glass, Transparency = 0.3 })
box(SX1 - 1, 0, PZ0, SX1, 12, PZ1, { Color = proWall })
box(SX0, 0, PZ0, SX1, 12, PZ0 + 1, { Color = proWall })
box(SX0, 0, PZ1 - 1, SX1, 12, PZ1, { Color = proWall })
local proSign = box(SX0 - 0.6, 12.5, PZ0 + 5, SX0 - 0.2, 17, PZ1 - 5, { Color = Color3.fromRGB(20, 10, 30) })
surfaceText(proSign, Enum.NormalId.Left, "부정행위 전문점", Color3.fromRGB(190, 120, 255), Enum.Font.GothamBlack)
do
	local neon = box(SX0 - 0.7, 12.3, PZ0 + 5, SX0 - 0.5, 12.5, PZ1 - 5, { Color = Color3.fromRGB(170, 80, 255), Material = Enum.Material.Neon })
	local l = Instance.new("PointLight")
	l.Color = Color3.fromRGB(170, 80, 255)
	l.Range = 20
	l.Brightness = 2
	l.Parent = neon
	local lamp = part({ Size = Vector3.new(16, 0.3, 2), Position = Vector3.new((SX0 + SX1) / 2, 11.8, (PZ0 + PZ1) / 2), Color = Color3.fromRGB(200, 160, 255), Material = Enum.Material.Neon })
	local l2 = Instance.new("PointLight")
	l2.Range = 30
	l2.Brightness = 1.3
	l2.Color = Color3.fromRGB(210, 190, 255)
	l2.Parent = lamp
end
-- 진열대: 빛나는 전자기기들
local GADGET_C = { Color3.fromRGB(80, 220, 255), Color3.fromRGB(255, 80, 200), Color3.fromRGB(120, 255, 140), Color3.fromRGB(255, 220, 80), Color3.fromRGB(170, 120, 255) }
for _, z in ipairs({ PZ0 + 6, PZ1 - 6 }) do
	box(SX0 + 12, 0, z - 1.5, SX1 - 4, 6, z + 1.5, { Color = Color3.fromRGB(40, 40, 50), Material = Enum.Material.Metal })
	for x = SX0 + 13, SX1 - 6, 2.5 do
		for _, y in ipairs({ 2.8, 5.4 }) do
			part({ Size = Vector3.new(1.2, 0.8, 0.3), Position = Vector3.new(x, y, z - 1.7), Color = GADGET_C[math.random(1, #GADGET_C)], Material = Enum.Material.Neon })
		end
	end
end
local proCounter = box(SX1 - 12, 0, PDOOR0 - 2, SX1 - 8, 4, PDOOR1 + 2, { Name = "ProCounter", Color = Color3.fromRGB(20, 20, 25), Material = Enum.Material.Glass, Reflectance = 0.2 })
local proPrompt = Instance.new("ProximityPrompt")
proPrompt.ActionText = "장비 구매"
proPrompt.ObjectText = "부정행위 전문점"
proPrompt.HoldDuration = 0
proPrompt.MaxActivationDistance = 12
proPrompt.RequiresLineOfSight = false
proPrompt.Parent = proCounter
do
	local cx, cz = SX1 - 5, (PDOOR0 + PDOOR1) / 2
	part({ Size = Vector3.new(2, 2.5, 1), Position = Vector3.new(cx, 1.25, cz), Color = Color3.fromRGB(20, 20, 20) })
	part({ Size = Vector3.new(2, 2, 1), Position = Vector3.new(cx, 3.5, cz), Color = Color3.fromRGB(25, 25, 30) })
	local h = part({ Size = Vector3.new(1.6, 1.6, 1.6), Position = Vector3.new(cx, 5.3, cz), Color = Color3.fromRGB(243, 210, 179), Shape = Enum.PartType.Ball })
	part({ Size = Vector3.new(1.4, 0.35, 0.2), Position = Vector3.new(cx - 0.85, 5.45, cz), Orientation = Vector3.new(0, 90, 0), Color = Color3.fromRGB(10, 10, 10) })
	makeBillboard(h, "전문점 사장", 2, Color3.fromRGB(200, 160, 255))
end

-------------------------------------------------------------------
-- 업그레이드 전문점 (매점 왼쪽)
-------------------------------------------------------------------
local UZ1, UZ0 = SZ0 - 6, SZ0 - 52
local UDOOR0, UDOOR1 = UZ0 + 19, UZ0 + 27
local upWall = Color3.fromRGB(28, 60, 80)
box(SX0, -0.2, UZ0, SX1, 0.2, UZ1, { Color = Color3.fromRGB(60, 70, 80), Material = Enum.Material.DiamondPlate })
box(SX0, 12, UZ0, SX1, 13, UZ1, { Color = Color3.fromRGB(20, 40, 55) })
box(SX0, 0, UZ0, SX0 + 1, 12, UDOOR0, { Color = upWall })
box(SX0, 0, UDOOR1, SX0 + 1, 12, UZ1, { Color = upWall })
box(SX0, 9, UDOOR0, SX0 + 1, 12, UDOOR1, { Color = upWall })
box(SX0, 3, UZ0 + 4, SX0 + 1.1, 8, UDOOR0 - 3, { Color = Color3.fromRGB(80, 170, 200), Material = Enum.Material.Glass, Transparency = 0.4 })
box(SX0, 3, UDOOR1 + 3, SX0 + 1.1, 8, UZ1 - 4, { Color = Color3.fromRGB(80, 170, 200), Material = Enum.Material.Glass, Transparency = 0.4 })
box(SX1 - 1, 0, UZ0, SX1, 12, UZ1, { Color = upWall })
box(SX0, 0, UZ0, SX1, 12, UZ0 + 1, { Color = upWall })
box(SX0, 0, UZ1 - 1, SX1, 12, UZ1, { Color = upWall })
local upSign = box(SX0 - 0.6, 12.5, UZ0 + 5, SX0 - 0.2, 17, UZ1 - 5, { Color = Color3.fromRGB(10, 25, 35) })
surfaceText(upSign, Enum.NormalId.Left, "업그레이드 전문점", Color3.fromRGB(90, 230, 255), Enum.Font.GothamBlack)
do
	local neon = box(SX0 - 0.7, 12.3, UZ0 + 5, SX0 - 0.5, 12.5, UZ1 - 5, { Color = Color3.fromRGB(60, 220, 255), Material = Enum.Material.Neon })
	local l = Instance.new("PointLight")
	l.Color = Color3.fromRGB(60, 220, 255)
	l.Range = 20
	l.Brightness = 2
	l.Parent = neon
	local lamp = part({ Size = Vector3.new(16, 0.3, 2), Position = Vector3.new((SX0 + SX1) / 2, 11.8, (UZ0 + UZ1) / 2), Color = Color3.fromRGB(200, 240, 255), Material = Enum.Material.Neon })
	local l2 = Instance.new("PointLight")
	l2.Range = 30
	l2.Brightness = 1.3
	l2.Parent = lamp
	-- 작업대와 위로 향한 화살표 장식
	local mx, mz = SX0 + 18, (UZ0 + UZ1) / 2
	box(mx - 3, 0, mz - 2, mx + 3, 3, mz + 2, { Color = Color3.fromRGB(70, 70, 75), Material = Enum.Material.Metal })
	box(mx - 2, 3, mz - 1.2, mx + 2, 4.2, mz + 1.2, { Color = Color3.fromRGB(50, 50, 55), Material = Enum.Material.Metal })
	for i = 0, 2 do
		local a = part({ Size = Vector3.new(0.4, 1.6, 1.6), Position = Vector3.new(SX1 - 2, 4 + i * 2.6, UZ0 + 8), Orientation = Vector3.new(45, 0, 0), Color = Color3.fromRGB(60, 220, 255), Material = Enum.Material.Neon })
		a.Name = "Arrow"
		local b = part({ Size = Vector3.new(0.4, 1.6, 1.6), Position = Vector3.new(SX1 - 2, 4 + i * 2.6, UZ1 - 8), Orientation = Vector3.new(45, 0, 0), Color = Color3.fromRGB(60, 220, 255), Material = Enum.Material.Neon })
		b.Name = "Arrow"
	end
end
local upCounter = box(SX1 - 12, 0, UDOOR0 - 2, SX1 - 8, 4, UDOOR1 + 2, { Name = "UpCounter", Color = Color3.fromRGB(40, 70, 90), Material = Enum.Material.Metal })
local upPrompt = Instance.new("ProximityPrompt")
upPrompt.ActionText = "업그레이드"
upPrompt.ObjectText = "업그레이드 전문점"
upPrompt.HoldDuration = 0
upPrompt.MaxActivationDistance = 12
upPrompt.RequiresLineOfSight = false
upPrompt.Parent = upCounter
do
	local cx, cz = SX1 - 5, (UDOOR0 + UDOOR1) / 2
	part({ Size = Vector3.new(2, 2.5, 1), Position = Vector3.new(cx, 1.25, cz), Color = Color3.fromRGB(60, 50, 40) })
	part({ Size = Vector3.new(2, 2, 1), Position = Vector3.new(cx, 3.5, cz), Color = Color3.fromRGB(150, 110, 60) })
	local h = part({ Size = Vector3.new(1.6, 1.6, 1.6), Position = Vector3.new(cx, 5.3, cz), Color = Color3.fromRGB(243, 210, 179), Shape = Enum.PartType.Ball })
	part({ Size = Vector3.new(1.2, 0.5, 1.2), Position = Vector3.new(cx, 6.1, cz), Color = Color3.fromRGB(255, 200, 40) })
	makeBillboard(h, "강화 장인", 2, Color3.fromRGB(150, 230, 255))
end

-------------------------------------------------------------------
-- 뉴비 감독관
-------------------------------------------------------------------
local VIEW_RANGE = 40
local VIEW_ANGLE = math.rad(32)
local NOOB_YELLOW = Color3.fromRGB(245, 205, 48)
local NOOB_BLUE = Color3.fromRGB(13, 105, 172)
local NOOB_GREEN = Color3.fromRGB(75, 151, 75)

local teacher = Instance.new("Model")
teacher.Name = "Teacher"
local tRoot = part({ Parent = teacher, Name = "Root", Size = Vector3.new(2, 2, 1), Position = Vector3.new(0, 4.5, 0), Color = NOOB_BLUE, CanCollide = false })
local function tPart(name, size, offset, color)
	return part({ Parent = teacher, Name = name, Size = size, CFrame = tRoot.CFrame * CFrame.new(offset), Color = color, CanCollide = false })
end
tPart("LegL", Vector3.new(1, 2.5, 1), Vector3.new(-0.5, -2.25, 0), NOOB_GREEN)
tPart("LegR", Vector3.new(1, 2.5, 1), Vector3.new(0.5, -2.25, 0), NOOB_GREEN)
tPart("ArmL", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0), NOOB_YELLOW)
tPart("ArmR", Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0), NOOB_YELLOW)
local tHead = tPart("Head", Vector3.new(2, 1, 1), Vector3.new(0, 1.5, 0), NOOB_YELLOW)
do
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Head
	mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
	mesh.Parent = tHead
	local face = Instance.new("Decal")
	face.Name = "face"
	face.Face = Enum.NormalId.Front
	face.Texture = "rbxasset://textures/face.png"
	face.Parent = tHead
end
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
makeBillboard(tHead, "뉴비 감독관", 2.2, Color3.fromRGB(255, 143, 163))
local speech = makeBillboard(tHead, "", 4.5, Color3.fromRGB(201, 24, 74))
speech.Size = UDim2.fromOffset(420, 60)
speech.Label.BackgroundTransparency = 0
speech.Label.BackgroundColor3 = Color3.new(1, 1, 1)
speech.Enabled = false
teacher.PrimaryPart = tRoot
teacher.Parent = world

local tState = { pos = Vector3.new(0, 4.5, ROOM_Z0 + 6), look = 0, target = nil, wait = 2 }
local freeze = 0

local function teacherCF()
	return CFrame.new(tState.pos) * CFrame.Angles(0, tState.look, 0)
end
teacher:PivotTo(teacherCF())

local function inRoom(pos)
	return math.abs(pos.X) < ROOM_X and pos.Z > ROOM_Z0 and pos.Z < ROOM_Z1
end

local function teacherSees(pos)
	if not inRoom(pos) then
		return false
	end
	local v = pos - tState.pos
	v = Vector3.new(v.X, 0, v.Z)
	if v.Magnitude < 3 then
		return true
	end
	if v.Magnitude > VIEW_RANGE then
		return false
	end
	local look = teacherCF().LookVector
	look = Vector3.new(look.X, 0, look.Z).Unit
	return math.acos(math.clamp(look:Dot(v.Unit), -1, 1)) < VIEW_ANGLE
end

-------------------------------------------------------------------
-- 플레이어 데이터
-------------------------------------------------------------------
local sessions = {} -- [player] = 시험 상태
local inventory = {} -- [player] = { [id] = 개수 }
local owned = {} -- [player] = { [기기 이름] = true }
local proCount = {} -- [player] = 전문점 구매 횟수 (갈수록 2배)
local gearLv = {} -- [player] = { [부정행위 이름] = 강화 단계 }
local perks = {} -- [player] = { stealth = n, poker = n, quick = n }

local function cheatFor(player, name)
	return Shared.makeCheat(name, owned[player] and owned[player][name], gearLv[player] and gearLv[player][name] or 0)
end
local function perk(player, id)
	return perks[player] and perks[player][id] or 0
end
local function sendUpgrades(player)
	remote:FireClient(player, "Upgrades", { perks = perks[player] or {}, gear = gearLv[player] or {} })
end

local function moneyOf(player)
	local ls = player:FindFirstChild("leaderstats")
	return ls and ls:FindFirstChild("돈")
end

local function toast(player, msg)
	remote:FireClient(player, "Toast", msg)
end

local function sendInventory(player)
	remote:FireClient(player, "Inventory", inventory[player] or {})
end

local function filterFor(player, str)
	local ok, res = pcall(function()
		local r = TextService:FilterStringAsync(str, player.UserId)
		return r:GetNonChatStringForUserAsync(player.UserId)
	end)
	if ok and res then
		return res
	end
	return "???"
end

local function logAll(str)
	remote:FireAllClients("Log", str)
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

local function getParts(player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	return char, hum, hrp
end

-- 가루 효과
local function dustParts(list)
	local count = 0
	for _, p in ipairs(list) do
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
		end
	end
end

local function seatPlayer(player, i)
	local _, hum, hrp = getParts(player)
	if hrp and hum then
		hum.WalkSpeed = 0
		hum.UseJumpPower = true
		hum.JumpPower = 0
		local p = desks[i].pos
		hrp.CFrame = CFrame.new(p.X, 3.2, p.Z + 0.3)
		hrp.Anchored = true
	end
end

local function freePlayer(player, where)
	local _, hum, hrp = getParts(player)
	if hrp and hum then
		hrp.Anchored = false
		hum.WalkSpeed = 16
		hum.UseJumpPower = true
		hum.JumpPower = 50
		if where then
			hrp.CFrame = where
		end
	end
end

-- reason: nil(정상 종료/시간 종료) | "caught" | "car"
local function endSession(player, reason)
	local s = sessions[player]
	if not s or s.ended then
		return
	end
	s.ended = true
	remote:FireClient(player, "End", {
		reason = reason,
		score = s.score,
		answered = s.qi - 1,
		grade = Shared.grade(s.score),
		timeUp = s.timeLeft <= 0,
	})
	local _, d = deskOf(player)
	if d then
		d.occupant = nil
	end
	sessions[player] = nil
	if reason == "caught" then
		player:LoadCharacter()
	elseif reason == nil then
		freePlayer(player, CFrame.new(0, 3, ROOM_Z1 - 6))
	end
end

local function catchAt(deskIndex, victim)
	local d = desks[deskIndex]
	if not d or d.dying then
		return
	end
	d.dying = true
	freeze = freeze + 1
	local s = sessions[victim]
	if s then
		s.cheating = false
	end
	local _, _, hrp = getParts(victim)
	local target = (s and s.away and hrp) and hrp.Position or d.pos
	local v = target - tState.pos
	tState.look = math.atan2(-v.X, -v.Z)
	teacher:PivotTo(teacherCF())
	speech.Label.Text = Shared.DOMAIN_LINE
	speech.Enabled = true
	logAll(victim.DisplayName .. " 적발")
	remote:FireAllClients("Domain", victim.DisplayName)

	task.wait(2)
	speech.Enabled = false
	local char = victim.Character
	if char then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Anchored = true
			end
		end
		dustParts(char:GetDescendants())
	end
	freeze = freeze - 1
	d.dying = false
	task.wait(2.5)
	endSession(victim, "caught")
end

local function nearestNeighbor(deskIndex)
	local me = desks[deskIndex]
	local best, bestD
	for i, d in ipairs(desks) do
		if i ~= deskIndex and d.occupant and not d.dying then
			local dist = (d.pos - me.pos).Magnitude
			if dist < 20 and (not bestD or dist < bestD) then
				best, bestD = i, dist
			end
		end
	end
	return best
end

local function seedOf(i)
	local d = desks[i]
	if d.occupant and sessions[d.occupant] then
		return sessions[d.occupant].seed
	end
	return d.seed
end

-------------------------------------------------------------------
-- 접속 / 캐릭터
-------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	local money = Instance.new("IntValue")
	money.Name = "돈"
	money.Value = Shared.START_MONEY
	money.Parent = ls
	ls.Parent = player
	inventory[player] = {}
	owned[player] = {}
	proCount[player] = 0
	gearLv[player] = {}
	perks[player] = {}
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			local s = sessions[player]
			if s and not s.ended then
				endSession(player, s.deathReason or "car")
			end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local _, d = deskOf(player)
	sessions[player] = nil
	inventory[player] = nil
	owned[player] = nil
	proCount[player] = nil
	gearLv[player] = nil
	perks[player] = nil
	if d then
		d.occupant = nil
	end
end)

proPrompt.Triggered:Connect(function(player)
	local m = moneyOf(player)
	remote:FireClient(player, "OpenProShop", m and m.Value or 0, proCount[player] or 0)
end)

upPrompt.Triggered:Connect(function(player)
	local m = moneyOf(player)
	sendUpgrades(player)
	remote:FireClient(player, "OpenUpShop", m and m.Value or 0)
end)

prompt.Triggered:Connect(function(player)
	local m = moneyOf(player)
	remote:FireClient(player, "OpenShop", m and m.Value or 0)
end)

-------------------------------------------------------------------
-- 클라이언트 요청
-------------------------------------------------------------------
remote.OnServerEvent:Connect(function(player, action, arg, extra)
	local s = sessions[player]
	if action == "Start" then
		if s or type(arg) ~= "string" then
			return
		end
		local order = {}
		for i = 1, #desks do
			order[i] = i
		end
		table.sort(order, function(a, b)
			return desks[a].pos.Magnitude < desks[b].pos.Magnitude
		end)
		local seat
		for _, i in ipairs(order) do
			if desks[i].occupant == nil and not desks[i].dying then
				seat = i
				break
			end
		end
		if not seat then
			toast(player, "빈자리가 없습니다.")
			return
		end
		desks[seat].occupant = player
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
		local cheatName = Shared.clip(arg, 20)
		sessions[player] = {
			seed = math.random(1, 999999),
			questions = qs,
			qi = 1,
			score = 0,
			timeLeft = Shared.TIME_LIMIT,
			suspicion = 0,
			luck = 0,
			cheating = false,
			away = false,
			nextEmptyCheck = 0,
			cheat = cheatFor(player, cheatName),
			cheatShown = filterFor(player, cheatName),
			desk = seat,
		}
		seatPlayer(player, seat)
		logAll(player.DisplayName .. " 입실 (" .. seat .. "번 자리)")
		sendQuestion(player, sessions[player])
	elseif action == "Answer" then
		if not s or s.ended or s.away or freeze > 0 or type(arg) ~= "number" then
			return
		end
		local _, correct = Shared.paperFor(s.seed, s.questions[s.qi])
		if arg == correct then
			s.score = s.score + 1
		end
		s.qi = s.qi + 1
		if s.qi > Shared.TOTAL_Q then
			endSession(player, nil)
		else
			sendQuestion(player, s)
		end
	elseif action == "Cheat" then
		if not s or s.ended or s.cheating or s.away or freeze > 0 then
			return
		end
		if type(arg) == "string" and arg ~= s.cheat.name then
			local n = Shared.clip(arg, 20)
			s.cheat = cheatFor(player, n)
			s.cheatShown = filterFor(player, n)
		end
		s.cheating = true
		-- 같은 이름이어도 강화/정품 상태가 바뀌었을 수 있으니 다시 계산
		s.cheat = cheatFor(player, s.cheat.name)
		local dur = math.max(1, Shared.CHEAT_TIME - 0.4 * perk(player, "quick"))
		s.cheatEnd = os.clock() + dur
		remote:FireClient(player, "CheatStart", dur)
	elseif action == "Leave" then
		-- 몰래 자리 비우기
		if not s or s.ended or s.away or s.cheating or freeze > 0 then
			return
		end
		s.away = true
		local p = desks[s.desk].pos
		freePlayer(player, CFrame.new(p.X + 7, 3, p.Z))
		local _, hum = getParts(player)
		if hum then
			hum.WalkSpeed = 14 + 3 * perk(player, "stealth")
		end
		remote:FireClient(player, "Away", true)
	elseif action == "Return" then
		if not s or s.ended or not s.away then
			return
		end
		local _, _, hrp = getParts(player)
		if not hrp or (hrp.Position - desks[s.desk].pos).Magnitude > 10 then
			toast(player, "자기 자리(" .. s.desk .. "번) 가까이 가야 앉을 수 있어요.")
			return
		end
		s.away = false
		seatPlayer(player, s.desk)
		remote:FireClient(player, "Away", false)
	elseif action == "Buy" then
		local item = type(arg) == "string" and Shared.shopItem(arg)
		local m = moneyOf(player)
		local _, _, hrp = getParts(player)
		if not item or not m or not hrp then
			return
		end
		if (hrp.Position - counter.Position).Magnitude > 18 then
			toast(player, "계산대 가까이 가야 살 수 있어요.")
			return
		end
		if m.Value < item.price then
			toast(player, "돈이 부족해요.")
			return
		end
		m.Value = m.Value - item.price
		local inv = inventory[player]
		inv[item.id] = (inv[item.id] or 0) + 1
		sendInventory(player)
		remote:FireClient(player, "Money", m.Value)
		toast(player, item.name .. " 구매 완료")
	elseif action == "BuyPro" then
		if type(arg) ~= "string" then
			return
		end
		local name = Shared.clip(arg, 20)
		local m = moneyOf(player)
		local _, _, hrp = getParts(player)
		if name == "" or not m or not hrp or not owned[player] then
			return
		end
		if (hrp.Position - proCounter.Position).Magnitude > 18 then
			toast(player, "전문점 계산대 가까이 가야 살 수 있어요.")
			return
		end
		if owned[player][name] then
			toast(player, "이미 가지고 있어요.")
			return
		end
		local price = Shared.doubled(Shared.proPrice(name), proCount[player])
		if m.Value < price then
			toast(player, "돈이 부족해요. (" .. price .. "원)")
			return
		end
		m.Value = m.Value - price
		owned[player][name] = true
		proCount[player] = proCount[player] + 1
		local list = {}
		for k in pairs(owned[player]) do
			table.insert(list, k)
		end
		remote:FireClient(player, "Owned", list, name, proCount[player])
		toast(player, filterFor(player, name) .. " 구매 완료 (정품: 성공률 +25%, 적발 확률 -15%)")
	elseif action == "Upgrade" then
		local u = type(arg) == "string" and Shared.upgrade(arg)
		local m = moneyOf(player)
		local _, _, hrp = getParts(player)
		if not u or not m or not hrp or not perks[player] then
			return
		end
		if (hrp.Position - upCounter.Position).Magnitude > 18 then
			toast(player, "업그레이드 전문점 계산대 가까이 가야 해요.")
			return
		end
		local lv, target
		if u.id == "gear" then
			target = Shared.clip(type(extra) == "string" and extra or "", 20)
			if target == "" then
				toast(player, "왼쪽 목록에서 강화할 물건을 고르세요.")
				return
			end
			lv = gearLv[player][target] or 0
		else
			lv = perks[player][u.id] or 0
		end
		if lv >= u.max then
			toast(player, "이미 최대 단계예요.")
			return
		end
		local price = Shared.doubled(u.base, lv)
		if m.Value < price then
			toast(player, "돈이 부족해요. (" .. price .. "원)")
			return
		end
		m.Value = m.Value - price
		if u.id == "gear" then
			gearLv[player][target] = lv + 1
			toast(player, filterFor(player, target) .. " +" .. (lv + 1) .. " 강화 성공")
		else
			perks[player][u.id] = lv + 1
			toast(player, u.name .. " " .. (lv + 1) .. "단계")
		end
		sendUpgrades(player)
	elseif action == "Eat" then
		local item = type(arg) == "string" and Shared.shopItem(arg)
		local inv = inventory[player]
		if not item or not inv or (inv[item.id] or 0) <= 0 then
			return
		end
		inv[item.id] = inv[item.id] - 1
		if inv[item.id] <= 0 then
			inv[item.id] = nil
		end
		if s and not s.ended then
			if item.time then
				s.timeLeft = s.timeLeft + item.time
			end
			if item.sus then
				s.suspicion = math.max(0, s.suspicion + item.sus)
			end
			if item.luck then
				s.luck = math.min(100, s.luck + item.luck)
			end
			remote:FireClient(player, "Timer", s.timeLeft, s.suspicion)
			toast(player, item.name .. " 냠냠 (" .. item.desc .. ")")
		else
			toast(player, item.name .. " 냠냠. 효과는 시험 중에만 있어요.")
		end
		sendInventory(player)
	end
end)

-- 부정행위 끝났을 때
local function finishCheat(player, s)
	s.cheating = false
	s.suspicion = math.min(100, s.suspicion + math.floor(s.cheat.risk / 3 * (1 - 0.2 * perk(player, "poker"))))
	if math.random() * 100 < s.cheat.risk * (0.4 + s.suspicion / 150) then
		task.spawn(catchAt, s.desk, player)
		return
	end
	local qIndex = s.questions[s.qi]
	local _, mine = Shared.paperFor(s.seed, qIndex)
	local msg
	local view = {}
	if s.cheat.copy then
		local n = nearestNeighbor(s.desk)
		if n then
			local _, theirs = Shared.paperFor(seedOf(n), qIndex)
			msg = n .. "번 자리 답안: " .. Shared.NUM[theirs] .. "번  (시험지 유형이 다를 수 있음)"
			view = { ans = theirs, seat = n, q = s.qi }
		else
			msg = "주변에 다른 수험생이 없다."
		end
	else
		local ans = mine
		if math.random() * 100 >= math.min(100, s.cheat.success + s.luck) then
			repeat
				ans = math.random(1, 5)
			until ans ~= mine
		end
		msg = "[" .. s.cheatShown .. "] 정답은 " .. Shared.NUM[ans] .. "번인 것 같다"
		view = { ans = ans, item = s.cheatShown, q = s.qi }
	end
	s.luck = 0
	remote:FireClient(player, "Hint", msg, view)
end

-------------------------------------------------------------------
-- 메인 루프
-------------------------------------------------------------------
local function pickTarget()
	for _, s in pairs(sessions) do
		if not s.away and math.random() < s.suspicion / 150 then
			local p = desks[s.desk].pos
			return Vector3.new(p.X + 7, 4.5, p.Z - 3)
		end
	end
	local xs = { -56, -42, -28, -14, 0, 14, 28, 42, 56 }
	return Vector3.new(xs[math.random(1, #xs)], 4.5, math.random(ROOM_Z0 + 5, ROOM_Z1 - 8))
end

local function updateCars(dt)
	for _, lane in ipairs(LANES) do
		lane.next = lane.next - dt
		if lane.next <= 0 then
			spawnCar(lane)
			lane.next = 0.8 + math.random() * 2
		end
	end
	for i = #cars, 1, -1 do
		local car = cars[i]
		car.z = car.z + car.lane.dir * car.speed * dt
		local cf = CFrame.new(car.lane.x, 0, car.z) * CFrame.Angles(0, car.lane.dir == 1 and math.pi or 0, 0)
		car.model:PivotTo(cf)
		if math.abs(car.z) > ROAD_LEN / 2 + 10 then
			car.model:Destroy()
			table.remove(cars, i)
		else
			-- 치였는지 검사
			for _, player in ipairs(Players:GetPlayers()) do
				local _, hum, hrp = getParts(player)
				if hum and hrp and hum.Health > 0 then
					local lp = (cf + Vector3.new(0, 2, 0)):PointToObjectSpace(hrp.Position)
					if math.abs(lp.X) < 3.8 and math.abs(lp.Z) < 7 and math.abs(lp.Y) < 5 then
						local s = sessions[player]
						if s then
							s.deathReason = "car"
						end
						hrp.Anchored = false
						hrp.AssemblyLinearVelocity = Vector3.new(0, 60, 0) + cf.LookVector * car.speed
						hum.Health = 0
						remote:FireAllClients("Log", player.DisplayName .. " 교통사고")
						toast(player, "차에 치였습니다.")
					end
				end
			end
		end
	end
end

RunService.Heartbeat:Connect(function(dt)
	updateCars(dt)
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
			tState.pos = tState.pos + v.Unit * math.min(dist, 9 * dt)
		end
	end
	teacher:PivotTo(teacherCF())

	local now = os.clock()
	for player, s in pairs(sessions) do
		if not s.ended and not desks[s.desk].dying then
			local _, _, hrp = getParts(player)
			-- 부정행위 중 들킴
			if s.cheating and teacherSees(desks[s.desk].pos) then
				remote:FireClient(player, "CheatCancel")
				task.spawn(catchAt, s.desk, player)
				return
			end
			if s.away then
				-- 몰래 돌아다니다 교실 안에서 들킴
				if hrp and teacherSees(hrp.Position) then
					task.spawn(catchAt, s.desk, player)
					return
				end
				-- 빈자리를 들킴 → 의심도 상승
				if now >= s.nextEmptyCheck and teacherSees(desks[s.desk].pos) then
					s.nextEmptyCheck = now + 6
					s.suspicion = math.min(100, s.suspicion + 25)
					remote:FireClient(player, "Timer", s.timeLeft, s.suspicion)
					toast(player, "감독관이 빈자리를 봤습니다. 의심도 +25")
					if s.suspicion >= 100 then
						task.spawn(catchAt, s.desk, player)
						return
					end
				end
			end
			if s.cheating and now >= s.cheatEnd then
				finishCheat(player, s)
			end
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
						endSession(player, nil)
					end
				end
			end
		end
	end
end)
