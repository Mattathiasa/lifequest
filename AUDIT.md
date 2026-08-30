# LifeQuest Project Audit

## Current State: ~75% Complete MVP

### What's Built & Working

| Layer | Status | Notes |
|-------|--------|-------|
| **Theme System** | ✅ Complete | All tokens from spec, no hardcoded values |
| **Core Widgets** | ✅ Complete | XpTickBar, TrailNode, QuestCard, etc. |
| **5-Tab Navigation** | ✅ Complete | With accent dot animation |
| **Trail Screen** | ✅ Complete | Greeting, hero card, trail nodes, reward, side quest |
| **Quest Board** | ✅ Complete | Filters, empty state, create sheet |
| **Character Screen** | ✅ Complete | 7 attributes, 7 skill branches, achievements |
| **Progress Screen** | ✅ Complete | Charts, heatmap, XP breakdown, coach card |
| **Profile Screen** | ✅ Complete | Settings, difficulty picker |
| **Focus Timer** | ✅ Complete | Start/pause/resume with tick bar |
| **XP/Level System** | ✅ Complete | Full award loop, multi-level crossing |
| **Overlays** | ✅ Complete | Complete flash, level-up animation |
| **Onboarding** | ✅ Complete | 4-step flow |
| **Persistence** | ✅ Complete | SharedPreferences with seed data |
| **Tests** | ⚠️ Partial | 3 test files exist |

---

## Critical Issues to Fix for MVP

### 1. Quest Persistence Bug
The `quest_providers.dart` creates `PrefsQuestRepository` but it's not actually being used correctly. Need to verify quests persist across app restarts.

### 2. Mock Data in Progress Screen
The Progress page uses hardcoded values:
- "86% COMPLETION" (not computed)
- "4,180 TOTAL" (not from history)
- Weekly XP chart is static mock data
- Heatmap is hardcoded

**Fix:** Wire up `GameStats` providers to compute real aggregates from completion history.

### 3. No Delete/Edit Quests
Users can create quests but cannot:
- Edit quest details
- Delete quests
- Mark as reschedule

### 4. No Notifications
Settings shows "Notifications" but no implementation for:
- Daily quest reminders
- Streak warnings
- Achievement notifications

### 5. No Real AI Integration
The "Generate with AI" is completely stubbed with hardcoded responses.

---

## Important Polish for Launch

### Missing Features:
1. **Pull-to-refresh** on Trail/Quests
2. **Search quests** functionality
3. **Quest history view** (completed quests archive)
4. **Accessibility** (semantic labels, screen reader)
5. **Localization** (English only currently)
6. **Error states** (network errors, empty states need more variety)
7. **Loading skeletons** (currently just空白)
8. **Haptic customization** (on/off toggle)
9. **Sound effects** (optional)
10. **Dark/Light mode toggle** (only dark exists)

### Animation Gaps:
- Tab transitions could be smoother
- Quest completion could have more celebration
- Level-up could show what's unlocked

### Data Gaps:
- No streak freeze mechanic
- No quest templates/presets
- No social proof (friend activity)
- No export/backup

---

## Monetization Strategy

### Tier 1: Free (Acquisition)
- Unlimited basic quests
- Single character class
- Basic stats (last 7 days)
- Local storage
- 3 AI generations per week

**Goal:** Get users hooked on the core loop

---

### Tier 2: Pro ($4.99/month or $39.99/year)
- ✨ Unlimited AI generations
- 📊 Advanced analytics (30/90/365 day views)
- ☁️ Cloud sync & backup
- 🎨 Custom accent colors (5 options)
- 📤 Export data (CSV/PDF)
- 🔔 Smart reminders (AI-suggested times)
- 🏆 All character classes
- 💾 Streak freeze (3 per month)
- 🎯 Quest templates library

**Conversion target:** 5-8% of active users

---

### Tier 3: Premium ($9.99/month or $79.99/year)
Everything in Pro, plus:
- 🤖 Advanced AI coaching (personalized plans)
- 👥 Social features (teams, challenges, leaderboards)
- 🔗 Integrations (Strava, Google Fit, Apple Health, Todoist, Notion)
- 📱 Widgets (iOS/Android)
- ⏰ Focus mode with app blocking
- 🎓 Learning paths (curated quest chains)
- 🛡️ Priority support
- 🔮 Beta features access

**Conversion target:** 2-3% of Pro users

---

### One-Time Purchases (Microtransactions)

| Item | Price | Description |
|------|-------|-------------|
| **Character Skins** | $0.99-$2.99 | Visual themes (pixel art, minimalist, etc.) |
| **Theme Packs** | $1.99 | Color schemes (Ocean, Forest, Sunset) |
| **Quest Templates** | $2.99 | Pre-made chains (Marathon Training, Reading Challenge) |
| **Streak Freeze Pack** | $0.99 | 5 streak freezes |
| **Boost XP** | $1.99 | Double XP for 24 hours |
| **Custom Badge** | $0.99 | Create your own achievement |

---

### B2B / Enterprise

| Tier | Price | Features |
|------|-------|----------|
| **Team** | $19/seat/month | Team leaderboards, shared quests, admin dashboard |
| **Corporate Wellness** | Custom pricing | Company-wide challenges, analytics, SSO |
| **API Access** | $99/month | Build custom integrations |

---

### Partnership Revenue

| Partner Type | Model | Examples |
|--------------|-------|----------|
| **Fitness Apps** | Revenue share | Strava, MyFitnessPal, Nike Run Club |
| **Learning Platforms** | Affiliate | Coursera, Duolingo, Skillshare |
| **Productivity Tools** | Integration fee | Todoist, Notion, Asana |
| **Corporate Wellness** | B2B contracts | Virgin Pulse, Wellable |

---

## Recommended Launch Strategy

### Phase 1: MVP Launch (Week 1-2)
**Fix critical issues:**
1. Fix quest persistence bug
2. Wire up real Progress data
3. Add delete/edit quests
4. Basic error handling

**Add essentials:**
- Pull-to-refresh
- Basic search
- Loading states

### Phase 2: Monetization (Week 3-4)
1. Add RevenueCat/IAP
2. Create Pro tier features
3. Add cloud sync (Firebase)
4. Implement notifications

### Phase 3: Growth (Month 2)
1. AI integration (OpenAI/Claude API)
2. Social features
3. Widgets
4. App Store optimization

### Phase 4: Scale (Month 3+)
1. B2B dashboard
2. Partnerships
3. Internationalization
4. Advanced analytics

---

## Immediate Action Items

1. **Fix persistence bug** - Critical for user retention
2. **Wire Progress screen to real data** - Users will notice fake stats
3. **Add delete/edit quests** - Basic CRUD needed
4. **Add basic search** - UX improvement
5. **Implement notifications** - Engagement driver
