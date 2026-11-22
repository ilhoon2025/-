-- 한국 수능 부정행위! : 서버 스크립트 (ServerScriptService)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")

local Shared = require(ReplicatedStorage:WaitForChild("SuneungShared"))

-- 처음엔 캐릭터를 만들지 않음 (플레이하기 버튼을 눌러야 입장)
Players.CharacterAutoLoads = false

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
local board = part({ Name = "Blackboard", Size = Vector3.new(72, 8, 0.4), Position = Vector3.new(0, 11.4, ROOM_Z0 + 0.7), Color = Color3.fromRGB(31, 77, 58) })
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

-- 뉴비 모양 차: 파란 몸통, 노란 머리(운전석)와 팔(옆 날개), 초록 바퀴
local function buildNoobCar()
	local m = Instance.new("Model")
	m.Name = "NoobCar"
	local YELLOW = Color3.fromRGB(245, 205, 48)
	local BLUE = Color3.fromRGB(13, 105, 172)
	local GREEN = Color3.fromRGB(75, 151, 75)
	local body = part({ Parent = m, Name = "Body", Size = Vector3.new(6, 2.4, 11), CFrame = CFrame.new(0, 2, 0), Color = BLUE, Material = Enum.Material.SmoothPlastic, CanCollide = false })
	-- 머리 = 운전석 (웃는 얼굴이 앞을 봄)
	local head = part({ Parent = m, Name = "Head", Size = Vector3.new(4, 2, 2), CFrame = CFrame.new(0, 4.6, 0.5), Color = YELLOW, CanCollide = false })
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Head
	mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
	mesh.Parent = head
	local face = Instance.new("Decal")
	face.Face = Enum.NormalId.Front
	face.Texture = "rbxasset://textures/face.png"
	face.Parent = head
	-- 팔 = 옆 날개
	part({ Parent = m, Size = Vector3.new(1.4, 1.4, 7), CFrame = CFrame.new(-3.7, 2.4, -0.5), Color = YELLOW, CanCollide = false })
	part({ Parent = m, Size = Vector3.new(1.4, 1.4, 7), CFrame = CFrame.new(3.7, 2.4, -0.5), Color = YELLOW, CanCollide = false })
	-- 다리 = 초록 바퀴
	for _, x in ipairs({ -3.2, 3.2 }) do
		for _, z in ipairs({ -3.6, 3.6 }) do
			part({ Parent = m, Size = Vector3.new(1, 2.2, 2.2), CFrame = CFrame.new(x, 1.1, z), Color = GREEN, Shape = Enum.PartType.Cylinder, CanCollide = false })
		end
	end
	-- 헤드라이트
	for _, x in ipairs({ -2, 2 }) do
		part({ Parent = m, Size = Vector3.new(1.2, 0.6, 0.2), CFrame = CFrame.new(x, 2.4, -5.55), Color = Color3.fromRGB(255, 250, 220), Material = Enum.Material.Neon, CanCollide = false })
	end
	m.PrimaryPart = body
	return m
end

-- 베이컨 모양 차 (도로를 달리는 차): 물결치는 베이컨 한 줄 + 바퀴
local function buildBaconCar()
	local m = Instance.new("Model")
	m.Name = "BaconCar"
	local MEAT = Color3.fromRGB(176, 52, 42)
	local DARK = Color3.fromRGB(130, 35, 30)
	local FAT = Color3.fromRGB(250, 220, 200)
	local SEG = 6
	local segLen = 12 / SEG
	for i = 0, SEG - 1 do
		local z = -6 + segLen * (i + 0.5)
		local y = 2.2 + math.sin(i * 1.1) * 0.6
		local tilt = math.cos(i * 1.1) * 0.35
		local cf = CFrame.new(0, y, z) * CFrame.Angles(tilt, 0, 0)
		-- 길이 방향 줄무늬: 살코기 / 비계 / 살코기
		part({ Parent = m, Size = Vector3.new(2.4, 0.7, segLen + 0.15), CFrame = cf * CFrame.new(-1.8, 0, 0), Color = (i % 2 == 0) and MEAT or DARK, Material = Enum.Material.SmoothPlastic, CanCollide = false })
		part({ Parent = m, Size = Vector3.new(1.2, 0.72, segLen + 0.15), CFrame = cf, Color = FAT, Material = Enum.Material.SmoothPlastic, CanCollide = false })
		part({ Parent = m, Size = Vector3.new(2.4, 0.7, segLen + 0.15), CFrame = cf * CFrame.new(1.8, 0, 0), Color = (i % 2 == 0) and DARK or MEAT, Material = Enum.Material.SmoothPlastic, CanCollide = false })
	end
	for _, x in ipairs({ -2.6, 2.6 }) do
		for _, z in ipairs({ -4, 4 }) do
			part({ Parent = m, Size = Vector3.new(0.8, 1.8, 1.8), CFrame = CFrame.new(x, 0.9, z), Color = Color3.fromRGB(25, 25, 25), Shape = Enum.PartType.Cylinder, CanCollide = false })
		end
	end
	local body = part({ Parent = m, Name = "Body", Size = Vector3.new(6, 0.2, 12), CFrame = CFrame.new(0, 1.2, 0), Transparency = 1, CanCollide = false })
	m.PrimaryPart = body
	return m
end

