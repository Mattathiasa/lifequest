# Handoff: LifeQuest — mobile app (Direction 2, "Trail")

## Overview

LifeQuest turns real-life goals, habits and routines into an RPG-style adventure: users clear
**quests**, earn **XP**, level up a character, grow **attributes**, unlock **skill branches**, and
keep a **streak**. This bundle specifies the full mobile UI for the five primary screens plus four
overlays, at high fidelity.

The organising idea of this direction: **the day is a trail, not a list.** Today's quests sit on one
continuous vertical path — cleared nodes behind you, the live quest open inline with its actions,
the rest ahead, and a reward node at the end of the path. A quest is not a checkbox: tapping
*Start focus* opens a run sheet with a live timer, and completing from there fires the XP sequence.

## About the design files

`prototype/LifeQuest v2.dc.html` is a **design reference built in HTML** — an interactive prototype
that shows intended look, motion and behavior. It is **not production code to port line by line.**

The task is to **recreate these designs in Flutter** (the target environment stated by the product
brief) using idiomatic Flutter widgets, the project's own theme layer, and clean architecture. The
Dart files in `flutter/` are a starting point for the theme and the XP rules, already carrying the
exact values from the prototype so nothing drifts.

To view the prototype: open `prototype/LifeQuest v2.dc.html` in a browser (keep `support.js` next
to it). Everything in it is live — tab navigation, quest completion, the focus timer, the AI
generator, skill-branch selection, level-up.

## Fidelity

**High fidelity.** Colors, typography, spacing, radii, motion curves and copy in this document are
final. Recreate pixel-close. Where a value is not listed, derive it from the tokens rather than
inventing a new one.

Layout was designed at **390 × 844 logical px** (iPhone 14/15 class) and must scale fluidly to
360–440 dp widths; nothing is pinned to a fixed height.

---

## Design tokens

### Color

| Token | Value | Use |
|---|---|---|
| `canvas` | `#05070A` | app background, deepest layer |
| `canvasTop` | `#0B1018` | top of the screen gradient (185°, to `#070A0F` 55%, to `#05070A`) |
| `sheetTop` | `#111823` | bottom-sheet gradient start |
| `sheetBottom` | `#080B11` | bottom-sheet gradient end |
| `accent` | `#C7F022` | the single action color — CTAs, live state, XP, cleared nodes |
| `accentHover` | `#D9FF4F` | pressed/hover on accent fills |
| `textPrimary` | `#ECF1F8` | titles, quest names, values |
| `slate` | `#7789AB` | secondary text, meta, labels, inactive icons |
| `muted` | `#4E5A70` | tertiary text, inactive nav labels, done-quest XP |
| `faint` | `#2C3648` | separators inside meta rows, footer text |
| `difficultyEasy` | `#7789AB` | difficulty I |
| `difficultyMedium` | `#C7F022` | difficulty II |
| `difficultyHard` | `#E8B923` | difficulty III |
| `difficultyEpic` | `#FF7A6B` | difficulty IV |

Derived fills (do not introduce new solids — these are all `slate` or `accent` at alpha over canvas):

- `surface` = `slate @ 5%` — cards, chips, list containers
- `surfaceRaised` = `slate @ 7%` — inputs, "due/repeat" fields
- `surfaceIcon` = `slate @ 10%` — quest code tile
- `border` = `slate @ 14%` — default card border
- `borderStrong` = `slate @ 20–22%` — inputs, avatar tile, chips
- `borderHairline` = `slate @ 10–12%` — list-row dividers, nav top border
- `accentSurface` = `accent @ 7–9%` — live/accent cards, coach card
- `accentBorder` = `accent @ 22–35%` — live card, side quest, node detail
- `trackInactive` = `slate @ 16–18%` — XP ticks, attribute ticks, progress tracks

Gradients:

- hero level card: `linear-gradient(160°, accent@9%, slate@5%)`
- live trail card: `linear-gradient(150°, accent@8%, slate@5%)`
- side quest card: `linear-gradient(150°, #1A2210, #0A0D12 70%)`
- coach card: `linear-gradient(150°, accent@9%, slate@4%)`
- level-up scrim: `linear-gradient(180°, #05070A f5, #1A2210 f5)`
- phone bezel: `linear-gradient(200°, slate@35%, slate@6% 45%, accent@18%)`

