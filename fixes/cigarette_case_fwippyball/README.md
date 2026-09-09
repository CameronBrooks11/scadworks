# Parametric Cigarette Case - FwippyBall on Reddit

Response to a post in [r/openscad](https://www.reddit.com/r/openscad/): *"Parametric
cigarette case (for helping to limit cigarette usage)"* by u/FwippyBall.
<!-- TODO: exact post permalink was not captured with the thread; fill before replying. -->

Thread captured 2026-09-09 11:36 EST, post ~22h old at that time.

## Context

OP wanted a printable case that both protects cigarettes in a bag and caps how many
get carried, and used it as their first OpenSCAD project. The design is a holder body
plus a slip-over lid, both derived from the same 2D outline: N overlapping circles
unioned, then filleted with an `offset(r)` / `offset(delta=-r)` pair, then extruded
with a chamfer at the top. Credit for the extruded-shape math goes to u/oldesole1,
per OP.

`cigarette_holder_v1.scad` is OP's file as posted, reformatted in place (commit
`d389ff0`) with no semantic change - it renders byte-identical STL to the original.
Treat it as the frozen "before" reference; the fix lives in
`cigarette_holder_v2.scad`.

Parameters as posted: 4 cylinders, 12 mm dia, 10.5 mm centre spacing, 3 mm fillet,
65 mm holder inner height, 45 mm lid inner height, 20 mm lid overlap, 1 mm wall,
0.01 mm fit tolerance, 0.2 mm outer chamfer.

## What OP actually asked for

> I still need to learn the syntax for setting up the Customizer, but if you play
> around with the variables you can probably figure out what they do.

So the ask is **Customizer annotation syntax**, not the geometry.

OP also volunteered a design gripe worth answering, since it is a parametrics problem
rather than a print problem:

> if I ever print a new one I should make the height of the lid shorter and the case
> (minus the overlap space) taller

In v1 `holderheight`, `lidheight` and `lidoverlap` are three independent free
variables, so nothing enforces that the lid covers the overlap or that the exposed
holder is the length OP wants. That relationship should be derived, not hand-tuned.

## Thread state - what is already answered

u/Internal_Teach1339 replied with the basics and OP has seen it: declare variables
globally (outside modules), open **Window -> Customizer**, and `//comment` immediately
above a variable becomes its label. They confirmed resizing and cylinder count work.

**A reply that only repeats that adds nothing.** The gap left open is everything past
the bare label: parameter groups/tabs, value constraints, and the fact that the file
has real problems that will bite OP the moment someone else opens it.

## Findings from running the file

Verified locally, not inferred:

| Finding | Evidence |
| --- | --- |
| `roof()` is an **experimental** builtin, off by default | 2026.09.05 nightly: `WARNING: Experimental builtin module 'roof' is not enabled ... line 44`. Needs `--enable=roof` on the CLI, or Preferences -> Features -> `roof` in the GUI. |
| On a release build `roof()` does not exist at all | 2021.01: `WARNING: Ignoring unknown module 'roof' ... line 44` (x5). Render still exits 0. It is worse than losing the chamfers: `chamfer()` intersects with a `union()` whose only other branch is `linear_extrude(h - chamfer)`, so every extrusion comes out short (Z `0.200..64.700` instead of `0.000..65.000`), and the bottom relief cut - where `h - chamfer` is 0 - intersects with an empty union and disappears entirely. |
| `engraving(false)` is called but never defined | Both versions: `WARNING: Ignoring unknown module 'engraving' in file cigarette_holder_v1.scad, line 104`. Leftover from OP's local copy; the posted file is not self-contained. |
| Stray empty statement | `;;` after `outline(...)` in `lid()`, now a lone `;` at line 88 post-format - harmless, cosmetic. |
| Six warnings in total on a release build | 2021.01: 5x `roof`, 1x `engraving`. Geometry is otherwise `Simple: yes`, 2450 facets. |

The `roof()` point matters most: it is the difference between "works great" for OP and
a quietly undersized part for anyone else who prints the file, and the warning scrolls
past among five identical copies of itself.

## The fix

Delivered as `cigarette_holder_v2.scad`, one commit per item:

1. `e3eb74f` - **drops the undefined `engraving()` call** and the stray `;`. Verified
   byte-identical STL to v1, so the rest of the work starts from a clean base.
2. `76ef920` - **replaces `roof()` with stacked inward `offset()` slices.** No feature
   flag, no version floor. A four-step minimum keeps small chamfers honest: at the
   0.2mm outer chamfer the profile lands 0.05mm off the `roof()` reference.
3. `054edba` - **derives `lidheight` from `ciglength`** and exposes the floor and
   ceiling that were bare `1`s. `holderheight` alone now slides the split, with two
   asserts guarding splits that cannot be built.
4. `f52d357` - **annotates the parameters for the Customizer** and adds a `part`
   dropdown, which also retires the commented-out `cylinder(84, d=9);` dummy at the
   foot of the file in favour of a `fitcheck` view.

The geometry is untouched beyond the chamfer implementation. The `offset` fillet trick
is OP's (and u/oldesole1's) and it works - this was about parameter surface and
portability, not a rewrite.

## Verification

| Check | Result |
| --- | --- |
| v2 on stock 2021.01, no flags | exit 0, **zero warnings** (v1 warns 6x) |
| v2 on 2026.09.05 nightly, no flags | exit 0, zero warnings |
| `part` = both / holder / lid / fitcheck | all render clean |
| Closed height across `holderheight` 60..80 | constant **87.50mm**, measured from renders |
| Both asserts | fail on the input each names, exit 1 |
| Customizer `-p/-P` parameter set | applies; 4->6 cylinders widens X 44.50 -> 65.50 |
| Chamfer vs `roof()` reference | base width 12.650 vs 12.600 (full 13.000) |

Known cosmetic artifact: the slice overlap epsilon puts the Z extent at
-0.001..65.001 instead of 0..65. One micron, well under print resolution.

Not verified here: the Customizer's actual *panel rendering* - groups, sliders,
dropdown - needs the GUI. The annotation syntax follows the documented form and the
parameters are confirmed reachable via `-p/-P`.

## Reply outline

Lead with the Customizer syntax OP asked for, in one pasteable block. Then the
version/flag warning as a short "heads up, on a release build this renders 0.2mm
short and loses the bottom relief".
Then the derived-heights suggestion as the answer to OP's own next-print note. Keep
the undefined `engraving()` to a one-line aside - it is a copy-paste slip, not worth
dwelling on.