local function spawnCar(lane)
	local m = buildBaconCar()
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
local sign = box(SX0 - 0.6, 13, SZ0 + 8, SX0 - 0.2, 22, SZ1 - 8, { Color = Color3.fromRGB(200, 40, 40) })
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
local proSign = box(SX0 - 0.6, 13, PZ0 + 5, SX0 - 0.2, 22, PZ1 - 5, { Color = Color3.fromRGB(20, 10, 30) })
surfaceText(proSign, Enum.NormalId.Left, "부정행위 전문점", Color3.fromRGB(190, 120, 255), Enum.Font.GothamBlack)
do
	local neon = box(SX0 - 0.7, 22, PZ0 + 5, SX0 - 0.5, 22.4, PZ1 - 5, { Color = Color3.fromRGB(170, 80, 255), Material = Enum.Material.Neon })
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
local upSign = box(SX0 - 0.6, 13, UZ0 + 5, SX0 - 0.2, 22, UZ1 - 5, { Color = Color3.fromRGB(10, 25, 35) })
surfaceText(upSign, Enum.NormalId.Left, "업그레이드 전문점", Color3.fromRGB(90, 230, 255), Enum.Font.GothamBlack)
do
	local neon = box(SX0 - 0.7, 22, UZ0 + 5, SX0 - 0.5, 22.4, UZ1 - 5, { Color = Color3.fromRGB(60, 220, 255), Material = Enum.Material.Neon })
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
local endingPending = {} -- [player] = 엔딩 끝 폭발 대기
local nukeRequest -- 아래 핵폭탄 부분에서 정의
local floodRequest, poopRequest -- 아래에서 정의
local enlistArmy, leaveArmy, armyShoot, armyRespawn -- 동굴 부대 (아래에서 정의)
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
	if reason == nil and Shared.grade(s.score) == 1 then
		endingPending[player] = true -- 1등급 엔딩 마지막에 폭발
	end
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
		if armyRespawn then
			task.defer(armyRespawn, player)
		end
		hum.Died:Connect(function()
			local s = sessions[player]
			if s and not s.ended then
				endSession(player, s.deathReason or "car")
			end
			-- 자동 부활이 꺼져 있으므로 직접 다시 살림
			task.delay(4, function()
				if player.Parent and player.Character == char then
					player:LoadCharacter()
				end
			end)
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
	if action == "EnlistArmy" then
		if enlistArmy and player.Character and not sessions[player] then
			enlistArmy(player)
		end
		return
	end
	if action == "LeaveArmy" then
		if leaveArmy then
			leaveArmy(player)
		end
		return
	end
	if action == "Shoot" then
		if armyShoot then
			armyShoot(player, arg)
		end
		return
	end
	if action == "Flood" then
		if floodRequest and player.Character then
			floodRequest(player)
		end
		return
	end
	if action == "Poop" then
		if poopRequest and player.Character then
			poopRequest(player)
		end
		return
	end
	if action == "Nuke" then
		if nukeRequest and player.Character then
			nukeRequest(player)
		end
		return
	end
	if action == "Explode" then
		-- 1등급 엔딩의 마지막: 캐릭터 폭발
		if endingPending[player] then
			endingPending[player] = nil
			local _, hum, hrp = getParts(player)
			if hrp and hum then
				hrp.Anchored = false
				local e = Instance.new("Explosion")
				e.Position = hrp.Position
				e.BlastRadius = 8
				e.BlastPressure = 200000
				e.DestroyJointRadiusPercent = 0 -- 다른 사람은 안 죽게
				e.ExplosionType = Enum.ExplosionType.NoCraters
				e.Parent = workspace
				hrp.AssemblyLinearVelocity = Vector3.new(math.random(-30, 30), 90, math.random(-30, 30))
				hum.Health = 0
				logAll(player.DisplayName .. " 폭발")
			end
		end
		return
	end
	if action == "Play" then
		-- 처음 화면에서 플레이하기를 눌러야 캐릭터가 생김
		if not player.Character then
			player:LoadCharacter()
		end
		return
	end
	if not player.Character then
		return
	end
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
		-- 1등급 상품권: 시험 중에 쓰면 바로 1등급
		if item.id == "voucher" then
			if not s or s.ended then
				toast(player, "1등급 상품권은 시험 중에만 쓸 수 있어요.")
				return
			end
			if s.away then
				toast(player, "자리에 앉아서 써야 해요.")
				return
			end
			inv.voucher = inv.voucher - 1
			if inv.voucher <= 0 then
				inv.voucher = nil
			end
			sendInventory(player)
			s.score = Shared.TOTAL_Q
			s.qi = Shared.TOTAL_Q + 1
			logAll(player.DisplayName .. " 1등급 상품권 사용")
			endSession(player, nil)
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

-------------------------------------------------------------------
-- 1등급 상품권: 맵 한쪽 구석에 딱 하나 (표시 글씨 없음)
-------------------------------------------------------------------
do
	local grass = world:FindFirstChild("Grass")
	local gp, gs = grass.Position, grass.Size
	for _, sx in ipairs({ -1 }) do
		for _, sz in ipairs({ 1 }) do
			local pos = Vector3.new(gp.X + sx * (gs.X / 2 - 6), 2.5, gp.Z + sz * (gs.Z / 2 - 6))
			local stand = part({ Size = Vector3.new(3, 1, 3), Position = Vector3.new(pos.X, 0.5, pos.Z), Color = Color3.fromRGB(240, 240, 240), Material = Enum.Material.Marble })
			local card = part({ Name = "Voucher", Size = Vector3.new(3, 1.8, 0.15), Position = pos + Vector3.new(0, 0.6, 0), Color = Color3.fromRGB(255, 200, 40), Material = Enum.Material.Neon, CanCollide = false })
			local glow = Instance.new("PointLight")
			glow.Color = Color3.fromRGB(255, 210, 80)
			glow.Range = 14
			glow.Brightness = 2
			glow.Parent = card
			-- 빙글빙글 돌기
			task.spawn(function()
				local a = 0
				while card.Parent do
					a = a + 0.03
					card.CFrame = CFrame.new(pos + Vector3.new(0, 0.6 + math.sin(a * 2) * 0.3, 0)) * CFrame.Angles(0, a, 0)
					task.wait()
				end
			end)
			local pp = Instance.new("ProximityPrompt")
			pp.ActionText = "줍기"
			pp.ObjectText = "1등급 상품권"
			pp.HoldDuration = 0.3
			pp.MaxActivationDistance = 10
			pp.RequiresLineOfSight = false
			pp.Parent = stand
			pp.Triggered:Connect(function(player)
				local inv = inventory[player]
				if not inv then
					return
				end
				if (inv.voucher or 0) > 0 then
					toast(player, "이미 1등급 상품권을 가지고 있어요.")
					return
				end
				inv.voucher = 1
				sendInventory(player)
				toast(player, "1등급 상품권 획득! 시험 중에 가방에서 '사용'을 누르세요.")
			end)
		end
	end
end

-------------------------------------------------------------------
-- 저격수 100명: 몰래 밖에 나간 수험생을 노림
-- 교실 지붕, 가게 지붕 3곳, 도로 양옆 감시탑에 배치
-------------------------------------------------------------------
local SNIPER_COUNT = 100
local AIM_TIME = 3 -- 레이저가 플레이어에 닿은 채로 이만큼 지나면 발사
local TRACK_SPEED = 7 -- 조준점이 플레이어를 따라가는 속도 (느림)
local sniperFolder = Instance.new("Folder")
sniperFolder.Name = "Snipers"
sniperFolder.Parent = world

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { sniperFolder }

-- 배치 위치 만들기
local sniperSpots = {}
local function addSpot(x, y, z)
	if #sniperSpots < SNIPER_COUNT then
		table.insert(sniperSpots, Vector3.new(x, y, z))
	end
end
-- 1) 교실 지붕 가장자리 28명
for i = 0, 6 do
	local x = -ROOM_X + 10 + i * ((ROOM_X * 2 - 20) / 6)
	addSpot(x, WALL_H + 1, ROOM_Z0 + 4)
	addSpot(x, WALL_H + 1, ROOM_Z1 - 4)
end
for i = 0, 6 do
	local z = ROOM_Z0 + 12 + i * ((ROOM_Z1 - ROOM_Z0 - 24) / 6)
	addSpot(-ROOM_X + 4, WALL_H + 1, z)
	addSpot(ROOM_X - 4, WALL_H + 1, z)
end
-- 2) 가게 지붕 3곳 × 8명
for _, range in ipairs({ { UZ0, UZ1 }, { SZ0, SZ1 }, { PZ0, PZ1 } }) do
	for i = 0, 3 do
		local z = range[1] + 6 + i * ((range[2] - range[1] - 12) / 3)
		addSpot(SX0 + 5, 13, z)
		addSpot(SX1 - 5, 13, z)
	end
end
-- 3) 도로 양옆 감시탑 (남은 인원)
do
	local remain = SNIPER_COUNT - #sniperSpots
	local perSide = math.ceil(remain / 2)
	for i = 0, perSide - 1 do
		local z = -ROAD_LEN / 2 + 10 + i * ((ROAD_LEN - 20) / math.max(1, perSide - 1))
		for _, x in ipairs({ ROAD_X0 - 5, ROAD_X1 + 4 }) do
			-- 가게 건물과 겹치는 자리는 건너뜀
			if not (x > ROAD_X1 and z > UZ0 - 4 and z < PZ1 + 4) and #sniperSpots < SNIPER_COUNT then
				box(x - 0.4, 0, z - 0.4, x + 0.4, 14, z + 0.4, { Color = Color3.fromRGB(90, 90, 95), Material = Enum.Material.Metal, Parent = sniperFolder })
				box(x - 2.5, 13.6, z - 2.5, x + 2.5, 14, z + 2.5, { Color = Color3.fromRGB(110, 100, 80), Material = Enum.Material.WoodPlanks, Parent = sniperFolder })
				addSpot(x, 14, z)
			end
		end
	end
	-- 감시탑 자리가 모자라면 교실 지붕 안쪽에 추가
	local k = 0
	while #sniperSpots < SNIPER_COUNT do
		addSpot(-ROOM_X + 20 + (k % 6) * 22, WALL_H + 1, ROOM_Z0 + 20 + math.floor(k / 6) * 16)
		k = k + 1
	end
