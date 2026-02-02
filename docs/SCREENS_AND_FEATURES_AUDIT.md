# Couplr — Screens & Features Audit

A concise audit of which screens are design-complete, which need the warm UI refresh, and what functionality is still placeholder or incomplete.

---

## 1. Screens with warm design applied ✅

These screens use the **welcome gradient background**, **transparent app bar** (where applicable), and **cohesive palette** (blush rose, sage, cream).

| Screen | Route | Notes |
|--------|-------|--------|
| **Home** | `/home` | Dashboard, couple score, conflict sense, talk-and-it-types, explore grid |
| **More** | `/more` | Gradient, friendly copy, card tiles with accent icons |
| **Profile** | `/profile` | Gradient, profile header with border, settings card |
| **Notifications settings** | `/profile/notifications` | Gradient, toggles for reminders & quiet hours |
| **Privacy settings** | `/profile/privacy` | Gradient, journal visibility sheet + analytics toggle |
| **Account settings** | `/profile/account` | Gradient, email/password/partner tiles |
| **About** | `/profile/about` | Gradient, version + Terms/Privacy/Support (url_launcher) |
| **Journal** | `/journal` | Gradient, filters (primary selected), entry cards with tags & border |
| **Journal entry detail** | `/journal/entry/:id` | ✅ Warm |
| **Journal calendar** | `/journal/calendar` | ✅ Warm |
| **Journal new entry** | `/journal/new` | ✅ Warm, photo picker + voice note (image_picker, record) |
| **Community** | `/community` | Gradient, header copy, room cards with per-room accent |
| **Forum room** | `/community/room/:id` | ✅ Warm |
| **Thread detail** | `/community/thread/:id` | ✅ Warm |
| **Saved threads** | `/community/saved` | ✅ Warm |
| **Things to do** | `/things-to-do` | Gradient, Individual / Couple tabs |
| **Talk (Guided conversation)** | `/talk` | Gradient, conversation list |
| **Conflict resolution hub** | `/talk/repair` | Gradient, status and CTAs |
| **Conflict private input** | `/talk/repair/input` | Gradient, form for feelings/triggers |
| **Conflict cooling** | `/talk/repair/cooling` | ✅ Warm |
| **Conflict joint session** | `/talk/repair/session` | Gradient, step-by-step guided flow |
| **Conflict dashboard** | `/talk/conflict-dashboard` | Gradient, history and streaks |
| **Grow** | `/grow` | ✅ Warm |
| **Habit challenges** | `/grow/challenges` | ✅ Warm |
| **Ritual scheduler** | `/grow/rituals` | ✅ Warm |
| **Date planner** | `/grow/dates` | ✅ Warm |
| **Experts** | `/experts` | ✅ Warm |
| **Ask expert** | `/experts/ask` | ✅ Warm |
| **My questions** | `/experts/questions` | ✅ Warm |
| **Live room** | `/experts/live/:id` | ✅ Warm, “Coming soon” state |
| **Insights** | `/insights` | ✅ Warm |
| **Paywall** | `/paywall` | ✅ Warm (gradient behind blur) |

---

## 2. Screens still needing design refresh 🎨 (optional)

Applying the same warm gradient + transparent app bar would align these with the rest of the app.

| Screen | Route | Current state |
|--------|-------|----------------|
| **Splash** | `/splash` | Custom gradient + pulse; could align with `welcomeGradientLight` |
| **Onboarding** | `/onboarding` | Carousel; uses theme but no shared gradient wrapper |
| **Auth** | `/auth` | Login/signup; no gradient |
| **Partner link** | `/partner-link` | QR/link flow; no gradient |

---

## 3. Placeholder or incomplete features ⚠️

### Done ✅

