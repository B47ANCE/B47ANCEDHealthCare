"""Pure metadata regression: no packages, game files or external programs written."""
import importlib.util
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/package_project.py"
SPEC = importlib.util.spec_from_file_location("package_project", SCRIPT)
PACKAGE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PACKAGE)


class PackageMetadataTests(unittest.TestCase):
    def data(self, newline="\n", ending=True):
        text = newline.join(("id=B47ANCEDHealthCare", "modversion=0.12.1",
                             "require=ProjectMORTIS,B47ANCEDKnowledgeAndWisdom"))
        return (text + (newline if ending else "")).encode("utf-8")

    def test_checkout_newlines_and_bom(self):
        for newline in ("\n", "\r\n"):
            for ending in (False, True):
                for bom in (b"", b"\xef\xbb\xbf"):
                    with self.subTest(newline=newline, ending=ending, bom=bom):
                        PACKAGE.validate_mod_metadata(bom + self.data(newline, ending), "0.12.1")

    def test_identity_version_and_dependencies_fail_closed(self):
        for before, after in ((b"id=B47ANCEDHealthCare", b"id=other"),
                              (b"modversion=0.12.1", b"modversion=0.12.0"),
                              (b"ProjectMORTIS", b"other")):
            with self.subTest(field=before), self.assertRaises(AssertionError):
                PACKAGE.validate_mod_metadata(self.data().replace(before, after), "0.12.1")

    def test_duplicate_fields_fail_closed(self):
        with self.assertRaises(AssertionError):
            PACKAGE.validate_mod_metadata(self.data() + b"id=B47ANCEDHealthCare\n", "0.12.1")


if __name__ == "__main__":
    unittest.main()
