# SCREENS.md — Every Screen: Layout, Components & Behaviour

## Screen Map

```
RootView
├── RecipeListView      (Tab 1)
│   └── RecipeDetailView
│       └── BrewView (fullScreenCover)
│           └── BrewCompleteSheet (.sheet)
├── FavoritesView       (Tab 2)
│   └── RecipeDetailView (reused)
└── HistoryView         (Tab 3)
```

---

## 1. RootView

**File:** `Views/RootView.swift`

```swift
struct RootView: View {
    @State private var selectedTab: Tab = .recipes
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                RecipeListView()
            }
            .tabItem { Label("Recepti", systemImage: "cup.and.saucer.fill") }
            .tag(Tab.recipes)
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem { Label("Favoriti", systemImage: "bookmark.fill") }
            .tag(Tab.favorites)
            
            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("Povijest", systemImage: "clock.fill") }
            .tag(Tab.history)
        }
        // iOS 26: TabView automatically renders with Liquid Glass
    }
}

enum Tab: CaseIterable {
    case recipes, favorites, history
}
```

---

## 2. RecipeListView

**File:** `Views/RecipeList/RecipeListView.swift`

**Layout:**
- `NavigationStack` title: "AeroPress" (large title)
- `ScrollView` with `LazyVStack` of `RecipeCardView`
- No header image — cards fill the list

**Behaviour:**
- Load all recipes from `RecipeStore` (predefined + custom)
- Tap card → navigate to `RecipeDetailView`
- Heart button on card → `toggleFavorite`

**Key code:**
```swift
struct RecipeListView: View {
    @Environment(RecipeStore.self) private var store
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.allRecipes) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("AeroPress")
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }
}
```

---

## 3. RecipeCardView

**File:** `Views/RecipeList/RecipeCardView.swift`

**Layout (horizontal card):**
```
┌────────────────────────────────────────┐
│ [80x80 image] │ Name (bold)      ♡    │
│               │ Author                 │
│               │ 🕐 2min  ☕ 11g  💧200ml│
│               │ [Početnik] Standard   │
└────────────────────────────────────────┘
```

**Behaviour:**
- Card: subtle shadow, `RoundedRectangle(cornerRadius: 16)`
- Press scale: `scaleEffect(isPressed ? 0.97 : 1.0).animation(.spring, value: isPressed)`
- Heart: `UIImpactFeedbackGenerator(.light)` on tap
- **No glass on card** — card is content layer

**Key code:**
```swift
struct RecipeCardView: View {
    let recipe: Recipe
    @Environment(RecipeStore.self) private var store
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: recipe.sortedSteps.first?.imageURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color("BrandBorder")
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    FavoriteButton(recipe: recipe)
                }
                Text(recipe.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    Label(recipe.totalTime.formattedDuration, systemImage: "clock")
                    Label("\(Int(recipe.coffeeAmount))g", systemImage: "cup.and.saucer")
                    Label("\(Int(recipe.waterAmount))ml", systemImage: "drop")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                HStack {
                    DifficultyBadge(difficulty: recipe.difficulty)
                    Spacer()
                    Text(recipe.method.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color("BrandSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("BrandPrimary").opacity(0.08), radius: 8, y: 2)
    }
}
```

---

## 4. RecipeDetailView

**File:** `Views/RecipeDetail/RecipeDetailView.swift`

**Layout:**
- `ScrollView`
- Hero image (full-width, 220pt height)
- Title + author
- Parameters grid (2x2: coffee/water/temp/ratio) — card style
- Info row: total time | difficulty | method
- Steps preview (first 3, then "+ još X koraka")
- Fixed bottom bar with "KRENI" button

**Key elements:**

```swift
struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showBrew = false
    @Environment(RecipeStore.self) private var store
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                content
            }
            .padding(.bottom, 100)   // space for bottom bar
        }
        .overlay(alignment: .bottom) {
            bottomBar
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(recipe: recipe)
            }
        }
        .fullScreenCover(isPresented: $showBrew) {
            BrewView(recipe: recipe)
        }
    }
    
    private var bottomBar: some View {
        // Glass KRENI button floating over content
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showBrew = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text("KRENI")
                    .fontWeight(.bold)
                    .kerning(1)
                Image(systemName: "chevron.right")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .glassEffect(.regular.tint(Color("BrandPrimary")).interactive(),
                     in: RoundedRectangle(cornerRadius: 28))
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .background(.ultraThinMaterial)    // blur behind the glass button
    }
}
```

