"""Offline identity, syntax, localization, Lua-only and case validation."""
import json
import hashlib
from pathlib import Path
import re
import struct
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]


def main():
    inventory = json.loads((ROOT / "SOURCE_INVENTORY.json").read_text(encoding="utf-8-sig"))
    source = ROOT / inventory["source_root"]
    files = sorted(p for p in source.rglob("*") if p.is_file())
    names = [p.relative_to(source).as_posix() for p in files]
    assert len(names) == len({name.casefold() for name in names}), "Case collision"
    allowed = {".lua", ".json", ".txt", ".info", ".png"}
    for path in files:
        assert not path.is_symlink(), "Linked source"
        assert path.suffix.lower() in allowed or path.name == ".keep", f"Unexpected runtime payload: {path.name}"
    lua = LuaRuntime(unpack_returned_tuples=True)
    compile_source = lua.eval("function(source,name) local f,e=loadstring(source,name); if not f then error(e) end; return true end")
    modules = {}
    for realm in ("shared", "client", "server"):
        for path in (source / "42/media/lua" / realm).rglob("*.lua"):
            module = path.relative_to(source / "42/media/lua" / realm).with_suffix("").as_posix()
            modules[module] = path
    for path in files:
        if path.suffix == ".lua":
            text = path.read_text(encoding="utf-8-sig")
            compile_source(text, str(path))
            assert '"experienceWorks/' not in text, "Removed dependency import"
            for imported in re.findall(r'require\s*\(?\s*["\']([^"\']+)["\']', text):
                if imported.startswith("medWorks/"):
                    assert imported in modules, f"Missing/case-wrong require: {imported}"
        elif path.suffix == ".json":
            json.loads(path.read_text(encoding="utf-8-sig"))
    translate = source / "42/media/lua/shared/Translate"
    en = {path.name: json.loads(path.read_text(encoding="utf-8-sig")) for path in (translate / "EN").glob("*.json")}
    locales = sorted(p for p in translate.iterdir() if p.is_dir())
    for locale in locales:
        for name, english in en.items():
            translated = json.loads((locale / name).read_text(encoding="utf-8-sig"))
            assert translated.keys() == english.keys(), f"Localization keys: {locale.name}/{name}"
            assert all(isinstance(value, str) and value.strip() for value in translated.values())
        assert json.loads((locale / "Sandbox.json").read_text(encoding="utf-8-sig"))["Sandbox_medWorks"] == "B47ANCE'd Health Care"
    info = dict(line.split("=", 1) for line in (source / "42/mod.info").read_text(encoding="utf-8-sig").splitlines() if "=" in line)
    assert info["name"] == "B47ANCE'd Health Care" and info["id"] == "B47ANCEDHealthCare"
    for role in ("poster", "icon"):
        image = source / "42" / info[role]
        data = image.read_bytes()
        assert data[:8] == b"\x89PNG\r\n\x1a\n" and all(struct.unpack(">II", data[16:24]))
    artwork = json.loads((ROOT / "artwork/ARTWORK.json").read_text(encoding="utf-8"))
    assert {entry["path"] for entry in artwork["outputs"]} == {
        "preview.png", f"{inventory['source_root']}/thumbnail.png",
        f"{inventory['source_root']}/42/{info['poster']}",
    }, "Artwork roles differ from authoritative metadata"
    for entry in [artwork["original"], *artwork["outputs"], artwork["preserved_icon"]]:
        data = (ROOT / entry["path"]).read_bytes()
        assert hashlib.sha256(data).hexdigest() == entry["sha256"], f"Artwork hash: {entry['path']}"
        assert len(data) == entry["bytes"] and data[:8] == b"\x89PNG\r\n\x1a\n"
        assert list(struct.unpack(">II", data[16:24])) == entry["dimensions"]
    assert len({entry["sha256"] for entry in artwork["outputs"]}) == 1
    assert all(entry["dimensions"] == [512, 512] and entry["bytes"] < 1_000_000 for entry in artwork["outputs"])
    for name in ("WORKSHOP_DESCRIPTION.txt", "WORKSHOP_CHANGE_NOTE.txt", "workshop.txt"):
        text = (ROOT / name).read_text(encoding="utf-8-sig")
        assert "\\n" not in text and "MP testing build - dedicated multiplayer NOT TESTED" in text
        assert "3788592396" in text
    print(f"PASS: Lua-only payload ({len(files)} files), {len(modules)} Lua modules, exact internal requires, {len(locales)} locales, artwork and Workshop identity/text")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
