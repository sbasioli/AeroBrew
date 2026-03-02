# ARCHITECTURE.md — AeroPress Brew Guide (Swift)

## App Architecture: MVVM + SwiftData

```
┌─────────────────────────────────────────────────┐
│                   SwiftUI Views                  │
│  (ContentView, RecipeListView, BrewView, etc.)   │
└──────────────────┬──────────────────────────────┘
                   │ reads/writes via @Environment
┌──────────────────▼──────────────────────────────┐
│              @Observable Stores                  │
│   RecipeStore  │  BrewSessionStore  │  AppState  │
└──────────────────┬──────────────────────────────┘
                   │ @Model objects
┌──────────────────▼──────────────────────────────┐
│                  SwiftData                       │
│     ModelContainer  →  ModelContext              │
│     Recipe  │  BrewSession  │  UserPreferences   │
└─────────────────────────────────────────────────┘
```

---

## File & Folder Structure

```
AeroPressGuide/
├── AeroPressGuideApp.swift          # App entry, ModelContainer setup
├── CLAUDE.md                        # This documentation (copy here)
│
├── Models/
│   ├── Recipe.swift                 # @Model Recipe + Step
│   ├── BrewSession.swift            # @Model BrewSession
│   └── SeedData.swift               # Predefined recipes (James Hoffmann etc.)
│
├── Stores/
│   ├── RecipeStore.swift            # @Observable — recipe CRUD, favorites
│   └── BrewSessionStore.swift       # @Observable — history management
│
├── Views/
│   ├── RootView.swift               # TabView entry point
│   │
│   ├── RecipeList/
│   │   ├── RecipeListView.swift     # Tab 1: scrollable recipe list
│   │   └── RecipeCardView.swift     # Individual recipe card
│   │
│   ├── RecipeDetail/
│   │   └── RecipeDetailView.swift   # Recipe params + start button
│   │
│   ├── Brew/
│   │   ├── BrewView.swift           # Full-screen brew guide
│   │   ├── BrewStepView.swift       # Single step display
│   │   ├── TimerView.swift          # Timer component
│   │   └── BrewCompleteSheet.swift  # Rating + notes bottom sheet
│   │
│   ├── Favorites/
│   │   └── FavoritesView.swift      # Tab 2: favorited recipes
│   │
│   ├── History/
│   │   └── HistoryView.swift        # Tab 3: brew sessions
│   │
│   └── Components/
│       ├── ProgressDotsView.swift   # Step progress indicator
│       ├── ParameterGridView.swift  # Coffee/water/temp/ratio grid
│       └── DifficultyBadge.swift    # Colored difficulty label
│
├── Services/
│   └── TimerService.swift           # DispatchSourceTimer wrapper
│
└── Extensions/
    ├── Color+Brand.swift            # Brand color palette
    └── TimeInterval+Format.swift    # formatTime(), formatTotalTime()
```

---

## Navigation Structure

```
RootView (TabView)
├── Tab 1: RecipeListView
│   └── NavigationStack
│       └── RecipeDetailView(recipe)
│           └── .fullScreenCover → BrewView(recipe)
│               └── .sheet → BrewCompleteSheet
│
├── Tab 2: FavoritesView
│   └── NavigationStack
│       └── RecipeDetailView(recipe)  [reused]
│
└── Tab 3: HistoryView
```

---

## State Management

### RecipeStore (@Observable)
```swift
@Observable final class RecipeStore {
    var customRecipes: [Recipe] = []        // from SwiftData
    var favoriteIDs: Set<String> = []       // persisted in SwiftData
    
    var allRecipes: [Recipe]                // computed: seed + custom
    var favoriteRecipes: [Recipe]           // computed: filtered
    
    func toggleFavorite(_ id: String)
    func addCustomRecipe(_ recipe: Recipe)
    func deleteRecipe(_ id: String)
}
```

### BrewSessionStore (@Observable)
```swift
@Observable final class BrewSessionStore {
    var sessions: [BrewSession] = []        // from SwiftData, max 100
    
    func addSession(_ session: BrewSession)
    func deleteSession(_ id: String)
}
```

### TimerService (per BrewView instance)
```swift
@Observable final class TimerService {
    var remaining: Int = 0
    var state: TimerState = .idle           // idle | running | paused | complete
    var progress: Double = 0.0
    
    // Uses DispatchSourceTimer — not setInterval
    func start()
    func pause()
    func reset()
    func configure(duration: Int)
}
```

---

## Data Flow: Brew Session

```
User taps "KRENI" on RecipeDetailView
    → BrewView presented fullScreenCover
    → BrewView owns TimerService instance
    → User swipes/taps through steps
    → On last step "Završi" → BrewCompleteSheet appears
    → User rates + notes → BrewSessionStore.addSession()
    → Sheet dismisses → BrewView dismisses → back to RecipeDetail
```

---

## Persistence via SwiftData

```swift
// In AeroPressGuideApp.swift
var sharedModelContainer: ModelContainer = {
    let schema = Schema([Recipe.self, BrewSession.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: false)
    return try! ModelContainer(for: schema, configurations: [config])
}()

// Seed predefined recipes on first launch (check if empty)
```

**Key decision:** Predefined recipes (James Hoffmann etc.) are seeded into SwiftData on first launch via `SeedData.swift`. This way favorites work uniformly for both predefined and custom recipes.
