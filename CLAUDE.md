# AeroPress Brew Guide – Native iOS (Swift / SwiftUI)
## Instructions for Claude Code

This document is the **entry point** for rebuilding the AeroPress Brew Guide app from scratch in native Swift/SwiftUI targeting iOS 26+. Read all referenced documents before writing any code.

---

## Document Index

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file — start here |
| `ARCHITECTURE.md` | App structure, data flow, file tree |
| `LIQUID_GLASS_GUIDE.md` | How to use Liquid Glass APIs correctly |
| `DATA_MODELS.md` | All Swift data models (direct port from TypeScript) |
| `SCREENS.md` | Every screen: layout, components, behaviour |
| `IMPLEMENTATION_GUIDE.md` | Step-by-step build order with code examples |

---

## Project Summary

**App name:** AeroPress Brew Guide  
**Platform:** iOS 26+ only (iPhone)  
**Language:** Swift 6, SwiftUI  
**Xcode:** 26+  
**Deployment target:** iOS 26.0  

**Core features to implement:**
1. Recipe list (predefined recipes + custom)
2. Recipe detail with parameters
3. Interactive brew guide (step-by-step with swipe navigation)
4. Countdown timers — **NEVER auto-start, always manual**
5. Favorites
6. Brew history with rating + notes
7. Liquid Glass UI throughout

---

## Non-Negotiable Rules

1. **Timers NEVER start automatically.** The user must tap to start every timer.
2. **iOS 26+ only.** Do not add any iOS 17/18 fallbacks or `#available` guards for Liquid Glass APIs.
3. **No third-party dependencies.** Pure Apple frameworks only: SwiftUI, SwiftData, Foundation, Combine (if needed).
4. **SwiftData for persistence** — replaces AsyncStorage.
5. **`@Observable`** macro for all state objects — not `ObservableObject`.
6. **Liquid Glass only on navigation/control layer**, never on content list cells.
7. All UI text stays in **Croatian** (hr-HR) to match the original app.

---

## Tech Stack

```
SwiftUI          → All UI
SwiftData        → Local persistence (recipes, favorites, history)
@Observable      → State management (replaces Zustand)
DispatchSourceTimer → Precision timers (replaces JS setInterval)
TabView          → Tab navigation
NavigationStack  → Screen navigation
UIImpactFeedbackGenerator → Haptics (replaces expo-haptics)
```

---

## Quick Start for Claude Code

```
1. Read ARCHITECTURE.md
2. Read DATA_MODELS.md
3. Read LIQUID_GLASS_GUIDE.md
4. Read SCREENS.md
5. Follow IMPLEMENTATION_GUIDE.md step by step
```

Create the Xcode project as: **AeroPressGuide** (Bundle ID: `com.yourname.aeropressguide`)
