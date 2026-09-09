# Parametric Cigarette Case - FwippyBall on Reddit

[Parametric cigarette case (for helping to limit cigarette usage)](https://www.reddit.com/r/openscad/comments/1wavv9n/parametric_cigarette_case_for_helping_to_limit/)
by u/FwippyBall in r/openscad. Thread read 2026-09-09.

`cigarette_holder_v1.scad` is OP's file, reformatted only (`d389ff0`) - the frozen
before. `cigarette_holder_v2.scad` is the answer.

## The ask

> I still need to learn the syntax for setting up the Customizer

u/Internal_Teach1339 already covered globals, the Window menu, and `//comment` as a
label, so a reply that stops there adds nothing. The gap is `/* [Group] */` tabs,
`[min:step:max]` sliders, and `/* [Hidden] */`.

OP also volunteered their own next-print note - shorter lid, taller case - which is a
parametrics problem: `holderheight`, `lidheight` and `lidoverlap` are three free
variables when the cigarette actually fixes the closed height.

## Found by running it

- **`roof()` is experimental.** Absent on release builds, off by default on dev
  snapshots. OpenSCAD only warns and still exits 0, so `chamfer()` loses its taper and
  every extrusion renders short - Z `0.200..64.700` instead of `0.000..65.000` - and
  the bottom relief cut, where `h - chamfer` is 0, intersects an empty union and
  vanishes. Anyone but OP prints a quietly undersized part. Six warnings on 2021.01,
  five of them identical, easy to scroll past.
- `engraving(false)` is called but never defined - the posted file is not self-contained.
- A stray `;` in `lid()`. Cosmetic.

## v2

Customizer-annotated; `lidheight` derived from `ciglength` so `holderheight` alone
slides the split (closed height stays 87.50mm across 60..80); `roof()` replaced with
stacked `offset()` slices needing no feature flag; two asserts for unbuildable splits.
99 lines against v1's 106.

Renders warning-free on stock 2021.01 and on a 2026.09 nightly, both with no flags.
Not checked: the Customizer's actual panel rendering, which needs the GUI.

## Reply

Lead with the Customizer syntax, one pasteable block. Then `roof()` as a short heads
up - on a release build this renders 0.2mm short and loses the bottom relief. Then
derived heights as the answer to OP's own note. `engraving()` as a one-line aside.
