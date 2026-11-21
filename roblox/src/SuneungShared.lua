-- 한국 수능 부정행위! : 서버/클라이언트 공용 모듈 (ReplicatedStorage)
local Shared = {}

-- ★ 영역전개 사진: domain.png를 Roblox에 업로드한 뒤 나온 이미지 ID로 바꾸세요.
--   예) "rbxassetid://1234567890"   (0 이면 사진 없이 대사만 나옵니다)
Shared.DOMAIN_IMAGE = "rbxassetid://0"

Shared.DOMAIN_LINE = "료이키 텐카이 무량공처!"
Shared.TOTAL_Q = 10
Shared.TIME_LIMIT = 120
Shared.CHEAT_TIME = 3 -- 부정행위에 걸리는 시간(초)
Shared.NUM = { "①", "②", "③", "④", "⑤" }

-- 매점
Shared.START_MONEY = 100000
Shared.SHOP = {
	{ id = "kimbap", name = "삼각김밥", price = 1200, desc = "의심도 -15", sus = -15 },
	{ id = "ramen", name = "컵라면", price = 1500, desc = "남은 시간 +30초", time = 30 },
	{ id = "milk", name = "바나나우유", price = 1400, desc = "다음 부정행위 성공률 +30%", luck = 30 },
	{ id = "choco", name = "초코바", price = 1000, desc = "남은 시간 +15초", time = 15 },
	{ id = "cola", name = "콜라", price = 1300, desc = "의심도 -10, 시간 +10초", sus = -10, time = 10 },
	{ id = "energy", name = "에너지드링크", price = 2000, desc = "다음 부정행위 성공률 +50%", luck = 50 },
}
-- 부정행위 전문점: 세상의 전자기기
Shared.PRO = {
	{ name = "스마트워치", price = 15000 },
	{ name = "스마트폰", price = 30000 },
	{ name = "무선 이어폰", price = 12000 },
	{ name = "골전도 이어폰", price = 18000 },
	{ name = "초소형 이어폰", price = 25000 },
	{ name = "스마트 안경", price = 40000 },
	{ name = "스마트 콘택트렌즈", price = 70000 },
	{ name = "초소형 카메라", price = 22000 },
	{ name = "계산기", price = 3000 },
	{ name = "공학용 계산기", price = 8000 },
	{ name = "전자사전", price = 9000 },
	{ name = "태블릿", price = 35000 },
	{ name = "노트북", price = 60000 },
	{ name = "무전기", price = 14000 },
	{ name = "블루투스 볼펜", price = 11000 },
	{ name = "스마트 반지", price = 28000 },
	{ name = "스마트 지우개", price = 9000 },
	{ name = "전자 손목시계", price = 5000 },
	{ name = "MP3 플레이어", price = 6000 },
	{ name = "녹음기", price = 7000 },
	{ name = "보조배터리 겸 통신기", price = 13000 },
	{ name = "레이저 포인터", price = 4000 },
	{ name = "휴대용 게임기", price = 20000 },
	{ name = "VR 헤드셋", price = 55000 },
	{ name = "소형 드론", price = 45000 },
	{ name = "투명 디스플레이 필름", price = 50000 },
	{ name = "위성 전화기", price = 65000 },
	{ name = "AI 스피커", price = 16000 },
	{ name = "뇌파 헤드밴드", price = 80000 },
	{ name = "시간 정지 리모컨", price = 99000 },
}
function Shared.proPrice(name)
	for _, it in ipairs(Shared.PRO) do
		if it.name == name then
			return it.price
		end
	end
	-- 목록에 없는 물건은 맞춤 제작
	return 20000 + (Shared.hash(name) % 60) * 1000
end

function Shared.shopItem(id)
	for _, it in ipairs(Shared.SHOP) do
		if it.id == id then
			return it
		end
	end
end

