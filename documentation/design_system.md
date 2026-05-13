# 4Directions Farm — Design System & UI Architecture

> **Design Principle:** A professional-grade, outdoor-first, enterprise Flutter application built for South African farming conditions.
> High contrast for bright sunlight. Tactile touch targets for gloved hands. Offline-first UI states for remote farms. Enterprise information density without complexity.

---

## 1. Design Language

### Philosophy
- **Material Design 3 (Material You)** — Dynamic colour system, expressive components, adaptive layouts
- **Outdoor-first** — High contrast ratios (WCAG AA minimum, targeting AAA for body text); large touch targets (minimum 48×48dp) for gloved or dirty hands; no fine print
- **Data-dense but scannable** — Farm dashboards must surface KPIs at a glance. Use cards, chips, and badges over tables. Hierarchy through size, weight, and colour — not decorative elements
- **Enterprise feel** — Consistent spacing grid, purposeful animation, polished micro-interactions that communicate action and state
- **SA context** — ZAR currency formatting, metric units, South African date format (DD/MM/YYYY), Afrikaans/isiZulu/Sesotho text length accommodated in layouts

### Visual Identity
| Attribute | Token | Value | Rationale |
|---|---|---|---|
| **Primary Brand** | `AppColors.primary` | Forest Green `#2E7D32` | Growth, nature, agriculture — strong outdoor contrast |
| **Primary Dark** | `AppColors.primaryDark` | Deep Green `#1A5E20` | Pressed states, gradients |
| **Primary Container** | `AppColors.primaryContainer` | Light Sage `#A5D6A7` | Subtle tints on surfaces |
| **Secondary Brand** | `AppColors.secondary` | Warm Amber `#F57F17` | Harvest, urgency, warmth — warning proximity |
| **Secondary Container** | `AppColors.secondaryContainer` | `#FFE0B2` | Amber tints |
| **Tertiary** | `AppColors.tertiary` | Sky Blue `#0277BD` | Water, clarity, measurement |
| **Tertiary Container** | `AppColors.tertiaryContainer` | `#B3E5FC` | |
| **Error** | `AppColors.error` | Deep Red `#B71C1C` | Disease alerts, critical state |
| **Error Container** | `AppColors.errorContainer` | `#FFCDD2` | Alert strip backgrounds |
| **Warning** | `AppColors.warning` | Amber `#FF8F00` | Caution, upcoming issues |
| **Warning Container** | `AppColors.warningContainer` | `#FFF3E0` | Warning strip backgrounds |
| **Success** | `AppColors.success` | Mid-Green `#388E3C` | Healthy status, completed |
| **Info** | `AppColors.info` | Teal `#00695C` | Informational states |
| **Surface** | `AppColors.surface` | Off-White `#FAFDF6` | Card backgrounds — warm, natural paper |
| **On-Surface** | `AppColors.onSurface` | Near-Black `#1A1C18` | High contrast body text |
| **Outline** | `AppColors.outline` | `#C8CBB3` | Borders, dividers |
| **Outline Variant** | `AppColors.outlineVariant` | `#E5E8D5` | Subtle card borders |

### Dark Theme
| Attribute | Value |
|---|---|
| **Primary** | Muted Sage `#81C784` |
| **Background** | `#121212` — true dark |
| **Surface** | `#1E2420` — slight green tint |
| **On-Surface** | `#E1E3DD` |
| **Card Surface** | `#252B22` |

### Species Colour Tokens
Used consistently in all species-tagged UI elements (cards, chips, avatars):
```
AppColors.cattleColor          → #5D4037  (Brown)
AppColors.cattleContainer      → #EFEBE9
AppColors.goatColor            → #827717  (Olive)
AppColors.goatContainer        → #F9FBE7
AppColors.sheepColor           → #546E7A  (Blue Grey)
AppColors.sheepContainer       → #ECEFF1
AppColors.pigColor             → #E91E63  (Pink)
AppColors.pigContainer         → #FCE4EC
AppColors.poultryColor         → #F57F17  (Amber)
AppColors.poultryContainer     → #FFF3E0
AppColors.horseColor           → #4E342E  (Dark Brown)
AppColors.horseContainer       → #EFEBE9
AppColors.rabbitColor          → #7B1FA2  (Purple)
AppColors.rabbitContainer      → #F3E5F5
AppColors.aquacultureColor     → #0277BD  (Blue)
AppColors.aquacultureContainer → #E1F5FE
AppColors.beesColor            → #F9A825  (Gold)
AppColors.beesContainer        → #FFFDE7
```

