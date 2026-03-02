# IMPLEMENTATION_GUIDE.md — Step-by-Step Build Order

## Prerequisites

- Xcode 26+ (beta or release)
- macOS 15+
- iOS 26 Simulator or physical device with iOS 26+
- No third-party dependencies (pure Apple frameworks)

---

## Step 0: Create Xcode Project

1. File → New → Project → iOS → App
2. **Product Name:** AeroPressGuide
3. **Team:** Your team
4. **Bundle ID:** com.yourname.aeropressguide
5. **Interface:** SwiftUI
6. **Language:** Swift
7. **Storage:** None (we'll add SwiftData manually)
8. **Minimum Deployment:** iOS 26.0

Delete the template `ContentView.swift` — we'll build our own.

---

## Step 1: Project Setup

### 1.1 Add Colors to Assets.xcassets

Create these named colors (support Dark Mode with appropriate variants):

| Asset Name | Light Mode | Dark Mode |
|------------|-----------|-----------|
| BrandPrimary | #2C1810 | #D4A574 |
| BrandSecondary | #8B4513 | #C0956A |
| BrandAccent | #D4A574 | #D4A574 |
| BrandBackground | #FAF8F5 | #1A1210 |
| BrandSurface | #FFFFFF | #2A1E18 |
| BrandBorder | #E8E4E0 | #3A2E28 |
| BrandTimerActive | #E65100 | #FF6B00 |
| BrandWarning | #FF9800 | #FF9800 |
| DifficultyGreen | #4CAF50 | #66BB6A |
| DifficultyOrange | #FF9800 | #FFA726 |
| DifficultyRed | #F44336 | #EF5350 |

### 1.2 Create folder structure
```
mkdir -p AeroPressGuide/Models
mkdir -p AeroPressGuide/Stores
mkdir -p AeroPressGuide/Views/RecipeList
mkdir -p AeroPressGuide/Views/RecipeDetail
mkdir -p AeroPressGuide/Views/Brew
mkdir -p AeroPressGuide/Views/Favorites
mkdir -p AeroPressGuide/Views/History
mkdir -p AeroPressGuide/Views/Components
mkdir -p AeroPressGuide/Services
mkdir -p AeroPressGuide/Extensions
```

---

## Step 2: Extensions

### Extensions/TimeInterval+Format.swift
```swift
import Foundation

extension Int {
    /// Formats seconds as "M:SS" or "Xs"
    var formattedTime: String {
        let mins = self / 60
        let secs = self % 60
        if mins == 0 { return "\(secs)s" }
        return "\(mins):\(String(format: "%02d", secs))"
    }
    
    /// Formats seconds as "X min" or "M:SS min"
    var formattedDuration: String {
        if self < 60 { return "\(self)s" }
        let mins = self / 60
        let secs = self % 60
        if secs == 0 { return "\(mins) min" }
        return "\(mins):\(String(format: "%02d", secs)) min"
    }
}

extension Date {
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "hr-HR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
```

---

## Step 3: Data Models

Create all files from `DATA_MODELS.md`:

**Build order:**
1. `Models/Step.swift`
2. `Models/Recipe.swift` (depends on Step)
3. `Models/BrewSession.swift`
4. `Models/SeedData.swift`

**Verify:** Project builds without errors before continuing.

---

## Step 4: Services

### Services/TimerService.swift

```swift
import Foundation
import Observation

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case complete
}

@Observable
final class TimerService {
    private(set) var remaining: Int = 0
    private(set) var state: TimerState = .idle
    private var duration: Int = 0
    
    private var timer: DispatchSourceTimer?
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return Double(duration - remaining) / Double(duration)
    }
    
    var formattedRemaining: String {
        remaining.formattedTime
    }
    
    func configure(duration: Int) {
        cancel()
        self.duration = duration
        self.remaining = duration
        self.state = .idle
    }
    
    func start() {
        guard state != .complete, duration > 0 else { return }
        state = .running
        
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now() + 1, repeating: 1.0)
        timer?.setEventHandler { [weak self] in
            guard let self else { return }
            if self.remaining <= 1 {
                self.remaining = 0
                self.state = .complete
                self.timer?.cancel()
                self.timer = nil
            } else {
                self.remaining -= 1
            }
        }
        timer?.resume()
    }
    
    func pause() {
        guard state == .running else { return }
        timer?.cancel()
        timer = nil
        state = .paused
    }
    
    func reset() {
        cancel()
        remaining = duration
        state = .idle
    }
    
    private func cancel() {
        timer?.cancel()
        timer = nil
    }
    
    deinit {
        cancel()
    }
}
```

---

## Step 5: Stores

### Stores/RecipeStore.swift

```swift
import Foundation
import SwiftData
import Observation

@Observable
final class RecipeStore {
    private var modelContext: ModelContext
    
    private(set) var allRecipes: [Recipe] = []
    
    var favoriteRecipes: [Recipe] {
        allRecipes.filter { $0.isFavorite }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchRecipes()
    }
    
    func fetchRecipes() {
        let descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        allRecipes = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        recipe.isFavorite.toggle()
        try? modelContext.save()
        // @Observable will automatically notify views
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        recipe.isFavorite
    }
    
    func addCustomRecipe(_ recipe: Recipe) {
        modelContext.insert(recipe)
        try? modelContext.save()
        fetchRecipes()
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        modelContext.delete(recipe)
        try? modelContext.save()
        fetchRecipes()
    }
}
```

### Stores/BrewSessionStore.swift

```swift
import Foundation
import SwiftData
import Observation

@Observable
final class BrewSessionStore {
    private var modelContext: ModelContext
    private(set) var sessions: [BrewSession] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchSessions()
    }
    
    func fetchSessions() {
        let descriptor = FetchDescriptor<BrewSession>(
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        let all = (try? modelContext.fetch(descriptor)) ?? []
        sessions = Array(all.prefix(100))
    }
    
    func addSession(_ session: BrewSession) {
        modelContext.insert(session)
        try? modelContext.save()
        fetchSessions()
    }
    
    func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
        try? modelContext.save()
        fetchSessions()
    }
}
```

---

## Step 6: App Entry Point

### AeroPressGuideApp.swift

```swift
import SwiftUI
import SwiftData

@main
struct AeroPressGuideApp: App {
    let container: ModelContainer
    
    @State private var recipeStore: RecipeStore
    @State private var sessionStore: BrewSessionStore
    
    init() {
        do {
            container = try ModelContainer(for: Recipe.self, Step.self, BrewSession.self)
        } catch {
            fatalError("SwiftData container error: \(error)")
        }
        
        let context = container.mainContext
        _recipeStore = State(initialValue: RecipeStore(modelContext: context))
        _sessionStore = State(initialValue: BrewSessionStore(modelContext: context))
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
                .environment(recipeStore)
                .environment(sessionStore)
                .onAppear { seedIfNeeded() }
        }
    }
    
    private func seedIfNeeded() {
        guard recipeStore.allRecipes.isEmpty else { return }
        let context = container.mainContext
        for recipe in SeedData.allRecipes() {
            context.insert(recipe)
        }
        try? context.save()
        recipeStore.fetchRecipes()
    }
}
```

---

## Step 7: Components

Build these in order (they have no interdependencies):

1. `Views/Components/DifficultyBadge.swift` — from SCREENS.md
2. `Views/Components/ProgressDotsView.swift` — from SCREENS.md
3. `Views/Components/ParameterGridView.swift` — from SCREENS.md

**FavoriteButton.swift** (shared across views):
```swift
struct FavoriteButton: View {
    let recipe: Recipe
    @Environment(RecipeStore.self) private var store
    
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            store.toggleFavorite(recipe)
        } label: {
            Image(systemName: recipe.isFavorite ? "bookmark.fill" : "bookmark")
                .foregroundStyle(recipe.isFavorite ? Color("BrandAccent") : .secondary)
        }
        .buttonStyle(.plain)
    }
}
```

---

## Step 8: Views (Build Order)

Build screens in this order — each builds on the previous:

### 8.1 RecipeCardView
### 8.2 RecipeListView
### 8.3 RecipeDetailView
### 8.4 TimerView (see LIQUID_GLASS_GUIDE.md)
### 8.5 BrewStepView
### 8.6 BrewCompleteSheet
### 8.7 BrewView (puts 8.4 + 8.5 + 8.6 together)
### 8.8 FavoritesView
### 8.9 HistoryView (HistoryRowView + HistoryView)
### 8.10 RootView

---

## Step 9: Final Wiring

Make sure `RootView.swift` correctly wraps everything:

```swift
struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                RecipeListView()
            }
            .tabItem { Label("Recepti", systemImage: "cup.and.saucer.fill") }
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem { Label("Favoriti", systemImage: "bookmark.fill") }
            
            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("Povijest", systemImage: "clock.fill") }
        }
    }
}
```

---

## Step 10: QA Checklist

Before considering the app done, verify:

**Timer behaviour:**
- [ ] Timer does NOT start on step load
- [ ] Play button starts timer
- [ ] Pause button pauses timer  
- [ ] Reset button resets to full duration
- [ ] Navigating to next/prev step resets timer to idle
- [ ] Complete state triggers haptic success notification
- [ ] Timer continues running if user scrolls (it shouldn't need to — timer is in TimerService, not the view)

**Navigation:**
- [ ] Swipe left/right on BrewView advances/goes back steps
- [ ] Close (X) button dismisses BrewView
- [ ] "Završi" on last step shows BrewCompleteSheet
- [ ] "Spremi" saves session and dismisses all sheets
- [ ] "Preskoči" saves session without rating and dismisses

**Persistence:**
- [ ] Favorites persist across app restarts
- [ ] Brew history persists across app restarts
- [ ] History is capped at 100 sessions

**Liquid Glass:**
- [ ] Glass only on navigation/control elements
- [ ] No glass on recipe cards or content
- [ ] Timer controls are in GlassEffectContainer
- [ ] Nav buttons are in GlassEffectContainer
- [ ] "KRENI" button has tinted glass
- [ ] Close button has interactive glass

**Haptics:**
- [ ] Tap recipe card → light impact
- [ ] Tap favorite → light impact
- [ ] Tap KRENI → medium impact
- [ ] Step change → light impact
- [ ] Brew complete → success notification
- [ ] Star rating → light impact

---

## Common Pitfalls

**Problem:** `@Observable` store not updating views  
**Fix:** Make sure `@Environment(RecipeStore.self)` is used, not `@EnvironmentObject`

**Problem:** Timer drifts over time  
**Fix:** `DispatchSourceTimer` handles this — don't use `Timer.scheduledTimer`

**Problem:** Glass effect not appearing  
**Fix:** Ensure deployment target is iOS 26.0. Check Xcode 26 is selected.

**Problem:** SwiftData relationship not loading steps  
**Fix:** Access `recipe.sortedSteps` not `recipe.steps` directly (the sort matters)

**Problem:** BrewView timer resets mid-session when app backgrounds  
**Fix:** Add `.backgroundTask` handling or use `@Environment(\.scenePhase)` to pause timer on background

**Problem:** TabView swipe conflict with BrewView page swipe  
**Fix:** BrewView is presented as `fullScreenCover`, not inside TabView — no conflict

---

## Nice-to-Have Additions (Post-MVP)

These are NOT in scope for the initial build but can be added later:

- Custom recipe creation UI (form with steps)
- Recipe edit/delete for custom recipes
- iCloud sync via CloudKit + SwiftData
- Bluetooth thermometer integration via CoreBluetooth
- Widget (WidgetKit) showing today's brew count
- Dynamic Island timer display (ActivityKit)
- Siri Shortcuts integration
- Share recipe as image
