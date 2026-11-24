-- 말랑이 공방: 서버/클라이언트 공용 (ReplicatedStorage)
local Shared = {}

Shared.GACHA_COST = 100 -- 뽑기 가격 (말랑 포인트)
Shared.MAX_PETS = 3 -- 따라다니는 말랑이 수
Shared.PASSIVE_EVERY = 5 -- 몇 초마다 펫이 포인트를 주는지

Shared.RARITY = {
	{ name = "일반", color = Color3.fromRGB(150, 160, 170), weight = 60, pts = 1 },
	{ name = "희귀", color = Color3.fromRGB(70, 150, 255), weight = 28, pts = 3 },
	{ name = "영웅", color = Color3.fromRGB(180, 90, 255), weight = 10, pts = 8 },
	{ name = "전설", color = Color3.fromRGB(255, 180, 30), weight = 2, pts = 25 },
}

-- shape: 모양 종류 (서버가 이 이름으로 모델을 만듦)
Shared.SQUISHIES = {
	{ id = "mochi", name = "모찌", rarity = 1, shape = "ball", color = Color3.fromRGB(250, 248, 240) },
	{ id = "strawberry", name = "딸기모찌", rarity = 1, shape = "leafball", color = Color3.fromRGB(255, 170, 190), leaf = Color3.fromRGB(90, 190, 90) },
	{ id = "bread", name = "식빵", rarity = 1, shape = "bread", color = Color3.fromRGB(250, 225, 170) },
	{ id = "pudding", name = "푸딩", rarity = 1, shape = "pudding", color = Color3.fromRGB(255, 225, 110) },
	{ id = "cloud", name = "구름", rarity = 2, shape = "cloud", color = Color3.fromRGB(240, 248, 255) },
	{ id = "cat", name = "고양이", rarity = 2, shape = "cat", color = Color3.fromRGB(200, 200, 205) },
	{ id = "peach", name = "복숭아", rarity = 2, shape = "leafball", color = Color3.fromRGB(255, 200, 170), leaf = Color3.fromRGB(110, 170, 80) },
	{ id = "jelly", name = "젤리 친구", rarity = 3, shape = "buddy", color = Color3.fromRGB(120, 230, 160), glass = true },
	{ id = "rainbow", name = "무지개 모찌", rarity = 3, shape = "rainbow", color = Color3.fromRGB(255, 120, 120) },
	{ id = "gold", name = "황금 모찌", rarity = 4, shape = "ball", color = Color3.fromRGB(255, 200, 50), neon = true },
	{ id = "space", name = "우주 말랑이", rarity = 4, shape = "space", color = Color3.fromRGB(120, 70, 220), neon = true },
}

function Shared.byId(id)
	for _, s in ipairs(Shared.SQUISHIES) do
		if s.id == id then
			return s
		end
	end
end

function Shared.pointsOf(id)
	local s = Shared.byId(id)
	return s and Shared.RARITY[s.rarity].pts or 1
end

-- 뽑기: 등급 확률로 등급을 고르고, 그 등급 안에서 무작위
function Shared.roll(rng)
	local total = 0
	for _, r in ipairs(Shared.RARITY) do
		total = total + r.weight
	end
	local x = rng:NextNumber() * total
	local rarity = 1
	for i, r in ipairs(Shared.RARITY) do
		if x < r.weight then
			rarity = i
			break
		end
		x = x - r.weight
	end
	local pool = {}
	for _, s in ipairs(Shared.SQUISHIES) do
		if s.rarity == rarity then
			table.insert(pool, s)
		end
	end
	return pool[rng:NextInteger(1, #pool)]
end

return Shared
