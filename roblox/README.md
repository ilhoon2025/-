# 한국 수능 부정행위! (Roblox 버전)

## 바로 열기
1. `SuneungCheat.rbxlx` 파일을 **Roblox Studio**로 엽니다 (파일 → 열기, 또는 더블클릭).
2. 위쪽 **▶ 플레이**를 누르면 교실이 자동으로 만들어지고 게임이 시작됩니다.

## 영역전개 사진 넣기 (한 번만)
Roblox는 외부 사진을 바로 못 쓰기 때문에 업로드가 필요해요.
1. Studio 상단 **보기 → 에셋 관리자(Asset Manager)** → **가져오기(Import)** 로 `domain.png` 업로드
   (또는 create.roblox.com → 개발자 아이템 → 데칼 업로드)
2. 업로드된 이미지를 우클릭 → **에셋 ID 복사**
3. `ReplicatedStorage > SuneungShared` 맨 위의 줄을 바꿉니다:
   ```lua
   Shared.DOMAIN_IMAGE = "rbxassetid://여기에_ID"
   ```
   ID가 `0`이면 사진 없이 대사만 나와요.

## 게임 방법
- 왼쪽 **✏️ 부정행위 적기!** 에 아무거나 적고 추가 → 고르고 **시험 시작**
- 내 캐릭터가 책상에 앉고 10문제(2분)를 풉니다.
- **🤫 부정행위 하기!** → 3초 동안 부정행위 → 성공하면 정답 힌트
- 시험지는 **학생마다 보기 순서가 달라서 정답 번호가 사람마다 다름**
  ("옆", "짝", "친구"가 들어간 부정행위는 옆사람 번호를 베끼는데… 대부분 틀림)
- 감독관의 **빨간 시야** 안에서 부정행위하면 적발 →
  감독관: **"료이키 텐카이 무량공처!"** → (검은 화면 없이) 사진이 잠깐 떴다 사라짐 → 들킨 학생은 **가루**
- AI 학생 없이, 서버에 들어온 플레이어들이 각자 빈 책상에 앉아 시험을 봐요. 감독관은 뉴비예요.

## 교실 밖
- 시험 중 **몰래 나가기**를 누르면 자리에서 일어나 걸을 수 있어요 (시험지는 잠시 숨겨짐).
- 교실 안에서 감독관 시야에 걸리면 적발, 감독관이 빈자리를 보면 의심도 +25 (100이 되면 적발).
- 오른쪽 **출입문** → 4차선 도로 → 길 건너 **매점**. 차에 치이면 죽고 시험은 실격 처리돼요.
- 매점 계산대에서 물건을 사고, 오른쪽 위 **가방**에서 먹으면 시험 중 효과가 있어요.
  (삼각김밥 의심도 -15, 컵라면 시간 +30초, 바나나우유/에너지드링크 다음 부정행위 성공률 증가 등)
- 처음 돈은 10,000원이에요. 자기 자리 가까이 와서 **자리로 돌아가기**를 누르면 다시 앉아요.

## 파일 구성
| 파일 | Studio 위치 |
|---|---|
| `src/SuneungShared.lua` | ReplicatedStorage › ModuleScript `SuneungShared` |
| `src/SuneungServer.server.lua` | ServerScriptService › Script `SuneungServer` |
| `src/SuneungClient.client.lua` | StarterPlayer › StarterPlayerScripts › LocalScript `SuneungClient` |

`.lua`를 수정했다면 `python3 build_rbxlx.py` 로 `.rbxlx`를 다시 만들 수 있어요.
