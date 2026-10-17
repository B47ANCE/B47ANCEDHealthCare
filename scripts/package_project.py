"""Build/verify a separate Workshop test package; never deploys or uploads."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import stat
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
MOD = "B47ANCEDHealthCare"
ITEM = "3788592396"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def inputs():
    inventory = json.loads((ROOT / "SOURCE_INVENTORY.json").read_text())
    version = (ROOT / "VERSION").read_text().strip()
    assert inventory["project_version"] == version and inventory["mod_ids"] == [MOD]
    assert inventory["workshop_ids"] == [ITEM]
    source = ROOT / inventory["source_root"]
    expected = {}
    for directory, folders, files in os.walk(source, followlinks=False):
        for name in folders + files:
            path = Path(directory) / name
            assert not path.is_symlink() and not os.path.isjunction(path), "Linked source entry"
        for name in files:
            path = Path(directory) / name
            if name == ".keep":
                continue
            assert path.suffix.lower() in {".lua", ".json", ".txt", ".info", ".png"}
            expected[f"Contents/mods/{MOD}/{path.relative_to(source).as_posix()}"] = path.read_bytes()
    for name in ("preview.png", "workshop.txt"):
        expected[name] = (ROOT / name).read_bytes()
    assert len(expected) == len({name.casefold() for name in expected})
    info = expected[f"Contents/mods/{MOD}/42/mod.info"].decode("utf-8-sig")
    assert f"id={MOD}\n" in info and f"modversion={version}\n" in info
    assert "require=ProjectMORTIS,B47ANCEDKnowledgeAndWisdom" in info
    descriptor = expected["workshop.txt"].decode("utf-8-sig")
    assert "visibility=public" in descriptor and "MP testing build - dedicated multiplayer NOT TESTED" in descriptor
    return version, expected


def verify_zip(package, expected):
    with zipfile.ZipFile(package) as archive:
        members = archive.infolist()
        names = [member.filename for member in members]
        assert len(names) == len(set(names)) == len({name.casefold() for name in names}), "Duplicate/case-colliding members"
        assert set(names) == set(expected), "Unexpected/missing ZIP members"
        for member in members:
            path = PurePosixPath(member.filename)
            assert not path.is_absolute() and ".." not in path.parts and "\\" not in member.filename
            assert not re.match(r"^[A-Za-z]:", member.filename)
            assert not stat.S_ISLNK(member.external_attr >> 16)
            assert archive.read(member) == expected[member.filename], "Source/ZIP byte mismatch"
        assert archive.testzip() is None, "CRC/data failure"


def verify_stage(stage, expected):
    actual = {}
    for directory, folders, files in os.walk(stage, followlinks=False):
        for name in folders + files:
            path = Path(directory) / name
            assert not path.is_symlink() and not os.path.isjunction(path)
        for name in files:
            path = Path(directory) / name
            actual[path.relative_to(stage).as_posix()] = path.read_bytes()
    assert actual == expected, "Staging/source mismatch or unexpected file"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify", action="store_true")
    parser.add_argument("--steam-build-id", default="25485521", help="Observed appmanifest build ID; game runtime NOT TESTED")
    options = parser.parse_args()
    version, expected = inputs()
    dist = ROOT / "dist"
    stage = dist / f"workshop-{version}"
    package = dist / f"{MOD}-{version}-workshop-ready.zip"
    manifest_path = dist / f"RELEASE_{version.replace('.', '_')}.json"
    if not options.verify:
        assert not stage.exists() and not package.exists() and not manifest_path.exists(), "Existing artifacts are immutable; choose explicit retained alternative"
        assert not subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT).strip(), "Commit the reviewed release payload before packaging"
        dist.mkdir(exist_ok=True)
        for name, data in expected.items():
            path = stage / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        with zipfile.ZipFile(package, "x", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for name, data in sorted(expected.items()):
                member = zipfile.ZipInfo(name, date_time=(2026, 10, 16, 0, 0, 0))
                member.compress_type = zipfile.ZIP_DEFLATED
                member.external_attr = (stat.S_IFREG | 0o644) << 16
                archive.writestr(member, data)
        verify_zip(package, expected)
        verify_stage(stage, expected)
        manifest = {
            "project_version": version, "mod_id": MOD, "workshop_id": ITEM, "appid": "108600",
            "source_commit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT).decode().strip(),
            "github": "https://github.com/B47ANCE/B47ANCEDHealthCare",
            "package": package.name, "package_sha256": digest(package.read_bytes()),
            "minimum_game_version": "42.20.3", "installed_steam_build_id": options.steam_build_id,
            "game_runtime_version": "NOT VERIFIED BY LAUNCH", "distribution": "MP testing build - dedicated multiplayer NOT TESTED",
            "validation": {"offline": f"PASS; see docs/VALIDATION_{version.replace('.', '_')}.md", "SP": "NOT TESTED", "G7": "BLOCKED / NOT TESTED", "stable_G8": "BLOCKED"},
            "files": {name: digest(data) for name, data in sorted(expected.items())},
        }
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    manifest = json.loads(manifest_path.read_text())
    assert manifest["project_version"] == version and manifest["mod_id"] == MOD and manifest["workshop_id"] == ITEM
    assert manifest["package_sha256"] == digest(package.read_bytes())
    assert manifest["files"] == {name: digest(data) for name, data in sorted(expected.items())}
    # Bind the actual package to committed authoritative inputs, even after a later evidence-only commit.
    for name, data in expected.items():
        relative = name.replace(f"Contents/mods/{MOD}", f"src/{MOD}", 1) if name.startswith("Contents/") else name
        committed = subprocess.check_output(["git", "show", f"{manifest['source_commit']}:{relative}"], cwd=ROOT)
        assert committed.replace(b"\r\n", b"\n") == data.replace(b"\r\n", b"\n"), "Manifest commit/payload mismatch"
    verify_zip(package, expected)
    verify_stage(stage, expected)
    print(f"PASS: {len(expected)} exact package/staging files, CRC, safe paths, no duplicates, case, source hashes and commit {manifest['source_commit']}")
    print("Package SHA-256:", manifest["package_sha256"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
