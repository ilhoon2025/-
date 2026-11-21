# src/*.lua 를 하나의 Roblox 장소 파일(SuneungCheat.rbxlx)로 묶습니다.
import pathlib
here = pathlib.Path(__file__).parent
def src(name):
    s = (here / "src" / name).read_text(encoding="utf-8")
    return "<![CDATA[" + s.replace("]]>", "]]]]><![CDATA[>") + "]]>"
ref = iter(range(1, 100))
def item(cls, name, children="", source=None):
    props = f'<string name="Name">{name}</string>'
    if source is not None:
        props += f'<ProtectedString name="Source">{source}</ProtectedString>'
    return f'<Item class="{cls}" referent="RBX{next(ref)}"><Properties>{props}</Properties>{children}</Item>\n'
xml = '<roblox version="4">\n'
xml += item("Workspace", "Workspace")
xml += item("ReplicatedStorage", "ReplicatedStorage", item("ModuleScript", "SuneungShared", source=src("SuneungShared.lua")))
xml += item("ServerScriptService", "ServerScriptService", item("Script", "SuneungServer", source=src("SuneungServer.server.lua")))
xml += item("StarterPlayer", "StarterPlayer", item("StarterPlayerScripts", "StarterPlayerScripts", item("LocalScript", "SuneungClient", source=src("SuneungClient.client.lua"))))
xml += "</roblox>\n"
(here / "SuneungCheat.rbxlx").write_text(xml, encoding="utf-8")
print("wrote SuneungCheat.rbxlx", len(xml))
