# AeroBrew Performance & Code Quality Analysis

> Generated: 2026-03-04
> Scope: Full codebase review (23 Swift files, ~1,430 LOC)

---

## Table of Contents

1. [Performance Issues](#1-performance-issues)
2. [Memory & Resource Issues](#2-memory--resource-issues)
3. [App Store Review Risks](#3-app-store-review-risks)
4. [Code Smells & Anti-Patterns](#4-code-smells--anti-patterns)
5. [Dead Code & Unused Imports](#5-dead-code--unused-imports)
6. [Inconsistent Naming Conventions](#6-inconsistent-naming-conventions)
7. [Components That Should Be Split](#7-components-that-should-be-split)
8. [Missing Error Handling](#8-missing-error-handling)
9. [Summary Priority Matrix](#9-summary-priority-matrix)

---

## 1. Performance Issues

### 1.1 `sortedSteps` Re-sorts on Every Access
**File:** `Recipe.swift:88-90` | **Severity:** Medium

```swift
var sortedSteps: [Step] {
    steps.sorted { $0.order < $1.order }
}
```

Called from `RecipeCardView`, `RecipeDetailView`, `BrewView`, and `BrewStepView`. Each access creates a new sorted array.

**Fix:** Cache the sorted result or store steps pre-sorted in SwiftData.

---

### 1.2 `favoriteRecipes` Filters Full Array on Every Access
**File:** `RecipeStore.swift:11-13` | **Severity:** Low

```swift
var favoriteRecipes: [Recipe] {
    allRecipes.filter { $0.isFavorite }
}
```

With `@Observable`, any view reading `favoriteRecipes` will also observe `allRecipes`, causing re-renders even when unrelated recipes change.

**Fix:** Maintain a separate cached `favoriteRecipes` array, updated in `fetchRecipes()`.

---

### 1.3 Deprecated `UIScreen.main.bounds`
**File:** `BrewStepView.swift:17` | **Severity:** Low

```swift
.frame(height: UIScreen.main.bounds.height * 0.42)
```

`UIScreen.main` is deprecated since iOS 16. Does not adapt to multitasking or external displays.

**Fix:** Use `GeometryReader` or `.containerRelativeFrame()`.

---

### 1.4 `UIImpactFeedbackGenerator` Re-allocated on Every Tap
**Files:** `RecipeDetailView.swift:144`, `BrewView.swift:31,75,102`, `BrewCompleteSheet.swift:30`, `FavoriteButton.swift:9` | **Severity:** Low-Medium

```swift
UIImpactFeedbackGenerator(style: .light).impactOccurred()
```

Creates a new generator instance per tap. Generators should be pre-allocated and reused.

**Fix:** Store as a `static let` or `@State` property.

---

### 1.5 `RelativeDateTimeFormatter` Created Per Cell Render
**File:** `TimeInterval+Format.swift:23-28` | **Severity:** Low-Medium

```swift
var relativeFormatted: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "hr-HR")
    ...
}
```

Formatters are expensive to create. Called for every history row on every render.

**Fix:** Use a `static let` cached formatter.

---

### 1.6 `AsyncImage` Has No Disk Cache
**Files:** `RecipeCardView.swift:9`, `RecipeDetailView.swift:56`, `BrewStepView.swift:11` | **Severity:** High

`AsyncImage` re-fetches from the network every time a view appears. The same Unsplash URLs are loaded repeatedly across card → detail → brew transitions.

**Fix:** Implement a custom image loader with `NSCache` + `URLCache`, or bundle images locally.

---

## 2. Memory & Resource Issues

### 2.1 No `onDisappear` Cleanup in `BrewView`
**File:** `BrewView.swift` | **Severity:** Medium

`BrewView` configures the timer in `onAppear` but never cleans up on dismiss. If the user exits mid-brew, the `DispatchSourceTimer` continues running until `deinit`, doing unnecessary main-thread work.

**Fix:** Add `.onDisappear { timerService.reset() }`.

---

### 2.2 `@Namespace` Allocated but Never Used
**File:** `TimerView.swift:6` | **Severity:** Low

```swift
@Namespace private var namespace
```

Declared but never referenced. Wasted resource.

**Fix:** Remove the line.

---

## 3. App Store Review Risks

### 3.1 BLOCKER: Missing App Icon
**File:** `Assets.xcassets/AppIcon.appiconset/Contents.json`

The AppIcon set declares a 1024×1024 slot but has **no `filename`** — no icon image exists. Apple **will reject** the submission.

**Fix:** Add a 1024×1024 PNG app icon.

---

### 3.2 BLOCKER: Placeholder Bundle ID
**File:** `project.yml:24`

```yaml
PRODUCT_BUNDLE_IDENTIFIER: com.yourname.aeropressguide
```

`com.yourname` is a placeholder. Must be replaced with your real Apple Developer team prefix.

---

### 3.3 HIGH: Forced Light Mode
**File:** `AeroPressGuideApp.swift:30`

```swift
.preferredColorScheme(.light)
```

Apple reviewers expect apps to respect system appearance unless there's a clear design reason. May be flagged.

**Fix:** Support dark mode or provide a user-facing toggle.

---

### 3.4 HIGH: English UI vs Croatian Spec
**Files:** Multiple

CLAUDE.md specifies Croatian (hr-HR) for all UI text, but every string is in English:
- Tab labels: "Recipes", "Favorites", "History"
- Completion: "Coffee is Ready!", "Save", "Skip"
- Timer: "Start", "Resume", "Done!"
- Navigation: "Next", "Finish", "Back"
- Empty states: "No Favorites", "No History Yet"
- Difficulty: "Beginner", "Intermediate", "Advanced"
- Method: "Standard", "Inverted"

**Fix:** Localize all user-facing strings to Croatian, or update the spec.

---

### 3.5 MEDIUM: No Privacy Manifest
**Severity:** Medium

Apple requires `PrivacyInfo.xcprivacy` for apps using certain APIs (networking, file timestamps, user defaults). The app makes network requests via `AsyncImage`.

**Fix:** Add a `PrivacyInfo.xcprivacy` file.

---

### 3.6 MEDIUM: External Unsplash URLs With No Fallback
**File:** `SeedData.swift` (all `imageURL` values)

All step images are remote Unsplash URLs:
- Requires internet for any images
- Subject to Unsplash rate limits
- Apple reviewers testing offline see only blank placeholders
- URLs may break if Unsplash changes their CDN

**Fix:** Bundle essential images locally or provide meaningful SF Symbol fallbacks.

---

### 3.7 LOW-MEDIUM: `fatalError` on SwiftData Init
**File:** `AeroPressGuideApp.swift:15`

```swift
fatalError("SwiftData container error: \(error)")
```

If the database is corrupted or migration fails, the app crashes on launch with no recovery path.

**Fix:** Attempt recovery (delete & recreate the store), or show an error UI.

---

### 3.8 MEDIUM: No Accessibility Support
**Severity:** Medium

No `accessibilityLabel`, `accessibilityHint`, or `accessibilityValue` modifiers anywhere. Affected areas:
- Timer display (VoiceOver can't read countdown state)
- Star rating (no label per star)
- Progress dots (purely visual)
- Custom buttons with only icons
- Difficulty badges

**Fix:** Add accessibility modifiers to all interactive and informational elements.

---

## 4. Code Smells & Anti-Patterns

### 4.1 Silent Error Swallowing (`try?`)
**Files:** `RecipeStore.swift:24,29,38,44`, `BrewSessionStore.swift:18,25,31`

Every SwiftData operation silently discards errors:
```swift
try? modelContext.save()
```

If a save fails, the user gets no feedback. Favorites, history entries, and custom recipes could be silently lost.

**Fix:** Log errors at minimum. Ideally propagate failures to the UI.

---

### 4.2 Dead Method: `isFavorite(_:)`
**File:** `RecipeStore.swift:32-34`

```swift
func isFavorite(_ recipe: Recipe) -> Bool {
    recipe.isFavorite
}
```

Never called anywhere. Just wraps a public property.

**Fix:** Delete the method.

---

### 4.3 Manual String IDs Alongside SwiftData
**File:** `Recipe.swift:40`

Using `var id: String` with manual `UUID().uuidString` alongside SwiftData's built-in `PersistentIdentifier`. Creates ambiguity about which is the canonical identity.

**Fix:** Use SwiftData's native identity or mark your `id` with `@Attribute(.unique)`.

---

### 4.4 Denormalized `recipeName` in `BrewSession`
**File:** `BrewSession.swift:8-9`

```swift
var recipeID: String
var recipeName: String
```

Duplicates the recipe name instead of using a `@Relationship`. Recipe renames won't update history. This may be intentional (history survives recipe deletion), but should be documented.

---

### 4.5 Inconsistent Color References
**Files:** Multiple

Two systems exist:
- `Color("BrandPrimary")` — string-based, used everywhere
- `Color.brandPrimary` — extension in `Color+Brand.swift`, used nowhere

**Fix:** Pick one approach and use it consistently. Delete the unused one.

---

## 5. Dead Code & Unused Imports

| Item | File | Type |
|------|------|------|
| `Color+Brand.swift` (entire file) | `Extensions/Color+Brand.swift` | Extension defined but never used |
| `isFavorite(_:)` method | `RecipeStore.swift:32-34` | Never called |
| `@Namespace private var namespace` | `TimerView.swift:6` | Declared, never used |
| `Tab: CaseIterable` conformance | `RootView.swift:3` | `Tab.allCases` never used |
| `import Observation` | `RecipeStore.swift:3`, `BrewSessionStore.swift:3` | `@Observable` is available via `import Foundation`; explicit import not strictly needed |

---

## 6. Inconsistent Naming Conventions

| Issue | Location | Notes |
|-------|----------|-------|
| `stepDescription` vs `description` | `Step.swift:9` | Named to avoid `CustomStringConvertible` clash, but non-obvious |
| Single-letter parameter names | `BrewCompleteSheet.swift:71` | `save(withRating r: Int?, notes n: String?)` — hurts readability |
| `formattedTime` vs `formattedDuration` | `TimeInterval+Format.swift` | Two similar methods, easy to confuse |
| Mixed language intent | Spec says Croatian, code is English | Needs resolution |
| `displayName` vs `localizedName` | `BrewMethod` vs `Difficulty` | Same concept, different property names |

---

## 7. Components That Should Be Split

### 7.1 `RecipeDetailView` (162 lines)
Handles hero image, content, steps preview, and bottom bar. Split into:
- `RecipeHeroImageView`
- `RecipeStepsPreviewView`
- `RecipeDetailBottomBar`

### 7.2 `HistoryRowView` Embedded in `HistoryView`
**File:** `HistoryView.swift:28-74`

Extract `HistoryRowView` to its own file for consistency.

### 7.3 `ParameterCell` Embedded in `ParameterGridView`
**File:** `ParameterGridView.swift:28-47`

Extract `ParameterCell` to its own file or keep but document.

---

## 8. Missing Error Handling

| Location | Issue |
|----------|-------|
| `AeroPressGuideApp.swift:15` | `fatalError` on SwiftData init — app crashes with no recovery |
| `RecipeStore.swift:24` | Fetch failure returns empty array silently |
| `RecipeStore.swift:29,38,44` | Save/delete failures silently ignored |
| `BrewSessionStore.swift:18,25,31` | Same silent failure pattern |
| `AeroPressGuideApp.swift:40` | Seed save failure ignored — user gets empty app forever |
| `AsyncImage` (multiple files) | No error state — failed loads show placeholder with no retry option |
| `BrewView` | No guard for empty `steps` array (would crash on force-unwrap) |
| `TimerView` | No guard for `duration <= 0` |

---

## 9. Summary Priority Matrix

| Priority | Issue | Category |
|----------|-------|----------|
| **BLOCKER** | Missing App Icon | App Store |
| **BLOCKER** | Placeholder bundle ID (`com.yourname`) | App Store |
| **HIGH** | No image caching (`AsyncImage`) | Performance |
| **HIGH** | External Unsplash URLs, no offline fallback | App Store / UX |
| **HIGH** | Forced light mode only | App Store |
| **HIGH** | English UI vs Croatian spec | Spec violation |
| **HIGH** | No accessibility support | App Store / Legal |
| **MEDIUM** | Silent `try?` error swallowing | Data integrity |
| **MEDIUM** | No privacy manifest | App Store |
| **MEDIUM** | `sortedSteps` re-sorts every access | Performance |
| **MEDIUM** | No `onDisappear` timer cleanup | Memory |
| **MEDIUM** | Haptic generators re-allocated per tap | Performance |
| **MEDIUM** | `RelativeDateTimeFormatter` per cell | Performance |
| **MEDIUM** | `fatalError` on DB init failure | Crash risk |
| **LOW** | Dead code (`Color+Brand.swift`, `isFavorite`, `@Namespace`) | Code quality |
| **LOW** | Deprecated `UIScreen.main` | Future compat |
| **LOW** | Inconsistent color reference style | Maintainability |
| **LOW** | Single-letter parameter names | Readability |
| **LOW** | `RecipeDetailView` too large | Maintainability |
