"""Exercise the iOS icon CLI against real PNGs in an isolated asset set."""

import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest
import zlib

from tools import icon_pack_v1 as pack


def png(path, width=1024, height=1024, alpha=False, transparency=False):
    # Real PNG fixtures without a Pillow dependency, including fully opaque RGBA.
    def chunk(kind, data):
        return (struct.pack(">I", len(data)) + kind + data
                + struct.pack(">I", zlib.crc32(kind + data)))

    pixel = b"\x10\x60\x80" + (b"\xff" if alpha else b"")
    data = chunk(b"IHDR", struct.pack(">IIBBBBB", width, height,
                                      8, 6 if alpha else 2, 0, 0, 0))
    if transparency:
        data += chunk(b"tRNS", struct.pack(">HHH", 16, 96, 128))
    data += chunk(b"IDAT", zlib.compress((b"\x00" + pixel * width) * height))
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + data + chunk(b"IEND", b""))


class IconPackTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(dir=pack.ROOT)
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.icon_set = self.root / "AppIcon.appiconset"
        self.icon_set.mkdir()
        self.contents = self.icon_set / "Contents.json"
        self.contents.write_bytes((pack.ICON_SET / "Contents.json").read_bytes())
        self.source = self.root / "source.png"
        png(self.source)

    def run_cli(self, *args):
        return subprocess.run(
            [sys.executable, *(["-S"] if sys.flags.no_site else []), str(pack.ROOT / "tools/icon_pack_v1.py"),
             str(self.source), "--icon-set", str(self.icon_set), *args],
            capture_output=True, text=True,
        )

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)

    def snapshot(self):
        return {p.name: (p.read_bytes(), p.stat().st_mtime_ns)
                for p in self.icon_set.iterdir()}

    def test_generated_manifest_sizes_and_read_only_check(self):
        manifest = self.contents.read_bytes()
        self.assert_success(self.run_cli())
        entries = json.loads(manifest)["images"]
        expected = {entry["filename"] for entry in entries}
        self.assertEqual({p.name for p in self.icon_set.glob("*.png")}, expected)
        for entry in entries:
            size = tuple(int(float(side) * int(entry["scale"][:-1]))
                         for side in entry["size"].split("x"))
            header = (self.icon_set / entry["filename"]).read_bytes()
            self.assertEqual(struct.unpack(">II", header[16:24]), size)
            self.assertNotIn(header[25], (4, 6))  # PNG color types with alpha
        self.assertEqual(self.contents.read_bytes(), manifest)
        before = self.snapshot()
        source_before = (self.source.read_bytes(), self.source.stat().st_mtime_ns)
        self.assert_success(self.run_cli("--check"))
        self.assertEqual(self.snapshot(), before)
        self.assertEqual((self.source.read_bytes(), self.source.stat().st_mtime_ns), source_before)

    def test_bad_source_fails_both_modes_without_writes(self):
        before = self.snapshot()
        for options, message in [({"width": 512}, "expected"),
                                 ({"alpha": True}, "alpha"),
                                 ({"transparency": True}, "alpha")]:
            png(self.source, **options)
            for args in [(), ("--check",)]:
                with self.subTest(options=options, args=args):
                    result = self.run_cli(*args)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn(message, result.stderr)
                    self.assertEqual(self.snapshot(), before)

    def test_bad_output_fails_check_without_repairing_it(self):
        self.assert_success(self.run_cli())
        target = self.icon_set / "Icon-App-83.5x83.5@2x.png"
        for options, message in [({"width": 166, "height": 167}, "expected"),
                                 ({"width": 167, "height": 167, "alpha": True}, "alpha")]:
            with self.subTest(options=options):
                png(target, **options)
                before = self.snapshot()
                result = self.run_cli("--check")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(message, result.stderr)
                self.assertIn(target.name, result.stderr)
                self.assertEqual(self.snapshot(), before)
        target.unlink()
        self.assertNotEqual(self.run_cli("--check").returncode, 0)
        self.assertFalse(target.exists())

    def test_checked_in_default_set(self):
        result = subprocess.run(
            [sys.executable, *(["-S"] if sys.flags.no_site else []),
             str(pack.ROOT / "tools/icon_pack_v1.py"), "--check"],
            capture_output=True, text=True,
        )
        self.assert_success(result)


if __name__ == "__main__":
    unittest.main()