**ParameterGridView:**
```swift
struct ParameterGridView: View {
    let recipe: Recipe
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                ParameterCell(icon: "cup.and.saucer.fill",
                              value: "\(Int(recipe.coffeeAmount))g",
                              label: "Kava")
                ParameterCell(icon: "drop.fill",
                              value: "\(Int(recipe.waterAmount))ml",
                              label: "Voda")
            }
            GridRow {
                ParameterCell(icon: "thermometer",
                              value: "\(recipe.waterTemperature)°C",
                              label: "Temperatura")
                ParameterCell(icon: "scalemass",
                              value: recipe.ratio,
                              label: "Omjer")
            }
        }
        .padding(16)
        .background(Color("BrandSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("BrandPrimary").opacity(0.06), radius: 8, y: 2)
    }
}
```

---

## 5. BrewView

**File:** `Views/Brew/BrewView.swift`

**Layout:**
```
┌────────────────────────────────────────┐
│ [X]                        2/9         │ ← glass buttons
├────────────────────────────────────────┤
│                                        │
│           Step Image                   │ ← content (no glass)
│           (scrollable via swipe)       │
│                                        │
│    Step Title                          │
│    Step Description                    │
│                                        │
│    [Timer Card — glass]                │
│                                        │
├────────────────────────────────────────┤
│   ●●●●○○○○○  ← progress dots          │
│   [←]        [Dalje →]                │ ← glass buttons
└────────────────────────────────────────┘
```

**Behaviour:**
- Present as `fullScreenCover` with `slide_from_bottom` feel (use `.transition(.move(edge: .bottom))`)
- **TabView with `.page` style** for swipe navigation — smooth native gesture
- Step indicator "2/9" top right
- Close button top left — `UIImpactFeedbackGenerator(.light)` on tap
- Timer: **never auto-starts**, user must tap play
- On last step → "Završi" button → show `BrewCompleteSheet`
- Haptics: `.light` on step change, `.success` notification on complete

**Core structure:**
```swift
struct BrewView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @State private var currentStepIndex: Int = 0
    @State private var showComplete: Bool = false
    @State private var timerService = TimerService()
    
    private var steps: [Step] { recipe.sortedSteps }
    private var isLastStep: Bool { currentStepIndex == steps.count - 1 }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content: swipeable steps
            TabView(selection: $currentStepIndex) {
                ForEach(steps.indices, id: \.self) { index in
                    BrewStepView(step: steps[index], timerService: timerService)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .onChange(of: currentStepIndex) { _, newIndex in
                timerService.reset()
                // Timer reset on step change — NEVER auto-start
                timerService.configure(duration: steps[newIndex].timerDuration ?? 0)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            
            // Floating bottom controls (glass)
            bottomControls
        }
        .overlay(alignment: .topLeading) {
            closeButton
        }
        .overlay(alignment: .topTrailing) {
            stepIndicator
        }
        .sheet(isPresented: $showComplete) {
            BrewCompleteSheet(recipe: recipe)
        }
        .onAppear {
            // Configure timer for first step if it has one
            if let duration = steps.first?.timerDuration {
                timerService.configure(duration: duration)
            }
        }
    }
    
    private var bottomControls: some View {
        VStack(spacing: 0) {
            ProgressDotsView(total: steps.count, current: currentStepIndex)
                .padding(.bottom, 8)
            
            GlassEffectContainer {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            currentStepIndex = max(0, currentStepIndex - 1)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 48, height: 48)
                    }
                    .glassEffect(.regular.interactive())
                    .disabled(currentStepIndex == 0)
                    .opacity(currentStepIndex == 0 ? 0.4 : 1.0)
                    
                    Button {
                        if isLastStep {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            showComplete = true
                        } else {
                            withAnimation(.spring(duration: 0.3)) {
                                currentStepIndex += 1
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(isLastStep ? "Završi" : "Dalje")
                                .fontWeight(.semibold)
                            Image(systemName: isLastStep ? "checkmark" : "chevron.right")
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                    }
                    .glassEffect(.regular.tint(Color("BrandPrimary")).interactive())
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 16)
    }
    
    private var closeButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 40, height: 40)
        }
        .glassEffect(.regular.interactive())
        .padding(.top, 60)
        .padding(.leading, 16)
    }
    
    private var stepIndicator: some View {
        Text("\(currentStepIndex + 1)/\(steps.count)")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 60)
            .padding(.trailing, 16)
    }
}
```

---

## 6. BrewStepView

**File:** `Views/Brew/BrewStepView.swift`

```swift
struct BrewStepView: View {
    let step: Step
    let timerService: TimerService
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                AsyncImage(url: URL(string: step.imageURL ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color("BrandBorder")
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.42)
                .clipped()
                
                // Step content
                VStack(alignment: .leading, spacing: 16) {
                    Text(step.title)
                        .font(.title2.weight(.bold))
                    
                    Text(step.stepDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                    
                    if step.hasTimer, let duration = step.timerDuration {
                        TimerView(timerService: timerService, duration: duration)
                            .padding(.top, 8)
                    }
                }
                .padding(20)
                .padding(.bottom, 140)    // space for bottom controls
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
```