end

local function buildSniper(pos)
	local m = Instance.new("Model")
	m.Name = "Sniper"
	local root0 = CFrame.new(pos)
	local camo = Color3.fromRGB(70, 85, 55)
	local function sp(size, off, color, mat)
		return part({ Parent = m, Size = size, CFrame = root0 * CFrame.new(off), Color = color, Material = mat or Enum.Material.Fabric, CanCollide = false, CanQuery = false })
	end
	local base = sp(Vector3.new(2, 0.2, 2), Vector3.new(0, 0.1, 0), camo)
	base.Transparency = 1
	m.PrimaryPart = base
	sp(Vector3.new(2, 2.4, 1), Vector3.new(0, 1.2, 0), Color3.fromRGB(50, 60, 40))
	sp(Vector3.new(2, 2, 1), Vector3.new(0, 3.4, 0), camo)
	sp(Vector3.new(2.8, 0.9, 2.2), Vector3.new(0, 3.8, -0.8), camo)
	local head = sp(Vector3.new(1.5, 1.5, 1.5), Vector3.new(0, 5.15, 0), Color3.fromRGB(230, 195, 160), Enum.Material.SmoothPlastic)
	head.Shape = Enum.PartType.Ball
	sp(Vector3.new(1.7, 0.6, 1.7), Vector3.new(0, 5.8, 0), Color3.fromRGB(40, 50, 35))
	sp(Vector3.new(0.35, 0.45, 5), Vector3.new(0, 4, -2.6), Color3.fromRGB(25, 25, 25), Enum.Material.Metal)
	m.Parent = sniperFolder
	local laser = part({ Parent = sniperFolder, Size = Vector3.new(0.1, 0.1, 1), Color = Color3.fromRGB(255, 30, 30), Material = Enum.Material.Neon, Transparency = 0.4, CanCollide = false, CanQuery = false, CanTouch = false })
	local dot = part({ Parent = sniperFolder, Size = Vector3.new(1, 0.1, 1), Color = Color3.fromRGB(255, 30, 30), Material = Enum.Material.Neon, CanCollide = false, CanQuery = false, CanTouch = false })
	return m, laser, dot
end

local snipers = {}
for i, pos in ipairs(sniperSpots) do
	local m, laser, dot = buildSniper(pos)
	snipers[i] = {
		model = m, laser = laser, dot = dot, pos = pos,
		phase = math.random() * 100, sx = 0.06 + math.random() * 0.1, sz = 0.05 + math.random() * 0.08, aimPos = nil,
		lock = nil, lockT = 0, lockLost = 0, cooldown = math.random() * 3,
	}
end

local function aim(sn, target, turnBody)
	local v = target - sn.pos
	local yaw = math.atan2(-v.X, -v.Z)
	local cf = CFrame.new(sn.pos) * CFrame.Angles(0, yaw, 0)
	if turnBody then
		sn.model:PivotTo(cf)
	end
	local from = (cf * CFrame.new(0, 4.2, -5.2)).Position
	local dir = target - from
	local hit = workspace:Raycast(from, dir.Unit * (dir.Magnitude + 2), rayParams)
	local endPos = hit and hit.Position or target
	local len = (endPos - from).Magnitude
	sn.laser.Size = Vector3.new(0.1, 0.1, len)
	sn.laser.CFrame = CFrame.lookAt(from, endPos) * CFrame.new(0, 0, -len / 2)
	sn.dot.CFrame = CFrame.new(endPos + Vector3.new(0, 0.05, 0))
	return from, hit, endPos
end

local function shoot(player, from, to)
	local len = (to - from).Magnitude
	local tracer = part({ Size = Vector3.new(0.3, 0.3, len), CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -len / 2), Color = Color3.fromRGB(255, 230, 120), Material = Enum.Material.Neon, CanCollide = false, CanQuery = false })
	TweenService:Create(tracer, TweenInfo.new(0.35), { Transparency = 1 }):Play()
	task.delay(0.4, function()
		tracer:Destroy()
	end)
	local s = sessions[player]
	local _, hum, hrp = getParts(player)
	if s then
		s.deathReason = "sniper"
	end
	if hrp then
		hrp.Anchored = false
		hrp.AssemblyLinearVelocity = (to - from).Unit * 40 + Vector3.new(0, 20, 0)
	end
	if hum then
		hum.Health = 0
	end
	logAll("탕! " .. player.DisplayName .. " 저격당함")
	remote:FireClient(player, "Toast", "저격수에게 맞았습니다.")
end

-- 노리는 대상: 시험 중 몰래 나가서 교실 밖에 있는 수험생
local function canTarget(player)
	local s = sessions[player]
	if not s or s.ended or not s.away then
		return nil
	end
	local _, hum, hrp = getParts(player)
	if not hum or hum.Health <= 0 or not hrp or inRoom(hrp.Position) then
		return nil
	end
	return hrp
end

local frame = 0
local warned = {} -- [player] = 마지막 경고 시각
RunService.Heartbeat:Connect(function(dt)
	frame = frame + 1
	local now = os.clock()
	local targets = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local hrp = canTarget(player)
		if hrp then
			targets[player] = hrp
		end
	end
	for i, sn in ipairs(snipers) do
		sn.cooldown = math.max(0, sn.cooldown - dt)
		local turnBody = (i + frame) % 3 == 0 -- 몸 돌리기는 3프레임에 한 번
		if sn.lock then
			local hrp = targets[sn.lock]
			if not hrp then
				sn.lock = nil
			else
				-- 조준점이 플레이어를 천천히 따라감
				local goal = hrp.Position
				local diff = goal - sn.aimPos
				if diff.Magnitude > 0.01 then
					sn.aimPos = sn.aimPos + diff.Unit * math.min(diff.Magnitude, TRACK_SPEED * dt)
				end
				local from, hit = aim(sn, sn.aimPos, true)
				local onTarget = hit and hit.Instance and sn.lock.Character and hit.Instance:IsDescendantOf(sn.lock.Character)
				sn.laser.Transparency = (math.floor(now * 4) % 2 == 0) and 0 or 0.5
				if onTarget then
					sn.lockLost = 0
					sn.lockT = sn.lockT + dt
					if sn.lockT >= AIM_TIME then
						shoot(sn.lock, from, hrp.Position)
						targets[sn.lock] = nil
						sn.lock = nil
						sn.cooldown = 6
					end
				else
					sn.lockT = math.max(0, sn.lockT - dt * 0.5)
					sn.lockLost = sn.lockLost + dt
					-- 숨거나 멀리 도망가면 놓침
					if sn.lockLost > 2.5 or diff.Magnitude > 35 then
						sn.lock = nil
						sn.cooldown = 3
					end
				end
			end
		end
		if not sn.lock then
			sn.laser.Transparency = 0.4
			-- 자기 주변 바깥을 천천히 훑기
			local t = now + sn.phase
			local target = Vector3.new(
				math.clamp(sn.pos.X + 20 + math.sin(t * sn.sx) * 40, ROOM_X + 2, SX1 + 30),
				0,
				sn.pos.Z + math.sin(t * sn.sz) * 50
			)
			local _, _, dotPos = aim(sn, target, turnBody)
			if sn.cooldown <= 0 then
				for player, hrp in pairs(targets) do
					local d = Vector3.new(hrp.Position.X - dotPos.X, 0, hrp.Position.Z - dotPos.Z).Magnitude
					if d < 9 then
						sn.lock = player
						sn.lockT = 0
						sn.lockLost = 0
						sn.aimPos = dotPos
						if not warned[player] or now - warned[player] > 2 then
							warned[player] = now
							remote:FireClient(player, "Toast", "저격수가 조준 중! 건물이나 차 뒤로 숨으세요!")
						end
						break
					end
				end
			end
		end
	end
end)

