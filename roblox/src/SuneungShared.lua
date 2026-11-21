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
function Shared.makeCheat(name)
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