- **About screen** — Terms, Privacy, Support open via `url_launcher` (couplr.app/terms, /privacy, /support).
- **Privacy settings** — Journal visibility bottom sheet (Only me / Partner / Both) + analytics toggle with SharedPreferences persistence.
- **Journal new entry** — Photo picker (`image_picker`) and voice note recording (`record`); paths stored on entry.
- **Experts live room** — “Coming soon” state with warm design.
- **Cleanup** — `HomePlaceholderScreen` and `ConflictRepairScreen` removed (router uses `HomeScreen` and `ConflictResolutionHubScreen`).

### Remaining (optional)

- **Talk and it types (Home)** — Voice input is mock STT. Option: integrate real STT or keep mock and document in code/comments.
- **Data & export** (Privacy) — Tile present; full “Download or delete your data” flow not implemented.

---

## 4. Suggested next steps (priority order)

1. **Optional design refresh (low)**  
   Apply warm gradient to Auth flow if desired: Splash, Onboarding, Auth, Partner link.

2. **Optional feature**  
   Real STT for “Talk and it types” or document mock behavior.  
   Implement “Data & export” flow in Privacy if required.

---

## 5. Quick reference — all routes

| Route | Screen | Design status |
|-------|--------|----------------|
| `/splash` | SplashScreen | Custom (optional align) |
| `/onboarding` | OnboardingScreen | No gradient |
| `/auth` | AuthScreen | No gradient |
| `/partner-link` | PartnerLinkScreen | No gradient |
| `/home` | HomeScreen | ✅ Warm |
| `/talk` | GuidedConversationScreen | ✅ Warm |
| `/talk/session/:id` | GuidedConversationSessionScreen | ✅ (nested in Talk) |
| `/talk/repair` | ConflictResolutionHubScreen | ✅ Warm |
| `/talk/repair/input` | ConflictPrivateInputScreen | ✅ Warm |
| `/talk/repair/cooling` | ConflictCoolingScreen | ✅ Warm |
| `/talk/repair/session` | ConflictJointSessionScreen | ✅ Warm |
| `/talk/conflict-dashboard` | ConflictDashboardScreen | ✅ Warm |
| `/grow` | GrowScreen | ✅ Warm |
| `/grow/challenges` | HabitChallengesScreen | ✅ Warm |
| `/grow/rituals` | RitualSchedulerScreen | ✅ Warm |
| `/grow/dates` | DatePlannerScreen | ✅ Warm |
| `/journal` | JournalScreen | ✅ Warm |
| `/journal/entry/:id` | JournalEntryDetailScreen | ✅ Warm |
| `/journal/calendar` | JournalCalendarScreen | ✅ Warm |
| `/journal/new` | JournalNewEntryScreen | ✅ Warm |
| `/more` | MoreScreen | ✅ Warm |
| `/profile` | ProfileScreen | ✅ Warm |
| `/profile/notifications` | NotificationsSettingsScreen | ✅ Warm |
| `/profile/privacy` | PrivacySettingsScreen | ✅ Warm |
| `/profile/account` | AccountSettingsScreen | ✅ Warm |
| `/profile/about` | AboutScreen | ✅ Warm |
| `/community` | CommunityScreen | ✅ Warm |
| `/community/room/:id` | ForumRoomScreen | ✅ Warm |
| `/community/thread/:id` | ThreadDetailScreen | ✅ Warm |
| `/community/saved` | SavedThreadsScreen | ✅ Warm |
| `/experts` | ExpertsScreen | ✅ Warm |
| `/experts/ask` | AskExpertScreen | ✅ Warm |
| `/experts/questions` | MyQuestionsScreen | ✅ Warm |
| `/experts/live/:id` | LiveRoomScreen | ✅ Warm (Coming soon) |
| `/paywall` | PaywallScreen | ✅ Warm |
| `/insights` | InsightsScreen | ✅ Warm |
| `/things-to-do` | ThingsToDoScreen | ✅ Warm |

---

*Last updated after completing design refresh, placeholder wiring, journal media, cleanup, and audit suggestions.*
