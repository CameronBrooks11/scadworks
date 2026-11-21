"""Render every .scad file in the repo and check the ones that state a result.

usage: python3 tests/test_scadworks.py [OPENSCAD]

- Every tracked .scad file but the two posted "before" files evaluates with
  --hardwarnings and no WARNING or ERROR line. OpenSCAD exits 0 on a failed
  assert when exporting, so the output decides, not the exit status.
- The struct examples echo what their "Should return" comment says.
- The cigarette case v2 closes to 87.5 mm whatever holderheight is, and
  refuses a split that leaves the lid nothing to grip.
"""

import os
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Posted as other people wrote them, faults and all: the README beside each says what is wrong.
BEFORE = {
    "fixes/cigarette_case_fwippyball/cigarette_holder_v1.scad": "uses the experimental roof()",
    "fixes/zosenerdambrug_sign_reddit/sign_old.scad": "the syntax error the post asked about",
}
CIGARETTE = os.path.join(ROOT, "fixes/cigarette_case_fwippyball/cigarette_holder_v2.scad")

results = []


def check(label, ok, got):
    results.append(bool(ok))
    print(f"{'ok  ' if ok else 'FAIL'} {label}: {got}")


def run(openscad, out, path, *args):
    r = subprocess.run([openscad, "--hardwarnings", "-o", out, *args, path],
                       capture_output=True, text=True, cwd=os.path.dirname(path))
    bad = [l for l in r.stderr.splitlines() if l.startswith(("WARNING", "ERROR"))]
    return r, bad


def heights(path):
    """The height of each separate solid in a binary STL, by joining shared corners."""
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    tris = [struct.unpack_from("<9f", data, 84 + i * 50 + 12) for i in range(n)]
    parent = {}

    def find(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    for t in tris:
        pts = (t[0:3], t[3:6], t[6:9])
        for p in pts:
            parent.setdefault(p, p)
        root = find(pts[0])
        for p in pts[1:]:
            parent[find(p)] = root
    parts = {}
    for t in tris:
        a, b, c = t[0:3], t[3:6], t[6:9]
        vol, lo, hi = parts.get(find(a), (0, 1e9, -1e9))
        vol += (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0])
                + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6
        parts[find(a)] = (vol, min(lo, a[2], b[2], c[2]), max(hi, a[2], b[2], c[2]))
    # A shell with negative volume is a cavity inside another solid, not a part.
    return sorted(hi - lo for vol, lo, hi in parts.values() if vol > 0)


def main():
    openscad = sys.argv[1] if len(sys.argv) > 1 else "openscad"
    files = subprocess.run(["git", "ls-files", "*.scad"], cwd=ROOT, capture_output=True, text=True,
                           check=True).stdout.split()
    with tempfile.TemporaryDirectory() as tmp:
        csg = os.path.join(tmp, "out.csg")
        stl = os.path.join(tmp, "out.stl")

        for f in files:
            if f in BEFORE:
                print(f"skip {f}: {BEFORE[f]}")
                continue
            r, bad = run(openscad, csg, os.path.join(ROOT, f))
            check(f"{f} evaluates", not bad and r.returncode == 0,
                  bad[0] if bad else ("no warnings" if not r.returncode else f"exit {r.returncode}"))

            path = os.path.join(ROOT, f)
            source = open(path).read()
            if "// Should return:" in source:
                want = [l[3:] for l in source.split("// Should return:")[1].splitlines() if l.startswith("// ECHO:")]
                got = [l for l in r.stderr.splitlines() if l.startswith("ECHO:")]
                check(f"{f} echoes what it says it should", got == want, got)

        for h in (60, 65, 80):
            r, bad = run(openscad, stl, CIGARETTE, "--export-format", "binstl",
                         "-D", f"holderheight={h}", "-D", "$fn=24")
            parts = None if bad else heights(stl)
            # The chamfer slices overlap by 1 micron, so compare to 0.01 mm.
            closed = parts and len(parts) == 2 and abs(parts[1] - h) < 0.01 \
                and abs(sum(parts) - 20 - 87.5) < 0.01
            check(f"cigarette case v2 at holderheight {h} closes to 87.5 mm", closed,
                  bad[0] if bad else f"part heights {[round(p, 3) for p in parts]}, lid overlap 20")

        r, bad = run(openscad, csg, CIGARETTE, "-D", "holderheight=20")
        check("cigarette case v2 refuses holderheight = lidoverlap",
              bad and "nothing left for the lid to grip" in bad[0], bad[0] if bad else "no error")

    print(f"{sum(results)} of {len(results)} checks passed")
    sys.exit(0 if all(results) else 1)


main()