Use helpers:
```dart
AppColors.forSpecies(String species)          // Returns species primary color
AppColors.containerForSpecies(String species) // Returns container color
```

---

## 2. Typography System

**Font Family:** `Inter` — Excellent legibility at all sizes, designed for screens, available in 9 weights.
**Display / Hero Numbers:** `Plus Jakarta Sans` — Warm, modern, premium feel for large KPI values and headlines.

Both loaded via `google_fonts` package.

### Type Scale (Material 3 aligned)

| Token | Font | Size | Weight | Use |
|---|---|---|---|---|
| `displayLarge` | Plus Jakarta Sans | 57sp | 400 | Hero stats (total herd count) |
| `displayMedium` | Plus Jakarta Sans | 45sp | 400 | Section heroes |
| `displaySmall` | Plus Jakarta Sans | 36sp | 400 | Empty state titles |
| `headlineLarge` | Plus Jakarta Sans | 32sp | 600 | Page titles |
| `headlineMedium` | Plus Jakarta Sans | 28sp | 600 | Card section titles |
| `headlineSmall` | Plus Jakarta Sans | 24sp | 600 | Sub-section headers |
| `titleLarge` | Inter | 22sp | 600 | List item primaries, modal titles |
| `titleMedium` | Inter | 16sp | 600 | Card subtitles, dialog titles |
| `titleSmall` | Inter | 14sp | 600 | Chip labels, tab labels |
| `bodyLarge` | Inter | 16sp | 400 | Body copy, descriptions |
| `bodyMedium` | Inter | 14sp | 400 | List secondaries, captions |
| `bodySmall` | Inter | 12sp | 400 | Timestamps, metadata |
| `labelLarge` | Inter | 14sp | 600 | Button labels |
| `labelMedium` | Inter | 12sp | 500 | Form labels, input hints |
| `labelSmall` | Inter | 11sp | 500 | Badges, tab labels (9–11sp in nav bar) |

**SA Field Note:** Label sizes down to 9sp are acceptable for nav labels and dense data tables — farmers read these in context, not in isolation.

---

## 3. Spacing & Layout Grid

| Token | Value | Use |
|---|---|---|
| `AppSpacing.xs` | 4dp | Icon inner padding, micro gaps |
| `AppSpacing.sm` | 8dp | Between tightly related elements |
| `AppSpacing.md` | 16dp | Standard card internal padding, between cards |
| `AppSpacing.lg` | 24dp | Section separation |
| `AppSpacing.xl` | 32dp | Major section gaps |
| `AppSpacing.xxl` | 48dp | Page-level breathing room |
| `AppSpacing.pagePaddingHorizontal` | 16dp | Page edge padding |

**Touch targets:** Minimum 48×48dp. Interactive elements in lists padded to 56dp tall.
**Content max width (tablet):** 800dp — use `ConstrainedBox` on wide layouts.

---

## 4. Border Radius Tokens

| Token | Value | Use |
|---|---|---|
| `AppRadius.card` | `BorderRadius.circular(16)` | All cards, containers |
| `AppRadius.button` | `BorderRadius.circular(12)` | All buttons, chips |
| `AppRadius.input` | `BorderRadius.circular(12)` | Form fields, search bars |
| `AppRadius.chip` | `BorderRadius.circular(8)` | Filter chips, status chips |
| `AppRadius.avatar` | `BorderRadius.circular(50)` | Circle avatars |
| `AppRadius.navBar` | `BorderRadius.circular(28)` | Floating nav bar container |

---

## 5. Shadow Tokens

| Token | Use |
|---|---|
| `AppShadows.level0` | Flat surfaces |
| `AppShadows.level1` | Cards resting on surface (subtle lift) |
| `AppShadows.level2` | Floating nav bar, active elements |
| `AppShadows.level3` | FAB, center nav button, modals |
| `AppShadows.level4` | Dialogs |

---

## 6. Elevation & Surface Hierarchy

```
Page background (cs.background)
  └── Card surface (cs.surface) — AppShadows.level1
       └── Elevated card (cs.surfaceContainerLow) — subtle tint
            └── Chip / badge (cs.surfaceContainerHigh)
```

Never use raw `elevation` property — use `AppShadows.*` BoxShadow lists for precise control across light/dark themes.

---

## 7. Component Library