Shared.BANK = {
	{ q = "다음 중 대한민국의 수도는?", a = "서울", w = { "부산", "평양", "도쿄", "세종대왕" } },
	{ q = "7 × 8 = ?", a = "56", w = { "54", "48", "63", "78" } },
	{ q = "물의 화학식은?", a = "H₂O", w = { "CO₂", "O₂", "NaCl", "H₂O₂" } },
	{ q = "'훈민정음'을 만든 왕은?", a = "세종대왕", w = { "태조", "광개토대왕", "정조", "선덕여왕" } },
	{ q = "빛의 삼원색이 아닌 것은?", a = "노랑", w = { "빨강", "초록", "파랑", "(전부 삼원색)" } },
	{ q = "1년은 보통 며칠인가?", a = "365일", w = { "360일", "366일", "300일", "100일" } },
	{ q = "'apple'의 뜻은?", a = "사과", w = { "배", "포도", "바나나", "감자" } },
	{ q = "지구에서 가장 큰 바다는?", a = "태평양", w = { "대서양", "인도양", "북극해", "동해" } },
	{ q = "√144 = ?", a = "12", w = { "14", "11", "72", "24" } },
	{ q = "삼각형 내각의 합은?", a = "180°", w = { "90°", "360°", "270°", "120°" } },
	{ q = "임진왜란이 일어난 해는?", a = "1592년", w = { "1392년", "1950년", "1910년", "1636년" } },
	{ q = "광합성에 필요하지 않은 것은?", a = "산소", w = { "빛", "물", "이산화탄소", "엽록소" } },
	{ q = "2의 10제곱은?", a = "1024", w = { "1000", "512", "2048", "100" } },
	{ q = "태양계에서 가장 큰 행성은?", a = "목성", w = { "토성", "지구", "화성", "태양" } },
	{ q = "수능 시험장에 가져가면 안 되는 것은?", a = "스마트폰", w = { "컴퓨터용 사인펜", "수험표", "신분증", "아날로그 시계" } },
}

local COPY_WORDS = { "옆", "짝", "친구", "앞사람", "뒷사람", "커닝", "베끼" }
local TYPES = { "전자기기형", "아날로그형", "초자연형", "물리형", "정신력형", "동물형" }

-- 한글이 깨지지 않게 글자 수 기준으로 자르기
function Shared.clip(str, n)
	local out, count = {}, 0
	local ok = pcall(function()
		for _, c in utf8.codes(str) do
			count = count + 1
			if count > n then
				break
			end
			out[#out + 1] = utf8.char(c)
		end
	end)
	if not ok then
		return ""
	end
	return table.concat(out)
end

-- 문자열 → 숫자 (항상 같은 값)
function Shared.hash(str)
	local h = 7
	for _, c in utf8.codes(str) do
		h = (h * 31 + c) % 2147483647
	end
	return h
end

-- 적은 아무거나 → 부정행위 능력치
function Shared.makeCheat(name, pro)
	local r = Random.new(Shared.hash(name))
	local copy = false
	for _, w in ipairs(COPY_WORDS) do
		if string.find(name, w, 1, true) then
			copy = true
		end
	end
	local cheat = { name = name, copy = copy }
	if copy then
		cheat.type = "옆사람 베끼기형"
		cheat.success = 90
	else
		cheat.type = TYPES[r:NextInteger(1, #TYPES)]
		cheat.success = r:NextInteger(35, 95)
	end
	cheat.risk = r:NextInteger(10, 65)
	-- 부정행위 전문점에서 산 정품 장비는 성능이 좋음
	if pro then
		cheat.pro = true
		cheat.type = "전문점 정품"
		cheat.success = math.min(99, cheat.success + 25)
		cheat.risk = math.max(5, cheat.risk - 15)
	end
	return cheat
end

-- 학생마다 다른 시험지: 보기 순서를 섞어서 정답 번호가 사람마다 다름
function Shared.paperFor(seed, qIndex)
	local q = Shared.BANK[qIndex]
	local opts = { q.a, q.w[1], q.w[2], q.w[3], q.w[4] }
	local r = Random.new(seed * 7 + qIndex * 7919)
	for i = #opts, 2, -1 do
		local j = r:NextInteger(1, i)
		opts[i], opts[j] = opts[j], opts[i]
	end
	local correct = 1
	for i, o in ipairs(opts) do
		if o == q.a then
			correct = i
		end
	end
	return opts, correct
end

function Shared.grade(score)
	if score >= 10 then return 1 end
	if score >= 9 then return 2 end
	if score >= 8 then return 3 end
	if score >= 7 then return 4 end
	if score >= 6 then return 5 end
	if score >= 5 then return 6 end
	if score >= 4 then return 7 end
	if score >= 2 then return 8 end
	return 9
end

return Shared
