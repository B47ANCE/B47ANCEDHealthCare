"""Check declared current version mirrors; historical evidence is immutable."""
import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SEMVER = r"(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?"


def check(release=False):
    version = (ROOT / "VERSION").read_text().strip()
    inventory = json.loads((ROOT / "SOURCE_INVENTORY.json").read_text())
    errors = []
    if not re.fullmatch(SEMVER, version):
        errors.append("Invalid canonical Semantic Version")
    if inventory["project_version"] != version:
        errors.append("Inventory version differs from VERSION")
    for mirror in inventory["version_mirrors"]:
        text = (ROOT / mirror["path"]).read_text(encoding="utf-8-sig")
        values = re.findall(mirror["pattern"], text, re.M)
        if values != [version]:
            errors.append(f'{mirror["path"]}: expected one current {version}, got {values}')
    info = (ROOT / inventory["source_root"] / "42/mod.info").read_text(encoding="utf-8-sig")
    metadata = dict(line.split("=", 1) for line in info.splitlines() if "=" in line)
    if metadata["id"] != inventory["mod_ids"][0]:
        errors.append("Mod ID does not match inventory")
    if metadata["require"].split(",") != inventory["required_mod_ids"]:
        errors.append("Required Mod IDs do not match inventory")
    if (ROOT / "WORKSHOP_ID.txt").read_text().strip() != inventory["workshop_ids"][0]:
        errors.append("Workshop item identity changed")
    if release:
        errors.append("Stable G8 BLOCKED: dedicated multiplayer G7 is NOT TESTED")
    for error in errors:
        print("FAIL:", error)
    if not errors:
        print(f"PASS: {version}, {len(inventory['version_mirrors'])} current mirrors and identities")
    return int(bool(errors))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release", action="store_true")
    sys.exit(check(parser.parse_args().release))