### Currently Implemented (`lib/shared/widgets/`)

| Widget | File | Purpose | Status |
|---|---|---|---|
| `FarmScaffold` | `farm_scaffold.dart` | Base page scaffold with safe area | ✅ |
| `FarmAppBar` | `farm_app_bar.dart` | Custom app bar with optional subtitle and actions | ✅ |
| `StatCard` | `stat_card.dart` | KPI card: icon + value + label + optional trend | ✅ |
| `SectionHeader` | `section_header.dart` | Section title + optional "View all →" action | ✅ |
| `ChartCard` | `chart_card.dart` | Card wrapper for fl_chart graphs | ✅ |
| `EmptyState` | `empty_state.dart` | Empty screen: illustration + message + CTA | ✅ |
| `LoadingShimmer` | `loading_shimmer.dart` | Skeleton shimmer loading wrapper | ✅ |
| `AlertBanner` | `alert_banner.dart` | Dismissible alert strip (error/warning/info/success) | ✅ |
| `StatusChip` | `status_chip.dart` | Coloured chip for health/production/alert status | ✅ |
| `AnimalListTile` | `animal_list_tile.dart` | Livestock record tile with avatar, status chip | ✅ |
| `SpeciesCard` | `species_card.dart` | Species selector card in Herd screen | ✅ |
| `OfflineBanner` | `offline_banner.dart` | Connectivity status strip | ✅ |
| `ConfirmDialog` | `confirm_dialog.dart` | Destructive action confirmation dialog | ✅ |
| `PrimaryButton` | `primary_button.dart` | Full-width primary CTA button | ✅ |
| `SecondaryButton` | `secondary_button.dart` | Outlined secondary action button | ✅ |
| `FarmTextField` | `farm_text_field.dart` | Styled text input with validation | ✅ |
| `FarmDropdown` | `farm_dropdown.dart` | Styled dropdown with optional search | ✅ |
| `DatePickerField` | `date_picker_field.dart` | Date input with Material date picker | ✅ |
| `AvatarWidget` | `avatar_widget.dart` | Animal/user avatar with species colour ring | ✅ |
| `BcsIndicator` | `bcs_indicator.dart` | Visual BCS score selector (1–5 or 1–9) | ✅ |
| `ProgressBar` | `progress_bar.dart` | Styled LinearProgressIndicator with label | ✅ |
| `TagCloud` | `tag_cloud.dart` | Horizontal chip list for tags/filters | ✅ |
| `KpiRow` | `kpi_row.dart` | Horizontal scrollable StatCard row | ✅ |
| `PaginatedListView` | `paginated_list_view.dart` | Lazy-loading list with page fetch | ✅ |
| `InfoSheet` | `info_sheet.dart` | Bottom sheet with info content | ✅ |
| `ErrorState` | `error_state.dart` | Error screen with retry action | ✅ |
| `IconActionButton` | `icon_action_button.dart` | Icon-only floating or inline action | ✅ |

### Screen-Level Private Widgets (Recently Added)

These components live within their respective screen files and should be promoted to shared widgets when used in 2+ screens:

| Widget | Screen | Purpose |
|---|---|---|
| `_CenterFabButton` | `app_router.dart` | Center nav FAB — green circle, 52×52dp, animated selected state |
| `_NavItem` | `app_router.dart` | Standard nav pill item with icon, fill variant, label |
| `_KpiChip` | `dashboard_screen.dart` | Compact 88×56dp KPI chip for horizontal scroll strip |
| `_ActivityTile` | `dashboard_screen.dart` | Activity feed row: icon chip + title/subtitle + timestamp |
| `_SpeciesHerdCard` | `livestock_screen.dart` | 130×116dp species card with count badge, emoji, head label |
| `_FilterChipRow` | `livestock_screen.dart` | Horizontal FilterChip scroll for herd filtering |
| `_LogTypeCard` | `record_screen.dart` | 2-column grid card for record type selection |
| `_LogEntryTile` | `record_screen.dart` | Recent log row with date group dividers |
| `_FarmHealthScoreCard` | `insights_screen.dart` | Gradient card with score + progress bar |
| `_MilkYieldChart` | `insights_screen.dart` | LineChart with mock yield data + average dashed line |
| `_HealthBreakdownCard` | `insights_screen.dart` | 3-bar health breakdown (Healthy/Alerts/Treated) |
| `_SpeciesPerformanceTable` | `insights_screen.dart` | Alternating-row species stats table |
| `_FarmProfileHeader` | `settings_screen.dart` | Farm avatar + Pro badge + stats strip |
| `_QuickBtn` | `settings_screen.dart` | Vertical icon+label quick action button |
| `_SettingsSection` | `settings_screen.dart` | Settings group with title and tile list |
| `_SettingsTile` | `settings_screen.dart` | Individual setting row: colored icon + title + optional badge |

