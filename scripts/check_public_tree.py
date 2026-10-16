"""Audit the exact Git index before a public push. Does not print secrets."""
from pathlib import Path, PurePosixPath
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
DENIED = {".git", ".codex", ".agents", "dist", "Contents", "__pycache__", "node_modules"}
PATTERNS = [
    rb"-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----",
    rb"gh[pousr]_[A-Za-z0-9]{25,}", rb"github_pat_[A-Za-z0-9_]{30,}",
    rb"AKIA[0-9A-Z]{16}", rb"sk-[A-Za-z0-9_-]{35,}",
    rb"(?i)(?:password|passwd|api[_-]?key|access[_-]?token)\s*[:=]\s*[\"'][^\"'\r\n]{8,}[\"']",
]


def main():
    names = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split("\0")
    failures = []
    for name in filter(None, names):
        path = PurePosixPath(name)
        if any(part in DENIED for part in path.parts) or path.suffix.lower() in {".zip", ".jar", ".class", ".exe", ".dll", ".vdf", ".log", ".pyc", ".pem", ".key"}:
            failures.append((name, "Excluded/generated/private path in index"))
        if path.name.lower() in {"console.txt", "server-console.txt", "loginusers.vdf", "config.vdf", ".steamcmd-last-upload.sha256"}:
            failures.append((name, "Local diagnostics/authentication state"))
        data = subprocess.check_output(["git", "show", ":" + name], cwd=ROOT)
        if any(re.search(pattern, data) for pattern in PATTERNS):
            failures.append((name, "Suspected credential pattern; inspect privately"))
        if (ROOT / name).is_symlink():
            failures.append((name, "Linked file must not be published"))
    for name, reason in failures:
        print("FAIL:", name, reason)
    print(f"Public index audit: {len(list(filter(None, names)))} files; {len(failures)} findings")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