-------------------------------------------------------------------
-- 탈 수 있는 차
-- Workspace 에 이름이 "탈것" 인 모델을 넣으면 그 모델을 운전할 수 있음
-- (없으면 교실 뒤 잔디에 기본 차가 생김)
-- 앞뒤가 반대로 가면 모델 속성(Attribute)에 Reverse = true 추가
-------------------------------------------------------------------
local DRIVE_MAX = 90 -- 최고 속도
local DRIVE_ACCEL = 45
local DRIVE_TURN = 2.2
local drivables = {}

local function groundY(pos, ignore)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local list = { ignore, carFolder, sniperFolder }
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			table.insert(list, p.Character)
		end
	end
	params.FilterDescendantsInstances = list
	local hit = workspace:Raycast(pos + Vector3.new(0, 40, 0), Vector3.new(0, -120, 0), params)
	return hit and hit.Position.Y or 0
end

local function makeDrivable(model)
	if not model.PrimaryPart then
		model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart", true)
	end
	if not model.PrimaryPart then
		return
	end
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
		end
	end
	local pivot = model:GetPivot()
	local size = model:GetExtentsSize()
	local look = pivot.LookVector
	local yaw0 = math.atan2(-look.X, -look.Z)
	local rel = CFrame.Angles(0, yaw0, 0):Inverse() * (pivot - pivot.Position)
	local seat = model:FindFirstChildWhichIsA("VehicleSeat", true)
	if not seat then
		seat = Instance.new("VehicleSeat")
		seat.Name = "DriverSeat"
		seat.Size = Vector3.new(2, 0.4, 2)
		seat.Transparency = 1
		seat.CanCollide = false
		seat.CFrame = CFrame.new(pivot.Position + Vector3.new(0, size.Y / 2 + 0.2, 0)) * CFrame.Angles(0, yaw0, 0)
		seat.Parent = model
	end
	seat.Anchored = true
	seat.MaxSpeed = 0
	local prompt2 = Instance.new("ProximityPrompt")
	prompt2.ActionText = "타기"
	prompt2.ObjectText = "차"
	prompt2.HoldDuration = 0
	prompt2.MaxActivationDistance = 14
	prompt2.RequiresLineOfSight = false
	prompt2.Parent = seat
	prompt2.Triggered:Connect(function(player)
		local _, hum = getParts(player)
		if hum and not seat.Occupant and not sessions[player] then
			seat:Sit(hum)
		elseif sessions[player] and not sessions[player].away then
			toast(player, "시험 중에는 자리에서 못 일어나요.")
		end
	end)
	table.insert(drivables, {
		model = model, seat = seat, speed = 0, yaw = yaw0, rel = rel,
		home = { pos = pivot.Position, yaw = yaw0 }, lastHum = nil,
		pos = pivot.Position, offset = pivot.Position.Y - groundY(pivot.Position, model),
		radius = math.max(size.X, size.Z) / 2 + 1,
		dir = model:GetAttribute("Reverse") and -1 or 1,
	})
end

-- 주차장 (교실 뒤): 차 50대
local DRIVE_COUNT = 50
local LOT_COLS, LOT_ROWS = 10, 5
local LOT_X0, LOT_Z0 = -54, ROOM_Z1 + 16
box(LOT_X0 - 6, -0.2, LOT_Z0 - 8, LOT_X0 + (LOT_COLS - 1) * 12 + 6, 0.05, LOT_Z0 + (LOT_ROWS - 1) * 18 + 10, { Name = "ParkingLot", Color = Color3.fromRGB(70, 72, 78), Material = Enum.Material.Asphalt })
local function lotSpot(i)
	local c = (i - 1) % LOT_COLS
	local r = math.floor((i - 1) / LOT_COLS)
	return CFrame.new(LOT_X0 + c * 12, 0, LOT_Z0 + r * 18)
end
for i = 1, DRIVE_COUNT do
	local cf = lotSpot(i)
	box(cf.X - 5.2, 0.05, cf.Z - 7.5, cf.X - 4.9, 0.1, cf.Z + 7.5, { Color = Color3.new(1, 1, 1), Material = Enum.Material.SmoothPlastic, CanCollide = false })
end

