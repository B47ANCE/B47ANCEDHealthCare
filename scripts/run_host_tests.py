"""Run existing regressions in isolated Lua 5.1; never starts PZ or a server."""
import argparse
import os
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dependencies", type=Path, default=ROOT.parent)
    options = parser.parse_args()
    os.chdir(ROOT)
    base = Path("src/B47ANCEDHealthCare/42/media")
    shared = base / "lua/shared/medWorks"
    client = base / "lua/client/medWorks"
    spectrum = options.dependencies / "B47ANCEDSPXTRM/src/B47ANCEDSPXTRM/42/media/lua/shared"
    sources = [ROOT / base / "lua"]
    sources.extend(options.dependencies / folder / "src" / mod / "42/media/lua" for folder, mod in [
        ("B47ANCEDKnowledgeAndWisdom", "B47ANCEDKnowledgeAndWisdom"),
        ("Project MORTIS", "ProjectMORTIS"), ("B47ANCEDSPXTRM", "B47ANCEDSPXTRM")])
    paths = ";".join((root / realm / "?.lua").as_posix() for root in sources for realm in ("shared", "client", "server"))
    arguments = {
        "test_severing.lua": [shared / "init.lua"],
        "test_procedure_diagnostics.lua": [shared / "ProcedureDiagnostics.lua"],
        "test_sunburn_treatment.lua": [shared / "init.lua", spectrum / "lightWorks/lightWorks_Sunburn.lua", shared / "SunburnTreatment.lua"],
        "test_load_graph.lua": [client / "Load.lua", base / "lua/server/medWorks/Load.lua"],
        "test_sandbox_contract.lua": [base / "sandbox-options.txt", base / "lua/shared/Translate/EN/Sandbox.json", shared / "CorpseRecovery.lua", shared / "Knowledge.lua", shared / "Examination.lua", client / "ExaminationAction.lua"],
    }
    failures = []
    tests = sorted((ROOT / "tests").glob("test_*.lua"))
    for test in tests:
        runtime = LuaRuntime(unpack_returned_tuples=True)
        runtime.globals().package.path = paths + ";" + runtime.globals().package.path
        runtime.globals().arg = runtime.table_from([p.as_posix() for p in arguments.get(test.name, [])])
        messages = []
        runtime.globals().print = lambda *values: messages.append(" ".join(map(str, values)))
        try:
            runtime.execute(test.read_text(encoding="utf-8-sig"), name="@" + test.as_posix())
            print("PASS", test.name, flush=True)
        except Exception as error:
            failures.append(test.name)
            print("\n".join(messages[-3:]))
            print("FAIL", test.name, error, flush=True)
    print(f"Offline Lua 5.1: {len(tests) - len(failures)}/{len(tests)} PASS. PZ/SP/dedicated NOT TESTED.")
    return int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
