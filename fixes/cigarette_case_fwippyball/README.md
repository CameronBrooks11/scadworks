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

`cigarette_holder_v1.scad` is OP's file exactly as posted - **do not modify it**, it is
the "before" reference for the fix.

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

Right now `holderheight`, `lidheight` and `lidoverlap` are three independent free
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
| `roof()` is an **experimental** builtin, off by default | 2026.09.05 nightly: `WARNING: Experimental builtin module 'roof' is not enabled ... line 43`. Needs `--enable=roof` on the CLI, or Preferences -> Features -> `roof` in the GUI. |
| On a release build `roof()` does not exist at all | 2021.01: `WARNING: Ignoring unknown module 'roof' ... line 43` (x5). Render still exits 0 - the chamfers just silently vanish. Anyone on a stable release gets a different part than OP printed and no error saying so. |
| `engraving(false)` is called but never defined | Both versions: `WARNING: Ignoring unknown module 'engraving' in file cigarette_holder_v1.scad, line 101`. Leftover from OP's local copy; the posted file is not self-contained. |
| Stray double semicolon | `outline(cyldiam+cylthick);;` in `lid()` - harmless, cosmetic. |
| Renders otherwise clean | 2021.01 CGAL: `Simple: yes`, 2450 facets, 3 volumes (holder + lid + the orphan translate). |

The `roof()` point matters most: it is the difference between "works great" for OP and
a chamfer-less part for a replier who tries it, and the warning is easy to scroll past.

## Scope of the fix

Deliver a `cigarette_holder_v2.scad` (or similarly named) alongside the original that:

1. **Customizer-annotates the parameters properly** - `/* [Group] */` tab headers,
   label comments, and constraint syntax where it earns its place: `[min:max]` /
   `[min:step:max]` sliders for the dimensional values, an integer spinbox for
   `cylnumber`, and `/* [Hidden] */` for `$fn` and anything not meant to be dialled.
2. **Derives the height relationship** instead of leaving three loose numbers, so
   OP's "shorter lid, taller case" is a parameter change rather than an arithmetic
   exercise - e.g. drive exposed holder length and overlap, compute lid height from
   them.
3. **Handles the `roof()` dependency honestly** - either state the version/flag
   requirement in a header comment, or replace the chamfer with something that works
   on a stock release build. Decide which before writing; do not ship both.
4. **Drops the undefined `engraving()` call** and the stray `;;` so the file runs
   clean out of the box.

Do not restructure the geometry. The `offset` fillet trick and the chamfer module are
OP's (and u/oldesole1's) and they work - the fix is about parameter surface and
portability, not a rewrite.

## Reply outline

Lead with the Customizer syntax OP asked for, in one pasteable block. Then the
version/flag warning as a short "heads up, this is why it might look flat for you".
Then the derived-heights suggestion as the answer to OP's own next-print note. Keep
the undefined `engraving()` to a one-line aside - it is a copy-paste slip, not worth
dwelling on.