### Widgets To Build (Phase 1 Gaps)

| Widget | Priority | Purpose |
|---|---|---|
| `FamachaScoreSelector` | High | 1–5 conjunctiva color picker with photo prompt for sheep/goats |
| `DagScoreSelector` | High | 0–5 breech soiling score selector for sheep |
| `RfidScanButton` | High | Trigger mobile_scanner for RFID/QR tag; inline in forms |
| `OfflineSyncIndicator` | High | Persistent sync queue count + last sync timestamp |
| `MovementPermitCard` | High | B313 permit preview with share/print actions |
| `WithdrawalCountdown` | Medium | Days remaining on medication withdrawal period |
| `NotifiableDiseasePrompt` | Medium | Full-screen alert when notifiable disease logged |
| `WoolRecordForm` | Medium | Shearing record fields with micron, staple, buyer |
| `AnimalSearchBar` | Medium | Debounced search across all animals with RFID scan option |
| `FmdZoneIndicator` | Low | Visual zone badge (Protected/Surveillance/Free) |
| `StudBookBadge` | Low | SA Studbook registered indicator chip |

---

## 8. Navigation Architecture

### 5-Tab Shell (GoRouter StatefulShellRoute.indexedStack)

```
Branch 0: /          → CommandScreen   (Dashboard)
Branch 1: /livestock → HerdScreen      (Livestock hub)
Branch 2: /record    → RecordScreen    (Events + Production unified) ← CENTER FAB
Branch 3: /insights  → InsightsScreen  (Analytics)
Branch 4: /settings  → FarmScreen      (Settings / Farm profile)
```

### Bottom Nav Pattern: Center FAB

The center item (Record, index 2) uses the Instagram/Twitter FAB pattern:
- **Unselected:** 52×52dp green circle (`AppColors.primary`), `Icons.add_rounded` (size 26), `AppShadows.level3`
- **Selected:** 52×52dp dark green circle (`Color(0xFF1A5E20)`), `Icons.edit_note_rounded` (size 26), `AppShadows.level2`
- Animated with `AnimatedContainer` 220ms `Curves.easeInOut`
- "Record" label below (9sp, `FontWeight.w700` when selected)

Regular nav items use `_NavItem`:
- Unselected: outline icon, `onSurfaceVariant` color
- Selected: filled icon + `AppColors.primary.withAlpha(22)` pill background, 18dp border radius
- Label: 9sp, `FontWeight.w700` when selected

### Sub-Routes

```
/livestock
  /:species                    → SpeciesListScreen
  /:species/add                → AddEditAnimalScreen
  /:species/:id                → AnimalDetailScreen
  /:species/:id/edit           → AddEditAnimalScreen
  /groups                      → GroupsScreen
  /groups/add                  → AddEditGroupScreen
  /groups/:groupId             → GroupDetailScreen
  /groups/:groupId/edit        → AddEditGroupScreen

/record
  /health                      → HealthEventsScreen
  /health/add                  → AddHealthEventScreen
  /weight                      → WeightRecordsScreen
  /weight/add                  → AddWeightRecordScreen
  /breeding                    → BreedingEventsScreen
  /breeding/add                → AddBreedingEventScreen
  /milk                        → MilkRecordsScreen
  /milk/add                    → AddMilkRecordScreen
  /eggs                        → EggRecordsScreen
  /eggs/add                    → AddEggRecordScreen
  /alerts                      → AlertsScreen

/insights
  /reports                     → ReportsScreen

/settings
  /farm                        → FarmSettingsScreen
  /account                     → AccountSettingsScreen
  /notifications               → NotificationSettingsScreen
  /theme                       → ThemeSettingsScreen
```

---

## 9. Screen Design Specifications

### Command Screen (Dashboard)

**Purpose:** Farm command centre — urgency hierarchy first, then snapshot, then KPIs.

