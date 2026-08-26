# CLAUDE.md — LifeQuest

## What this repo is

A Flutter mobile app that turns real-life goals and habits into an RPG-style adventure. The UI is
already designed and approved; this repository is the implementation of that design.

## Read first

`design_handoff_lifequest/README.md` is the design spec — tokens, every screen, every interaction,
and the exact game rules. Treat it as the source of truth. `design_handoff_lifequest/prototype/`
holds the interactive HTML reference; open it in a browser to see intended motion and behavior.
**The HTML is a reference, not code to port** — rebuild it in Flutter.

## Non-negotiables

- **Dark first.** Canvas `#05070A`, one accent `#C7F022`, slate `#7789AB` for everything secondary.
  No new hues, no gradients beyond the ones listed in the spec, no glow-on-everything.
- **Accent is the action color.** If something is not interactive, live, or a reward, it is not lime.
- **Two fonts.** Sora for sentence-case, DM Mono (uppercase, tracked) for labels and codes.
  Nothing else, ever.
- **No icon set.** Marks are type or geometry, quest identity is a three-letter mono code.
- **Tokens over literals.** Colors, radii, spacing and durations come from `core/theme/`.
  A magic number in a widget file is a bug.
- **Never gray out.** Passive states drop the fill and keep the accent outline.
- Text never below 12 sp; tap targets never below 44 dp.

## Architecture

Clean architecture, feature-first, repository pattern, Riverpod for state. Presentation never
touches a data source directly. Start with in-memory repositories seeded from the spec's mock data,
behind the same interfaces Firebase will implement later — swapping them must not touch a widget.

Layout: `lib/core/{theme,widgets,utils}` + `lib/features/<feature>/{data,domain,application,presentation}`.
The suggested tree is in the handoff README.

## Order of work

1. `core/theme` (already drafted in the handoff — copy it in) and the shared widgets: XP tick bar,
   trail node, quest card, category chip, segment tabs, stat tile, sheet chrome, empty state.
2. App shell + bottom nav + the Trail screen against mock data.
3. The completion sequence — complete overlay → XP award → level-up overlay → haptics. This is the
   emotional core; it should feel right before anything else is built on top of it.
4. Focus run sheet + timer controller (cancel timers on dispose).
5. Quest board: filters, empty state, then the create sheet (manual form first, AI row stubbed).
6. Character: attributes, skill branches, node detail, achievements.
7. Progress: charts driven by real aggregates.
8. Profile + settings, then onboarding (goals → difficulty → character).
9. Firebase (auth, Firestore, messaging, analytics, crashlytics), then offline sync.
10. Tests: `xp_rules` unit tests first (the award loop crossing multiple levels is the interesting
    case), then widget tests per screen, then a golden per screen.

## Definition of done for a screen

Matches the spec's values; empty, loading and error states all designed and implemented; animations
use the durations and curves from `Motion`; no hardcoded colors; scrolls without overflow at 360 dp
and 440 dp widths; respects safe areas; passes `flutter analyze` with no warnings.

## Conventions

- `flutter analyze` and `dart format .` clean before every commit.
- Commit messages: imperative subject under 72 chars, scoped where useful
  (`feat(trail): add reward node`). **Do not add a `Co-authored-by` trailer to commits.**
- One feature per PR; no dead code, no commented-out blocks, no TODOs without an owner.
