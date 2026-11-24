# 말랑이 공방 (Roblox 말랑이 게임)

## 바로 열기
`MalangGame.rbxlx` 를 Roblox Studio로 열고 ▶ 플레이.

## 게임 방법
- 말랑이를 **클릭**하면 납작하게 눌렸다가 탱글탱글 돌아오면서 **말랑 포인트(P)** 를 줘요.
- 빠르게 연달아 누르면 **콤보** (최대 x20, 콤보마다 +10%).
- 광장 가운데 **왕말랑이**는 포인트 2배.
- **말랑이 뽑기** 기계 앞에서 E (100P) → 캡슐이 흔들리다 열리면서 새 말랑이 등장.
- 뽑은 말랑이는 **펫처럼 나를 따라다니고** (최대 3마리), 5초마다 포인트를 모아 와요. 펫도 클릭하면 말랑해요.
- 오른쪽 아래 **도감** 버튼으로 모은 말랑이 확인.

## 말랑이 12종 (실제 말랑이 장난감 모양)
| 등급 (확률) | 말랑이 | 1번 누를 때 |
|---|---|---|
| 일반 (60%) | 찹쌀떡 모찌, 두부 말랑이, 식빵 말랑이, 계란후라이 말랑이 | 1P |
| 희귀 (28%) | 마카롱 말랑이, 치즈 말랑이, 젤리 큐브 | 3P |
| 영웅 (10%) | 붕어빵 말랑이, 메쉬볼, 물방울 말랑이 | 8P |
| 전설 (2%) | 황금 붕어빵, 반짝이 슬라임볼 | 25P |

## 소리
- 누를 때 "꾸욱… 뽀용" 소리 (말랑이가 클수록 낮은 소리), 뽑기 캡슐이 열릴 때 "뽕" 소리
- 기본은 Roblox 내장 소리. `sounds/squish.mp3`, `sounds/pop.mp3` 를 Roblox에 오디오로 올린 뒤
  `MalangShared` 의 `Shared.SQUISH_SOUND`, `Shared.POP_SOUND` 에 ID를 넣으면 진짜 말랑한 소리가 나요.

## 파일
| 파일 | Studio 위치 |
|---|---|
| `src/MalangShared.lua` | ReplicatedStorage › ModuleScript `MalangShared` |
| `src/MalangServer.server.lua` | ServerScriptService › Script `MalangServer` |
| `src/MalangClient.client.lua` | StarterPlayer › StarterPlayerScripts › LocalScript `MalangClient` |

`.lua`를 고친 뒤 `python3 build_rbxlx.py` 로 `.rbxlx`를 다시 만들 수 있어요.
저장 기능은 없어서 나갔다 들어오면 처음부터예요.
