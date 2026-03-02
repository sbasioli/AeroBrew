# LIQUID_GLASS_GUIDE.md — How to Use Liquid Glass in This App

## Official Reference
- https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass
- https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)
- https://developer.apple.com/documentation/swiftui/glasseffectcontainer
- https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views

**Requires:** iOS 26+, Xcode 26+

---

## Core API

```swift
// Basic usage
Text("Hello")
    .padding()
    .glassEffect()                                    // default: .regular, .capsule

// With shape
Button("Start") { }
    .padding()
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))

// Tinted (for primary CTA only)
Button("KRENI") { }
    .glassEffect(.regular.tint(.orange).interactive())

// Interactive (responds to touch in real-time)
Image(systemName: "play.fill")
    .glassEffect(.regular.interactive())

// Multiple elements that should blend/morph together
GlassEffectContainer {
    HStack(spacing: 16) {
        Button("Pause") { }.glassEffect()
        Button("Reset") { }.glassEffect()
    }
}

// Glass variants
.glassEffect()                     // .regular — standard frosted glass
.glassEffect(.clear)               // .clear — more transparent
.glassEffect(.identity)            // .identity — fallback/no-op (for accessibility)
```

---

## The Golden Rules

### Rule 1: Glass belongs on the NAVIGATION layer, not content
```swift
// ✅ CORRECT — glass on floating controls over content
ZStack {
    ScrollView { recipeList }         // content — NO glass
    VStack {
        Spacer()
        BrewButton().glassEffect()    // floating control — YES glass
    }
}

// ❌ WRONG — glass on list cells
List(recipes) { recipe in
    RecipeCardView(recipe)
        .glassEffect()               // DON'T
}
```

### Rule 2: Use GlassEffectContainer for grouped elements
```swift
// ✅ Glass cannot sample other glass — container prevents this
GlassEffectContainer {
    HStack(spacing: 12) {
        pauseButton.glassEffect()
        resetButton.glassEffect()
    }
}

// ❌ Without container = inconsistent, expensive rendering
HStack {
    pauseButton.glassEffect()
    resetButton.glassEffect()
}
```

### Rule 3: Tint only for semantic meaning (primary CTA)
```swift
// ✅ Tint communicates "this is the primary action"
Button("KRENI") { }
    .glassEffect(.regular.tint(Color("BrandOrange")).interactive())

// ❌ Tint as decoration
Text("Recipe Title")
    .glassEffect(.regular.tint(.blue))   // meaningless, confusing
```

### Rule 4: Single glass layer (no stacking)
```swift
// ✅ One glass layer
view.glassEffect()

// ❌ Glass on glass
VStack {
    HeaderView().glassEffect()    // layer 1
    ContentView().glassEffect()   // layer 2 — can't sample layer 1!
}
```

### Rule 5: Trust the system for accessibility
```swift
// ✅ Let system handle reduceTransparency automatically
Button("Start") { }.glassEffect()

// Only override if truly necessary:
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
.glassEffect(reduceTransparency ? .identity : .regular)
```

---

## Where to Apply Glass in This App

| Element | Glass Usage | Rationale |
|---------|------------|-----------|
| Tab bar (custom) | `GlassEffectContainer { ... }` with `.glassEffect()` per tab | Floating nav layer |
| "KRENI" start button | `.glassEffect(.regular.tint(.orange).interactive())` | Primary CTA |
| Timer controls (Play/Pause/Reset) | `GlassEffectContainer { }` with `.glassEffect()` | Grouped controls |
| Timer display card | `.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))` | Floating over step content |
| Close (X) button in BrewView | `.glassEffect(.regular.interactive())` | Floating control |
| Step nav buttons (←/→) | `GlassEffectContainer { }` with `.glassEffect()` | Grouped nav |
| BrewCompleteSheet | Native `.sheet()` — automatic glass treatment | System handles it |
| Recipe cards | **No glass** | Content layer |
| Parameters card | **No glass** | Content layer |
| History cards | **No glass** | Content layer |
| NavigationStack toolbar | Automatic (system applies glass in iOS 26) | Just use `.toolbar {}` |

---

## Tab Bar Implementation

The custom floating pill tab bar from React Native becomes a native SwiftUI tab bar with Liquid Glass:

```swift
// iOS 26 TabView automatically gets Liquid Glass treatment
TabView(selection: $selectedTab) {
    RecipeListView()
        .tabItem {
            Label("Recepti", systemImage: "cup.and.saucer.fill")
        }
        .tag(Tab.recipes)
    
    FavoritesView()
        .tabItem {
            Label("Favoriti", systemImage: "bookmark.fill")
        }
        .tag(Tab.favorites)
    
    HistoryView()
        .tabItem {
            Label("Povijest", systemImage: "clock.fill")
        }
        .tag(Tab.history)
}
// The tab bar automatically gets Liquid Glass in iOS 26 — no extra code needed!
```