---

## 7. TimerView

**File:** `Views/Brew/TimerView.swift`  
See `LIQUID_GLASS_GUIDE.md` for full implementation.

Key behaviour rules:
- **State `.idle`**: show "Pokreni timer" button — user MUST tap
- **State `.running`**: show pause + reset in GlassEffectContainer
- **State `.paused`**: show resume + reset  
- **State `.complete`**: haptic notification, green checkmark, pulse animation
- Timer display: `font(.system(size: 56, weight: .bold, design: .monospaced))`
- Progress bar: `ProgressView(value: timerService.progress)` with `.tint(Color("BrandTimerActive"))`

---

## 8. BrewCompleteSheet

**File:** `Views/Brew/BrewCompleteSheet.swift`

**Layout:** Native `.sheet` with `presentationDetents([.medium])`

```swift
struct BrewCompleteSheet: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Environment(BrewSessionStore.self) private var sessionStore
    
    @State private var rating: Int = 0
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Coffee cup icon
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color("BrandAccent"))
                    .padding(20)
                    .glassEffect(.regular, in: Circle())
                
                Text("Kava je spremna!")
                    .font(.title2.weight(.bold))
                Text("Kako ti se svidjela?")
                    .foregroundStyle(.secondary)
                
                // Star rating
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            rating = star
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 36))
                                .foregroundStyle(star <= rating ? Color("BrandWarning") : Color.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Notes input
                TextField("Dodaj bilješku...", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(16)
                    .background(Color("BrandBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Buttons
                VStack(spacing: 12) {
                    Button("Spremi") {
                        save(withRating: rating > 0 ? rating : nil, notes: notes)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassEffect(.regular.tint(Color("BrandPrimary")).interactive(),
                                 in: RoundedRectangle(cornerRadius: 28))
                    
                    Button("Preskoči") {
                        save(withRating: nil, notes: nil)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func save(withRating r: Int?, notes n: String?) {
        sessionStore.addSession(BrewSession(
            recipeID: recipe.id,
            recipeName: recipe.name,
            rating: r,
            notes: n?.isEmpty == false ? n : nil
        ))
        dismiss()
    }
}
```

---

## 9. FavoritesView

**File:** `Views/Favorites/FavoritesView.swift`

Identical layout to `RecipeListView` but filters `store.favoriteRecipes`.

```swift
struct FavoritesView: View {
    @Environment(RecipeStore.self) private var store
    
    var body: some View {
        Group {
            if store.favoriteRecipes.isEmpty {
                ContentUnavailableView("Nemaš favorita",
                    systemImage: "bookmark",
                    description: Text("Dodaj recepte u favorite pritiskom na oznaku"))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.favoriteRecipes) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeCardView(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("Favoriti")
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }
}
```

---

## 10. HistoryView

**File:** `Views/History/HistoryView.swift`

```swift
struct HistoryView: View {
    @Environment(BrewSessionStore.self) private var sessionStore
    
    var body: some View {
        Group {
            if sessionStore.sessions.isEmpty {
                ContentUnavailableView("Još nema povijesti",
                    systemImage: "clock",
                    description: Text("Pripremi prvu kavu i ovdje će se pojaviti tvoja povijest"))
            } else {
                List {
                    ForEach(sessionStore.sessions) { session in
                        HistoryRowView(session: session)
                    }
                    .onDelete { indexSet in
                        sessionStore.deleteSessions(at: indexSet)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Povijest")
    }
}

struct HistoryRowView: View {
    let session: BrewSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundStyle(Color("BrandAccent"))
                    .frame(width: 44, height: 44)
                    .background(Color("BrandPrimary").opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.recipeName)
                        .font(.headline)
                    Text(session.completedAt.relativeFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let rating = session.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color("BrandWarning"))
                        Text("\(rating)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("BrandWarning").opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            if let notes = session.notes {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
```

---

## 11. ProgressDotsView

**File:** `Views/Components/ProgressDotsView.swift`

```swift
struct ProgressDotsView: View {
    let total: Int
    let current: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(dotColor(for: index))
                    .frame(width: dotSize(for: index), height: dotSize(for: index))
                    .animation(.spring(duration: 0.3), value: current)
            }
        }
    }
    
    private func dotColor(for index: Int) -> Color {
        if index == current { return Color("BrandPrimary") }
        if index < current  { return Color("BrandAccent") }
        return Color("BrandBorder")
    }
    
    private func dotSize(for index: Int) -> CGFloat {
        index == current ? 10 : 8
    }
}
```

---

## 12. DifficultyBadge

**File:** `Views/Components/DifficultyBadge.swift`

```swift
struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var body: some View {
        Text(difficulty.localizedName)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(Color(difficulty.color))
            .background(Color(difficulty.color).opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
```