### Typography

Two families, from Google Fonts: **Sora** (300/400/500/600/700) for everything readable, **DM Mono**
(400/500) for labels, codes and numeric meta.

| Role | Font | Size | Weight | Notes |
|---|---|---|---|---|
| Focus timer | Sora | 66 | 600 | `letter-spacing -.03em`, tabular numerals |
| Level-up number | Sora | 76 | 700 | `-.03em` |
| XP flash | Sora | 42 | 700 | accent |
| Hero level | Sora | 34 | 700 | `-.02em` |
| Screen title | Sora | 24 | 600 | line-height 1.2 |
| Sheet title (run) | Sora | 21 | 600 | 1.3 |
| Section/side-quest headline | Sora | 19 | 600 | 1.35 |
| Card title (board) | Sora | 15 | 500 | 1.25 |
| Card title (trail) | Sora | 14 | 500 | 1.25 |
| Body / description | Sora | 12.5–13.5 | 300 | 1.5–1.6 |
| Button label | Sora | 11.5–13.5 | 600 | |
| Nav label | Sora | 10.5 | 400 / 600 active | |
| Mono meta | DM Mono | 9.5–11 | 400 | `letter-spacing .10–.16em`, uppercase |
| Mono micro-label | DM Mono | 8.5–9 | 400 | `.08–.12em`, uppercase |
| Mono eyebrow | DM Mono | 10 | 400 | `.18–.30em`, uppercase, accent |

Rule of thumb: **anything uppercase is DM Mono with tracking; anything sentence-case is Sora.**

### Spacing, radius, motion