If you want a **custom floating pill** (matching the original design):
```swift
// Custom glass tab bar
struct GlassTabBar: View {
    @Binding var selection: Tab
    
    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 0) {
                ForEach(Tab.allCases) { tab in
                    Spacer()
                    Button {
                        selection = tab
                    } label: {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: selection == tab ? .bold : .regular))
                            .foregroundStyle(selection == tab ? Color("BrandAccent") : .secondary)
                            .frame(width: 48, height: 48)
                    }
                    .glassEffect(selection == tab ? .regular.tint(Color("BrandAccent").opacity(0.2)) : .regular)
                    Spacer()
                }
            }
        }
        .frame(width: 200, height: 64)
        .clipShape(Capsule())
    }
}
```

---

## Timer View Glass Pattern

```swift
struct TimerView: View {
    let timerService: TimerService
    
    var body: some View {
        VStack(spacing: 16) {
            // Time display — glass card floating over step content
            Text(timerService.formattedRemaining)
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundStyle(timerService.state == .running ? .white : .primary)
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .glassEffect(
                    timerService.state == .running
                        ? .regular.tint(Color("BrandOrange"))
                        : .regular,
                    in: RoundedRectangle(cornerRadius: 20)
                )
            
            // Progress bar (custom, not glass)
            ProgressView(value: timerService.progress)
                .tint(Color("BrandOrange"))
                .padding(.horizontal)
            
            // Controls
            GlassEffectContainer {
                HStack(spacing: 16) {
                    switch timerService.state {
                    case .idle:
                        Button {
                            timerService.start()
                        } label: {
                            Label("Pokreni", systemImage: "play.fill")
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        }
                        .glassEffect(.regular.tint(Color("BrandPrimary")).interactive())
                        
                    case .running:
                        Button { timerService.pause() } label: {
                            Image(systemName: "pause.fill")
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.regular.interactive())
                        
                        Button { timerService.reset() } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.regular.interactive())
                        
                    case .paused:
                        Button { timerService.start() } label: {
                            Label("Nastavi", systemImage: "play.fill")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                        }
                        .glassEffect(.regular.tint(Color("BrandPrimary")).interactive())
                        
                        Button { timerService.reset() } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.regular.interactive())
                        
                    case .complete:
                        Label("Gotovo!", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .padding()
                    }
                }
            }
        }
    }
}
```

---

## BrewView Glass Pattern (Floating Controls Over Step Content)

```swift
struct BrewView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content layer — NO glass
            TabView(selection: $currentStepIndex) {
                ForEach(recipe.steps.indices, id: \.self) { index in
                    BrewStepView(step: recipe.steps[index], timerService: timerService)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Floating control layer — GLASS
            VStack(spacing: 0) {
                ProgressDotsView(total: recipe.steps.count, current: currentStepIndex)
                
                GlassEffectContainer {
                    HStack(spacing: 12) {
                        // Back button
                        Button { goBack() } label: {
                            Image(systemName: "chevron.left")
                                .frame(width: 48, height: 48)
                        }
                        .glassEffect(.regular.interactive())
                        .disabled(currentStepIndex == 0)
                        
                        // Next/Finish button
                        Button { goNext() } label: {
                            HStack {
                                Text(isLastStep ? "Završi" : "Dalje")
                                Image(systemName: isLastStep ? "checkmark" : "chevron.right")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                        }
                        .glassEffect(.regular.tint(Color("BrandPrimary")).interactive())
                    }
                }
                .padding(.bottom, 32)
            }
            .padding()
            
            // Close button (top-leading)
            // Position with .overlay + .topLeading alignment
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .frame(width: 40, height: 40)
            }
            .glassEffect(.regular.interactive())
            .padding()
        }
    }
}
```

---

## GlassEffect with Morphing (glassEffectID)

For the timer controls that change state, use `glassEffectID` for smooth morphing:

```swift
GlassEffectContainer {
    Group {
        if timerService.state == .idle {
            startButton
                .glassEffectID("primary", in: namespace)
        } else {
            pauseButton
                .glassEffectID("primary", in: namespace)
        }
    }
}

// Requires @Namespace var namespace in the parent view
```

---

## Brand Colors (Color+Brand.swift)

```swift
extension Color {
    static let brandPrimary    = Color(red: 0.173, green: 0.094, blue: 0.063)  // #2C1810
    static let brandSecondary  = Color(red: 0.545, green: 0.271, blue: 0.075)  // #8B4513
    static let brandAccent     = Color(red: 0.831, green: 0.647, blue: 0.455)  // #D4A574
    static let brandBackground = Color(red: 0.980, green: 0.973, blue: 0.961)  // #FAF8F5
    static let brandSurface    = Color.white
    static let brandTimerActive = Color(red: 0.902, green: 0.314, blue: 0.000) // #E65100
}
```

Add these to `Assets.xcassets` as named colors for both light and dark mode support.
