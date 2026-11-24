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

-- 실제 말랑이 장난감 모양 (shape 이름으로 서버가 모델을 만듦)
Shared.SQUISHIES = {
	{ id = "mochi", name = "찹쌀떡 모찌", rarity = 1, shape = "mochi", color = Color3.fromRGB(250, 248, 242) },
	{ id = "tofu", name = "두부 말랑이", rarity = 1, shape = "tofu", color = Color3.fromRGB(248, 246, 236) },
	{ id = "bread", name = "식빵 말랑이", rarity = 1, shape = "bread", color = Color3.fromRGB(250, 232, 190) },
	{ id = "egg", name = "계란후라이 말랑이", rarity = 1, shape = "egg", color = Color3.fromRGB(255, 255, 250) },
	{ id = "macaron", name = "마카롱 말랑이", rarity = 2, shape = "macaron", color = Color3.fromRGB(255, 185, 205) },
	{ id = "cheese", name = "치즈 말랑이", rarity = 2, shape = "cheese", color = Color3.fromRGB(255, 215, 90) },
	{ id = "jelly", name = "젤리 큐브", rarity = 2, shape = "jelly", color = Color3.fromRGB(120, 220, 170) },
	{ id = "fishbread", name = "붕어빵 말랑이", rarity = 3, shape = "fish", color = Color3.fromRGB(215, 150, 70) },
	{ id = "meshball", name = "메쉬볼", rarity = 3, shape = "mesh", color = Color3.fromRGB(150, 200, 255) },
	{ id = "waterball", name = "물방울 말랑이", rarity = 3, shape = "water", color = Color3.fromRGB(180, 230, 255) },
	{ id = "goldfish", name = "황금 붕어빵", rarity = 4, shape = "fish", color = Color3.fromRGB(255, 200, 50), neon = true },
	{ id = "glitter", name = "반짝이 슬라임볼", rarity = 4, shape = "glitter", color = Color3.fromRGB(190, 120, 255) },
}

-- 소리: sounds 폴더의 mp3를 Roblox에 올린 뒤 오디오 ID로 바꾸면 더 말랑한 소리가 나요
-- (0 이면 Roblox 기본 소리를 대신 씀)
Shared.SQUISH_SOUND = "rbxassetid://0" -- squish.mp3
Shared.POP_SOUND = "rbxassetid://0" -- pop.mp3

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