do
	-- Workspace 의 "탈것" 모델(없으면 기본 차)을 복제해서 50대 채우기
	local originals = {}
	for _, m in ipairs(workspace:GetChildren()) do
		if m:IsA("Model") and m.Name == "탈것" then
			table.insert(originals, m)
		end
	end
	for i = 1, DRIVE_COUNT do
		local m
		if #originals > 0 then
			local src = originals[(i - 1) % #originals + 1]
			if i <= #originals then
				m = src
			else
				m = src:Clone()
				m.Parent = workspace
			end
			-- 원래 방향은 유지하고 주차 칸으로 이동
			local pv = m:GetPivot()
			local look = pv.LookVector
			local yaw = math.atan2(-look.X, -look.Z)
			local rel = CFrame.Angles(0, yaw, 0):Inverse() * (pv - pv.Position)
			local spot = lotSpot(i)
			m:PivotTo(CFrame.new(spot.X, pv.Y - groundY(pv.Position, m), spot.Z) * CFrame.Angles(0, yaw, 0) * rel)
		else
			m = buildNoobCar()
			m.Name = "탈것"
			m:PivotTo(lotSpot(i))
			m.Parent = world
		end
		makeDrivable(m)
	end
end

-- 운전자가 죽으면 차를 원래 주차 칸으로
local function resetCar(c)
	c.speed = 0
	c.pos = Vector3.new(c.home.pos.X, c.home.pos.Y, c.home.pos.Z)
	c.yaw = c.home.yaw
	c.model:PivotTo(CFrame.new(c.pos) * CFrame.Angles(0, c.yaw, 0) * c.rel)
end

RunService.Heartbeat:Connect(function(dt)
	for _, c in ipairs(drivables) do
		local hum = c.seat.Occupant
		if c.lastHum and (c.lastHum.Health <= 0 or not c.lastHum:IsDescendantOf(workspace)) then
			c.lastHum = nil
			resetCar(c)
		elseif hum then
			c.lastHum = hum
		elseif c.lastHum then
			c.lastHum = nil -- 그냥 내림
		end
		local throttle = hum and c.seat.ThrottleFloat or 0
		local steer = hum and c.seat.SteerFloat or 0
		local target = throttle * DRIVE_MAX
		if math.abs(target - c.speed) > 0.1 then
			local acc = (throttle == 0) and DRIVE_ACCEL * 1.5 or DRIVE_ACCEL
			c.speed = c.speed + math.clamp(target - c.speed, -acc * dt, acc * dt)
		end
		if math.abs(c.speed) > 0.5 then
			c.yaw = c.yaw - steer * DRIVE_TURN * dt * math.sign(c.speed)
			local fwd = Vector3.new(-math.sin(c.yaw), 0, -math.cos(c.yaw)) * c.dir
			local nextPos = c.pos + fwd * c.speed * dt
			local gy = groundY(nextPos, c.model)
			c.pos = Vector3.new(nextPos.X, gy + c.offset, nextPos.Z)
			c.model:PivotTo(CFrame.new(c.pos) * CFrame.Angles(0, c.yaw, 0) * c.rel)
			-- 빠르게 달리면 다른 플레이어를 치어버림
			if math.abs(c.speed) > 30 then
				for _, player in ipairs(Players:GetPlayers()) do
					local _, h, hrp = getParts(player)
					if h and hrp and h ~= hum and h.Health > 0 and (hrp.Position - c.pos).Magnitude < c.radius then
						local s = sessions[player]
						if s then
							s.deathReason = "car"
						end
						hrp.Anchored = false
						hrp.AssemblyLinearVelocity = fwd * math.abs(c.speed) + Vector3.new(0, 50, 0)
						h.Health = 0
						logAll(player.DisplayName .. " 교통사고")
					end
				end
			end
		end
	end
end)

-------------------------------------------------------------------
-- 핵 벙커 (교실 뒤쪽 왼편 구석): 안에 있으면 핵폭탄·홍수에도 안 죽음
-------------------------------------------------------------------
local BX0, BX1, BZ0, BZ1, BH = -68, -50, 60, 78, 10
local function inBunker(pos)
	return pos.X > BX0 + 1 and pos.X < BX1 - 1 and pos.Z > BZ0 + 1 and pos.Z < BZ1 - 1 and pos.Y < BH + 2
end
do
	local concrete = { Color = Color3.fromRGB(120, 122, 118), Material = Enum.Material.Concrete }
	local function c()
		return { Color = concrete.Color, Material = concrete.Material }
	end
	box(BX0, 0, BZ0, BX1, BH, BZ0 + 1.5, c())
	box(BX0, 0, BZ1 - 1.5, BX1, BH, BZ1, c())
	box(BX0, 0, BZ0, BX0 + 1.5, BH, BZ1, c())
	-- 입구 (교실 쪽)
	box(BX1 - 1.5, 0, BZ0, BX1, BH, 66, c())
	box(BX1 - 1.5, 0, 72, BX1, BH, BZ1, c())
	box(BX1 - 1.5, 8, 66, BX1, BH, 72, c())
	box(BX0, BH, BZ0, BX1, BH + 1.5, BZ1, c())
	-- 노란 검정 경고 띠
	for i = 0, 5 do
		box(BX1 - 0.1, 8 + (i % 2) * 0, 66 + i, BX1 + 0.1, 8.6, 66 + i + 1, { Color = (i % 2 == 0) and Color3.fromRGB(240, 200, 30) or Color3.fromRGB(25, 25, 25), Material = Enum.Material.SmoothPlastic })
	end
	local sign = box(BX1 + 0.05, 8.7, 64, BX1 + 0.25, 10, 74, { Color = Color3.fromRGB(30, 30, 30) })
	surfaceText(sign, Enum.NormalId.Right, "핵 벙커", Color3.fromRGB(255, 220, 60), Enum.Font.GothamBlack)
	-- 안쪽: 조명, 의자, 통조림 선반
	local lamp = box(-62, BH - 0.4, 68, -56, BH - 0.1, 70, { Color = Color3.fromRGB(255, 240, 200), Material = Enum.Material.Neon })
	local l = Instance.new("PointLight")
	l.Range = 18
	l.Brightness = 1.2
	l.Color = Color3.fromRGB(255, 220, 160)
	l.Parent = lamp
	box(BX0 + 2, 0, BZ0 + 2, BX0 + 4, 1.8, BZ1 - 2, { Color = Color3.fromRGB(90, 70, 50), Material = Enum.Material.Wood })
	box(BX0 + 2, 0, BZ1 - 4, BX1 - 4, 6, BZ1 - 2, { Color = Color3.fromRGB(80, 85, 90), Material = Enum.Material.Metal })
	for x = BX0 + 3, BX1 - 6, 1.5 do
		part({ Size = Vector3.new(1, 1.2, 1), Position = Vector3.new(x, 2.6, BZ1 - 3), Color = Color3.fromRGB(200, 60, 40), Shape = Enum.PartType.Cylinder, Orientation = Vector3.new(0, 0, 90) })
		part({ Size = Vector3.new(1, 1.2, 1), Position = Vector3.new(x, 4.6, BZ1 - 3), Color = Color3.fromRGB(60, 140, 60), Shape = Enum.PartType.Cylinder, Orientation = Vector3.new(0, 0, 90) })
	end
end

-------------------------------------------------------------------
-- 핵폭탄 (아무나 발사 가능, 60초에 한 번)
-------------------------------------------------------------------
local NUKE_COOLDOWN = 60
local lastNuke = -math.huge
local NUKE_TARGET = Vector3.new(0, 0, 20) -- 교실 한가운데

local function launchNuke(byPlayer)
	lastNuke = os.clock()
	logAll(byPlayer.DisplayName .. " 핵폭탄 발사!")
	remote:FireAllClients("NukeWarn", byPlayer.DisplayName, 10)
	-- 하늘에서 떨어지는 미사일
	local missile = part({ Size = Vector3.new(3, 3, 16), Color = Color3.fromRGB(230, 230, 230), Material = Enum.Material.Metal, CanCollide = false, CanQuery = false })
	local tip = part({ Size = Vector3.new(3, 3, 3), Color = Color3.fromRGB(200, 30, 30), Shape = Enum.PartType.Ball, CanCollide = false, CanQuery = false })
	local fire = Instance.new("Fire")
	fire.Size = 12
	fire.Heat = 20
	fire.Parent = missile
	local start = NUKE_TARGET + Vector3.new(150, 700, -150)
	local t0 = os.clock()
	while os.clock() - t0 < 10 do
		local k = (os.clock() - t0) / 10
		local p = start:Lerp(NUKE_TARGET, k * k)
		local cf = CFrame.lookAt(p, NUKE_TARGET)
		missile.CFrame = cf
		tip.CFrame = cf * CFrame.new(0, 0, -8)
		task.wait()
	end
	missile:Destroy()
	tip:Destroy()

	-- 폭발
	remote:FireAllClients("NukeBoom")
	local ball = part({ Size = Vector3.new(10, 10, 10), Position = NUKE_TARGET, Shape = Enum.PartType.Ball, Color = Color3.fromRGB(255, 230, 150), Material = Enum.Material.Neon, CanCollide = false, CanQuery = false })
	local light = Instance.new("PointLight")
	light.Range = 60
	light.Brightness = 10
	light.Color = Color3.fromRGB(255, 180, 80)
	light.Parent = ball
	TweenService:Create(ball, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(400, 400, 400), Color = Color3.fromRGB(255, 120, 30), Transparency = 0.4 }):Play()
	-- 벙커 밖에 있는 모든 플레이어 사망
	for _, player in ipairs(Players:GetPlayers()) do
		local _, hum, hrp = getParts(player)
		if hrp and inBunker(hrp.Position) then
			remote:FireClient(player, "Toast", "벙커 덕분에 살았다!")
		else
			local s = sessions[player]
			if s then
				s.deathReason = "nuke"
			end
			if hrp then
				hrp.Anchored = false
				local away = (hrp.Position - NUKE_TARGET)
				away = Vector3.new(away.X, 0, away.Z)
				if away.Magnitude < 1 then
					away = Vector3.new(1, 0, 0)
				end
				hrp.AssemblyLinearVelocity = away.Unit * 150 + Vector3.new(0, 120, 0)
			end
			if hum then
				hum.Health = 0
			end
		end
	end
	task.wait(2)
	-- 버섯구름
	local stem = part({ Size = Vector3.new(20, 1, 20), Position = NUKE_TARGET, Shape = Enum.PartType.Cylinder, Color = Color3.fromRGB(120, 110, 100), Material = Enum.Material.SmoothPlastic, CanCollide = false, CanQuery = false })
	stem.CFrame = CFrame.new(NUKE_TARGET) * CFrame.Angles(0, 0, math.rad(90))
	local cap = part({ Size = Vector3.new(30, 20, 30), Position = NUKE_TARGET + Vector3.new(0, 20, 0), Shape = Enum.PartType.Ball, Color = Color3.fromRGB(160, 140, 120), Material = Enum.Material.SmoothPlastic, CanCollide = false, CanQuery = false })
	TweenService:Create(ball, TweenInfo.new(2), { Transparency = 1 }):Play()
	TweenService:Create(stem, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(200, 40, 40), CFrame = CFrame.new(NUKE_TARGET + Vector3.new(0, 100, 0)) * CFrame.Angles(0, 0, math.rad(90)) }):Play()
	TweenService:Create(cap, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(220, 110, 220), Position = NUKE_TARGET + Vector3.new(0, 210, 0) }):Play()
	task.wait(8)
	TweenService:Create(stem, TweenInfo.new(3), { Transparency = 1 }):Play()
	TweenService:Create(cap, TweenInfo.new(3), { Transparency = 1 }):Play()
	task.wait(3)
	ball:Destroy()
	stem:Destroy()
	cap:Destroy()