**Layout (CustomScrollView):**
1. `_UrgentAlertsStrip` — `errorContainer` background strip, only visible when `recentHealthAlerts > 0`
2. `_TodaySnapshotCard` — Green gradient hero card: farm name, weather chip, location, date, tasks pending pill
3. `_KpiScrollStrip` — 88dp wide KPI chips, horizontal scroll: Animals, Alerts, Breeding, Species, Healthy Rate
4. Quick Actions — 2×2 grid: Add Animal, Log Event, Insights, Alerts
5. Herd Overview — 130×116dp species cards horizontal scroll
6. Farm Activity Feed — 5 recent events with colored icon chips

### Herd Screen (Livestock)

**Purpose:** Full herd visibility with quick access to any species.

**Layout (CustomScrollView with slivers):**
1. `_HerdHealthBanner` — amber warning strip (only when alerts > 0)
2. `_SearchBar` — 44dp `TextField` in `surfaceContainerLow` container
3. `_FilterChips` — horizontal FilterChip scroll: All / Alerts / Active / Pregnant / Overdue
4. `_SpeciesGrid` — horizontal 130dp species cards with count badge and "X head" label
5. `_GroupsCard` — tertiary-colored groups card with border and shadow

**FAB:** `FloatingActionButton.extended` — "Add Animal" — `AppColors.primary`

### Record Screen (Events + Production Hub)

**Purpose:** Single tap to any record type from one screen.

**Layout:**
1. `_LogTypeGrid` — 2×4 GridView, `childAspectRatio: 1.65`, 8 log type cards
2. Recent Logs section — grouped by Today/Yesterday with `SectionHeader` date dividers
3. Each log tile: leading colored icon chip + title/subtitle + timestamp

**Log types:**
| Type | Icon | Color | Route |
|---|---|---|---|
| Health Event | `health_and_safety_rounded` | `AppColors.error` | `/record/health` |
| Weight Record | `monitor_weight_rounded` | `AppColors.tertiary` | `/record/weight` |
| Breeding Event | `favorite_rounded` | `#E91E63` | `/record/breeding` |
| Milk Record | `water_drop_rounded` | `AppColors.primary` | `/record/milk` |
| Egg Record | `egg_rounded` | `AppColors.secondary` | `/record/eggs` |
| Alerts | `notifications_active_rounded` | `AppColors.warning` | `/record/alerts` |
| Move Animal | `move_down_rounded` | `#795548` | Coming soon |
| Feed Log | `inventory_2_rounded` | `#388E3C` | Coming soon |

### Insights Screen (Analytics)

**Purpose:** Farm health score, financial KPIs, production trends, species performance.

**Layout (ListView):**
1. Period selector — animated chips: Week / Month / Quarter / Year
2. `_FarmHealthScoreCard` — green gradient, dynamic score (calculated from summary), progress bar
3. `_FinancialKpiRow` — 3 `StatCard` widgets: Revenue / Cost / Margin
4. `_MilkYieldChart` — `ChartCard` wrapping `LineChart` with 7 data points + dashed average line
5. `_HealthBreakdownCard` — 3 `LinearProgressIndicator` rows with labels
6. `_SpeciesPerformanceTable` — alternating rows, species emoji + head count + alerts
7. `_UpcomingEventsCard` — 3 upcoming events with day-of-week badge chips

**Reports button in AppBar** → `/insights/reports`

### Farm Screen (Settings)

**Purpose:** Farm identity, quick team actions, settings navigation.

**Layout:**
1. `_FarmProfileHeader` — gradient card: avatar + farm name + province + Pro badge + stats strip (Animals / Team / Paddocks)
2. `_QuickActionsRow` — 3 `_QuickBtn`: Edit Profile / Manage Team / Upgrade (accent: secondary)
3. Settings sections:
   - **Farm Management:** Farm Profile, Paddocks (placeholder), Breed Registry (placeholder)
   - **Team & Access:** Users & Roles, Activity Log (placeholder)
   - **Preferences:** Notifications, Units, Appearance
   - **Data & Compliance:** Sync & Backup, Export Data
   - **App:** Version, Privacy Policy, Terms, Help & Support

---

## 10. State Management Patterns

### Provider Types Used

| Provider Type | When To Use |
|---|---|
| `Provider<T>` | Services, constants, GoRouter |
| `FutureProvider<T>` | One-time async loads (initial data fetch) |
| `NotifierProvider<T, S>` | Complex state with methods (edit forms, complex screens) |
| `AutoDisposeNotifierProvider<T, S>` | Screen-scoped state that clears on exit |
| `StateProvider<T>` | Simple reactive values (filter index, toggle) — prefer NotifierProvider for complex logic |

