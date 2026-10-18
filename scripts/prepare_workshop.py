"""Prepare an existing-item VDF from canonical text. Never authenticates/uploads."""
import argparse
import json
import hashlib
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def quote(value):
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--preserve-existing-preview", action="store_true", help="Omit previewfile so Steam retains the existing Workshop thumbnail")
    options = parser.parse_args()
    subprocess.run([sys.executable, str(ROOT / "scripts/check_versions.py")], check=True)
    subprocess.run([sys.executable, str(ROOT / "scripts/validate_source.py")], check=True)
    subprocess.run([sys.executable, str(ROOT / "scripts/package_project.py"), "--verify"], check=True)
    version = (ROOT / "VERSION").read_text().strip()
    manifest = json.loads((ROOT / f"dist/RELEASE_{version.replace('.', '_')}.json").read_text())
    assert manifest["workshop_id"] == "3788592396" and manifest["appid"] == "108600"
    description = (ROOT / "WORKSHOP_DESCRIPTION.txt").read_text(encoding="utf-8-sig")
    changes = (ROOT / "WORKSHOP_CHANGE_NOTE.txt").read_text(encoding="utf-8-sig")
    assert "\\n" not in description + changes and "\n\n" in description and "\n\n" in changes
    assert len(description.encode("utf-8")) < 8000, "Description exceeds Steam's description limit"
    values = {
        "appid": "108600", "publishedfileid": "3788592396",
        "contentfolder": (ROOT / f"dist/workshop-{version}").as_posix(),
        "title": "B47ANCE'd Health Care", "description": description, "changenote": changes,
    }
    preview_path = ROOT / f"dist/workshop-{version}/preview.png"
    if not options.preserve_existing_preview:
        values["previewfile"] = preview_path.as_posix()
    preview = preview_path.read_bytes()
    assert preview.startswith(b"\x89PNG\r\n\x1a\n") and 0 < len(preview) < 1_000_000, "Preview must be PNG under 1 MB"
    assert hashlib.sha256(preview).hexdigest() == manifest["files"]["preview.png"], "Preview differs from verified package"
    # Preview replacement is explicit; preserve-existing-preview leaves Steam's
    # current thumbnail untouched. Visibility/tags are always omitted.
    text = '"workshopitem"\n{\n' + "".join(f"    {quote(key)} {quote(value)}\n" for key, value in values.items()) + "}\n"
    tokens = re.findall(r'"(?:\\.|[^"\\])*"', text, re.S)
    decoded = [json.loads(token, strict=False) for token in tokens]
    assert decoded[0] == "workshopitem" and dict(zip(decoded[1::2], decoded[2::2])) == values
    target = ROOT / f"dist/B47ANCEDHealthCare-{version}.vdf"
    if target.exists():
        assert target.read_text(encoding="utf-8") == text, "Existing descriptor differs; review explicitly"
    else:
        target.write_text(text, encoding="utf-8", newline="\n")
    preview_result = "existing Workshop preview preserved (previewfile omitted)" if options.preserve_existing_preview else "verified staged preview included"
    print(f"PASS: existing item 3788592396 / App 108600; canonical title, description, changes; {preview_result}; actual paragraph breaks round-trip; visibility/tags omitted")
    print("VDF:", target)


if __name__ == "__main__":
    main()