end

nukeRequest = function(player)
	local left = NUKE_COOLDOWN - (os.clock() - lastNuke)
	if left > 0 then
		toast(player, "핵폭탄 재장전 중… " .. math.ceil(left) .. "초")
		return
	end
	task.spawn(launchNuke, player)
end

-------------------------------------------------------------------
-- 홍수 (60초에 한 번): 물이 차오르고 오래 잠겨 있으면 익사
-- 교실 뒤 벽 사다리로 지붕에 올라가면 안전
-------------------------------------------------------------------
do
	local ladder = Instance.new("TrussPart")
	ladder.Anchored = true
	ladder.Size = Vector3.new(2, WALL_H + 2, 2)
	ladder.Position = Vector3.new(-8, (WALL_H + 2) / 2, ROOM_Z1 + 1.5)
	ladder.Color = Color3.fromRGB(200, 200, 60)
	ladder.Parent = world
	local sign2 = box(-11, 4, ROOM_Z1 + 0.6, -5, 6, ROOM_Z1 + 0.7, { Color = Color3.fromRGB(30, 120, 200) })
	surfaceText(sign2, Enum.NormalId.Back, "지붕 대피 사다리", Color3.new(1, 1, 1))
end

local FLOOD_COOLDOWN = 60
local FLOOD_MAX = 12
local lastFlood = -math.huge
local floodLevel = -1
local water = part({ Name = "FloodWater", Size = Vector3.new(800, 0.1, 800), Position = Vector3.new(60, -1, 20), Color = Color3.fromRGB(40, 110, 190), Material = Enum.Material.Glass, Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false })

local function setWater(level)
	floodLevel = level
	local h = math.max(0.1, level + 1)
	water.Size = Vector3.new(800, h, 800)
	water.Position = Vector3.new(60, -1 + h / 2, 20)
end

local function runFlood(byPlayer)
	lastFlood = os.clock()
	logAll(byPlayer.DisplayName .. " 홍수 발동!")
	remote:FireAllClients("FloodWarn", byPlayer.DisplayName)
	water.Transparency = 0.35
	local function animate(from, to, dur)
		local t0 = os.clock()
		while os.clock() - t0 < dur do
			setWater(from + (to - from) * ((os.clock() - t0) / dur))
			task.wait()
		end
		setWater(to)
	end
	animate(-1, FLOOD_MAX, 12)
	task.wait(12)
	animate(FLOOD_MAX, -1, 8)
	water.Transparency = 1
end

-- 익사 검사
local underwater = {}
task.spawn(function()
	while true do
		task.wait(0.25)
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			local head = char and char:FindFirstChild("Head")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if head and hum and hum.Health > 0 and head.Position.Y < floodLevel - 0.3 and not inBunker(head.Position) then
				underwater[player] = (underwater[player] or 0) + 0.25
				if underwater[player] == 1 then
					toast(player, "물에 잠겼다! 교실 뒤 사다리로 지붕에 올라가세요!")
				end
				if underwater[player] >= 5 then
					underwater[player] = 0
					local s = sessions[player]
					if s then
						s.deathReason = "flood"
					end
					hum.Health = 0
					logAll(player.DisplayName .. " 익사")
				end
			else
				underwater[player] = 0
			end
		end
	end
end)

floodRequest = function(player)
	local left = FLOOD_COOLDOWN - (os.clock() - lastFlood)
	if left > 0 then
		toast(player, "홍수 준비 중… " .. math.ceil(left) .. "초")
		return
	end
	task.spawn(runFlood, player)
end