### Existing Key Providers

| Provider | Location | Purpose |
|---|---|---|
| `dashboardSummaryProvider` | `dashboard/providers/dashboard_providers.dart` | Farm summary data (total animals, species breakdown, recent alerts) |
| `authProvider` | `auth/providers/auth_provider.dart` | Auth state (bool — logged in/out) |
| `routerProvider` | `core/router/app_router.dart` | GoRouter instance with auth redirect |
| `_herdFilterProvider` | `livestock/screens/livestock_screen.dart` | Filter index for herd screen (0–4) |

### Naming Conventions
- Providers: `camelCaseProvider` (e.g., `dashboardSummaryProvider`)
- Notifiers: `PascalCaseNotifier` (e.g., `HerdFilterNotifier`)
- State: Use sealed classes or enums for `AsyncValue` wrapping in complex providers

---

## 11. Animation & Micro-interactions

| Context | Animation | Duration | Notes |
|---|---|---|---|
| Screen transitions | Shared axis horizontal | 300ms | GoRouter default |
| Card appears | Fade + slide up 8dp | 200ms | `AnimatedOpacity` |
| Nav item selection | `AnimatedContainer` | 220ms `easeInOut` | Pill expand + color |
| Center FAB selection | `AnimatedContainer` | 220ms `easeInOut` | Color + icon swap |
| Stat counter | Number tween | 800ms | `TweenAnimationBuilder<double>` |
| Loading state | Shimmer sweep | 1200ms loop | `LoadingShimmer` widget |
| Alert banner | Slide down | 250ms | `AnimatedSlide` |
| FAB scale | Scale bounce | 200ms | `ScaleTransition` |
| FilterChip selection | Background color | 180ms | Built-in Material |
| Success feedback | Lottie check | 600ms | `lottie` package |

All animations respect `MediaQuery.disableAnimations`.

---

## 12. Offline UI States

Every data-driven screen must handle all four states:

| State | Widget | Visual |
|---|---|---|
| **Loading** | `LoadingShimmer` | Skeleton layout matching actual content shape |
| **Data** | Normal content | — |
| **Empty** | `EmptyState` | Icon + title + message + primary CTA button |
| **Error** | `ErrorState` | Error icon + message + "Retry" button |

Persistent offline indicator: `OfflineBanner` — shows when `ConnectivityResult.none`. Never block UI — all data reads from local cache; banner is informational only.

### Offline Queue Visual
When RMIS or API sync is pending, show a persistent subtle chip in the app bar:
```
[⟳ 3 pending syncs]
```
Tapping opens a sync queue bottom sheet with pending record count per type.

---

## 13. Forms & Input Design

### Form Field Standards
- All inputs use `FarmTextField` — includes label, hint, validation, error message
- Date fields: `DatePickerField` — calendar popup with DD/MM/YYYY format (SA standard)
- Dropdowns: `FarmDropdown` — Material dropdown with optional type-to-search
- Required fields: `*` suffix on label, validated on submit (not on every keystroke)
- Currency fields: ZAR prefix (R), comma thousand separator, 2 decimal places

### Multi-Step Forms
Complex forms (Add Animal, Log Health Event) use a step indicator:
```
Step 1 of 3: Basic Info → Step 2 of 3: Identity → Step 3 of 3: Health Status
```
- Progress via `LinearProgressIndicator` at top
- Back/Next buttons at bottom; Submit only on final step
- Draft auto-saved to local DB after each step

### RFID / QR Scan Integration
Every `tagNumber` / `rfidNumber` field has a scan button inline:
```dart
FarmTextField(
  label: 'RFID / Tag Number',
  suffix: IconButton(
    icon: Icon(Icons.qr_code_scanner_rounded),
    onPressed: () => _scanTag(context, ref),
  ),
)
```

---

## 14. Responsive Design

| Breakpoint | Width | Layout |
|---|---|---|
| Mobile (primary) | < 600dp | Single column, floating bottom nav |
| Tablet | 600–900dp | Two columns, navigation rail (left) |
| Desktop / Web | > 900dp | Three columns, nav drawer |

`AdaptiveLayout` widget wraps content; `LayoutBuilder` determines breakpoint. Mobile is the primary design target — tablet/desktop are progressive enhancements.

---

## 15. Accessibility Standards