- Screen gutter: **24**. Card padding: **14 / 16 / 18 / 20**. Sheet padding: **20 24 28**.
- Gaps: 6, 7, 8, 9, 10, 12, 13, 16, 18, 22, 26 (use the scale, don't interpolate).
- Radii: phone screen **43**, sheet **34** (top only), hero card **26**, panels **24**,
  board card **22**, trail card / detail **20**, primary button **17–19**, input/secondary **16**,
  icon tile **14**, chip **11**, ticks **1–3**, nodes/dots **full**.
- Nav bar: top border hairline, `padding: 10 18 24`, 5 equal items, 5 px accent dot above the
  active label, dot + color animate `.25s`.
- Motion: sheet in `translateY(101%)→0` **340 ms** `cubic-bezier(.22,1,.36,1)`; overlay pop
  `scale(.9)→1` **400–450 ms** same curve; inline reveal `translateY(16px)+fade` **280–300 ms** ease;
  XP flight `translateY(-110px) scale(.6)` **1300 ms** delay 300 ms `cubic-bezier(.4,0,.6,1)`;
  live-node halo `box-shadow 0→14px accent@35%` **2.4 s** ease-out infinite; bar/tick fills
  **450–500 ms**; hover/state changes **200–250 ms**.
- Haptics (Flutter): light impact on quest complete, medium on level-up, selection click on
  chip/tab/difficulty change.

---

## Screens

### 1. Trail (Home) — `data-screen-label="Home"`

Purpose: answer "where am I in today's journey" in one glance, and start the next thing.

Layout, top to bottom inside a single scroll view (gutter 24, bottom padding 26):

1. **Greeting row** — left: mono date line `TUE 26 AUG · DAY 14`, Sora 24/600 `Good morning, Matt`,
   then a 300-weight slate line that is *contextual*: `Next up: deep work block.` (lowercased name of
   the first unfinished quest), or `Trail cleared. Rest is part of it.` at 100%.
   Right: 42×42 avatar tile, radius 16, `#131A24`, border `slate@22%`, initials in accent 13/600.
   Tapping it goes to the You tab.
2. **Hero level card** — radius 26, accent gradient, border `slate@16%`, padding 18.
   Row: level number Sora 34/700 + mono `LEVEL` baseline-aligned; right-aligned `2,450 / 3,000 XP`
   (Sora 13/600 accent) over `550 XP to next` (mono 10, slate).
   Below: **XP tick bar** — 20 segments, 3 px gap, 6 px tall, fully rounded; filled = accent,
   empty = `slate@18%`; fill count = `round(xp / need * 20)`; each segment animates 450 ms.
   Below that: three stat columns — `STREAK 14 days`, `TODAY 72%` (accent), `THIS WEEK 86%`.
3. **Section head** — `Today's trail` (Sora 13/600) + right mono `4 of 6 cleared`.
4. **The trail** — a relatively positioned block. A 2 px vertical rail sits at x = 51 from the
   screen edge, from 34 px below the top of the list to 52 px above its bottom, painted
   `linear-gradient(180°, accent 0 → accent P, slate@20% P → 100%)` where `P = cleared / total`.
   Each quest row: 32×32 circular node (2 px border) + a card, gap 16, row padding 7 vertical.

   | Quest state | Node fill | Node border | Node glyph | Card |
   |---|---|---|---|---|
   | cleared | accent | accent | `✓` in canvas | `slate@5%`, border `slate@14%`, title `muted` + line-through, XP `muted` |
   | **live** (first unfinished) | `accent@14%` | accent | index `03` in accent | accent gradient, border `accent@35%`, halo animation on the node, **actions visible** |
   | ahead | transparent | `slate@30%` | index in `muted` | `slate@5%`, border `slate@14%`, title `textPrimary` |

   Card content: name (Sora 14/500, ellipsis on overflow), mono meta `PRODUCTIVITY · 60 min`,
   right-aligned `+280` in Sora 13/600 accent. The live card additionally reveals a button row:
   **Start focus** (flex, accent fill, canvas text, radius 13, padding 11) and **Done**
   (radius 13, border `slate@30%`, slate label) — Done completes without the timer.
   Tapping anywhere else on a card opens the run sheet paused at 00:00.
5. **Reward node** — always last: 32 px circle with a *dashed* border and `✦`, plus a dashed card.
   Incomplete: `Clear the trail for +250 XP` / mono `2 QUESTS REMAINING`, all slate.
   Complete: accent node fill, accent title `Day cleared · +250 bonus XP`, mono
   `CLAIMED · STREAK EXTENDED TO 15`, card background `accent@7%`.
6. **Side quest card** (the daily challenge, toggleable via the `showDailyChallenge` prop) — radius
   26, dark olive gradient, border `accent@28%`, a soft accent radial blob top-right drifting
   ±6 px over 6 s. Eyebrow mono accent `SIDE QUEST · RARE`, right mono slate `expires 23:59`.
   Headline Sora 19/600 `Do the one thing you've been avoiding.` Footer: `+300 XP` Sora 20/700
   accent, and an **Accept** button (accent fill → after accepting: transparent fill, accent label,
   text `Accepted`). Accepting awards 300 XP through the normal completion sequence.

### 2. Quest board — `data-screen-label="Quests"`

Purpose: the full backlog, filterable; where quests are created.

- Header row: `Quest board` (24/600) + mono `9 ACTIVE · ALL`; right: **New** button (accent, radius 14).
- **Segment tabs**: `TODAY / UPCOMING / RECURRING / COMPLETED`, mono 10 with `.12em`, 22 px apart,
  13 px bottom padding, active = `textPrimary` + 2 px accent underline flush with the 1 px
  `slate@14%` divider; inactive = `muted`.
- **Category chips**: horizontal scroller, `ALL / HEALTH / LEARNING / PRODUCTIVITY / SOCIAL /
  FINANCE / MINDFULNESS`, mono 9.5, radius 11, padding 9×12. Selected = accent fill + canvas text;
  unselected = `slate@8%` fill, `slate@20%` border, slate text.
- **Quest cards**: radius 22, `slate@5%`, border `slate@14%`; hover/press → border `accent@35%`,
  background `accent@4%`. Layout: 40×40 code tile (radius 14, `slate@10%`, border `slate@20%`,
  3-letter mono code tinted by difficulty) + name (15/500) and description (12.5/300 slate) +
  right-aligned `+150`. Second row, indented 54 px to align under the text: mono
  `II MEDIUM / 60 min / 7:00 PM` with `faint` slashes as separators. Completed cards render at
  50 % opacity with a struck title.
- **Empty state** (any filter with no results): dashed `slate@28%` border, radius 26, 52 px
  padding; 44 px accent-outlined `✦` tile, `Your adventure is waiting` (18/600), one slate line
  `Nothing queued here yet. Add a quest and it lands on today's trail.`, then a **Create quest**
  button. Reachable in the prototype via Completed → any category, or Upcoming → Mindfulness.

### 3. Character — `data-screen-label="Character"`

- **Identity row**: 76 px tile (radius 26, accent gradient, border `accent@30%`, initials 22/600
  accent) + mono `CLASS · SCHOLAR`, `Disciplined Adventurer` (21/600), mono accent
  `LVL 12 · 34,120 LIFETIME XP`.
- **Attributes** (7): label mono 9.5 slate in a 74 px column, then a **20-segment tick bar**
  (2 px gap, 8 px tall, radius 1; filled = accent, empty = `slate@16%`, filled = `round(value/5)`),
  then the value right-aligned in Sora 13/600. Values: STRENGTH 64, INTELLECT 81, DISCIPLINE 88,
  HEALTH 72, CREATIVITY 57, SOCIAL 43, FOCUS 76. Attribute gains are driven by quest category
  (workout → HEALTH +2, study → INTELLECT +2, reading → FOCUS +1, social → SOCIAL +2).
- **Skill branches**: chip scroller of 7 branches (`HEALTH / KNOWLEDGE / CAREER / FINANCE / BONDS /
  CRAFT / MIND`), then the selected branch's **4 nodes side by side** as equal-width tiles
  (radius 20, `slate@5%`, 1 px border that is accent only on the selected tile): a 30 px circle,
  the node name (11/500), and the state in mono 8.5 `muted`.

  | State | Circle | Glyph | Name color |
  |---|---|---|---|
  | Mastered | accent fill | `✦` canvas | `textPrimary` |
  | Unlocked | `accent@16%`, accent border | `●` accent | `textPrimary` |
  | Available | transparent, slate border | `○` slate | `textPrimary` |
  | Locked | transparent, `slate@28%` border | `—` | `muted` |

  Selecting a node reveals a **detail panel** below (radius 22, accent gradient, border
  `accent@22%`, 280 ms rise-in): name (15/600) + state in mono accent, a 300-weight description,
  then two mono pills — benefit (`accent@12%` on accent text) and requirement (`slate@10%` on slate).
  Full node content for all seven branches is in the prototype's logic (`TREE`).
- **Achievements**: 2-column grid of radius-20 tiles. Earned: `accent@7%` fill, `accent@30%` border,
  accent `✦`, name in `textPrimary`, mono hint (`Earned Apr 2`). Locked: transparent, `slate@16%`
  border, `—` glyph, name in `muted`, progress hint (`68 / 100`). Six defined: 7 Day Streak,
  First Level Up, Quest Hunter, Night Owl, Perfect Week, Level 25.

### 4. Progress — `data-screen-label="Progress"`

- Three stat tiles in a row: `86% COMPLETION` (accent), `14 STREAK`, `31 RECORD`.
- **Weekly XP** panel: mono `4,180 TOTAL`; 7 bars, 112 px plot, 8 px gaps, radius 8, height
  proportional to max; the best day is accent, others `slate@28%`; day initial below in mono,
  accent for the best day. Bars animate height 500 ms.
- **Consistency** panel: 14 × 3 grid of square cells, 5 px gap, radius 3, four intensity steps
  (`slate@12%` for none, then accent at 0.15/0.75/1.0 alpha ramp); caption mono
  `LAST 6 WEEKS · LIME = QUESTS CLEARED`.
- **Where your XP goes**: five labelled 5 px progress rows — Health 38 %, Learning 22 %,
  Productivity 19 %, Mindfulness 13 %, Social 8 % — accent stepping down through slate.
- **Coach card**: accent gradient, eyebrow `COACH`, one 300-weight sentence naming the imbalance and
  the single next action. This is the surface for AI recommendations and adaptive difficulty.

### 5. You (Profile) — `data-screen-label="Profile"`

Identity row (64 px tile), three stat tiles (`LIFETIME XP` accent, `QUESTS DONE`, `BADGES`), then a
settings list in one radius-24 container: rows of 17×18 padding divided by `slate@10%` hairlines,
name 13/500 over a 300-weight slate hint, chevron in `muted`, row hover `accent@4%`.
Rows: Appearance / Notifications / Difficulty / Privacy / Account. Footer mono line
`LIFEQUEST 1.0 · LEVEL UP YOUR REAL LIFE` in `faint`.

---

## Overlays

### Focus run sheet
Opened by tapping a trail card or **Start focus**. Scrim `canvas@86%` + 8 px blur, tap-to-dismiss
above the sheet. Sheet: radius 34 top, sheet gradient, 38×4 grab handle, mono meta line
`PRODUCTIVITY · HARD · 60 min`, name 21/600, description 13/300, then the **timer** — Sora 66/600
tabular `MM:SS` with a mono status line below: `READY WHEN YOU ARE` → `FOCUS RUNNING` → `PAUSED`.
A 24-segment tick bar fills as elapsed time grows (1 segment ≈ 2.5 s in the prototype; in
production, scale to the quest's estimated duration). Footer: secondary
**Start / Pause / Resume** and primary **Complete · +280 XP** (accent).

### Quest complete
82 px accent square (radius 28) with a canvas `✓`, mono `QUEST COMPLETE`, then `+280` in 42/700
accent that flies up 110 px while shrinking to 0.6 and fading (1300 ms, 300 ms delay), and the quest
name below. Non-interactive, auto-dismisses at 1700 ms. Fire light haptic on open.

### Level up
Full-bleed dark-to-olive scrim. Eyebrow `LEVEL UP` (mono `.30em` accent), then
`12 → 13` with the old level in 38/300 slate and the new one in 76/700 `textPrimary`, a
300-weight line `Your character has grown stronger.`, and a pill
`New branch unlocked · Focus`. Queued **1400 ms after** the XP award (so the complete overlay reads
first), visible 2600 ms. Medium haptic.

### Create quest sheet
Same sheet chrome. Order matters: the **AI generator sits first**, above the manual form.
- AI row: 34 px accent-outlined `✦` tile, `Generate with AI` / `Describe a goal, get a quest chain
  back.`, right action `Try it`. After generating, the row restates the prompt
  (`From "I want to become healthier"`) with `Edit anything before it joins your trail.` and `Redo`.
- Generated list: four rows (mono code, name, `+XP`) then **Add all four** (accent). Adds them as
  recurring quests and lands the user on Quests → Recurring.
- Divider, then the manual form: **QUEST NAME** text input (radius 16, `slate@7%`, `slate@20%`
  border, placeholder `Run 5 KM`), **CATEGORY** chips, **DIFFICULTY SETS THE REWARD** — four equal
  tiles (Easy/Medium/Hard/Epic) each showing its computed reward, selected = accent fill,
  and **DUE** / **REPEAT** fields (`Today · 8:00 PM`, `Daily`).
- Primary action **Add to trail** — inserts into today and navigates to Quests → Today.

---

## Interactions & behavior

| Trigger | Result |
|---|---|
| Tap nav item | switch tab; dot + label color animate 250 ms |
| Tap trail card | open run sheet, timer at 00:00, not running |
| Tap **Start focus** | open run sheet with the timer already running (1 s tick) |
| Tap **Done** on live card | complete immediately, skip the sheet |
| Tap **Complete** in sheet | mark done → complete overlay → XP added → sheet closes, timer resets |
| Complete a quest | quest struck at 50 % opacity, node turns accent `✓`, rail gradient extends, next quest becomes live, XP ticks refill, day % and stat columns recompute |
| XP crosses the level threshold | after 1400 ms, level-up overlay; carry the remainder into the new level |
| Tap **Accept** on side quest | +300 XP via the same sequence; button becomes a passive `Accepted` |
| Change segment tab / category chip | filter the board; empty result renders the empty state |
| Select a skill node | detail panel rises in below the node row |
| Tap **New** / **Create quest** | create sheet |
| Tap **Try it** | reveal four generated quests (300 ms rise) |
| Tap scrim above a sheet | dismiss; the run timer resets |

All disabled/passive states are expressed by dropping the fill and keeping the accent outline — never
by graying out to a new color.

## State

Prototype state, one-to-one with what the production controller needs:

- `tab` — `home | quests | character | progress | profile`
- `level`, `xp` (within level), `lifetime`, `streak`
- `quests[]` — `id, code, name, desc, cat, diff, time, due, when (today|upcoming|recurring), done`
- `qtab`, `cat` — board filters
- `skillCat`, `node` — skill-tree selection
- `run` (quest id | null), `runSec`, `running` — focus session
- `sheet`, `ai`, `formName`, `formCat`, `formDiff` — create flow
- `flash` (`{xp, name}` | null), `levelUp` (previous level | null), `challenge`

Timers: 1 s interval for the run clock (cancel on close/complete/dispose); 1700 ms flash dismiss;
1400 ms level-up delay + 2600 ms dismiss. **Cancel every timer on dispose** — the prototype does
this in `componentWillUnmount`.

## Game rules (exact)

- XP to advance a level: `need(level) = 250 * level`. Level 12 → 13 costs 3,000 XP.
- Base rewards: Easy 50, Medium 150, Hard 280, Epic 500.
- Difficulty mode multiplies rewards and rounds to the nearest 10: Casual ×1.5, Balanced ×1.0,
  Hardcore ×0.7. (Exposed as a tweak in the prototype; ship it as the onboarding "difficulty" choice.)
- Awarding XP: add, then `while (xp >= need(level)) { xp -= need(level); level++; }` — a single
  award can cross more than one level.
- Clearing every quest in a day: +250 bonus and the streak increments.
- Difficulty numerals shown in the UI: I / II / III / IV, tinted per the difficulty colors.

Reference implementation: `flutter/lib/features/progression/domain/xp_rules.dart`.

## Suggested Flutter structure

```
lib/
  core/
    theme/        app_colors.dart · app_typography.dart · app_spacing.dart · app_theme.dart
    widgets/      xp_tick_bar.dart · trail_node.dart · quest_card.dart · category_chip.dart
                  segment_tabs.dart · stat_tile.dart · glass_sheet.dart · empty_state.dart
    utils/        haptics.dart · formatters.dart
  features/
    trail/        presentation/trail_page.dart · widgets/…
    quests/       data/ · domain/ · presentation/quest_board_page.dart · create_quest_sheet.dart
    focus/        presentation/focus_run_sheet.dart · application/focus_timer_controller.dart
    character/    presentation/character_page.dart · widgets/skill_branch_row.dart
    progress/     presentation/progress_page.dart · widgets/weekly_xp_chart.dart · heatmap.dart
    profile/      presentation/profile_page.dart
    progression/  domain/xp_rules.dart · application/progression_controller.dart
  app.dart · main.dart
```

Repository pattern with an in-memory/local implementation first (`QuestRepository`,
`ProgressionRepository`, `AchievementRepository`), swapped for Firestore later without touching
presentation. Riverpod for state. `google_fonts` for Sora + DM Mono.

## Build order

1. Theme + shared widgets (tick bar, node, cards, chips, sheet chrome) — everything else composes these.
2. Shell + bottom nav + Trail screen with mock data.
3. Quest completion sequence: complete overlay → XP award → level-up overlay → haptics.
4. Focus run sheet and its timer controller.
5. Quest board with filters + empty state, then the create sheet (manual form first, AI row stubbed).
6. Character (attributes, branches, node detail, achievements).
7. Progress (charts from real aggregates).
8. Profile + settings, onboarding (from the product brief: goals → difficulty → character).
9. Firebase swap, then tests.

## Assets

None external. Every mark in the design is type or geometry: `✓ ✦ ● ○ — ✕ ›` set in Sora, plus
three-letter mono quest codes (`MOV HYD FOC STU MED RST RUN FIN SHP CAL RED`) in place of icons.
Nothing needs an icon set to ship; if you later add one, keep it monoline and single-color.

## Files in this bundle

| Path | What it is |
|---|---|
| `prototype/LifeQuest v2.dc.html` | the interactive design reference (open in a browser) |
| `prototype/support.js` | runtime the prototype loads; keep it alongside |
| `flutter/lib/core/theme/app_colors.dart` | every color token above, as Dart |
| `flutter/lib/core/theme/app_typography.dart` | Sora + DM Mono text styles |
| `flutter/lib/core/theme/app_spacing.dart` | spacing, radii, durations, curves |
| `flutter/lib/core/theme/app_theme.dart` | assembled dark `ThemeData` |
| `flutter/lib/features/progression/domain/xp_rules.dart` | XP curve, rewards, level-up math |
| `CLAUDE.md` | instructions for implementing this with Claude Code |