-------------------------------------------------------------------
-- 똥누기 (3초에 한 번): 밟으면 미끄러짐, 시험 중이면 감독관이 냄새를 맡음
-------------------------------------------------------------------
local lastPoop = {}
poopRequest = function(player)
	local now = os.clock()
	if lastPoop[player] and now - lastPoop[player] < 3 then
		return
	end
	lastPoop[player] = now
	local char, hum, hrp = getParts(player)
	if not hrp or not hum or hum.Health <= 0 then
		return
	end
	local behind = (hrp.CFrame * CFrame.new(0, 0, 2)).Position
	local gy = groundY(behind, char)
	local base = Vector3.new(behind.X, gy, behind.Z)
	local m = Instance.new("Model")
	m.Name = "Poop"
	local brown = Color3.fromRGB(110, 70, 30)
	local layers = { { 2.2, 0.7 }, { 1.6, 0.6 }, { 1.0, 0.55 }, { 0.45, 0.45 } }
	local y = 0
	local bottom
	for i, l in ipairs(layers) do
		local p = part({ Parent = m, Size = Vector3.new(l[2], l[1], l[1]), CFrame = CFrame.new(base + Vector3.new(0, y + l[2] / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Shape = Enum.PartType.Cylinder, Color = brown, Material = Enum.Material.SmoothPlastic, CanCollide = false })
		if i == 1 then
			bottom = p
		end
		y = y + l[2] * 0.75
	end
	local smell = Instance.new("Smoke")
	smell.Color = Color3.fromRGB(120, 170, 60)
	smell.Opacity = 0.15
	smell.RiseVelocity = 2
	smell.Size = 1.5
	smell.Parent = bottom
	m.Parent = world
	-- 밟으면 미끄러짐
	local slipped = {}
	bottom.CanTouch = true
	bottom.Touched:Connect(function(hit)
		local h = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		local pl = h and Players:GetPlayerFromCharacter(hit.Parent)
		if h and pl and pl ~= player and not slipped[pl] then
			slipped[pl] = true
			h.Sit = true
			toast(pl, "똥을 밟고 미끄러졌다!")
		end
	end)
	logAll(player.DisplayName .. " 똥 쌌다")
	local s = sessions[player]
	if s and not s.ended then
		s.suspicion = math.min(100, s.suspicion + 10)
		remote:FireClient(player, "Timer", s.timeLeft, s.suspicion)
		toast(player, "감독관이 냄새를 맡았다… 의심도 +10")
	else
		toast(player, "뿌직.")
	end
	task.delay(30, function()
		m:Destroy()
	end)
end

-------------------------------------------------------------------
-- 동굴 부대 (군대 게임 모드): 엔딩 끝에 입대하면 플레이
-- 임무: 1 점호 → 2 사격훈련 → 3 경계근무 → 4 전역
-------------------------------------------------------------------
local AO = Vector3.new(0, 0, -700) -- 동굴 기지 위치
local RANKS = { "이병", "일병", "상병", "병장", "전역" }
local MISSIONS = {
	"생활관 앞 노란 점호 장소로 집합!",
	"사격장에서 표적 10개 명중!",
	"초소를 지켜라! 동굴에서 오는 적 8명 저지!",
	"전역 게이트(초록 문)로 나가라!",
}
local armyState = {} -- [player] = { stage, count, enemies }
local armyFolder = Instance.new("Folder")
armyFolder.Name = "CaveBase"
armyFolder.Parent = world

local function A(x, y, z)
	return AO + Vector3.new(x, y, z)
end
local function abox(x0, y0, z0, x1, y1, z1, props)
	props = props or {}
	props.Parent = props.Parent or armyFolder
	return box(AO.X + x0, y0, AO.Z + z0, AO.X + x1, y1, AO.Z + z1, props)
end

-- 동굴 만들기
local ROCK = { Color = Color3.fromRGB(70, 65, 60), Material = Enum.Material.Slate }
local function rock()
	return { Color = ROCK.Color, Material = ROCK.Material }
end
abox(-85, -1, -65, 85, 0, 65, { Color = Color3.fromRGB(90, 80, 65), Material = Enum.Material.Ground })
abox(-85, 0, -65, -80, 24, 65, rock())
abox(80, 0, -65, 85, 24, 65, rock())
abox(-85, 0, 60, 85, 24, 65, rock())
abox(-85, 0, -65, 85, 24, -60, rock())
abox(-85, 24, -65, 85, 28, 65, rock())
-- 울퉁불퉁한 바위
for i = 1, 24 do
	local x, z = math.random(-75, 75), math.random(-55, 55)
	if math.abs(x) > 30 or math.abs(z) > 50 then
		local sz = math.random(3, 7)
		local p = part({ Parent = armyFolder, Size = Vector3.new(sz, sz, sz), Position = A(x, sz / 2 - 1, z), Orientation = Vector3.new(math.random(0, 90), math.random(0, 90), 0), Color = ROCK.Color, Material = ROCK.Material })
		p.Name = "Rock"
	end
end
-- 횃불 조명
for _, pos in ipairs({ { -60, 40 }, { -20, 40 }, { 20, 40 }, { 60, 40 }, { -60, -20 }, { -20, -20 }, { 20, -20 }, { 60, -20 }, { -40, -50 }, { 40, -50 }, { 0, 10 } }) do
	local t = part({ Parent = armyFolder, Size = Vector3.new(0.8, 0.8, 0.8), Position = A(pos[1], 14, pos[2]), Color = Color3.fromRGB(255, 150, 50), Material = Enum.Material.Neon })
	local l = Instance.new("PointLight")
	l.Color = Color3.fromRGB(255, 170, 90)
	l.Range = 34
	l.Brightness = 1.6
	l.Parent = t
end
-- 생활관 침상
for i = 0, 5 do
	abox(-75, 0, 22 + i * 6, -63, 1.5, 26 + i * 6, { Color = Color3.fromRGB(100, 110, 80), Material = Enum.Material.Fabric })
	abox(-75, 1.5, 22 + i * 6, -73, 2.1, 26 + i * 6, { Color = Color3.fromRGB(230, 230, 220) })
end
local sign1 = abox(-79.9, 8, 26, -79.7, 12, 50, { Color = Color3.fromRGB(40, 50, 35) })
surfaceText(sign1, Enum.NormalId.Right, "생활관", Color3.fromRGB(230, 230, 200))
-- 점호 장소
local rollcall = part({ Parent = armyFolder, Size = Vector3.new(0.3, 10, 10), CFrame = CFrame.new(A(-25, 0.15, 38)) * CFrame.Angles(0, 0, math.rad(90)), Shape = Enum.PartType.Cylinder, Color = Color3.fromRGB(255, 220, 60), Material = Enum.Material.Neon, CanCollide = false })
-- 사격장: 사로(모래주머니)와 표적 10개
abox(24, 0, -40, 27, 2.5, 40, { Color = Color3.fromRGB(190, 170, 120), Material = Enum.Material.Sand })
local targets = {}
for i = 0, 9 do
	local z = -36 + i * 8
	local x = 55 + (i % 3) * 8
	abox(x - 0.2, 0, z - 0.2, x + 0.2, 4, z + 0.2, { Color = Color3.fromRGB(90, 70, 50) })
	local t = part({ Parent = armyFolder, Name = "Target", Size = Vector3.new(0.4, 3.6, 3.6), CFrame = CFrame.new(A(x, 5.5, z)) , Shape = Enum.PartType.Cylinder, Color = Color3.fromRGB(230, 40, 40), Material = Enum.Material.SmoothPlastic })
	t:SetAttribute("ArmyTarget", true)
	local inner = part({ Parent = armyFolder, Size = Vector3.new(0.45, 1.6, 1.6), CFrame = t.CFrame, Shape = Enum.PartType.Cylinder, Color = Color3.new(1, 1, 1), CanQuery = false })
	table.insert(targets, { part = t, inner = inner })
end
local sign2 = abox(79.7, 8, -30, 79.9, 12, 30, { Color = Color3.fromRGB(40, 50, 35) })
surfaceText(sign2, Enum.NormalId.Left, "사격장", Color3.fromRGB(230, 230, 200))
-- 초소와 적이 나오는 동굴 굴
local POST = A(-40, 0, -35)
abox(-46, 0, -41, -34, 3, -40, { Color = Color3.fromRGB(190, 170, 120), Material = Enum.Material.Sand })
abox(-46, 0, -41, -45, 3, -29, { Color = Color3.fromRGB(190, 170, 120), Material = Enum.Material.Sand })
abox(-35, 0, -41, -34, 3, -29, { Color = Color3.fromRGB(190, 170, 120), Material = Enum.Material.Sand })
abox(-46, 9, -41, -34, 9.5, -29, { Color = Color3.fromRGB(80, 90, 60) })
local TUNNEL = A(-74, 0, -54)
abox(-80, 0, -60, -68, 12, -59, { Color = Color3.fromRGB(10, 10, 10) })
-- 전역 게이트
local gate = abox(-6, 0, -59.5, 6, 12, -59, { Color = Color3.fromRGB(60, 220, 100), Material = Enum.Material.Neon, CanCollide = false })
surfaceText(gate, Enum.NormalId.Back, "전역 게이트", Color3.fromRGB(10, 60, 20), Enum.Font.GothamBlack)
local ARMY_SPAWN = A(-55, 3, 40)

local function armySend(player)
	local st = armyState[player]
	if st then
		local prog = ""
		if st.stage == 2 then
			prog = st.count .. " / 10"
		elseif st.stage == 3 then
			prog = st.count .. " / 8"
		end
		remote:FireClient(player, "Army", { rank = RANKS[st.stage], mission = MISSIONS[st.stage], progress = prog, stage = st.stage })
	end
end

local function giveRifle(player)
	local _, hum = getParts(player)
	if not hum or player.Backpack:FindFirstChild("소총") or (player.Character and player.Character:FindFirstChild("소총")) then
		return
	end
	local tool = Instance.new("Tool")
	tool.Name = "소총"
	tool.CanBeDropped = false
	local h = Instance.new("Part")
	h.Name = "Handle"
	h.Size = Vector3.new(0.4, 0.6, 4)
	h.Color = Color3.fromRGB(30, 30, 30)
	h.Material = Enum.Material.Metal
	h.CanCollide = false
	h.Parent = tool
	tool.Grip = CFrame.new(0, -0.2, 1)
	tool.Parent = player.Backpack
	hum:EquipTool(tool)
end

local function placeInCave(player)
	local _, hum, hrp = getParts(player)
	if hrp and hum then
		hrp.Anchored = false
		hum.WalkSpeed = 18
		hum.JumpPower = 50
		hrp.CFrame = CFrame.new(ARMY_SPAWN)
		giveRifle(player)
	end
end

local function clearEnemies(st)
	for _, e in ipairs(st.enemies or {}) do
		if e.model then
			e.model:Destroy()
		end
	end
	st.enemies = {}
end

local function nextStage(player)
	local st = armyState[player]
	st.stage = st.stage + 1
	st.count = 0
	clearEnemies(st)
	if st.stage <= 4 then
		toast(player, RANKS[st.stage] .. " 진급! " .. MISSIONS[st.stage])
	end
	armySend(player)
end

-- 적 (회색 블록 병사)
local function spawnEnemy(player, st)
	local m = Instance.new("Model")
	m.Name = "Enemy"
	local grey = Color3.fromRGB(110, 110, 115)
	local body = part({ Parent = m, Name = "Body", Size = Vector3.new(2, 2, 1), Position = TUNNEL + Vector3.new(0, 3.5, 0), Color = grey, CanCollide = false })
	part({ Parent = m, Size = Vector3.new(2, 2.4, 1), Position = TUNNEL + Vector3.new(0, 1.2, 0), Color = Color3.fromRGB(60, 60, 65), CanCollide = false })
	part({ Parent = m, Size = Vector3.new(1.5, 1.5, 1.5), Position = TUNNEL + Vector3.new(0, 5.3, 0), Color = Color3.fromRGB(200, 170, 140), CanCollide = false, Shape = Enum.PartType.Ball })
	part({ Parent = m, Size = Vector3.new(1.7, 0.5, 1.7), Position = TUNNEL + Vector3.new(0, 6, 0), Color = Color3.fromRGB(70, 70, 75), CanCollide = false })
	for _, p in ipairs(m:GetChildren()) do
		p:SetAttribute("ArmyEnemy", true)
	end
	m.PrimaryPart = body
	m.Parent = armyFolder
	table.insert(st.enemies, { model = m, pos = TUNNEL })
end

-- 동굴 부대 들어가기 / 나가기
enlistArmy = function(player)
	armyState[player] = { stage = 1, count = 0, enemies = {}, spawned = 0, nextSpawn = 0 }
	placeInCave(player)
	toast(player, "동굴 부대에 입대했습니다! " .. MISSIONS[1])
	armySend(player)
end
leaveArmy = function(player)
	local st = armyState[player]
	if st then
		clearEnemies(st)
	end
	armyState[player] = nil
	player:LoadCharacter()
end

-- 동굴 부대에서 죽으면 동굴 생활관에서 다시 시작
armyRespawn = function(player)
	if armyState[player] and armyState[player].stage <= 4 then
		task.wait(0.2)
		placeInCave(player)
		armySend(player)
	end
end

-- 사격
local lastShot = {}
armyShoot = function(player, aimPos)
	local st = armyState[player]
	if not st or typeof(aimPos) ~= "Vector3" then
		return
	end
	local now = os.clock()
	if lastShot[player] and now - lastShot[player] < 0.25 then
		return
	end
	lastShot[player] = now
	local char = player.Character
	local head = char and char:FindFirstChild("Head")
	if not head then
		return
	end
	local from = head.Position
	local dir = aimPos - from
	if dir.Magnitude < 0.1 then
		return
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	local hit = workspace:Raycast(from, dir.Unit * 400, params)
	local to = hit and hit.Position or (from + dir.Unit * 400)
	local len = (to - from).Magnitude
	local tracer = part({ Size = Vector3.new(0.15, 0.15, len), CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -len / 2), Color = Color3.fromRGB(255, 230, 120), Material = Enum.Material.Neon, CanCollide = false, CanQuery = false })
	task.delay(0.08, function()
		tracer:Destroy()
	end)
	if not hit then
		return
	end
	local inst = hit.Instance
	if inst:GetAttribute("ArmyTarget") and st.stage == 2 and inst.Transparency < 0.5 then
		inst.Transparency = 0.8
		st.count = st.count + 1
		armySend(player)
		task.delay(1.5, function()
			inst.Transparency = 0
		end)
		if st.count >= 10 then
			nextStage(player)
		end
	elseif inst:GetAttribute("ArmyEnemy") then
		for i, e in ipairs(st.enemies) do
			if inst:IsDescendantOf(e.model) then
				e.model:Destroy()
				table.remove(st.enemies, i)
				st.count = st.count + 1
				armySend(player)
				if st.count >= 8 then
					nextStage(player)
				end
				break
			end
		end
	end
end

-- 임무 진행 검사
RunService.Heartbeat:Connect(function(dt)
	for player, st in pairs(armyState) do
		local _, hum, hrp = getParts(player)
		if hrp and hum and hum.Health > 0 then
			local p = hrp.Position
			if st.stage == 1 then
				if (Vector3.new(p.X, 0, p.Z) - Vector3.new(rollcall.Position.X, 0, rollcall.Position.Z)).Magnitude < 5 then
					toast(player, "점호 완료! \"이병 " .. player.DisplayName .. "!\"")
					nextStage(player)
				end
			elseif st.stage == 3 then
				st.nextSpawn = st.nextSpawn - dt
				if st.spawned < 8 + st.count and #st.enemies < 4 and st.nextSpawn <= 0 then
					spawnEnemy(player, st)
					st.spawned = st.spawned + 1
					st.nextSpawn = 2.5
				end
				for i = #st.enemies, 1, -1 do
					local e = st.enemies[i]
					local v = POST - e.pos
					local d = Vector3.new(v.X, 0, v.Z)
					if d.Magnitude < 3 then
						toast(player, "적이 초소에 도달했다! 경계근무 다시!")
						clearEnemies(st)
						st.count = 0
						st.spawned = 0
						armySend(player)
						break
					end
					e.pos = e.pos + d.Unit * 5 * dt
					e.model:PivotTo(CFrame.lookAt(e.pos + Vector3.new(0, 3.5, 0), POST + Vector3.new(0, 3.5, 0)))
				end
			elseif st.stage == 4 then
				if (p - gate.Position).Magnitude < 8 then
					st.stage = 5
					clearEnemies(st)
					remote:FireClient(player, "ArmyEnd", player.DisplayName)
				end
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