- All interactive elements have `semanticsLabel` set
- Minimum contrast ratio 4.5:1 (WCAG AA) — targeting 7:1 for body text
- All touch targets minimum 48×48dp
- Screen reader compatible — `Semantics` widgets on custom components
- Font scaling support up to 1.5× (test all layouts at 1.3× and 1.5×)
- `MediaQuery.disableAnimations` respected everywhere
- High-contrast mode support via theme override
- Colour is never the sole indicator of meaning (always paired with icon or text)

---

## 16. Iconography

**Primary:** Material Symbols Rounded — `material_symbols_icons` package v4.2928+
- Rounded style for warm, approachable feel
- Fill variant (`Icons.*_rounded` with filled style) for selected/active states
- Default weight 400; 600 for emphasis

**Custom SVG Icons** (for species not well represented in Material Symbols):
```
assets/icons/livestock/
  cattle.svg, goat.svg, sheep.svg, pig.svg,
  poultry.svg, horse.svg, rabbit.svg, fish.svg, bee.svg

assets/icons/farm/
  farm_house.svg, field.svg, tractor.svg,
  weather.svg, finance.svg, task.svg, brand.svg, rfid.svg
```

Rendered via `flutter_svg`. All use `currentColor` for theme adaptation.

**Species Emoji Fallback:** For quick implementation in cards/lists, species are also represented by emoji:
```
🐄 Cattle  🐐 Goats  🐑 Sheep  🐷 Pigs  🐔 Poultry
🐴 Horses  🐇 Rabbits  🐟 Aquaculture  🐝 Bees
```

---

## 17. Package Stack

### Runtime Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^3.3.1 | State management |
| `go_router` | ^17.2.3 | Declarative navigation + deep linking |
| `google_fonts` | ^8.1.0 | Inter + Plus Jakarta Sans |
| `material_symbols_icons` | ^4.2928.1 | Extended icon library |
| `flutter_svg` | ^2.3.0 | SVG asset rendering |
| `fl_chart` | ^1.2.0 | Line, bar, pie, radar charts |
| `cached_network_image` | ^3.4.1 | Network image caching |
| `shimmer` | ^3.0.0 | Skeleton loading |
| `intl` | ^0.20.2 | Date/number formatting, i18n |
| `equatable` | ^2.0.7 | Value equality for models |
| `connectivity_plus` | ^6.1.4 | Offline detection |
| `flutter_local_notifications` | ^19.0.1 | Vaccination/event reminders |
| `mobile_scanner` | ^7.0.1 | RFID/QR/barcode scanning |
| `image_picker` | ^1.1.2 | Camera/gallery photo capture |
| `path_provider` | ^2.1.5 | File system paths |
| `shared_preferences` | ^2.3.5 | Key-value persistence (theme, settings) |
| `drift` | ^2.23.1 | SQLite ORM — offline-first data layer |
| `sqlite3_flutter_libs` | ^0.5.26 | SQLite native libraries |
| `dio` | ^5.8.0 | HTTP client for API calls |
| `pdf` | (to add) | Movement permit and report PDF generation |
| `share_plus` | (to add) | Share PDFs via WhatsApp, email |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `riverpod_generator` | ^4.0.3 | Provider code generation |
| `build_runner` | ^2.4.15 | Code generation runner |
| `freezed` | ^3.0.0 | Immutable model code generation |
| `json_serializable` | ^6.9.5 | JSON serialization |
| `drift_dev` | ^2.23.1 | Drift schema code generation |
| `flutter_lints` | ^6.0.0 | Lint rules |
| `mocktail` | ^1.0.4 | Mocking for unit tests |

---

## 18. Theming Architecture

```dart
// Correct pattern — always use tokens, never hard-code:
Theme.of(context).colorScheme.primary     // ✅
AppColors.primary                          // ✅ (wraps colorScheme)
const Color(0xFF2E7D32)                    // ❌ never hard-code hex in widgets

Theme.of(context).textTheme.titleMedium   // ✅
AppSpacing.md                              // ✅
AppRadius.card                             // ✅
```

Theme switching (light ↔ dark) controlled by Riverpod `themeNotifier` provider, persisted via `shared_preferences`. Users can also follow system theme (`ThemeMode.system`).

---

_Document version 2.0 — Updated with full component inventory post-redesign (Command, Herd, Record, Insights, Farm screens), SA-specific design notes, and new widget specifications. Previous version 1.0 archived._
